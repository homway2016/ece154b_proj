`timescale 1ns / 1ps
module hazard_handle(
input [4:0] rsE,rtE,//forward RAW
input [4:0] rtD,//stall RAW
input [4:0] rsD,
input [4:0] writeregM,writeregW,//forward RAW
input regwriteM,regwriteW,//forward RAW
input memtoregE,//stall RAW
input [4:0] writeregE,
input pcsrcD,memtoregM,regwriteE,
input jump,//from control unit
output [1:0]forwardAE,forwardBE,
output forwardAD,forwardBD,
output flushD,
output stallF,stallD,flushE);

reg lwstall;
wire bstall;
wire bstall_temp1,bstall_temp2;
//RAW data hazard
forward_unit forward_RAW(writeregM,writeregW,rsE,rtE,regwriteM,regwriteW,forwardAE,forwardBE);
//RAW data hazard(lw)
always@(*) begin
    if(((rtD==rsE)||(rtD==rtE))&memtoregE&(rtD!=0))
        lwstall = 1;
    else lwstall = 0;
end
//assign {stallF,stallD,flushE} = {3{lwstall}};
//control hazard(branch)
assign flushD = pcsrcD | jump;
wire [1:0]forwardAD_temp,forwardBD_temp;
forward_unit forward_control(writeregM,0,rsE,rtE,regwriteM,0,forwardAD_temp,forwardBD_temp);
assign forwardAD = forwardAD_temp[0];
assign forwardBD = forwardBD_temp[0];
assign bstall_temp1 = pcsrcD&&(regwriteE&&((writeregE==rsD)||(writeregE==rtD)));
assign bstall_temp2 = pcsrcD&&(memtoregM&&((writeregM==rsD)||(writeregM==rtD)));
assign bstall = bstall_temp1 | bstall_temp2;
assign stallD = lwstall | bstall;
assign stallF = lwstall | bstall;
assign flushE = lwstall | bstall;
endmodule

`timescale 1ns / 1ps
module forward_unit(
input [4:0]baseM,baseW,
input [4:0]rs,rt,
input ctrM,ctrW,
output reg [1:0]forwardA,forwardB);
//M-->01,W-->10
always@(*) begin
    if((rs!=0)&&(rs==baseM)&&ctrM)
        forwardA = 2'b01;
    else if ((rs!=0)&&(rs==baseW)&&ctrW)
        forwardA = 2'b10;
    else
        forwardA = 2'b00;
end

always@(*) begin
    if((rt!=0)&&(rt==baseM)&&ctrM)
        forwardB = 2'b01;
    else if ((rt!=0)&&(rt==baseW)&&ctrW)
        forwardB = 2'b10;
    else
        forwardB = 2'b00;
end
endmodule