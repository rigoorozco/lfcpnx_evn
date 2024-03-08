// LFCPNX-EVN picoRV32 SoC

module picosoc_lfcpnx #(
	parameter [ 0:0] ENABLE_COUNTERS      = 1,
	parameter [ 0:0] ENABLE_COUNTERS64    = 1,
	parameter [ 0:0] ENABLE_REGS_16_31    = 1,
	parameter [ 0:0] ENABLE_REGS_DUALPORT = 1,
	parameter [ 0:0] TWO_STAGE_SHIFT      = 1,
	parameter [ 0:0] BARREL_SHIFTER       = 0,
	parameter [ 0:0] TWO_CYCLE_COMPARE    = 0,
	parameter [ 0:0] TWO_CYCLE_ALU        = 0,
	parameter [ 0:0] COMPRESSED_ISA       = 0,
	parameter [ 0:0] CATCH_MISALIGN       = 1,
	parameter [ 0:0] CATCH_ILLINSN        = 1,
	parameter [ 0:0] ENABLE_PCPI          = 0,
	parameter [ 0:0] ENABLE_MUL           = 1,
	parameter [ 0:0] ENABLE_FAST_MUL      = 0,
	parameter [ 0:0] ENABLE_DIV           = 1,
	parameter [ 0:0] ENABLE_IRQ           = 1,
	parameter [ 0:0] ENABLE_IRQ_QREGS     = 1,
	parameter [ 0:0] ENABLE_IRQ_TIMER     = 1,
	parameter [ 0:0] ENABLE_TRACE         = 1,
	parameter [ 0:0] REGS_INIT_ZERO       = 0,
	parameter [31:0] MASKED_IRQ           = 32'h0000_0000,
	parameter [31:0] LATCHED_IRQ          = 32'hffff_ffff,
	parameter [31:0] PROGADDR_RESET       = 32'h0000_0000,
	parameter [31:0] PROGADDR_IRQ         = 32'h0000_0010,
	parameter [31:0] STACKADDR            = 32'hffff_ffff
) (
    input         clk,
    input         resetn,
	output        trap,

	output        ser_tx,
	input         ser_rx,

    input  [31:0] irq,
	output [31:0] eoi,

    output        trace_valid,
	output [35:0] trace_data
);

localparam MEM_WORDS = 65536;

wire        mem_valid;
wire [31:0] mem_addr;
wire [31:0] mem_wdata;
wire [ 3:0] mem_wstrb;
wire        mem_instr;
wire        mem_ready;
wire [31:0] mem_rdata;

wire        mem_la_read;
wire        mem_la_write;
wire [31:0] mem_la_addr;
wire [31:0] mem_la_wdata;
wire [ 3:0] mem_la_wstrb;

picorv32 #(
    .ENABLE_COUNTERS     (ENABLE_COUNTERS     ),
    .ENABLE_COUNTERS64   (ENABLE_COUNTERS64   ),
    .ENABLE_REGS_16_31   (ENABLE_REGS_16_31   ),
    .ENABLE_REGS_DUALPORT(ENABLE_REGS_DUALPORT),
    .TWO_STAGE_SHIFT     (TWO_STAGE_SHIFT     ),
    .BARREL_SHIFTER      (BARREL_SHIFTER      ),
    .TWO_CYCLE_COMPARE   (TWO_CYCLE_COMPARE   ),
    .TWO_CYCLE_ALU       (TWO_CYCLE_ALU       ),
    .COMPRESSED_ISA      (COMPRESSED_ISA      ),
    .CATCH_MISALIGN      (CATCH_MISALIGN      ),
    .CATCH_ILLINSN       (CATCH_ILLINSN       ),
    .ENABLE_PCPI         (ENABLE_PCPI         ),
    .ENABLE_MUL          (ENABLE_MUL          ),
    .ENABLE_FAST_MUL     (ENABLE_FAST_MUL     ),
    .ENABLE_DIV          (ENABLE_DIV          ),
    .ENABLE_IRQ          (ENABLE_IRQ          ),
    .ENABLE_IRQ_QREGS    (ENABLE_IRQ_QREGS    ),
    .ENABLE_IRQ_TIMER    (ENABLE_IRQ_TIMER    ),
    .ENABLE_TRACE        (ENABLE_TRACE        ),
    .REGS_INIT_ZERO      (REGS_INIT_ZERO      ),
    .MASKED_IRQ          (MASKED_IRQ          ),
    .LATCHED_IRQ         (LATCHED_IRQ         ),
    .PROGADDR_RESET      (PROGADDR_RESET      ),
    .PROGADDR_IRQ        (PROGADDR_IRQ        ),
    .STACKADDR           (STACKADDR           )
) picorv32_core (
    .clk                 (clk),
    .resetn              (resetn),
    .trap                (trap),
    .mem_valid           (mem_valid),
    .mem_addr            (mem_addr),
    .mem_wdata           (mem_wdata),
    .mem_wstrb           (mem_wstrb),
    .mem_instr           (mem_instr),
    .mem_ready           (mem_ready),
    .mem_rdata           (mem_rdata),
    .mem_la_read         (mem_la_read),
    .mem_la_write        (mem_la_write),
    .mem_la_addr         (mem_la_addr),
    .mem_la_wdata        (mem_la_wdata),
    .mem_la_wstrb        (mem_la_wstrb),
    .irq                 (irq),
    .eoi                 (eoi),
    .trace_valid         (trace_valid),
    .trace_data          (trace_data)
);

