// LFCPNX-EVN Testbench

module lfcpnx_evn_tb ();

parameter CLOCK_FREQUECY = 50_000_000;
parameter CLOCK_PERIOD   = 1/CLOCK_FREQUECY;

reg  external_clock;
reg  external_resetn;
reg  uart_rx;
wire uart_tx;

lfcpnx_evn dut (
    .external_clock  (external_clock),
    .external_resetn (external_resetn),
    .uart_rx         (uart_rx),
    .uart_tx         (uart_tx)
);

initial begin
    external_clock  = 0;
    external_resetn = 0;

    @(posedge external_clock);
    @(posedge external_clock);
    @(posedge external_clock);
    external_resetn = 1;

    repeat(10000) @(posedge external_clock);
end

always #(CLOCK_PERIOD/2) external_clock = ~external_clock;

endmodule
