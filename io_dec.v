module io_dec(
    input wire clk,
    input wire rst_n,
    input wire ce,
    input wire [31:0] addr,
    input wire we,
    input wire [31:0] din,

    output [31:0] dout,
    output [15:0] led,
    output [2:0] led_reg0,
    output [2:0] led_reg1,
    output reg [7:0] num_csn,
    output reg [6:0] num_a_g
);

//IO读写使能信号
wire led_we = we && (addr[15:0] == 16'hf000);
wire led_reg0_we = we && (addr[15:0] == 16'hf100);
wire led_reg1_we = we && (addr[15:0] == 16'hf104);
wire num_we = we && (addr[15:0] == 16'hf200);
wire timer_we = we && (addr[15:0] == 16'he000);




wire [31:0] data_i = {din[7:0], din[15:8], din[23:16], din[31:24]};

reg [31:0] led_data;
assign led = led_data[15:0];
reg [31:0] led_reg0_data;
assign led_reg0 = led_reg0_data[2:0];
reg [31:0] led_reg1_data;
assign led_reg1 = led_reg1_data[2:0];
reg [31:0] num_data;

//IO输出信号
always @ (posedge clk) begin
    if (rst_n == 1'b0) begin
        led_data <= 32'b0;
        led_reg0_data <= 32'b0;
        led_reg1_data <= 32'b0;
        num_data <= 32'b0;
    end else begin
        if (ce == 1'b1) begin
            case ({led_we, led_reg0_we, led_reg1_we, num_we})
                4'b1000: led_data <= data_i;
                4'b0100: led_reg0_data <= data_i;
                4'b0010: led_reg1_data <= data_i;
                4'b0001: num_data <= data_i;
                default: ;
            endcase
        end
    end
end

//timer计时器
reg [31:0] timer;
always @ (posedge clk) begin
    if (rst_n == 1'b0) begin
        timer <= 32'b0;
    end else if (timer_we) begin
        timer <= data_i;
    end else begin
        timer <= timer + 1'b1;
    end
end
wire [31:0] data_t = (addr[15:0] == 16'he000) ? timer : 32'b0;
assign dout = {data_t[7:0], data_t[15:8], data_t[23:16], data_t[31:24]};

//数码管显示
reg [19:0] div_counter;
always @ (posedge clk) begin
    if (rst_n == 1'b0) begin
        div_counter <= 20'b0;
    end else begin
        div_counter <= div_counter + 1'b1;
    end
end

parameter [2:0] SEG1 = 3'b000;
parameter [2:0] SEG2 = 3'b001;
parameter [2:0] SEG3 = 3'b010;
parameter [2:0] SEG4 = 3'b011;
parameter [2:0] SEG5 = 3'b100;
parameter [2:0] SEG6 = 3'b101;
parameter [2:0] SEG7 = 3'b110;
parameter [2:0] SEG8 = 3'b111;

reg [3:0] value;
always @ (posedge clk) begin
    if (rst_n == 1'b0) begin
        num_csn <= 8'b11111111;
        value <= 4'b0;
    end else begin
        case(div_counter[19:17])
            SEG1: begin
                num_csn <= 8'b01111111;
                value <= num_data[31:28];
            end
            SEG2: begin
                num_csn <= 8'b10111111;
                value <= num_data[27:24];
            end
            SEG3: begin
                num_csn <= 8'b11011111;
                value <= num_data[23:20];
            end
            SEG4: begin
                num_csn <= 8'b11101111;
                value <= num_data[19:16];
            end
            SEG5: begin
                num_csn <= 8'b11110111;
                value <= num_data[15:12];
            end
            SEG6: begin
                num_csn <= 8'b11111011;
                value <= num_data[11:8];
            end
            SEG7: begin
                num_csn <= 8'b11111101;
                value <= num_data[7:4];
            end
            SEG8: begin
                num_csn <= 8'b11111110;
                value <= num_data[3:0];
            end
            default: begin
                num_csn <= 8'b11111111;
                value <= 4'b0;
            end
        endcase
    end
end

always @ (posedge clk) begin
    if (rst_n == 1'b0) begin
        num_a_g <= 7'b0000000;
    end else begin
        case(value)
            4'h0: num_a_g <= 7'b0000001; // 0
            4'h1: num_a_g <= 7'b1001111; // 1
            4'h2: num_a_g <= 7'b0010010; // 2
            4'h3: num_a_g <= 7'b0000110; // 3
            4'h4: num_a_g <= 7'b1001100; // 4
            4'h5: num_a_g <= 7'b0100100; // 5
            4'h6: num_a_g <= 7'b0100000; // 6
            4'h7: num_a_g <= 7'b0001111; // 7
            4'h8: num_a_g <= 7'b0000000; // 8
            4'h9: num_a_g <= 7'b0000100; // 9
            4'h10: num_a_g <= 7'b0001000; // A
            4'h11: num_a_g <= 7'b1100000; // B
            4'h12: num_a_g <= 7'b0110001; // C
            4'h13: num_a_g <= 7'b1000010; // D
            4'h14: num_a_g <= 7'b0110000; // E
            4'h15: num_a_g <= 7'b0111000; // F
            default: num_a_g <= 7'b0000000; // 无效
        endcase
    end
end

endmodule