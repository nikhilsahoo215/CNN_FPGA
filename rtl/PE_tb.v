`timescale 1ns/1ps

module PE_tb;
    reg clk,rst,valid_in;
    reg [7:0]data_in;
    reg [7:0] w0_pe,w1_pe,w2_pe,w3_pe,w4_pe,w5_pe,w6_pe,w7_pe,w8_pe;
    wire [7:0]w0,w1,w2,w3,w4,w5,w6,w7,w8;
    wire valid_out;
    reg valid_out_pe;
    wire mem_fetch;
    reg [7:0] mem [0:63];
    reg [5:0] ctr;
    wire [7:0] sum;
    integer i;

    linebuffer #(8,8,8) lb(clk,rst,valid_in,data_in,w0,w1,w2,w3,w4,w5,w6,w7,w8,valid_out,mem_fetch);
    PE #(8) pe1(clk,rst,valid_out,w0_pe,w1_pe,w2_pe,w3_pe,w4_pe,w5_pe,w6_pe,w7_pe,w8_pe,sum);

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
    initial begin
        for(i = 0;i < 200;i = i+1)begin
            if(valid_out)begin
                valid_out_pe <= valid_out;
                w0_pe=w0;w1_pe=w1;w2_pe=w2;
                w3_pe=w3;w4_pe=w4;w5_pe=w5;
                w6_pe=w6;w7_pe=w7;w8_pe=w8;
                #10;
        end
        end
    end
endmodule