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
output[11:0] colour,
output reg [6:0] display,
output reg [7:0] an,
output reg dp
    );
    
    parameter r=0,u=1,d=2,l=3;
    parameter box_size = 5;
    parameter max_length = 50;
    parameter SCREEN_WIDTH = 11'd800;
    parameter SCREEN_HEIGHT = 10'd600;
    
//    reg collide;   
    reg[1:0] current_state;
    wire h_disp,v_disp;
    wire[10:0] h_loc;
    wire [9:0]v_loc;
    reg[11:0] colour_reg;
    reg[24:0] counter;


    reg [10:0] snake_x[0:max_length-1];
    reg [9:0] snake_y[0:max_length-1];
    reg [5:0] snake_length;
    reg lengthincrease;
    
    reg [10:0] h_food_reg;
    reg [9:0] v_food_reg; 
    reg [10:0] h_food_next;
    reg [9:0] v_food_next; 
    
    
    
    reg [6:0] score;
    wire [7:0] score_bcd;
    wire [3:0] tens, units;
    
    reg [20:0] count;
    reg flip ;
        
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
    bin2bcd bcd_converter (
        .bin(score),
        .bcd(bcd_score),
        .units(units),
        .tens(tens)
    );
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
        
        if(reset || restart ) begin
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
            score <= 7'b0;
            count <= 0;
            flip <= 1'b0;
        end
        else
        begin
            if (
            (snake_x[0] + box_size >= h_food_reg - box_size) &&
            (snake_x[0] - box_size <= h_food_reg + box_size) &&
            (snake_y[0] + box_size >= v_food_reg - box_size) &&
            (snake_y[0] - box_size <= v_food_reg + box_size)
            )
            begin
                lengthincrease <= 1'b1;
                h_food_reg <= h_food_next;
                v_food_reg <= v_food_next;
            end
            
            else begin
                h_food_reg <= h_food_reg;
                v_food_reg <= v_food_reg;
                end
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
                    r: begin
                        if(snake_x[0] + box_size < SCREEN_WIDTH)  // Right edge = 800 - box_size
                            snake_x[0] <= snake_x[0] + box_size;
                    end
                    l: begin
                        if(snake_x[0] - box_size >= 0)            // Left edge = 0 + box_size
                            snake_x[0] <= snake_x[0] - box_size;
                    end
                    u: begin
                        if(snake_y[0] - box_size >= 0)            // Top edge = 0 + box_size
                            snake_y[0] <= snake_y[0] - box_size;
                    end
                    d: begin
                        if(snake_y[0] + box_size < SCREEN_HEIGHT)  // Bottom edge = 600 - box_size
                            snake_y[0] <= snake_y[0] + box_size;
                    end
                endcase
                if (lengthincrease && score < 99)  // Increment score when food is eaten
                    score <= score + 7'b0000001;
                
                if(lengthincrease && (snake_length < max_length)) begin
                    snake_x[snake_length] <= snake_x[snake_length-1];
                    snake_y[snake_length] <= snake_y[snake_length-1];
                    snake_length <= snake_length + 1;
                end
                lengthincrease <= 1'b0;
            end      
            else
                counter <= counter + 1'b1;
            count <= count + 1;
            
            if (count == 400000)
                begin
                    count <= 0;
                    flip <= ~flip;
                end
        end
    end
    
    integer j;
    integer k;
    reg snake_appear;
    reg head_appear;
    reg food_appear;
    reg self_coll;
    always @(*) begin
        snake_appear = 1'b0;
        food_appear = 1'b0;
        self_coll = 1'b0;
        head_appear=1'b0;
//        collide=1'b0;
        if(h_disp && v_disp) begin
            for(j=0; j<snake_length; j=j+1) begin
            if(
                (h_loc >= snake_x[j] - box_size) && 
                (h_loc <= snake_x[j] + box_size) && 
                (v_loc >= snake_y[j] - box_size) && 
                (v_loc <= snake_y[j] + box_size)
            ) snake_appear = 1'b1;
          
            end
            
            for(k=3; k < snake_length; k=k+1) begin
            if(
                (snake_x[0] >= snake_x[k] - box_size) && 
                (snake_x[0] <= snake_x[k] + box_size) && 
                (snake_y[0] >= snake_y[k] - box_size) && 
                (snake_y[0] <= snake_y[k] + box_size)
            ) self_coll = 1'b1;
//             collide=1'b1;
        end
            
            if(
            (h_loc >= h_food_reg - box_size) && 
            (h_loc <= h_food_reg + box_size) && 
            (v_loc >= v_food_reg - box_size) && 
            (v_loc <= v_food_reg + box_size)
               ) food_appear = 1'b1;
              if(
                (h_loc >= snake_x[0] - box_size) && 
                (h_loc <= snake_x[0] + box_size) && 
                (v_loc >= snake_y[0] - box_size) && 
                (v_loc <= snake_y[0] + box_size)
            ) head_appear = 1'b1;
              /*
            else if((snake_x[0] + box_size >= h_food_reg && snake_x[0] - box_size <= h_food_reg) && (snake_y[0] + box_size >= v_food_reg && snake_y[0] - box_size <= v_food_reg))
                food_appear = 1'b0; */
            if(snake_appear && head_appear)
                colour_reg=12'b010011001000;   
            else if(snake_appear)
                colour_reg =12'b111100000000;
            else if(food_appear)
                colour_reg =12'b111111110000;
            else
                colour_reg = 12'b000011110000;
            
            if(
            (snake_x[0] >= 11'h7FF - box_size) ||  // Right wall
            (snake_x[0] < box_size) ||            // Left wall
            (snake_y[0] >= 10'h3FF - box_size) ||  // Bottom wall
            (snake_y[0] < box_size) ||            // Top wall
            self_coll
               ) colour_reg = 12'b000000001111; // Blue (game over)               
        end
        
        else
            colour_reg = 12'b000000000000;
    end
    
    assign colour = (h_disp && v_disp)?colour_reg:12'b0;
    
    always @(*) begin
        dp = 1'b1;
        if (flip) begin

            an = 8'b11111110;
            case (units)
                4'd0: display = 7'b0000001;  
                4'd1: display = 7'b1001111;  
                4'd2: display = 7'b0010010;  
                4'd3: display = 7'b0000110;  
                4'd4: display = 7'b1001100;  
                4'd5: display = 7'b0100100;  
                4'd6: display = 7'b0100000;  
                4'd7: display = 7'b0001111;  
                4'd8: display = 7'b0000000;  
                4'd9: display = 7'b0000100;  
                default: display = 7'b0000001;
            endcase
        end else begin

            an = 8'b11111101; 
            case (tens)
                4'd0: display = 7'b0000001;  
                4'd1: display = 7'b1001111;  
                4'd2: display = 7'b0010010;  
                4'd3: display = 7'b0000110;  
                4'd4: display = 7'b1001100;  
                4'd5: display = 7'b0100100;  
                4'd6: display = 7'b0100000;  
                4'd7: display = 7'b0001111;  
                4'd8: display = 7'b0000000;  
                4'd9: display = 7'b0000100;  
                default: display = 7'b0000001;
            endcase
        end
    end
    
endmodule