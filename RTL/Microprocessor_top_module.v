`timescale 1ns / 1ps

//================================================================
// Top Module: 전체 마이크로프로세서 구조 (최종 완성본)
//================================================================
module Microprocessor_top_module(
    // FPGA 보드 입출력
    input clk_ref,      // 기준 클럭 (보드에서 제공)
    input [3:0] sw,         // 4-bit 슬라이드 스위치
    input [3:0] btn,        // 4-bit 푸시 버튼

    output [3:0] led,       // 4-bit LED
    output [6:0] ssd_seg,   // 7-Segment 패턴
    output [3:0] ssd_anode  // 7-Segment 자리 선택
);

    // --- 내부 신호 선언 (Wires) ---
    wire clk_100M, rst;

    // 모듈 간 연결 신호
    wire [15:0] instruction;
    wire [3:0]  Opcode, Rd1, Rd2, Wr;
    wire [3:0]  pst;
    wire        Reg_Write;
    wire        ALU_Src;
    wire [3:0]  ALU_Op;
    wire [3:0]  ALU_Result;
    wire        overflow;
    wire        underflow;
    wire [3:0]  Rd1_data;
    wire [3:0]  Rd2_data;
    wire [3:0]  alu_in2;
    wire [3:0]  sync_btn, D_btn, E_btn;

    // --- 보조 모듈 인스턴스화 ---

    // 1. 리셋 신호 정의
    assign rst = btn[3];

    // 2. 클럭 생성 (Vivado IP 사용)
    // clk_wiz_0 IP를 사용하여 보드 기준 클럭으로부터 100MHz 클럭 생성
    clk_gen clock_generator (
        .clk_ref(clk_ref), 
        .rst(rst), 
        .clk_100M(clk_100M)
    );

    // 3. 버튼 신호 안정화 (Syncronizer -> Debouncer)
    // for-generate 문을 사용하여 4개 버튼에 대해 동일한 모듈을 반복적으로 인스턴스화
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : BTN_STABILIZE
            Syncronizer sync_unit (.clk(clk_100M), .async_in(btn[i]), .sync_out(sync_btn[i]));
            Debouncer deb_unit (.clk(clk_100M), .noisy(sync_btn[i]), .debounced(D_btn[i]));
        end
    endgenerate

    // 안정화된 버튼 신호를 최종 사용
    assign E_btn = {btn[3:1], D_btn[0]};

    // --- MUX 로직 ---
    // ALU의 두 번째 입력은 ALU_Src 신호에 따라 결정됨
    assign alu_in2 = (ALU_Src) ? instruction[7:4] : Rd2_data;

    // --- 핵심 모듈 인스턴스화 ---

    // 1. IO 모듈: FSM을 관리하고 instruction과 pst를 생성
    IO io_unit (
        .clk(clk_100M), .rst(rst),
        .switch(sw), .button(E_btn), .ALU_result(ALU_Result),
        .led(led), .ssd_seg(ssd_seg), .ssd_anode(ssd_anode),
        .instruction(instruction),
        .pst(pst)
    );

    // 2. 명령어 필드 분배
    assign Opcode = instruction[15:12];
    assign Rd1    = instruction[11:8];
    assign Rd2    = instruction[7:4];
    assign Wr     = instruction[3:0];

    // 3. Control 모듈: pst 없이 Opcode만 해독
    Control control_unit (
        .clk(clk_100M), .rst(rst),
        .Opcode(Opcode),
        .Reg_Write(Reg_Write), .ALU_Src(ALU_Src), .ALU_Op(ALU_Op)
    );

    // 4. Register 모듈: pst를 받아 쓰기 타이밍 제어
    Register reg_file_unit (
        .clk(clk_100M), .rst(rst),
        .pst(pst),
        .Reg_Write(Reg_Write),
        .Rd1(Rd1), .Rd2(Rd2), .Wr(Wr),
        .ALU_result(ALU_Result), .overflow(overflow), .underflow(underflow),
        .Read_data1(Rd1_data), .Read_data2(Rd2_data)
    );

    // 5. ALU 모듈
    ALU alu_unit (
        .clk(clk_100M), .rst(rst),
        .ALU_Op(ALU_Op),
        .in1(Rd1_data), .in2(alu_in2),
        .ALU_Result(ALU_Result),
        .overflow(overflow), .underflow(underflow)
    );

endmodule