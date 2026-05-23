# Week 2 — Important Circuits

## Objective
Design the core building blocks of your CPU in Verilog.
Every module you build this week will be instantiated inside
the processor in weeks 5–8. Getting them right here, with
passing testbenches, means you can trust them later.

---

## Circuits to Build

### 1. Parameterized MUX (mux/mux.v)
An N-bit wide 2:1 and 4:1 MUX. Parameterized width so you
can reuse the same module anywhere in the datapath.

```verilog
module mux2 #(parameter WIDTH = 8) (
    input  [WIDTH-1:0] a, b,
    input              sel,
    output [WIDTH-1:0] y
);
```

### 2. ALU (alu/alu.v)
8-bit ALU supporting: ADD, SUB, AND, OR, XOR, SHIFTL, SHIFTR.
Outputs: result, zero flag, carry flag, overflow flag.
This is the computational heart of your CPU.

```
Operations (op[2:0]):
  000 -> ADD
  001 -> SUB
  010 -> AND
  011 -> OR
  100 -> XOR
  101 -> SHIFTL (shift left by 1)
  110 -> SHIFTR (shift right by 1)
```

### 3. Register File (register_file/regfile.v)
4 registers (A, B, C, D), each 8 bits wide.
- 2 asynchronous read ports
- 1 synchronous write port
- Write-enable controlled

```verilog
module regfile(
    input        clk,
    input        we,          // write enable
    input  [1:0] raddr0,      // read port 0 address (selects A/B/C/D)
    input  [1:0] raddr1,      // read port 1 address
    input  [1:0] waddr,       // write address
    input  [7:0] wdata,       // data to write
    output [7:0] rdata0,      // read port 0 output
    output [7:0] rdata1       // read port 1 output
);
```

### 4. Program Counter (program_counter/pc.v)
6-bit PC with synchronous load and increment.
- `inc`: increment PC by 1
- `load`: load an external value into PC
- `load` takes priority over `inc`

```verilog
module pc(
    input        clk, rst,
    input        inc,
    input        load,
    input  [5:0] load_val,
    output reg [5:0] pc_out
);
```

---

## Textbook Reference (Brown & Vranesic, 3rd Ed.)

| Topic                          | Section          |
|-------------------------------|------------------|
| Arithmetic circuits (adders)  | Ch. 3, §3.1–3.2  |
| Adder/subtractor              | Ch. 3, §3.2      |
| Overflow detection            | Ch. 3, §3.3–3.4  |
| Arithmetic in Verilog         | Ch. 3, §3.5      |
| Multiplexers (detailed)       | Ch. 4, §4.3      |
| Decoders                      | Ch. 4, §4.1      |
| Registers                     | Ch. 5, §5.4      |
| Shift registers               | Ch. 5, §5.5      |

---

## Exercises

First do the select problems in HDLBits that will build up to these modules then go to the `Assignment`.

---

## How to Run

```bash
# ALU example
iverilog -o sim testbenches/tb_alu.v alu/alu.v && vvp sim

# Register file
iverilog -o sim testbenches/tb_regfile.v register_file/regfile.v && vvp sim

# Program counter
iverilog -o sim testbenches/tb_pc.v program_counter/pc.v && vvp sim
```

---
