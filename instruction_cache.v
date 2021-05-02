`include "instruction_memory.v"

module instruction_cache (

    input               clock, read,reset ,
    input[9:0]          address,
    output reg [32:0]   readdata,
    output reg          busywait

);

reg [133:0] Cache[7:0] ;    // [134:0] = valid[1] + tag [4:0]  + data[127:0] 
// off set [1:0]

reg valid  ,  hit ;
reg [5:0] mem_address ;
reg mem_read ;

wire[2:0] index ;
wire[2:0] tag ;
wire[3:0] offset ;

assign tag    = address[9:7] ;
assign index  = address[6:4] ;
assign offset = address[3:0] ;

Instruction_memory Instruction_memory( clock , mem_read , mem_address , ,  ) ;

always @( address * read )
begin

    
    #1 ;                // word select 
    valid    = Cache [index][133] ;
    
    if ( tag == Cache[index][132:128] )
    begin
      #1 ;  // tag delay
      hit = 1'b1 ;
    end else begin
      #1 ;  // tag delay
      hit = 1'b0 ;
    end

    if ( hit * valid  )
    begin 

      case ( offset )                         // select block
        4'b0000 : readdata = Cache[ index ][  31 :  0 ] ;
        4'b0100 : readdata = Cache[ index ][  63 : 32 ] ;
        4'b1000 : readdata = Cache[ index ][  95 : 64 ] ;
        4'b1100 : readdata = Cache[ index ][ 128 : 96 ] ; 
      endcase
        busywait = 1'b0 ;
        mem_read = 1'b0 ;
    end else begin
      busywait = 1'b1 ;   // busy 
      mem_read    = 1'b1 ; // instr memory 
      mem_address = { tag , index } ;
      @Instruction_memory.busywait ;        // busy up
      @Instruction_memory.busywait ;        // busy down      // 80 cycle
      
                                                             // 81 cycle
      #1 ;                                  // tag , valid , cache update 
      Cache[index][127:  0] = Instruction_memory.readdata ; 
      Cache[index][132:128] = tag ; 
      Cache[index][    133] = 1'b1; 
      case ( offset )                       // put data in cache
        4'b0000 : readdata <= #2 Cache[ index ][  31 :  0 ] ;
        4'b0100 : readdata <= #2 Cache[ index ][  63 : 32 ] ;
        4'b1000 : readdata <= #2 Cache[ index ][  95 : 64 ] ;
        4'b1100 : readdata <= #2 Cache[ index ][ 128 : 96 ] ; 
      endcase

        #1 ;                              // word select 
        valid    = Cache [index][133] ;
    
        if ( tag == Cache[index][132:128] )
        begin
          #1 ;  // tag delay
          hit = 1'b1 ;
        end else begin
          #1 ;  // tag delay
          hit = 1'b0 ;
        end

        if ( hit * valid  )
        begin 

          case ( offset )                 // select data
            4'b0000 : readdata = Cache[ index ][  31 :  0 ] ;
            4'b0100 : readdata = Cache[ index ][  63 : 32 ] ;
            4'b1000 : readdata = Cache[ index ][  95 : 64 ] ;
            4'b1100 : readdata = Cache[ index ][ 128 : 96 ] ; 
          endcase
        end
      @(posedge clock)  
      busywait = 1'b0 ;                   // de assert busy wait
      mem_read = 1'b0 ;                   // mem read stop
    end

end



// reset 
always @( posedge reset )
begin
  // reset cache
  Cache[0]   = 128'b0 ;
  Cache[1]   = 128'b0 ;
  Cache[2]   = 128'b0 ;
  Cache[3]   = 128'b0 ;
  Cache[4]   = 128'b0 ;
  Cache[5]   = 128'b0 ;
  Cache[6]   = 128'b0 ;
  Cache[7]   = 128'b0 ;

  // reset registers
  busywait   = 1'b0 ; 
  readdata   = 32'b0 ; 
  valid      = 1'b0 ; 
  hit        = 1'b0 ;

end

endmodule