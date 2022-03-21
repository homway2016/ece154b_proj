`timescale 1ns / 1ps
module control_unit(
input [5:0] funct,//instr[5:0]
input [5:0] op,//instr[31:26]
input rst_n,
output reg regwrite,
output reg memtoreg,
output reg memwrite,
output reg [1:0] branch,
output reg [3:0] alucontrol,//first bit for signed
output reg alusrc,
output reg regdst,
output reg jump,
output reg mult_sel);

wire [3:0] aluop;

main_decoder main_decoder(.op(op),.rst_n(rst_n),.aluop(aluop),.regwrite(regwrite),
            .memtoreg(memtoreg),.memwrite(memwrite),
            .branch(branch),.alusrc(alusrc),.regdst(regdst),.jump(jump));

alu_decoder alu_decoder(.funct(funct),.rst_n(rst_n),.aluop(aluop),
                        .mult_sel(mult_sel),.func(alucontrol));
                        
endmodule


`timescale 1ns / 1ps
module main_decoder(
input [5:0]op,
input rst_n,
output [3:0]aluop,//first bit is 1 --> signed
output regwrite,
output memtoreg,
output memwrite,
output [1:0]branch,//0x --> no branch, 10->beq, 11->bne
output alusrc,
output regdst,
output jump);

reg [11:0]control;

assign {aluop,regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump}=control;

always@(*) begin
    if(!rst_n)
        control = 12'b0;
    else begin 
        case(op)
            6'b000000: control = 12'b1111_110_00000;//r-type
            6'b001000: control = 12'b1000_101_00000;//addi
            6'b001001: control = 12'b0000_101_00000;//addiu
            6'b001100: control = 12'b0011_101_00000;//andi
            6'b001101: control = 12'b0010_101_00000;//ori
            6'b001110: control = 12'b0100_101_00000;//xori
            6'b001011: control = 12'b0110_101_00000;//sltiu
            6'b100011: control = 12'b0000_101_00010;//lw
            6'b101001: control = 12'b0000_001_00100;//sw
            6'b001111: control = 12'b0111_101_00000;//lui
            6'b000101: control = 12'b0001_000_11000;//bne -
            6'b000100: control = 12'b0001_000_10000;//beq -
            6'b000010: control = 12'b0000_000_00001;//j
            default:control = 12'b0;
        endcase
    end
end
endmodule

`timescale 1ns / 1ps
module alu_decoder(
input [5:0]funct,
input rst_n,
input [3:0]aluop,//first bit is 1 --> signed
output mult_sel,
output [3:0]func);

reg [4:0] ctr;
assign {mult_sel,func} = ctr;

always@(*) begin
    if(!rst_n) 
        ctr = 5'b0;
    else if (aluop == 4'b1111) begin//r-type instruction
        case(funct)
            6'b100000: ctr = 5'b01000;//add
            6'b100001: ctr = 5'b00000;//addu
            6'b100010: ctr = 5'b01001;//sub
            6'b100011: ctr = 5'b00001;//subu
            6'b100100: ctr = 5'b00010;//and
            6'b100101: ctr = 5'b00011;//or
            6'b100110: ctr = 5'b00100;//xor
            6'b100111: ctr = 5'b00101;//xnor
            6'b101010: ctr = 5'b01110;//slt
            6'b101011: ctr = 5'b00110;//sltu
            6'b000111: ctr = 5'b11000;//mult
            6'b000101: ctr = 5'b10000;//multu
        endcase
    end
    else
        ctr = {1'b0,aluop};
end
endmodule