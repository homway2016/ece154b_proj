module inst_memory(
input clk,//for writing memory
input [31:0] a,
output reg [31:0] rd,
input [31:0] ext_instr,ext_instr_addr,
input ext_instr_en,
input start);

reg [7:0] inst_mem [255:0];

always@(*)
begin
    if(start == 1)
        rd = {inst_mem[a],inst_mem[a+1],inst_mem[a+2],inst_mem[a+3]};
    else 
        rd = 0;
end

integer n;

always@(posedge clk)
begin
    if(ext_instr_en) begin
        inst_mem[ext_instr_addr]<=ext_instr[31:24];
        inst_mem[ext_instr_addr+1]<=ext_instr[23:16];
        inst_mem[ext_instr_addr+2]<=ext_instr[15:8];
        inst_mem[ext_instr_addr+3]<=ext_instr[7:0];
    end
end
endmodule