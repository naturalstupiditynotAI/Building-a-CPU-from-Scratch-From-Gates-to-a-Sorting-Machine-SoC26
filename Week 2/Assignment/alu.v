// Week 2 — 8-bit ALU
// op: 000=ADD 001=SUB 010=AND 011=OR 100=XOR 101=SHIFTL 110=SHIFTR
// Run: iverilog -o sim ../testbenches/tb_alu.v alu.v && vvp sim

module alu(
    input  [7:0]     a, b,
    input  [2:0]     op,
    output reg [7:0] result,
    output reg       zero,
    output reg       carry,
    output reg       overflow
    );
    reg [8:0] temp;
    always@(*)
    begin 
    temp=9'b0;
        case(op)
            3'b000: 
                begin 
                    result = a+b;
                    temp = a+b;  
                end
            3'b001: 
                begin 
                result = a-b;
                temp = a-b; 
                end
            3'b010: result = a&b;
            3'b011: result = a|b;
            3'b100: result = a^b;
            3'b101: result = a<< 1;
            3'b110: result = a>> 1;

        endcase

          if(result==8'b0)
              zero=1; 
          else zero=0; 
          
          if(op==3'b000||op==3'b001)
              carry=temp[8]; 
          else carry=1'b0; 

          if((op==3'b000&&a[7]==b[7]&&result[7]!=a[7])||(op==3'b001&&a[7]!=b[7]&&result[7]!=a[7]))
              overflow=1; 
          else overflow=0;
          
        end
endmodule
