// 1. Program Counter
module pc (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] pc_next,
    output reg  [31:0] pc
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'h0000_0000;
        else
            pc <= pc_next;
    end
endmodule

// 2. Instruction Memory
module instruction_mem (
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] rom [0:63];
    assign instr = rom[addr[7:2]];

    initial begin
        rom[0] = 32'h20010005; // addi $1, $0, 5     ($1 = 5)
        rom[1] = 32'h2002000A; // addi $2, $0, 10    ($2 = 10)
        rom[2] = 32'h00221820; // add  $3, $1, $2    ($3 = 15)
        rom[3] = 32'h10600001; // beq  $3, $0, 1     (Branch not taken)
        rom[4] = 32'h00622022; // sub  $4, $3, $2    ($4 = 5)
        rom[5] = 32'h08000005; // j    5             (Jump)
    end
endmodule

// 3. Register File
module register_file (
    input  wire        clk,
    input  wire        reg_write,
    input  wire [4:0]  rs,
    input  wire [4:0]  rt,
    input  wire [4:0]  write_reg,
    input  wire [31:0] write_data,
    output wire [31:0] read_data_1,
    output wire [31:0] read_data_2
);
    reg [31:0] registers [0:31];
    assign read_data_1 = (rs == 5'b0) ? 32'b0 : registers[rs];
    assign read_data_2 = (rt == 5'b0) ? 32'b0 : registers[rt];

    always @(posedge clk) begin
        if (reg_write && (write_reg != 5'b0)) begin
            registers[write_reg] <= write_data;
        end
    end
endmodule

// 4. Control Unit
module control_unit (
    input  wire [5:0] opcode,
    input  wire [5:0] funct,
    output reg        reg_dst,
    output reg        reg_write,
    output reg        alu_src,
    output reg        mem_read,
    output reg        mem_write,
    output reg        mem_to_reg,
    output reg        branch,
    output reg        jump,
    output reg  [2:0] alu_ctrl
);
    always @(*) begin
        {reg_dst, reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, jump} = 8'b0;
        alu_ctrl = 3'b000;

        case (opcode)
            6'b000000: begin // R-Type
                reg_dst = 1; reg_write = 1;
                case (funct)
                    6'b100000: alu_ctrl = 3'b010; // ADD
                    6'b100010: alu_ctrl = 3'b110; // SUB
                    6'b100100: alu_ctrl = 3'b000; // AND
                    6'b100101: alu_ctrl = 3'b001; // OR
                    6'b101010: alu_ctrl = 3'b111; // SLT
                    default:   alu_ctrl = 3'b000;
                endcase
            end
            6'b100011: begin // LW
                alu_src = 1; mem_to_reg = 1; reg_write = 1; mem_read = 1; alu_ctrl = 3'b010;
            end
            6'b101011: begin // SW
                alu_src = 1; mem_write = 1; alu_ctrl = 3'b010;
            end
            6'b000100: begin // BEQ
                branch = 1; alu_ctrl = 3'b110;
            end
            6'b001000: begin // ADDI
                alu_src = 1; reg_write = 1; alu_ctrl = 3'b010;
            end
            6'b000010: begin // J
                jump = 1;
            end
            default: ;
        endcase
    end
endmodule

// 5. ALU
module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [2:0]  alu_ctrl,
    output reg  [31:0] result,
    output wire        zero
);
    always @(*) begin
        case (alu_ctrl)
            3'b000: result = a & b;                      // AND
            3'b001: result = a | b;                      // OR
            3'b010: result = a + b;                      // ADD
            3'b110: result = a - b;                      // SUB
            3'b111: result = (a < b) ? 32'b1 : 32'b0;    // SLT
            default: result = 32'b0;
        endcase
    end
    assign zero = (result == 32'b0);
endmodule

// 6. Data Memory
module data_mem (
    input  wire        clk,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output wire [31:0] read_data
);
    reg [31:0] ram [0:63];
    assign read_data = mem_read ? ram[addr[7:2]] : 32'b0;

    always @(posedge clk) begin
        if (mem_write)
            ram[addr[7:2]] <= write_data;
    end
endmodule

// 7. Top-Level MIPS Core Wrapper
module mips_core (
    input  wire        clk,
    input  wire        reset,
    output wire [31:0] alu_result,
    output wire [31:0] read_data_2
);
    wire [31:0] pc, pc_next, pc_plus_4, instr;
    wire reg_dst, reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, jump, zero_flag;
    wire [2:0] alu_ctrl;
    wire [31:0] reg_read1, reg_read2_wire, mem_read_data;

    assign pc_plus_4 = pc + 32'd4;

    pc pc_inst (
        .clk(clk), .reset(reset), .pc_next(pc_next), .pc(pc)
    );

    instruction_mem imem_inst (
        .addr(pc), .instr(instr)
    );

    control_unit ctrl_inst (
        .opcode(instr[31:26]), .funct(instr[5:0]),
        .reg_dst(reg_dst), .reg_write(reg_write), .alu_src(alu_src),
        .mem_read(mem_read), .mem_write(mem_write), .mem_to_reg(mem_to_reg),
        .branch(branch), .jump(jump), .alu_ctrl(alu_ctrl)
    );

    wire [4:0]  write_reg   = reg_dst ? instr[15:11] : instr[20:16];
    wire [31:0] write_data  = mem_to_reg ? mem_read_data : alu_result;

    register_file rf_inst (
        .clk(clk), .reg_write(reg_write),
        .rs(instr[25:21]), .rt(instr[20:16]),
        .write_reg(write_reg), .write_data(write_data),
        .read_data_1(reg_read1), .read_data_2(reg_read2_wire)
    );

    wire [31:0] sign_ext_imm = {{16{instr[15]}}, instr[15:0]};
    wire [31:0] alu_operand2 = alu_src ? sign_ext_imm : reg_read2_wire;

    alu alu_inst (
        .a(reg_read1), .b(alu_operand2),
        .alu_ctrl(alu_ctrl), .result(alu_result), .zero(zero_flag)
    );

    data_mem dmem_inst (
        .clk(clk), .mem_read(mem_read), .mem_write(mem_write),
        .addr(alu_result), .write_data(reg_read2_wire),
        .read_data(mem_read_data)
    );

    wire [31:0] branch_target = pc_plus_4 + (sign_ext_imm << 2);
    wire [31:0] jump_addr     = {pc_plus_4[31:28], instr[25:0], 2'b00};
    
    assign pc_next = jump ? jump_addr :
                     (branch && zero_flag) ? branch_target : pc_plus_4;

    assign read_data_2 = reg_read2_wire;
endmodule
