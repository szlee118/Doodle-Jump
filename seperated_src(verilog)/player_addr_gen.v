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
