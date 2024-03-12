// LFCPNX-EVN Top Level

module lfcpnx_evn (
    input         external_clock,

`ifdef SIM
    output [35:0] trace_data,
    output        trace_valid,
    output        trap,
`endif

    input         uart_rx,
    output        uart_tx
);

wire        clock_62M5;

pll_div div (
    .clki_i  (external_clock),
    .rstn_i  (1),
    .clkop_o (clock_62M5),
    .lock_o  (/*open*/)
);

wire        resetn;

power_on_reset por (
    .clk    (clock_62M5),
    .resetn (resetn)
);

wire        picosoc_clk;
wire        picosoc_resetn;
wire        picosoc_trap;

wire        picosoc_ser_tx;
wire        picosoc_ser_rx;

wire [31:0] picosoc_irq;
wire [31:0] picosoc_eoi;

wire        picosoc_trace_valid;
wire [35:0] picosoc_trace_data;

picosoc_lfcpnx #(
    .CLOCK_RATE (62_500_000),
    .UART_BAUD  (921_000)
) picosoc (
    .clk          (picosoc_clk),
    .resetn       (picosoc_resetn),
    .trap         (picosoc_trap),
    .ser_tx       (picosoc_ser_tx),
    .ser_rx       (picosoc_ser_rx),
    .irq          (picosoc_irq),
    .eoi          (picosoc_eoi),
    .trace_valid  (picosoc_trace_valid),
    .trace_data   (picosoc_trace_data)
);

// IRQ generation for test
reg [31:0] test_irq = 0;
reg [15:0] count_cycle = 0;

always @(posedge clock_62M5)
    count_cycle <= resetn ? count_cycle + 1 : 0;

always @* begin
    test_irq = 0;
    test_irq[4] = &count_cycle[12:0];
    test_irq[5] = &count_cycle[15:0];
end

assign uart_tx           = picosoc_ser_tx;
assign picosoc_ser_rx    = uart_rx;

// Inputs that need to be driven
assign picosoc_clk       = clock_62M5;
assign picosoc_resetn    = resetn;
assign picosoc_irq       = test_irq;

`ifdef SIM
assign trace_data  = picosoc_trace_data;
assign trace_valid = picosoc_trace_valid;
assign trap        = picosoc_trap;
`endif

endmodule
