//  vector      memory array
reg [1:0] register2d [0:127]; // 128 separate 2bit registers
//  
reg [1:0][127:0] vector2d; // 256bit register organised into 128 groups of 2
//            rows  cols
reg  array2d [0:15][0:15]; // 16x16 array

assign a ? b : c;

assign concatenate = {a, b, c};

assign replicate = {2{1'b1}}; // 2'b11

always @(*) begin
    reduction = &replicate; // replicate[0] & replicate[1]
    ^replicate;             // replicate[0] XOR replicate[1]
end

module instanceArray [99:0] ( 

    // bit 0 goes to instance 0

);
endmodule 

assign vectorpartselect = w[x +: y]; // = w[x:(x + y - 1)]

// 'checkerboard' KMAP
// -  odd # in = 1: XOR
// - even # in = 1: XNOR

// 'arithmetic': preserve sign via /2
module arithmeticRightShift (
    input clk,
    input load,
    input ena,
    input [1:0] amount,
    input [63:0] data,
    output reg [63:0] q); 
    
    // $signed(q) forces signed
    always_ff @(posedge clk) begin
        if (load) begin
            q <= data;
        end else begin
            if (ena) begin 
                case (amount) 
                    2'b00 : q <= q << 1;
                    2'b01 : q <= q << 8;
                    2'b10 : q <= $signed(q) >>> 1; 
                    2'b11 : q <= $signed(q) >>> 8;
                endcase
            end
        end 
    end 

endmodule

// FSMs
// moore: depend on current state
// mealy: depend on current state + current input