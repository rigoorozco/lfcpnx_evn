// Generate a reset pulse at start up

module power_on_reset #(
    parameter CYCLE_COUNT = 200
) (
    input  clk,
    output resetn
);

localparam CYCLE_COUNT_WIDTH = $clog2(CYCLE_COUNT);

reg [CYCLE_COUNT_WIDTH-1:0] count = CYCLE_COUNT;
reg resetn_int = 0;;

always @(posedge clk) begin
    if (count > 0) begin
        count  <= count - 1;
        resetn_int <= 0;
    end
    else begin
        resetn_int <= 1;
    end
end

assign resetn = resetn_int;

endmodule
