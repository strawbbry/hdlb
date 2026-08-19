module basic (
    input  logic clock,
    input  logic sel,
    output logic blocking,
    output logic nonblocking
);

// logic: declare init value
logic   outside = 1'b1;
//  wire: inputs will change, recompute!
wire    dontcare = 4'b1zz1;

// 1 purpose = 1 always block (u can have more than 1!)

always_comb begin : combBlock
    outside = dontcare[0] + dontcare[1]; // 'assign'

    case (sel)
        1'b0:    blocking = 1'b1;
        1'b1:    blocking = 1'b0;
        default: blocking = 1'b0;
    endcase
end

always_ff @(posedge clock) begin : seqBlock
    nonblocking <= 1'b1;
end

endmodule


module fulladder ( input a, input b, input cin, output sum, output cout );

	assign sum = a ^ b ^ cin;
    assign cout = a & b | a & cin | b & cin; 

endmodule


module asyncreset ( input clk, input areset, input ena, input [7:0] d, output [7:0] q );
    
    //          rising edge     falling edge
    always_ff @(posedge clk or negedge areset) begin
        if (areset)
            q <= 8'b0;
        else 
            q <= d;
    end 

    // latch = level-sensitive to i/o signal 'enable'
    always_latch begin 
        if (ena)
            q <= d;
    end

endmodule


module counter ( input clk, input reset, output [3:0] q );
    
    always_ff @(posedge clk) begin
        if (reset) begin
            q <= 4'b0;
        end else begin
            q <= q + 4'b1;
        end 
    end 

endmodule


module shiftregister ( input clk, input areset, input load, input ena, input [3:0] data, output logic [3:0] q); 

    always_ff @(posedge clk or posedge areset) begin
        if (areset) begin
            q <= 4'b0;
        end else begin
            if (load) begin
                q <= data;
            end else begin 
                if (ena) begin
                    q <= q >> 1;
                end 
            end 
        end 
    end 

endmodule


module lookuptable (
    input clk,
    input enable,
    input S,
    input A, B, C,
    output Z ); 
    
    logic [7:0] Q;
    
    // 'random access' (RAM) read
    always_ff @(posedge clk) begin
        if (enable) begin
            Q <= {Q[6:0], S};
        end 
    end 
    
    always_comb begin
        case ({A, B, C})
            3'b000 : Z = Q[0];
            3'b001 : Z = Q[1];
            3'b010 : Z = Q[2];
            3'b011 : Z = Q[3];
            3'b100 : Z = Q[4];
            3'b101 : Z = Q[5];
            3'b110 : Z = Q[6];
            3'b111 : Z = Q[7];
        endcase
    end

endmodule


// forloop =/= _ cycles (use counter!)
module forloop (input clk, input load, input [511:0] data, output [511:0] q ); 
    
    genvar i;

    always_ff @(posedge clk) begin
        if (load) begin
            q <= data;
        end else begin
            for (int i = 0; i < 512; i = i + 1) begin 
                q[i] <= ((i == 0) ? 1'b0 : q[i-1]) ^ ((i == 511) ? 1'b0 : q[i+1]);
            end 
        end 
    end

endmodule


// serial 2's complementer
module moorefsm (
    input clk,
    input areset,
    input x,
    output z
);

    // states
    typedef enum logic [1:0] { 
        A = 2'd0,
        B = 2'd1,
        C = 2'd2,
        D = 2'd3
    } states;
    
    states state, next_state;
    
    always_comb begin
        case (state) // moore: x in next state eq only
            A : next_state = x ? B : A;
            B : next_state = x ? C : D;
            C : next_state = x ? C : D;
            D : next_state = x ? C : D;
        endcase
    end 
    
    always_ff @(posedge clk or posedge areset) begin
        if (areset) begin
            state <= A;
        end else begin
            state <= next_state;
        end 
    end
    
    always_comb begin
        case (state) 
            A : z = 0;
            B : z = 1;
            C : z = 0;
            D : z = 1;
        endcase
    end 

endmodule


// serial 2's complementer (via 1-hot encoding)
module mealyfsm (
    input clk,
    input areset,
    input x,
    output z
); 

    // states
    parameter A = 0, B = 1;
    logic [1:0] state;
    
    always_ff @(posedge clk or posedge areset) begin
        if (areset) begin
            state <= 2'b01;
        end else begin
            if (state[A]) begin 
                state <= x ? 2'b10 : 2'b01;
            end else begin 
                state <= state;
            end 
        end
    end 
    
    always_comb begin  // mealy: x in output eq too!
        if (state[A]) 
            z = x;
        else if (state[B])
            z = ~x;
        else 
            z = 0;
    end

endmodule