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
