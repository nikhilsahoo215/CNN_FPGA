module linebuffer #(parameter IMG_W = 200,
                    parameter IMG_H = 200)
(
    input clk, rst,
    input valid_in,
    input [15:0] pixel_in,

    output reg [15:0] w0,w1,w2,
    output reg [15:0] w3,w4,w5,
    output reg [15:0] w6,w7,w8,

    output reg valid_out
);

// Line buffers
reg [15:0] line1 [0:IMG_W-1];
reg [15:0] line2 [0:IMG_W-1];

// Column and row counters
reg [$clog2(IMG_W):0] col;
reg [$clog2(IMG_W):0] row;

// Shift registers (MUST be reg)
reg [15:0] r0[0:2];
reg [15:0] r1[0:2];
reg [15:0] r2[0:2];

always @(posedge clk) begin
    if (rst) begin
        col <= 0;
        row <= 0;
        valid_out <= 0;
    end
    else if (valid_in) begin

        // Shift window
        r0[0] <= r0[1];
        r0[1] <= r0[2];
        r0[2] <= line2[col];

        r1[0] <= r1[1];
        r1[1] <= r1[2];
        r1[2] <= line1[col];

        r2[0] <= r2[1];
        r2[1] <= r2[2];
        r2[2] <= pixel_in;

        // Update line buffers
        line2[col] <= line1[col];
        line1[col] <= pixel_in;

        // Column update
        if (col == IMG_W-1) begin
            col <= 0;
            if (row == IMG_H-1)
                row <= 0;
            else
                row <= row + 1;
        end

        // Output window
        w0 <= r0[0]; w1 <= r0[1]; w2 <= r0[2];
        w3 <= r1[0]; w4 <= r1[1]; w5 <= r1[2];
        w6 <= r2[0]; w7 <= r2[1]; w8 <= r2[2];

        // Valid condition
        if (row >= 2 && col >= 2)
            valid_out <= 1;
        else
            valid_out <= 0;

    end
end

endmodule