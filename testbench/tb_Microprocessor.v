`timescale 1ns / 1ps

//================================================================
// Comprehensive Testbench (Hardcoded Final Version)
// - Task를 사용하지 않고 모든 신호 변화를 명시적으로 나열하여
//   시뮬레이션의 안정성과 명확성을 확보한 최종 버전입니다.
//================================================================
module tb_Microprocessor;

    // --- Testbench Signals ---
    reg clk_ref;
    reg [3:0] sw;
    reg [3:0] btn;

    wire [3:0] led;
    wire [6:0] ssd_seg;
    wire [3:0] ssd_anode;

    // --- DUT(Device Under Test) 인스턴스화 ---
    Microprocessor_top_module dut (
        .clk_ref(clk_ref),
        .sw(sw),
        .btn(btn),
        .led(led),
        .ssd_seg(ssd_seg),
        .ssd_anode(ssd_anode)
    );

    // --- 클럭 생성 (100MHz) ---
    always #4 clk_ref = ~clk_ref;

    // --- 메인 시뮬레이션 시퀀스 ---
    initial begin
        clk_ref = 0; btn = 4'b0000; sw = 4'b0000;
    #10              btn = 4'b1000; // IDLE
    #10              btn = 4'b0000;
    
    // Case 1: Op: 2 Read Rd1: 3 Rd2: 4 Wr: 1 
    #1000          btn = 4'b0001;  // State 1
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0010; // OP: 2 Read
    #10000         btn = 4'b0001; // State 2 
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0011; // Rd1: 3
    #10000         btn = 4'b0001; // State 3
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0100; // Rd2: 4
    #10000         btn = 4'b0001; // State 4
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0001; // Wr: 1
    #10000         btn = 4'b0001; // State 5 Done 
    #5000          btn = 4'b0000;
    #10000         btn = 4'b0010; //button[1] SSD로 명령어 표기, 즉 State 4와 같은 상태 
    #5000          btn = 4'b0000;
    
    #10000         btn = 4'b0001; // Comeback Idle State
    #5000          btn = 4'b0000; 
    #10000         btn = 4'b1000;
    #5000          btn = 4'b0000;
    
    
    // Case 2: Op: 3 Copy Rd1: 3 Rd2: 4 Wr: 1 
    #1000          btn = 4'b0001;  // State 1
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0011; // OP: 3 Copy
    #10000         btn = 4'b0001; // State 2 
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0011; // Rd1: 3
    #10000         btn = 4'b0001; // State 3
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0100; // Rd2: 4
    #10000         btn = 4'b0001; // State 4
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0001; // Wr: 1
    #10000         btn = 4'b0001; // State 5 Done 
    #5000          btn = 4'b0000;
    #10000         btn = 4'b0010; //button[1] SSD로 명령어 표기, 즉 State 4와 같은 상태 
    #5000          btn = 4'b0000;
    
    #10000         btn = 4'b0001; // Comeback Idle State
    #5000          btn = 4'b0000; 
    #10000         btn = 4'b1000;
    #5000          btn = 4'b0000;
    
    // Case 3: Op: 4 Not Rd1: 3 Rd2: 4 Wr: 1 
    #1000          btn = 4'b0001;  // State 1
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0100; // OP: 4 Not
    #10000         btn = 4'b0001; // State 2 
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0011; // Rd1: 3
    #10000         btn = 4'b0001; // State 3
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0100; // Rd2: 4
    #10000         btn = 4'b0001; // State 4
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0001; // Wr: 1
    #10000         btn = 4'b0001; // State 5 Done 
    #5000          btn = 4'b0000;
    #10000         btn = 4'b0010; //button[1] SSD로 명령어 표기, 즉 State 4와 같은 상태 
    #5000          btn = 4'b0000;
    
    #10000         btn = 4'b0001; // Comeback Idle State
    #5000          btn = 4'b0000; 
    #10000         btn = 4'b1000;
    #5000          btn = 4'b0000;
    
    // Case 4: Op: 5 AND Rd1: 3 Rd2: 4 Wr: 1 
    #1000          btn = 4'b0001;  // State 1
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0101; // OP: 5 And
    #10000         btn = 4'b0001; // State 2 
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0011; // Rd1: 3
    #10000         btn = 4'b0001; // State 3
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0110; // Rd2: 6
    #10000         btn = 4'b0001; // State 4
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0001; // Wr: 1 (0010)
    #10000         btn = 4'b0001; // State 5 Done 
    #5000          btn = 4'b0000;
    #10000         btn = 4'b0010; //button[1] SSD로 명령어 표기, 즉 State 4와 같은 상태 
    #5000          btn = 4'b0000;
    
    #10000         btn = 4'b0001; // Comeback Idle State
    #5000          btn = 4'b0000; 
    #10000         btn = 4'b1000;
    #5000          btn = 4'b0000;
    
    // Case 5: Op: 6 Or Rd1: 3 Rd2: 4 Wr: 1 
    #1000          btn = 4'b0001;  // State 1
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0110; // OP: 6 Or
    #10000         btn = 4'b0001; // State 2 
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0011; // Rd1: 3
    #10000         btn = 4'b0001; // State 3
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0110; // Rd2: 6
    #10000         btn = 4'b0001; // State 4
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0001; // Wr: 1 (0111)
    #10000         btn = 4'b0001; // State 5 Done 
    #5000          btn = 4'b0000;
    #10000         btn = 4'b0010; //button[1] SSD로 명령어 표기, 즉 State 4와 같은 상태 
    #5000          btn = 4'b0000;
    
    #10000         btn = 4'b0001; // Comeback Idle State
    #5000          btn = 4'b0000; 
    #10000         btn = 4'b1000;
    #5000          btn = 4'b0000;
    
    // Case 6: Op: 7 XOR Rd1: 3 Rd2: 4 Wr: 1 
    #1000          btn = 4'b0001;  // State 1
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0111; // OP: 7 XOR
    #10000         btn = 4'b0001; // State 2 
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0011; // Rd1: 3
    #10000         btn = 4'b0001; // State 3
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0110; // Rd2: 6
    #10000         btn = 4'b0001; // State 4
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0001; // Wr: 1 (0101)
    #10000         btn = 4'b0001; // State 5 Done 
    #5000          btn = 4'b0000;
    #10000         btn = 4'b0010; //button[1] SSD로 명령어 표기, 즉 State 4와 같은 상태 
    #5000          btn = 4'b0000;
    
    #10000         btn = 4'b0001; // Comeback Idle State
    #5000          btn = 4'b0000; 
    #10000         btn = 4'b1000;
    #5000          btn = 4'b0000;
    
    // Case 7: Op: 8 NAND Rd1: 3 Rd2: 4 Wr: 1 
    #1000          btn = 4'b0001;  // State 1
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b1000; // OP: 8 NAND
    #10000         btn = 4'b0001; // State 2 
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0011; // Rd1: 3
    #10000         btn = 4'b0001; // State 3
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0110; // Rd2: 6
    #10000         btn = 4'b0001; // State 4
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0001; // Wr: 1 (1101)
    #10000         btn = 4'b0001; // State 5 Done 
    #5000          btn = 4'b0000;
    #10000         btn = 4'b0010; //button[1] SSD로 명령어 표기, 즉 State 4와 같은 상태 
    #5000          btn = 4'b0000;
    
    #10000         btn = 4'b0001; // Comeback Idle State
    #5000          btn = 4'b0000; 
    #10000         btn = 4'b1000;
    #5000          btn = 4'b0000;
    
    // Case 8: Op: 9 NOR Rd1: 3 Rd2: 4 Wr: 1 
    #1000          btn = 4'b0001;  // State 1
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b1001; // OP: 9 NOR
    #10000         btn = 4'b0001; // State 2 
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0011; // Rd1: 3
    #10000         btn = 4'b0001; // State 3
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0110; // Rd2: 6
    #10000         btn = 4'b0001; // State 4
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0001; // Wr: 1 (1000)
    #10000         btn = 4'b0001; // State 5 Done 
    #5000          btn = 4'b0000;
    #10000         btn = 4'b0010; //button[1] SSD로 명령어 표기, 즉 State 4와 같은 상태 
    #5000          btn = 4'b0000;
    
    #10000         btn = 4'b0001; // Comeback Idle State
    #5000          btn = 4'b0000; 
    #10000         btn = 4'b1000;
    #5000          btn = 4'b0000;
    
    // Case 9: Op: 10 ADD Rd1: 3 Rd2: 4 Wr: 1 
    #1000          btn = 4'b0001;  // State 1
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b1010; // OP: 10 ADD
    #10000         btn = 4'b0001; // State 2 
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0011; // Rd1: 3
    #10000         btn = 4'b0001; // State 3
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b1101; // Rd2: 13 value: 3
    #10000         btn = 4'b0001; // State 4
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0001; // Wr: 1 (0110)
    #10000         btn = 4'b0001; // State 5 Done 
    #5000          btn = 4'b0000;
    #10000         btn = 4'b0010; //button[1] SSD로 명령어 표기, 즉 State 4와 같은 상태 
    #5000          btn = 4'b0000;
    
    #10000         btn = 4'b0001; // Comeback Idle State
    #5000          btn = 4'b0000; 
    #10000         btn = 4'b1000;
    #5000          btn = 4'b0000;
    
    // Case 10: Op: 11 SUB Rd1: 3 Rd2: 4 Wr: 1 
    #1000          btn = 4'b0001;  // State 1
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b1011; // OP: 11 SUB
    #10000         btn = 4'b0001; // State 2 
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0011; // Rd1: 3
    #10000         btn = 4'b0001; // State 3
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0110; // Rd2: 6
    #10000         btn = 4'b0001; // State 4
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0001; // Wr: 1 (-3(1011)-> Underflow)
    #10000         btn = 4'b0001; // State 5 Done 
    #5000          btn = 4'b0000;
    #10000         btn = 4'b0010; //button[1] SSD로 명령어 표기, 즉 State 4와 같은 상태 
    #5000          btn = 4'b0000;
    
    #10000         btn = 4'b0001; // Comeback Idle State
    #5000          btn = 4'b0000; 
    #10000         btn = 4'b1000;
    #5000          btn = 4'b0000;
    


    // Case 11: Op: 12 ADDI Rd1: 3 Rd2: 4 Wr: 1 
    #1000          btn = 4'b0001;  // State 1
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b1110; // OP: 12 ADDI
    #10000         btn = 4'b0001; // State 2 
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0011; // Rd1: 3
    #10000         btn = 4'b0001; // State 3
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b1101; // Rd2: 13 
    #10000         btn = 4'b0001; // State 4
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0001; // Wr: 1 (10000 -> overflow)
    #10000         btn = 4'b0001; // State 5 Done 
    #5000          btn = 4'b0000;
    #10000         btn = 4'b0010; //button[1] SSD로 명령어 표기, 즉 State 4와 같은 상태 
    #5000          btn = 4'b0000;
    
    #10000         btn = 4'b0001; // Comeback Idle State
    #5000          btn = 4'b0000; 
    #10000         btn = 4'b1000;
    #5000          btn = 4'b0000;
    
    // Case 12: Op: 10 ADD Rd1: 3 Rd2: 4 Wr: 1 
    #1000          btn = 4'b0001;  // State 1
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b1010; // OP: 10 ADD
    #10000         btn = 4'b0001; // State 2 
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b1111; // Rd1: 15
    #10000         btn = 4'b0001; // State 3
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0110; // Rd2: 6
    #10000         btn = 4'b0001; // State 4
    #5000          btn = 4'b0000;
    #10000                        sw = 4'b0001; // Wr: 1 (Overflow 21 1'0101)
    #10000         btn = 4'b0001; // State 5 Done 
    #5000          btn = 4'b0000;
    #10000         btn = 4'b0010; //button[1] SSD로 명령어 표기, 즉 State 4와 같은 상태 
    #5000          btn = 4'b0000;
    
    #10000         btn = 4'b0001; // Comeback Idle State
    #5000          btn = 4'b0000; 
    #10000         btn = 4'b1000;
    #5000          btn = 4'b0000;
    
    
    #100 $finish;
    end

endmodule
