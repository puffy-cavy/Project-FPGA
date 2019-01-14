module gravity(input  logic [9:0] Ball_Y_Pos,
					input  logic jump, Clk, Reset,
					output logic stop, 
					output logic [9:0] Ball_Y_Motion_in);
					
enum logic [2:0] {state0,state1, state2, state3} state, next_state;	
logic [9:0] next_Ball_Y_Motion;


always_ff @(posedge Clk or posedge Reset) begin
		if(Reset) 
			begin
			state <= state0;
			Ball_Y_Motion_in <= 10'd0;
			end	
		else 
			begin
			state <= next_state;
			Ball_Y_Motion_in <= next_Ball_Y_Motion;
			end
	end
							
always_comb 
	begin
	next_state = state;
		case(state) 
		state0:
			if(jump || Ball_Y_Pos < 10'd390)
				next_state = state1;
			else
				next_state = state0;
		state1:
			if(Ball_Y_Pos <= 10'd200) //highest point, go down
				next_state = state2;
			else 
				next_state = state1;   //keep going up
		state2:
			if(Ball_Y_Pos >= 10'd390) //touch the ground
				next_state = state3;
			else
				next_state = state2;   //keep going down
		state3:
				next_state = state0;
		endcase
	end

always_comb
	begin
	next_Ball_Y_Motion = Ball_Y_Motion_in;
	stop = 1'b0;
		case(state) 
		state0:
			begin
				next_Ball_Y_Motion = 10'd0;
				stop = 1'b0;
			end
		state1: 	
			begin
				next_Ball_Y_Motion = (~(10'd8) + 1'b1);
				stop = 1'b0;
			end
		state2:	
			begin
				next_Ball_Y_Motion = 10'd2;
				stop = 1'b0;
			end
		state3:	
			begin
				next_Ball_Y_Motion = 10'd0;
				stop = 1'b1;
			end
		endcase
	end
	
endmodule
