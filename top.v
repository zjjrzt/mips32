module top(
    input wire clk,
    input wire rst_n,

    output wire [31:0] iaddr,
    output wire ice,
    input wire [31:0] inst,

    output wire dce,
    output wire [31:0] daddr,
    output wire [3:0] we,
    output wire [31:0] din,
    input wire [31:0] dm
);

//连接取值阶段与取值译码寄存器
wire [31:0] pc;

//连接取值译码寄存器与译码阶段
wire [31:0] id_pc_i;

//连接译码阶段与通用寄存器堆
wire re1;
wire [4:0] ra1;
wire [31:0] rd1;
wire re2;
wire [4:0] ra2;
wire [31:0] rd2;

//连接译码阶段与译码执行寄存器
wire [7:0] id_aluop_o;
wire [2:0] id_alutype_o;
wire [31:0] id_src1_o;
wire [31:0] id_src2_o;
wire id_wreg_o;
wire [4:0] id_wa_o;
wire whilo_o;
wire mreg_o;
wire [31:0] id_din_o;

//连接译码执行寄存器与执行阶段
wire [7:0] exe_aluop_i;
wire [2:0] exe_alutype_i;
wire [31:0] exe_src1_i;
wire [31:0] exe_src2_i;
wire exe_wreg_i;
wire [4:0] exe_wa_i;
wire whilo_i;
wire mreg_i;
wire [31:0] exe_din_i;

//连接执行阶段与HILO寄存器
wire [31:0] hi_i;
wire [31:0] lo_i;

//连接执行阶段与执行访存寄存器的信号
wire [7:0] exe_aluop_o;
wire exe_wreg_o;
wire [4:0] exe_wa_o;
wire [31:0] exe_wd_o;
wire exe_mreg_o;
wire [31:0] exe_din_o;
wire exe_whilo_o;
wire [63:0] exe_hilo_o;

//连接执行访存寄存器与访存阶段
wire [7:0] mem_aluop_i;
wire mem_wreg_i;
wire [4:0] mem_wa_i;
wire [31:0] mem_wd_i;
wire mem_mreg_i;
wire [31:0] mem_din_i;
wire mem_whilo_i;
wire [63:0] mem_hilo_i;

//连接访存阶段与访存写回寄存器
wire mem_wreg_o;
wire [4:0] mem_wa_o;
wire [31:0] mem_dreg_o;
wire mem_mreg_o;
wire [3:0] mem_dre_o;
wire mem_whilo_o;
wire [63:0] mem_hilo_o;

//连接访存写回寄存器与写回阶段
wire wb_wreg_i;
wire [4:0] wb_wa_i;
wire [31:0] wb_dreg_i;
wire wb_mreg_i;
wire [3:0] wb_dre_i;
wire wb_whilo_i;
wire [63:0] wb_hilo_i;

//连接写回阶段与通用寄存器堆
wire [4:0] wb_wa_o;
wire [31:0] wb_wd_o;
wire wb_wreg_o;

//连接写回阶段与HILO寄存器
wire wb_whilo_o;
wire [63:0] wb_hilo_o;
//转移指令相关
wire [31:0] jump_addr_1; //跳转指令的地址1
wire [31:0] jump_addr_2; //跳转指令的地址2
wire [31:0] jump_addr_3; //跳转指令的地址3
wire [1:0] jtsel;        //跳转选择信号
wire [31:0] ret_addr;    //返回地址
wire [31:0] pc_plus_4;   //pc+4
wire [31:0] id_pc_plus_4;
wire [31:0] id_ret_addr;
//暂停相关信号
wire [3:0] stall;
wire stallreq_id;
wire stallreq_exe;

//例化取值阶段
if_stage if_stage(
    .clk(clk),
    .rst_n(rst_n),
    .ice(ice),
    .iaddr(iaddr),
    .pc(pc),
    .pc_plus_4(pc_plus_4),
    .jump_addr_1(jump_addr_1),
    .jump_addr_2(jump_addr_2),
    .jump_addr_3(jump_addr_3),
    .jtsel(jtsel),
    .stall(stall)
);

