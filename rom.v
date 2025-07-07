module rom(
    input wire [4:0] addr, // 5位地址可寻址32字
    output reg [31:0] data
);
    reg [31:0] mem [0:27];
    initial begin
        mem[0] = 32'hff000134;
        mem[1] = 32'h00000000;
        mem[2] = 32'h00000000;
        mem[3] = 32'h030001a0;
        mem[4] = 32'hee000134;
        mem[5] = 32'h00000000;
        mem[6] = 32'h00000000;
        mem[7] = 32'h020001a0;
        mem[8] = 32'hdd000134;
        mem[9] = 32'h00000000;
        mem[10] = 32'h00000000;
        mem[11] = 32'h010001a0;
        mem[12] = 32'hcc000134;
        mem[13] = 32'h00000000;
        mem[14] = 32'h00000000;
        mem[15] = 32'h000001a0;
        mem[16] = 32'h03000280;
        mem[17] = 32'h00000000;
        mem[18] = 32'h5544013c;
        mem[19] = 32'h00000000;
        mem[20] = 32'h00000000;
        mem[21] = 32'h77662134;
        mem[22] = 32'h00000000;
        mem[23] = 32'h00000000;
        mem[24] = 32'h080001ac;
        mem[25] = 32'h0800028c;
        mem[26] = 32'h00000000;
        mem[27] = 32'h00000000;
    end
    always @(*) begin
        if (addr < 28)
            data = mem[addr];
        else
            data = 32'b0;
    end
endmodule
