# Simple Microprocessor  
## - 4단계 구조의 16bit Microprocessor 설계

---

### 1. Project Goal

- **간단한 마이크로프로세서의 동작 원리와 구조 이해**
- Verilog HDL로 기본적인 마이크로프로세서를 직접 설계, Vivado 기반에서 동작 검증
- 연산 및 데이터 처리의 전체 흐름(IO → Control → Register → MUX → ALU)을 구현

---

### 2. System Architecture
```
┌─────┐  ┌─────────┐  ┌──────────┐  ┌─────┐  ┌─────┐
│ IO  │─►│ Control │─►│ Register │─►│ MUX │─►│ ALU │
└─────┘  └─────────┘  └──────────┘  └─────┘  └─────┘
                            ▲                   │
                            └───────────────────┘
```

- **IO Module**: 외부 입력/출력 관리 (스위치, 버튼, LED 등)
- **Control Unit**: 명령어 해석 및 제어 신호 생성 (Opcode 해석, 제어 FSM)
- **Register File**: 데이터 저장 및 레지스터 간 이동
- **MUX**: 입력 선택 (Register/Immediate 선택 등)
- **ALU**: 산술/논리 연산 수행

---

### 3. Functional Overview

- **명령어 세트**: 4bit Opcode 기반 기본 산술/논리 연산(ADD, SUB, AND, OR, XOR 등)  
- **클럭 동작**: 100MHz 기준 동작  
- **입출력**: 스위치/버튼/LED로 연산 과정 관찰  
- **제어 구조**: FSM 기반 명령어 처리, 레지스터 직접 연동  
- **설계 환경**: Vivado 202x, Verilog HDL

---

### 4. Verification & PPA Evaluation

- **기능 검증**  
  - Vivado 시뮬레이션을 통해 모든 명령어의 동작 확인  
  - Testbench 기반 입력 벡터 생성 및 결과 자동 체크  
- **성능(PPA) 평가**  
  - Synthesis 기준 최대 동작 속도: 100MHz  
  - Gate-level netlist 생성 및 Timing 분석  
  - 회로 복잡도, 레지스터/ALU 자원 점유율 비교(기초적인 수준)

---

### 5. File Structure
```
/rtl
├─ io_module.v
├─ control_unit.v
├─ register_file.v
├─ mux.v
├─ alu.v
└─ top_microprocessor.v

/testbench
└─ tb_top_microprocessor.v

README.md
```

---

### 6. Future Development / Expansion

- **MIPS 구조로의 확장**  
  - 5단계 파이프라인 구조(IF, ID, EX, MEM, WB) 적용  
  - Hazard Detection, Forwarding 등 고급 구조 추가  
  - 분기 예측, 인터럽트 핸들링 등 시스템 확장
- **클럭 주파수 향상**  
  - 파이프라인/타이밍 최적화로 200MHz 이상 동작 목표  
- **실제 Application 연결**  
  - 간단한 소프트웨어 인터프리터 또는 외부 디바이스 제어 예제 추가

---

### 7. Author

- **창현(Changhyeon)**
  - Microprocessor Design Project
  - [github.com/joyua](https://github.com/joyua)
  








