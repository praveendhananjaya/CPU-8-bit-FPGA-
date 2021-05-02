`timescale 1ns / 1ps
`include "reg_file.v"
`include "alu.v"
`include "dcache.v"
`include "instruction_cache.v"

module CPU( 
  input CLOCK , RESET 
 );
    reg [31:0] PC ;

    wire [7:0] REGOUT1 , REGOUT2  ;                                                                                    // output data port
    reg [2:0] WRITEREG , READREG1 , READREG2 ;                                                                         // input output address
    reg  WRITEENABLE  = 1'b1  ;                                                                                        // write enable , clock , reset

    reg_file myregfile( dataW.out , REGOUT1 , REGOUT2 , WRITEREG , READREG1 , READREG2 , WRITEENABLE, CLOCK , RESET );    // REGISTER FILE 

    wire [7:0]  OPERAND1 ;                      // alu data1 , data2                                                     // ALU 8 bit input
    wire [7:0]  ALURESULT ;                     // alu output                                                            // ALU output
    reg  [2:0]  ALUOP ;                         // alu selector                                                          // ALU selector
      
    alu alu ( REGOUT1 , OPERAND1 , ALURESULT , ALUOP ,  );

    data_write_selector dataW( ) ;

    reg pc_cache_read ;
    reg[9:0] pc_address ; 
    instruction_cache instruction_cache(CLOCK,pc_cache_read,RESET,pc_address,,);

    wire [31:0] oneInstr  ; 
    assign oneInstr = instruction_cache.readdata ;

    // data memory 
    reg data_memory_write , data_memory_read ;
    dcache dcache ( CLOCK , RESET , data_memory_read , data_memory_write , alu.RESULT , REGOUT1 , , );

  always@( posedge RESET )                                                                              // register reset 
  begin
    #1 ;
    PC = -4 ;
    offset = 7'b0 ;
    dcache.busywait = 1'b0 ;
    alu.ZERO = 1'b0 ;

  end


 
  reg  [7:0] IMMEDIATE , TWOCOMPOUT ;                                                                   // IMMEDIATE , TWOCOMPOUT 
  reg [7:0] OPCODE , DESTINATION , SOPERAND1 , offset ;                                                 // OPCODE , DESTINATION , SOPERAND1 , jump off set  


  wire [7:0] IMMEDIATE_MUXOUT , TWO_COMP_MUX_OUT ;                                                      // IMMEDIATE , TWOCOMPOUT mux output
  reg [0:0] IMMEDIATE_MUXSELEC , TWO_COMP_MUX_SELEC ;                                                   // IMMEDIATE_MUXSELEC (0-immed , 1-2s com mux ) , TWO_COMP_MUX_SELEC (0- regout2 , 1-2s comp)

  twoscom twoscom(REGOUT2,);

   MUX IMMEDIATE_MUX ( IMMEDIATE , TWO_COMP_MUX_OUT , IMMEDIATE_MUXSELEC , OPERAND1 ) ;
   MUX TWOCOMPOUT_MUX ( REGOUT2  , twoscom.out , TWO_COMP_MUX_SELEC , TWO_COMP_MUX_OUT  ) ;
  PC_mod PC_mod(offset);

  always @( oneInstr )
  begin
    {OPCODE,DESTINATION,SOPERAND1} = oneInstr[31:8] ;     // input instruction seperate ,
    IMMEDIATE =  oneInstr[7:0] ;  
    WRITEREG = DESTINATION[2:0] ;
    offset = 7'b0 ;                                       // jump off set make zero 
    READREG1 = SOPERAND1[2:0] ;
    READREG2 = oneInstr[2:0] ;
    dataW.in <=#1 1'b0 ;
    
  
      // decode delay                                                                                                                          
    case (OPCODE[3:0])                                                                                                                                                                                                              // mux path set up , register file read address set up , trun on write enable and turn off write enable
      4'b0000 :  begin  WRITEENABLE  <= #4 1'b1  ;  IMMEDIATE_MUXSELEC <= #1 1'b0 ; ALUOP <= #1 3'b000 ;    end                                                                                           // load!  , immed mux bypass immediate , alu forwar setup
      4'b0010 :  begin  WRITEENABLE  <= #4 1'b1  ;  IMMEDIATE_MUXSELEC <= #1 1'b1 ; ALUOP <= #1 3'b001 ; TWO_COMP_MUX_SELEC <= #1 1'b0 ;  end     // add mux path set
      4'b0011 :  begin  WRITEENABLE  <= #4 1'b1  ;  IMMEDIATE_MUXSELEC <= #1 1'b1 ; ALUOP <= #1 3'b001 ; TWO_COMP_MUX_SELEC <= #1 1'b1 ;  end     // sub make second number nagative
      4'b0100 :  begin  WRITEENABLE  <= #4 1'b1  ;  IMMEDIATE_MUXSELEC <= #1 1'b1 ; ALUOP <= #1 3'b010 ; TWO_COMP_MUX_SELEC <= #1 1'b0 ;  end     // and 
      4'b0101 :  begin  WRITEENABLE  <= #4 1'b1  ;  IMMEDIATE_MUXSELEC <= #1 1'b1 ; ALUOP <= #1 3'b011 ; TWO_COMP_MUX_SELEC <= #1 1'b0 ;  end     // or
      4'b0001 :  begin  WRITEENABLE  <= #4 1'b1  ;  IMMEDIATE_MUXSELEC <= #1 1'b1 ; ALUOP <= #1 3'b000 ; TWO_COMP_MUX_SELEC <= #1 1'b0 ;  end                                // mov
      4'b0110 :  begin  offset = DESTINATION ; alu.ZERO <= #2 1'b1 ; ALUOP <= #1 3'b111 ; end// j selct mux
      4'b0111 :  begin  IMMEDIATE_MUXSELEC <= #1 1'b1 ; ALUOP <= #1 3'b001 ; TWO_COMP_MUX_SELEC <= #1 1'b1 ;  offset = DESTINATION ;   end                                  //beq , 1st and 2nd data compara inside alu , if comparador = 1  , then pc change + offset                                      // beq
      4'b1000 :  begin  WRITEENABLE <= #4 1'b1   ;  IMMEDIATE_MUXSELEC <= #1 1'b1 ; ALUOP <= #1 3'b000 ; TWO_COMP_MUX_SELEC <= #1 1'b0 ; dataW.in <=#1 1'b1 ; data_memory_read <= #3 1'b1 ; data_memory_write <= #3 1'b0 ;  end // lwd 
      4'b1001 :  begin  WRITEENABLE <= #4 1'b1   ;  IMMEDIATE_MUXSELEC <= #1 1'b0 ; ALUOP <= #1 3'b000 ; TWO_COMP_MUX_SELEC <= #1 1'b0 ; dataW.in <=#1 1'b1 ; data_memory_read <= #2 1'b1 ; data_memory_write <= #2 1'b0 ; end // lwi
      4'b1010 :  begin  IMMEDIATE_MUXSELEC <= #1 1'b1 ; ALUOP <= #1 3'b000 ; TWO_COMP_MUX_SELEC <= #1 1'b0 ; dataW.in <=#1 1'b1 ; data_memory_read <= #3 1'b0 ; data_memory_write <= #3 1'b1 ; end // swd
      4'b1011 :  begin  IMMEDIATE_MUXSELEC <= #1 1'b0 ; ALUOP <= #1 3'b000 ; TWO_COMP_MUX_SELEC <= #1 1'b0 ; dataW.in <=#1 1'b1 ; data_memory_read <= #2 1'b0 ; data_memory_write <= #2 1'b1 ; end  // swi
    endcase
                                                                                                                                       

  end
 
  
  
endmodule

module MUX(
  input [7:0] in1 , in2 ,
  input [0:0]  MUXselector ,
  output reg [7:0] out
);
  
  always@ (in1,in2,MUXselector)
  begin
    case ( MUXselector )                // mux select
      1'b0  :  out = in1 ;
      1'b1  :  out = in2 ;
    endcase
     
  end

endmodule


module PC_mod( 

  input  [7:0] offset 
 );
 
 // always@ (  )

  always@ (  posedge CPU.CLOCK   )  // stall the cpu when busywait = 1 
  begin
    
    #1 ;
    CPU.pc_cache_read = 1'b1 ; 
    if ( ~(dcache.busywait || instruction_cache.busywait )  )
      begin
          CPU.data_memory_read =  1'b0 ; CPU.data_memory_write =  1'b0 ; 
          CPU.PC[31:2] =  CPU.PC[31:2] + { 20'hfffff*offset[7] , 2'b11*offset[7] , offset[7:0] }*alu.ZERO ;  // change pc value 31-2 (only change by 4 * x  ) , 31-10 sign bit expand by 11111*sign value , ZERO is overall control gate
          CPU.offset  =  7'b0 ;         // after pc change ,  offset and zero chage again into zero 
          alu.ZERO = 1'b0 ;
          CPU.WRITEENABLE  =  1'b0  ;                            // trun off write 
          if ( ~CPU.PC[31] )
          begin
            
            CPU.pc_address = CPU.PC[31:0] ;                     // assign address
          //  @(instruction_cache.readdata)  ;
            //CPU.oneInstr   =  instruction_cache.readdata ;
           // instruction_cache.readdata = 32'b0 ;
            
          end 

          if ( ~instruction_cache.busywait  ) 
          begin  
            CPU.PC         =#1 CPU.PC + 4 ;    // pc update 
           // @( posedge CPU.CLOCK )
            CPU.pc_cache_read = 1'b0 || instruction_cache.busywait ;    // read status
          end         

      end 
        
      
  end

endmodule

module twoscom(
    input[7:0] in ,
    output reg [7:0] out  
);
    always@(in)
    begin
      out <= #1 ~in + 1'b1 ;
    end

endmodule

module data_write_selector(   //  select memory or alu out
    output reg [7:0] out 
);
    reg in ;

    always @( in , alu.RESULT , dcache.readdata )   
    begin
        case (in)
          1'b0: out = alu.RESULT ;                
          1'b1: out = dcache.readdata ; 
        endcase
    end

endmodule