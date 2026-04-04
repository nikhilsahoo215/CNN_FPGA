module linebuffer #(parameter IMG_W = 200,
                    parameter IMG_H = 200,
                    parameter DATA_WIDTH = 8)
(
    input clk, rst,
    input valid_in,
    input [DATA_WIDTH-1:0] pixel_in,

    output reg [DATA_WIDTH-1:0] w0,w1,w2,
    output reg [DATA_WIDTH-1:0] w3,w4,w5,
    output reg [DATA_WIDTH-1:0] w6,w7,w8,

    output reg valid_out,
    output reg mem_fetch
);

localparam PAD_W = IMG_W + 2;
localparam PAD_H = IMG_H + 2;

// Line buffers
reg [DATA_WIDTH-1:0] line1 [0:PAD_W-1];
reg [DATA_WIDTH-1:0] line2 [0:PAD_W-1];
reg [DATA_WIDTH-1:0] line3 [0:PAD_W-1];

// Column and row counters
reg [$clog2(PAD_W):0] col;
reg [$clog2(PAD_W):0] row;
reg [$clog2(PAD_W):0] c_ptr;
reg [$clog2(PAD_W):0] r_ptr;
reg valid_pipe;
integer i;
reg ctr;
reg last_line;

// Shift registers (MUST be reg)
reg [DATA_WIDTH-1:0] r0[0:2];
reg [DATA_WIDTH-1:0] r1[0:2];
reg [DATA_WIDTH-1:0] r2[0:2];
reg [DATA_WIDTH-1:0] r3[0:2];

// wire is_border = (row == 0) || (row == PAD_H-1) ||
//                   (col == 0) || (col == PAD_W-1);

wire [DATA_WIDTH-1:0] pixel_pad = (last_line)?0:pixel_in;
//wire [1:0] state= (last_line)?(PAD_0):PAD_1;

always@(posedge clk)begin
    // Column update
    if (col == PAD_W-2) begin
            col <= 1;
            mem_fetch <= 0;
            // ctr <= 0;
        end
    else if(mem_fetch) col <= col + 1;

    if ((c_ptr == PAD_W)) begin
        c_ptr <= 0;
        mem_fetch = 1;
        if (r_ptr == PAD_H-2-1)begin
            r_ptr <= 0;
            last_line <= 1;
        end
        else
            r_ptr <= r_ptr + 1;
    end
    else c_ptr <= c_ptr + 1;

    // Valid condition
        if ((r_ptr >= 1 || last_line==1) && c_ptr >= 2)begin  // the c_ptr is from 0-PAD_W-1 but row is 0-IMG_W-1
            valid_pipe <= 1'b1;
            valid_out  <= valid_pipe;
        end
        else begin
            valid_pipe <= 0;
            valid_out <= 0;
        end
end

always @(posedge clk) begin
    if (rst) begin
        col <= 1;
        c_ptr <= 0;
        ctr <= 0;
        row <= 0;
        r_ptr <= 0;
        valid_out <= 0;
        mem_fetch <= 1;
        valid_pipe <= 0;
        last_line <= 0;

        for(i=0;i<PAD_W;i=i+1)begin
            line1[i] = 0;
            line2[i] = 0;
            line3[i] = 0;
        end
        for(i=0;i<3;i=i+1)begin
            r0[i] = 0;
            r1[i] = 0;
            r2[i] = 0;
        end
    end
    // case(state)
    // PAD_0:pixel_pad <= 0;
    // PAD_1:begin
    //     if(mem_fetch)begin
    //         ctr <= 1;        // the ctr is to avoid that previous stored value in reg to load into line
    //         if(ctr)begin
    //             line3[col] <= line2[col];
    //             line2[col] <= line1[col];
    //             line1[col] <= pixel_pad;
    //         end
    //     end
    //     else ctr <= 0;
    // end
    // endcase
    else if (valid_in) begin

        // Shift window
        r0[0] <= r0[1];
        r0[1] <= r0[2];
        r0[2] <= line3[c_ptr];

        r1[0] <= r1[1];
        r1[1] <= r1[2];
        r1[2] <= line2[c_ptr];

        r2[0] <= r2[1];
        r2[1] <= r2[2];
        r2[2] <= line1[c_ptr];

        r3[0] <= r3[1];
        r3[1] <= r3[2];
        r3[2] <= pixel_pad;

        // Update line buffers
        
        if(mem_fetch)begin
            ctr <= 1;        // the ctr is to avoid that previous stored value in reg to load into line
            if(ctr)begin
                line3[col] <= line2[col];
                line2[col] <= line1[col];
                line1[col] <= pixel_pad;
            end
        end
        else ctr <= 0;

        

        // Output window
        w0 <= r0[0]; w1 <= r0[1]; w2 <= r0[2];
        w3 <= r1[0]; w4 <= r1[1]; w5 <= r1[2];
        w6 <= r2[0]; w7 <= r2[1]; w8 <= r2[2];

        

    end
end

endmodule