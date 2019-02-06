`define So_l 32'd196 //bB_freq
`define Do   32'd262 //C_freq
`define Mi   32'd330 //D_freq
`define La   32'd440 //bE_freq
`define So   32'd392 //F_freq
`define Fa   32'd349 //G_freq
`define Re   32'd294 //A_freq
`define La_l 32'd220
`define Si   32'd494
`define Si_l 32'd247
`define Fa_s 32'd370


`define silence 32'd20000 //slience (over freq.)

module top(
   input clk,
   input rst,
   input sw,
   output reg [3:0] vgaRed,
   output reg [3:0] vgaGreen,
   output reg [3:0] vgaBlue,
   output wire[6:0] seg,
   output wire[3:0] an,
   output hsync,
   output vsync,
   output pmod_1,
   output pmod_2,
   output pmod_4,
   output reg[15:0] LED,
   inout wire PS2Data,
   inout wire PS2Clk
);
 
 
  
   reg [3:0] LED_cnt;
   reg [1:0]LED_state;
   
   
   wire clk_25MHz, clk23, clk27,clk22;
   wire valid;
   wire [9:0] h_cnt; 
   wire [9:0] v_cnt;  
   
   wire [8:0] rand_x1,rand_x2,rand_x3,rand_x4,rand_x5,rand_x6,rand_x7,rand_x8,rand_x9,rand_x10; //left top of platform, x coordinate
   wire [8:0] sh_y1,sh_y2,sh_y3,sh_y4,sh_y5,sh_y6,sh_y7,sh_y8,sh_y9,sh_y10;//left top of platform, y coordinate
   wire [9:0] floor;
   
   wire [9:0] bg_addr;
   wire [6:0] blt_addr;
   wire [11:0] plyr_addr;
   wire [12:0] mon_addr;
   wire [14:0] text_doodle_addr;
   wire [15:0] text_win_addr;
   wire [15:0] text_lose_addr;
   wire [10:0] text_enter_addr;
   wire [11:0] doodle_left_addr,doodle_right_addr,doodle_up_addr;
   wire [9:0]  plt_left_addr,plt_right_addr;
   wire [12:0] monster_mid_addr;
   
   wire [11:0] pixel_bg, pixel_plyr,pixel_text_doodle,pixel_blt, pixel_mon,pixel_enter,pixel_win,pixel_lose;
   wire [11:0] pixel_dleft,pixel_dright,pixel_dup,pixel_pltleft,pixel_pltright,pixel_midmon;
   
   wire [11:0] data_bg, data_plyr, data_text_doodle,data_text_enter,data_text_win,data_text_lose, data_blt, data_mon,
               data_dleft,data_dright,data_dup,data_midmon,data_pltleft,data_pltright;
   
   wire dleft_vld,dright_vld,dup_vld;//start page doodle
   wire pltleft_vld,pltright_vld;//startpage plt
   wire midmon_vld;
   wire doodle_vld,enter_vld,win_vld,lose_vld;
   
   wire [9:0]plyr_x,plyr_y;
   wire [9:0]blt_x,blt_y;
   wire [9:0]mon_x,mon_y;
   wire plyr_dir,plyr_fly;
   wire bg_vld, plyr_vld, blt_vld, mon_vld;
   
   
   wire [3:0]advance;
   wire hit;
   wire [2:0]blt_dir;
   wire exist_blt;
   wire mon_alive;
   wire [3:0] spd_x, spd_y;
   
   wire [511:0]key_down;
   wire [8:0]last_change;
   wire key_valid;
   
   wire[31:0] freq;
   wire[8:0] ibeatNum;
   wire beatFreq;
   
   parameter START=0,RUN0=1,RUN1=2,END=3;
   reg [1:0] state=START,next_state;
   reg [13:0] score;
   reg [15:0] nums;
   
   /*state control*/
   always@(posedge clk)begin
       if(rst)state<=START;
       else state<=next_state;
   end
   
   always@(*)begin
       case(state)
           START:next_state=(last_change==8'b0101_1010&&key_valid)?RUN0:START;
           RUN0:next_state=(last_change==8'b0010_1001&&key_valid)?RUN1:RUN0;
           RUN1:next_state=(score>=9999||plyr_y>=479||(mon_y-plyr_y<67&&mon_x-plyr_x<60)||
                                                      (mon_y-plyr_y<67&&plyr_x-mon_x<120)||
                                                      (plyr_y-mon_y<67&&mon_x-plyr_x<60)||
                                                      (plyr_y-mon_y<67&&plyr_x-mon_x<120))?END:RUN1;
           END:next_state=(last_change==8'b0111_0110&&key_valid)?START:END;
           default:next_state=state;
       endcase
   end
   
   /*score control*/
   
   always@(posedge clk23)begin
     if(rst||(state!=RUN1&&state!=END))
        score<=0;
     else
        score<=(score>=9999)?9999:score+(3*advance);
   end
   
   /*seven_segment control*/
   always@(*)begin
        if     (score<=9999&&score>=9000) nums[15:12]=4'b1001;
        else if(score<=8999&&score>=8000)nums[15:12]=4'b1000;
        else if(score<=7999&&score>=7000)nums[15:12]=4'b0111;
        else if(score<=6999&&score>=6000)nums[15:12]=4'b0110;
        else if(score<=5999&&score>=5000)nums[15:12]=4'b0101;
        else if(score<=4999&&score>=4000)nums[15:12]=4'b0100;
        else if(score<=3999&&score>=3000)nums[15:12]=4'b0011;
        else if(score<=2999&&score>=2000)nums[15:12]=4'b0010;
        else if(score<=1999&&score>=1000)nums[15:12]=4'b0001;
        else if(score<=999&&score>=0)nums[15:12]=4'b0000;
        else nums[15:12]=4'b0000;
        
        if((score%1000)>=0&&(score%1000)<=99)nums[11:8]=4'b0000;
        else if((score%1000)>=100&&(score%1000)<=199)nums[11:8]=4'b0001;
        else if((score%1000)>=200&&(score%1000)<=299)nums[11:8]=4'b0010;
        else if((score%1000)>=300&&(score%1000)<=399)nums[11:8]=4'b0011;
        else if((score%1000)>=400&&(score%1000)<=499) nums[11:8]=4'b0100;
        else if((score%1000)>=500&&(score%1000)<=599)nums[11:8]=4'b0101;
        else if((score%1000)>=600&&(score%1000)<=699)nums[11:8]=4'b0110;
        else if((score%1000)>=700&&(score%1000)<=799)nums[11:8]=4'b0111;
        else if((score%1000)>=800&&(score%1000)<=899)nums[11:8]=4'b1000;
        else if((score%1000)>=900&&(score%1000)<=999)nums[11:8]=4'b1001;
        else nums[11:8]=4'b0000;
        
         if((score%100)>=0&&(score%1000)<=9)nums[7:4]=4'b0000;
         else if((score%100)>=10&&(score%100)<=19)nums[7:4]=4'b0001;
         else if((score%100)>=20&&(score%100)<=29)nums[7:4]=4'b0010;
         else if((score%100)>=30&&(score%100)<=39)nums[7:4]=4'b0011;
         else if((score%100)>=40&&(score%100)<=49)nums[7:4]=4'b0100;
         else if((score%100)>=50&&(score%100)<=59)nums[7:4]=4'b0101;
         else if((score%100)>=60&&(score%100)<=69)nums[7:4]=4'b0110;
         else if((score%100)>=70&&(score%100)<=79)nums[7:4]=4'b0111;
         else if((score%100)>=80&&(score%100)<=89)nums[7:4]=4'b1000;
         else if((score%100)>=90&&(score%100)<=99)nums[7:4]=4'b1001;
         else nums[7:4]=4'b0000;
         
         if((score%10)==0)nums[3:0]=4'b0000;
         else if((score%10)==1)nums[3:0]=4'b0001;
         else if((score%10)==2)nums[3:0]=4'b0010;
         else if((score%10)==3)nums[3:0]=4'b0011;
         else if((score%10)==4)nums[3:0]=4'b0100;
         else if((score%10)==5)nums[3:0]=4'b0101;
         else if((score%10)==6)nums[3:0]=4'b0110;
         else if((score%10)==7)nums[3:0]=4'b0111;
         else if((score%10)==8)nums[3:0]=4'b1000;
         else if((score%10)==9)nums[3:0]=4'b1001;
         else nums[3:0]=4'b0000;
   end
   
   /* LED control*/   
      always@(posedge clk23) begin
          if (rst) begin
              LED_state <= 2'd3;
              LED_cnt <= 4'd0;
              LED <= 16'h0000;
          end else begin
              if (state==END && score>=9999) begin
                  case (LED_state)
                  2'd0: begin
                      if (LED_cnt == 0) begin
                          LED_state <= 2'd1;
                          LED_cnt <= 4'd15;
                          LED <= 16'b1111_1111_1111_1110;
                      end else begin
                          LED_state <= LED_state;
                          LED_cnt <= LED_cnt - 4'd1;
                          LED <= {1'b1, LED[15:1]};
                      end
                  end
                  2'd1: begin
                      if (LED_cnt == 4'd0) begin
                          LED_state <= 2'd2;
                          LED_cnt <= 4'd15;
                          LED <= 16'b0111_1111_1111_1110;
                      end else begin
                          LED_state <= LED_state;
                          LED_cnt <= LED_cnt - 4'd1;
                          LED <= {LED[14:0], 1'b1};
                      end
                  end
                  2'd2: begin
                      if (LED_cnt == 4'd0) begin
                          LED_state <= 2'd3;
                          LED_cnt <= 4'd15;
                          LED <= 16'b1100_1100_0011_0011;
                      end else begin
                          LED_state <= LED_state;
                          LED_cnt <= LED_cnt - 4'd1;
                          if (LED_cnt >= 4'd8) begin
                              LED <= {2'b01, LED[15:10], LED[5:0], 2'b01};
                          end else begin
                              LED <= {LED[13:8], 4'b1111, LED[7:2]};
                          end
                      end
                  end
                  2'd3: begin
                      if (LED_cnt == 4'd0) begin
                          LED_state <= 2'd0;
                          LED_cnt <= 4'd15;
                          LED <= 16'b0111_1111_1111_1111;
                      end else begin
                          LED_state <= LED_state;
                          LED_cnt <= LED_cnt - 4'd1;
                          if (LED == 16'b1100_1100_0011_0011) begin
                              LED <= 16'b0011_0011_1100_1100;
                          end else begin
                              LED <= 16'b1100_1100_0011_0011;
                          end
                      end
                  end
                  endcase
              end else begin
                  LED_state <= 2'd3;
                  LED_cnt <= 4'd0;
                  LED <= 16'h0;
              end
          end
      end
     
   
   /*output pixel control*/
   always@(*)begin
      if(valid==1'b1)begin
         case(state)
         START:
             if(doodle_vld){vgaRed, vgaGreen, vgaBlue} = pixel_text_doodle;
             else begin
                if(dleft_vld){vgaRed, vgaGreen, vgaBlue} = pixel_dleft;
                else begin
                    if(dright_vld){vgaRed, vgaGreen, vgaBlue} = pixel_dright;
                    else begin
                        if(dup_vld){vgaRed, vgaGreen, vgaBlue} = pixel_dup;
                        else begin
                              if(midmon_vld){vgaRed, vgaGreen, vgaBlue} = pixel_midmon;
                              else begin
                                 if(pltleft_vld){vgaRed, vgaGreen, vgaBlue} = pixel_pltleft;
                                 else begin
                                    if(pltright_vld){vgaRed, vgaGreen, vgaBlue} = pixel_pltright;
                                    else begin
                                       if(enter_vld){vgaRed, vgaGreen, vgaBlue} = pixel_enter;
                                       else  {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
                                    end
                                  end
                               end
                           end
                        end
                    end
                end
             
         RUN0,RUN1:
             if(blt_vld) {vgaRed, vgaGreen, vgaBlue} = (pixel_blt==12'hfff)?((plyr_vld)?pixel_plyr:pixel_bg):pixel_blt;
             else begin
                 if(plyr_vld){vgaRed, vgaGreen, vgaBlue} =(pixel_plyr==12'hfff)?pixel_bg:pixel_plyr;
                 else begin
                       if(mon_vld) {vgaRed, vgaGreen, vgaBlue} = (pixel_mon==12'hfff)?pixel_bg:pixel_mon;
                       else  begin
                        if(bg_vld) {vgaRed, vgaGreen, vgaBlue} = pixel_bg;
                        else       {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
                       end
                 end
             end
         END:
                       {vgaRed, vgaGreen, vgaBlue} = (score>=9999)?pixel_win:pixel_lose;
         
         default:      {vgaRed, vgaGreen, vgaBlue} = 12'h0;
         endcase
      end
      else {vgaRed, vgaGreen, vgaBlue} =12'h0;
       
   end
   
   /*voice output control*/
   assign pmod_2=1'd1;
   assign pmod_4=sw;

   clock_divisor clk_wiz_0_inst(
      .clk(clk),
      .clk1(clk_25MHz),
      .clk23(clk23),
      .clk27(clk27),
      .clk22(clk22)
   );

   /*blocks of mem_addr_generators*/
   bg_gen BG(
      .h_cnt(h_cnt),
      .v_cnt(v_cnt),
      .valid(bg_vld),
      .clk(clk_25MHz),
      .rand_x1(rand_x1),.rand_x2(rand_x2),.rand_x3(rand_x3),.rand_x4(rand_x4),.rand_x5(rand_x5),.rand_x6(rand_x6),.rand_x7(rand_x7),.rand_x8(rand_x8),.rand_x9(rand_x9),.rand_x10(rand_x10),
      .sh_y1(sh_y1),.sh_y2(sh_y2),.sh_y3(sh_y3),.sh_y4(sh_y4),.sh_y5(sh_y5),.sh_y6(sh_y6),.sh_y7(sh_y7),.sh_y8(sh_y8),.sh_y9(sh_y9),.sh_y10(sh_y10),
      .pixel_addr(bg_addr)
   );
   
   player_addr_gen player(
       .pos_x(plyr_x),
       .pos_y(plyr_y),
       .width(10'd60),
       .height(10'd60),
       .h_cnt(h_cnt),
       .v_cnt(v_cnt),
       .valid(plyr_vld),
       .pixel_addr(plyr_addr)
   );
   
   
   static_addr_gen DOODLE(
       .width(10'd440),
       .height(10'd56),
       .start_x(10'd100),
       .start_y(10'd20),
       .h_cnt(h_cnt),
       .v_cnt(v_cnt),
       .valid(doodle_vld),
       .pixel_addr(text_doodle_addr)
   );
      
   static_addr_gen ENTER (
       .width(10'd110),
       .height(10'd15),
       .start_x(10'd410),
       .start_y(10'd100),
       .h_cnt(h_cnt),
       .v_cnt(v_cnt),
       .valid(enter_vld),
       .pixel_addr(text_enter_addr)
   );
   static_addr_gen WIN (
       .width(10'd340),
       .height(10'd85),
       .start_x(10'd150),
       .start_y(10'd200),
       .h_cnt(h_cnt),
       .v_cnt(v_cnt),
       .valid(win_vld),
       .pixel_addr(text_win_addr)
   );
   static_addr_gen LOSE (
       .width(10'd340),
       .height(10'd85),
       .start_x(10'd150),
       .start_y(10'd200),
       .h_cnt(h_cnt),
       .v_cnt(v_cnt),
       .valid(lose_vld),
       .pixel_addr(text_lose_addr)
   );
   
  static_addr_gen DOODLE_left (
       .width(10'd60),
       .height(10'd60),
       .start_x(10'd60),
       .start_y(10'd300-clk27),//80+120
       .h_cnt(h_cnt),
       .v_cnt(v_cnt),
       .valid(dleft_vld),
       .pixel_addr(doodle_left_addr)
   );
   
   static_addr_gen DOODLE_right (
       .width(10'd60),
       .height(10'd60),
       .start_x(10'd460),//580-120
       .start_y(10'd300+clk27),//60+120+20
       .h_cnt(h_cnt),
       .v_cnt(v_cnt),
       .valid(dright_vld),
       .pixel_addr(doodle_right_addr)
    );
    
   static_addr_gen DOODLE_up (
       .width(10'd60),
       .height(10'd60),
       .start_x(10'd260+clk27),
       .start_y(10'd160),
       .h_cnt(h_cnt),
       .v_cnt(v_cnt),
       .valid(dup_vld),
       .pixel_addr(doodle_up_addr)
    );
   
   static_addr_gen MONSTER_mid (
         .width(10'd120),
         .height(10'd67),
         .start_x(10'd230),
         .start_y(10'd293),
         .h_cnt(h_cnt),
         .v_cnt(v_cnt),
         .valid(midmon_vld),
         .pixel_addr(monster_mid_addr)
       );
   
   static_addr_gen PLT_left (
         .width(10'd58),
         .height(10'd15),
         .start_x(10'd60),
         .start_y(10'd395),//200+120+5
         .h_cnt(h_cnt),
         .v_cnt(v_cnt),
         .valid(pltleft_vld),
         .pixel_addr(plt_left_addr)
     );
   
   static_addr_gen PLT_right (
         .width(10'd58),
         .height(10'd15),
         .start_x(10'd460),
         .start_y(10'd265),//200-30-5
         .h_cnt(h_cnt),
         .v_cnt(v_cnt),
         .valid(pltright_vld),
         .pixel_addr(plt_right_addr)
     );
     
  
    
   /*blocks of moving objects' controllers & detectors*/
   move_controller move_c(
       .clk(clk22),
       .rst(rst),
       .state(state),
       .hit(hit),                             /*hit: 1 when collision occurs*/
       .floor(floor),
       .left(key_down[8'b0001_1100]),          // A--(1C)
       .right(key_down[8'b0010_0011]),         // D--(23)
       .fig_width(10'd60),                      /*figure*/
       .fig_height(10'd60),
       .dir(plyr_dir),                         /*direction: 0 for left, 1 for right*/
       .fly(plyr_fly),                         /*fly: 0 for falling,  1 for airborne*/
       .pos_x(plyr_x),                         /*position*/
       .pos_y(plyr_y),
       .spd_x(spd_x),
       .spd_y(spd_y),
       .advance(advance)                       /*advance; used to update increase height*/
       );
    
    collision_detector_10 detector(
           .plyr_x(plyr_x), 
           .plyr_y(plyr_y),
           .obj_xs({rand_x1,rand_x2,rand_x3,rand_x4,rand_x5,rand_x6,rand_x7,rand_x8,rand_x9,rand_x10}),
           .obj_ys({sh_y1,sh_y2,sh_y3,sh_y4,sh_y5,sh_y6,sh_y7,sh_y8,sh_y9,sh_y10}),
           .map_width(10'd640),
           .spd_x(spd_x),
           .spd_y(spd_y),
           .plyr_width(8'd60), 
           .plyr_height(8'd60),
           .obj_width(8'd58),
           .dir(plyr_dir),
           .fly(plyr_fly),
           .hit(hit),
           .floor(floor),
           .state(state)
        );
        
   bullet_controller bullet_c(
            .clk(clk22),
            .rst(rst),
            .h_cnt(h_cnt),
            .v_cnt(v_cnt),
            .been_ready(key_valid),
            .key_down(key_down),
            .exist(exist_blt),
            .state(state),
            .valid(blt_vld),
            .dir(blt_dir),
            .pos_x(blt_x),
            .pos_y(blt_y),
            .plyr_x(plyr_x),
            .plyr_y(plyr_y),
            .pixel_addr(blt_addr)
        );
        
   monster_controller monster_c(
             .clk(clk22),
             .rst(rst),
             .h_cnt(h_cnt),
             .v_cnt(v_cnt),
             .state(state),
             .blt_x(blt_x),
             .blt_y(blt_y),
             .blt_exist(exist_blt),
             .adv(advance),
             .rand_x2(rand_x2),
             .score(score),
             .valid(mon_vld),
             .mon_alive(mon_alive),
             .pos_x(mon_x),
             .pos_y(mon_y),
             .pixel_addr(mon_addr)
        );
   
   /*RAMs aka block memories*/
   blk_mem_gen_0 bg_pltfm_blk(
         .clka(clk_25MHz),
         .wea(0),
         .addra(bg_addr),
         .dina(data_bg[11:0]),
         .douta(pixel_bg)
       );
    blk_mem_gen_0 pltleft_blk(
         .clka(clk_25MHz),
         .wea(0),
         .addra(plt_left_addr),
         .dina(data_pltleft[11:0]),
         .douta(pixel_pltleft)
    );  
    blk_mem_gen_0 pltright_blk(
         .clka(clk_25MHz),
         .wea(0),
         .addra(plt_right_addr),
         .dina(data_pltright[11:0]),
         .douta(pixel_pltright)
    ); 
       
    /*doodle_player*/
    blk_mem_gen_1 player_blk(
           .clka(clk_25MHz),
           .wea(0),
           .addra(plyr_addr),
           .dina(data_plyr[11:0]),
           .douta(pixel_plyr)
      );
      
     blk_mem_gen_1 doodle_left_blk(
                .clka(clk_25MHz),
                .wea(0),
                .addra(doodle_left_addr),
                .dina(data_dleft[11:0]),
                .douta(pixel_dleft)
           );
           
     blk_mem_gen_1 doodle_right_blk(
                 .clka(clk_25MHz),
                 .wea(0),
                 .addra(doodle_right_addr),
                 .dina(data_dright[11:0]),
                 .douta(pixel_dright)
           );
      blk_mem_gen_1 doodle_up_blk(
                 .clka(clk_25MHz),
                 .wea(0),
                 .addra(doodle_up_addr),
                 .dina(data_dup[11:0]),
                 .douta(pixel_dup)
           );
           
     /*text:doodle*/      
     blk_mem_gen_2 text_doodle_blk(
            .clka(clk_25MHz),
            .wea(0),
            .addra(text_doodle_addr),
            .dina(data_text_doodle[11:0]),
            .douta(pixel_text_doodle)
      );
      
      
      blk_mem_gen_3 bullet_blk(
          .clka(clk_25MHz),
          .wea(0),
          .addra(blt_addr),
          .dina(data_blt[11:0]),
          .douta(pixel_blt)
      );
      
       blk_mem_gen_4 mon_blk(
          .clka(clk_25MHz),
          .wea(0),
          .addra(mon_addr),
          .dina(data_mon[11:0]),
          .douta(pixel_mon)
      );
      blk_mem_gen_4 midmon_blk(
          .clka(clk_25MHz),
          .wea(0),
          .addra(monster_mid_addr),
          .dina(data_midmon[11:0]),
          .douta(pixel_midmon)
       );
      
      blk_mem_gen_5 enter_blk(
          .clka(clk_25MHz),
          .wea(0),
          .addra(text_enter_addr),
          .dina(data_text_enter[11:0]),
          .douta(pixel_enter)
     );      
     
     blk_mem_gen_6 win_blk(
         .clka(clk_25MHz),
         .wea(0),
         .addra(text_win_addr),
         .dina(data_text_win[11:0]),
         .douta(pixel_win)
    );     
    
      blk_mem_gen_7 lose_blk(
        .clka(clk_25MHz),
        .wea(0),
        .addra(text_lose_addr),
        .dina(data_text_lose[11:0]),
        .douta(pixel_lose)
   );     
      

   vga_controller   vga_inst(
      .pclk(clk_25MHz),
      .reset(rst),
      .hsync(hsync),
      .vsync(vsync),
      .valid(valid),
      .h_cnt(h_cnt),
      .v_cnt(v_cnt)
    );
    
    /*random generator of platforms*/
    LFSR lf(
        .clk(clk22),
        .rst(rst),
        .state(state),
        .score(score),
        .y1(sh_y1),.y2(sh_y2),.y3(sh_y3),.y4(sh_y4),.y5(sh_y5),.y6(sh_y6),.y7(sh_y7),.y8(sh_y8),.y9(sh_y9),.y10(sh_y10),
        .out1(rand_x1),.out2(rand_x2),.out3(rand_x3),.out4(rand_x4),.out5(rand_x5),.out6(rand_x6),.out7(rand_x7),.out8(rand_x8),.out9(rand_x9),.out10(rand_x10)
    );     
    
   /*control y position of platforms*/
   pt_shift p(
       .clk(clk22),
       .rst(rst),
       .adv(advance),
       .state(state),
       .sh_y1(sh_y1),
       .sh_y2(sh_y2),
       .sh_y3(sh_y3),
       .sh_y4(sh_y4),
       .sh_y5(sh_y5),
       .sh_y6(sh_y6),
       .sh_y7(sh_y7),
       .sh_y8(sh_y8),
       .sh_y9(sh_y9),
       .sh_y10(sh_y10)
   );
   
  KeyboardDecoder key_decoder(
       .key_down(key_down),
       .last_change(last_change),
       .key_valid(key_valid),
       .PS2_DATA(PS2Data),
       .PS2_CLK(PS2Clk),
       .rst(rst),
       .clk(clk)
       );
       
  SevenSegment seven(
        .display(seg),
        .digit(an),
        .nums(nums),
        .rst(rst),
        .clk(clk)
    );
  
  PWM_gen btSpeedGen(
              .clk(clk),
              .reset(rst),
              .freq(32'd8),    //one beat=0.125seconds
              .duty(10'd512),   //duty cycle=50%
              .PWM(beatFreq)
  );
  
  PlayerCtrl playerCtrl_00(
              .clk(beatFreq),
              .reset(rst),
              .ibeat(ibeatNum) 
  );
  
  Music music00 (
              .ibeatNum(ibeatNum),
              .tone(freq)
  );
  
  PWM_gen toneGen(
              .clk(clk),
              .reset(rst),
              .freq(freq),
              .duty(10'd512),
              .PWM(pmod_1)
  );
  
   
endmodule
