module max_pool #(parameter IMG_W = 200,
                  parameter IMG_H = 200,
                  parameter DATA_WIDTH = 8,
                  parameter DIM = 2)
(
    input clk,rst,valid_in,
    input signed [2*DATA_WIDTH-1:0] data_in,

    output reg signed [2*DATA_WIDTH-1:0] pool_data,
    output reg pool_done

);

reg [2*DATA_WIDTH-1:0] line1 [0:IMG_W];
// reg [2*DATA_WIDTH-1:0] line2 [0:IMG_W];

reg [2*DATA_WIDTH-1:0] r0 [0:DIM-1];
reg [2*DATA_WIDTH-1:0] r1 [0:DIM-1];

reg [4:0] col;
reg [4:0] row;
reg pool_en;
reg valid_in_1;
reg valid_in_2;
integer i;
reg [1:0] ctr;
reg [2*DATA_WIDTH-1:0] row_1_max;
reg [2*DATA_WIDTH-1:0] row_2_max;

always@(posedge clk)begin
    if(col == ((IMG_W >> 1)-1))begin
//        col <= 0;
        if(row == IMG_H-1)begin
            row <= 0;
            pool_done <= 1;
        end
        row <= row + 1;
    end

    if(row >= 1 || col >= 1)begin
        pool_en <= 1;
    end
    else pool_en <= 0;
end
// line_buffer #(8,8,8) lb();
always@(posedge clk)begin
    if (rst) begin
        col <= 0;
        row <= 0;
        pool_done <= 0;
        pool_en <= 0;
        ctr <= 0;
        pool_data <= 0;

        for(i=0;i<IMG_W;i=i+1)begin
            line1[i] = 0;
        end
        for(i=0;i<2;i=i+1)begin
            r0[i] = 0;
            r1[i] = 0;
        end
    end

    else begin

        // Shift window
        // r0[0] <= r0[1];
        // r0[1] <= line1[col];

        // r1[0] <= r1[1];
        // r1[1] <= data_in;

        // line1[col] <= data_in;

        // Output window
//        w0 <= r0[0]; w1 <= r0[1];
//        w2 <= r1[0]; w3 <= r1[1]; 
        if(valid_in)begin
            if((ctr==0) && (col == 4))begin
                ctr <= 0;
                col <= 0;
            end
            else if((ctr == 1))begin
                if(pool_en)begin
                    pool_data <= row_2_max;
                end
                line1[col] <= row_1_max;
                row_1_max <= (r1[1] > data_in) ? r1[1] : data_in;
                row_2_max <= (line1[col] > ((r1[1] > data_in) ? r1[1] : data_in)) ? line1[col] : ((r1[1] > data_in) ? r1[1] : data_in);
                ctr <= 0;
                col <= col+1;
            end
            else begin
                r1[0] <= r1[1];
                r1[1] <= data_in;
                ctr <= ctr + 1;

            end
        end
    end
end
// always@(*)begin
//     row_1_max = (r1[1] > data_in) ? r1[1] : data_in;
//     row_2_max = (line1[col] > row_1_max) ? line1[col] : row_1_max;
// end

// always@(posedge clk)begin
//     if(valid_in)begin
//         valid_in_1 <= valid_in;
//         valid_in_2 <= valid_in_1;
//     end
//     if(pool_en && valid_in)begin
//         row_1_max <= (r0[1] > r0[0]) ? r0[1] : r0[0];
//         row_2_max <= (r1[1] > r1[0]) ? r1[1] : r1[0];
//         pool_data <= (row_1_max > row_2_max)?(row_1_max):(row_2_max);
//     end
// end

endmodule

