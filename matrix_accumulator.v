`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2025 12:37:05 PM
// Design Name: 
// Module Name: matrix_accumulator
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


//2 bit inputs
//top module: 16 switch inputs, 5 buttons (before/after computation): 
// - UP: none/C11
// - LEFT: load/C12
// - CENTER: rst/rst
// - RIGHT: start/C21
// - DOWN: none/C22
module top(input clk, rst_raw, up, left, right, down, 
           input [15:0]switches, output dp,a,b,c,d,e,f,g, output [3:0]anode,
           output load_done, output reg fsm_done
           
           ,output reg Test0,Test1,Test2,Test3,Test4,Test5,Test6,Test7,Test8,Test9,Test10, output [1:0] it);
    


    wire [7:0] A, B;    //input matrices to write in ram (initialize)
    wire [3:0] init_ram_addr, fsm_ram_addr, ram_addr;   //multiplexed
    wire [1:0] rf_w_addr;
    wire rf_w_en;
    wire ram_w_en, init_ram_w_en, fsm_ram_w_en;   //multiplexed
    wire [1:0] reg_r_addr1, reg_r_addr2, reg_r_addr3, reg_r_addr4;
    wire [7:0] init_w_ram_data, fsm_w_ram_data, 
               w_ram_data, r_ram_data;  //multiplexed
    wire acc_en, acc_clear;
    wire done;
    wire [3:0] pp0, pp1; //intermediate accummulator products
    wire [1:0] A1, A2, B1, B2;  //current matrix values to multiply
    wire [4:0] acc; //accumulated result (extra bit for carryout)
    wire [4:0] C11, C12, C21, C22;  //result matrix
    
    //buttons and display
    wire up_clean, left_clean, rst, right_clean, down_clean;   //debounced signals
    reg load_en;
    reg load_button;    //load ram button signal
    reg start_button;   //start button signal
    reg C11_button, C12_button, C21_button, C22_button; //display result button signals    
    reg display;    //signal to begin displaying (latched fsm done)

    //button debouncers
    debouncer udb(.clk(clk), .raw(up), .clean(up_clean)); 
    debouncer ldb(.clk(clk), .raw(left), .clean(left_clean)); 
    debouncer cdb(.clk(clk), .raw(rst_raw), .clean(rst)); //reset always on center button
    debouncer rdb(.clk(clk), .raw(right), .clean(right_clean)); 
    debouncer ddb(.clk(clk), .raw(down), .clean(down_clean)); 
    
    //ram initializer
    load_RAM init(.clk(clk), 
                  .rst(rst), 
                  .en(load_en), 
                  .button(load_button), 
                  .matrices(switches), 
                  .write_en(init_ram_w_en), 
                  .done(load_done), 
                  .ram_addr(init_ram_addr),
                  .w_ram_data(init_w_ram_data));    
    
    
    
    wire test0,test1,test2,test3,test4,test5,test6,test7,test8,test9,test10;
    always @(posedge clk) begin
        if(rst) begin
            Test0 <= 0;
            Test1 <= 0;
            Test2 <= 0;
            Test3 <= 0;
            Test4 <= 0;
            Test5 <= 0;
            Test6 <= 0;
            Test7 <= 0;
            Test8 <= 0;
            Test9 <= 0;
            Test10 <= 0;
        end else if(test0)
            Test0 <= test0;
        else if(test1)
            Test1 <= test1;
        else if(test2)
            Test2 <= test2;
        else if(test3)
            Test3 <= test3;
        else if(test4)
            Test4 <= test4;
        else if(test5)
            Test5 <= test5;
        else if(test6)
            Test6 <= test6;
        else if(test7)
            Test7 <= test7;
        else if(test8)
            Test8 <= test8;
        else if(test9)
            Test9 <= test9;
        else if(test10)
            Test10 <= test10;
    end
            
    
    
    
    
    
    controller fsm(.clk(clk),
                   .rst(rst),
                   .start(start_button),
                   .acc(acc),
                   .ram_addr(fsm_ram_addr),
                   .rf_w_addr(rf_w_addr),
                   .ram_w_en(fsm_ram_w_en), 
                   .rf_w_en(rf_w_en), 
                   .w_ram_data(fsm_w_ram_data), 
                   .reg_r_addr1(reg_r_addr1), 
                   .reg_r_addr2(reg_r_addr2), 
                   .reg_r_addr3(reg_r_addr3), 
                   .reg_r_addr4(reg_r_addr4),
                   .acc_en(acc_en),
                   .acc_clear(acc_clear),
                   .done(done),
                   .C11(C11), 
                   .C12(C12), 
                   .C21(C21), 
                   .C22(C22)
                   
                   
                   
                   
                   ,.PS_test(PS_test) ,.test0(test0),.test1(test1),.test2(test2),.test3(test3),.test4(test4),.test5(test5),.test6(test6),.test7(test7),.test8(test8),.test9(test9),.test10(test10), .it(it));

    register_file rf(.clk(clk), 
                     .rst(rst), 
                     .write_en(rf_w_en), 
                     .w_addr(rf_w_addr), 
                     .r_addr1(reg_r_addr1), 
                     .r_addr2(reg_r_addr2), 
                     .r_addr3(reg_r_addr3), 
                     .r_addr4(reg_r_addr4), 
                     .w_data(r_ram_data[1:0]), //only need lower 2 bits
                     .data1(A1), 
                     .data2(A2), 
                     .data3(B1), 
                     .data4(B2));
    
    RAM8bit ram(.clk(clk), .rst(rst), .write_en(ram_w_en), .address(ram_addr), 
                .w_data(w_ram_data), .r_data(r_ram_data));
    
    multiplier multi0(.A(A1), .B(B1), .product(pp0));
    multiplier multi1(.A(A2), .B(B2), .product(pp1));

    accumulator accum(.clk(clk), .rst(rst), .acc_en(acc_en), .clear(acc_clear), 
                      .pp0(pp0), .pp1(pp1), .acc(acc));
    
    display seg(.clk(clk), 
                .rst(rst),
                .display(display), 
                .C11(C11), 
                .C12(C12), 
                .C21(C21), 
                .C22(C22),
                .C11_button(C11_button), 
                .C12_button(C12_button),
                .C21_button(C21_button),
                .C22_button(C22_button),
                .dp(dp),.a(a),.b(b),.c(c),.d(d),.e(e),.f(f),.g(g), 
                .anode(anode));   
          
    //mulitplex ram signals for loading and regular use
    assign ram_addr = load_en ? init_ram_addr : fsm_ram_addr;
    assign w_ram_data = load_en ? init_w_ram_data : fsm_w_ram_data;
    assign ram_w_en = load_en ? init_ram_w_en : fsm_ram_w_en;    
    
    //fsm done latch
    always @(posedge clk) begin
        if(rst)
            fsm_done <= 0;
        else if(done)
            fsm_done <= done;
        else
            fsm_done <= fsm_done;
    end
            
    //button logic    
    always @(posedge clk) begin
        if(rst) begin
            load_en <= 1;   //reset to ram loading process
            load_button <= 0;   //disable during reset
            start_button <= 0;  //start button disabled during loading
            C11_button <= 0;    //display output signals disabled
            C12_button <= 0;
            C21_button <= 0;
            C22_button <= 0;
            display <= 0;   //disable display
        end else if(load_en) begin
            if(load_done) begin //wait until load finishes
                load_en <= 0;   //disable input loading after completion 
                load_button <= 0;   //disable loading after loading
            end else begin
                load_en <= 1;
                load_button <= left_clean;   //left button tied to load signal
            end
        end else if(!fsm_done) begin
            load_en <= 0;   
            load_button <= 0;   
            start_button <= right_clean & load_done;  //enable start button
        end else if(fsm_done) begin //wait until controller finishes
            load_en <= 0;
            load_button <= 0;
            start_button <= 0;  //disable start button after calculations
            C11_button <= up_clean; //enable output signal buttons
            C12_button <= left_clean;
            C21_button <= right_clean;
            C22_button <= down_clean;
            display <= 1;   //enable display
        end
    end
endmodule


//debounce button signal
module debouncer(input raw, input clk, output reg clean);
    reg [19:0]counter = 0;
    initial clean = 0;
    
    always @(posedge clk) begin
        if(raw) begin
            if(!(&counter)) //not max count
                counter <= counter + 1; //debounce button press
        end else begin
            if(counter != 0) 
                counter <= counter - 1; //debounce button release
        end
        
        if(&counter)
            clean <= 1;
        else if(counter == 0)
            clean <= 0;
    end
endmodule


//load current switch combination into ram as designated matrices upon button press
module load_RAM(input clk, rst, en, button, input [15:0]matrices,
                output reg write_en, done, output reg [3:0]ram_addr,
                output reg [7:0]w_ram_data);
                  
    reg [2:0]count; //track address (A: 0-3, B: 4-7)
    reg [1:0]current;
     
    //determine input value to write
    always @(*) begin
        case(count)
            0: current = matrices[15:14];   //A11
            1: current = matrices[13:12];
            2: current = matrices[11:10];
            3: current = matrices[9:8];
            4: current = matrices[7:6];
            5: current = matrices[5:4];
            6: current = matrices[3:2];
            7: current = matrices[1:0]; //B22
        endcase
    end    
          
    always @(posedge clk) begin
        if(rst) begin
            count <= 0;
            write_en <= 0;
            done <= 0;
            ram_addr <= 0;
            w_ram_data <= 0;
        end else if(en && button) begin   //write 
            write_en <= done ? 0 : 1;   //disable writes when done
            if(!done) begin    //dont reload while button still held but done
                ram_addr <= count;
                w_ram_data <= {6'b000000,current};  //pad to 8 bits
                count <= count + 1;
                if(&count)
                    done <= 1;  //done at max count
            end 
        end else if(done) begin  //hold done after loading
            count <= 0;
            write_en <= 0;
            done <= 1;  //hold done
            ram_addr <= 0;
            w_ram_data <= 0;
        end 
    end
endmodule


//FSM
module controller(input clk,
                  input rst,
                  input start,
                  input [4:0] acc,
                  output reg [3:0] ram_addr,
                  output reg [1:0] rf_w_addr,
                  output reg ram_w_en, rf_w_en, 
                  output reg [7:0] w_ram_data, 
                  output reg [1:0] reg_r_addr1, reg_r_addr2, reg_r_addr3, reg_r_addr4,
                  output reg acc_en,
                  output reg acc_clear,
                  output reg done,
                  output reg [4:0] C11, C12, C21, C22
                  
                  ,output [3:0] PS_test, output reg test0,test1,test2,test3,test4,test5,test6,test7,test8,test9,test10,
                  output [1:0] it);

    parameter IDLE = 0; 
    parameter READ_A1 = 1;
    parameter LOAD_A1_READ_A2 = 2;
    parameter LOAD_A2_READ_B1 = 3;
    parameter LOAD_B1_READ_B2 = 4;
    parameter LOAD_B2 = 5;
    parameter MULTIPLY = 6;
    parameter ADD = 7;
    parameter WRITE = 8;
    parameter UPDATE = 9;
    parameter DONE = 10;
    
    reg [3:0] PS, NS;
    reg [1:0] iteration, next_it;    //track current process iteration
    reg [2:0] A1_addr, A2_addr, B1_addr, B2_addr; 
    reg [4:0] NC11, NC12, NC21, NC22;   //for holding output matrix values
    
    
    
    assign PS_test = PS;
    assign it = iteration;
    
    
    //present state updates, iteration tracking
    always @(posedge clk) begin
        if(rst) begin
            PS <= IDLE;
            iteration <= 0;
        end else begin
            PS <= NS;
            iteration <= next_it;
        end
    end
    
    //output latching (prevents unessecary reads before displaying)
    always @(posedge clk) begin
        if(rst)
            {C11,C12,C21,C22} <= 0;
        else if(PS != IDLE)
            {C11,C12,C21,C22} <= {NC11,NC12,NC21,NC22};
        else 
            {C11,C12,C21,C22} <= {C11,C12,C21,C22};
    end
    
    //next state updates
    always @(*) begin
        case(PS)
            IDLE: NS = start ? READ_A1 : IDLE;   //begin at start signal
            READ_A1: NS = LOAD_A1_READ_A2;
            LOAD_A1_READ_A2: NS = LOAD_A2_READ_B1;
            LOAD_A2_READ_B1: NS = LOAD_B1_READ_B2;
            LOAD_B1_READ_B2: NS = LOAD_B2;
            LOAD_B2: NS = MULTIPLY;
            MULTIPLY: NS = ADD;
            ADD: NS = WRITE;
            WRITE: NS = UPDATE;  
            UPDATE: NS = (iteration == 3) ? DONE : READ_A1;  //repeat until finished
            DONE: NS = IDLE;    //loop for now
            default: NS = IDLE; 
        endcase     
    end
    
    //hardcoded address combinations per iteration
    always @(*) begin
        case(iteration)
            0: {A1_addr,A2_addr,B1_addr,B2_addr} = {3'd0,3'd1,3'd4,3'd6};
            1: {A1_addr,A2_addr,B1_addr,B2_addr} = {3'd0,3'd1,3'd5,3'd7};
            2: {A1_addr,A2_addr,B1_addr,B2_addr} = {3'd2,3'd3,3'd4,3'd6};
            3: {A1_addr,A2_addr,B1_addr,B2_addr} = {3'd2,3'd3,3'd5,3'd7};
        endcase
    end
    
    
    always @(*) begin
        case(iteration)
            0: next_it = (PS == WRITE) ? 1 : 0;
            1: next_it = (PS == WRITE) ? 2 : 1;
            2: next_it = (PS == WRITE) ? 3 : 2;
        endcase
    end
    
    
    //main logic
    always @(*) begin
    
    
        test0 = 0;
        test1 = 0;
        test2 = 0;
        test3 = 0;
        test4 = 0;
        test5 = 0;
        test6 = 0;
        test7 = 0;
        test8 = 0;
        test9 = 0;
        test10 = 0;
        
    
    
        case(PS)
            IDLE: begin
            
            
                test0 = 1;
            
            
                ram_addr = 0;
                rf_w_addr = 0;
                ram_w_en = 0;
                rf_w_en = 0;
                w_ram_data = 0;
                reg_r_addr1 = 0;
                reg_r_addr2 = 1;
                reg_r_addr3 = 2;
                reg_r_addr4 = 3;
                acc_en = 0;
                acc_clear = 0;
                done = 0;
                {NC11,NC12,NC21,NC22} = 0;
            end
            READ_A1: begin  
                acc_clear = 0;  //allow accumulation in iteration > 0
                rf_w_en = 1;
                ram_addr = A1_addr;
                
                
                
                test1 = 1;
                
                
                
            end
            LOAD_A1_READ_A2: begin    
                rf_w_en = 1;
                rf_w_addr = 0;
                ram_addr = A2_addr;
                
                
                
                
                test2 = 1;  //test
                
                
            end
            LOAD_A2_READ_B1: begin
                rf_w_en = 1;
                rf_w_addr = 1;   
                ram_addr = B1_addr;
                
                
                test3 = 1;
                
                
            end
            LOAD_B1_READ_B2: begin
                rf_w_en = 1;
                rf_w_addr = 2;
                ram_addr = B2_addr;
                
                
                
                test4 = 1;
                
                
            end
            LOAD_B2: begin
                rf_w_en = 1;
                rf_w_addr = 3;
                
                
                
                test5 = 1;
                
                
            end
            MULTIPLY: begin
                rf_w_en = 0;          
                
                
                test6 = 1;
                
                 
            end
            ADD: begin
                acc_en = 1;
                acc_clear = 0;  //accumulate
                
                
                test7 = 1;
                
                
            end
            WRITE: begin
            
            
                test8 = 1;
            
            
            
                acc_en = 0;
                ram_w_en = 1;
                w_ram_data = {3'b000, acc};   //write accumulated result in ram
                case(iteration) //write accumulated result locally for display (skip reads)
                    0: begin
                        ram_addr = 8; 
                        NC11 = acc;
                    end
                    1: begin
                        ram_addr = 9;
                        NC12 = acc;
                    end
                    2: begin
                        ram_addr = 10;
                        NC21 = acc;
                    end
                    3: begin
                        ram_addr = 11;
                        NC22 = acc;
                    end
                endcase
            end   
            UPDATE: begin
            
            
                test9 = 1;
            
            
                done = (iteration == 3) ? 1 : 0;    //trigger done early to 
                //prevent extra whole fsm cycle
                ram_w_en = 0;
                acc_clear = 1;  //reset accumulator
            end
            DONE: begin
            
            
                test10 = 1;
            
            
                done = 1;
            end
        endcase
    end
endmodule


//register file (4 registers, 2 bits each)
module register_file(clk, rst, write_en, w_addr, r_addr1, r_addr2, r_addr3, 
                     r_addr4, w_data, data1, data2, data3, data4);
                     
    parameter DATA_W = 2;    //2 bit data
    parameter ADDR_CNT = 4;    //4 addresses
    parameter ADDR_W = $clog2(ADDR_CNT);   //2 bit address width
    
    input clk, rst, write_en;
    input [ADDR_W-1:0]r_addr1, r_addr2, r_addr3, r_addr4, w_addr;
    input [DATA_W-1:0]w_data;
    output reg [DATA_W-1:0]data1, data2, data3, data4;
    
    reg[DATA_W-1:0] mem[0:ADDR_CNT-1];  
    integer i;
    
    always @(posedge clk) begin
        if(rst) begin
            for(i=0; i<ADDR_CNT; i=i+1) begin
                mem[i] <= 0; 
            end
        end else begin
            if(write_en)
                mem[w_addr] <= w_data;
        end
    end
    
    always @(*) begin
        data1 = mem[r_addr1];
        data2 = mem[r_addr2];
        data3 = mem[r_addr3];
        data4 = mem[r_addr4];
    end
endmodule


//8 bit data width, 12 different addresses
module RAM8bit(clk, rst, write_en, address, w_data, r_data);
    parameter DATA_W = 8;   //8 bit data
    parameter ADDR_CNT = 12;   //12 addresses (4 per matrix)
    parameter ADDR_W = $clog2(ADDR_CNT); //address bit width (4)
    
    input clk,rst,write_en;
    input [ADDR_W-1:0]address;
    input [DATA_W-1:0]w_data;
    output reg [DATA_W-1:0]r_data;
    
    reg[DATA_W-1:0] mem[0:ADDR_CNT-1];  
    integer i;
    
    always @(posedge clk) begin     
        if(rst) begin
            for(i=0; i<ADDR_CNT; i=i+1) 
                mem[i] <= 0;
        end else begin
            if(write_en)
                mem[address] <= w_data;
            else
                r_data <= mem[address];  //synchronous reads
        end
    end
endmodule


//multiplier
module multiplier(input [1:0] A, B, output [3:0] product);
    assign product = A * B;
endmodule


//accumulator 
module accumulator(input clk, rst, acc_en, clear, input [3:0] pp0, pp1, 
                   output reg [4:0] acc);
    always @(posedge clk) begin
        if(rst || clear)
            acc <= 0;   //0 on reset or clear signal
        else if(acc_en)
            acc <= acc + pp0 + pp1; //accumulate intermediate products
        else
            acc <= acc;
    end
endmodule


//                                    display modules
//--------------------------------------------------------------------------------


//top level display
module display(input clk, 
               input rst, 
               input display,
               input [4:0]C11, 
               input [4:0]C12, 
               input [4:0]C21, 
               input [4:0]C22, 
               input C11_button,
               input C12_button,
               input C21_button,
               input C22_button,
               output dp,a,b,c,d,e,f,g, 
               output [3:0]anode);

    wire [4:0] Cij; //current matrix value to process
    wire [7:0] bcd_Cij; //only save final 2 digits (max BCD total of 18)
    wire conv_en;   
    wire conv_done;
    wire [3:0] value;  //current digit binary value
      
    display_controller ctrl(.clk(clk),
                            .rst(rst),
                            .display(display),
                            .conv_done(conv_done),
                            .C11(C11),
                            .C12(C12),
                            .C21(C21),
                            .C22(C22),
                            .C11_button(C11_button),
                            .C12_button(C12_button),
                            .C21_button(C21_button),
                            .C22_button(C22_button),
                            .Cij(Cij),
                            .conv_en(conv_en));

    //pad input and truncate output
    BCDconv converter(.clk(clk), .rst(rst), .en(conv_en), .bin_in({7'b0000000,Cij}), 
                      .bcd_out(bcd_Cij), .done(conv_done));
    
    anodeGen gen(.clk(clk), .rst(rst), .bcd_in({11'd0, bcd_Cij}), 
                 .anode(anode), .val(value));
    
    segConv seg(.num(value), .dp(dp),.a(a),.b(b),.c(c),.d(d),.e(e),.f(f),.g(g));
    
endmodule


//display fsm
module display_controller(input clk,
                          input rst,
                          input display,
                          input conv_done,
                          input [4:0]C11,
                          input [4:0]C12,
                          input [4:0]C21,
                          input [4:0]C22,
                          input C11_button,
                          input C12_button,
                          input C21_button,
                          input C22_button,
                          output reg [4:0]Cij,
                          output reg conv_en);

    parameter IDLE = 0;
    parameter READ = 1;
    parameter CONVERT = 2;
    parameter DISPLAY = 3;
    parameter DONE = 4;

    reg [2:0]PS, NS;
    
    always @(posedge clk) begin
        if(rst)
            PS <= IDLE;
        else
            PS <= NS;
    end
    
    always @(*) begin
        case(PS)
            IDLE: NS = display ? READ : IDLE;   //begin displaying after main fsm finishes
            READ: NS = CONVERT;
            CONVERT: NS = conv_done ? DISPLAY : CONVERT; //wait for conversion completion
            DISPLAY: NS = (|{C11_button,C12_button,C21_button,C22_button}) 
                           ? IDLE : DISPLAY;   //hold display until next button press
        endcase
    end

    always @(*) begin
        case(PS)
            IDLE: begin
                Cij <= 0;
                conv_en <= 0;
            end
            READ: begin
                if(C11_button)
                    Cij = C11;
                else if(C12_button)
                    Cij = C12;
                else if(C21_button)
                    Cij = C21;
                else if(C22_button)
                    Cij = C22;
                else
                    Cij = 0;    //default
            end
            CONVERT: begin
                conv_en = 1;
            end
            DISPLAY: begin
                conv_en = 0;
            end
        endcase
    end
endmodule


//convert binary to bcd
module BCDconv(input clk, en, rst, input [11:0]bin_in, 
               output reg [15:0]bcd_out, output reg done);

    parameter IDLE = 2'b00;
    parameter ADD = 2'b01;
    parameter SHIFT = 2'b10;
    parameter DONE = 2'b11;
    
    reg [27:0]shift_reg;   //16 + 12 = 28
    reg [3:0]shift_idx;    //index state for all 12 bits
    reg [1:0]state;        
    
    always @(posedge clk) begin
        if(rst) begin  //wipe all registers on reset
            done <= 0;
            bcd_out <= 0;
            shift_reg <= 0;
            shift_idx <= 0;
            state <= IDLE;
        end else begin
            case(state)
                IDLE: begin
                    done <= 0;
                    if(en) begin
                        shift_idx <= 0;
                        shift_reg <= {16'b0, bin_in};   //load shifting register 
                        state <= SHIFT;
                    end
                end
                ADD: begin
                    if(shift_reg[27:24] > 4)
                        shift_reg[27:24] <= shift_reg[27:24] + 3;
                    if(shift_reg[23:20] > 4)
                        shift_reg[23:20] <= shift_reg[23:20] + 3;
                    if(shift_reg[19:16] > 4)
                        shift_reg[19:16] <= shift_reg[19:16] + 3;
                    if(shift_reg[15:12] > 4)
                        shift_reg[15:12] <= shift_reg[15:12] + 3;
                    state <= SHIFT;
                end
                SHIFT: begin  
                    shift_reg <= shift_reg << 1;  //shift (after add) and 
                                                  // update values next clock edge
                    shift_idx <= shift_idx + 1;   //increment shift index counter
                    
                    if(shift_idx == 11)
                        state <= DONE;
                    else
                        state <= ADD;
                end
                DONE: begin
                    bcd_out <= shift_reg[27:12];    //extract BCD value
                    done <= 1;
                    state <= IDLE;   //return to idle next clock edge for next value
                end
            endcase
        end
    end
endmodule


//select digit 
module anodeGen(input clk, rst, input [15:0]bcd_in, 
                output reg [3:0]anode, output reg [3:0] val);

    reg [9:0] count; 
    
    always @(posedge clk) begin
        if(rst) begin
            anode <= 4'b1110; 
            val <= 0;
            count <= 0;
        end else begin
            count <= count + 1;
            if(count == 1023) begin   //count 2^10-1 clock cycles
                anode <= {anode[0],anode[3:1]};	//shift current anode
                count <= 0;  //overwrite count++, reset count
            end
            case(anode)
                4'b1110: val <= bcd_in[3:0];
                4'b1101: val <= bcd_in[7:4];
                4'b1011: val <= bcd_in[11:8];
                4'b0111: val <= bcd_in[15:12];
            endcase
        end
    end
endmodule


//seven segment converter
module segConv(input [3:0]num, output reg dp,a,b,c,d,e,f,g);
    always @(*) begin
        dp = 1'b1;   //default decimal value
        case(num)   //active low
            4'b0000: {a,b,c,d,e,f,g} = 7'b0000001;
            4'b0001: {a,b,c,d,e,f,g} = 7'b1001111;
            4'b0010: {a,b,c,d,e,f,g} = 7'b0010010;
            4'b0011: {a,b,c,d,e,f,g} = 7'b0000110;
            4'b0100: {a,b,c,d,e,f,g} = 7'b1001100;
            4'b0101: {a,b,c,d,e,f,g} = 7'b0100100;
            4'b0110: {a,b,c,d,e,f,g} = 7'b0100000;
            4'b0111: {a,b,c,d,e,f,g} = 7'b0001111;
            4'b1000: {a,b,c,d,e,f,g} = 7'b0000000;
            4'b1001: {a,b,c,d,e,f,g} = 7'b0001100;
            default: {a,b,c,d,e,f,g} = 7'b1111111;
        endcase
    end
endmodule
