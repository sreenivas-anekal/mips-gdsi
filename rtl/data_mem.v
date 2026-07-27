module data_mem (
    input  wire        clk,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output wire [31:0] read_data
);
    // 64 words of 32-bit RAM
    reg [31:0] ram [0:63];

    // Asynchronous Read Logic
    assign read_data = mem_read ? ram[addr[7:2]] : 32'b0;

    // Synchronous Write Logic
    always @(posedge clk) begin
        if (mem_write)
            ram[addr[7:2]] <= write_data;
    end
endmodule
