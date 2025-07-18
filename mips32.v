module minips32(
    input clk,
    input rst_n,

    output wire [15:0] led,
    output wire [2:0] rgb_reg0,
    output wire [2:0] rgb_reg1,
    output wire [7:0] num_csn,
    output wire [6:0] num_a_g
);

    wire [31:0] iaddr;
    wire ice;
    wire dce;
    wire [31:0] daddr;
    wire [3:0] we;
    wire [31:0] din;

    wire [31:0] inst_dout;
    wire [31:0] dout;
    wire inst_ce;
    wire [31:0] inst_addr;
    wire [31:0] inst;
    wire data_ce;
    wire [31:0] data_we;
    wire [31:0] data_addr;
    wire [31:0] data_din;
    wire io_ce;
    wire io_we;
    wire [31:0] io_addr;
    wire [31:0] io_din;

    top u_top(
        .clk(clk),
        .rst_n(rst_n),
        .iaddr(iaddr),
        .ice(ice),
        .inst(inst),
        .dce(dce),
        .daddr(daddr),
        .we(we),
        .din(din),
        .dm(dout),
        .int(6'b0)
    );
    dev_if u_dev_if(
        .ice(ice),
        .iaddr(iaddr),
        .dce(dce),
        .daddr(daddr),
        .we(we),
        .din(din),
        .inst_dout(inst_dout),
        .data_dout(data_dout),
        .io_dout(io_dout),
        .inst(inst),
        .dout(dout),
        .inst_ice(inst_ce),
        .inst_addr(inst_addr),
        .data_ce(data_ce),
        .data_we(data_we),
        .data_addr(data_addr),
        .data_din(data_din),
        .io_ce(io_ce),
        .io_we(io_we),
        .io_addr(io_addr),
        .io_din(io_din)
    );

    rom u_rom(
        .clk(clk),
        .ena(inst_ce),
        .addra(inst_addr[15:2]),
        .douta(inst_dout)
    );

    ram u_ram(
        .clk(clk),
        .ena(data_ce),
        .wea(data_we),
        .addr(data_addr[16:0]),
        .dina(data_din),
        .douta(data_dout)
    );

    io_dec u_io(
        .clk(clk),
        .rst_n(rst_n),
        .ce(io_ce),
        .we(io_we),
        .addr(io_addr),
        .din(io_din),
        .dout(io_dout),
        .led(led),
        .led_reg0(rgb_reg0),
        .led_reg1(rgb_reg1),
        .num_csn(num_csn),
        .num_a_g(num_a_g)
    );

endmodule