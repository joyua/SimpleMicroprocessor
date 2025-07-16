`timescale 1ns / 1ps

//================================================================
// ALU Module (Unsigned Arithmetic Optimized Version)
// - ����ġ �Է��� ����� �����ϴٴ� ���� �ݿ��Ͽ�, ��� ��� ������
//   Unsigned �������� ����ȭ�ϰ� Overflow/Underflow ������
//   �ܼ�ȭ�� ���� �����Դϴ�.
//================================================================
module ALU(
    input clk, rst,

    // From Control
    input [3:0] ALU_Op,

    // From Register / MUX
    input [3:0] in1, // Read_data1
    input [3:0] in2, // Read_data2 or Immediate

    // To Register / IO
    output reg [3:0] ALU_Result,
    output reg overflow,
    output reg underflow
);

    // ��ɾ� Opcode ����
    parameter NOP   = 4'h0, WRITE = 4'h1, READ  = 4'h2, COPY  = 4'h3,
              NOT_OP= 4'h4, AND_OP= 4'h5, OR_OP = 4'h6, XOR_OP= 4'h7,
              NAND_OP=4'h8, NOR_OP= 4'h9, ADD   = 4'hA, SUB   = 4'hB,
              ADDI  = 4'hC, SUBI  = 4'hD, SLL   = 4'hE, SRL   = 4'hF;

    // ������ ���� 5��Ʈ Ȯ�� ��������
    reg [4:0] result_extended;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ALU_Result <= 4'h0;
            overflow   <= 1'b0;
            underflow  <= 1'b0;
        end else begin
            // ���� �� �Ź� �ʱ�ȭ
            overflow   <= 1'b0;
            underflow  <= 1'b0;

            case (ALU_Op)
                // --- �⺻ �� �� ���� ---
                NOP:     ALU_Result <= ALU_Result;
                WRITE:   ALU_Result <= in2;
                READ:    ALU_Result <= in1;
                COPY:    ALU_Result <= in1;
                NOT_OP:  ALU_Result <= ~in1;
                AND_OP:  ALU_Result <= in1 & in2;
                OR_OP:   ALU_Result <= in1 | in2;
                XOR_OP:  ALU_Result <= in1 ^ in2;
                NAND_OP: ALU_Result <= ~(in1 & in2);
                NOR_OP:  ALU_Result <= ~(in1 | in2);

                // --- ��� ���� (Unsigned ����ȭ ����) ---
                ADD, ADDI: begin
                    // 0���� Ȯ���Ͽ� 5��Ʈ ���� ����
                    result_extended = {1'b0, in1} + {1'b0, in2};
                    // 5��° ��Ʈ(carry-out)�� 1�̸� �����÷ο�
                    if (result_extended[4]) begin
                        overflow <= 1'b1;
                    end
                    ALU_Result <= result_extended[3:0];
                end
                SUB, SUBI: begin
                    // 0���� Ȯ���Ͽ� 5��Ʈ ���� ����
                    result_extended = {1'b0, in1} - {1'b0, in2};
                    // 5��° ��Ʈ(borrow)�� 1�̸� ����÷ο�
                    if (result_extended[4]) begin
                        underflow <= 1'b1;
                    end
                    ALU_Result <= result_extended[3:0];
                end

                // --- ����Ʈ ���� ---
                SLL: ALU_Result <= in1 << in2;
                SRL: ALU_Result <= in1 >> in2;

                default: ALU_Result <= 4'hF; // ���ǵ��� ���� Opcode
            endcase
        end
    end
endmodule
