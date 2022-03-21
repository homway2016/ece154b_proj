module reg_file(
input [31:0] wd,//data written in
input [4:0] a3,//write addr, for I instruction: [20:16] for R instruction: [15:11]
input clk,reg_wr,rst_n,
input [4:0] a1,a2,//read addr,[25:21]&[20:16]
output [31:0]rd1,rd2);//output data

reg [31:0] rf [31:0];
integer i;

always@(negedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        for (i=0;i<32;i=i+1) begin rf[i] <= 0; end
    end
    else begin 
        if (reg_wr) begin rf[a3] <= wd; end
    end
end 

/*always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rd1 <= 0;
        rd2 <= 0;
    end
    else begin
        rd1 <= rf[a1];
        rd2 <= rf[a2];
    end
end*/
assign rd1 = a1?rf[a1]:0; 
assign rd2 = a2?rf[a2]:0; 

endmodule