`timescale 1ns / 1ps

/**
 * Register Module (Final Corrected Version)
 * 16���� 4��Ʈ �������ͷ� ������ �������� ����.
 * - �����(Synchronous)���� �����͸� �а� ���ϴ�.
 * - IO ����� ����(pst)�� �޾�, S_EXEC ������ ���� ���� ������ �����Ͽ� ��Ȯ�� Ÿ�̹��� �����մϴ�.
 */
module Register(
    // --- �ý��� �Է� ---
    input clk, rst,

    // --- Ÿ�̹� �� ���� ��ȣ ---
    input [3:0] pst,        // IO ����� ���� ���� (���� Ÿ�̹� �����)
    input Reg_Write,    // Control ����� ���� �㰡 ��ȣ

    // --- �ּ� �� ������ �Է� ---
    input [3:0] Rd1,        // �б� �ּ� 1
    input [3:0] Rd2,        // �б� �ּ� 2
    input [3:0] Wr,         // ���� �ּ�
    input [3:0] ALU_result, // ALU�κ��� �� ���� ������
    input overflow,     // ALU�� �����÷ο� �߻� ��ȣ
    input underflow,    // ALU�� ����÷ο� �߻� ��ȣ 

    // --- ������ ��� ---
    output reg [3:0] Read_data1, // Rd1 �ּҿ��� ���� ������
    output reg [3:0] Read_data2  // Rd2 �ּҿ��� ���� ������
);

    // FSM ���� ���� (IO ���� ����ȭ)
    parameter S_EXEC  = 4'b1110; // ���� ����

    // 16 x 4-bit �������� ���� ����
    reg [3:0] register_file [15:0];

    // �������� �ʱⰪ ���� (������Ʈ �� ���)
    // ���� FPGA������ �ʱ�ȭ�� �ٸ��� ������ �� �����Ƿ�,
    // ������� ���� ������ ����ϴ� ���� �� �������Դϴ�.
    initial begin
        register_file[0]  = 4'd0; // 0�� �������ʹ� �׻� 0
        register_file[1]  = 4'd1;
        register_file[2]  = 4'd2;
        register_file[3]  = 4'd3;
        register_file[4]  = 4'd4;
        register_file[5]  = 4'd5;
        register_file[6]  = 4'd6;
        register_file[7]  = 4'd7;
        register_file[8]  = 4'd8;
        register_file[9]  = 4'd9;
        register_file[10] = 4'd10;
        register_file[11] = 4'd11;
        register_file[12] = 4'd12;
        register_file[13] = 4'd3;
        register_file[14] = 4'd14;
        register_file[15] = 4'd15;
    end

    // ����� �б�/���� ����
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // ���� �� ��� ��Ʈ �ʱ�ȭ
            Read_data1 <= 4'b0;
            Read_data2 <= 4'b0;
            // ���� �� �������� ���� ��ü�� �ʱ�ȭ�� ���� �ֽ��ϴ�.
            // for (integer i = 0; i < 16; i = i + 1) begin
            //     register_file[i] <= i;
            // end
        end else begin
            // --- ����� �б� (Synchronous Read) ---
            // �׻� ���� �ּ�(Rd1, Rd2)�� �ش��ϴ� �����͸� �о� ��� �������Ϳ� �غ�.
            // �̷��� �ϸ� ��� ���� ���������� �����˴ϴ�.
            Read_data1 <= register_file[Rd1];
            Read_data2 <= register_file[Rd2];

            // --- ����� ���� (Synchronous Write) ---
            // ���� ������ S_EXEC �����̰�, Reg_Write ��ȣ�� 1�� ���� ����.
            if ((pst == S_EXEC) && Reg_Write) begin
                // $0 �������ʹ� �� �� ����, �����÷ο찡 �߻����� �ʾ��� ���� ���� ����
                if (Wr != 4'h0 && (!overflow && !underflow)) begin
                    register_file[Wr] <= ALU_result;
                end
            end
        end
    end

endmodule
