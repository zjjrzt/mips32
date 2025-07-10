module rom(
    input wire clk,
    input wire [8:0] addr, // 9位地址可寻址512字
    output reg [31:0] data
);
    reg [31:0] mem [0:175];
    integer i;
    initial begin
        // 先全部清零
        for (i = 0; i < 176; i = i + 1) mem[i] = 32'b0;
        // div.coe共17组，每组4个地址，原coe第n个值放到mem[n*4]
        mem[0]  = 32'h00010234;
        mem[4]  = 32'h99000334;
        mem[8]  = 32'h02006014;
        mem[12] = 32'h1a004300;
        mem[16] = 32'h0d000700;
        mem[20] = 32'hffff0124;
        mem[24] = 32'h04006114;
        mem[28] = 32'h0080013c;
        mem[32] = 32'h02004114;
        mem[36] = 32'h00000000;
        mem[40] = 32'h0d000600;
        mem[44] = 32'h12100000;
        mem[48] = 32'h10200000;
        mem[52] = 32'h12280000;
        mem[56] = 32'h00000000;
        mem[60] = 32'h00000000;
        mem[64] = 32'h00000000;
    end
    reg [8:0] addr_r;
    always @(posedge clk) begin
        addr_r = addr;
        data = mem[addr_r];
    end
endmodule
