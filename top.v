module top(
    input wire CLK,             // board clock: 100 MHz on Arty/Basys3/Nexys
    input wire RST_BTN,         // reset button
    input wire PAUSE_BTN,       // pause button
    input wire [7:0] sw,        // 4 movement controls
    output wire VGA_HS_O,       // horizontal sync output
    output wire VGA_VS_O,       // vertical sync output
    output wire [2:0] VGA_R,    // 3-bit VGA red output
    output wire [2:0] VGA_G,    // 3-bit VGA green output
    output wire [1:0] VGA_B     // 2-bit VGA blue output
    );

    wire rst;
    wire pause;
	 
    // generate a 25 MHz pixel strobe. So a clock that is four times slower.
    reg [15:0] cnt = 0;
    reg pix_stb = 0;
	 
	 
    always @(posedge CLK)
    begin
        {pix_stb, cnt} <= cnt + 16'h4000;  // divide by 4: (2^16)/4 = 0x4000. pix_stb AND cnt are assigned.
    end
	 
	 
    wire [9:0] x;  // current (visible) pixel x position: 10-bit value: 0-1023. We go up to 640.
    wire [8:0] y;  // current (visible) pixel y position:  9-bit value: 0-511. We go up to 480.
    wire animate;  // high when we're ready to animate at end of drawing
    wire paused; // high when paused
	 
	 debouncer reset_button(
			.i_btn(RST_BTN),
			.i_clk(CLK),
			.o_btn_state(rst)
			);
	
	 debouncer pause_button(
			.i_btn(PAUSE_BTN),
			.i_clk(CLK),
			.o_btn_state(pause)
			);
			
			
			
	 // Controllable player ship 
    wire player_ship;
    wire [11:0] player_x1, player_x2, player_y1, player_y2;  // 12-bit values: 0-4095

    // Player's bullet 
    wire player_bullet; 
    wire firing;
    wire [11:0] bullet_x1, bullet_x2, bullet_y1, bullet_y2; 

    // Light streaks
    wire light;
    wire [11:0] light1_x1, light1_x2, light1_y1, light1_y2;  
    wire [11:0] light2_x1, light2_x2, light2_y1, light2_y2;  
	 wire [11:0] light3_x1, light3_x2, light3_y1, light3_y2;  
    wire [11:0] light4_x1, light4_x2, light4_y1, light4_y2; 
	 wire [11:0] light5_x1, light5_x2, light5_y1, light5_y2;  
    wire [11:0] light6_x1, light6_x2, light6_y1, light6_y2;
	 
	 
    vga640x480 display (
        .i_clk(CLK),
        .i_pix_stb(pix_stb),
        .i_rst(rst),
		  .i_pause(pause),
        .o_hs(VGA_HS_O), 
        .o_vs(VGA_VS_O), 
        .o_x(x), 
        .o_y(y),
        .o_animate(animate),
		  .o_paused(paused)
    );


    ship #(.H_SIZE(20)) player (
        .i_clk(CLK),
        .i_ani_stb(pix_stb),
        .i_rst(rst),
        .i_paused(paused),
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

    lightspeed #(.H_SIZE(3), .IX(30), .L_FACTOR(15), .SPEED(9)) light1 (
        .i_clk(CLK),
        .i_ani_stb(pix_stb),
        .i_rst(rst),
        .i_paused(paused),
        .i_animate(animate),
        .o_1x1(light1_x1),
        .o_1x2(light1_x2),
        .o_1y1(light1_y1),
        .o_1y2(light1_y2),
        .o_2x1(light2_x1),
        .o_2x2(light2_x2),
        .o_2y1(light2_y1),
        .o_2y2(light2_y2)
    );
	 
	 lightspeed #(.H_SIZE(4), .IX(40), .L_FACTOR(8), .SPEED(7)) light2 (
        .i_clk(CLK),
        .i_ani_stb(pix_stb),
        .i_rst(rst),
        .i_paused(paused),
        .i_animate(animate),
        .o_1x1(light3_x1),
        .o_1x2(light3_x2),
        .o_1y1(light3_y1),
        .o_1y2(light3_y2),
        .o_2x1(light4_x1),
        .o_2x2(light4_x2),
        .o_2y1(light4_y1),
        .o_2y2(light4_y2)
    );
	 
	 lightspeed #(.H_SIZE(3), .IX(50), .L_FACTOR(11), .SPEED(8)) light3 (
        .i_clk(CLK),
        .i_ani_stb(pix_stb),
        .i_rst(rst),
        .i_paused(paused),
        .i_animate(animate),
        .o_1x1(light5_x1),
        .o_1x2(light5_x2),
        .o_1y1(light5_y1),
        .o_1y2(light5_y2),
        .o_2x1(light6_x1),
        .o_2x2(light6_x2),
        .o_2y1(light6_y1),
        .o_2y2(light6_y2)
    );
	 

    assign player_ship = ((x > player_x1) & (y > player_y1) & (x < player_x2) & (y < player_y2)) ? 1'b1 : 1'b0;

    // Color in the bullet as long as its firing/intheair
    assign player_bullet = ((x > bullet_x1) & (y > bullet_y1) & (x < bullet_x2) & (y < bullet_y2) & (firing)) ? 1'b1 : 1'b0;

    assign light = (((x > light1_x1) & (y > light1_y1) & (x < light1_x2) & (y < light1_y2)) || 
						  ((x > light2_x1) & (y > light2_y1) & (x < light2_x2) & (y < light2_y2)) || 
						  ((x > light3_x1) & (y > light3_y1) & (x < light3_x2) & (y < light3_y2)) || 
						  ((x > light4_x1) & (y > light4_y1) & (x < light4_x2) & (y < light4_y2)) ||
						  ((x > light5_x1) & (y > light5_y1) & (x < light5_x2) & (y < light5_y2)) || 
						  ((x > light6_x1) & (y > light6_y1) & (x < light6_x2) & (y < light6_y2))
						  ) ? 1'b1 : 1'b0;
 
    // Designate colors:
    assign VGA_R[2] = player_ship | light;  // player_ship is red
    assign VGA_G[2] = player_bullet | light;// player_bullet is green  
    assign VGA_B[1] = player_ship | light; // light is white (so present in all colors)

    // Must fill in rest of bits in array for VGA. Default set to zero.
    assign VGA_R[0] = player_ship | light;
    assign VGA_R[1] = player_ship | light;
	 
    assign VGA_G[0] = player_bullet | light;
    assign VGA_G[1] = player_bullet | light;
	 
    assign VGA_B[0] = player_ship | light;
    
endmodule
