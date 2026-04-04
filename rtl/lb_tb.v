`timescale 1ns/1ps

module lb_tb;
    reg clk,rst,valid_in;
    reg [7:0]data_in;
    wire [7:0]w0,w1,w2,w3,w4,w5,w6,w7,w8;
    wire valid_out;
    wire mem_fetch;
    reg [7:0] mem [0:63];
    reg [5:0] ctr;

    integer i;

    linebuffer #(8,8,8) lb(clk,rst,valid_in,data_in,w0,w1,w2,w3,w4,w5,w6,w7,w8,valid_out,mem_fetch);

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        i=0;
        ctr = 0;
        valid_in = 0;
        for(i = 0;i<64;i=i+1)begin
                mem[i] = i;
        end
        #20
        rst = 0;
        valid_in = 1; 
        for(i = 0;i < 200;i = i+1)begin
            if(mem_fetch)begin
                data_in = mem[ctr];
                ctr = ctr+1; 
                //valid_in = 1;
            end         
            #10; 
            //valid_in = 0;             
        end
    end
endmodule