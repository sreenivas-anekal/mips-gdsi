module tb_control_unit;
    reg  [5:0] opcode, funct;
    wire       reg_dst, reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, jump;
    wire [2:0] alu_ctrl;

    control_unit uut (
        .opcode(opcode),
        .funct(funct),
        .reg_dst(reg_dst),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump),
        .alu_ctrl(alu_ctrl)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_control_unit);

        // 1. Test R-Type ADD (Opcode = 0x00, Funct = 0x20)
        opcode = 6'b000000; funct = 6'b100000;
        #10;

        // 2. Test LW (Opcode = 0x23) -> Expect reg_write=1, alu_src=1, mem_read=1
        opcode = 6'b100011; funct = 6'b000000;
        #10;

        // 3. Test BEQ (Opcode = 0x04) -> Expect branch=1, alu_ctrl=3'b110 (SUB)
        opcode = 6'b000100; funct = 6'b000000;
        #10;

        // 4. Test Jump (Opcode = 0x02) -> Expect jump=1
        opcode = 6'b000010; funct = 6'b000000;
        #10;

        $finish;
    end
endmodule
