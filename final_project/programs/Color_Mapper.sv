//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( input              is_ball, is_diren,            // Whether current pixel belongs to ball 
							  input [4:0] kirby_action, diren_action,
							  input [7:0] data_Out,
                                                              //   or background (computed in ball.sv)
                       input        [9:0] DrawX, DrawY, Ball_X_Pos, Ball_Y_Pos, diren_X_Pos, diren_Y_Pos,      // Current pixel coordinates, Ball_X_Pos, Ball_Y_Pos are the center of the tile
							  output [19:0] SRAM_ADDR,
							  inout wire [15:0] SRAM_DQ,
                       output logic [7:0] VGA_R, VGA_G, VGA_B, // VGA RGB output
                       output logic [18:0] read_address
							);
							    
						   parameter [9:0] X_Max = 10'd639;     // Rightmost point on the X axis
						   parameter [9:0] Y_Max = 10'd479;     // Bottommost point on the Y axis
							parameter [9:0] y_ground = 10'd300;     // Rightmost point on the X axis

	 
	 logic [18:0] read_address_diren, read_address_kirby;
	 color_extract color_extract_module( .*);
	 color_extract_diren color_extract_diren_module(.*);
	 
	 logic [19:0] DrawY_SRAM, DrawX_SRAM;
	 assign DrawY_SRAM = {10'b0, DrawY};
	 assign DrawX_SRAM = {10'b0, DrawX};
	 assign SRAM_ADDR = (DrawY_SRAM * 20'd640) + DrawX_SRAM;
						
    
    logic [7:0] Red, Green, Blue;
	 logic [23:0] color [43];
	 assign color[ 0 ] = 24'h000000;
	assign color[ 1 ] = 24'hE0F8F8;
	assign color[ 2 ] = 24'hF8F8F8;
	assign color[ 3 ] = 24'h707078;
	assign color[ 4 ] = 24'h686868;
	assign color[ 5 ] = 24'h601010;
	assign color[ 6 ] = 24'hE07868;
	assign color[ 7 ] = 24'h883800;
	assign color[ 8 ] = 24'hC84800;
	assign color[ 9 ] = 24'hf84808;
	assign color[ 10 ] = 24'hD87000;
	assign color[ 11 ] = 24'hF0A878;
	assign color[ 12 ] = 24'h734C10;
	assign color[ 13 ] = 24'hF0B800;
	assign color[ 14 ] = 24'hF8C800;
	assign color[ 15 ] = 24'hF8D088;
	assign color[ 16 ] = 24'hF8F800;
	assign color[ 17 ] = 24'hF0F890;
	assign color[ 18 ] = 24'h287800;
	assign color[ 19 ] = 24'h389800;
	assign color[ 20 ] = 24'h68F800;
	assign color[ 21 ] = 24'h185808;
	assign color[ 22 ] = 24'hB8F8A8;
	assign color[ 23 ] = 24'h20B080;
	assign color[ 24 ] = 24'h007048;
	assign color[ 25 ] = 24'h009060;
	assign color[ 26 ] = 24'h50E0B0;
	assign color[ 27 ] = 24'hB8F8F8;
	assign color[ 28 ] = 24'h88E0F8;
	assign color[ 29 ] = 24'h2888E0;
	assign color[ 30 ] = 24'h60B8F0;
	assign color[ 31 ] = 24'h0048E0;
	assign color[ 32 ] = 24'hF868C8;
	assign color[ 33 ] = 24'hF8D0F0;
	assign color[ 34 ] = 24'hF898D8;
	assign color[ 35 ] = 24'hF8A8E0;
	assign color[ 36 ] = 24'hF82088;
	assign color[ 37 ] = 24'hFA90C0;
	assign color[ 38 ] = 24'h880020;
	assign color[ 39 ] = 24'hE05078;
	assign color[ 40 ] = 24'hB00028;
	assign color[ 41 ] = 24'hD80858;
	assign color[ 42 ] = 24'hF878A8;
	 
	 
    
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
    always_comb
	 begin
		if(is_diren)
			read_address = read_address_diren;
		else if(is_ball)
			read_address = read_address_kirby;
		else
			read_address = read_address_kirby;
	 end
    // Assign color based on is_ball signal
    always_comb
    begin
			if (is_diren == 1'b1 && color[data_Out] != 24'h734C10) //diren
				begin
					Red = color[data_Out][23:16];
					Green = color[data_Out][15:8];
					Blue = color[data_Out][7:0];
				end
			
          else  if (is_ball == 1'b1 && color[data_Out] != 24'h734C10) //draw_ball
				begin
					Red = color[data_Out][23:16];
					Green = color[data_Out][15:8];
					Blue = color[data_Out][7:0];
				end
        else if  (DrawY >= y_ground) //draw ground
		  begin
				Red = 8'h00; 
            Green = 8'hc7;
            Blue = 8'h1b;
		  end
		  else
        begin
            // Background with nice color gradient
            Red = {SRAM_DQ[14:10], 3'b1}; 
            Green = {SRAM_DQ[9:5], 3'b1};
            Blue = {SRAM_DQ[4:0], 3'b1};
        end
    end 
    
endmodule



module color_extract (input [9:0] DrawX, DrawY, Ball_X_Pos, Ball_Y_Pos,
							 input [4:0] kirby_action,
                      output [18:0] read_address_kirby
);
	
	
	logic [18:0]draw_x_pos;
	logic [18:0]draw_y_pos;
	logic [18:0]ball_x_pos;
	logic [18:0]ball_y_pos;
	
	assign draw_x_pos = {9'b0, DrawX};
	assign draw_y_pos = {9'b0, DrawY};
	assign ball_x_pos = {9'b0, Ball_X_Pos};
	assign ball_y_pos = {9'b0, Ball_Y_Pos};
	

	always_comb
	   begin
				unique case(kirby_action)
					5'b00001:  // left walk
						begin
							read_address_kirby = ((19'd15 - (ball_y_pos - draw_y_pos)) << 8)  + (19'd79 - (ball_x_pos - draw_x_pos));					
						end
					5'b00010:  // left walk 2
 						begin
							read_address_kirby = ((19'd15 - (ball_y_pos - draw_y_pos)) << 8)  + (19'd111 - (ball_x_pos - draw_x_pos));					
						end
					5'b00011:  // right walk 
						begin
							read_address_kirby = ((19'd15 - (ball_y_pos - draw_y_pos)) << 8)  + (19'd143 - (ball_x_pos - draw_x_pos));
						end
					5'b00100:  // right walk 2
						begin
							read_address_kirby = ((19'd15 - (ball_y_pos - draw_y_pos)) << 8)  + (19'd175 - (ball_x_pos - draw_x_pos));
						end
					5'b00101:  // left jump 
						begin
							read_address_kirby = ((19'd47 - (ball_y_pos - draw_y_pos)) << 8)  + (19'd15 - (ball_x_pos - draw_x_pos));
						end
					5'b00110:  // right jump 
						begin
							read_address_kirby = ((19'd47 - (ball_y_pos - draw_y_pos)) << 8)  + (19'd45 - (ball_x_pos - draw_x_pos));
						end
					5'b00111:  // mid jump 
						begin
							read_address_kirby = ((19'd47 - (ball_y_pos - draw_y_pos)) << 8)  + (19'd79 - (ball_x_pos - draw_x_pos));
						end
					5'b01000:  // sleep
						begin
							read_address_kirby = ((19'd15 - (ball_y_pos - draw_y_pos)) << 8)  + (19'd45 - (ball_x_pos - draw_x_pos));
						end
					5'b01001:  // suck left
						begin
							read_address_kirby = ((19'd15 - (ball_y_pos - draw_y_pos)) << 8)  + (19'd207 - (ball_x_pos - draw_x_pos));
						end
					5'b01010:  // suck right
						begin
							read_address_kirby = ((19'd15 - (ball_y_pos - draw_y_pos)) << 8)  + (19'd239 - (ball_x_pos - draw_x_pos));
						end
					default: //stop
						begin
							read_address_kirby = ((19'd15 - (ball_y_pos - draw_y_pos)) << 8)  + (19'd15 - (ball_x_pos - draw_x_pos));
						end
				endcase
        end
		  	
endmodule

module color_extract_diren (input [9:0] DrawX, DrawY, diren_X_Pos, diren_Y_Pos,
							 input [4:0] diren_action,
                      output [18:0] read_address_diren
);
	
	
	logic [18:0]draw_x_pos;
	logic [18:0]draw_y_pos;
	logic [18:0]diren_x_pos;
	logic [18:0]diren_y_pos;
	
	assign draw_x_pos = {9'b0, DrawX};
	assign draw_y_pos = {9'b0, DrawY};
	assign diren_x_pos = {9'b0, diren_X_Pos};
	assign diren_y_pos = {9'b0, diren_Y_Pos};
	

	always_comb
	   begin
				unique case(diren_action)
					5'b00001:  // left walk
						begin
							read_address_diren = ((19'd47 - (diren_y_pos - draw_y_pos)) << 8)  + (19'd111 - (diren_x_pos - draw_x_pos));					
						end
					5'b00010:  // left walk 2
 						begin
							read_address_diren = ((19'd47 - (diren_y_pos - draw_y_pos)) << 8)  + (19'd143 - (diren_x_pos - draw_x_pos));					
						end
					5'b00011:  // right walk 
						begin
							read_address_diren = ((19'd47 - (diren_y_pos - draw_y_pos)) << 8)  + (19'd175 - (diren_x_pos - draw_x_pos));
						end
					5'b00100:  // right walk 2
						begin
							read_address_diren = ((19'd47 - (diren_y_pos - draw_y_pos)) << 8)  + (19'd207 - (diren_x_pos - draw_x_pos));
						end
					default: //stop
						begin
							read_address_diren = ((19'd47 - (diren_y_pos - draw_y_pos)) << 8)  + (19'd111 - (diren_x_pos - draw_x_pos));	
						end
				endcase
        end
		  	
endmodule
	
	
	
	
	
	
