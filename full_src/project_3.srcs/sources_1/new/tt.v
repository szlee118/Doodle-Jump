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


module LFSR(
    input clk,
    input rst,
    input [1:0]state,
    input [13:0]score,
    input [8:0] y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,
    output [8:0] out1,out2,out3,out4,out5,out6,out7,out8,out9,out10
);
    reg  [8:0] r1,r2,r3,r4,r5,r6,r7,r8,r9,r10;
    wire [8:0] next_r1,next_r2,next_r3,next_r4,next_r5,next_r6,next_r7,next_r8,next_r9,next_r10;
    reg dir1,dir2,dir3,dir4,dir5,dir6,dir7,dir8,dir9,dir10;
    always@(posedge clk)begin  //supposed to be flag
        if(rst)begin
             r1<=8'b1101_0001;
             r2<=8'b1001_1001;
             r3<=8'b0101_1101;
             r4<=8'b0110_0001;
             r5<=8'b1101_1001;
             r6<=8'b1000_1101;
             r7<=8'b1111_0001;
             r8<=8'b1101_0101;
             r9<=8'b1001_0101;
             r10<=8'b1100_1001;
             dir1<=0;
             dir2<=1;
             dir3<=0;
             dir4<=0;
             dir5<=1;
             dir6<=1;
             dir7<=0;
             dir8<=1;
             dir9<=0;
             dir10<=1;
        end
        else begin
        case(state)
        2:
            if(score<=5000)begin
                 r1<=(y1>479)?next_r1:r1;
                 r2<=(y2>479)?next_r2:r2;
                 r3<=(y3>479)?next_r3:r3;
                 r4<=(y4>479)?next_r4:r4;
                 r5<=(y5>479)?next_r5:r5;
                 r6<=(y6>479)?next_r6:r6;
                 r7<=(y7>479)?next_r7:r7;
                 r8<=(y8>479)?next_r8:r8;
                 r9<=(y9>479)?next_r9:r9;
                 r10<=(y10>479)?next_r10:r10;
             end
             else begin
                if(r1==0)begin
                    r1<=(y1>479)?next_r1:r1+1;
                    dir1<=~dir1;
                end
                else if(r1==480)begin
                    r1<=(y1>479)?next_r1:r1-1;
                    dir1<=~dir1;
                end
                else begin
                     r1<=(y1>479)?next_r1:(dir1==1)?r1-1:r1+1;
                     dir1<=~dir1;
                end
  
                if(r2==0)begin
                    r2<=(y2>479)?next_r2:r2+1;
                    dir2<=~dir2;
                end
                else if(r2>=480)begin
                    r2<=(y2>479)?next_r2:r2-1;
                    dir2<=~dir2;
                end
                else begin
                    r2<=(y2>479)?next_r2:(dir2==1)?r2-1:r2+1;
                    dir2<=dir2;
                end
                
                if(r3==0)begin
                    r3<=(y3>479)?next_r3:r3+1;
                    dir3<=~dir3;
                end
                else if(r3>=480)begin
                    r3<=(y3>479)?next_r3:r3-1;
                    dir3<=~dir3;
                end
                else begin
                    r3<=(y3>479)?next_r3:(dir3==1)?r3-1:r3+1;
                    dir3<=dir3;
                end    
                if(r4==0)begin
                    r4<=(y4>479)?next_r4:r4+1;
                    dir4<=~dir4;
                end
                else if(r4>=480)begin
                    r4<=(y4>479)?next_r4:r4-1;
                    dir4<=~dir4;
                end
                else begin
                    r4<=(y4>479)?next_r4:(dir4==1)?r4-1:r4+1;
                    dir4<=dir4;
                end
                
                if(r5==0)begin
                    r5<=(y5>479)?next_r5:r5+1;
                     dir5<=~dir5;
                end
                else if(r5>=480)begin
                    r5<=(y5>479)?next_r5:r5-1;
                    dir5<=~dir5;
                end
                else begin
                    r5<=(y5>479)?next_r5:(dir5==1)?r5-1:r5+1;
                    dir5<=dir5;
                end
                    
                if(r6==0)begin
                    r6<=(y6>479)?next_r6:r6+1;
                    dir6<=~dir6;
                end
                else if(r6>=480)begin
                    r6<=(y6>479)?next_r6:r6-1;
                    dir6<=~dir6;
                end
                else begin
                    r6<=(y6>479)?next_r6:(dir6==1)?r6-1:r6+1;
                    dir6<=dir6;
                end
                if(r7==0)begin
                    r7<=(y7>479)?next_r7:r7+1;
                    dir7<=~dir7;
                end
                else if(r7>=480)begin
                    r7<=(y7>479)?next_r7:r7-1;
                    dir7<=~dir7;
                end
                else begin
                    r7<=(y7>479)?next_r7:(dir7==1)?r7-1:r7+1;
                    dir7<=dir7;
                end
                    
                if(r8==0)begin
                    r8<=(y8>479)?next_r8:r8+1;
                    dir8<=~dir8;
                end
                else if(r8>=480)begin
                    r8<=(y8>479)?next_r8:r8-1;
                    dir8<=~dir8;
                end
                else begin
                    r8<=(y8>479)?next_r8:(dir8==1)?r8-1:r8+1;
                    dir8<=dir8;
                end
                if(r9==0)begin
                    r9<=(y9>479)?next_r9:r9+1;
                    dir9<=~dir9;
                end
                else if(r9>=480)begin
                    r9<=(y9>479)?next_r9:r9-1;
                    dir9<=~dir9;
                end
                else begin
                    r9<=(y9>479)?next_r9:(dir9==1)?r9-1:r9+1;
                    dir9<=dir9;
                end
                if(r10==0)begin
                    r10<=(y10>479)?next_r10:r10+1;
                    dir10<=~dir10;
                end
                else if(r10>=480)begin
                    r10<=(y10>479)?next_r10:r10-1;
                    dir10<=~dir10;
                end
                else begin
                    r10<=(y10>479)?next_r10:(dir10==1)?r10-1:r10+1;              
                    dir10<=dir10;
                end                    
          end
       default:  begin
                r1<=r1;
                r2<=r2;     
                r3<=r3;
                r4<=r4;
                r5<=r5;
                r6<=r6;
                r7<=r7;
                r8<=r8;
                r9<=r9;
                r10<=r10;
       end
                    
       endcase
     end
    end

    assign  next_r1[8:1]=r1[7:0],next_r1[0]=r1[8]^r1[7];
    assign  next_r2[8:1]=r2[7:0],next_r2[0]=r2[8]^r2[7];
    assign  next_r3[8:1]=r3[7:0],next_r3[0]=r3[8]^r3[7];
    assign  next_r4[8:1]=r4[7:0],next_r4[0]=r4[8]^r4[7];
    assign  next_r5[8:1]=r5[7:0],next_r5[0]=r5[8]^r5[7];
    assign  next_r6[8:1]=r6[7:0],next_r6[0]=r6[8]^r6[7];
    assign  next_r7[8:1]=r7[7:0],next_r7[0]=r7[8]^r7[7];
    assign  next_r8[8:1]=r8[7:0],next_r8[0]=r8[8]^r8[7];
    assign  next_r9[8:1]=r9[7:0],next_r9[0]=r9[8]^r9[7];
    assign  next_r9[8:1]=r9[7:0],next_r9[0]=r9[8]^r9[7];
    assign  out1=r1, out2=r2, out3=r3, out4=r4, out5=r5, out6=r6, out7=r7, out8=r8, out9=r9, out10=r10;
            
