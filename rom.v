module rom(
    input wire [4:0] addr, // 5位地址可寻址32字
    output reg [31:0] data
);
    reg [31:0] mem [0:10];
    initial begin
        mem[0]  = 32'h3412013c;
        mem[1]  = 32'hcdab2134;
        mem[2]  = 32'h3012023c;
        mem[3]  = 32'hcdab4234;
        mem[4]  = 32'h23182200;
        mem[5]  = 32'h18004300;
        mem[6]  = 32'h10200000;
        mem[7]  = 32'h12280000;
        mem[8]  = 32'h00000000;
        mem[9]  = 32'h00000000;
        mem[10] = 32'h00000000;
    end
    always @(*) begin
        if (addr < 11)
            data = mem[addr];
        else
            data = 32'b0;
    end
endmodule
