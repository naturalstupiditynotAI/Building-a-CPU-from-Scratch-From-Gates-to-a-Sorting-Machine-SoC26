`timescale 1ns/1ps

module testbench;

    reg clk;
    reg reset;

    main dut (
        .clk(clk),
        .reset(reset)
    );

    // 10ns clock period
    initial clk = 0;
    always #5 clk = ~clk;

    integer cycle_count;
    parameter MAX_CYCLES = 500;

    // Expected result: bubble sort of {7,3,2,1,6,4,5,8} ascending
    reg [7:0] expected [0:7];
    integer i;
    integer errors;

    initial begin
        expected[0]=8'd1; expected[1]=8'd2; expected[2]=8'd3; expected[3]=8'd4;
        expected[4]=8'd5; expected[5]=8'd6; expected[6]=8'd7; expected[7]=8'd8;

        $dumpfile("bubble_sort_sim.vcd");
        $dumpvars(0, testbench);

        errors = 0;
        cycle_count = 0;
        reset = 1'b1;

        @(posedge clk);
        @(posedge clk);
        reset = 1'b0;
    end

    // Trace + termination: program ends by looping on the NOOP at address 51
    // (End: NOOP has no branch out, so pc parks there once sorting is done).
    always @(posedge clk) begin
        if (!reset) begin
            cycle_count = cycle_count + 1;

            $display("t=%0t cyc=%0d pc=%0d instr=%b | A=%0d B=%0d C=%0d D=%0d | Z=%b N=%b V=%b C=%b",
                       $time, cycle_count, dut.pc, dut.instr,
                       dut.RF.regs[0], dut.RF.regs[1], dut.RF.regs[2], dut.RF.regs[3],
                       dut.zf, dut.nf, dut.vf, dut.cf);

            // Program is done once PC reaches the End: NOOP at address 51
            // and has settled there (NOOP keeps incrementing PC forever with
            // no side effects, so give it a couple of extra cycles then stop).
            if (dut.pc == 8'd52) begin
                repeat (2) @(posedge clk);
                check_result;
                $finish;
            end

            if (cycle_count >= MAX_CYCLES) begin
                $display("\n--- Watchdog: MAX_CYCLES reached without completion ---");
                $display("Array did not finish sorting in time; dumping current state:");
                dump_array;
                $finish;
            end
        end
    end

    task dump_array;
        integer k;
        begin
            $display("\n=== Data Memory[0:7] (the array) ===");
            for (k = 0; k < 8; k = k + 1)
                $display("array[%0d] = %0d", k, dut.DMEM.ram[k]);
        end
    endtask

    task check_result;
        integer k;
        begin
            dump_array;
            errors = 0;
            for (k = 0; k < 8; k = k + 1) begin
                if (dut.DMEM.ram[k] !== expected[k]) begin
                    $display("MISMATCH at array[%0d]: got %0d, expected %0d",
                              k, dut.DMEM.ram[k], expected[k]);
                    errors = errors + 1;
                end
            end
            if (errors == 0)
                $display("\n*** PASS: array correctly sorted in %0d cycles ***", cycle_count);
            else
                $display("\n*** FAIL: %0d mismatches ***", errors);
        end
    endtask

endmodule
