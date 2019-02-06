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
