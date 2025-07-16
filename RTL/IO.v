`timescale 1ns / 1ps

//================================================================
// Improved IO Module (Restored First Version)
// - ǥ�� FSM ����� ���յ� ���÷��� ���� ������ ������
//   ���� �������� �����ϰ� ����ȭ�� �����Դϴ�.
//================================================================
module IO (
    // --- �ý��� �Է� ---
    input clk, rst,

    // --- ����� �Է� ---
    input [3:0] switch,
    input [3:0] button, // Debouncer�� ��ģ �޽� ��ȣ��� ����
    input [3:0] ALU_result,

    // --- �ܺ� ��� ---
    output [3:0] led,
    output [6:0] ssd_seg,
    output [3:0] ssd_anode,
    output [15:0] instruction,
    output [3:0] pst
);

    // --- FSM ���� ���� ---
    localparam S_IDLE  = 4'b0000, S_OP    = 4'b1000, S_RD1   = 4'b0100,
               S_RD2   = 4'b0010, S_WR    = 4'b0001, S_EXEC  = 4'b1110,
               S_DONE  = 4'b1111;

    // --- ���� ��ȣ ---
    reg [3:0]  current_state, next_state;
    reg [15:0] instruction_reg;
    reg        show_instruction_toggle;
    reg        button1_prev;

    // --- ��� �Ҵ� ---
    assign instruction = instruction_reg;
    assign pst = current_state;

    // --- FSM ���� �������� (���� ��) ---
    // Ŭ�� ������ ���� "���� ����"�� "���� ����"�� ������Ʈ
    always @(posedge clk or posedge rst) begin
        if (rst || button[3])
            current_state <= S_IDLE;
        else
            current_state <= next_state;
    end

    // --- FSM ���� ���� ���� ���� (���� ��) ---
    // "���� ����"�� "�Է�"�� �������� "���� ����"�� ����
    always @(*) begin
        next_state = current_state; // �⺻�����δ� ���� ���� ����
        if (button[0]) begin // btn[0] �޽��� �����Ǹ� ���� ����
            case (current_state)
                S_IDLE: next_state = S_OP;
                S_OP:   next_state = S_RD1;
                S_RD1:  next_state = S_RD2;
                S_RD2:  next_state = S_WR;
                S_WR:   next_state = S_EXEC;
                S_DONE: next_state = S_IDLE;
                default: ; // S_EXEC�� �Ʒ����� �ڵ� ����
            endcase
        end
        // S_EXEC ���¿����� �ڵ����� S_DONE���� ����
        if (current_state == S_EXEC) begin
            next_state = S_DONE;
        end
    end

    // --- ������ �� ��� �������� (���� ��) ---
    always @(posedge clk or posedge rst) begin
        if (rst || button[3]) begin
            instruction_reg <= 16'h0;
            show_instruction_toggle <= 1'b0;
            button1_prev <= 1'b0;
        end else begin
            // ���� ���·� �Ѿ�� ������ ���� ���¿��� ������ ����
            case (current_state)
                S_OP:   instruction_reg[15:12] <= switch;
                S_RD1:  instruction_reg[11:8]  <= switch;
                S_RD2:  instruction_reg[7:4]   <= switch;
                S_WR:   instruction_reg[3:0]   <= switch;
                default: ;
            endcase

            // S_DONE ���¿��� button[1] ��� ����
            button1_prev <= button[1]; // ���� ��ư ���� ����
            if (current_state == S_DONE) begin
                if (button[1] && !button1_prev) begin // ��� ���� ����
                    show_instruction_toggle <= ~show_instruction_toggle;
                end
            end else begin
                show_instruction_toggle <= 1'b0; // �ٸ� ���¿����� ����
            end
        end
    end
    
    // LED�� �׻� ���� ���¸� �ݿ�
    assign led = current_state;

    // --- SSD ���� ���� (�ú��� ����ȭ) ---
    reg [19:0] ssd_clk_div;
    reg [1:0]  ssd_digit_selector;
    reg [3:0]  ssd_data_mux;
    wire [6:0] decoded_seg;

    // SSD �ڸ� ���� ī����
    always @(posedge clk or posedge rst) begin
        if (rst) {ssd_clk_div, ssd_digit_selector} <= 0;
        else if (ssd_clk_div >= 20'd99999) {ssd_clk_div, ssd_digit_selector} <= {20'd0, ssd_digit_selector + 1};
        else ssd_clk_div <= ssd_clk_div + 1;
    end

    // SSD�� ǥ���� ������ ���� ����
    always @(*) begin
        ssd_data_mux = 4'h0; // �⺻��
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

    // --- ���� ��� ���� ---
    hex_to_7seg decoder (.hex_in(ssd_data_mux), .seg(decoded_seg));
    assign ssd_seg = decoded_seg;
    assign ssd_anode = ~(4'b1 << ssd_digit_selector);

endmodule
