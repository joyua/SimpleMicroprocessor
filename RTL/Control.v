`timescale 1ns / 1ps
/**
 * Control Module (Improved Version)
 * Opcode�� �ص��Ͽ� ���� ��ȣ�� �����ϴ� ���� �ص���(Decoder) ���.
 * FSM ����(pst)�κ��� �����Ǿ� ���뼺�� ��⼺�� ���Ǿ����ϴ�.
 */
module Control(
    input clk, rst,
    input [3:0] Opcode,      // �ص��� 4��Ʈ Opcode

    output reg [3:0] ALU_Op, // ALU ���� ���� ���� ��ȣ
    output reg ALU_Src,      // ALU Input2 �ҽ� ���� ���� ��ȣ
    output reg Reg_Write     // Register ���� �㰡 ���� ��ȣ
);

    // ��ɾ� Opcode ����
    parameter NOP   = 4'h0, WRITE = 4'h1, READ  = 4'h2, COPY  = 4'h3,
              NOT_OP= 4'h4, AND_OP= 4'h5, OR_OP = 4'h6, XOR_OP= 4'h7,
              NAND_OP=4'h8, NOR_OP= 4'h9, ADD   = 4'hA, SUB   = 4'hB,
              ADDI  = 4'hC, SUBI  = 4'hD, SLL   = 4'hE, SRL   = 4'hF;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // ���� �� ��� ���� ��ȣ ��Ȱ��ȭ
            ALU_Op    <= 4'h0;
            Reg_Write <= 1'b0;
            ALU_Src   <= 1'b0;
        end else begin
            // FSM ����(pst)�� ������� �׻� Opcode�� �ص��Ͽ�
            // �׿� �´� ���� ��ȣ�� ����մϴ�.
            case (Opcode)
                NOP: begin
                    Reg_Write <= 1'b0; // Write ����
                    ALU_Src   <= 1'b0;
                    ALU_Op    <= NOP;
                end
                WRITE: begin
                    Reg_Write <= 1'b1;
                    ALU_Src   <= 1'b1; // Rd2 �ʵ带 Data�� ���
                    ALU_Op    <= WRITE;
                end
                READ: begin
                    Reg_Write <= 1'b0; // Write ����
                    ALU_Src   <= 1'b0;
                    ALU_Op    <= READ;
                end
                COPY: begin
                    Reg_Write <= 1'b1;
                    ALU_Src   <= 1'b0;
                    ALU_Op    <= COPY;
                end
                NOT_OP: begin
                    Reg_Write <= 1'b1;
                    ALU_Src   <= 1'b0;
                    ALU_Op    <= NOT_OP;
                end
                // R-Type ��ɾ� �׷�
                AND_OP, OR_OP, XOR_OP, NAND_OP, NOR_OP, ADD, SUB: begin
                    Reg_Write <= 1'b1;
                    ALU_Src   <= 1'b0; // Register �� ���
                    ALU_Op    <= Opcode;
                end
                // I-Type ��ɾ� �׷�
                ADDI, SUBI, SLL, SRL: begin
                    Reg_Write <= 1'b1;
                    ALU_Src   <= 1'b1; // Rd2 �ʵ带 Data�� ���
                    ALU_Op    <= Opcode;
                end
                default: begin
                    ALU_Op    <= 4'h0;
                    Reg_Write <= 1'b0;
                    ALU_Src   <= 1'b0;
                end
            endcase
        end
    end
endmodule
