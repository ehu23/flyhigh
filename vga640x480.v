module vga640x480(
    input wire i_clk,           // base clock
    input wire i_pix_stb,       // pixel clock strobe
    input wire i_rst,           // reset: restarts frame
	 input wire i_pause,			  // pause: the button itself
    output wire o_hs,           // horizontal sync
    output wire o_vs,           // vertical sync
    output wire o_blanking,     // high during blanking interval
    output wire o_active,       // high during active pixel drawing
    output wire o_screenend,    // high for one tick at the end of screen
    output wire o_animate,      // high for one tick at end of active drawing
	 output wire o_paused,		  // high when in a pause state
    output wire [9:0] o_x,      // current (visible) pixel x position
    output wire [8:0] o_y       // current (visible) pixel y position
    );
    // o_x and o_y are used for positioning and drawing graphics

    localparam HS_STA = 16;              // horizontal sync start
    localparam HS_END = 16 + 96;         // horizontal sync end
    localparam HA_STA = 16 + 96 + 48;    // horizontal active pixel start
    localparam VS_STA = 480 + 10;        // vertical sync start
    localparam VS_END = 480 + 10 + 2;    // vertical sync end
    localparam VA_END = 480;             // vertical active pixel end
    localparam LINE   = 800;             // complete line (pixels). From left to right.
    localparam SCREEN = 525;             // complete screen (lines). From top to bottom

    // h/v count represent # of screens and lines that have occurred since the
    // start, including the blanking interval. Used for sync signals.
    reg [9:0] h_count;  // line position. 640 active pixels and 160 for front/back porch and sync pulse. Total: 800.
    reg [9:0] v_count;  // screen position. 480 active pixels and 45 for front/back porch and sync pulse. Total: 525.
	 reg paused = 0;
	 
    // generate sync signals (active low for 640x480, so '0' during the sync)
    assign o_hs = ~((h_count >= HS_STA) & (h_count < HS_END));
    assign o_vs = ~((v_count >= VS_STA) & (v_count < VS_END));

    // keep x and y bound within the active pixels
    assign o_x = (h_count < HA_STA) ? 1'b0 : (h_count - HA_STA);
    assign o_y = (v_count >= VA_END) ? (VA_END - 1'b1) : (v_count);

    // blanking: high within the blanking period
    assign o_blanking = ((h_count < HA_STA) | (v_count > VA_END - 1'b1));

    // active: high during active pixel drawing
    assign o_active = ~((h_count < HA_STA) | (v_count > VA_END - 1'b1)); 

    // screenend: high for one tick at the end of the screen
    assign o_screenend = ((v_count == SCREEN - 1'b1) & (h_count == LINE));

    // animate: high for one tick at the end of the final active pixel line.
    // So bottom right corner of visible pixel box.
    // We want to animate after this frame is done drawing but before it resets to
    // start a new frame, this is during the back porch.
    assign o_animate = ((v_count == VA_END - 1'b1) & (h_count == LINE));

	 assign o_paused = paused;
	 
    always @ (posedge i_clk)
    begin
        if (i_rst)  // reset to start of frame
        begin
            h_count <= 1'b0;
            v_count <= 1'b0;
				paused <= 0;
        end
		  
		  if (i_pause) // pause is pressed
		  begin
				paused <= ~paused;
		  end

        if (i_pix_stb)  // once per pixel
        begin
            if (h_count == LINE)  // end of line
            begin
                h_count <= 1'b0;
                v_count <= v_count + 1'b1;
            end
            else 
                h_count <= h_count + 1'b1;

            if (v_count == SCREEN)  // end of screen
                v_count <= 1'b0;
        end
		  

    end
endmodule
