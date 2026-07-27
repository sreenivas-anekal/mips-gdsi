module tb_data_mem;
    reg        clk;
    reg        mem_read;
    reg        mem_write;
    reg  [31:0] addr;
    reg  [31:0] write_data;
    wire [31:0] read_data;

    data_mem uut (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr(addr),
        .write_data(write_data),
        .read_data(read_data)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_data_mem);

        clk = 0; mem_read = 0; mem_write = 0; addr = 0; write_data = 0;
        #10;

        // 1. Store Word (SW): Write 0xABCD1234 to Address 0x04
        addr = 32'h0000_0004; write_data = 32'hABCD_1234; mem_write = 1;
        #10; // Latch on clock edge

        // 2. Clear write signal
        mem_write = 0;
        #10;

        // 3. Load Word (LW): Read back from Address 0x04
        mem_read = 1;
        #10;

        $finish;
    end
endmodule
