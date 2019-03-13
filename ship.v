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
    input wire i_paused,
    input wire i_animate,     // animate when input is high
    input wire [7:0] i_sw,      // movement switches
    output wire [11:0] o_x1,  // player left edge: 12-bit value: 0-4095. We use 12 bits so this module can be used on 4k as well.
    output wire [11:0] o_x2,  // player right edge
    output wire [11:0] o_y1,  // player top edge
    output wire [11:0] o_y2   // player bottom edge
    output wire [11:0] o_bx1, // bullet left edge 
    output wire [11:0] o_bx2, // bullet right edge
    output wire [11:0] o_by1, // bullet top edge
    output wire [11:0] o_by2, // bullet bottom edge
    output wire o_firing      // high when bullet is fired
    );

    reg [11:0] x = IX;   // horizontal position of player centre
    reg [11:0] y = IY;   // vertical position of player centre

    // For now, assigning bullet position to player initially
    reg [11:0] bx = IX;
    reg [11:0] by = IY;
    reg in_air = 0;

    assign o_x1 = x - H_SIZE;  // left: centre minus half horizontal size
    assign o_x2 = x + H_SIZE;  // right
    assign o_y1 = y - H_SIZE;  // top
    assign o_y2 = y + H_SIZE;  // bottom

    // For now, assign the bullet to be the same as the player size
    assign o_bx1 = bx - H_SIZE;
    assign o_bx2 = bx + H_SIZE;
    assign o_by1 = by - H_SIZE;
    assign o_by2 = by + H_SIZE;

    assign o_firing = in_air;

    always @ (posedge i_clk)
    begin
        if (i_rst)  // on reset return to starting position
        begin
            x <= IX;
            y <= IY;
            bx <= IX;
            by <= IY;
            in_air = 0;
        end
        if (i_animate && i_ani_stb && ~i_paused)
        begin
            // Player Movement
            if (i_sw[0]) // Right
                x <= x + 1'b1;
            if (i_sw[7]) // Left
                x <= x - 1'b1;
            if (i_sw[6]) // Up
                y <= y - 1'b1;
            if (i_sw[1]) // Down
                y <= y + 1'b1;


            // Bullet logic
            if (i_sw[4] & ~in_air) // If we press shoot and the bullet is not in the air
                in_air = 1;

            if (in_air) // If bullet is in the air
                by <= by - 1'b1; // Move bullet up

            // Player Boundary control:
            if (x <= H_SIZE + 1'b1)  // edge of square is at left of screen
                x <= H_SIZE + 2'b10);
            if (x >= (D_WIDTH - H_SIZE - 1'b1))  // edge of square at right
                x <= D_WIDTH - H_SIZE - 2'b10;            
            if (y <= H_SIZE + 1'b1)  // edge of square at top of screen
                y <= H_SIZE + 2'b10;  
            if (y >= (D_HEIGHT - H_SIZE - 1'b1))  // edge of square at bottom
                y <= D_HEIGHT - H_SIZE - 2'b10;                

            // Bullet Boundary Detection:
            if ((bx <= H_SIZE + 1'b1) || (bx >= (D_WIDTH - H_SIZE - 1'b1)) || (by <= H_SIZE + 1'b1) || (by >= (D_HEIGHT - H_SIZE - 1'b1)))
            begin
                in_air = 0;
                by <= y;
                bx <= x;
            end

        end
    end
endmodule
