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
