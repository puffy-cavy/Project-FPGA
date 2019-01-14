module walk(	input logic frame_clk, walk_left, walk_right, jump, Reset, Clk, ground, jump_left, jump_right,
					output logic walk_left_1, walk_left_2, walk_right_1, walk_right_2, midjump_1, leftjump_1, leftjump_2, rightjump_1, rightjump_2, sleep_1,
					output logic [4:0] counter_out);
		  
enum logic [5:0] {stop, sleep1, sleep2, leftwalk1, leftwalk2, rightwalk1, rightwalk2, midjump, leftjump, rightjump, leftjump2, rightjump2, stop2} state, next_state;		
logic [4:0] counter;
logic [6:0] counter_long;
assign counter_out = counter; 

always_ff @(posedge Clk) begin
	if(Reset)
			begin
				state <= stop;
			end
	else
			state <= next_state;
end

always_ff @(posedge frame_clk) begin
	if(counter == 5'd10) 
		counter <= 5'd0;
	else 
		counter <= counter + 5'd1;
		
	if(counter_long == 7'd255)
		counter_long <= 7'd0;
	else 
		counter_long <= counter_long + 7'd1;
end
	
always_comb 
	begin
	next_state = state;
		case(state) 
		stop:
			if(walk_left)
			next_state = leftwalk1;
			else if(walk_right)
			next_state = rightwalk1;
			else if(jump && ~jump_left && ~jump_right)
			next_state = midjump;
			else if(jump_left)
			next_state = leftjump;
			else if(jump_right)
			next_state = rightjump;
			else if(counter_long == 7'd128 && ~walk_left && ~walk_right && ~jump_left && ~jump_right && ~jump)
			next_state = sleep1;
			else
			next_state = stop;
		sleep1:
			if(counter_long == 7'd250)
			next_state = sleep2;
			else
			next_state = sleep1;
		sleep2:
			if(walk_left || walk_right || jump_left || jump_right || jump)
			next_state = stop;
			else
			next_state = sleep2;
		leftwalk1:
			if(counter == 5'd5)
			next_state = leftwalk2;
			else
			next_state = leftwalk1;
		leftwalk2:
			if(counter == 5'd10)
			next_state = stop2;
			else
			next_state = leftwalk2;
		rightwalk1:
			if(counter == 5'd5)
			next_state = rightwalk2;
			else
			next_state = rightwalk1;
		rightwalk2:
			if(counter == 5'd10)
			next_state = stop2;
			else
			next_state = rightwalk2;
		midjump:
			if(ground)
			next_state = stop2;
			else
			next_state = midjump;	
		leftjump:
			if(ground)
			next_state = stop2;
			else if(walk_right)
			next_state = rightjump;
			else if(counter == 5'd5)
			next_state = leftjump2;
			else
			next_state = leftjump;
		leftjump2:
			if(ground)
			next_state = stop2;
			else if(walk_right)
			next_state = rightjump;
			else if(counter == 5'd10)
			next_state = leftjump;
			else
			next_state = leftjump2;
		rightjump:
			if(ground)
			next_state = stop2;
			else if(walk_left)
			next_state = leftjump;
			else if(counter == 5'd5)
			next_state = rightjump2;
			else
			next_state = rightjump;	
		rightjump2:
			if(ground)
			next_state = stop2;
			else if(walk_left)
			next_state = leftjump;
			else if(counter == 5'd10)
			next_state = rightjump;
			else
			next_state = rightjump2;
		stop2:
			next_state = stop;
		default : ;
		endcase
	end

always_comb 
	begin
	walk_left_1 = 1'b0;
	walk_left_2 = 1'b0;
	walk_right_1 = 1'b0;
	walk_right_2 = 1'b0;
	midjump_1 = 1'b0;
	rightjump_1 = 1'b0;
	leftjump_1 = 1'b0;
	rightjump_2 = 1'b0;
	leftjump_2 = 1'b0;
	sleep_1 = 1'b0;
	
		case(state) 
		
		stop: begin
				walk_left_1 = 1'b0;
				walk_left_2 = 1'b0;
				walk_right_1 = 1'b0;
				walk_right_2 = 1'b0;
				end

		stop2:begin
				walk_left_1 = 1'b0;
				walk_left_2 = 1'b0;
				walk_right_1 = 1'b0;
				walk_right_2 = 1'b0;
				end
				
		sleep2:begin
				sleep_1 = 1'b1;
				end

		leftwalk1:	begin
				walk_left_1 = 1'b1;
				walk_left_2 = 1'b0;
				walk_right_1 = 1'b0;
				walk_right_2 = 1'b0;
				end
				
		leftwalk2:	begin
				walk_left_1 = 1'b0;
				walk_left_2 = 1'b1;
				walk_right_1 = 1'b0;
				walk_right_2 = 1'b0;
				end
				
		rightwalk1:	begin
				walk_left_1 = 1'b0;
				walk_left_2 = 1'b0;
				walk_right_1 = 1'b1;
				walk_right_2 = 1'b0;
				end
				
		rightwalk2:	begin
				walk_left_1 = 1'b0;
				walk_left_2 = 1'b0;
				walk_right_1 = 1'b0;
				walk_right_2 = 1'b1;
				end
		midjump: begin
				midjump_1 = 1'b1;
				end
	   leftjump: begin
				leftjump_1 = 1'b1;
				end
		rightjump: begin
				rightjump_1 = 1'b1;
				end
		leftjump2: begin
				leftjump_2 = 1'b1;
				end
		rightjump2: begin
				rightjump_2 = 1'b1;
				end
		default : ;
		endcase
	end

endmodule 