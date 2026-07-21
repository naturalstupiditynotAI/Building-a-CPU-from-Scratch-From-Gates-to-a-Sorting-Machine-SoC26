module alu(
    input  [7:0] a,
    input  [7:0] b,
    input        sub,          // 0 = add, 1 = subtract
    output [7:0] result,
    output       zero,
    output       negative,
    output       overflow,
    output       carry
);
    wire [8:0] ext = sub ? ({1'b0,a} - {1'b0,b}) : ({1'b0,a} + {1'b0,b});
    assign result   = ext[7:0];
    assign zero     = (result == 8'b0);
    assign negative = result[7];
    assign carry    = ext[8];
    assign overflow = sub ? ((a[7] != b[7]) && (result[7] != a[7]))
                           : ((a[7] == b[7]) && (result[7] != a[7]));
endmodule

module regfile(
    input        clk,
    input        reset,
    input  [1:0] rx_sel,
    input  [1:0] ry_sel,
    output [7:0] rx_data,
    output [7:0] ry_data,
    input        we,
    input  [1:0] w_sel,
    input  [7:0] w_data
);
    reg [7:0] regs [0:3];
    integer i;

    assign rx_data = regs[rx_sel];
    assign ry_data = regs[ry_sel];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 4; i = i + 1) regs[i] <= 8'b0;
        end else if (we) begin
            regs[w_sel] <= w_data;
        end
    end
endmodule

