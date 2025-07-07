module hilo(
    input wire clk,
    input wire rst_n,

    input wire we,
    input wire [31:0] hi_i,
    input wire [31:0] lo_i,


    output reg [31:0] hi_o,
    output reg [31:0] lo_o
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        hi_o <= 32'h0;
        lo_o <= 32'h0;
    end
    else if (we) begin
        hi_o <= hi_i;
        lo_o <= lo_i;
    end
end

endmodule