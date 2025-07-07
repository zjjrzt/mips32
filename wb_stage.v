module wb_stage(
    input wire rst_n,

    input wire [4:0] wb_wa_i,       //写回地址
    input wire wb_wreg_i,     //是否写入寄存器堆
    input wire [31:0] wb_dreg_i,      //从寄存器堆读出的数据
    input wire wb_mreg_i,     //是否访问寄存器堆
    input wire [3:0] wb_dre_i,       //数据存储器读写使能
    input wire wb_whilo_i,    //是否写入HI/LO寄存器
    input wire [63:0] wb_hilo_i,    //HI/LO寄存器数据
    input wire [31:0] dm,       //数据存储器地址
    
    output wire [4:0] wb_wa_o,       //写回地址
    output wire wb_wreg_o,     //是否写入寄存器堆
    output wire [31:0] wb_wd_o,       //写回数据
    output wire wb_whilo_o,    //是否写入HI/LO寄存器
    output wire [63:0] wb_hilo_o    //HI/LO寄存器数据
);
    // 直通信号
    assign wb_wa_o    = (rst_n == 1'b0) ? 5'b0 : wb_wa_i;
    assign wb_wreg_o  = (rst_n == 1'b0) ? 1'b0 : wb_wreg_i;
    assign wb_whilo_o = (rst_n == 1'b0) ? 1'b0 : wb_whilo_i;
    assign wb_hilo_o  = (rst_n == 1'b0) ? 64'b0 : wb_hilo_i;

    // 数据存储器数据处理
    wire [31:0] data = (rst_n == 1'b0) ? 32'b0 :
        (wb_dre_i == 4'b1111) ? {dm[7:0], dm[15:8], dm[23:16], dm[31:24]} :
        (wb_dre_i == 4'b1000) ? {{24{dm[31]}}, dm[31:24]} :
        (wb_dre_i == 4'b0100) ? {{24{dm[23]}}, dm[23:16]} :
        (wb_dre_i == 4'b0010) ? {{24{dm[15]}}, dm[15:8 ]} :
        (wb_dre_i == 4'b0001) ? {{24{dm[7 ]}}, dm[7 :0 ]} : 32'b0;

    // 写回数据选择
    assign wb_wd_o = (rst_n == 1'b0) ? 32'b0 :
        (wb_mreg_i ? data : wb_dreg_i);
endmodule

