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
