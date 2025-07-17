//译码模块
module id_stage(
    input wire rst_n,
    input wire [31:0] id_inst_i,
    input wire [31:0] id_pc_i, //译码阶段的PC值
    //通用寄存器读出数据接口
    input wire [31:0] rd1,
    input wire [31:0] rd2,
    //译码模块输出接口
    output wire [2:0] id_alutype_o,  //ALU操作类型
    output wire [7:0] id_aluop_o,    //ALU操作码
    output wire       id_whilo_o,    //是否写入HI/LO寄存器
    output wire       id_mreg_o,     //是否访问寄存器堆
    output wire       id_wreg_o,     //是否写入寄存器堆
    output wire [4:0] id_wa_o,       //写入寄存器堆的地址
    output wire [31:0] id_din_o,       //写入寄存器堆的数据
    //译码阶段指令源操作数
    output wire [31:0] id_src1_o,
    output wire [31:0] id_src2_o,
    //寄存器堆使能及地址
    output wire rreg1,
    output wire rreg2,
    output wire [4:0] ra1,
    output wire [4:0] ra2,
    //从执行阶段获得的写回信号
    input wire exe2id_wreg, //是否写入寄存器堆
    input wire [4:0] exe2id_wa,    //写入寄存器堆的地址
    input wire [31:0] exe2id_wd,   //写入寄存器堆的数据
    //从访存阶段获得的写回信号
    input wire mem2id_wreg, //是否写入寄存器堆
    input wire [4:0] mem2id_wa,    //写入寄存器堆的地址
    input wire [31:0] mem2id_wd,    //写入寄存器堆的数据
    //添加转移指令相关代码
    input wire [31:0] pc_plus_4, //译码阶段的pc加4值
    output wire [31:0] jump_addr_1, //跳转指令的地址1
    output wire [31:0] jump_addr_2, //跳转指令的地址2
    output wire [31:0] jump_addr_3, //跳转指令的地址3
    output wire [1:0] jtsel ,   //跳转选择信号
    output wire [31:0] ret_addr,
    //暂停相关信号
    input wire exe2id_mreg,
    input wire mem2id_mreg,
    output wire stallreq_id,
    //流水线异常相关信号
    input wire id_in_delay_i,//是否延迟槽指令
    input wire flush_im,//清空指令队列
    output wire [31:0] cp0_addr,//异常信号地址
    output wire [31:0] id_pc_o,
    output wire id_in_delay_o,
    output wire next_delay_o,
    output wire [4:0] id_exccode_o
);


