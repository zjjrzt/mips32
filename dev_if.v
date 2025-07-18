module dev_if(
    input wire rst_n,
    input wire [31:0] iaddr,
    input wire ice,
    input wire [31:0] inst_dout,
    input wire dce,
    input wire [3:0] we,
    input wire [31:0] daddr,
    input wire [31:0] din,
    input wire [31:0] data_dout,

    output reg inst_ice,
    output reg [31:0] inst_addr,
    output reg [31:0] inst,

    output reg data_ce,
    output reg [3:0] data_we,
    output reg [31:0] data_addr,
    output reg [31:0] data_din,
    output wire [31:0] dout,

    output reg io_ce,
    output reg io_we,
    output reg [31:0] io_addr,
    output reg [31:0] io_din,
    input wire [31:0] io_dout
);

//rom相关
always @(*) begin
    if (rst_n == 1'b0) begin
        inst_addr = 32'b0;
        inst_ice = 1'b0;
        inst = 32'b0;
    end else begin
        inst_addr = iaddr;
        inst_ice = ice;
        inst = inst_dout;
    end
end

//ram相关
always @(*) begin
    if (rst_n == 1'b0) begin
        data_ce = 1'b0;
        data_we = 4'b0;
        data_addr = 32'b0;
        data_din = 32'b0;
    end else begin
        data_ce = (daddr[31:16] != 4'hBFD0) ? dce : 1'b0;
        data_we = we;
        data_addr = daddr;
        data_din = din;
    end
end

//IO相关
always @(*) begin
    if (rst_n == 1'b0) begin
        io_ce = 1'b0;
        io_we = 1'b0;
        io_addr = 32'b0;
        io_din = 32'b0;
    end else begin
        io_ce = (daddr[31:16] == 4'hBFD0) ? dce : 1'b0;
        io_we = |we;
        io_addr = daddr;
        io_din = din;
    end
end

//dout输出
assign dout = (daddr[31:16] != 4'hBFD0) ? data_dout : io_dout;

endmodule
