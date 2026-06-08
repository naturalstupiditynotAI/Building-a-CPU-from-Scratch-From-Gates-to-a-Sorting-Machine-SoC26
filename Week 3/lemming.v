//there are 2 states in the FSM: Walk left and walk right
//the 2 states represent the direction in which the character is walking 

module lemmings_1(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input reg bump_left,
    input reg bump_right,
    output  walk_left,
    output  walk_right); //  

    parameter LEFT=0, RIGHT=1;
    reg state, next_state;

    always @(*) begin
        case(state)
            LEFT: next_state= bump_left? RIGHT:LEFT; 
            RIGHT: next_state= bump_right?LEFT:RIGHT;
        endcase
    end

    always @(posedge clk, posedge areset) begin
        if(areset) begin
           state=LEFT; 
        end 
        else 
            state=next_state;// State flip-flops with asynchronous reset
    end

    // Output logic
            assign walk_left = (state == LEFT);
            assign walk_right = (state == RIGHT);

endmodule


//there are 4 states in the FSM, representing the direction of current and previous motion[if needed]

module lemmings_2(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
    input ground,
    output walk_left,
    output walk_right,
    output aaah ); 
    
    reg [1:0] state, nextstate; 
    parameter LEFT=0, RIGHT=1, LEFT_FALL=2, RIGHT_FALL=3; 
    always@(*) begin
        if(ground)
            case(state) 
                LEFT: nextstate= bump_left? RIGHT:LEFT; 
                RIGHT: nextstate = bump_right? LEFT: RIGHT; 
                LEFT_FALL: nextstate =LEFT;
				RIGHT_FALL:nextstate = RIGHT;
            endcase 
        else 
            case(state)
                LEFT: nextstate= LEFT_FALL;
                RIGHT: nextstate=RIGHT_FALL; 
                LEFT_FALL: nextstate = LEFT_FALL; 
				RIGHT_FALL:nextstate = RIGHT_FALL;
            endcase 
    end 
    always@(posedge clk, posedge areset) begin
        if(areset)
            state<=LEFT;
        else 
        state<=nextstate;
    end
    assign walk_left=(state==LEFT); 
    assign walk_right=(state==RIGHT);
    assign aaah=(state==LEFT_FALL||state==RIGHT_FALL); 
        endmodule

//6 states FSM 

module lemmings_3(
 input clk,
input areset, // Freshly brainwashed Lemmings walk left.
input bump_left,
input bump_right,
input ground,
input dig,
output walk_left,
output walk_right,
output aaah,
output digging);

    reg [5:0] state, nextstate;
parameter L=0, R=1, FL=2, FR=3,DL=4, DR=5;

always@(*) begin
    nextstate[L]= (state[L]&~bump_left&ground | state[FL]&ground|state[R]&bump_right&ground);
    nextstate[R]= state[R]&~bump_right&ground | state[FR]&ground | state[L]&bump_left&ground;
nextstate[FL]= state[L]&~ground | state[DL]&~ground|state[FL]&~ground;
nextstate[FR]=state[R]&~ground | state[DR]&~ground | state[FR]&~ground;
    nextstate[DL]= state[L]&dig&ground |state[DL]&ground;
    nextstate[DR]= state[R]&dig&ground|state[DR]&ground;
    if(nextstate[DL]|nextstate[DR]) nextstate[L]=0; 
    if(nextstate[DL]|nextstate[DR]) nextstate[R]=0; 
    
end

always@(posedge clk, posedge areset) begin
if(areset) begin
    state[L]<=1;
    state[R]<=0; state[FR]<=0; state[DR]<=0; state[DL]<=0; state[FL]<=0; end
else
     state<=nextstate;
end

assign walk_left= (state[L]);
assign walk_right= (state[R]);
assign aaah= (state[FR]|state[FL]);
assign digging =(state[DR]| state[DL]);
   
endmodule



