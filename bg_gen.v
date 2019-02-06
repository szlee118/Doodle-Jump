module bg_gen(
   input clk,
   input rst,
   input [9:0] h_cnt,
   input [9:0] v_cnt,
   input [8:0]rand_x1,rand_x2,rand_x3,rand_x4,rand_x5,rand_x6,rand_x7,rand_x8,rand_x9,rand_x10,
   input [8:0]sh_y1,sh_y2,sh_y3,sh_y4,sh_y5,sh_y6,sh_y7,sh_y8,sh_y9,sh_y10,
   output reg [9:0] pixel_addr,
   output reg valid
   );

    
    always@(*)begin
        if     (v_cnt>=sh_y1 && v_cnt<sh_y1+15)// moving region 1
              if(h_cnt>rand_x1 && h_cnt<=rand_x1+58)begin
                   pixel_addr=(h_cnt-rand_x1)+(v_cnt-sh_y1)*58;
                   valid=1;
              end
              else begin
                   pixel_addr=0;
                   valid=0;
              end
        else if(v_cnt>=sh_y2 && v_cnt<sh_y2+15)//moving region 2    
              if(h_cnt>rand_x2 && h_cnt<=rand_x2+58)begin  
                   pixel_addr=(h_cnt-rand_x2)+(v_cnt-sh_y2)*58;
                   valid=1;
              end   
              else begin
                   pixel_addr=0;
                   valid=0;
              end
        else if(v_cnt>=sh_y3 && v_cnt<sh_y3+15)//moving region 3
              if(h_cnt>rand_x3  && h_cnt<=rand_x3+58)begin
                   pixel_addr=(h_cnt-rand_x3)+(v_cnt-sh_y3)*58;
                   valid=1;
              end
              else begin 
                   pixel_addr=0;
                   valid=0;
              end
        else if(v_cnt>=sh_y4 && v_cnt<sh_y4+15)//moving region 4
              if(h_cnt>rand_x4  && h_cnt<=rand_x4+58)begin
                   pixel_addr=(h_cnt-rand_x4)+(v_cnt-sh_y4)*58;
                   valid=1;  
              end
              else begin
                   pixel_addr=0;
                   valid=0;
              end
        else if(v_cnt>=sh_y5 && v_cnt<sh_y5+15)//moving region 5
              if(h_cnt>rand_x5  && h_cnt<=rand_x5+58)begin
                   pixel_addr=(h_cnt-rand_x5)+(v_cnt-sh_y5)*58;
                   valid=1;
              end
              else begin
                   pixel_addr=0;
                   valid=0;
              end
        else if(v_cnt>=sh_y6 && v_cnt<sh_y6+15)//moving region 6
              if(h_cnt>rand_x6   && h_cnt<=rand_x6+58)begin
                   pixel_addr=(h_cnt-rand_x6)+(v_cnt-sh_y6)*58;
                   valid=1;
              end
              else begin
                   pixel_addr=0;
                   valid=0;
              end
        else if(v_cnt>=sh_y7 && v_cnt<sh_y7+15)//moving region 7
              if(h_cnt>rand_x7   && h_cnt<=rand_x7+58)begin
                   pixel_addr=(h_cnt-rand_x7)+(v_cnt-sh_y7)*58;
                   valid=1;
              end
              else begin
                   pixel_addr=0;
                   valid=0;
              end
        else if(v_cnt>=sh_y8 && v_cnt<sh_y8+15)//moving region 8
              if(h_cnt>rand_x8   && h_cnt<=rand_x8+58)begin
                   pixel_addr=(h_cnt-rand_x8)+(v_cnt-sh_y8)*58;
                   valid=1;
              end
              else begin
                   pixel_addr=0;
                   valid=0;
              end
        else if(v_cnt>=sh_y9 && v_cnt<sh_y9+15)//moving region 9
              if(h_cnt>rand_x9   && h_cnt<=rand_x9+58)begin
                   pixel_addr=(h_cnt-rand_x9)+(v_cnt-sh_y9)*58;
                   valid=1;
              end
              else begin
                   pixel_addr=0;
                   valid=0;
              end
        else if(v_cnt>=sh_y10 && v_cnt<sh_y10+15)//moving region 10
              if(h_cnt>rand_x10&& h_cnt<=rand_x10+58)begin
                   pixel_addr=(h_cnt-rand_x10)+(v_cnt-sh_y10)*58;
                   valid=1;
              end
              else begin
                   pixel_addr=0;
                   valid=0;
              end
        else  begin
              pixel_addr = 0;
              valid = 0;
        end
    
    end

endmodule