endmodule

module pt_shift(
    input wire clk,
    input wire rst,
    input [3:0] adv,     /*advance*/
    input [1:0] state,
    output reg [8:0] sh_y1,sh_y2,sh_y3,sh_y4,sh_y5,sh_y6,sh_y7,sh_y8,sh_y9,sh_y10
);
    reg [8:0] next_y1,next_y2,next_y3,next_y4,next_y5,next_y6,next_y7,next_y8,next_y9,next_y10;
    always@(posedge clk)begin
        if(rst||state!=2)begin
           sh_y1<=480;
           sh_y2<=432;
           sh_y3<=384;
           sh_y4<=336;
           sh_y5<=288;
           sh_y6<=240;
           sh_y7<=192;
           sh_y8<=144;
           sh_y9<=96;
           sh_y10<=48;
        end
        else begin
           sh_y1<=(state==2)?next_y1:sh_y1;
           sh_y2<=(state==2)?next_y2:sh_y2;
           sh_y3<=(state==2)?next_y3:sh_y3;
           sh_y4<=(state==2)?next_y4:sh_y4;
           sh_y5<=(state==2)?next_y5:sh_y5;
           sh_y6<=(state==2)?next_y6:sh_y6;
           sh_y7<=(state==2)?next_y7:sh_y7;
           sh_y8<=(state==2)?next_y8:sh_y8;
           sh_y9<=(state==2)?next_y9:sh_y9;
           sh_y10<=(state==2)?next_y10:sh_y10;
        end
      end    
      always@(*)begin
           next_y1=(sh_y1>479)?((sh_y10>=48&& sh_y10<sh_y1)?(sh_y10-48):sh_y1+adv):sh_y1+adv;
           next_y2=(sh_y2>479)?((sh_y1>=48&& sh_y1<sh_y2)?(sh_y1-48):sh_y2+adv):sh_y2+adv;
           next_y3=(sh_y3>479)?((sh_y2>=48&& sh_y2<sh_y3)?(sh_y2-48):sh_y3+adv):sh_y3+adv;
           next_y4=(sh_y4>479)?((sh_y3>=48&& sh_y3<sh_y4)?(sh_y3-48):sh_y4+adv):sh_y4+adv;
           next_y5=(sh_y5>479)?((sh_y4>=48&& sh_y4<sh_y5)?(sh_y4-48):sh_y5+adv):sh_y5+adv;
           next_y6=(sh_y6>479)?((sh_y5>=48&& sh_y5<sh_y6)?(sh_y5-48):sh_y6+adv):sh_y6+adv;
           next_y7=(sh_y7>479)?((sh_y6>=48&& sh_y6<sh_y7)?(sh_y6-48):sh_y7+adv):sh_y7+adv;
           next_y8=(sh_y8>479)?((sh_y7>=48&& sh_y7<sh_y8)?(sh_y7-48):sh_y8+adv):sh_y8+adv;
           next_y9=(sh_y9>479)?((sh_y8>=48&& sh_y8<sh_y9)?(sh_y8-48):sh_y9+adv):sh_y9+adv;
           next_y10=(sh_y10>479)?((sh_y9>=48&& sh_y9<sh_y10)?(sh_y9-48):sh_y10+adv):sh_y10+adv;
      end
     
    
endmodule

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

module player_addr_gen(
    input [9:0] pos_x,
    input [9:0] pos_y,
    input [9:0] width,
    input [9:0] height,
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    output reg valid,
    output reg [16:0] pixel_addr
    );

    always@(*) begin
        if (v_cnt >= pos_y && v_cnt < pos_y + height) begin
            if (h_cnt > pos_x && h_cnt <= pos_x + width) begin
                valid = 1'b1;
                pixel_addr = (h_cnt - pos_x) + (v_cnt - pos_y)*width;
            end else begin
                valid = 1'b0;
                pixel_addr = 17'd0;
            end
        end else begin
            valid = 1'b0;
            pixel_addr = 17'd0;
        end
    end

endmodule


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


