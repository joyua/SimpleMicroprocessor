`timescale 1ns / 1ps
// �񵿱� ��ȣ�� ����ȭ�Ͽ� Metastability ����
module Syncronizer (
    input clk, async_in,
    output reg sync_out
);
    reg t;
    always @(posedge clk) begin
        t <= async_in;
        sync_out <= t;
    end
endmodule