//例化取值译码寄存器
ifid_reg if_id_reg(
    .clk(clk),
    .rst_n(rst_n),
    .if_pc(pc),
    .id_pc(id_pc_i),
    .if_pc_plus_4(pc_plus_4),
    .id_pc_plus_4(id_pc_plus_4),
    .stall(stall)
);

//例化译码阶段
id_stage id_stage(
    .rst_n(rst_n),
    .id_inst_i(inst),
    .rd1(rd1),
    .rd2(rd2),
    .ra1(ra1),
    .ra2(ra2),
    .rreg1(re1),
    .rreg2(re2),
    .id_aluop_o(id_aluop_o),
    .id_alutype_o(id_alutype_o),
    .id_src1_o(id_src1_o),
    .id_src2_o(id_src2_o),
    .id_wreg_o(id_wreg_o),
    .id_wa_o(id_wa_o),
    .id_whilo_o(whilo_o),
    .id_mreg_o(mreg_o),
    .id_din_o(id_din_o),
    .exe2id_wa(exe_wa_o),
    .exe2id_wreg(exe_wreg_o),
    .exe2id_wd(exe_wd_o),
    .mem2id_wa(mem_wa_o),
    .mem2id_wreg(mem_wreg_o),
    .mem2id_wd(mem_dreg_o),
    .jump_addr_1(jump_addr_1),
    .jump_addr_2(jump_addr_2),
    .jump_addr_3(jump_addr_3),
    .jtsel(jtsel),
    .ret_addr(ret_addr),
    .pc_plus_4(id_pc_plus_4),
    .exe2id_mreg(exe_mreg_o),
    .mem2id_mreg(mem_mreg_o),
    .stallreq_id(stallreq_id)
);

//例化通用寄存器堆
regfile regfile(
    .clk(clk),
    .rst_n(rst_n),
    .re1(re1),
    .ra1(ra1),
    .rd1(rd1),
    .re2(re2),
    .ra2(ra2),
    .rd2(rd2),
    .we(wb_wreg_o),
    .wa(wb_wa_o),
    .wd(wb_wd_o)
);

//例化译码执行寄存器
idexe_reg id_exe_reg(
    .clk(clk),
    .rst_n(rst_n),
    .id_alutype(id_alutype_o),
    .id_aluop(id_aluop_o),
    .id_src1(id_src1_o),
    .id_src2(id_src2_o),
    .id_wreg(id_wreg_o),
    .id_wa(id_wa_o),
    .id_whilo(whilo_o),
    .id_mreg(mreg_o),
    .id_din(id_din_o),
    .exe_alutype(exe_alutype_i),
    .exe_aluop(exe_aluop_i),
    .exe_src1(exe_src1_i),
    .exe_src2(exe_src2_i),
    .exe_wreg(exe_wreg_i),
    .exe_wa(exe_wa_i),
    .exe_whilo(whilo_i),
    .exe_mreg(mreg_i),
    .exe_din(exe_din_i),
    .id_ret_addr(ret_addr),
    .exe_ret_addr(id_ret_addr),
    .stall(stall)
);

//例化执行阶段
exe_stage exe_stage(
    .rst_n(rst_n),
    .exe_alutype_i(exe_alutype_i),
    .exe_aluop_i(exe_aluop_i),
    .exe_src1_i(exe_src1_i),
    .exe_src2_i(exe_src2_i),
    .exe_wreg_i(exe_wreg_i),
    .exe_wa_i(exe_wa_i),
    .exe_whilo_i(whilo_i),
    .exe_mreg_i(mreg_i),
    .exe_din_i(exe_din_i),
    .hi_i(hi_i),
    .lo_i(lo_i),
    .exe_aluop_o(exe_aluop_o),
    .exe_wreg_o(exe_wreg_o),
    .exe_wa_o(exe_wa_o),
    .exe_wd_o(exe_wd_o),
    .exe_mreg_o(exe_mreg_o),
    .exe_din_o(exe_din_o),
    .exe_whilo_o(exe_whilo_o),
    .exe_hilo_o(exe_hilo_o),
    .mem_2exe_whilo(mem_whilo_o),
    .mem_2exe_hilo(mem_hilo_o),
    .wb2exe_whilo(wb_whilo_o),
    .wb2exe_hilo(wb_hilo_o),
    .ret_addr(id_ret_addr),
    .clk(clk),
    .stallreq_exe(stallreq_exe)
    );

