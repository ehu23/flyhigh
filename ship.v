module ship #(
    H_SIZE=80,      // half square width (for ease of co-ordinate calculations)
    IX=320,         // initial horizontal position of square centre
    IY=240,         // initial vertical position of square centre
    D_WIDTH=640,    // width of display
    D_HEIGHT=480    // height of display
    )
    // The above values are default parameters if none are supplied.
    (
    input wire i_clk,         // base clock
    input wire i_ani_stb,     // animation clock: pixel clock is 1 pix/frame
    input wire i_rst,         // reset: returns animation to starting position
    input wire i_animate,     // animate when input is high
    input wire [3:0] sw,      // movement switches
    output wire [11:0] o_x1,  // square left edge: 12-bit value: 0-4095. We use 12 bits so this module can be used on 4k as well.
    output wire [11:0] o_x2,  // square right edge
    output wire [11:0] o_y1,  // square top edge
    output wire [11:0] o_y2   // square bottom edge
    );

    reg [11:0] x = IX;   // horizontal position of square centre
    reg [11:0] y = IY;   // vertical position of square centre

    assign o_x1 = x - H_SIZE;  // left: centre minus half horizontal size
    assign o_x2 = x + H_SIZE;  // right
    assign o_y1 = y - H_SIZE;  // top
    assign o_y2 = y + H_SIZE;  // bottom

    always @ (posedge i_clk)
    begin
        if (i_rst)  // on reset return to starting position
        begin
            x <= IX;
            y <= IY;
        end
        if (i_animate && i_ani_stb)
        begin
            if (sw[0])
                x <= x - 1'b1;
            if (sw[3])
                x <= x + 1'b1;
            if (sw[1])
                y <= y - 1'b1;
            if (sw[2])
                y <= y + 1'b1;

            if (x <= H_SIZE + 1'b1)  // edge of square is at left of screen
                x <= H_SIZE + 1'b1;  // stay put
            if (x >= (D_WIDTH - H_SIZE - 1'b1))  // edge of square at right
                x <= D_WIDTH - H_SIZE - 1'b1;  // stay put          
            if (y <= H_SIZE + 1'b1)  // edge of square at top of screen
                y <= H_SIZE + 1'b1;  // stay put
            if (y >= (D_HEIGHT - H_SIZE - 1'b1))  // edge of square at bottom
                y <= D_HEIGHT - H_SIZE - 1'b1;  // stay put              
        end
    end
endmodule
