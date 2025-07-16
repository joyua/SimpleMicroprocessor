# 📘 Simple-Microprocessor – FSM 기반 수동 실행 마이크로프로세서

> Verilog & Vivado를 활용한 **FSM 기반 Microprocessor 설계 프로젝트**  
> 사용자 입력으로 직접 명령어를 구성하고, 버튼을 통해 단계적으로 실행

---

## 📌 프로젝트 개요

이 프로젝트는 FPGA를 이용해 설계한 **16bit 명령어 기반의 Simple Microprocessor**입니다.  
명령어 입력은 슬라이드 스위치와 버튼을 통해 직접 구성하며, FSM 기반으로 `Idle → 명령어 입력 → 실행 → Done` 순으로 제어됩니다.

- 명령어 구성: `Opcode | Rd1 | Rd2 | Wr` (각 4bit, 총 16bit)
- 4bit 레지스터 16개 사용
- 연산 결과는 LED/7-segment로 출력

---

## 🧱 전체 구조 (Block Diagram)

``` code
Switch/Button → IO FSM → Instruction Register
↓
Control Unit
↓
Register File (Read)
↓
ALU ← MUX ← Register / Immediate
↓
Register File (Write)
↓
LED / SSD 출력
```


---

## 🛠️ 주요 모듈

| 모듈 이름 | 기능 |
|-----------|------|
| `Microprocessor_top_module.v` | 전체 시스템 Top module |
| `IO.v` | 슬라이드 스위치/버튼 입력 FSM → 명령어 구성 |
| `Control.v` | Opcode에 따라 ALU Op, ALU Src, RegWrite 제어 신호 생성 |
| `Register.v` | 16×4bit 레지스터 파일 (Read/Write 지원) |
| `ALU.v` | 산술/논리 연산 처리 |
| `clk_gen.v` | 100MHz 클럭 생성기 |
| `Debouncer.v`, `Synchronizer.v` | 버튼 입력 안정화 처리 |

---

## 🗂️ 명령어 포맷 (16bit)

```code
[15:12] Opcode : 연산 종류
[11:8] Rd1 : Read Register 1
[7:4] Rd2/Imm : Read Register 2 또는 Immediate 값
[3:0] Wr : Write Register
```


예시: `Instruction = 16'hA248`  
→ `Opcode=A(ADD), Rd1=2, Rd2=4, Wr=8`

---

## 🧪 지원하는 연산 목록 (Opcode)

| Opcode | 연산 | 설명 |
|--------|------|------|
| 0000 (0) | NOP | 아무것도 안 함 |
| 0001 (1) | WRITE | Rd2 값 → Wr 저장 |
| 0010 (2) | READ | Rd1 값 읽음 |
| 0011 (3) | COPY | Rd1 → Wr |
| 0100~0111 | NOT, AND, OR, XOR | 논리 연산 |
| 1000~1011 | NAND, NOR, ADD, SUB | 기본 연산 |
| 1100~1101 | ADDI, SUBI | Immediate 연산 |
| 1110~1111 | LSHIFT, RSHIFT | 비트 시프트 연산 |

---

## 🔁 FSM 동작 흐름

| 상태 | 설명 | 버튼 동작 | 출력 |
|------|------|------------|--------|
| Idle | 대기 | BTN[0] → 명령어 입력 시작 | SSD: 0 |
| 명령어 입력 1~4 | Opcode, Rd1, Rd2, Wr 입력 | BTN[0]으로 단계 이동 | 각 SSD에 해당 값 출력 |
| 실행 | 구성된 명령 실행 | 자동 실행 후 Done으로 이동 | 연산 결과 저장 |
| Done | 결과 확인 상태 | BTN[0] → Idle 복귀 | SSD: 결과 출력 |

- `BTN[3]`: 언제든지 Idle로 복귀  
- `BTN[1]`: Done 상태에서 명령어 확인

---

## 💡 설계 특징

- 레지스터 0번은 항상 0으로 고정  
- 연산 결과는 SSD(7-segment)에 표시  
- FSM 상태는 LED로 시각화  
- ADD/SUB는 4bit 2의 보수 방식 사용  
- 100MHz 클럭에서 동작

---

## 📷 예시 동작 (설명용)

```
Instruction = 16’hA248
→ Opcode = A (ADD), Rd1 = 2, Rd2 = 4, Wr = 8
→ 레지스터 2와 4의 값을 더해 8번 레지스터에 저장
→ 결과값은 SSD와 LED로 확인 가능
```


---

## 📁 디렉토리 구성 예시

```
Simple-Microprocessor/
├── src/
│ ├── Microprocessor_top_module.v
│ ├── IO.v
│ ├── ALU.v
│ ├── Register.v
│ ├── Control.v
│ ├── clk_gen.v
│ └── ...
├── testbench/
│ └── simple_tb.v
├── doc/
│ └── Microprocessor_diagram.pdf
├── prog/
│ └── instruction_example.txt
└── README.md
```


---

## 🔗 향후 발전 방향

- 버튼 기반 수동 구조 → Instruction Memory + PC로 자동화  
- MIPS 기반 5단계 Pipeline 구조로 발전 예정  
- Forwarding / Hazard Detection 포함한 고속 동작 구조로 확장


---

## 👨‍💻 제작자

- **프로젝트명**: Simple-Microprocessor
- **제작자**: 창현 (Changhyeon)
- **설계 환경**: Vivado 2019.2, Verilog HDL
- **작성일자**: 2025.07.16
- **연락처**: kil0886@naver.com



