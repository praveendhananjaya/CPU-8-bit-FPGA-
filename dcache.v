`include "data_memory.v"

module dcache (
    input           clock,
    input           reset,
    input           read,
    input           write,
    input[7:0]      address,
    input[7:0]      writedata,
    output reg [7:0]readdata,
    output reg      busywait
);
    // data status
    reg valid , dirty , hit ;
    // mem reg 
    reg mem_read , mem_write   ;
    reg [5:0] mem_address ;
    reg [31:0] mem_writedata ; 
    data_memory memory ( clock , reset , mem_read , mem_write , mem_address , mem_writedata ,, ) ;

    wire [1:0] offset ;
    wire [2:0] tag ;
    wire [2:0] index ;

    assign offset = address[1:0] ;
    assign index  = address[4:2] ;
    assign tag    = address[7:5] ;

    reg status ;                 // fire controller

    
    reg [36:0] Cache [7:0];      // [38:0] = valid[1] + drity[1] + tag[2:0] + data[31:0]  ,{ tag[2:0] + index[2:0] +  + offset[1:0] }

    // reading cache and writing hit
    always @( address * (read | write) , busywait )
    begin
        if ( read | write )
        begin
            busywait = 1'b1 ;                                           // busy on
             #1 ;                                                       // word selection delay , tag , valid  , drity
             valid = Cache[index][36] ;
             dirty = Cache[index][35] ;     
                if (   tag == Cache[index][34:32]   ) 
                begin
                    #1 ;                                                
                    hit = 1'b1  ;                                       // hit , dalay
                end else begin
                    #1 
                    hit = 1'b0  ;
                end

                if ( read * hit * valid )                               // read data from cache
                begin
                    case ( offset )                                     
                        2'b00: readdata = Cache[index][ 31:24 ]  ;
                        2'b01: readdata = Cache[index][ 23:16 ]  ;
                        2'b10: readdata = Cache[index][ 15: 8 ]  ;
                        2'b11: readdata = Cache[index][  7: 0 ]  ;
                    endcase
                    busywait = 1'b0 ;                                   // busy off
                end else if ( write * ( hit  || ( ~valid ) ) )
                    begin
                    Cache[index][34:32] = tag ; 
                    Cache[index][36]    = 1'b1 ;       // valid
                    Cache[index][35]    = 1'b1 ;       // drity 
                    case ( offset )
                        2'b00:  Cache[index][ 31:24 ] = writedata ;
                        2'b01:  Cache[index][ 23:16 ] = writedata ;
                        2'b10:  Cache[index][ 15: 8 ] = writedata ;
                        2'b11:  Cache[index][  7: 0 ] = writedata ;
                    endcase
                    busywait = 1'b0 ;                                   // busyoff
                end else begin
                  //  #1 ;
                    @(posedge clock)
                    status   = 1'b1 ;                                   // fire control off
                end
        end
    end



    
    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_READ = 3'b001 , MEM_WRITE_BACK = 3'b010 ;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @( * )
    begin

            case (state)
                IDLE:
                    if ((read || write) && !dirty && !hit)              // only miss read not dirty
                        next_state = MEM_READ ;
                    else if ( (read || write) && dirty && !hit )        // only miss write back
                        next_state = MEM_WRITE_BACK ;
                    else
                        next_state = IDLE;                              // idle
                
                MEM_READ:                                               // only miss read not dirty
                    if (! memory.busywait )
                        next_state = IDLE ;
                    else    
                        next_state = MEM_READ ;                         // looping mem read 
                
                MEM_WRITE_BACK:                                         // write back loop
                    if( !memory.busywait )
                        next_state = MEM_READ ;
                    else
                        next_state = MEM_WRITE_BACK ;

            endcase
   
    end

    // combinational output logic
    always @( * )
    begin
        if ( status )                                                   // fire controller
        begin
            case(state)
                IDLE:
                begin
                    if ( read )
                        begin
                        busywait  = 1'b0;
                        #1 ;
                        Cache[index][31:0]  = memory.readdata ;         // cache upadate
                        Cache[index][34:32] = tag ;                     
                        Cache[index][36]    = 1'b1 ;                    // valid
                        Cache[index][35]    = 1'b0 ;                    // drity
                        end

                    mem_read  = 1'b0;                                   // mem off
                    mem_write = 1'b0;
                    busywait  = 1'b0;                                   // busy off
                    status    = 1'b0;                                   // fire control on
                end
            
                MEM_READ:                                               // read or write memory
                begin
                    if( read )                                          // read
                        begin
                            mem_read    = 1'b1 ;                        // mem read
                            mem_write   = 1'b0 ;
                            mem_address = {tag, index};
                            busywait    = 1'b1 ;
                        end
                    if( write )                                         // write on cache
                        begin
                            busywait    = 1'b0 ;
                            #1 ;                                        // write delay hit 
                            Cache[index][36]    = 1'b1 ;                // valid
                            Cache[index][35]    = 1'b1 ;                // drity
                            Cache[index][34:32] = tag  ;                // tag 
                            #1 ;
                            case ( offset )
                                2'b00:  Cache[index][ 31:24 ] = writedata ;
                                2'b01:  Cache[index][ 23:16 ] = writedata ;
                                2'b10:  Cache[index][ 15: 8 ] = writedata ;
                                2'b11:  Cache[index][  7: 0 ] = writedata ;
                            endcase

                        end
                end

                MEM_WRITE_BACK:                                             // write-back
                    begin
                        if ( dirty )
                        begin
                            mem_read      =  1'b0 ;                         // write mem data
                            mem_write     =  1'b1 ;
                            mem_address   =  {Cache[index][34:32],index}  ;
                            mem_writedata =  Cache[index][31:0];
                            busywait      =  1'b1 ;
                        end
                    end
                
                
            endcase
        end
    end

    // sequential logic for state transitioning 
    always @(posedge clock, reset  )
    begin
        
        if(reset)                                               // 1st stage
            state = IDLE;
        else if ( status * ( ~memory.busywait ) )               // next stage with control fire
            state = next_state ;
    end

    /* Cache Controller FSM End */

    always @( posedge reset )                                   // full reset
    begin
        status        = 1'b0 ;
        state         = 2'b0 ;
        next_state    = 2'b0 ;
        memory.readdata = 31'b0 ;
        Cache[3'b000] = 36'b0 ;
        Cache[3'b001] = 36'b0 ;
        Cache[3'b010] = 36'b0 ;
        Cache[3'b011] = 36'b0 ;
        Cache[3'b100] = 36'b0 ;
        Cache[3'b101] = 36'b0 ;
        Cache[3'b110] = 36'b0 ;
        Cache[3'b111] = 36'b0 ;

    end

endmodule