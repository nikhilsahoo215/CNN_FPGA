module top_module #(parameter IMG_W = 200,
                    parameter IMG_H = 200,
                    parameter DATA_WIDTH = 8)
(
    input clk,rst,valid_in,
    input signed [DATA_WIDTH-1:0] data_in,

    output reg signed [2*DATA_WIDTH-1:0] sum_tb,
    output reg valid_out_pe,
    output reg mem_fetch_tb
);

wire signed [DATA_WIDTH-1:0] w0,w1,w2;
wire signed [DATA_WIDTH-1:0] w3,w4,w5;
wire signed [DATA_WIDTH-1:0] w6,w7,w8;

wire valid_out;
wire mem_fetch;
wire [2*DATA_WIDTH-1:0] sum;
wire [2*DATA_WIDTH-1:0] pool_data;
wire pool_done;
wire pool_en;

reg signed [DATA_WIDTH-1:0] w0_pe,w1_pe,w2_pe;
reg signed [DATA_WIDTH-1:0] w3_pe,w4_pe,w5_pe;
reg signed [DATA_WIDTH-1:0] w6_pe,w7_pe,w8_pe;

// assign valid_out =  rst?0:valid_out;
// assign mem_fetch =  rst?0:mem_fetch;
// assign sum =  rst?0:sum;

always@(posedge clk)begin
    mem_fetch_tb <= mem_fetch;
    sum_tb <= sum;
    valid_out_pe <= valid_out;
end

always@(posedge clk)begin
    if(rst)begin
        valid_out_pe <= 0;
    end
    else if(valid_out)begin
        w0_pe <= w0; w1_pe <= w1; w2_pe <= w2;
        w3_pe <= w3; w4_pe <= w4; w5_pe <= w5;
        w6_pe <= w6; w7_pe <= w7; w8_pe <= w8;
    end
end

linebuffer #(8,8,8) lb(clk,rst,valid_in,data_in,w0,w1,w2,w3,w4,w5,w6,w7,w8,valid_out,mem_fetch);
PE #(8) pe1(clk,rst,valid_out_pe,w0_pe,w1_pe,w2_pe,w3_pe,w4_pe,w5_pe,w6_pe,w7_pe,w8_pe,sum,pool_en);
max_pool #(8,8,8,2) mp(clk,rst,pool_en,sum,pool_data,pool_done);
// paul_pool pp(clk,sum,pool_en,pool_done,pool_data);
// PE #(8) pe1(clk,rst,valid_out,w0,w1,w2,w3,w4,w5,w6,w7,w8,sum);

endmodule