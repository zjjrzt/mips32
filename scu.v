module scu(
    input wire rst_n,
    input wire stallreq_id,
    input wire stallreq_exe,
    output wire [3:0] stall
);

reg [3:0] stall_r;
assign stall = (rst_n) ? stall_r : 4'b0000;
always @(*) begin
    if (rst_n == 1'b0)
        stall_r = 4'b0000;
    else if (stallreq_exe === 1'b1)
        stall_r = 4'b1111;
    else if (stallreq_id === 1'b1)
        stall_r = 4'b0111;
    else
        stall_r = 4'b0000;
end

endmodule