`timescale 1ns / 1ps

module clk_gen(
    input clk_ref, rst,
    output clk_100M
    );
    wire clk_125M = clk_ref;
    
clk_wiz_0 clk_gen (
        .clk_out1(clk_100M),
        .reset(rst),
        .clk_in1(clk_ref)
        );
        
endmodule
