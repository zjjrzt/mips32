//取指/译码寄存器模块

module ifid_reg(
    input wire clk,
    input wire rst_n,
    input wire [31:0] if_pc,        //取指阶段的pc值
    output reg [31:0] id_pc,        //译码阶段的pc值
    input wire [31:0] if_pc_plus_4, //取指阶段的pc加4值
    output reg [31:0] id_pc_plus_4  //译码阶段的pc加4值
);


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            id_pc <= 32'h0000_3000;
            id_pc_plus_4 <= 32'h0000_3000;
        end
        else begin
            id_pc <= if_pc;
            id_pc_plus_4 <= if_pc_plus_4;
        end
    end

endmodule