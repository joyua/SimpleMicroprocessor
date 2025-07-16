`timescale 1ns / 1ps
/**
 * @file hex_to_7seg.v
 * @brief 4비트 16진수 입력을 7세그먼트 디스플레이 출력으로 변환하는 모듈.
 * @details
 * - 입력: 4비트 16진수 값 (0-F)
 * - 출력: 7세그먼트 제어 신호
 * - 디스플레이 유형: 공통 양극 (Common Anode) - Active Low (0 = ON)
 */
module hex_to_7seg (
    input  [3:0] hex_in,  // 4-bit hexadecimal input (0x0 to 0xF)
    output reg [6:0] seg      // 7-bit output for segments {g,f,e,d,c,b,a}
);

    // `hex_in` 입력이 변경될 때마다 항상 실행
    always @(hex_in) begin
        case (hex_in)
            // 숫자 (0-9)
            4'h0: seg = 7'b0000001; // 0
            4'h1: seg = 7'b1001111; // 1
            4'h2: seg = 7'b0010010; // 2
            4'h3: seg = 7'b0000110; // 3
            4'h4: seg = 7'b1001100; // 4
            4'h5: seg = 7'b0100100; // 5
            4'h6: seg = 7'b0100000; // 6
            4'h7: seg = 7'b0001111; // 7
            4'h8: seg = 7'b0000000; // 8
            4'h9: seg = 7'b0000100; // 9
            
            // 16진수 문자 (A-F)
            4'hA: seg = 7'b0001000; // A
            4'hB: seg = 7'b0110000; // b
            4'hC: seg = 7'b0110001; // C
            4'hD: seg = 7'b0010001; // d
            4'hE: seg = 7'b0110000; // E (or 7'b0110010)
            4'hF: seg = 7'b0111000; // F
            
            // 4비트 입력에서는 default가 발생하지 않지만, 안전을 위해 추가
            default: seg = 7'b1111111; // 모든 세그먼트 OFF
        endcase
    end

endmodule
