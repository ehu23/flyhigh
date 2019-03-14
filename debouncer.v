module debouncer(
	input i_btn,
	input i_clk,
	output o_btn_state
    );
	 
reg btn_state_value = 0;
reg [23:0] counter;

always @ (posedge i_clk)
begin
	if(i_btn == 0) // when button is not pressed, reset values
	begin
		counter <= 0;
		btn_state_value <= 0;
	end
	
	else
	begin
		counter <= counter + 1'b1;
		if(counter == 24'hffffff) // if we count up to the max, we know its a good sample
		begin
			btn_state_value <= 1;
			counter <= 0;
		end
	end
end

assign o_btn_state = btn_state_value;

endmodule
