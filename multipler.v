`timescale 1ns / 1ps
module multipler(//for add&sub, there is no different in the circut, but multiple is
input [31:0] a,
input [31:0] b,
input clk,
input sign,
output reg [31:0]multout);

wire signed [31:0]a_sign,b_sign;
reg signed [31:0]multout_sign;

always@(*) begin
    if (sign) 
        multout = a*b;
    else begin
        multout_sign = a_sign*b_sign;
        multout = multout_sign;
    end
end

endmodule