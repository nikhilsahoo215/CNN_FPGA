module PE #(parameter DATA_WIDTH = 8
            )
( 
    input clk,rst,valid_in,
    input signed [DATA_WIDTH-1:0] w0,w1,w2,
    input signed [DATA_WIDTH-1:0] w3,w4,w5,
    input signed [DATA_WIDTH-1:0] w6,w7,w8,

    output reg signed [2*DATA_WIDTH-1:0] sum,
    output reg pool_en
);

reg [DATA_WIDTH-1:0] ker [0:8];
reg [2*DATA_WIDTH-1:0] mul[0:8];
reg [2*DATA_WIDTH-1:0] add[0:2];
reg [2*DATA_WIDTH-1:0] acc_comb;
reg [2*DATA_WIDTH-1:0] acc;
integer i;

always@(*)begin
    mul[0] = w0 * ker[0]; mul[1] = w1 * ker[1]; mul[2] = w2 * ker[2];
    mul[3] = w3 * ker[3]; mul[4] = w4 * ker[4]; mul[5] = w5 * ker[5];
    mul[6] = w6 * ker[6]; mul[7] = w7 * ker[7]; mul[8] = w8 * ker[8];
end

always@(*)begin
    add[0] = mul[0] + mul[3] + mul[6];
    add[1] = mul[1] + mul[4] + mul[7];
    add[2] = mul[2] + mul[5] + mul[8];
    acc_comb = (add[0] + add[1] + add[2]);
end
// always@(*)begin
//     add[0] = (mul[0] >>> 8) + (mul[0] >>> 8) + (mul[0] >>> 8);
//     add[1] = (mul[0] >>> 8) + (mul[0] >>> 8) + (mul[0] >>> 8);
//     add[2] = (mul[0] >>> 8) + (mul[0] >>> 8) + (mul[0] >>> 8);
//     acc_comb = (add[0] + add[1] + add[2]) >>> 1;
// end

always@(posedge clk)begin
    if(rst)begin
        acc_comb <= 0;
        pool_en <= 0;
        ker[0]=1; ker[1]=1; ker[2]=4;
        ker[3]=1; ker[4]=1; ker[5]=4;
        ker[6]=1; ker[7]=1; ker[8]=4;
    end
    else if(valid_in)begin
        sum <= acc_comb;
        pool_en <= 1;
    end
    else pool_en <= 0;
end
endmodule