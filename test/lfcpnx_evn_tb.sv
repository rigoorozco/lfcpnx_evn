// LFCPNX-EVN Testbench

`timescale 1ns/1ns

module lfcpnx_evn_tb ();

parameter CLOCK_FREQUECY = 50_000_000;
parameter CLOCK_PERIOD   = 1000000000.0/CLOCK_FREQUECY;

reg  external_clock;
reg  external_resetn;
reg  uart_rx;
wire uart_tx;

wire [35:0] trace_data;
wire        trace_valid;
wire        trap;

integer     trace_file;

lfcpnx_evn dut (
    .external_clock  (external_clock),
    .external_resetn (external_resetn),
    .trace_data      (trace_data),
    .trace_valid     (trace_valid),
    .trap            (trap),
    .uart_rx         (uart_rx),
    .uart_tx         (uart_tx)
);

initial begin
    external_clock  = 0;
    external_resetn = 0;

    uart_rx = 0;

    repeat(1000) @(posedge external_clock);
    external_resetn = 1;

    repeat(1000000) @(posedge external_clock);

    $stop(0);
end

initial begin
    trace_file = $fopen("testbench.trace", "w");
    repeat (10) @(posedge external_clock);
    while (!trap) begin
        @(posedge external_clock);
        if (trace_valid)
            $fwrite(trace_file, "%x\n", trace_data);
    end
    $fclose(trace_file);
    $display("Finished writing testbench.trace.");
end

always #(CLOCK_PERIOD/2.0) external_clock = ~external_clock;

endmodule
