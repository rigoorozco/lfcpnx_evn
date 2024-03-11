// LFCPNX-EVN BRAM for picoRV

`ifndef SIM_FIRMWARE_FILE
  `define FIRMWARE_FILE "firmware.hex"
`else
  `define FIRMWARE_FILE `SIM_FIRMWARE_FILE
`endif

module bram_simple_sp #(
  parameter ADDR_WIDTH = 8
) (
    input                       clk,
    input      [ADDR_WIDTH-1:0] addr,
    input      [31:0]           din,
    input      [ 3:0]           we,
    output reg [31:0]           dout
);

reg [31:0] mem [(1<<ADDR_WIDTH)-1:0];
initial $readmemh (`FIRMWARE_FILE, mem);
    
always @(posedge clk) begin
    if (we[0]) mem[addr][ 7: 0] <= din[ 7: 0];
    if (we[1]) mem[addr][15: 8] <= din[15: 8];
    if (we[2]) mem[addr][23:16] <= din[23:16];
    if (we[3]) mem[addr][31:24] <= din[31:24];

    dout <= mem[addr];
end

endmodule
