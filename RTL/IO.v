`timescale 1ns / 1ps

//================================================================
// Improved IO Module (Restored First Version)
// - 표준 FSM 설계와 통합된 디스플레이 제어 로직을 적용한
//   최초 개선안을 복원하고 안정화한 버전입니다.
//================================================================
module IO (
    // --- 시스템 입력 ---
    input clk, rst,

    // --- 사용자 입력 ---
    input [3:0] switch,
    input [3:0] button, // Debouncer를 거친 펄스 신호라고 가정
    input [3:0] ALU_result,

    // --- 외부 출력 ---
    output [3:0] led,
    output [6:0] ssd_seg,
    output [3:0] ssd_anode,
    output [15:0] instruction,
    output [3:0] pst
);

    // --- FSM 상태 정의 ---
    localparam S_IDLE  = 4'b0000, S_OP    = 4'b1000, S_RD1   = 4'b0100,
               S_RD2   = 4'b0010, S_WR    = 4'b0001, S_EXEC  = 4'b1110,
               S_DONE  = 4'b1111;

    // --- 내부 신호 ---
    reg [3:0]  current_state, next_state;
    reg [15:0] instruction_reg;
    reg        show_instruction_toggle;
    reg        button1_prev;

    // --- 출력 할당 ---
    assign instruction = instruction_reg;
    assign pst = current_state;

    // --- FSM 상태 레지스터 (순차 논리) ---
    // 클럭 엣지에 맞춰 "현재 상태"를 "다음 상태"로 업데이트
    always @(posedge clk or posedge rst) begin
        if (rst || button[3])
            current_state <= S_IDLE;
        else
            current_state <= next_state;
    end

    // --- FSM 다음 상태 결정 로직 (조합 논리) ---
    // "현재 상태"와 "입력"을 바탕으로 "다음 상태"를 결정
    always @(*) begin
        next_state = current_state; // 기본적으로는 현재 상태 유지
        if (button[0]) begin // btn[0] 펄스가 감지되면 상태 전이
            case (current_state)
                S_IDLE: next_state = S_OP;
                S_OP:   next_state = S_RD1;
                S_RD1:  next_state = S_RD2;
                S_RD2:  next_state = S_WR;
                S_WR:   next_state = S_EXEC;
                S_DONE: next_state = S_IDLE;
                default: ; // S_EXEC는 아래에서 자동 전이
            endcase
        end
        // S_EXEC 상태에서는 자동으로 S_DONE으로 전이
        if (current_state == S_EXEC) begin
            next_state = S_DONE;
        end
    end

    // --- 데이터 및 출력 레지스터 (순차 논리) ---
    always @(posedge clk or posedge rst) begin
        if (rst || button[3]) begin
            instruction_reg <= 16'h0;
            show_instruction_toggle <= 1'b0;
            button1_prev <= 1'b0;
        end else begin
            // 다음 상태로 넘어가기 직전의 현재 상태에서 데이터 저장
            case (current_state)
                S_OP:   instruction_reg[15:12] <= switch;
                S_RD1:  instruction_reg[11:8]  <= switch;
                S_RD2:  instruction_reg[7:4]   <= switch;
                S_WR:   instruction_reg[3:0]   <= switch;
                default: ;
            endcase

            // S_DONE 상태에서 button[1] 토글 로직
            button1_prev <= button[1]; // 이전 버튼 상태 저장
            if (current_state == S_DONE) begin
                if (button[1] && !button1_prev) begin // 상승 엣지 감지
                    show_instruction_toggle <= ~show_instruction_toggle;
                end
            end else begin
                show_instruction_toggle <= 1'b0; // 다른 상태에서는 리셋
            end
        end
    end
    
    // LED는 항상 현재 상태를 반영
    assign led = current_state;

    // --- SSD 제어 로직 (시분할 다중화) ---
    reg [19:0] ssd_clk_div;
    reg [1:0]  ssd_digit_selector;
    reg [3:0]  ssd_data_mux;
    wire [6:0] decoded_seg;

    // SSD 자리 선택 카운터
    always @(posedge clk or posedge rst) begin
        if (rst) {ssd_clk_div, ssd_digit_selector} <= 0;
        else if (ssd_clk_div >= 20'd99999) {ssd_clk_div, ssd_digit_selector} <= {20'd0, ssd_digit_selector + 1};
        else ssd_clk_div <= ssd_clk_div + 1;
    end

    // SSD에 표시할 데이터 선택 로직
    always @(*) begin
        ssd_data_mux = 4'h0; // 기본값
        case (current_state)
            S_OP:   if(ssd_digit_selector == 2'd3) ssd_data_mux = switch;
            S_RD1:  case(ssd_digit_selector) 2'd3: ssd_data_mux = instruction_reg[15:12]; 2'd2: ssd_data_mux = switch; default:; endcase
            S_RD2:  case(ssd_digit_selector) 2'd3: ssd_data_mux = instruction_reg[15:12]; 2'd2: ssd_data_mux = instruction_reg[11:8]; 2'd1: ssd_data_mux = switch; default:; endcase
            S_WR:   case(ssd_digit_selector) 2'd3: ssd_data_mux = instruction_reg[15:12]; 2'd2: ssd_data_mux = instruction_reg[11:8]; 2'd1: ssd_data_mux = instruction_reg[7:4]; 2'd0: ssd_data_mux = switch; default:; endcase
            S_DONE: begin
                if (show_instruction_toggle) begin
                    case(ssd_digit_selector)
                        2'd3: ssd_data_mux = instruction_reg[15:12]; 2'd2: ssd_data_mux = instruction_reg[11:8];
                        2'd1: ssd_data_mux = instruction_reg[7:4];   2'd0: ssd_data_mux = instruction_reg[3:0];
                    endcase
                end else if (ssd_digit_selector == 2'd0) ssd_data_mux = ALU_result;
            end
            default: ssd_data_mux = (current_state == S_IDLE) ? 4'h0 : 4'hF;
        endcase
    end

    // --- 최종 출력 로직 ---
    hex_to_7seg decoder (.hex_in(ssd_data_mux), .seg(decoded_seg));
    assign ssd_seg = decoded_seg;
    assign ssd_anode = ~(4'b1 << ssd_digit_selector);

endmodule
