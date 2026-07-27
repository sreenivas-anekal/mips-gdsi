module register_file (
    input  wire        clk,
    input  wire        reg_write,
    input  wire [4:0]  rs,          // Read Register 1 Specifier
    input  wire [4:0]  rt,          // Read Register 2 Specifier
    input  wire [4:0]  write_reg,   // Write Register Specifier
    input  wire [31:0] write_data,  // Data to Write
    output wire [31:0] read_data_1, // Output of rs
    output wire [31:0] read_data_2  // Output of rt
);
    // 32 registers, each 32-bits wide
    reg [31:0] registers [0:31];

    // Asynchronous Read Ports ($0 is always 0)
    assign read_data_1 = (rs == 5'b0) ? 32'b0 : registers[rs];
    assign read_data_2 = (rt == 5'b0) ? 32'b0 : registers[rt];

    // Synchronous Write Port (Ignores writes to $0)
    always @(posedge clk) begin
        if (reg_write && (write_reg != 5'b0)) begin
            registers[write_reg] <= write_data;
        end
    end
endmodule
