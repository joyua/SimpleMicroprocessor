`timescale 1ns / 1ps

//================================================================
// ALU Module (Unsigned Arithmetic Optimized Version)
// - 스위치 입력은 양수만 가능하다는 점을 반영하여, 모든 산술 연산을
//   Unsigned 기준으로 최적화하고 Overflow/Underflow 로직을
//   단순화한 최종 버전입니다.
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

    // 명령어 Opcode 정의
    parameter NOP   = 4'h0, WRITE = 4'h1, READ  = 4'h2, COPY  = 4'h3,
              NOT_OP= 4'h4, AND_OP= 4'h5, OR_OP = 4'h6, XOR_OP= 4'h7,
              NAND_OP=4'h8, NOR_OP= 4'h9, ADD   = 4'hA, SUB   = 4'hB,
              ADDI  = 4'hC, SUBI  = 4'hD, SLL   = 4'hE, SRL   = 4'hF;

    // 연산을 위한 5비트 확장 레지스터
    reg [4:0] result_extended;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ALU_Result <= 4'h0;
            overflow   <= 1'b0;
            underflow  <= 1'b0;
        end else begin
            // 연산 전 매번 초기화
            overflow   <= 1'b0;
            underflow  <= 1'b0;

            case (ALU_Op)
                // --- 기본 및 논리 연산 ---
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

                // --- 산술 연산 (Unsigned 최적화 로직) ---
                ADD, ADDI: begin
                    // 0으로 확장하여 5비트 덧셈 수행
                    result_extended = {1'b0, in1} + {1'b0, in2};
                    // 5번째 비트(carry-out)가 1이면 오버플로우
                    if (result_extended[4]) begin
                        overflow <= 1'b1;
                    end
                    ALU_Result <= result_extended[3:0];
                end
                SUB, SUBI: begin
                    // 0으로 확장하여 5비트 뺄셈 수행
                    result_extended = {1'b0, in1} - {1'b0, in2};
                    // 5번째 비트(borrow)가 1이면 언더플로우
                    if (result_extended[4]) begin
                        underflow <= 1'b1;
                    end
                    ALU_Result <= result_extended[3:0];
                end

                // --- 쉬프트 연산 ---
                SLL: ALU_Result <= in1 << in2;
                SRL: ALU_Result <= in1 >> in2;

                default: ALU_Result <= 4'hF; // 정의되지 않은 Opcode
            endcase
        end
    end
endmodule
