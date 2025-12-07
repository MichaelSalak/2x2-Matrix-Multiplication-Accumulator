`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2025 10:50:11 PM
// Design Name: 
// Module Name: matrix_accumulator_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module matrix_accumulator_tb();

    reg clk, rst_raw, up, left, right, down; 
    reg [15:0]switches;
    wire dp,a,b,c,d,e,f,g; 
    wire [3:0]anode;
    wire load_done, fsm_done;
    
    top dut(.clk(clk), .rst_raw(rst_raw), .up(up), .left(left), .down(down), 
            .right(right), .switches(switches), 
            .dp(dp),.a(a),.b(b),.c(c),.d(d),.e(e),.f(f),.g(g),
            .anode(anode), .load_done(load_done), .fsm_done(fsm_done));
            
    reg rst_done;
            
    initial begin
        clk = 0;
        rst_raw = 1;
        up = 0;
        left = 0;
        right = 0;
        down = 0;
        switches = 0;
        rst_done = 0;
        wait (dut.cdb.clean);    //wait for debounced reset signal
        #10 rst_raw = 0;    //hold for a clock cycle
        wait (!dut.cdb.clean);   //wait for debounced reset deassert
        rst_done = 1;
    end
    always #5 clk = ~clk;
    
    initial begin
        wait (rst_done);    //wait for initial reset
        switches = {{2'b11,2'b10,2'b01,2'b10},{2'b01,2'b11,2'b00,2'b10}};  
        //{A,B}
        
        
        #7 left = 1;   //load ram
        wait (load_done);   
        
        
        //#10
        #7 left = 0;   //disable load ram
        right = 1;  //toggle start
        
        
        wait (dut.start_button);
        #10 right = 0;  //disable start
        wait (dut.done);    //wait for fsm to finish
        
        #50 up = 1; //show 1st result matrix value
        wait (dut.up_clean);    //ensure signal is debounced
        wait (dut.seg.conv_done);   //wait for result to compute
        #10 up = 0; 
        //wait (!dut.up_clean);   //wait for debounced signal to go low
        
        #10 left = 1;
        wait (dut.left_clean); 
        wait (dut.seg.conv_done);
        #10 left = 0;
        //wait (!dut.left_clean);
        
        #10 right = 1;
        wait (dut.right_clean); 
        wait (dut.seg.conv_done);
        #10 right = 0;
        //wait (!dut.right_clean);
        
        #10 down = 1;
        wait (dut.down_clean); 
        wait (dut.seg.conv_done);
        #10 down = 0;
        wait (!dut.down_clean);
        
        
        
        $finish;
        
        
        //test 2nd input case + reset functionality
        
        
        #10 rst_raw = 1;
        wait (dut.cdb.clean);    
        #10 rst_raw = 0;    
        wait (!dut.cdb.clean);   
        
        switches = {{2'b01,2'b01,2'b10,2'b11},{2'b11,2'b01,2'b11,2'b10}};  
        //{A,B}
        left = 1;   //load ram
        wait (load_done);   
        #10 left = 0;   //disable load ram
        right = 1;  //toggle start
        wait (dut.start_button);
        #10 right = 0;  //disable start
        wait (dut.done);    //wait for fsm to finish
        
        #50 up = 1; //show 1st result matrix value
        wait (dut.up_clean);    //ensure signal is debounced
        wait (dut.seg.conv_done);   //wait for result to compute
        #10 up = 0; 
        //wait (!dut.up_clean);   //wait for debounced signal to go low
        
        #10 left = 1;
        wait (dut.left_clean); 
        wait (dut.seg.conv_done);
        #10 left = 0;
        //wait (!dut.left_clean);
        
        #10 right = 1;
        wait (dut.right_clean); 
        wait (dut.seg.conv_done);
        #10 right = 0;
        //wait (!dut.right_clean);
        
        #10 down = 1;
        wait (dut.down_clean); 
        wait (dut.seg.conv_done);
        #10 down = 0;
        wait (!dut.down_clean);

        $finish;
    end
endmodule
