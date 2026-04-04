module PE #(parameter DATA_WIDTH = 8
            )
( 
    input clk,rst,valid_out,
    input [DATA_WIDTH-1:0] w0,w1,w2,
    input [DATA_WIDTH-1:0] w3,w4,w5,
    input [DATA_WIDTH-1:0] w6,w7,w8,

    output[7:0] sum
);

reg [7:0] ker [0:8];
reg [15:0] mul[0:8];
reg [8:0] add[0:2];
reg [8:0] acc_comb;
reg [7:0] acc;
integer i;

always@(*)begin
    mul[0] = w0 * ker[0]; mul[1] = w1 * ker[1]; mul[2] = w2 * ker[2];
    mul[3] = w3 * ker[3]; mul[4] = w4 * ker[4]; mul[5] = w5 * ker[5];
    mul[6] = w6 * ker[6]; mul[7] = w7 * ker[7]; mul[8] = w8 * ker[8];
end

always@(*)begin
    add[0] = (mul[0] >>> 8) + (mul[0] >>> 8) +(mul[0] >>> 8);
    add[1] = (mul[0] >>> 8) + (mul[0] >>> 8) +(mul[0] >>> 8);
    add[2] = (mul[0] >>> 8) + (mul[0] >>> 8) +(mul[0] >>> 8);
    acc_comb = (add[0] + add[1] + add[2]) >>> 1;
end

always@(posedge clk)begin
    if(rst)begin
        acc <= 0;
        for(i = 0;i<9;i=i+1)begin
            ker[i] = 0;
        end
    end
    else if(valid_out)begin
        acc <= acc_comb;
    end
end
endmodule