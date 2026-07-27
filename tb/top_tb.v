module tb_mips_core;
    reg        clk;
    reg        reset;
    wire [31:0] alu_result;
    wire [31:0] read_data_2;

    mips_core uut (
        .clk(clk),
        .reset(reset),
        .alu_result(alu_result),
        .read_data_2(read_data_2)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_mips_core);

        clk = 0;
        reset = 1;
        #10;

        reset = 0;

        // Run for 100ns to allow full program execution
        #100;

        $finish;
    end
endmodule
