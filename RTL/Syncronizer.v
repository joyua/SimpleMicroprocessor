`timescale 1ns / 1ps
// 비동기 신호를 동기화하여 Metastability 방지
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
