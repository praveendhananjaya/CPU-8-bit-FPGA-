module reg_file(

    input [7:0] IN ,                                                    // input data port
    output reg [7:0] OUT1 , OUT2 ,                                      // output data port
    input [2:0] INADDRESS , OUT1ADDRESS , OUT2ADDRESS,                  // input output address
    input  WRITE , CLOCK , RESET                                        // write enable , clock , reset
     );
    reg [7:0] Regout0 , Regout1 , Regout2 , Regout3 , Regout4 , Regout5 , Regout6 , Regout7  ;// Registers  to save data 0 - 7

    always @( posedge RESET)                                            // reset pulse - reset all Registers
      begin
      #4 ;                                                              // reset 2 time  // read  2 time
      Regout0 = 8'b00000000 ;
      Regout1 = 8'b00000000 ;
      Regout2 = 8'b00000000 ;
      Regout3 = 8'b00000000 ;
      Regout4 = 8'b00000000 ;
      Regout5 = 8'b00000000 ;
      Regout6 = 8'b00000000 ;
      Regout7 = 8'b00000000 ;
      OUT1    = 8'b00000000 ;
      OUT2    = 8'b00000000 ;
      
      
    end
    
    always @( posedge CLOCK * WRITE )                                          // positive egde clock
    begin  

                                                    // write data to register    
        #1 ;                                                            // writing delay  
        case(INADDRESS)                                                 // write file
            3'b000:
                Regout0 = IN ;
            3'b001:
                Regout1 = IN ;
            3'b010:
                Regout2 = IN ;
            3'b011:
                Regout3 = IN ;
            3'b100:
                Regout4 = IN ;
            3'b101:
                Regout5 = IN ;
            3'b110:
                Regout6 = IN ;
            3'b111:
                Regout7 = IN ;

        endcase
    
    end 
   
     always @( OUT1ADDRESS , OUT2ADDRESS ) begin                     // data reading when positive edge and negitive Write
         
            #2 ;                                                                                // read dealay
            case( OUT1ADDRESS )                                                                 // data registers 1

                3'b000:
                    OUT1 = Regout0 ;
                3'b001:
                    OUT1 = Regout1 ;
                3'b010:
                    OUT1 = Regout2 ;
                3'b011:
                    OUT1 = Regout3 ;
                3'b100:
                    OUT1 = Regout4 ;
                3'b101:
                    OUT1 = Regout5 ;
                3'b110:
                    OUT1 = Regout6 ;
                3'b111:
                    OUT1 = Regout7 ;
            endcase

            case( OUT2ADDRESS )                                                 // data registers 1 
                3'b000:
                    OUT2 = Regout0 ;
                3'b001:
                    OUT2 = Regout1 ;
                3'b010:
                    OUT2 = Regout2 ;
                3'b011:
                    OUT2 = Regout3 ;
                3'b100:
                    OUT2 = Regout4 ;
                3'b101:
                    OUT2 = Regout5 ;
                3'b110:
                    OUT2 = Regout6 ;
                3'b111:
                    OUT2 = Regout7 ;
            endcase
            
    end

endmodule