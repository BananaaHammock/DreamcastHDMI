module I2C_write(

	input clk,
	input reset,

	input [6:0] chip_addr,
	input [7:0] reg_addr,
	input [7:0] value,
	input enable,
	output reg done,

	input i2c_busy,
	output reg i2c_ena,
	output reg [6:0] i2c_addr,
	output reg i2c_rw,
	output reg [7:0] i2c_data_wr
);

(* syn_encoding = "safe" *)
reg [1:0] state;
reg [5:0] busy_cnt;
reg busy_prev;


reg [6:0] chip_addr_reg;
reg [7:0] reg_addr_reg;
reg [7:0] value_reg;


localparam s_idle = 0,
			  s_send = 1;

initial begin
	state <= s_idle;
	busy_cnt = 0;
	done <= 1'b1;
end

			  
always @ (posedge clk) begin
	if (~reset) begin
		state <= s_idle;
		busy_cnt = 0;
		done <= 1'b1;
	end
	else begin
		case(state)
			s_idle: begin
				if (enable) begin
					chip_addr_reg <= chip_addr;
					reg_addr_reg <= reg_addr;
					value_reg <= value;
					done <= 1'b0;
					state <= s_send;
				end
			end
			
			s_send: begin
				busy_prev <= i2c_busy;
				if (~busy_prev && i2c_busy) begin
					busy_cnt = busy_cnt + 1'b1;
				end
				case (busy_cnt)
					0: begin
						i2c_ena <= 1'b1;
						i2c_addr <= chip_addr_reg;
						i2c_rw <= 1'b0;
						i2c_data_wr <= reg_addr_reg;
					end
					
					1: begin
						i2c_data_wr <= value_reg;
					end
					
					2: begin
						i2c_ena <= 1'b0;
						if (~i2c_busy) begin
							busy_cnt = 0;
							done <= 1'b1;
							state <= s_idle;
						end
					end
				endcase
			end
			
		endcase
	end
end

endmodule

