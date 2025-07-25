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
    input wire [31:0] dm,
    input wire [5:0] int
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
//异常相关信号
wire flush;
wire [31:0] cp0_excaddr;
wire flush_im;
wire id_in_delay_i;
wire [4:0] id_exccode;
wire [31:0] id_pc;
wire next_delay;
wire id_in_delay;
wire [4:0] cp0_addr;
wire [4:0] exe_exccode;
wire [31:0] exe_pc;
wire [4:0] exe_cp0_addr;
wire exe_in_delay;
wire [4:0] mem2exe_cp0_wa;
wire [31:0] mem2exe_cp0_wd;
wire mem2exe_cp0_we;
wire [4:0] wb2exe_cp0_wa;
wire [31:0] wb2exe_cp0_wd;
wire wb2exe_cp0_we;
wire [31:0] cp0_data;
wire [4:0] exe_exccode_o;
wire [31:0] exe_pc_o;
wire exe_in_delay_o;
wire cp0_re_o;
wire [4:0] cp0_raddr_o;
wire [4:0] cp0_waddr_o;
wire [31:0] cp0_wdata_o;
wire [4:0] mem_exccode;
wire [31:0] mem_pc;
wire mem_in_delay;
wire mem_cp0_we;
wire [4:0] mem_cp0_waddr;
wire [31:0] mem_cp0_wdata;
wire [31:0] cp0_status;
wire [31:0] cp0_cause;
wire [4:0] mem_exccode_o;
wire [31:0] mem_pc_o;
wire mem_in_delay_o;
wire wb_cp0_we;
wire [4:0] wb_cp0_waddr;
wire [31:0] wb_cp0_wdata;
wire exe_cp0_we_o;
wire [4:0] exe_cp0_waddr_o;
wire [31:0] exe_cp0_wdata_o;


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
    .stall(stall),
    .flush(flush_im),
    .cp0_excaddr(cp0_excaddr)
);

//例化取值译码寄存器
ifid_reg ifid_reg(
    .clk(clk),
    .rst_n(rst_n),
    .if_pc(pc),
    .id_pc(id_pc_i),
    .if_pc_plus_4(pc_plus_4),
    .id_pc_plus_4(id_pc_plus_4),
    .stall(stall),
    .flush(flush)
);

