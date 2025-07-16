`timescale 1ns / 1ps
// ��ư �Է��� ����ȭ��Ű�� ��ٿ ���
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
