
`timescale 1ns /  1ps

module alu(
    input  [7:0] DATA1 , DATA2 ,            // ALU 8 bit input
    output reg [7:0] RESULT ,               // ALU output
    input  [2:0] SELECT  ,                  // ALU selector
    output reg ZERO                   // beq  
    
    );

    always @( DATA1 , DATA2 , SELECT )     //  select sensitive is more suitable
    begin                           
      case( SELECT )
      3'b000:                              // Forward
        RESULT <= #1 DATA2 ;
      3'b001:
        begin 
        #2 ;  
        RESULT =  DATA1 + DATA2  ;         // Add ,
        ZERO = ~(RESULT[0] | RESULT[1] | RESULT[2] | RESULT[3] | RESULT[4] | RESULT[5] | RESULT[6] |RESULT[7]);
        end
      3'b010:
        RESULT <= #1 DATA1 & DATA2  ;         // AND
      3'b011:
        RESULT <= #1 DATA1 | DATA2  ;         // Or
    
                                           // reserved for future functions units 
      endcase
    end



endmodule

