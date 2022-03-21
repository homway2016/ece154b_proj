module alu(
input [31:0] in1,
input [31:0] in2,
input [3:0] func,
output reg[31:0] aluout);

always @(*) begin
    case (func[2:0]) 
        3'b000 : aluout = in1+in2;
        3'b001 : aluout = in1-in2;
        3'b010 : aluout = in1|in2;
        3'b011 : aluout = in1&in2;
        3'b100 : aluout = in1^in2;
        3'b101 : aluout = ~(in1^in2);
        3'b110 : aluout = (in1-in2)?0:1;//slt
        3'b111 : aluout = {in2[15:0],16'b0};//lui
        default : aluout = 32'b0;
    endcase
end
endmodule