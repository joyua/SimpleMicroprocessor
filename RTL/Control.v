`timescale 1ns / 1ps
/**
 * Control Module (Improved Version)
 * Opcode를 해독하여 제어 신호를 생성하는 순수 해독기(Decoder) 모듈.
 * FSM 상태(pst)로부터 독립되어 재사용성과 모듈성이 향상되었습니다.
 */
module Control(
    input clk, rst,
    input [3:0] Opcode,      // 해독할 4비트 Opcode

    output reg [3:0] ALU_Op, // ALU 연산 동작 제어 신호
    output reg ALU_Src,      // ALU Input2 소스 선택 제어 신호
    output reg Reg_Write     // Register 쓰기 허가 제어 신호
);

    // 명령어 Opcode 정의
    parameter NOP   = 4'h0, WRITE = 4'h1, READ  = 4'h2, COPY  = 4'h3,
              NOT_OP= 4'h4, AND_OP= 4'h5, OR_OP = 4'h6, XOR_OP= 4'h7,
              NAND_OP=4'h8, NOR_OP= 4'h9, ADD   = 4'hA, SUB   = 4'hB,
              ADDI  = 4'hC, SUBI  = 4'hD, SLL   = 4'hE, SRL   = 4'hF;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // 리셋 시 모든 제어 신호 비활성화
            ALU_Op    <= 4'h0;
            Reg_Write <= 1'b0;
            ALU_Src   <= 1'b0;
        end else begin
            // FSM 상태(pst)와 관계없이 항상 Opcode를 해독하여
            // 그에 맞는 제어 신호를 출력합니다.
            case (Opcode)
                NOP: begin
                    Reg_Write <= 1'b0; // Write 안함
                    ALU_Src   <= 1'b0;
                    ALU_Op    <= NOP;
                end
                WRITE: begin
                    Reg_Write <= 1'b1;
                    ALU_Src   <= 1'b1; // Rd2 필드를 Data로 사용
                    ALU_Op    <= WRITE;
                end
                READ: begin
                    Reg_Write <= 1'b0; // Write 안함
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
                // R-Type 명령어 그룹
                AND_OP, OR_OP, XOR_OP, NAND_OP, NOR_OP, ADD, SUB: begin
                    Reg_Write <= 1'b1;
                    ALU_Src   <= 1'b0; // Register 값 사용
                    ALU_Op    <= Opcode;
                end
                // I-Type 명령어 그룹
                ADDI, SUBI, SLL, SRL: begin
                    Reg_Write <= 1'b1;
                    ALU_Src   <= 1'b1; // Rd2 필드를 Data로 사용
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
