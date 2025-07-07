//译码模块
module id_stage(
    input wire rst_n,
    input wire [31:0] id_inst_i,
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
    output wire [4:0] ra2
);

//将大端模式的指令转换为小端模式
wire [31:0] id_inst = {id_inst_i[7:0], id_inst_i[15:8], id_inst_i[23:16], id_inst_i[31:24]};

//提取指令字段
wire [5:0] op = id_inst[31:26]; //操作码
wire [4:0] rs = id_inst[25:21]; //源寄存器1
wire [4:0] rt = id_inst[20:16]; //源寄存器2
wire [4:0] rd = id_inst[15:11]; //目的寄存器
wire [4:0] sa = id_inst[10:6]; //移位量
wire [5:0] funct = id_inst[5:0]; //功能码
wire [15:0] imm = id_inst[15:0]; //立即数


//第一级译码逻辑
wire inst_reg  = ~|op;
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

// ALU类型输出
assign id_alutype_o[2] = (rst_n == 1'b0) ? 1'b0 : inst_sll;
assign id_alutype_o[1] = (rst_n == 1'b0) ? 1'b0 : (inst_and | inst_mfhi | inst_mflo | inst_ori | inst_lui);
assign id_alutype_o[0] = (rst_n == 1'b0) ? 1'b0 : (inst_add | inst_subu | inst_slt | inst_mfhi | inst_mflo | inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw);

// ALU操作码输出
assign id_aluop_o[7] = (rst_n == 1'b0) ? 1'b0 : (inst_lb | inst_lw | inst_sb | inst_sw);
assign id_aluop_o[6] = 1'b0;
assign id_aluop_o[5] = (rst_n == 1'b0) ? 1'b0 : (inst_slt | inst_sltiu);
assign id_aluop_o[4] = (rst_n == 1'b0) ? 1'b0 : (inst_add | inst_subu | inst_and | inst_mult | inst_sll | inst_ori | inst_addiu | inst_lb | inst_lw | inst_sb | inst_sw);
assign id_aluop_o[3] = (rst_n == 1'b0) ? 1'b0 : (inst_add | inst_subu | inst_and | inst_mfhi | inst_mflo | inst_ori | inst_addiu | inst_sb | inst_sw);
assign id_aluop_o[2] = (rst_n == 1'b0) ? 1'b0 : (inst_slt | inst_and | inst_mult | inst_mfhi | inst_mflo | inst_ori | inst_lui | inst_sltiu);
assign id_aluop_o[1] = (rst_n == 1'b0) ? 1'b0 : (inst_subu | inst_slt | inst_sltiu | inst_lw | inst_sw);
assign id_aluop_o[0] = (rst_n == 1'b0) ? 1'b0 : (inst_subu | inst_mflo | inst_sll | inst_ori | inst_lui | inst_addiu | inst_sltiu);

// 写寄存器堆使能
assign id_wreg_o = (rst_n == 1'b0) ? 1'b0 : (inst_add | inst_subu | inst_slt | inst_and | inst_mfhi | inst_mflo | inst_sll | inst_ori | inst_lui | inst_addiu | inst_sltiu | inst_lb | inst_lw);
// 写HI/LO寄存器使能
assign id_whilo_o = (rst_n == 1'b0) ? 1'b0 : inst_mult;
// 访问存储器使能
assign id_mreg_o = (rst_n == 1'b0) ? 1'b0 : (inst_lb | inst_lw);

// 立即数相关信号
wire shift = inst_sll;
wire immsel = inst_ori | inst_lui | inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw;
wire rtsel  = inst_ori | inst_lui | inst_addiu | inst_sltiu | inst_lb | inst_lw;
wire sext   = inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw;
wire upper  = inst_lui;

// 读寄存器使能
assign rreg1 = (rst_n == 1'b0) ? 1'b0 : (inst_add | inst_subu | inst_slt | inst_and | inst_mult | inst_ori | inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw);
assign rreg2 = (rst_n == 1'b0) ? 1'b0 : (inst_add | inst_subu | inst_slt | inst_and | inst_mult | inst_sll | inst_sb | inst_sw);

// 读寄存器地址
assign ra1 = (rst_n == 1'b0) ? 5'b0 : rs;
assign ra2 = (rst_n == 1'b0) ? 5'b0 : rt;

// 立即数扩展
wire [31:0] imm_ext = (rst_n == 1'b0) ? 32'b0 :
                      (upper ? (imm << 16) : (sext ? {{16{imm[15]}}, imm} : {16'b0, imm}));

// 写寄存器地址选择
assign id_wd_o = (rst_n == 1'b0) ? 5'b0 : (rtsel ? rt : rd);
// 写寄存器数据
assign id_din_o = (rst_n == 1'b0) ? 32'b0 : rd2;

// 源操作数选择
assign id_src1_o = (rst_n == 1'b0) ? 32'b0 : (shift ? {27'b0, sa} : (rreg1 ? rd1 : 32'b0));
assign id_src2_o = (rst_n == 1'b0) ? 32'b0 : (immsel ? imm_ext : (rreg2 ? rd2 : 32'b0));


endmodule