module regfile(
    input wire clk,
    input wire rst_n,

    //写端口
    input wire [4:0] wa,       //写寄存器地址
    input wire [31:0] wd,      //写寄存器数据
    input wire we,              //写使能

    //读端口1
    input wire re1,          //读寄存器1使能
    input wire [4:0] ra1,      //读寄存器1地址
    output reg [31:0] rd1,     //读寄存器1数据

    //读端口2
    input wire re2,          //读寄存器2使能
    input wire [4:0] ra2,      //读寄存器2地址
    output reg [31:0] rd2      //读寄存器2数据
);

reg [31:0] regfile [0:31]; //32个寄存器，每个寄存器32位

// 异步复位，同步写入
integer i;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 32; i = i + 1) begin
            regfile[i] <= 32'b0;
        end
    end else if (we && wa != 5'b0) begin
        regfile[wa] <= wd;
    end
end

// 读端口1
always @(*) begin
    if (!re1) begin
        rd1 = 32'b0;
    end else if (ra1 == 5'b0) begin
        rd1 = 32'b0;
    end else begin
        rd1 = regfile[ra1];
    end
end

// 读端口2
always @(*) begin
    if (!re2) begin
        rd2 = 32'b0;
    end else if (ra2 == 5'b0) begin
        rd2 = 32'b0;
    end else begin
        rd2 = regfile[ra2];
    end
end
endmodule