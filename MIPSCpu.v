`timescale 1ns / 1ps
module MIPSCpu(
input clk, rst_n,
input [31:0] ext_data,ext_data_addr,
input ext_data_en,
input [31:0] ext_instr,ext_instr_addr,
input ext_instr_en,
output [31:0] result,
input start);

wire regwrite,memtoregE,regwriteM,regwriteW,pcsrcD,memtoregM,regwriteE,memtoreg,memwrite;
wire [1:0] branch,forwardAE,forwardBE;
wire [3:0] alucontrol;
wire alusrc,regdst,jump,mult_sel,forwardAD,forwardBD,flushD,stallF,stallD,flushE;
wire[4:0] rsE,rtE,rtD,rsD,writeregM,writeregW,writeregE;
wire [5:0]op,funct;
    
datapath datapath(clk,rst_n,regwrite,memtoreg,memwrite,branch,alucontrol,
                    alusrc,regdst,jump,mult_sel,forwardAE,forwardBE,forwardAD,forwardBD,
                    flushD,stallF,stallD,flushE,rsE,rtE,rtD,rsD,writeregM,writeregW,
                    regwriteM,regwriteW, memtoregE,writeregE,pcsrcD,memtoregM,regwriteE,
                    op,funct,result,ext_data,ext_data_addr,ext_data_en,ext_instr,
                    ext_instr_addr,ext_instr_en,start);
                    
hazard_handle hazard_handle(rsE,rtE,rtD,rsD,writeregM,writeregW,regwriteM,regwriteW,
                            memtoregE,writeregE,pcsrcD,memtoregM,regwriteE,jump,
                            forwardAE,forwardBE,forwardAD,forwardBD,flushD,
                            stallF,stallD,flushE);
                            
control_unit control_unit(funct,op,rst_n,regwrite,memtoreg,memwrite,branch,alucontrol,
                        alusrc,regdst,jump,mult_sel);

endmodule