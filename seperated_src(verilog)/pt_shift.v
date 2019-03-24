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