module move_controller(
    input clk,
    input rst,
    input hit,                              /*hit: 1 when collision occurs*/
    input left,
    input right,
    input [1:0] state,
    input [7:0] fig_width,                  /*figure*/
    input [7:0] fig_height,
    input [9:0] floor,
    output reg dir,                         /*direction: 0 for left, 1 for right*/
    output reg fly,                         /*fly: 0 for falling,  1 for airborne*/
    output reg [9:0] pos_x,                 /*position*/
    output reg [9:0] pos_y,
    output reg [3:0] spd_x,                 /*speed*/
    output reg [3:0] spd_y,
    output reg [3:0] advance                /*advance; used to update increase height*/
    );
    reg [9:0] add_x, sub_x, fal_y, ris_y, jmp_y;    /*add, subtract*/
    reg [3:0] acc_x, acc_y;                         /*accelerate*/
    reg [3:0] dec_x, drp_x, dec_y;                  /*deccelerate, drop*/
    wire mv_lft, mv_rgt;                            /*move left, right*/
    wire acc_lft, acc_rgt, dec_lft, dec_rgt;
    wire spd_up, slw_dn;                            /*speed up, slow down*/
    
    parameter map_width = 10'd640;
    parameter map_height = 10'd480;
    
    and move_left(mv_lft, left, ~right),
        move_right(mv_rgt, ~left, right),
        acc_left(acc_lft, mv_lft, ~dir),
        acc_right(acc_rgt, mv_rgt, dir),
        dec_left(dec_lft, mv_rgt, ~dir),
        dec_right(dec_rgt, mv_lft, dir);
    or  speed_up(spd_up, acc_lft, acc_rgt),
        slow_down(slw_dn, dec_lft, dec_rgt);
    
    always@(posedge clk) begin
        if (rst||(state!=2)) begin
            dir <= 1'b0;
            fly <= 1'b1;
            pos_x <= (map_width - fig_width)>>1;
            pos_y <= (map_height - fig_height*2);
            spd_x <= 4'd0;
            spd_y <= 4'd15;
        end else begin
            /*position_x control*/
            if (dir) begin
                pos_x <= add_x;
            end else begin
                pos_x <= sub_x;
            end
            /*position_y control*/
            if (hit) begin
                pos_y <= ris_y;
            end else begin
                if (fly) begin
                    pos_y <= ris_y;
                end else begin
                    pos_y <= fal_y;
                end
            end
            /*speed_x control*/
            if (spd_up) begin
                spd_x <= acc_x;
                dir <= dir;
            end else begin
                if (slw_dn) begin
                    if (spd_x == 4'd0) begin
                        spd_x <= acc_x;
                        dir <= ~dir;
                    end else begin
                        spd_x <= dec_x;
                        dir <= dir;
                    end
                end else begin
                    spd_x <= drp_x;
                    dir <= dir;
                end
            end
            /*speed_y control*/
            if (hit) begin
                spd_y <= 4'd15;
                fly <= 1'b1;
            end else begin
                if (fly) begin
                    if (spd_y == 4'd0) begin
                        spd_y <= acc_y;
                        fly <= ~fly;
                    end else begin
                        spd_y <= dec_y;
                        fly <= fly;
                    end
                end else begin
                    spd_y <= acc_y;
                    fly <= fly;
                end
            end
        end
    end
    
    always@(*) begin
        if (spd_x > 4'd1) begin
            dec_x = spd_x - 4'd2;
        end else begin
            dec_x = 4'd0;
        end
        if (spd_x > 4'd0) begin
            drp_x = spd_x - 4'd1;
        end else begin
            drp_x = 4'd0;
        end
        if (spd_x < 4'd15) begin
            acc_x = spd_x + 4'd1;
        end else begin
            acc_x = 4'd15;
        end
    end
    always@(*) begin
        if (spd_y > 4'd0) begin
            dec_y = spd_y - 4'd1;
        end else begin
            dec_y = 4'd0;
        end
        if (spd_y < 4'd15) begin
            acc_y = spd_y + 4'd1;
        end else begin
            acc_y = 4'd15;
        end
    end
    always@(*) begin
        if (pos_x > spd_x) begin
            sub_x = pos_x - spd_x;
        end else begin
            sub_x = map_width - fig_width - 1;
        end
        if (pos_x + fig_width < map_width - spd_x) begin
            add_x = pos_x + spd_x;
        end else begin
            add_x = 10'd0;
        end
    end
    always@(*) begin
        if (pos_y - spd_y > (map_height>>1) - (fig_height>>1)) begin
            ris_y = pos_y - spd_y;
            advance = 4'd0;
        end else begin
            ris_y = (map_height>>1) - (fig_height>>1);
            advance = spd_y - (pos_y - ((map_height>>1) - (fig_height>>1)));
        end
        if (pos_y < map_height) begin
            fal_y = pos_y + spd_y;
        end else begin
            fal_y = 10'd0;
        end
        jmp_y = floor - spd_y + (floor - pos_y);
    end
endmodule


module collision_detector(
    input [9:0] plyr_x, plyr_y,     /*player*/
    input [8:0] obj_x, obj_y,       /*object*/
    input [3:0] spd_x, spd_y,       /*speed*/
    input [9:0] map_width,
    input [9:0] plyr_width, plyr_height,
    input [9:0] obj_width,
    input [1:0] state,
    input dir, fly,                 /*direction: 0 for left, 1 for right; fl: 0 for fall, 1 for fly*/
    output reg hit
    );
    reg able_x, able_y;
    
    always@(*)begin
        if(able_x && able_y && state==2)hit=1;
        else hit=0;
    end
    
    always@(*) begin
        if (dir) begin
            if ((plyr_x + plyr_width + spd_x) >= obj_x && (plyr_x + spd_x) <= (obj_x + obj_width)) begin
                able_x = 1'b1;
            end else begin
                able_x = 1'b0;
            end
        end else begin
            if (plyr_x <= (obj_x + obj_width + spd_x)%map_width && (plyr_x + plyr_width) >= (obj_x + spd_x)) begin
                able_x = 1'b1;
            end else begin
                able_x = 1'b0;
            end
        end
    end
    always@(*) begin
        if (fly) begin
            able_y = 1'b0;
        end else begin
            if ((plyr_y + plyr_height) <= obj_y && (plyr_y + plyr_height + spd_y) > obj_y) begin
                able_y = 1'b1;
            end else begin
                able_y = 1'b0;
            end
        end
    end
endmodule

module collision_detector_10(
    input [9:0] plyr_x, plyr_y,
    input [89:0] obj_xs,
    input [89:0] obj_ys,
    input [3:0] spd_x, spd_y,
    input [9:0] map_width,
    input [9:0] plyr_width, plyr_height,
    input [9:0] obj_width,
    input [1:0] state,
    input dir, fly,
    output hit,
    output reg [9:0] floor
    );
    wire [9:0] hits;
    wire [4:0] con_a;
    wire [1:0] con_b;
    wire con_c;
    
    or  con_a0(con_a[0], hits[0], hits[1]),
        con_a1(con_a[1], hits[2], hits[3]),
        con_a2(con_a[2], hits[4], hits[5]),
        con_a3(con_a[3], hits[6], hits[7]),
        con_a4(con_a[4], hits[8], hits[9]);
    or  con_b0(con_b[0], con_a[1], con_a[0]),
        con_b1(con_b[1], con_a[3], con_a[2]);
    or  con_c0(con_c, con_b[1], con_b[0]),
        final(hit, con_c, con_a[4]); 
    
    collision_detector detect00(.plyr_x(plyr_x), .plyr_y(plyr_y), .obj_x(obj_xs[8:0]), .obj_y(obj_ys[8:0]), .map_width(map_width),
                       .plyr_width(plyr_width), .plyr_height(plyr_height), .obj_width(obj_width),
                       .dir(dir), .fly(fly), .hit(hits[0]),.state(state), .spd_x(spd_x), .spd_y(spd_y)),
                       detect01(.plyr_x(plyr_x), .plyr_y(plyr_y), .obj_x(obj_xs[17:9]), .obj_y(obj_ys[17:9]), .map_width(map_width),
                       .plyr_width(plyr_width), .plyr_height(plyr_height), .obj_width(obj_width),
                       .dir(dir), .fly(fly), .hit(hits[1]),.state(state), .spd_x(spd_x), .spd_y(spd_y)),
                       detect02(.plyr_x(plyr_x), .plyr_y(plyr_y), .obj_x(obj_xs[26:18]), .obj_y(obj_ys[26:18]), .map_width(map_width),
                       .plyr_width(plyr_width), .plyr_height(plyr_height), .obj_width(obj_width),
                       .dir(dir), .fly(fly), .hit(hits[2]),.state(state), .spd_x(spd_x), .spd_y(spd_y)),
                       detect03(.plyr_x(plyr_x), .plyr_y(plyr_y), .obj_x(obj_xs[35:27]), .obj_y(obj_ys[35:27]), .map_width(map_width),
                       .plyr_width(plyr_width), .plyr_height(plyr_height), .obj_width(obj_width),
                       .dir(dir), .fly(fly), .hit(hits[3]),.state(state), .spd_x(spd_x), .spd_y(spd_y)),
                       detect04(.plyr_x(plyr_x), .plyr_y(plyr_y), .obj_x(obj_xs[44:36]), .obj_y(obj_ys[44:36]), .map_width(map_width),
                       .plyr_width(plyr_width), .plyr_height(plyr_height), .obj_width(obj_width),
                       .dir(dir), .fly(fly), .hit(hits[4]),.state(state), .spd_x(spd_x), .spd_y(spd_y)),
                       
                       detect05(.plyr_x(plyr_x), .plyr_y(plyr_y), .obj_x(obj_xs[53:45]), .obj_y(obj_ys[53:45]), .map_width(map_width),
                       .plyr_width(plyr_width), .plyr_height(plyr_height), .obj_width(obj_width),
                       .dir(dir), .fly(fly), .hit(hits[5]),.state(state), .spd_x(spd_x), .spd_y(spd_y)),
                       detect06(.plyr_x(plyr_x), .plyr_y(plyr_y), .obj_x(obj_xs[62:54]), .obj_y(obj_ys[62:54]), .map_width(map_width),
                       .plyr_width(plyr_width), .plyr_height(plyr_height), .obj_width(obj_width),
                       .dir(dir), .fly(fly), .hit(hits[6]),.state(state), .spd_x(spd_x), .spd_y(spd_y)),
                       detect07(.plyr_x(plyr_x), .plyr_y(plyr_y), .obj_x(obj_xs[71:63]), .obj_y(obj_ys[71:63]), .map_width(map_width),
                       .plyr_width(plyr_width), .plyr_height(plyr_height), .obj_width(obj_width),
                       .dir(dir), .fly(fly), .hit(hits[7]),.state(state), .spd_x(spd_x), .spd_y(spd_y)),
                       detect08(.plyr_x(plyr_x), .plyr_y(plyr_y), .obj_x(obj_xs[80:72]), .obj_y(obj_ys[80:72]), .map_width(map_width),
                       .plyr_width(plyr_width), .plyr_height(plyr_height), .obj_width(obj_width),
                       .dir(dir), .fly(fly), .hit(hits[8]),.state(state), .spd_x(spd_x), .spd_y(spd_y)),
                       detect09(.plyr_x(plyr_x), .plyr_y(plyr_y), .obj_x(obj_xs[89:81]), .obj_y(obj_ys[89:81]), .map_width(map_width),
                       .plyr_width(plyr_width), .plyr_height(plyr_height), .obj_width(obj_width),
                       .dir(dir), .fly(fly), .hit(hits[9]),.state(state), .spd_x(spd_x), .spd_y(spd_y));
                       
    always@(*) begin
        if (hits[0]) begin
            floor = obj_ys[8:0];
        end else begin
            if (hits[1]) begin
                floor = obj_ys[17:9];
            end else begin
                if (hits[2]) begin
                    floor = obj_ys[26:18];
                end else begin
                    if (hits[3]) begin
                        floor = obj_ys[35:27];
                    end else begin
                        if (hits[4]) begin
                            floor = obj_ys[44:36];
                        end else begin
                            if (hits[5]) begin
                                floor = obj_ys[53:45];
                            end else begin
                                if (hits[6]) begin
                                    floor = obj_ys[62:54];
                                end else begin
                                    if (hits[7]) begin
                                        floor = obj_ys[71:63];
                                    end else begin
                                        if (hits[8]) begin
                                            floor = obj_ys[80:72];
                                        end else begin
                                            if (hits[9]) begin
                                                floor = obj_ys[89:81];
                                            end else begin
                                                floor = 10'd0;
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

endmodule

module bullet_controller(
    input clk,
    input rst,
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    input [1:0] state,
    input been_ready,
    input [511:0] key_down,
    input [9:0] plyr_x,plyr_y,
    output exist,
    output valid,
    output reg [2:0] dir,
    output reg [9:0] pos_x,
    output reg [9:0] pos_y,
    output reg [6:0] pixel_addr
);
    /*dir: num_9 = code_0; num_6~8 = code_(n - 1); num1~4 = code_n*/
    reg est_x, est_y;
    reg vld_x, vld_y;
    wire vld_all;

    parameter map_width = 10'd640;
    parameter map_height = 10'd480;
    parameter spd_x = 5'd25;
    parameter spd_y = 5'd25;

    parameter CODES_1 = 9'b0_0110_1001;// 69, 1, downleft
    parameter CODES_2 = 9'b0_0111_0010;// 72, 2, down
    parameter CODES_3 = 9'b0_0111_1010;// 7A, 3, downright
    parameter CODES_4 = 9'b0_0110_1011;// 6B, 4, left
    parameter CODES_6 = 9'b0_0111_0100;// 74  6 right
    parameter CODES_7 = 9'b0_0110_1100;// 6c 7 upleft
    parameter CODES_8 = 9'b0_0111_0101;// 75 8 up
    parameter CODES_9 = 9'b0_0111_1101;//7D 9 upright

    and check_exist(exist, est_x, est_y),
        check_valid(vld_all, vld_x, vld_y),
        is_valid(valid, vld_all, exist);
    
    always@(*) begin
        if (h_cnt >= pos_x && h_cnt < pos_x + 10) begin
            vld_x = 1'b1;
        end else begin
            vld_x = 1'b0;
        end
        if (v_cnt >= pos_y && v_cnt < pos_y + 11) begin
            vld_y = 1'b1;
        end else begin
            vld_y = 1'b0;
        end
    end
    
    always@(*) begin
        if (valid) begin
            pixel_addr = (h_cnt - pos_x) + (v_cnt - pos_y)*10;
        end else begin
            pixel_addr = 0;
        end
    end

    always@(posedge clk) begin
        if (rst||(state!=2)) begin
            pos_x <= plyr_x;
            pos_y <= plyr_y;
            dir <= 3'd0;
            est_x <= 1'b0;
            est_y <= 1'b0;
        end else begin
            if (exist) begin
                if (dir == 3 || dir == 5 || dir == 0) begin
                    if (pos_x + spd_x < map_width) begin
                        pos_x <= pos_x + spd_x;
                        est_x <= est_x;
                    end else begin
                        pos_x <= pos_x;
                        est_x <= 1'b0;
                    end
                end else if (dir == 1 || dir == 4 || dir == 6) begin
                    if (pos_x < spd_x) begin
                        pos_x <= pos_x;
                        est_x <= 1'b0;
                    end else begin
                        pos_x <= pos_x - spd_x;
                        est_x <= est_x;
                    end
                end else begin
                    pos_x <= pos_x;
                    est_x <= est_x;
                end
                if (dir == 1 || dir == 2 || dir == 3) begin
                    if (pos_y + spd_y < map_height) begin
                        pos_y <= pos_y + spd_y;
                        est_y <= est_y;
                    end else begin
                        pos_y <= pos_y;
                        est_y <= 1'b0;
                    end
                end else if (dir == 6 || dir == 7 || dir == 0) begin
                    if (pos_y < spd_y) begin
                        pos_y <= pos_y;
                        est_y <= 1'b0;
                    end else begin
                        pos_y <= pos_y - spd_y;
                        est_y <= est_y;
                    end
                end else begin
                        pos_y <= pos_y;
                        est_y <= est_y;
                end
            end 
            else begin
                    if(key_down[CODES_1]==1)begin
                        {est_x, est_y} <= 2'b11;
                        dir <= 3'd1;
                        pos_x<=plyr_x;
                        pos_y<=plyr_y+60;    
                    end
                    else if(key_down[CODES_2]==1)begin
                        {est_x, est_y} <= 2'b11;
                        dir <= 3'd2;
                        pos_x<=plyr_x+30;
                        pos_y<=plyr_y+60;    
                    end
                    else if(key_down[CODES_3]==1)begin
                        {est_x, est_y} <= 2'b11;
                        dir <= 3'd3;
                        pos_x<=plyr_x+60;
                        pos_y<=plyr_y+60; 
                    end
                    else if(key_down[CODES_4]==1)begin
                        {est_x, est_y} <= 2'b11;
                        dir <= 3'd4;
                        pos_x<=plyr_x;
                        pos_y<=plyr_y+30; 
                    end
                    else if(key_down[CODES_6]==1)begin
                        {est_x, est_y} <= 2'b11;
                        dir <= 3'd5;
                        pos_x<=plyr_x+60;
                        pos_y<=plyr_y+30; 
                    end
                    else if(key_down[CODES_7]==1)begin
                        {est_x, est_y} <= 2'b11;
                        dir <= 3'd6;
                        pos_x<=plyr_x;
                        pos_y<=plyr_y; 
                    end
                    else if(key_down[CODES_8]==1)begin
                        {est_x, est_y} <= 2'b11;
                        dir <= 3'd7;
                        pos_x<=plyr_x+30;
                        pos_y<=plyr_y; 
                    end
                    else if(key_down[CODES_9]==1) begin
                        {est_x, est_y} <= 2'b11;
                        dir <= 3'd0;
                        pos_x<=plyr_x+60;
                        pos_y<=plyr_y; 
                    end
                    else begin
                        {est_x, est_y} <= {est_x, est_y};
                        dir <= dir;
                        pos_x<=plyr_x;
                        pos_y<=plyr_y;
                    end
            end
        end
    end
endmodule

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


module clock_divisor(clk23, clk22,clk27, clk1, clk);
    input clk;
    output clk1,clk22,clk23,clk27;

    reg [26:0] num;
    wire [26:0] next_num;

    always @(posedge clk) begin
        num <= next_num;
    end

    assign next_num = num + 1'b1;
    assign clk1 = num[1];
    assign clk23= num[22];
    assign clk27= num[26];
    assign clk22= num[21];
endmodule


module vga_controller 
  (
    input wire pclk,reset,
    output wire hsync,vsync,valid,
    output wire [9:0]h_cnt,
    output wire [9:0]v_cnt
    );
    
    reg [9:0]pixel_cnt;
    reg [9:0]line_cnt;
    reg hsync_i,vsync_i;
    wire hsync_default, vsync_default;
    wire [9:0] HD, HF, HS, HB, HT, VD, VF, VS, VB, VT;

   
    assign HD = 640;
    assign HF = 16;
    assign HS = 96;
    assign HB = 48;
    assign HT = 800; 
    assign VD = 480;
    assign VF = 10;
    assign VS = 2;
    assign VB = 33;
    assign VT = 525;
    assign hsync_default = 1'b1;
    assign vsync_default = 1'b1;
     
    always@(posedge pclk)
        if(reset)
            pixel_cnt <= 0;
        else begin
             if(pixel_cnt < (HT - 1))
                pixel_cnt <= pixel_cnt + 1;
             else
                pixel_cnt <= 0;
        end

    always@(posedge pclk)
        if(reset)
            hsync_i <= hsync_default;
        else if((pixel_cnt >= (HD + HF - 1))&&(pixel_cnt < (HD + HF + HS - 1)))
                hsync_i <= ~hsync_default;
            else
                hsync_i <= hsync_default; 
    
    always@(posedge pclk)
        if(reset)
            line_cnt <= 0;
        else if(pixel_cnt == (HT -1))
                if(line_cnt < (VT - 1))
                    line_cnt <= line_cnt + 1;
                else
                    line_cnt <= 0;
                    
    always@(posedge pclk)
        if(reset)
            vsync_i <= vsync_default; 
        else if((line_cnt >= (VD + VF - 1))&&(line_cnt < (VD + VF + VS - 1)))
            vsync_i <= ~vsync_default; 
        else
            vsync_i <= vsync_default; 
                    
    assign hsync = hsync_i;
    assign vsync = vsync_i;
    assign valid = ((pixel_cnt < HD) && (line_cnt < VD));
    
    assign h_cnt = (pixel_cnt < HD) ? pixel_cnt:10'd0;
    assign v_cnt = (line_cnt < VD) ? line_cnt:10'd0;
           
endmodule


module KeyboardDecoder(
	output reg [511:0] key_down,
	output wire [8:0] last_change,
	output reg key_valid,
	inout wire PS2_DATA,
	inout wire PS2_CLK,
	input wire rst,
	input wire clk
    );
    
    parameter [1:0] INIT			= 2'b00;
    parameter [1:0] WAIT_FOR_SIGNAL = 2'b01;
    parameter [1:0] GET_SIGNAL_DOWN = 2'b10;
    parameter [1:0] WAIT_RELEASE    = 2'b11;
    
	parameter [7:0] IS_INIT			= 8'hAA;
    parameter [7:0] IS_EXTEND		= 8'hE0;
    parameter [7:0] IS_BREAK		= 8'hF0;
    
    reg [9:0] key;		// key = {been_extend, been_break, key_in}
    reg [1:0] state;
    reg been_ready, been_extend, been_break;
    wire pulse_been_ready;
    wire [7:0] key_in;
    wire is_extend;
    wire is_break;
    wire valid;
    wire err;
    
    wire [511:0] key_decode = 1 << last_change;
    assign last_change = {key[9], key[7:0]};
    
    KeyboardCtrl_1 inst (
		.key_in(key_in),
		.is_extend(is_extend),
		.is_break(is_break),
		.valid(valid),
		.err(err),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(rst),
		.clk(clk)
	);
	
	OnePulse op (
		.signal_single_pulse(pulse_been_ready),
		.signal(been_ready),
		.clock(clk)
	);
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		state <= INIT;
    		been_ready  <= 1'b0;
    		been_extend <= 1'b0;
    		been_break  <= 1'b0;
    		key <= 10'b0_0_0000_0000;
    	end else begin
    		state <= state;
			been_ready  <= been_ready;
			been_extend <= (is_extend) ? 1'b1 : been_extend;
			been_break  <= (is_break ) ? 1'b1 : been_break;
			key <= key;
    		case (state)
    			INIT : begin
    					if (key_in == IS_INIT) begin
    						state <= WAIT_FOR_SIGNAL;
    						been_ready  <= 1'b0;
							been_extend <= 1'b0;
							been_break  <= 1'b0;
							key <= 10'b0_0_0000_0000;
    					end else begin
    						state <= INIT;
    					end
    				end
    			WAIT_FOR_SIGNAL : begin
    					if (valid == 0) begin
    						state <= WAIT_FOR_SIGNAL;
    						been_ready <= 1'b0;
    					end else begin
    						state <= GET_SIGNAL_DOWN;
    					end
    				end
    			GET_SIGNAL_DOWN : begin
						state <= WAIT_RELEASE;
						key <= {been_extend, been_break, key_in};
						been_ready  <= 1'b1;
    				end
    			WAIT_RELEASE : begin
    					if (valid == 1) begin
    						state <= WAIT_RELEASE;
    					end else begin
    						state <= WAIT_FOR_SIGNAL;
    						been_extend <= 1'b0;
    						been_break  <= 1'b0;
    					end
    				end
    			default : begin
    					state <= INIT;
						been_ready  <= 1'b0;
						been_extend <= 1'b0;
						been_break  <= 1'b0;
						key <= 10'b0_0_0000_0000;
    				end
    		endcase
    	end
    end
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		key_valid <= 1'b0;
    		key_down <= 511'b0;
    	end else if (key_decode[last_change] && pulse_been_ready) begin
    		key_valid <= 1'b1;
    		if (key[8] == 0) begin
    			key_down <= key_down | key_decode ;
    		end else begin
    			key_down <= key_down & (~key_decode);
    		end
    	end else begin
    		key_valid <= 1'b0;
			key_down <= key_down;
    	end
    end
endmodule

module OnePulse (
	output reg signal_single_pulse,
	input wire signal,
	input wire clock
	);
	
	reg signal_delay;

	always @(posedge clock) begin
		if (signal == 1'b1 & signal_delay == 1'b0)
		  signal_single_pulse <= 1'b1;
		else
		  signal_single_pulse <= 1'b0;

		signal_delay <= signal;
	end
endmodule

module SevenSegment(
	output reg [6:0] display,
	output reg [3:0] digit,
	input wire [15:0] nums,
	input wire rst,
	input wire clk
    );
    
    reg [15:0] clk_divider;
    reg [3:0] display_num;
    
    always @ (posedge clk) begin
    	if (rst) begin
    		clk_divider <= 15'b0;
    	end else begin
    		clk_divider <= clk_divider + 15'b1;
    	end
    end
    
    always @ (posedge clk_divider[15]) begin
    	if (rst) begin
    		display_num <= 4'b0000;
    		digit <= 4'b1111;
    	end else begin
    		case (digit)
    		    4'b1110 : begin
                        display_num <= nums[7:4];
                        digit <= 4'b1101;
                    end
    			4'b1101 : begin
						display_num <= nums[11:8];
						digit <= 4'b1011;
					end
			    4'b1011 : begin
                        display_num <= nums[15:12];
                        digit <= 4'b0111;
                    end
                4'b0111 : begin
                        display_num <= nums[3:0];
                        digit <= 4'b1110;
                    end
    			default : begin
						display_num <= nums[7:4];
						digit <= 4'b1110;
					end				
    		endcase
    	end
    end
    
    always @ (*) begin
    	case (display_num)
    		0 : display = 7'b1000000;	//0000
			1 : display = 7'b1111001;   //0001                                                
			2 : display = 7'b0100100;   //0010                                                
			3 : display = 7'b0110000;   //0011                                             
			4 : display = 7'b0011001;   //0100                                               
			5 : display = 7'b0010010;   //0101                                               
			6 : display = 7'b0000010;   //0110
			7 : display = 7'b1111000;   //0111
			8 : display = 7'b0000000;   //1000
			9 : display = 7'b0010000;	//1001
			default : display = 7'b1111111;
    	endcase
    end
    
endmodule


module PWM_gen (
    input wire clk,
    input wire reset,
	input [31:0] freq,
    input [9:0] duty,
    output reg PWM
);

wire [31:0] count_max = 100_000_000 / freq;
wire [31:0] count_duty = count_max * duty / 1024;
reg [31:0] count;
    
always @(posedge clk, posedge reset) begin
    if (reset) begin
        count <= 0;
        PWM <= 0;
    end else if (count < count_max) begin
        count <= count + 1;
		if(count < count_duty)
            PWM <= 1;
        else
            PWM <= 0;
    end else begin
        count <= 0;
        PWM <= 0;
    end
end

endmodule


module PlayerCtrl (
	input clk,
	input reset,
	output reg [8:0] ibeat
);
parameter BEATLEAGTH = 287;

always @(posedge clk, posedge reset) begin
	if (reset)
		ibeat <= 0;
	else if (ibeat < BEATLEAGTH) 
		ibeat <= ibeat + 1;
	else 
		ibeat <= 0;
end

endmodule


module Music (
	input [8:0] ibeatNum,	
	output reg [31:0] tone
);

always @(*) begin
	case (ibeatNum)		// 1/4 beat
		8'd0 : tone = `silence;	
		8'd1 : tone = `So_l;
		8'd2 : tone = `So_l;
		8'd3 : tone = `Do;
		8'd4 : tone = `Do;	
		8'd5 : tone = `Do;
		8'd6 : tone = `Do;
		8'd7 : tone = `Mi;
		8'd8 : tone = `La;	
		8'd9 : tone = `La;
		8'd10 : tone = `La;
		8'd11 : tone = `Mi;
		8'd12 : tone = `So;	
		8'd13 : tone = `So;
		8'd14 : tone = `So;
		8'd15 : tone = `So;
		
		8'd16 : tone = `So;
		8'd17 : tone = `So;
		8'd18 : tone = `So;
		8'd19 : tone = `La;
		8'd20 : tone = `So;
		8'd21 : tone = `So;
		8'd22 : tone = `So;
		8'd23 : tone = `Mi;
		8'd24 : tone = `Fa;
		8'd25 : tone = `Fa;
		8'd26 : tone = `Fa;
		8'd27 : tone = `Mi;
		8'd28 : tone = `Re;
		8'd29 : tone = `Re;
		8'd30 : tone = `Re;
		8'd31 : tone = `Re;
		
		8'd32 : tone = `La_l;
		8'd33 : tone = `La_l;
		8'd34 : tone = `La_l;
		8'd35 : tone = `Re;
		8'd36 : tone = `Re;
		8'd37 : tone = `Re;
		8'd38 : tone = `Re;
		8'd39 : tone = `Fa;
		8'd40 : tone = `Si;
		8'd41 : tone = `Si;
		8'd42 : tone = `Si;
		8'd43 : tone = `Si;
		8'd44 : tone = `La;
		8'd45 : tone = `La;
		8'd46 : tone = `La;
		8'd47 : tone = `So;
		
		8'd48 : tone = `Fa;
		8'd49 : tone = `Fa;
		8'd50 : tone = `Fa;
		8'd51 : tone = `Fa;
		8'd52 : tone = `Fa;
		8'd53 : tone = `Fa;
		8'd54 : tone = `Fa;
		8'd55 : tone = `Mi;
		8'd56 : tone = `La_l;
		8'd57 : tone = `La_l;
		8'd58 : tone = `Si_l;
		8'd59 : tone = `Si_l;
		8'd60 : tone = `Si_l;
		8'd61 : tone = `Si_l;
		8'd62 : tone = `Si_l;
		8'd63 : tone = `Do;
		
		8'd64 : tone = `Re;
		8'd65 : tone = `Re;
		8'd66 : tone = `Re;
		8'd67 : tone = `Re;
		8'd68 : tone = `silence;
		8'd69 : tone = `silence;
		8'd70 : tone = `silence;
		8'd71 : tone = `silence;
		8'd72 : tone = `silence;
		8'd73 : tone = `silence;
		8'd74 : tone = `silence;
		8'd75 : tone = `silence;
		8'd76 : tone = `silence;
		8'd77 : tone = `silence;
		8'd78 : tone = `silence;
		8'd79 : tone = `silence;
		
		8'd80 : tone = `silence;	
        8'd81 : tone = `So_l;
        8'd82 : tone = `So_l;
        8'd83 : tone = `Do;
        8'd84 : tone = `Do;    
        8'd85 : tone = `Do;
        8'd86 : tone = `Do;
        8'd87 : tone = `Mi;
        8'd88 : tone = `La;    
        8'd89 : tone = `La;
        8'd90 : tone = `La;
        8'd91 : tone = `Mi;
        8'd92 : tone = `So;    
        8'd93 : tone = `So;
        8'd94 : tone = `So;
        8'd95 : tone = `So;
		
	    8'd96 : tone = `So;
        8'd97 : tone = `So;
        8'd98 : tone = `So;
        8'd99 : tone = `La;
        8'd100 : tone = `So;
        8'd101 : tone = `So;
        8'd102 : tone = `So;
        8'd103 : tone = `Mi;
        8'd104 : tone = `Fa;
        8'd105 : tone = `Fa;
        8'd106 : tone = `Fa;
        8'd107 : tone = `Mi;
        8'd108 : tone = `Re;
        8'd109 : tone = `Re;
        8'd110 : tone = `Re;
        8'd111 : tone = `Re;
		
		8'd112 : tone = `La_l;
        8'd113 : tone = `La_l;
        8'd114 : tone = `La_l;
        8'd115 : tone = `Re;
        8'd116 : tone = `Re;
        8'd117 : tone = `Re;
        8'd118 : tone = `Re;
        8'd119 : tone = `Fa;
        8'd120 : tone = `Si;
        8'd121 : tone = `Si;
        8'd122 : tone = `Si;
        8'd123 : tone = `Si;
        8'd124 : tone = `La;
        8'd125 : tone = `La;
        8'd126 : tone = `La;
        8'd127 : tone = `So;
		
		8'd128 : tone = `Fa;	//3
		8'd129 : tone = `Fa;
		8'd130 : tone = `Fa;
		8'd131 : tone = `Fa;
		8'd132 : tone = `Fa;	//1
		8'd133 : tone = `Fa;
		8'd134 : tone = `Fa;
		8'd135 : tone = `Mi;
		8'd136 : tone = `Si_l;	//2
		8'd137 : tone = `Si_l;
		8'd138 : tone = `Si_l;
		8'd139 : tone = `Si_l;
		8'd140 : tone = `Re;	//6
		8'd141 : tone = `Re;
		8'd142 : tone = `Re;
		8'd143 : tone = `Re;
				
		8'd144 : tone = `Do;
		8'd145 : tone = `Do;
		8'd146 : tone = `Do;
		8'd147 : tone = `Do;
		8'd148 : tone = `silence;
		8'd149 : tone = `silence;
		8'd150 : tone = `silence;
		8'd151 : tone = `silence;
		8'd152 : tone = `silence;
		8'd153 : tone = `silence;
		8'd154 : tone = `silence;
		8'd155 : tone = `silence;
		8'd156 : tone = `silence;
		8'd157 : tone = `silence;
		8'd158 : tone = `silence;
		8'd159 : tone = `silence;
		
		8'd160 : tone = `La;
		8'd161 : tone = `La;
		8'd162 : tone = `La;
		8'd163 : tone = `La;
		8'd164 : tone = `La;
		8'd165 : tone = `La;
		8'd166 : tone = `So;
		8'd167 : tone = `So;
		8'd168 : tone = `Fa;
		8'd169 : tone = `So;
		8'd170 : tone = `La;
		8'd171 : tone = `silence;
		8'd172 : tone = `So;
		8'd173 : tone = `So;
		8'd174 : tone = `So;
		8'd175 : tone = `So;
		
		8'd176 : tone = `Re;
		8'd177 : tone = `Re;
		8'd178 : tone = `Re;
		8'd179 : tone = `Mi;
		8'd180 : tone = `Fa_s;
		8'd181 : tone = `Fa_s;
		8'd182 : tone = `Fa_s;
		8'd183 : tone = `Re;
		8'd184 : tone = `So;
		8'd185 : tone = `So;
		8'd186 : tone = `So;
		8'd187 : tone = `So;
		8'd188 : tone = `silence;
		8'd189 : tone = `silence;
		8'd190 : tone = `silence;
		8'd191 : tone = `silence;
		
		8'd192 : tone = `La;
		8'd193 : tone = `La;
		8'd194 : tone = `La;
		8'd195 : tone = `La;
		8'd196 : tone = `So;
		8'd197 : tone = `So;
		8'd198 : tone = `So;
		8'd199 : tone = `So;
		8'd200 : tone = `Re;
		8'd201 : tone = `Re;
		8'd202 : tone = `Mi;
		8'd203 : tone = `Mi;
		8'd204 : tone = `Fa_s;
		8'd205 : tone = `Fa_s;
		8'd206 : tone = `Re;
		8'd207 : tone = `Re;
		
		8'd208 : tone = `So;
		8'd209 : tone = `So;
		8'd210 : tone = `So;
		8'd211 : tone = `silence;
		8'd212 : tone = `silence;
		8'd213 : tone = `silence;
		8'd214 : tone = `silence;
		8'd215 : tone = `silence;
		8'd216 : tone = `silence;
		8'd217 : tone = `silence;
		8'd218 : tone = `silence;
		8'd219 : tone = `silence;
		8'd220 : tone = `silence;
		8'd221 : tone = `silence;
		8'd222 : tone = `silence;
		8'd223 : tone = `silence;
		
		8'd224 : tone = `La;
		8'd225 : tone = `La;
		8'd226 : tone = `La;
		8'd227 : tone = `La;
		8'd228 : tone = `So;
		8'd229 : tone = `So;
		8'd230 : tone = `So;
		8'd231 : tone = `So;
		8'd232 : tone = `Fa;
		8'd233 : tone = `Fa;
		8'd234 : tone = `Fa;
		8'd235 : tone = `Fa;
		8'd236 : tone = `silence;
		8'd237 : tone = `silence;
		8'd238 : tone = `silence;
		8'd239 : tone = `silence;
		
		8'd240 : tone = `Re;
		8'd241 : tone = `Re;
		8'd242 : tone = `Re;
		8'd243 : tone = `Re;
		8'd244 : tone = `Si;
		8'd245 : tone = `Si;
		8'd246 : tone = `Si;
		8'd247 : tone = `La;
		8'd248 : tone = `So;
		8'd249 : tone = `So;
		8'd250 : tone = `So;
		8'd251 : tone = `La;
		8'd252 : tone = `So;
		8'd253 : tone = `So;
		8'd254 : tone = `So;
		8'd255 : tone = `Fa;
		
		9'd256 : tone = `silence;
        9'd257 : tone = `silence;
        9'd258 : tone = `silence;
        9'd259 : tone = `silence;
        9'd260 : tone = `So;
        9'd261 : tone = `So;
        9'd262 : tone = `So;
        9'd263 : tone = `La;
        9'd264 : tone = `Mi;
        9'd265 : tone = `Mi;
        9'd266 : tone = `Mi;
        9'd267 : tone = `silence;
        9'd268 : tone = `Re;
        9'd269 : tone = `Re;
        9'd270 : tone = `Re;
        9'd271 : tone = `Re;
        
        
        9'd272 : tone = `Do;
        9'd273 : tone = `Do;
        9'd274 : tone = `Do;
        9'd275 : tone = `Do;
        9'd276 : tone = `silence;
        9'd277 : tone = `silence;
        9'd278 : tone = `silence;
        9'd279 : tone = `silence;
        9'd280 : tone = `silence;
        9'd281 : tone = `silence;
        9'd282 : tone = `silence;
        9'd283 : tone = `silence;
        9'd284 : tone = `silence;
        9'd285 : tone = `silence;
        9'd286 : tone = `silence;
        9'd287 : tone = `silence;
       
		
		default : tone = `silence;
	endcase
end

endmodule