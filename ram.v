module ram(
    input wire clk,
    input wire ena,           // 使能
    input wire [10:0] addr,   // 2KB/4B=512=2^9，扩展为11位方便后续扩容
    input wire [3:0] wea,     // 4位写使能，支持字节写
    input wire [31:0] dina,   // 写入数据
    output reg [31:0] douta   // 读出数据
);
    reg [31:0] mem [0:511];   // 2KB/4B=512
    integer i;
    initial begin
        for (i = 0; i < 512; i = i + 1) mem[i] = 32'b0;
    end
    always @(posedge clk) begin
        if (ena) begin
            if (wea[3]) mem[addr][31:24] <= dina[31:24];
            if (wea[2]) mem[addr][23:16] <= dina[23:16];
            if (wea[1]) mem[addr][15:8]  <= dina[15:8];
            if (wea[0]) mem[addr][7:0]   <= dina[7:0];
        end
    end
    always @(*) begin
        if (ena)
            douta = mem[addr];
        else
            douta = 32'b0;
    end
endmodule