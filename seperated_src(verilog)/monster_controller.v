module monster_controller(
   input clk,
	 input rst,
	 input [9:0] h_cnt,
	 input [9:0] v_cnt,
	 input [1:0] state,
	 input [9:0] blt_x,blt_y,
	 input blt_exist,
	 input [3:0] adv,
	 input [8:0] rand_x2,
	 input [13:0]score,
	 output valid,
	 output reg mon_alive,
	 output reg [9:0] pos_x,
	 output reg [9:0] pos_y,
	 output reg [16:0] pixel_addr
);
     
    parameter map_width = 10'd640;
    parameter map_height = 10'd480;
    parameter spd_x = 4'd10;

    reg valid_all;
    reg [13:0] score_reg;
	reg dir;
	
	assign valid=valid_all& mon_alive;
	
	always@(*)begin
	      if(h_cnt>=pos_x&&h_cnt<pos_x+120)
		         if(v_cnt>=pos_y&& v_cnt<pos_y+67)begin
				             valid_all=1;
							 pixel_addr=(h_cnt-pos_x)+(v_cnt-pos_y)*120;
				 end
			     else   begin
				             valid_all=0;
							 pixel_addr=0;
				 end
		   else     begin
		                     valid_all=0;
							 pixel_addr=0; 
		   end
	end
	

always@(posedge clk)begin
      if(rst||(state!=2))begin
	           mon_alive<=0;
	           pos_x<=rand_x2;
			   pos_y<=0;
			   dir<=0;
			   score_reg<=0;
	  end
	  
	  else   begin
	          if(mon_alive)begin
			          if(dir==0) begin//right
					      if(pos_x+120<map_width-spd_x)begin
			                   pos_x<=pos_x+spd_x;
							   dir<=dir;
						 end
						 else begin
						       pos_x<=pos_x;
							   dir<=~dir;
					     end
					  end
				      else begin//left
					      if(pos_x>spd_x)begin
						       pos_x<=pos_x-spd_x;
							   dir<=dir;
						  end
					      else begin
						      pos_x<=pos_x;
							  dir<=~dir;
						  end
					  end  
					  pos_y<=pos_y+adv;
					  score_reg<=score;
					  
					  /*monster alive*/
					  if(pos_y>=map_height)begin
					                 mon_alive<=0;
					  end
					  else begin
					      if(blt_exist)begin
					  		if(blt_x>pos_x)begin
					         		if(blt_y>pos_y)begin
					                		mon_alive<=(blt_x-pos_x<115&&blt_y-pos_y<60)?0:1;
							 		end
							 		else begin
							        		mon_alive<=(blt_x-pos_x<115&&pos_y-blt_y<11)?0:1;
							 		end
					  		end
					  		else begin
					         		if(blt_y>pos_y)begin
					                		mon_alive<=(pos_x-blt_x<10&&blt_y-pos_y<60)?0:1;
							 		end
							 		else begin
							        		mon_alive<=(pos_x-blt_x<115&&pos_y-blt_y<11)?0:1;
							 		end  
					  		end
					  	   end
					  	   else begin
					  	        mon_alive<=1;
					  	   end
						end
			  end
			  
			  
			  else begin
			          pos_x<=rand_x2;
					  dir<=dir;
			          pos_y<=0;
					  mon_alive<=(score>score_reg+500)?1:0;
					  score_reg<=score_reg;
			  end
	  
	  end
 
end
	
endmodule
