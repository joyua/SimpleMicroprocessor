`timescale 1ns / 1ps

/**
 * Register Module (Final Corrected Version)
 * 16개의 4비트 레지스터로 구성된 레지스터 파일.
 * - 동기식(Synchronous)으로 데이터를 읽고 씁니다.
 * - IO 모듈의 상태(pst)를 받아, S_EXEC 상태일 때만 쓰기 동작을 수행하여 정확한 타이밍을 제어합니다.
 */
module Register(
    // --- 시스템 입력 ---
    input clk, rst,

    // --- 타이밍 및 제어 신호 ---
    input [3:0] pst,        // IO 모듈의 현재 상태 (쓰기 타이밍 제어용)
    input Reg_Write,    // Control 모듈의 쓰기 허가 신호

    // --- 주소 및 데이터 입력 ---
    input [3:0] Rd1,        // 읽기 주소 1
    input [3:0] Rd2,        // 읽기 주소 2
    input [3:0] Wr,         // 쓰기 주소
    input [3:0] ALU_result, // ALU로부터 온 쓰기 데이터
    input overflow,     // ALU의 오버플로우 발생 신호
    input underflow,    // ALU의 언더플로우 발생 신호 

    // --- 데이터 출력 ---
    output reg [3:0] Read_data1, // Rd1 주소에서 읽은 데이터
    output reg [3:0] Read_data2  // Rd2 주소에서 읽은 데이터
);

    // FSM 상태 정의 (IO 모듈과 동기화)
    parameter S_EXEC  = 4'b1110; // 실행 상태

    // 16 x 4-bit 레지스터 파일 선언
    reg [3:0] register_file [15:0];

    // 레지스터 초기값 설정 (프로젝트 명세 기반)
    // 실제 FPGA에서는 초기화가 다르게 동작할 수 있으므로,
    // 명시적인 리셋 로직을 사용하는 것이 더 안정적입니다.
    initial begin
        register_file[0]  = 4'd0; // 0번 레지스터는 항상 0
        register_file[1]  = 4'd1;
        register_file[2]  = 4'd2;
        register_file[3]  = 4'd3;
        register_file[4]  = 4'd4;
        register_file[5]  = 4'd5;
        register_file[6]  = 4'd6;
        register_file[7]  = 4'd7;
        register_file[8]  = 4'd8;
        register_file[9]  = 4'd9;
        register_file[10] = 4'd10;
        register_file[11] = 4'd11;
        register_file[12] = 4'd12;
        register_file[13] = 4'd3;
        register_file[14] = 4'd14;
        register_file[15] = 4'd15;
    end

    // 동기식 읽기/쓰기 로직
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // 리셋 시 출력 포트 초기화
            Read_data1 <= 4'b0;
            Read_data2 <= 4'b0;
            // 리셋 시 레지스터 파일 자체를 초기화할 수도 있습니다.
            // for (integer i = 0; i < 16; i = i + 1) begin
            //     register_file[i] <= i;
            // end
        end else begin
            // --- 동기식 읽기 (Synchronous Read) ---
            // 항상 현재 주소(Rd1, Rd2)에 해당하는 데이터를 읽어 출력 레지스터에 준비.
            // 이렇게 하면 출력 값이 안정적으로 유지됩니다.
            Read_data1 <= register_file[Rd1];
            Read_data2 <= register_file[Rd2];

            // --- 동기식 쓰기 (Synchronous Write) ---
            // 쓰기 동작은 S_EXEC 상태이고, Reg_Write 신호가 1일 때만 수행.
            if ((pst == S_EXEC) && Reg_Write) begin
                // $0 레지스터는 쓸 수 없고, 오버플로우가 발생하지 않았을 때만 쓰기 수행
                if (Wr != 4'h0 && (!overflow && !underflow)) begin
                    register_file[Wr] <= ALU_result;
                end
            end
        end
    end

endmodule
