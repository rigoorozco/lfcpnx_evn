// LFCPNX-EVN BRAM for picoRV

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
// initial $readmemh ("ram.hex", mem);
    
always @(posedge clk) begin
    if (we[0]) mem[addr] <= din[ 7: 0];
    if (we[1]) mem[addr] <= din[15: 8];
    if (we[2]) mem[addr] <= din[23:16];
    if (we[3]) mem[addr] <= din[31:24];

    dout <= mem[addr];
end

endmodule
