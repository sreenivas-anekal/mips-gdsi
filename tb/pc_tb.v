module tb_pc;
    reg        clk;
    reg        reset;
    reg  [31:0] pc_next;
    wire [31:0] pc;

    // Instantiate ONLY the Program Counter module
    pc uut (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc(pc)
    );

    // Generate a 10ns Clock (5ns HIGH, 5ns LOW)
    always #5 clk = ~clk;

    initial begin
        // Mandatory for EDA Playground waveform generation
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_pc);

        // 1. Initialize Signals & Apply Reset
        clk = 0;
        reset = 1;
        pc_next = 32'h0000_0004;
        #10; // Wait 1 clock cycle under reset

        // 2. Release Reset and apply next PC values
        reset = 0;
        #10;
        
        pc_next = 32'h0000_0008;
        #10;

        pc_next = 32'h0000_000C;
        #10;

        // 3. Test Mid-Execution Asynchronous Reset
        reset = 1;
        #5;  // Assert reset mid-cycle
        reset = 0;
        #15;

        $finish;
    end
endmodule