//例化译码阶段
id_stage id_stage(
    .rst_n(rst_n),
    .id_inst_i(inst),
    .id_pc_i(id_pc_i),
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
    .stallreq_id(stallreq_id),
    .flush_im(flush_im),
    .id_in_delay_i(id_in_delay_i),
    .id_exccode_o(id_exccode),
    .id_pc_o(id_pc),
    .next_delay_o(next_delay),
    .id_in_delay_o(id_in_delay),
    .cp0_addr(cp0_addr)
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
    .stall(stall),
    .flush(flush_im),
    .next_delay_o(id_in_delay_i),
    .id_exccode(id_exccode),
    .id_pc(id_pc),
    .next_delay_i(next_delay),
    .id_in_delay(id_in_delay),
    .id_cp0_addr(cp0_addr),
    .exe_exccode(exe_exccode),
    .exe_pc(exe_pc),
    .exe_cp0_addr(exe_cp0_addr),
    .exe_in_delay(exe_in_delay)
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
    .stallreq_exe(stallreq_exe),
    .exe_exccode_i(exe_exccode),
    .exe_pc_i(exe_pc),
    .cp0_addr_i(exe_cp0_addr),
    .exe_in_delay_i(exe_in_delay),
    .mem2exe_cp0_wa(mem2exe_cp0_wa),
    .mem2exe_cp0_wd(mem2exe_cp0_wd),
    .mem2exe_cp0_we(mem2exe_cp0_we),
    .wb2exe_cp0_wa(wb2exe_cp0_wa),
    .wb2exe_cp0_wd(wb2exe_cp0_wd),
    .wb2exe_cp0_we(wb2exe_cp0_we),
    .cp0_data_i(cp0_data),
    .exe_exccode_o(exe_exccode_o),
    .exe_pc_o(exe_pc_o),
    .exe_in_delay_o(exe_in_delay_o),
    .cp0_re_o(cp0_re_o),
    .cp0_raddr_o(cp0_raddr_o),
    .cp0_we_o(exe_cp0_we_o),
    .cp0_waddr_o(exe_cp0_waddr_o),
    .cp0_wdata_o(exe_cp0_wdata_o)
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
    .stall(stall),
    .flush(flush_im),
    .exe_exccode(exe_exccode_o),
    .exe_pc(exe_pc_o),
    .exe_in_delay(exe_in_delay_o),
    .exe_cp0_we(exe_cp0_we_o),
    .exe_cp0_waddr(exe_cp0_waddr_o),
    .exe_cp0_wdata(exe_cp0_wdata_o),
    .mem_exccode(mem_exccode),
    .mem_pc(mem_pc),
    .mem_in_delay(mem_in_delay),
    .mem_cp0_we(mem_cp0_we),
    .mem_cp0_waddr(mem_cp0_waddr),
    .mem_cp0_wdata(mem_cp0_wdata)
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
    .we(we),
    .cp0_we_o(mem2exe_cp0_we),
    .cp0_waddr_o(mem2exe_cp0_wa),
    .cp0_wdata_o(mem2exe_cp0_wd),
    .mem_exccode_i(mem_exccode),
    .mem_pc_i(mem_pc),
    .mem_in_delay_i(mem_in_delay),
    .cp0_we_i(mem_cp0_we),
    .cp0_waddr_i(mem_cp0_waddr),
    .cp0_wdata_i(mem_cp0_wdata),
    .cp0_exccode(mem_exccode_o),
    .cp0_pc(mem_pc_o),
    .cp0_in_delay(mem_in_delay_o),
    .cp0_status(cp0_status),
    .cp0_cause(cp0_cause)
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
    .wb_hilo(wb_hilo_i),
    .flush(flush_im),
    .mem_cp0_we(mem2exe_cp0_we),
    .mem_cp0_waddr(mem2exe_cp0_wa),
    .mem_cp0_wdata(mem2exe_cp0_wd),
    .wb_cp0_we(wb_cp0_we),
    .wb_cp0_waddr(wb_cp0_waddr),
    .wb_cp0_wdata(wb_cp0_wdata)
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
    .wb_hilo_o(wb_hilo_o),
    .cp0_we_o(wb2exe_cp0_we),
    .cp0_waddr_o(wb2exe_cp0_wa),
    .cp0_wdata_o(wb2exe_cp0_wd),
    .cp0_we_i(wb_cp0_we),
    .cp0_waddr_i(wb_cp0_waddr),
    .cp0_wdata_i(wb_cp0_wdata)
);

//例化HILO寄存器
hilo hilo_reg(
    .clk(clk),
    .rst_n(rst_n),
    .hi_i(wb_hilo_o[63:32]),
    .lo_i(wb_hilo_o[31:0]),
    .hi_o(hi_i),
    .lo_o(lo_i),
    .we(wb_whilo_o)
);

scu scu(
    .rst_n(rst_n),
    .stall(stall),
    .stallreq_id(stallreq_id),
    .stallreq_exe(stallreq_exe)
);

cp0_reg cp0_reg(
    .clk(clk),
    .rst_n(rst_n),
    .flush(flush),
    .cp0_excaddr(cp0_excaddr),
    .flush_im(flush_im),
    .re(cp0_re_o),
    .raddr(cp0_raddr_o),
    .we(wb2exe_cp0_we),
    .waddr(wb2exe_cp0_wa),
    .wdata(wb2exe_cp0_wd),
    .exccode_i(mem_exccode_o),
    .pc_i(mem_pc_o),
    .in_delay_i(mem_in_delay_o),
    .status_o(cp0_status),
    .cause_o(cp0_cause),
    .data_o(cp0_data),
    .int_i(int)
);

endmodule