`timescale 1ns / 1ps

//================================================================
// Top Module: ��ü ����ũ�����μ��� ���� (���� �ϼ���)
//================================================================
module Microprocessor_top_module(
    // FPGA ���� �����
    input clk_ref,      // ���� Ŭ�� (���忡�� ����)
    input [3:0] sw,         // 4-bit �����̵� ����ġ
    input [3:0] btn,        // 4-bit Ǫ�� ��ư

    output [3:0] led,       // 4-bit LED
    output [6:0] ssd_seg,   // 7-Segment ����
    output [3:0] ssd_anode  // 7-Segment �ڸ� ����
);

    // --- ���� ��ȣ ���� (Wires) ---
    wire clk_100M, rst;

    // ��� �� ���� ��ȣ
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

    // --- ���� ��� �ν��Ͻ�ȭ ---

    // 1. ���� ��ȣ ����
    assign rst = btn[3];

    // 2. Ŭ�� ���� (Vivado IP ���)
    // clk_wiz_0 IP�� ����Ͽ� ���� ���� Ŭ�����κ��� 100MHz Ŭ�� ����
    clk_gen clock_generator (
        .clk_ref(clk_ref), 
        .rst(rst), 
        .clk_100M(clk_100M)
    );

    // 3. ��ư ��ȣ ����ȭ (Syncronizer -> Debouncer)
    // for-generate ���� ����Ͽ� 4�� ��ư�� ���� ������ ����� �ݺ������� �ν��Ͻ�ȭ
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : BTN_STABILIZE
            Syncronizer sync_unit (.clk(clk_100M), .async_in(btn[i]), .sync_out(sync_btn[i]));
            Debouncer deb_unit (.clk(clk_100M), .noisy(sync_btn[i]), .debounced(D_btn[i]));
        end
    endgenerate

    // ����ȭ�� ��ư ��ȣ�� ���� ���
    assign E_btn = {btn[3:1], D_btn[0]};

    // --- MUX ���� ---
    // ALU�� �� ��° �Է��� ALU_Src ��ȣ�� ���� ������
    assign alu_in2 = (ALU_Src) ? instruction[7:4] : Rd2_data;

    // --- �ٽ� ��� �ν��Ͻ�ȭ ---

    // 1. IO ���: FSM�� �����ϰ� instruction�� pst�� ����
    IO io_unit (
        .clk(clk_100M), .rst(rst),
        .switch(sw), .button(E_btn), .ALU_result(ALU_Result),
        .led(led), .ssd_seg(ssd_seg), .ssd_anode(ssd_anode),
        .instruction(instruction),
        .pst(pst)
    );

    // 2. ��ɾ� �ʵ� �й�
    assign Opcode = instruction[15:12];
    assign Rd1    = instruction[11:8];
    assign Rd2    = instruction[7:4];
    assign Wr     = instruction[3:0];

    // 3. Control ���: pst ���� Opcode�� �ص�
    Control control_unit (
        .clk(clk_100M), .rst(rst),
        .Opcode(Opcode),
        .Reg_Write(Reg_Write), .ALU_Src(ALU_Src), .ALU_Op(ALU_Op)
    );

    // 4. Register ���: pst�� �޾� ���� Ÿ�̹� ����
    Register reg_file_unit (
        .clk(clk_100M), .rst(rst),
        .pst(pst),
        .Reg_Write(Reg_Write),
        .Rd1(Rd1), .Rd2(Rd2), .Wr(Wr),
        .ALU_result(ALU_Result), .overflow(overflow), .underflow(underflow),
        .Read_data1(Rd1_data), .Read_data2(Rd2_data)
    );

    // 5. ALU ���
    ALU alu_unit (
        .clk(clk_100M), .rst(rst),
        .ALU_Op(ALU_Op),
        .in1(Rd1_data), .in2(alu_in2),
        .ALU_Result(ALU_Result),
        .overflow(overflow), .underflow(underflow)
    );

endmodule