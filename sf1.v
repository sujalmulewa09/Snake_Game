`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2025 19:04:26
// Design Name: 
// Module Name: sf1
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.03.2025 20:12:48
// Design Name: 
// Module Name: sf
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

module sf1(
input clk,
input reset,restart,
input right,left,down,up,
output h_sync,v_sync,
output[11:0] colour
    );
    
    parameter r=0,u=1,d=2,l=3;
    parameter box_size = 5;
    parameter max_length = 50;
    
    
    reg[1:0] current_state;
    wire h_disp,v_disp;
    wire[10:0] h_loc;
    wire [9:0]v_loc;
    reg[11:0] colour_reg;
    reg[24:0] counter;
//    reg[10:0] initial_hloc;
//    reg[9:0] initial_vloc;

    reg [10:0] snake_x[0:max_length-1];
    reg [9:0] snake_y[0:max_length-1];
    reg [5:0] snake_length;
    reg lengthincrease;
//    reg lengthincrease_sync0;
//    reg lengthincrease_flag;
    reg [10:0] h_food_reg;
    reg [9:0] v_food_reg; 
    reg [10:0] h_food_next;
    reg [9:0] v_food_next; 
    
    //reg [10:0] h_food_reg;
    //reg [9:0] v_food_reg;
    //reg feedback_v,feedback_h;
    //reg food_eaten;
    clk_wiz_0 inst1
   (
    // Clock out ports
    .CLK_100MHz(CLK_100MHz),     // output CLK_100MHz
    .CLK_25MHz(CLK_25MHz),     // output CLK_25MHz
    .CLK_400MHz(CLK_400MHz),     // output CLK_400MHz
    .CLK_40MHz(CLK_40MHz),     // output CLK_40MHz
    // Status and control signals
    .reset(rst), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(clk)      // input clk_in1
);

    display inst2(.clk(CLK_40MHz),.rst(reset),.h_sync(h_sync),.v_sync(v_sync),.v_disp(v_disp),.h_disp(h_disp),.v_loc(v_loc),.h_loc(h_loc));
    
    integer i;
    always @(*)
    begin
        h_food_next[0]  = (h_food_reg[10] ^ h_food_reg[5]) | (~h_food_reg[2] & h_food_reg[8]);
        h_food_next[1]  = (h_food_reg[9] & h_food_reg[3]) ^ (h_food_reg[1] | h_food_reg[7]);
        h_food_next[2]  = (~h_food_reg[8] | h_food_reg[0]) & (h_food_reg[6] ^ h_food_reg[4]);
        h_food_next[3]  = (h_food_reg[7] & h_food_reg[2]) | (~h_food_reg[1] ^ h_food_reg[5]);
        h_food_next[4]  = (h_food_reg[6] ^ h_food_reg[3]) & (~h_food_reg[0] | h_food_reg[9]);
        h_food_next[5]  = (h_food_reg[5] | h_food_reg[1]) ^ (h_food_reg[8] & ~h_food_reg[10]);
        h_food_next[6]  = (~h_food_reg[4] ^ h_food_reg[2]) & (h_food_reg[9] | h_food_reg[7]);
        h_food_next[7]  = (h_food_reg[3] & h_food_reg[10]) | (~h_food_reg[5] ^ h_food_reg[6]);
        h_food_next[8]  = (h_food_reg[2] | ~h_food_reg[7]) ^ (h_food_reg[8] & h_food_reg[0]);
        h_food_next[9]  =  1'b0; //(h_food_reg[1] & ~h_food_reg[6]) | (h_food_reg[4] ^ h_food_reg[5]);
        h_food_next[10] = 1'b0; //(h_food_reg[0] | h_food_reg[9]) & (~h_food_reg[8] ^ h_food_reg[3]);
        
        v_food_next[0] = (v_food_reg[9] ^ v_food_reg[4]) | (~v_food_reg[2] & v_food_reg[7]);
        v_food_next[1] = (v_food_reg[8] & v_food_reg[3]) ^ (v_food_reg[1] | v_food_reg[6]);
        v_food_next[2] = (~v_food_reg[7] | v_food_reg[0]) & (v_food_reg[5] ^ v_food_reg[4]);
        v_food_next[3] = (v_food_reg[6] & v_food_reg[2]) | (~v_food_reg[1] ^ v_food_reg[4]);
        v_food_next[4] = (v_food_reg[5] ^ v_food_reg[3]) & (~v_food_reg[0] | v_food_reg[8]);
        v_food_next[5] = (v_food_reg[4] | v_food_reg[1]) ^ (v_food_reg[7] & ~v_food_reg[9]);
        v_food_next[6] = (~v_food_reg[3] ^ v_food_reg[2]) & (v_food_reg[8] | v_food_reg[6]);
        v_food_next[7] = (v_food_reg[2] & v_food_reg[9]) | (~v_food_reg[5] ^ v_food_reg[7]);
        v_food_next[8] = (v_food_reg[1] | ~v_food_reg[6]) ^ (v_food_reg[8] & v_food_reg[0]);
        v_food_next[9] = 1'b0; //(v_food_reg[0] & ~v_food_reg[4]) | (v_food_reg[3] ^ v_food_reg[5]);
    end
    always @(posedge CLK_100MHz) begin
     
        if((snake_x[0] >= h_food_reg && snake_x[0]- box_size < h_food_reg ) && (snake_y[0] >= v_food_reg && snake_y[0]- box_size < v_food_reg ))
        begin
            lengthincrease <= 1'b1;
            h_food_reg <= h_food_next;
            v_food_reg <= v_food_next;
                end
                
      
        else begin
            h_food_reg <= h_food_reg;
            v_food_reg <= v_food_reg;
            end
        
        if(reset || restart) begin
            counter <= 25'b0;
            current_state <= r;
            snake_length <= 6'b1;
            //colour_reg <= 12'b000011110000; // Reset color
            snake_x[0] <= 11'b00110001100;   // Initial location
            snake_y[0] <= 10'b0100101000; 
            h_food_reg <= 11'b00011001000;
            v_food_reg <= 10'b0001100100;
            //food_eaten <= 1'b0;   
            lengthincrease <= 1'b0;        
            //colour_reg <= 12'b000011110000;
        end else
        begin
            case(current_state)
                r:
                begin
                    if(up)
                        current_state <= u;
                    else if(down)
                        current_state <= d;
                    else
                        current_state <= r;
                      
                    /*if(counter == 25'b1110010011100001110000000) begin
                        if(initial_hloc < 11'b01100100000) begin
                            initial_hloc = initial_hloc + 3'b101;
                            initial_vloc = initial_vloc;
                        end else
                        begin
                            colour_reg = 12'b000000001111;
                        end
                    end */
                end
                l:
                begin
                    if(up)
                        current_state <= u;
                    else if(down)
                        current_state <= d;
                    else
                        current_state <= l;
                        
                    /*if(counter == 25'b1110010011100001110000000) begin
                        if(initial_hloc > 11'b0) begin
                            initial_hloc = initial_hloc - 3'b101;
                            initial_vloc = initial_vloc;
                        end else
                        begin
                            colour_reg = 12'b000000001111;
                        end 
                    end*/
                end
                u:
                begin
                    if(right)
                        current_state <= r;
                    else if(left)
                        current_state <= l;
                    else
                        current_state <= u;
                        
                    /*if(counter == 25'b1110010011100001110000000) begin
                        if(v_loc > 10'b0) begin
                            initial_vloc = initial_vloc - 3'b101;
                            initial_hloc = initial_hloc;
                        end else
                        begin
                            colour_reg = 12'b000000001111;
                        end 
                    end*/
                end
                
                
                d:
                begin
                    if(right)
                        current_state <= r;
                    else if(left)
                        current_state <= l;
                    else
                        current_state <= d;
                    
                    /*if(counter == 25'b1110010011100001110000000) begin
                        if(v_loc < 10'b1001011000) begin
                            initial_vloc = initial_vloc + 3'b101;
                            initial_hloc = initial_hloc;
                        end else
                        begin
                            colour_reg = 12'b000000001111;
                        end
                    end*/
                end
                default: current_state <= r;
            endcase
            if(counter > 25'b1110010011100001110000000) begin
                counter <= 25'b0;
                
                for (i = max_length - 1; i > 0; i = i - 1) begin
                        if (i < snake_length)
                            begin
                                snake_x[i] <= snake_x[i-1];
                                snake_y[i] <= snake_y[i-1];
                            end
                end

                 
                case(current_state)
                    r:
                    begin
                        if(snake_x[0] <= 11'b01100100000)
                            snake_x[0] <= snake_x[0] + box_size;
                    end
                    l:
                    begin
                        if(snake_x[0] >= box_size)
                            snake_x[0] <= snake_x[0] - box_size;
                    end
                    u:
                    begin
                        if(snake_y[0] >= box_size)
                            snake_y[0] <= snake_y[0] - box_size;
                    end
                    d:
                    begin
                        if(snake_y[0] <= 10'b1001011000)
                            snake_y[0] <= snake_y[0] + box_size;
                    end
                endcase
                
                if(lengthincrease && (snake_length < max_length)) begin
                    snake_x[snake_length] <= snake_x[snake_length-1];
                    snake_y[snake_length] <= snake_y[snake_length-1];
                    snake_length <= snake_length + 1;
                end
                lengthincrease <= 1'b0;
            end      
            else
                counter <= counter + 1'b1;
        end
    end
    
    integer j;
    integer k;
    reg snake_appear;
    reg food_appear;
    reg body;
    reg self_coll;
    always @(*) begin
        snake_appear = 1'b0;
        food_appear = 1'b0;
        if(h_disp && v_disp) begin
            for(j=0;j<snake_length;j=j+1) begin
                if((h_loc <= snake_x[j] && h_loc > snake_x[j] - box_size) && (v_loc <= snake_y[j] && v_loc > snake_y[j] - box_size)) begin
                    snake_appear = 1'b1;
//                    if(j!=0) begin
//                    body=1'b1;
//                    end
                    end
               for (j = 1; j < snake_length; j = j + 1) begin  // Start from 1 to skip head
            if ((snake_x[0] == snake_x[j]) && (snake_y[0] == snake_y[j])) begin
                self_coll = 1'b1; // Collision detected
            end
              
                 
            end
            
            if((h_loc <= h_food_reg && h_loc > h_food_reg - box_size) && (v_loc <= v_food_reg && v_loc > v_food_reg - box_size))
                food_appear = 1'b1;
            else if((snake_x[0] >= h_food_reg && snake_x[0] < h_food_reg + box_size) && (snake_y[0] >= v_food_reg && snake_y[0] < v_food_reg + box_size))
                food_appear = 1'b0;
                
            if(snake_appear)
                colour_reg =12'b111100000000;
            else if(food_appear)
                colour_reg =12'b111111110000;
            else
                colour_reg = 12'b000011110000;
                
            if((snake_x[0] > 11'b01100100000 || snake_x[0] < box_size || snake_y[0] > 10'b1001011000 || snake_y[0] < box_size)|| self_coll) begin
                colour_reg = 12'b000000001111;                
        end
         else begin
            colour_reg = 12'b000000000000;
            end
    end
    
 
   
    assign colour = (h_disp && v_disp)?colour_reg:12'b0; 
endmodule
