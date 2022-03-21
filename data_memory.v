module data_memory(
input [31:0] a,
input [31:0] wd,
input clk,
input we,//enable signal
output [31:0] rd,
input [31:0] ext_data,ext_data_addr,
input ext_data_en);

reg [7:0] data_ram [255:0];

assign rd = {data_ram[a],data_ram[a+1],data_ram[a+2],data_ram[a+3]};//word aligned

integer n;
always@(posedge clk) begin
    //if (!rst_n) begin
    //    for(n=0;n<255;n=n+1) 
    //        data_ram[n]<=0;
    //end
//    else
    if(ext_data_en)
        {data_ram[ext_data_addr],data_ram[ext_data_addr+1],data_ram[ext_data_addr+2],data_ram[ext_data_addr+3]} <= ext_data;
    if (we) 
        {data_ram[a],data_ram[a+1],data_ram[a+2],data_ram[a+3]} <= wd;
end
endmodule