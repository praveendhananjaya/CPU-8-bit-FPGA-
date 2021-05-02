`include "cpu.v"

module testbench;
  reg CLOCK ;
  reg RESET ;

  CPU CPU( CLOCK , RESET );

  initial begin
    // generate files needed to plot the waveform using GTKWave
    $dumpfile("wavedata.vcd");
		$dumpvars(0, testbench);

    #0
    CLOCK = 1'b1 ;
    #2
    RESET = 1'b1 ; 

    #10
    RESET = 1'b0 ; 


    #7000              // 100 / 10 = 10 cycle
    $finish;
  end

  always 
    #4 CLOCK = ~CLOCK ;
endmodule