module flags_reg(
    input       clk,
    input       reset,
    input       we,
    input       c_in, o_in, n_in, z_in,
    output reg  c_flag, o_flag, n_flag, z_flag
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            {c_flag, o_flag, n_flag, z_flag} <= 4'b0;
        end else if (we) begin
            c_flag <= c_in;
            o_flag <= o_in;
            n_flag <= n_in;
            z_flag <= z_in;
        end
    end
endmodule

module code_memory(
    input  [7:0] adr,
    output [15:0] instr
);
    reg [15:0] rom [0:255];
    initial begin : init
        integer k;
        for (k = 0; k < 256; k = k + 1) rom[k] = 16'b0;  // default NOOP

        rom[32] = 16'b0011000000000000;  //         LOADI A, 0
        rom[33] = 16'b1000110000001000;  // Outer:   LOAD   D, [last]
        rom[34] = 16'b0011010000000000;  //          LOADI B, 0
        rom[35] = 16'b1101001100000000;  //          CMP    A, D
        rom[36] = 16'b1111001100001110;  //          BRGE   End
        rom[37] = 16'b1000110000001000;  // Inner:   LOAD   D, [last]
        rom[38] = 16'b0110110000000000;  //          SUB    D, A
        rom[39] = 16'b1101011100000000;  //          CMP    B, D
        rom[40] = 16'b1111001100001000;  //          BRGE   Iinc
        rom[41] = 16'b1001100100000000;  // If:      LOADF  C, [array+B]
        rom[42] = 16'b1001110100000001;  //          LOADF  D, [array+B+1]
        rom[43] = 16'b1101111000000000;  //          CMP    D, C
        rom[44] = 16'b1111001100000010;  //          BRGE   Jinc
        rom[45] = 16'b1011110100000000;  // Swap:    STOREF [array+B], D
        rom[46] = 16'b1011100100000001;  //          STOREF [array+B+1], C
        rom[47] = 16'b0101010000000001;  // Jinc:    ADDI   B, 1
        rom[48] = 16'b1110000011110100;  //          JUMP   Inner
        rom[49] = 16'b0101000000000001;  // Iinc:    ADDI   A, 1
        rom[50] = 16'b1110000011101110;  //          JUMP   Outer
        rom[51] = 16'b0000000000000000;  // End:     NOOP
    end
    assign instr = rom[adr];
endmodule

module data_memory(
    input        clk,
    input  [7:0] addr,
    input  [7:0] din,
    input        we,
    output [7:0] dout
);
    reg [7:0] ram [0:255];
    integer j;
    initial begin
        for (j = 0; j < 256; j = j + 1) ram[j] = 8'b0;
        // array BYTE 7,3,2,1,6,4,5,8   -> addresses 0-7
        ram[0] = 8'd7; ram[1] = 8'd3; ram[2] = 8'd2; ram[3] = 8'd1;
        ram[4] = 8'd6; ram[5] = 8'd4; ram[6] = 8'd5; ram[7] = 8'd8;
        // last BYTE 7                 -> address 8 (index of last element)
        ram[8] = 8'd7;
    end
    assign dout = ram[addr];
    always @(posedge clk) begin
        if (we) ram[addr] <= din;
    end
endmodule

module main(
    input clk,
    input reset
);
    reg  [7:0] pc;
    wire [15:0] instr;

    wire [3:0] opcode = instr[15:12];
    wire [1:0] rx_sel = instr[11:10];
    wire [1:0] ry_sel = instr[9:8];
    wire [7:0] imm    = instr[7:0];

    // ---- opcode decode ----
    wire is_noop   = (opcode == 4'b0000);
    wire is_loadi  = (opcode == 4'b0011);
    wire is_add    = (opcode == 4'b0100);
    wire is_addi   = (opcode == 4'b0101);
    wire is_sub    = (opcode == 4'b0110);
    wire is_load   = (opcode == 4'b1000);
    wire is_loadf  = (opcode == 4'b1001);
    wire is_store  = (opcode == 4'b1010);
    wire is_storef = (opcode == 4'b1011);
    wire is_cmp    = (opcode == 4'b1101);
    wire is_jump   = (opcode == 4'b1110);
    wire is_branch = (opcode == 4'b1111);

    // ---- register file ----
    wire [7:0] rx_data, ry_data;
    wire       reg_we;
    wire [7:0] reg_wdata;

    regfile RF (
        .clk(clk), .reset(reset),
        .rx_sel(rx_sel), .ry_sel(ry_sel),
        .rx_data(rx_data), .ry_data(ry_data),
        .we(reg_we), .w_sel(rx_sel), .w_data(reg_wdata)
    );

    wire       use_imm_b    = is_addi;                 // ADDI uses immediate as B operand
    wire [7:0] alu_b        = use_imm_b ? imm : ry_data;
    wire       alu_sub      = is_sub | is_cmp;          // SUB/CMP subtract; ADD/ADDI add
    wire [7:0] alu_result;
    wire       alu_z, alu_n, alu_v, alu_c;

    alu ALU (
        .a(rx_data), .b(alu_b), .sub(alu_sub),
        .result(alu_result),
        .zero(alu_z), .negative(alu_n), .overflow(alu_v), .carry(alu_c)
    );

    // ---- flags register ----
    wire flags_we = is_add | is_addi | is_sub | is_cmp;
    wire zf, nf, vf, cf;
    flags_reg FLAGS (
        .clk(clk), .reset(reset), .we(flags_we),
        .c_in(alu_c), .o_in(alu_v), .n_in(alu_n), .z_in(alu_z),
        .c_flag(cf), .o_flag(vf), .n_flag(nf), .z_flag(zf)
    );

    // ---- effective address for LOAD/LOADF/STORE/STOREF ----
    wire        indexed  = is_loadf | is_storef;
    wire [7:0]  eff_addr = imm + (indexed ? ry_data : 8'b0);

    // ---- data memory ----
    wire        mem_we   = is_store | is_storef;
    wire [7:0]  mem_dout;

    data_memory DMEM (
        .clk(clk), .addr(eff_addr),
        .din(rx_data),          // RX holds the value to store for STORE/STOREF
        .we(mem_we),
        .dout(mem_dout)
    );

    // ---- register writeback mux ----
    assign reg_we    = is_loadi | is_add | is_addi | is_sub | is_load | is_loadf;
    assign reg_wdata = is_loadi          ? imm :
                        (is_load|is_loadf) ? mem_dout :
                        alu_result;


    wire cond_eq = zf;
    wire cond_ne = ~zf;
    wire cond_gt = ~zf & (nf ~^ vf);
    wire cond_ge = (nf ~^ vf);
    wire branch_taken = is_branch & (
                            (ry_sel == 2'b00 & cond_eq) |
                            (ry_sel == 2'b01 & cond_ne) |
                            (ry_sel == 2'b10 & cond_gt) |
                            (ry_sel == 2'b11 & cond_ge) );
    wire take_offset = is_jump | branch_taken;

    // ---- code memory / PC ----
    code_memory ROM (.adr(pc), .instr(instr));

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 8'd32;   // program starts at address 32 (6'b100000)
        else if (take_offset)
            pc <= pc + 8'd1 + imm;   // imm is added as a signed 8-bit offset (wraps correctly)
        else
            pc <= pc + 8'd1;
    end

endmodule
