module top(
    input wire CLK,             // board clock: 100 MHz on Arty/Basys3/Nexys
    input wire RST_BTN,         // reset button
    input wire [7:0] sw,        // 4 movement controls
    output wire VGA_HS_O,       // horizontal sync output
    output wire VGA_VS_O,       // vertical sync output
    output wire [2:0] VGA_R,    // 3-bit VGA red output
    output wire [2:0] VGA_G,    // 3-bit VGA green output
    output wire [1:0] VGA_B     // 2-bit VGA blue output
    );

    wire rst = RST_BTN;  // reset is active high on Basys3 (BTNC) and Nexys 3

    // generate a 25 MHz pixel strobe. So a clock that is four times slower.
    reg [15:0] cnt = 0;
    reg pix_stb = 0;
    always @(posedge CLK)
        {pix_stb, cnt} <= cnt + 16'h4000;  // divide by 4: (2^16)/4 = 0x4000. pix_stb AND cnt are assigned.

    wire [9:0] x;  // current (visible) pixel x position: 10-bit value: 0-1023. We go up to 640.
    wire [8:0] y;  // current (visible) pixel y position:  9-bit value: 0-511. We go up to 480.
    wire animate;  // high when we're ready to animate at end of drawing
    
    vga640x480 display (
        .i_clk(CLK),
        .i_pix_stb(pix_stb),
        .i_rst(rst),
        .o_hs(VGA_HS_O), 
        .o_vs(VGA_VS_O), 
        .o_x(x), 
        .o_y(y),
        .o_animate(animate)
    );

    // Controllable player ship 
    wire player_ship;
    wire [11:0] player_x1, player_x2, player_y1, player_y2;  // 12-bit values: 0-4095

    // Player's bullet 
    wire player_bullet; 
    wire firing;
    wire [11:0] bullet_x1, bullet_x2, bullet_y1, bullet_y2;  // 12-bit values: 0-4095

    ship #(.H_SIZE(20)) player (
        .i_clk(CLK),
        .i_ani_stb(pix_stb),
        .i_rst(rst),
        .i_animate(animate),
        .i_sw(sw),
        .o_x1(player_x1),
        .o_x2(player_x2),
        .o_y1(player_y1),
        .o_y2(player_y2),
        .o_bx1(bullet_x1),
        .o_bx2(bullet_x2),
        .o_by1(bullet_y1),
        .o_by2(bullet_y2),
        .o_firing(firing)
    );

    assign player_ship = ((x > player_x1) & (y > player_y1) &
        (x < player_x2) & (y < player_y2)) ? 1'b1 : 1'b0;

    // Color in the bullet as long as its firing/intheair
    assign player_bullet = ((x > bullet_x1) & (y > bullet_y1) &
        (x < bullet_x2) & (y < bullet_y2) & (firing)) ? 1'b1 : 1'b0;
 
    // Designate colors:
    assign VGA_R[2] = player_ship;  // player_ship is red
    assign VGA_G[2] = player_bullet;// player_bullet is green  
    assign VGA_B[1] = 1'b0; 

    // Must fill in rest of bits in array for VGA. Default set to zero.
    assign VGA_R[0] = 1'b0;
    assign VGA_R[1] = 1'b0;
    assign VGA_G[0] = 1'b0;
    assign VGA_G[1] = 1'b0;
    assign VGA_B[0] = 1'b0;
    
endmodule
