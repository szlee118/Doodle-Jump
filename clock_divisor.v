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