//例化执行访存寄存器
exemem_reg exe_mem_reg(
    .clk(clk),
    .rst_n(rst_n),
    .exe_aluop(exe_aluop_o),
    .exe_wa(exe_wa_o),
    .exe_wd(exe_wd_o),
    .exe_wreg(exe_wreg_o),
    .exe_mreg(exe_mreg_o),
    .exe_din(exe_din_o),
    .exe_whilo(exe_whilo_o),
    .exe_hilo(exe_hilo_o),
    .mem_aluop(mem_aluop_i),
    .mem_wa(mem_wa_i),
    .mem_wd(mem_wd_i),
    .mem_wreg(mem_wreg_i),
    .mem_mreg(mem_mreg_i),
    .mem_din(mem_din_i),
    .mem_whilo(mem_whilo_i),
    .mem_hilo(mem_hilo_i),
    .stall(stall)
);

//例化访存阶段
mem_stage mem_stage(
    .rst_n(rst_n),
    .mem_aluop_i(mem_aluop_i),
    .mem_wa_i(mem_wa_i),
    .mem_wreg_i(mem_wreg_i),
    .mem_mreg_i(mem_mreg_i),
    .mem_wd_i(mem_wd_i),
    .mem_din_i(mem_din_i),
    .mem_hilo_i(mem_hilo_i),
    .mem_whilo_i(mem_whilo_i),
    .mem_dreg_o(mem_dreg_o),
    .mem_wa_o(mem_wa_o),
    .mem_wreg_o(mem_wreg_o),
    .mem_mreg_o(mem_mreg_o),
    .dre(mem_dre_o),
    .mem_whilo_o(mem_whilo_o),
    .mem_hilo_o(mem_hilo_o),
    .dce(dce),
    .daddr(daddr),
    .din(din),
    .we(we)
);

//例化访存写回寄存器
memwb_reg mem_wb_reg(
    .clk(clk),
    .rst_n(rst_n),
    .mem_dreg(mem_dreg_o),
    .mem_wa(mem_wa_o),
    .mem_wreg(mem_wreg_o),
    .mem_mreg(mem_mreg_o),
    .dre(mem_dre_o),
    .mem_whilo(mem_whilo_o),
    .mem_hilo(mem_hilo_o),
    .wb_dreg(wb_dreg_i),
    .wb_wa(wb_wa_i),
    .wb_wreg(wb_wreg_i),
    .wb_mreg(wb_mreg_i),
    .wb_dre(wb_dre_i),
    .wb_whilo(wb_whilo_i),
    .wb_hilo(wb_hilo_i)
);

//例化写回阶段
wb_stage wb_stage(
    .rst_n(rst_n),
    .wb_dreg_i(wb_dreg_i),
    .wb_wa_i(wb_wa_i),
    .wb_wreg_i(wb_wreg_i),
    .wb_mreg_i(wb_mreg_i),
    .wb_dre_i(wb_dre_i),
    .wb_whilo_i(wb_whilo_i),
    .wb_hilo_i(wb_hilo_i),
    .dm(dm),
    .wb_wa_o(wb_wa_o),
    .wb_wd_o(wb_wd_o),
    .wb_wreg_o(wb_wreg_o),
    .wb_whilo_o(wb_whilo_o),
    .wb_hilo_o(wb_hilo_o)
);

//例化HILO寄存器
hilo hilo_reg(
    .clk(clk),
    .rst_n(rst_n),
    .hi_i(wb_hilo_o[63:32]),
    .lo_i(wb_hilo_o[31:0]),
    .hi_o(exe_hi_i),
    .lo_o(exe_lo_i),
    .we(wb_whilo_o)
);

scu scu(
    .rst_n(rst_n),
    .stall(stall),
    .stallreq_id(stallreq_id),
    .stallreq_exe(stallreq_exe)
);

endmodule