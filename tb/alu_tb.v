module tb_alu;
    reg  [31:0] a, b;
    reg  [2:0]  alu_ctrl;
    wire [31:0] result;
    wire        zero;

    alu uut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_alu);

        // Inputs: A = 15, B = 10
        a = 32'd15; b = 32'd10;

        // 1. ADD (15 + 10 = 25 / 0x19)
        alu_ctrl = 3'b010;
        #10;

        // 2. SUB (15 - 10 = 5)
        alu_ctrl = 3'b110;
        #10;

        // 3. AND (15 & 10 -> 0x0F & 0x0A = 0x0A / 10)
        alu_ctrl = 3'b000;
        #10;

        // 4. Test Zero Flag with Subtraction (15 - 15 = 0 -> zero = 1)
        b = 32'd15;
        alu_ctrl = 3'b110;
        #10;

        $finish;
    end
endmodule
