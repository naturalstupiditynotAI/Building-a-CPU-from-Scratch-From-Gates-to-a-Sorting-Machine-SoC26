module decoder(
    input [15:0] in,
    output reg [15:0] o4to16, 
    output reg [3:0] o2to4A, 
    output reg [3:0] o2to4B,
    output reg [1:0] o1to2, 
    output reg NOOP, MOVE,LOADI,ADD,ADDI,SUB,SUBI,LOAD,LOADF,STORE,STOREF,CMP, JUMP, INPUTC,INPUTCF,
    INPUTD,INPUTDF,SHIFTL,SHIFTR,BRE,BRNE,BRG,BRGE,
    output reg [7:0] ADDR,
    output reg [1:0] RY, RX

);

    always @(*) begin
   o4to16 = 16'b0; o2to4A = 4'b0; o2to4B = 4'b0; o1to2 = 2'b0;
        NOOP = 0; MOVE = 0; LOADI = 0; ADD = 0; ADDI = 0; SUB = 0; SUBI = 0;
        LOAD = 0; LOADF = 0; STORE = 0; STOREF = 0; CMP = 0; JUMP = 0;
        INPUTC = 0; INPUTCF = 0; INPUTD = 0; INPUTDF = 0;
        SHIFTL = 0; SHIFTR = 0; BRE = 0; BRNE = 0; BRG = 0; BRGE = 0;  
   
    // 4-to-16 decoder logic
    case (in[15:12])
      0: o4to16[0] = 1;
      1: o4to16[1] = 1;
      2: o4to16[2] = 1;
      3: o4to16[3] = 1;
      4: o4to16[4] = 1;
      5: o4to16[5] = 1;
      6: o4to16[6] = 1;
      7: o4to16[7] = 1;
      8: o4to16[8] = 1;
      9: o4to16[9] = 1;
      10: o4to16[10] = 1;
      11: o4to16[11] = 1;
      12: o4to16[12] = 1;
      13: o4to16[13] = 1;
      14: o4to16[14] = 1;
      15: o4to16[15] = 1;

     default: o4to16 = 16'b0; // For input '1111'
        endcase

     if(o4to16[1]==1) begin 
        case(in[9:8])
            0: o2to4A[0] = 1;
            1: o2to4A[1] = 1;
            2: o2to4A[2] = 1;
            3: o2to4A[3] = 1;
            default: o2to4A = 4'b0; // For input '11'
           endcase 
     end


    if(o4to16[15]==1) begin 
        case(in[9:8])
            0: o2to4B[0] = 1;
            1: o2to4B[1] = 1;
            2: o2to4B[2] = 1;
            3: o2to4B[3] = 1;
            default: o2to4B = 4'b0; // For input '11'
           endcase 
     end

    if(o4to16[12]==1) begin 
        case(in[8])
            0: o1to2[0] = 1;
            1: o1to2[1] = 1;
            default: o1to2 = 2'b0; // For input '11'
           endcase 
     end

    NOOP= o4to16[0];
    MOVE= o4to16[2];
    LOADI= o4to16[3];
    ADD= o4to16[4];
    ADDI= o4to16[5];
    SUB= o4to16[6];
    SUBI= o4to16[7];
    LOAD= o4to16[8];
    LOADF= o4to16[9];
    STORE= o4to16[10];
    STOREF= o4to16[11];
    CMP= o4to16[13];
    JUMP= o4to16[14];
    INPUTC= o2to4A[0];
    INPUTCF= o2to4A[1];
    INPUTD= o2to4A[2];
    INPUTDF= o2to4A[3];
    SHIFTL= o1to2[0];
    SHIFTR= o1to2[1];
    BRE= o2to4B[0];
    BRNE= o2to4B[1];
    BRG= o2to4B[2];
    BRGE= o2to4B[3];
    ADDR= in[7:0];
    RY= in[9:8];
    RX= in[11:10];
    
    end
    endmodule

