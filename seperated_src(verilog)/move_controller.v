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
