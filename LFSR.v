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
