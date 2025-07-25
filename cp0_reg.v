module cp0_reg(
    input wire clk,
    input wire rst_n,
    input wire we,
    input wire re,
    input wire [4:0] raddr,
    input wire [4:0] waddr,
    input wire [31:0] wdata,
    input wire [5:0] int_i,
    input wire [31:0] pc_i,
    input wire in_delay_i,
    input wire [4:0] exccode_i,
    output wire flush,
    output wire flush_im,
    output wire [31:0] cp0_excaddr,
    output wire [31:0] data_o,
    output wire [31:0] status_o,
    output wire [31:0] cause_o
);

reg [31:0] badvaddr;
reg [31:0] status;
reg [31:0] cause;
reg [31:0] epc;
reg [31:0] cp0_excaddr_reg;
reg flush_i;

assign status_o = status;
assign cause_o = cause;

//根据异常信息生成flush信号
assign flush = (rst_n == 1'b0) ? 1'b0 : (exccode_i != 5'h10) ? 1'b1 : 1'b0;
assign flush_im = (rst_n) ? flush : 1'b0;

always @ (posedge clk) begin
    if (rst_n == 1'b0) begin
        flush_i <= 1'b0;
    end else begin
        flush_i <= flush;
    end
end

task do_exc;
begin
    if (status[1] == 0) begin
        if (in_delay_i) begin
            cause[31] <= 1'b1; // 设置延迟槽异常标志
            epc <= pc_i - 4; // 设置异常程序计数器
        end else begin
            cause[31] <= 1'b0; // 设置非延迟槽异常标志
            epc <= pc_i; // 设置异常程序计数器
        end
    end
    status[1] <= 1'b1; // 设置异常中断屏蔽位
    cause[6:2] <= exccode_i; // 设置异常代码
end
endtask

task do_eret;
begin
    status[1] <= 1'b0; // 清除异常中断屏蔽位
end
endtask

always @(posedge clk) begin
    if (rst_n == 1'b0) begin
        cp0_excaddr_reg <= 32'b0;
    end else begin
        if (exccode_i == 5'b00) begin
            cp0_excaddr_reg <= 32'h040;
        end else if (exccode_i == 5'h11 && waddr == 14 && we) begin
            cp0_excaddr_reg <= wdata;
        end else if (exccode_i == 5'h11) begin
            cp0_excaddr_reg <= epc;
        end else if (exccode_i != 5'h10) begin
            cp0_excaddr_reg <= 32'h100;
        end else begin
            cp0_excaddr_reg <= 32'h000;
        end
    end
end

assign cp0_excaddr = cp0_excaddr_reg;

always @ (posedge clk) begin
    if (rst_n == 1'b0) begin
        badvaddr <= 32'b0;
        status <= 32'h10000000;
        cause <= 32'b0;
        epc <= 32'b0;
    end else begin
        cause[15:10] <= int_i;
        case(exccode_i)
            5'h10:
                if (we) begin
                    case(waddr)
                        8:badvaddr <= wdata;
                        12:status <= wdata;
                        13:cause <= wdata;
                        14:epc <= wdata;
                    endcase
                end
            5'h11:
                do_eret();
            default:
                do_exc();
        endcase
    end
end

assign data_o = (rst_n == 1'b0) ? 32'b0 :
                (re != 1'b1) ? 32'b0 :
                (raddr == 8) ? badvaddr :
                (raddr == 12) ? status :
                (raddr == 13) ? cause :
                (raddr == 14) ? epc : 32'b0;

endmodule