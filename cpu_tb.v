`timescale 1ns / 1ps
module cpu_tb();

parameter SIZE_MEM = 10;
parameter SIZE_IM = 6;

reg clk;
reg rst_n;
reg [31:0] ext_data,ext_data_addr;
reg ext_data_en;
reg [31:0] ext_instr,ext_instr_addr;
reg ext_instr_en;
reg start;
wire [31:0] result;

reg [31:0]inst_mem_tb[SIZE_IM-1:0];
reg [31:0]data_mem_tb[SIZE_MEM-1:0];

integer i;

MIPSCpu cpu(clk,rst_n,ext_data,ext_data_addr,ext_data_en,ext_instr,ext_instr_addr,ext_instr_en,result,start);

always
begin
    #50 clk = !clk;
end

initial 
begin
    $readmemh("C:/Users/chenx/mips_5stages/mips_5stages.srcs/sources_1/new/im_file.txt",inst_mem_tb);
    $readmemh("C:/Users/chenx/mips_5stages/mips_5stages.srcs/sources_1/new/mem_file.txt",data_mem_tb);
end

initial 
begin
    rst_n = 1;
    clk = 1;
    ext_data = 0;
    ext_data_addr = 0;
    ext_data_en = 0;
    ext_instr = 0;
    ext_instr_addr = 0;
    ext_instr_en = 0;
    start = 0;
    @(negedge clk);
    for (i=0;i<SIZE_IM;i=i+1) begin//loading instruction memory
        ext_instr_en = 1;
        ext_instr_addr = 4*i;
        ext_instr = inst_mem_tb[i];
        @(negedge clk);
    end
    ext_instr = 0;
    ext_instr_addr = 0;
    ext_instr_en = 0;
    @(negedge clk);
        for (i=0;i<SIZE_MEM;i=i+1) begin//loading data memory
        ext_data_en = 1;
        ext_data_addr = 4*i;
        ext_data = data_mem_tb[i];
        @(negedge clk);
    end
    ext_data = 0;
    ext_data_addr = 0;
    ext_data_en = 0;
    @(negedge clk);
    #20
    rst_n = 0;
    #20
    rst_n = 1;
    start = 1;
end
endmodule