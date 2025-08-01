module mips32(
    input clock,
    input rst_n,

    output wire [15:0] led,
    output wire [2:0] rgb_reg0,
    output wire [2:0] rgb_reg1,
    output wire stcp,
    output wire shcp,
    output wire ds,
    output wire oe
);

    wire [31:0] iaddr;
    wire ice;
    wire dce;
    wire [31:0] daddr;
    wire [3:0] we;
    wire [31:0] din;
    wire [31:0] inst_dout;
	 wire [31:0] data_din;

    
    wire [31:0] dout;
    wire inst_ce;
    wire [31:0] inst_addr;
    wire [31:0] inst;
    wire data_ce;
    wire data_we;
    wire [31:0] data_addr;
    
    wire io_ce;
    wire io_we;
    wire [31:0] io_addr;
    wire [31:0] io_din;
    wire [31:0] data_dout;
    wire [31:0] io_dout;

    reg clk;
    // 时钟分频逻辑，将 clock 从 50MHz 分频为 150kHz
    reg [8:0] cnt;
    always @(posedge clock or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 9'd0;
            clk <= 1'b0;
        end else if (cnt == 9'd333) begin
            cnt <= 9'd0;
            clk <= ~clk;
        end else begin
            cnt <= cnt + 1'b1;
        end
    end
    wire [7:0] num_csn;
    wire [6:0] num_a_g;
    wire [41:0] data_595;
    wire [5:0] point;
    wire seg_en;
    wire sign;

    data u_data(
        .clk(clk),
        .rst_n(rst_n),
        .data_in(num_a_g),
        .addr_in(num_csn),
        .data_out(data_595),
        .point(point),
        .seg_en(seg_en),
        .sign(sign)
    );

    seg_595_dynamic u_seg_595_dynamic(
        .sys_clk(clk),
        .sys_rst_n(rst_n),
        .data(data_595),
        .point(point),
        .seg_en(seg_en),
        .sign(sign),
        .stcp(stcp),
        .shcp(shcp),
        .ds(ds),
        .oe(oe),
        .led(led)
    );



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
        .rst_n(rst_n),
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

    rom	rom_inst (
	.address ( inst_addr[13:2] ),
	.clock ( clk ),
	.rden ( inst_ce ),
	.q ( inst_dout )
	);

    ram	ram_inst (
	.address ( data_addr[10:0] ),
	.clock ( clk ),
	.data ( data_din ),
	.rden ( data_ce ),
	.wren ( data_we ),
	.q ( data_dout )
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