//将大端模式的指令转换为小端模式
wire [31:0] id_inst = (flush_im == 1'b1) ? 32'b0 :{id_inst_i[7:0], id_inst_i[15:8], id_inst_i[23:16], id_inst_i[31:24]};

//提取指令字段
wire [5:0] op = id_inst[31:26]; //操作码
wire [4:0] rs = id_inst[25:21]; //源寄存器1
wire [4:0] rt = id_inst[20:16]; //源寄存器2
wire [4:0] rd = id_inst[15:11]; //目的寄存器
wire [4:0] sa = id_inst[10:6]; //移位量
wire [5:0] funct = id_inst[5:0]; //功能码
wire [15:0] imm = id_inst[15:0]; //立即数

//产生源操作数选择信号
wire [1:0] fwrd1 = (rst_n == 1'b0) ? 2'b00 : 
                    (exe2id_wreg && exe2id_wa == ra1 && rreg1) ? 2'b01 : 
                    (mem2id_wreg && mem2id_wa == ra1 && rreg1) ? 2'b10 :
                    (rreg1) ? 2'b11 : 2'b00; // 00:不转发，01:从执行阶段转发，10:从访存阶段转发，11:从寄存器堆读取

wire [1:0] fwrd2 = (rst_n == 1'b0) ? 2'b00 :
                    (exe2id_wreg && exe2id_wa == ra2 && rreg2) ? 2'b01 : 
                    (mem2id_wreg && mem2id_wa == ra2 && rreg2) ? 2'b10 :
                    (rreg2) ? 2'b11 : 2'b00; // 00:不转发，01:从执行阶段转发，10:从访存阶段转发，11:从寄存器堆读取

//直接送往执行阶段的信号
assign id_pc_o = (rst_n == 1'b0) ? 32'b0 : id_pc_i;
assign id_in_delay_o = (rst_n == 1'b0) ? 1'b0 : id_in_delay_i;


//获得访存阶段要存入数据存储器的数据
assign id_din_o = (rst_n == 1'b0) ? 32'b0 :
                    (fwrd1) ? exe2id_wd : //从执行阶段转发
                    (fwrd2) ? mem2id_wd : //从访存阶段转
                    (rreg2) ? rd2 : 32'b0; //从寄存器堆读取

//第一级译码逻辑

wire inst_reg  = ~|op;
wire inst_div = inst_reg & ~funct[5] &  funct[4] &  funct[3] & ~funct[2] & funct[1] & ~funct[0];
wire inst_add  = inst_reg & funct[5] & ~funct[4] & ~funct[3] & ~funct[2] & ~funct[1] & ~funct[0];
wire inst_subu = inst_reg & funct[5] & ~funct[4] & ~funct[3] & ~funct[2] &  funct[1] &  funct[0];
wire inst_slt  = inst_reg & funct[5] & ~funct[4] &  funct[3] & ~funct[2] &  funct[1] & ~funct[0];
wire inst_and  = inst_reg & funct[5] & ~funct[4] & ~funct[3] &  funct[2] & ~funct[1] & ~funct[0];
wire inst_mult = inst_reg & ~funct[5] &  funct[4] &  funct[3] & ~funct[2] & ~funct[1] & ~funct[0];
wire inst_mfhi = inst_reg & ~funct[5] &  funct[4] & ~funct[3] & ~funct[2] & ~funct[1] & ~funct[0];
wire inst_mflo = inst_reg & ~funct[5] &  funct[4] & ~funct[3] & ~funct[2] &  funct[1] & ~funct[0];
wire inst_sll  = inst_reg & ~funct[5] & ~funct[4] & ~funct[3] & ~funct[2] & ~funct[1] & ~funct[0];
wire inst_ori  = ~op[5] & ~op[4] &  op[3] &  op[2] & ~op[1] &  op[0];
wire inst_lui  = ~op[5] & ~op[4] &  op[3] &  op[2] &  op[1] &  op[0];
wire inst_addiu= ~op[5] & ~op[4] &  op[3] & ~op[2] & ~op[1] &  op[0];
wire inst_sltiu= ~op[5] & ~op[4] &  op[3] & ~op[2] &  op[1] &  op[0];
wire inst_lb   =  op[5] & ~op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0];
wire inst_lw   =  op[5] & ~op[4] & ~op[3] & ~op[2] &  op[1] &  op[0];
wire inst_sb   =  op[5] & ~op[4] &  op[3] & ~op[2] & ~op[1] & ~op[0];
wire inst_sw   =  op[5] & ~op[4] &  op[3] & ~op[2] &  op[1] &  op[0];

wire inst_i = ~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & ~op[0];
wire inst_jal = ~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0];
wire inst_jr = inst_reg & ~funct[5] & ~funct[4] & funct[3] & ~funct[2] & ~funct[1] & ~funct[0];
wire inst_beq = ~op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & ~op[0];
wire inst_ben = ~op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & op[0];
wire equ = (rst_n == 1'b0) ?1'b0 :
            (inst_beq) ? (id_src1_o == id_src2_o) : //等于
            (inst_ben) ? (id_src1_o != id_src2_o) : //不等于
            1'b0; //默认不等于

wire inst_syscall = inst_reg & ~funct[5] & ~funct[4] & funct[3] & funct[2] & ~funct[1] & ~funct[0];
wire inst_eret = ~op[5] & op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0] & ~funct[5] & funct[4] & funct[3] & ~funct[2] & ~funct[1] & ~funct[0];
wire inst_mfc0 = ~op[5] & op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0] & ~id_inst[23];
wire inst_mtc0 = ~op[5] & op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0] & id_inst[23];

// ALU类型输出
assign id_alutype_o[2] = (rst_n == 1'b0) ? 1'b0 : (inst_sll | inst_i | inst_jal | inst_jr | inst_beq | inst_ben | inst_syscall | inst_eret | inst_mtc0);
assign id_alutype_o[1] = (rst_n == 1'b0) ? 1'b0 : (inst_and | inst_mfhi | inst_mflo | inst_ori | inst_lui | inst_syscall | inst_eret | inst_mfc0 | inst_mtc0);
assign id_alutype_o[0] = (rst_n == 1'b0) ? 1'b0 : (inst_add | inst_subu | inst_slt | inst_mfhi | inst_mflo | inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw | inst_i | inst_jal | inst_jr | inst_beq | inst_ben | inst_mfc0);

// ALU操作码输出
assign id_aluop_o[7] = (rst_n == 1'b0) ? 1'b0 : (inst_lb | inst_lw | inst_sb | inst_sw | inst_syscall | inst_eret | inst_mfc0 | inst_mtc0);
assign id_aluop_o[6] = 1'b0;
assign id_aluop_o[5] = (rst_n == 1'b0) ? 1'b0 : (inst_slt | inst_sltiu | inst_i | inst_jal | inst_jr | inst_beq | inst_ben);
assign id_aluop_o[4] = (rst_n == 1'b0) ? 1'b0 : (inst_add | inst_subu | inst_and | inst_mult | inst_sll | inst_ori | inst_addiu | inst_lb | inst_lw | inst_sb | inst_sw | inst_beq | inst_ben | inst_div);
assign id_aluop_o[3] = (rst_n == 1'b0) ? 1'b0 : (inst_add | inst_subu | inst_and | inst_mfhi | inst_mflo | inst_ori | inst_addiu | inst_sb | inst_sw | inst_i | inst_jal | inst_jr | inst_mfc0 | inst_mtc0);
assign id_aluop_o[2] = (rst_n == 1'b0) ? 1'b0 : (inst_slt | inst_and | inst_mult | inst_mfhi | inst_mflo | inst_ori | inst_lui | inst_sltiu |inst_i | inst_jal | inst_jr | inst_div | inst_syscall | inst_eret | inst_mfc0 | inst_mtc0);
assign id_aluop_o[1] = (rst_n == 1'b0) ? 1'b0 : (inst_subu | inst_slt | inst_sltiu | inst_lw | inst_sw | inst_jal | inst_div | inst_syscall | inst_eret);
assign id_aluop_o[0] = (rst_n == 1'b0) ? 1'b0 : (inst_subu | inst_mflo | inst_sll | inst_ori | inst_lui | inst_addiu | inst_sltiu | inst_jr | inst_ben | inst_eret | inst_mtc0);

// 写寄存器堆使能
assign id_wreg_o = (rst_n == 1'b0) ? 1'b0 : (inst_add | inst_subu | inst_slt | inst_and | inst_mfhi | inst_mflo | inst_sll | inst_ori | inst_lui | inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_jal | inst_mfc0);
// 写HI/LO寄存器使能
assign id_whilo_o = (rst_n == 1'b0) ? 1'b0 : (inst_mult | inst_div);
// 访问存储器使能
assign id_mreg_o = (rst_n == 1'b0) ? 1'b0 : (inst_lb | inst_lw);

// 立即数相关信号
wire shift = inst_sll;
wire immsel = inst_ori | inst_lui | inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw;
wire rtsel  = inst_ori | inst_lui | inst_addiu | inst_sltiu | inst_lb | inst_lw;
wire sext   = inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw;
wire upper  = inst_lui;

// 读寄存器使能
assign rreg1 = (rst_n == 1'b0) ? 1'b0 : (inst_add | inst_subu | inst_slt | inst_and | inst_mult | inst_ori | inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw | inst_jr | inst_beq | inst_ben | inst_div);
assign rreg2 = (rst_n == 1'b0) ? 1'b0 : (inst_add | inst_subu | inst_slt | inst_and | inst_mult | inst_sll | inst_sb | inst_sw | inst_beq | inst_ben | inst_div | inst_mtc0);

// 读寄存器地址
assign ra1 = (rst_n == 1'b0) ? 5'b0 : rs;
assign ra2 = (rst_n == 1'b0) ? 5'b0 : rt;

//转移地址信号
wire jal = inst_jal;
assign jtsel[1] = inst_jr | inst_beq & equ | inst_ben & equ; //跳转选择信号1
assign jtsel[0] = inst_i | inst_jal | inst_beq & equ | inst_ben & equ; //跳转选择信号0

// 立即数扩展
wire [31:0] imm_ext = (rst_n == 1'b0) ? 32'b0 :
                      (upper ? (imm << 16) : (sext ? {{16{imm[15]}}, imm} : {16'b0, imm}));

// 写寄存器地址选择
assign id_wa_o = (rst_n == 1'b0) ? 5'b0 :
                    (rtsel || inst_mfc0) ? rt : //立即数指令，使用rt作为写寄存器地址
                    (jal) ? 5'b11111 : //jal指令，使用$ra寄存器
                    rd; //其他指令，使用rd作为写寄存器地址
// 写寄存器数据
//assign id_din_o = (rst_n == 1'b0) ? 32'b0 : rd2;

// 源操作数选择
//assign id_src1_o = (rst_n == 1'b0) ? 32'b0 : (shift ? {27'b0, sa} : (rreg1 ? rd1 : 32'b0));
//assign id_src2_o = (rst_n == 1'b0) ? 32'b0 : (immsel ? imm_ext : (rreg2 ? rd2 : 32'b0));
assign id_src1_o = (rst_n == 1'b0) ? 32'b0 : 
                    (shift) ? {27'b0, sa} : //移位指令，使用移位量
                    (fwrd1 == 2'b01) ? exe2id_wd : //从执行阶段转发
                    (fwrd1 == 2'b10) ? mem2id_wd : //从访存阶段转发
                    (fwrd1 == 2'b11) ? rd1 : 32'b0;

assign id_src2_o = (rst_n == 1'b0) ? 32'b0 :
                    (immsel) ? imm_ext : //立即数指令，使用扩展后的立即数
                    (fwrd2 == 2'b01) ? exe2id_wd : //从执行阶段转发
                    (fwrd2 == 2'b10) ? mem2id_wd : //
                    (fwrd2 == 2'b11) ? rd2 : 32'b0; //从寄存器堆读取

//转移地址所需代码
wire [31:0] pc_plus_8 = pc_plus_4 + 4;
wire [25:0] instr_index = id_inst[25:0]; //指令索引
wire [31:0] imm_jump = {{14{imm[15]}}, imm, 2'b00}; //立即数跳转地址
assign jump_addr_1 = {pc_plus_4[31:28], instr_index, 2'b00}; //跳转指令的地址1
assign jump_addr_2 = pc_plus_8 + imm_jump; //跳转指令的地址2
assign jump_addr_3 = id_src1_o; //跳转指令的地址3
assign ret_addr = pc_plus_8; //返回地址

//暂停相关信号
assign stallreq_id = (rst_n == 1'b0) ? 1'b0 :
                        (((exe2id_wreg && exe2id_wa == ra1 && rreg1) || (exe2id_wreg && exe2id_wa == ra2 &&rreg2)) && (exe2id_mreg)) ? 1'b1 :
                        (((mem2id_wreg && mem2id_wa == ra1 && rreg1) || (mem2id_wreg && mem2id_wa == ra2 && rreg2)) && (mem2id_mreg)) ? 1'b1 : 1'b0; //暂停信号

//判断下一条指令是否为延迟槽指令
assign next_delay_o = (rst_n == 1'b0) ? 1'b0 :
                        (inst_i | inst_jr | inst_jal | inst_beq | inst_ben);
//判断当前阶段是否存在异常，并设置相应的异常类型编码
assign id_exccode_o = (rst_n == 1'b0) ? 5'h10 :
                        (inst_syscall) ? 5'h08 :
                        (inst_eret) ? 5'h11 : 5'h10; //异常类型编码
assign cp0_addr = (rst_n == 1'b0) ? 5'b0 : rd; //CP0寄存器地址

endmodule