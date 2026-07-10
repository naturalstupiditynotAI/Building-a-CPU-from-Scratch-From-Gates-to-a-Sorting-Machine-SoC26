`timescale 1ns/1ps

module decoder_tb;

    // 1. Test bench inputs (Declared as reg)
    reg [15:0] tb_in;

    // 2. Test bench outputs (Declared as wire)
    wire [15:0] tb_o4to16;
    wire [3:0] tb_o2to4A;
    wire [3:0] tb_o2to4B;
    wire [1:0] tb_o1to2;
    wire tb_NOOP, tb_MOVE, tb_LOADI, tb_ADD, tb_ADDI, tb_SUB, tb_SUBI;
    wire tb_LOAD, tb_LOADF, tb_STORE, tb_STOREF, tb_CMP, tb_JUMP;
    wire tb_INPUTC, tb_INPUTCF, tb_INPUTD, tb_INPUTDF;
    wire tb_SHIFTL, tb_SHIFTR;
    wire tb_BRE, tb_BRNE, tb_BRG, tb_BRGE;
    wire [7:0] tb_ADDR;
    wire [1:0] tb_RY, tb_RX;
// 3. Connect your decoder design to the test bench variables
    decoder uut (
        .in(tb_in),
        .o4to16(tb_o4to16),
        .o2to4A(tb_o2to4A),
        .o2to4B(tb_o2to4B),
        .o1to2(tb_o1to2),
        .NOOP(tb_NOOP),
        .MOVE(tb_MOVE),
        .LOADI(tb_LOADI),
        .ADD(tb_ADD),
        .ADDI(tb_ADDI),
        .SUB(tb_SUB),
        .SUBI(tb_SUBI),
        .LOAD(tb_LOAD),
        .LOADF(tb_LOADF),
        .STORE(tb_STORE),
        .STOREF(tb_STOREF),
        .CMP(tb_CMP),
        .JUMP(tb_JUMP),
        .INPUTC(tb_INPUTC),
        .INPUTCF(tb_INPUTCF),
        .INPUTD(tb_INPUTD),
        .INPUTDF(tb_INPUTDF),
        .SHIFTL(tb_SHIFTL),
        .SHIFTR(tb_SHIFTR),
        .BRE(tb_BRE),
        .BRNE(tb_BRNE),
        .BRG(tb_BRG),
        .BRGE(tb_BRGE),
        .ADDR(tb_ADDR),
        .RY(tb_RY),
        .RX(tb_RX)
    );

    // 4. Run the simulation inputs sequentially
    initial begin
        tb_in = 16'h0000;
        #10;

        // Test Case 1: NOOP (Opcode 0000)
        tb_in = 16'b0000_0000_0000_0000; 
        #10;

        // Test Case 2: INPUTC (Opcode 0001, RY 00)
        tb_in = 16'b0001_0000_0000_0000; 
        #10;

        // Test Case 3: SHIFTR (Opcode 0111, C8/RY[0] = 1)
        tb_in = 16'b0111_0000_0001_0000; 
        #10;

        // Test Case 4: MOVE (Opcode 0010)
        tb_in = 16'b0010_0110_0000_0000; 
        #10;

        // Test Case 5: JUMP (Opcode 1110)
        tb_in = 16'b1110_0000_0000_0000; 
        #10;

        // Test Case 6: BRE/BRZ (Opcode 1111, RY 00)
        tb_in = 16'b1111_0000_0000_0000; 
        #10;

        $finish; 
    end

    // 5. Setup file dumping for GTKWave
    initial begin
        $dumpfile("simulation_output.vcd");
        $dumpvars(0, decoder_tb);
    end

endmodule
