`timescale 1ns / 1ps
// 버튼 입력을 안정화시키는 디바운서 모듈
module Debouncer #(parameter N = 30, parameter K = 30) (
    input clk, noisy,
    output debounced
);
    reg [K-1:0] cnt;
    always @(posedge clk) begin
        if(noisy) cnt <= cnt + 1'b1;
        else cnt <= 0;
    end
    assign debounced = (cnt == N) ? 1'b1 : 1'b0;
endmodule
