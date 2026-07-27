module tb_register_file;
    reg        clk;
    reg        reg_write;
    reg  [4:0] rs, rt, write_reg;
    reg  [31:0] write_data;
    wire [31:0] read_data_1, read_data_2;

    // Instantiate Register File alone
    register_file uut (
        .clk(clk),
        .reg_write(reg_write),
        .rs(rs),
        .rt(rt),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_register_file);

        clk = 0; reg_write = 0; rs = 0; rt = 0; write_reg = 0; write_data = 0;
        #10;

        // 1. Write 0xDEADBEEF into Register $1
        write_reg = 5'd1; write_data = 32'hDEADBEEF; reg_write = 1;
        #10; // Wait for clock edge

        // 2. Write 0xCAFEBABE into Register $2
        write_reg = 5'd2; write_data = 32'hCAFEBABE; reg_write = 1;
        #10;

        // 3. Read back $1 on read_data_1 and $2 on read_data_2
        reg_write = 0;
        rs = 5'd1; rt = 5'd2;
        #10;

        // 4. Try writing 0xFFFFFFFF to $0 (Should be ignored)
        write_reg = 5'd0; write_data = 32'hFFFFFFFF; reg_write = 1;
        #10;

        // 5. Read back $0 (Should read 0)
        reg_write = 0;
        rs = 5'd0;
        #10;

        $finish;
    end
endmodule
