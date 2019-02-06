module static_addr_gen(
    input [9:0] width,
    input [9:0] height,
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    input [9:0] start_x,
    input [9:0] start_y,
    output reg [16:0] pixel_addr,
    output reg valid
);
  always@(*)begin
      if(v_cnt>=start_y && v_cnt<start_y+height)begin
         if(h_cnt>start_x && h_cnt<=start_x+width)begin
            pixel_addr=(h_cnt-start_x)+(v_cnt-start_y)*width;
            valid=1;
         end
         else begin
             pixel_addr=0;
             valid=0;
         end
      end
      else begin
         pixel_addr=0;
         valid=0;
      end
  end
   
endmodule
