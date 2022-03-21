module datapath(
input clk,
input rst_n,
input regwrite,
input memtoreg,
input memwrite,
input [1:0] branch,
input [3:0] alucontrol,//first bit for signed
input alusrc,
input regdst,
input jump,
input mult_sel,
//input for hazard handle
input [1:0]forwardAE,forwardBE,
input forwardAD,forwardBD,
input flushD,
input stallF,stallD,flushE,
//output for hazard handle
output [4:0] rsE,rtE,//forward RAW
output [4:0] rtD,//stall RAW
output [4:0] rsD,
output [4:0] writeregM,writeregW,//forward RAW
output regwriteM,regwriteW,//forward RAW
output memtoregE,//stall RAW
output [4:0] writeregE,
output pcsrcD,//for branch control
output memtoregM,regwriteE,
//
output [5:0]op,
output [5:0] funct,
output [31:0] resultW,
//loading data from outside
input [31:0] ext_data,ext_data_addr,
input ext_data_en,
input [31:0] ext_instr,ext_instr_addr,
input ext_instr_en,
input start);


wire [31:0]realoutM,writedataM;
/////////////////////Fetch///////////////////////////////
wire [31:0] pcF;
wire [31:0] instrD;
wire [31:0] pcplus4D;
wire [31:0] pc_n;
wire [31:0] pcbranchD;//branch address
wire [31:0] instrF,pcplus4F;
wire [31:0] jumpadd;//jump address
assign pcplus4F = pcF+4;

wire [31:0] pc_n_temp;

mux2 #(32) PCBranchMux(pcplus4F,pcbranchD,pcsrcD,pc_n_temp);
mux2 #(32) PCJumpMux(pc_n_temp,jumpadd,jump,pc_n);
//assign pc_n = jump?(pcsrcD?pcplus4F:pcbranchD):jumpadd;

Fetch Fetchff(clk,rst_n,stallF,pc_n,pcF);
inst_memory fetch_mem(clk,pcF,instrF,ext_instr,ext_instr_addr,ext_instr_en,start);//instruction memory

////////////////////Decode/////////////////////////
Decode Decodeff(clk,rst_n,stallD,flushD,instrF,pcplus4F,instrD,pcplus4D);

assign op = instrD[31:26];
assign funct = instrD[5:0];
wire regwriteD,memtoregD,memwriteD;
wire [1:0] branchD;
wire [4:0] a1,a2;
wire [3:0] alucontrolD;//first bit for signed
wire alusrcD,regdstD,jumpD,mult_selD;
assign {regwriteD,memtoregD,memwriteD,branchD,alucontrolD,alusrcD,regdstD,jumpD,mult_selD}=
        {regwrite,memtoreg,memwrite,branch,alucontrol,alusrc,regdst,jump,mult_sel};
assign a1 = instrD[25:21];//rs
assign a2 = instrD[20:16];//rt
wire [31:0] rd1D,rd2D,signimmD;//
wire [4:0] rdD;
wire [31:0] signimmE,rd1E,rd2E;
wire [4:0] rdE;
wire memwriteE,alusrcE,regdstE,mult_selE;
wire [3:0] alucontrolE;
assign rtD = instrD[20:16];//for I-type write 
assign rdD = instrD[15:11];//for R-tpye write
assign rsD = instrD[25:21];

wire [31:0]rd1,rd2;

reg_file reg_file(resultW,writeregW,clk,regwriteW,rst_n,a1,a2,rd1,rd2);

mux2 #(32) CtrHazardMux1(rd1,realoutM,forwardAD,rd1D);
mux2 #(32) CtrHazardMux2(rd2,realoutM,forwardBD,rd2D);//control hazard forward