wire        ram_clk;
wire [15:0] ram_addr;
wire [31:0] ram_din;
wire [ 3:0] ram_we;
wire [31:0] ram_dout;

bram_simple_sp #(
    .ADDR_WIDTH (16)
) ram (
    .clk  (ram_clk),
    .addr (ram_addr),
    .din  (ram_din),
    .we   (ram_we),
    .dout (ram_dout)
);

wire        uart_clk;
wire        uart_resetn;
wire        uart_ser_tx;
wire        uart_ser_rx;

wire  [3:0] uart_reg_div_we;
wire [31:0] uart_reg_div_di;
wire [31:0] uart_reg_div_do;

wire        uart_reg_dat_we;
wire        uart_reg_dat_re;
wire [31:0] uart_reg_dat_di;
wire [31:0] uart_reg_dat_do;
wire        uart_reg_dat_wait;

simpleuart uart (
    .clk         (uart_clk),
    .resetn      (uart_resetn),
    .ser_tx      (uart_ser_tx),
    .ser_rx      (uart_ser_rx),
    .reg_div_we  (uart_reg_div_we),
    .reg_div_di  (uart_reg_div_di),
    .reg_div_do  (uart_reg_div_do),
    .reg_dat_we  (uart_reg_dat_we),
    .reg_dat_re  (uart_reg_dat_re),
    .reg_dat_di  (uart_reg_dat_di),
    .reg_dat_do  (uart_reg_dat_do),
    .reg_dat_wait(uart_reg_dat_wait)
);

wire uart_reg_div_sel = mem_valid && (mem_addr == 32'h0200_0004);
wire uart_reg_dat_sel = mem_valid && (mem_addr == 32'h0200_0008);

reg ram_ready;

always @(posedge clk)
    ram_ready <= mem_valid && !mem_ready && mem_addr < 4*MEM_WORDS;

// Drive picoRV inputs
assign mem_ready = ram_ready ||
    uart_reg_div_sel || (uart_reg_dat_sel && !uart_reg_dat_wait);

assign mem_rdata =
    ram_ready ? ram_dout :
    uart_reg_div_sel ? uart_reg_div_do :
    uart_reg_dat_sel ? uart_reg_dat_do :
    32'h0000_0000;

// Drive BRAM inputs
assign ram_clk  = clk;
assign ram_addr = mem_la_addr[17:2];
assign ram_din  = mem_la_wdata;
assign ram_we   = mem_la_wstrb;

// Drive UART inputs
assign uart_clk        = clk;
assign uart_resetn     = resetn;
assign uart_ser_rx     = ser_rx;
assign uart_reg_div_we = uart_reg_div_sel ? mem_wstrb : 4'b0000;
assign uart_reg_div_di = mem_wdata;
assign uart_reg_dat_we = uart_reg_dat_sel ? mem_wstrb[0] : 1'b0;
assign uart_reg_dat_re = uart_reg_dat_sel && !mem_wstrb;
assign uart_reg_dat_di = mem_wdata;

// Drive top-level outputs
assign ser_tx = uart_ser_tx;

endmodule
