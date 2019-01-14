//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  12-08-2017                               --
//    Spring 2018 Distribution                                           --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  diren ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
               output logic  is_diren,             // Whether current pixel belongs to ball or background
					output logic[4:0]  diren_action,
					output logic[9:0]  diren_X_Pos, diren_Y_Pos
              );
    
    parameter [9:0] Ball_X_Center = 10'd500;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center = 10'd390;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min = 10'd400;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max = 10'd600;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min = 10'd0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max = 10'd400;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step = 10'd1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step = 10'd1;      // Step size on the Y axis
    parameter [9:0] Ball_Size = 10'd12;        // Ball size
	 parameter [9:0] kirby_size = 10'd15;			 // kirby diameter 36

	 walk_diren walk_diren0(.*);
	 
    logic [9:0] Ball_X_Motion, Ball_Y_Motion;
    logic [9:0] Ball_X_Pos, Ball_Y_Pos, Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
	 logic left, right;
    
	 assign diren_X_Pos = Ball_X_Pos;
	 assign diren_Y_Pos = Ball_Y_Pos;

    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
	 
    // Update registers
    always_ff @ (posedge Clk)
    begin
        if (Reset)
        begin
            Ball_X_Pos <= Ball_X_Center;
            Ball_Y_Pos <= Ball_Y_Center;
            Ball_Y_Motion <= 10'd0;
            Ball_X_Motion <= Ball_X_Step;
        end
        else
        begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
            Ball_X_Motion <= Ball_X_Motion_in;
            Ball_Y_Motion <= Ball_Y_Motion_in;
        end
    end
    //////// Do not modify the always_ff blocks. ////////
    
    // You need to modify always_comb block.
    always_comb
    begin
        // By default, keep motion and position unchanged
        Ball_X_Pos_in = Ball_X_Pos;
        Ball_Y_Pos_in = Ball_Y_Pos;
        Ball_X_Motion_in = Ball_X_Motion;
		  left = 1'b0;
		  right = 1'b0;
        //Ball_Y_Motion_in = Ball_Y_Motion;
        
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
            // Be careful when using comparators with "logic" datatype because compiler treats 
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min 
            // If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
            
            // TODO: Add other boundary detections and handle keypress here.
				
				if( Ball_X_Pos + Ball_Size >= Ball_X_Max )  // Ball is at the right edge, BOUNCE!
					 begin
							Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);  // 2's complement.  
							right = 1'b1;
					 end
            else if ( Ball_X_Pos <= Ball_X_Min + Ball_Size )  // Ball is at the left edge, BOUNCE!
					 begin
							Ball_X_Motion_in = Ball_X_Step;
							left = 1'b1;
					 end
        	     
            // Update the ball's position with its motion
            Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
            Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
        end
    end
    
    // Compute whether the pixel corresponds to ball or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
    int DistX, DistY, Size;
    assign DistX = DrawX - Ball_X_Pos;
    assign DistY = DrawY - Ball_Y_Pos;
    assign Size = kirby_size;
    always_comb begin
        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) ) 
            is_diren = 1'b1;
        else
            is_diren = 1'b0;
    end
    
endmodule

module walk_diren(	input logic frame_clk, Reset, Clk, left, right,
					output logic [4:0] diren_action);
		  
enum logic [5:0] {leftwalk1, leftwalk2, rightwalk1, rightwalk2} state, next_state;		
logic [5:0] counter;

always_ff @(posedge Clk) begin
	if(Reset)
			begin
				state <= leftwalk1;
			end
	else
			state <= next_state;
end

always_ff @(posedge frame_clk) begin
	if(counter == 5'd20) 
		counter <= 5'd0;
	else 
		counter <= counter + 5'd1;
end
	
always_comb 
	begin
	next_state = state;
		case(state) 
		leftwalk1:
			if(counter == 5'd10)
			next_state = leftwalk2;
			else if(left)
			next_state = rightwalk1;
			else
			next_state = leftwalk1;
		leftwalk2:
			if(counter == 5'd20)
			next_state = leftwalk1;
			else if(left)
			next_state = rightwalk1;
			else
			next_state = leftwalk2;
		rightwalk1:
			if(counter == 5'd10)
			next_state = rightwalk2;
			else if(right)
			next_state = leftwalk1;
			else
			next_state = rightwalk1;
		rightwalk2:
			if(counter == 5'd20)
			next_state = rightwalk1;
			else if(right)
			next_state = leftwalk1;
			else
			next_state = rightwalk2;
		default : ;
		endcase
	end

always_comb 
	begin
		case(state) 
		leftwalk1:	begin
					diren_action = 5'b00001;
				end
				
		leftwalk2:	begin
					diren_action = 5'b00010;
				end
				
		rightwalk1:	begin
					diren_action = 5'b00011;
				end
				
		rightwalk2:	begin
					diren_action = 5'b00100;
				end
		default : ;
		endcase
	end

endmodule 