wire pcsrcD_temp;
mux2 #(1) BranchMux1((rd1D == rd2D),(rd1D != rd2D),branchD[0],pcsrcD_temp);
mux2 #(1) BranchMux2(1'b0,pcsrcD_temp,branchD[1],pcsrcD);
//assign pcsrcD = branchD[1]?0:(branchD[0]?(rd1D == rd2D):(rd1D != rd2D));
assign jumpadd = {pcF[31:28],instrD[25:0],2'b0};
assign signimmD = {{16{instrD[15]}},instrD[15:0]}<<2;
assign pcbranchD = pcplus4D+signimmD;


wire [31:0] srcaE,srcbE;
wire [31:0] aluoutE, multoutE;
wire [31:0] writedataE;
wire [31:0] rd1E_temp,rd2E_temp;
/////////////////////////Execution///////////////////////////////
Execute Executeff(clk,rst_n,flushE,signimmD,rd1D,rd2D,rtD,rdD,rsD,regwriteD,memtoregD,memwriteD,alusrcD,regdstD,mult_selD,
                    alucontrolD,signimmE,rd1E_temp,rd2E_temp,rtE,rdE,rsE,alucontrolE,
                    regwriteE,memtoregE,memwriteE,alusrcE,regdstE,mult_selE);

mux3 #(32) RAWHazardMux1(rd1E_temp,resultW,realoutM,forwardAE,rd1E);
mux3 #(32) RAWHazardMux2(rd2E_temp,resultW,realoutM,forwardBE,rd2E);//RAW Hazard forward

assign srcaE = rd1E;
mux2 #(32) SrcBMux(rd2E,signimmE,alusrcE,srcbE);
//assign srcbE = alusrcE?signimmE:rd2E;

alu alu(srcaE,srcbE,alucontrolE,aluoutE); 
multipler multipler(srcaE,srcbE,clk,alucontrolE[3],multoutE);//alucontrolE[2]=1,signed

wire [31:0] realoutE;
wire memwriteM;

mux2 #(32) ALU_MULT_Mux(aluoutE,multoutE,mult_sel,realoutE);
//assign realoutE = mult_selE?aluoutE:multoutE;
assign writedataE = rd2E;
mux2 #(5) regMux(rtE,rdE,regdstE,writeregE);
//assign writeregE = regdstE?rtE:rdE;


///////////////////////Memory////////////////////////////////
Memory Memoryff(clk,rst_n,regwriteE,memtoregE,memwriteE,realoutE,writedataE,writeregE,
                regwriteM,memtoregM,memwriteM,realoutM,writedataM,writeregM);

wire [31:0]readdataM;

data_memory data_memory(realoutM,writedataM,clk,memwriteM,readdataM,ext_data,ext_data_addr,ext_data_en);

wire memtoregW;
wire [31:0]readdataW,realoutW;
///////////////////////Writeback/////////////////////////////////
WriteBack WriteBackff(clk,rst_n,regwriteM,memtoregM,realoutM,writeregM,readdataM,
                        regwriteW,memtoregW,realoutW,writeregW,readdataW);
mux2 #(32) ResultMux(realoutW,readdataW,memtoregW,resultW);
//assign resultW = memtoregW?realoutW:readdataW;
endmodule

`timescale 1ns / 1ps
module Fetch(
input clk, rst_n,
input enable_n,
input [31:0] pc_n,
output reg [31:0] pcF);

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        pcF<=0;
    else if(!enable_n)
        pcF<=pc_n;
end
endmodule

module Decode(
input clk,rst_n,
input enable_n, flushD,
input [31:0] instrF,pcplus4F,
output reg [31:0] instrD,pcplus4D);

always@(posedge clk or negedge rst_n or posedge flushD)
begin
    if(!rst_n) begin
        instrD <= 0;
        pcplus4D <= 0;
    end
    else if (flushD) begin
        instrD <= 0;
        pcplus4D <= 0;
    end
    else if (!enable_n) begin
        instrD <= instrF;
        pcplus4D <= pcplus4F;
    end
end
endmodule

module Execute(
input clk,rst_n,
input flushE,
input [31:0] signimmD,rd1D,rd2D,
input [4:0] rtD,rdD,rsD,
input regwriteD,memtoregD,memwriteD,alusrcD,regdstD,mult_selD,
input [3:0]alucontrolD,
output reg [31:0] signimmE,rd1E,rd2E,
output reg [4:0] rtE,rdE,rsE,
output reg [3:0] alucontrolE,
output reg regwriteE,memtoregE,memwriteE,alusrcE,regdstE,mult_selE);

always@(posedge clk,negedge rst_n,posedge flushE)
begin
    if((!rst_n) || flushE) begin
        signimmE <= 0;
        rd1E <= 0;
        rd2E <= 0;
        {regwriteE,memtoregE,memwriteE,alucontrolE,alusrcE,regdstE,mult_selE} <= 0;
        rtE <= 0;
        rdE <= 0;
        rsE <= 0;
    end
    else begin
        signimmE <= signimmD;
        rd1E <= rd1D;
        rd2E <= rd2D;
        {regwriteE,memtoregE,memwriteE,alucontrolE,regdstE,mult_selE} <= 
        {regwriteD,memtoregD,memwriteD,alucontrolD,regdstD,mult_selD};
        alusrcE <= alusrcD;
        rtE <= rtD;
        rdE <= rdD;
        rsE <= rsD;
    end
end
endmodule

module Memory(
input clk,rst_n,
input regwriteE,memtoregE,memwriteE,
input [31:0]realoutE,writedataE,
input [4:0]writeregE,
output reg regwriteM,
output reg memtoregM,memwriteM,
output reg [31:0]realoutM,writedataM,
output reg [4:0]writeregM);

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n) begin
        {regwriteM,memtoregM,memwriteM} <= 0;
        realoutM <= 0;
        writedataM <= 0;
        writeregM <= 0;
    end
    else begin
        {regwriteM,memtoregM,memwriteM} <= {regwriteE,memtoregE,memwriteE};
        realoutM <= realoutE;
        writedataM <= writedataE;
        writeregM <= writeregE;
    end
end
endmodule

module WriteBack(
input clk,rst_n,
input regwriteM,memtoregM,
input [31:0]realoutM,
input [4:0]writeregM,
input [31:0]readdataM,
output reg regwriteW,memtoregW,
output reg [31:0]realoutW,
output reg [4:0]writeregW,
output reg [31:0]readdataW);

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n) begin
        regwriteW <= 0;
        memtoregW <= 0;
        readdataW <= 0;
        realoutW <= 0;
        writeregW <= 0;
    end
    else begin
        regwriteW <= regwriteM;
        memtoregW <= memtoregM;
        readdataW <= readdataM;
        realoutW <= realoutM;
        writeregW <= writeregM;
    end
end
endmodule

`timescale 1ns / 1ps
module mux3 #(parameter WIDTH=8)(
input [WIDTH-1:0]a,
input [WIDTH-1:0]b,
input [WIDTH-1:0]c,
input [1:0]sel,
output reg [WIDTH-1:0]d);

always@(*)
begin
    case(sel)
        2'b00: d=a;
        2'b01: d=b;
        2'b10: d=c;
        default: d=0;
    endcase
end
endmodule

`timescale 1ns / 1ps
module mux2 #(parameter WIDTH=8)(
input [WIDTH-1:0]a,
input [WIDTH-1:0]b,
input sel,
output [WIDTH-1:0]c);

assign c = sel?b:a;

endmodule