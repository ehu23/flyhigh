module lightspeed #(
    H_SIZE=80,      // half square width (for ease of co-ordinate calculations)
    IX=320,         // initial horizontal position of square centre
    IY=240,         // initial vertical position of square centre
    D_WIDTH=640,    // width of display
    D_HEIGHT=480,   // height of display
    L_FACTOR=4,     // Factor of length of a piece of light
	 SPEED=2			  // Speed of light
    )
    // The above values are default parameters if none are supplied.
    (
    input wire i_clk,         // base clock
    input wire i_ani_stb,     // animation clock: pixel clock is 1 pix/frame
    input wire i_rst,         // reset: returns animation to starting position
    input wire i_paused,      // paused state: high when paused
    input wire i_animate,     // animate when input is high
    output wire [11:0] o_1x1,  // square left edge: 12-bit value: 0-4095. We use 12 bits so this module can be used on 4k as well.
    output wire [11:0] o_1x2,  // square right edge
    output wire [11:0] o_1y1,  // square top edge
    output wire [11:0] o_1y2,   // square bottom edge
    output wire [11:0] o_2x1,  // square left edge: 12-bit value: 0-4095. We use 12 bits so this module can be used on 4k as well.
    output wire [11:0] o_2x2,  // square right edge
    output wire [11:0] o_2y1,  // square top edge
    output wire [11:0] o_2y2   // square bottom edge
    );

    reg [11:0] x1 = IX;   // horizontal position of square centre
    reg [11:0] y1 = IY;   // vertical position of square centre
    reg [11:0] x2 = (IX < D_WIDTH/2) ? (D_WIDTH/2-IX) + D_WIDTH/2 : D_WIDTH/2 - (IX-D_WIDTH/2);   // horizontal position of square centre
    reg [11:0] y2 = IY;   // vertical position of square centre

    assign o_1x1 = x1 - H_SIZE;  // left: centre minus half horizontal size
    assign o_1x2 = x1 + H_SIZE;  // right
    assign o_1y1 = y1 - L_FACTOR*H_SIZE;  // top
    assign o_1y2 = y1 + L_FACTOR*H_SIZE;  // bottom

    assign o_2x1 = x2 - H_SIZE;  // left: centre minus half horizontal size
    assign o_2x2 = x2 + H_SIZE;  // right
    assign o_2y1 = y2 - L_FACTOR*H_SIZE;  // top
    assign o_2y2 = y2 + L_FACTOR*H_SIZE;  // bottom

    always @ (posedge i_clk)
    begin
        if (i_rst)  // on reset return to starting position
        begin
            x1 <= IX;
            y1 <= IY;
            x2 <= (IX < D_WIDTH/2) ? (D_WIDTH/2-IX) + D_WIDTH/2 : D_WIDTH/2 - (IX-D_WIDTH/2);
            y2 <= IY;
        end
        if (i_animate && i_ani_stb && ~i_paused)
        begin
            y1 <= y1 + SPEED*1'b1;  // move the light down to simulate lightspeed 
            y2 <= y2 + SPEED*1'b1;

            // Player Boundary control:
            if (x1 <= H_SIZE + 1'b1)  // edge of square is at left of screen
                x1 <= H_SIZE + 2'b10;
            if (x1 >= (D_WIDTH - H_SIZE - 1'b1))  // edge of square at right
                x1 <= D_WIDTH - H_SIZE - 2'b10;            
            if (y1 <= H_SIZE + 1'b1)  // edge of square at top of screen
                y1 <= H_SIZE + 2'b10;  
            if (y1 >= (D_HEIGHT - H_SIZE - 1'b1))  // edge of square at bottom
                y1 <= H_SIZE + 2'b10; // move to top of screen                

            if (x2 <= H_SIZE + 1'b1)  // edge of square is at left of screen
                x2 <= H_SIZE + 2'b10;
            if (x2 >= (D_WIDTH - H_SIZE - 1'b1))  // edge of square at right
                x2 <= D_WIDTH - H_SIZE - 2'b10;            
            if (y2 <= H_SIZE + 1'b1)  // edge of square at top of screen
                y2 <= H_SIZE + 2'b10;  
            if (y2 >= (D_HEIGHT - H_SIZE - 1'b1))  // edge of square at bottom
                y2 <= H_SIZE + 2'b10; // Move to top of screen               
        end
    end
endmodule
