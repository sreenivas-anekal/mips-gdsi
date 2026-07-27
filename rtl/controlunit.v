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
        // Default values (prevents unintended latches)
        {reg_dst, reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, jump} = 8'b0;
        alu_ctrl = 3'b000;

        case (opcode)
            6'b000000: begin // R-Type Instructions
                reg_dst = 1; 
                reg_write = 1;
                case (funct)
                    6'b100000: alu_ctrl = 3'b010; // ADD
                    6'b100010: alu_ctrl = 3'b110; // SUB
                    6'b100100: alu_ctrl = 3'b000; // AND
                    6'b100101: alu_ctrl = 3'b001; // OR
                    6'b101010: alu_ctrl = 3'b111; // SLT (Set on Less Than)
                    default:   alu_ctrl = 3'b000;
                endcase
            end
            6'b100011: begin // LW (Load Word)
                alu_src = 1; mem_to_reg = 1; reg_write = 1; mem_read = 1; alu_ctrl = 3'b010;
            end
            6'b101011: begin // SW (Store Word)
                alu_src = 1; mem_write = 1; alu_ctrl = 3'b010;
            end
            6'b000100: begin // BEQ (Branch Equal)
                branch = 1; alu_ctrl = 3'b110; // Uses SUB logic to check zero flag
            end
            6'b001000: begin // ADDI (Add Immediate)
                alu_src = 1; reg_write = 1; alu_ctrl = 3'b010;
            end
            6'b000010: begin // J (Jump)
                jump = 1;
            end
            default: ;
        endcase
    end
endmodule
