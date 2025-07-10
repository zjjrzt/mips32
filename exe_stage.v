//执行模块
module exe_stage(
    input wire rst_n,

    //译码阶段输出接口
    input wire [2:0] exe_alutype_i,
    input wire [7:0] exe_aluop_i,
    input wire [31:0] exe_src1_i,
    input wire [31:0] exe_src2_i,
    input wire [4:0] exe_wa_i,
    input wire exe_wreg_i,
    input wire exe_mreg_i,
    input wire [31:0] exe_din_i,
    input wire exe_whilo_i,

    //从HILO寄存器读取的数据
    input wire [31:0] hi_i,
    input wire [31:0] lo_i,

    //执行阶段输出接口
    output wire [7:0] exe_aluop_o,    //ALU操作码
    output wire [4:0] exe_wa_o,       //写回地址
    output wire [31:0] exe_wd_o,       //写回数据
    output wire exe_wreg_o,     //是否写入寄存器堆
    output wire exe_mreg_o,     //是否访问寄存器堆
    output wire exe_whilo_o,    //是否写入HI/LO寄存器
    output wire [31:0] exe_din_o,       //写入寄存器堆的数据
    output wire [63:0] exe_hilo_o,    //HI/LO寄存器数据
    //从访存阶段获得的HI、LO寄存器数据
    input wire mem_2exe_whilo,
    input wire [63:0] mem_2exe_hilo,
    //从写回阶段获得的HI、LO寄存器数据
    input wire wb2exe_whilo,
    input wire [63:0] wb2exe_hilo,
    //转移指令相关代码
    input wire [31:0] ret_addr,
    //除法运算相关代码
    input wire clk,
    output wire stallreq_exe
);

    // 逻辑运算结果
    wire [31:0] logicres = (rst_n == 1'b0) ? 32'b0 :
        (exe_aluop_i == 8'h1C) ? (exe_src1_i & exe_src2_i) : // AND
        (exe_aluop_i == 8'h1D) ? (exe_src1_i | exe_src2_i) : // ORI
        (exe_aluop_i == 8'h05) ? exe_src2_i : 32'b0;         // LUI

    // 移位运算结果
    wire [31:0] shiftres = (rst_n == 1'b0) ? 32'b0 :
        (exe_aluop_i == 8'h11) ? (exe_src2_i << exe_src1_i) : 32'b0; // SLL

    // HI/LO相关
    wire [31:0] hi_t = (rst_n == 1'b0) ? 32'b0 : 
                        (mem_2exe_whilo) ? mem_2exe_hilo[63:32] :
                        (wb2exe_whilo) ? wb2exe_hilo[63:32] : hi_i;
    wire [31:0] lo_t = (rst_n == 1'b0) ? 32'b0 : 
                        (mem_2exe_whilo) ? mem_2exe_hilo[31:0] :
                        (wb2exe_whilo) ? wb2exe_hilo[31:0] : lo_i;
    wire [31:0] moveres = (rst_n == 1'b0) ? 32'b0 :
        (exe_aluop_i == 8'h0C) ? hi_t : // MFHI
        (exe_aluop_i == 8'h0D) ? lo_t : 32'b0; // MFLO

    // 算术运算结果
    wire [31:0] arithres = (rst_n == 1'b0) ? 32'b0 :
        (exe_aluop_i == 8'h18) ? (exe_src1_i + exe_src2_i) : // ADD
        (exe_aluop_i == 8'h90) ? (exe_src1_i + exe_src2_i) : // LB
        (exe_aluop_i == 8'h92) ? (exe_src1_i + exe_src2_i) : // LW
        (exe_aluop_i == 8'h98) ? (exe_src1_i + exe_src2_i) : // SB
        (exe_aluop_i == 8'h9A) ? (exe_src1_i + exe_src2_i) : // SW
        (exe_aluop_i == 8'h19) ? (exe_src1_i + exe_src2_i) : // ADDIU
        (exe_aluop_i == 8'h1B) ? (exe_src1_i + (~exe_src2_i) + 1) : // SUBU
        (exe_aluop_i == 8'h26) ? (($signed(exe_src1_i) < $signed(exe_src2_i)) ? 32'b1 : 32'b0) : // SLT
        (exe_aluop_i == 8'h27) ? ((exe_src1_i < exe_src2_i) ? 32'b1 : 32'b0) : 32'b0; // SLTIU

    // 乘法结果
    wire [63:0] mulres = $signed(exe_src1_i) * $signed(exe_src2_i);

    // 除法相关信号与状态机（全新实现，标准32次移位减法）
    reg  [63:0] divres;
    reg  [5:0]  div_cnt;
    reg  [1:0]  state;
    reg         div_ready;
    reg  [31:0] dividend_reg, divisor_reg;
    reg  [31:0] quotient, remainder;
    reg         div_sign;
    reg         busy;
    wire        div_start = (rst_n == 1'b0) ? 1'b0 : ((exe_aluop_i == 8'h16) && (div_ready == 1'b0)) ? 1'b1 : 1'b0;
    // 除法暂停信号
    assign stallreq_exe = (rst_n == 1'b0) ? 1'b0 : ((exe_aluop_i == 8'h16) && (div_ready == 1'b0)) ? 1'b1 : 1'b0;

    always @(posedge clk) begin
        if (!rst_n) begin
            state     <= 2'b00;
            div_ready <= 1'b0;
            divres    <= 64'b0;
            busy      <= 1'b0;
            div_cnt   <= 6'd0;
            quotient  <= 32'b0;
            remainder <= 32'b0;
            dividend_reg <= 32'b0;
            divisor_reg  <= 32'b0;
            div_sign     <= 1'b0;
        end else begin
            case (state)
            2'b00: begin // DIV_FREE
                if (div_start) begin
                    state <= 2'b10;
                    busy  <= 1'b1;
                    div_ready <= 1'b0;
                    div_cnt   <= 6'd0;
                    div_sign <= exe_src1_i[31] ^ exe_src2_i[31];
                    dividend_reg <= exe_src1_i[31] ? (~exe_src1_i + 1) : exe_src1_i;
                    divisor_reg  <= exe_src2_i[31] ? (~exe_src2_i + 1) : exe_src2_i;
                    quotient     <= 32'b0;
                    remainder    <= 32'b0;
                end else begin
                    div_ready <= 1'b0;
                    divres    <= 64'b0;
                    busy      <= 1'b0;
                end
            end
            2'b10: begin // DIV_ON
                if (div_cnt < 6'd32) begin
                    {remainder, dividend_reg} = {remainder, dividend_reg} << 1;
                    if (remainder[31:0] >= divisor_reg) begin
                        remainder = remainder - divisor_reg;
                        quotient[31-div_cnt] = 1'b1;
                    end
                    div_cnt = div_cnt + 1;
                end else begin
                    // 符号修正
                    if (div_sign) quotient = ~quotient + 1;
                    if (exe_src1_i[31]) remainder = ~remainder + 1;
                    divres <= {remainder, quotient};
                    div_ready <= 1'b1;
                    state <= 2'b11;
                    busy  <= 1'b0;
                end
            end
            2'b11: begin // DIV_END
                if (!div_start) begin
                    state     <= 2'b00;
                    div_ready <= 1'b0;
                end
            end
            endcase
        end
    end


    // HI/LO输出，支持MULT和DIV
    assign exe_hilo_o = (rst_n == 1'b0) ? 64'b0 :
        (exe_aluop_i == 8'h14) ? mulres :
        (exe_aluop_i == 8'h16) ? divres : 64'b0;

    // 直通信号
    assign exe_aluop_o = (rst_n == 1'b0) ? 8'b0 : exe_aluop_i;
    assign exe_wa_o    = (rst_n == 1'b0) ? 5'b0 : exe_wa_i;
    assign exe_wreg_o  = (rst_n == 1'b0) ? 1'b0 : exe_wreg_i;
    assign exe_mreg_o  = (rst_n == 1'b0) ? 1'b0 : exe_mreg_i;
    assign exe_whilo_o = (rst_n == 1'b0) ? 1'b0 : exe_whilo_i;
    assign exe_din_o   = (rst_n == 1'b0) ? 32'b0 : exe_din_i;

    // 写回数据选择
    assign exe_wd_o = (rst_n == 1'b0) ? 32'b0 :
        (exe_alutype_i == 3'b010) ? logicres : // LOGIC
        (exe_alutype_i == 3'b100) ? shiftres : // SHIFT
        (exe_alutype_i == 3'b011) ? moveres  : // MOVE
        (exe_alutype_i == 3'b001) ? arithres : // ARITH
        (exe_alutype_i == 3'b101) ? ret_addr :
        32'b0;

endmodule

