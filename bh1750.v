module bh1750#(parameter Freq_MegaHZ = 50)(sys_clk, _rst, str, SCL, SDA, data, busy);
input sys_clk, _rst, str;
inout SCL, SDA;
output [15:0]data;
output busy;

wire RW, start;
reg [14:0]measure_cycle = 'd0;
reg [8:0]cnt = 'd0;
reg [3:0]state = 'd0;
//---------------------------------------------------//
parameter IDLE    = 4'h0;
parameter Address = 4'h1;
parameter Ack_0   = 4'h2;
parameter W_data  = 4'h3;
parameter Ack_1   = 4'h4;
parameter NAck_1  = 4'h5;
parameter R_data  = 4'h6;
parameter NAck_2  = 4'h7;
parameter stop    = 4'h8;
parameter write   = 1'b1;
parameter read    = 1'b0;
parameter ADDR_H  = 7'b1011100;
parameter ADDR_L  = 7'b0100011;
//---------------------------------------------------//
reg scl_iic = 1'b1, sda_iic = 1'b1;
reg scl_gate = 1'b1, sda_gate = 1'b1;
reg clk_iic = 1'b0;
assign data = Rxdata;
assign SCL = (!scl_gate)?1'bz:scl_iic;//I/O
assign SDA = (!sda_gate)?1'bz:sda_iic;
assign busy = (state==IDLE&&measure_cycle>19500)?1'b0:1'b1;
assign RW = (measure_cycle<100)?1'b0:1'b1;
assign start = (str&&(measure_cycle<100||measure_cycle>19000))?1'b1:1'b0;
always@(posedge clk_iic)if(measure_cycle==20000) measure_cycle <= 'd0;else measure_cycle <= measure_cycle + 1'b1;
//---------------------------------------------------//
	always@(posedge sys_clk, negedge  _rst)begin
		if(!_rst)begin
			cnt     <= 'd0;
			clk_iic <= 1'b0;
		end
		else begin
			if(str)begin
				if(cnt==Freq_MegaHZ*5)begin// 
					clk_iic <= ~clk_iic;
					cnt     <= 'd0;
				end
				else 
					cnt <= cnt + 1'b1;
			end
			else begin
				cnt     <= 'd0;
				clk_iic <= 1'b0;
			end
		end
	end
//---------------------------------------------------//
wire clk_IR = (state==stop)?1'b1:1'b0;
reg [ 7:0]Txdata  = 'h11;
reg [ 1:0]IR = 'd0;
	always@(posedge clk_IR)begin
		IR <= IR + 1'b1;
		case(IR)
			2'b00:Txdata <= 8'h00;
			2'b01:Txdata <= 8'h01;
			2'b10:Txdata <= 8'h07;
			2'b11:Txdata <= 8'h21;
		endcase
	end
//---------------------------------------------------//
reg [15:0]Rxdata  = 'd0;
reg [ 3:0]RxCnt   = 'hF;
reg [ 3:0]clk_cnt = 'hB;
reg [ 2:0]TxCnt   = 'd7;
reg [ 7:0]IRreg   = 'h0;
reg ack_flag      = 'b0;
	always@(posedge clk_iic, negedge  _rst)begin
		if(!_rst)begin
			Rxdata  <= 16'h0000;
			sda_iic <= 1'b1;
			scl_iic <= 1'b1;
			RxCnt   <= 4'hF;
			TxCnt   <= 3'd7;
			IRreg   <= 8'd0;
			state   <= IDLE;
		end
		else begin
			case(state)
				IDLE:begin
					TxCnt <= 3'd7;
					RxCnt <= 4'hF;
					ack_flag <= 1'b0;
					sda_gate <= write;
					scl_gate <= write;
					if(start)begin
						clk_cnt <= clk_cnt - 1'b1;
						if(clk_cnt=='d0)begin
							clk_cnt <= 'hB;
							IRreg   <= {ADDR_H, RW};
							state   <= Address;
						end
						else if(clk_cnt=='d1)
							scl_iic <= 1'b0;
						else if(clk_cnt=='d3)
							sda_iic <= 1'b0;
					end
					else begin
						sda_iic  <= 1'b1;
						scl_iic  <= 1'b1;
						clk_cnt  <= 4'hB;
						state    <= IDLE;
					end
				end
				Address:begin
					clk_cnt <= clk_cnt - 1'b1;
					if(clk_cnt=='d0)begin
						clk_cnt  <= 'hB;
						TxCnt    <= TxCnt - 1'b1;
						if(TxCnt=='d0)begin
							TxCnt    <= 3'd7;
							sda_gate <= read;
							state    <= Ack_0;
						end
						else 
							state <= Address;
					end
					else if(clk_cnt=='d2)
						sda_iic <= 1'b0;
					else if(clk_cnt=='d3)
						scl_iic <= 1'b0;
					else if(clk_cnt=='d8)
						scl_iic <= 1'b1;
					else if(clk_cnt=='d9)
						sda_iic <= IRreg[TxCnt];
				end
				Ack_0:begin
					clk_cnt <= clk_cnt - 1'b1;
					if(clk_cnt=='d0)begin
						if(ack_flag)begin
							clk_cnt  <= 'hB;
							ack_flag <= ~ack_flag;
							if(!IRreg[0])begin
								sda_gate <= write;
								state    <= W_data;
							end
							else begin
								RxCnt    <= 4'hF;
								sda_gate <= read;
								state    <= R_data;
							end
						end
						else begin
							clk_cnt <= 'd2;
							state   <= Ack_0;
						end
					end
					else if(clk_cnt=='d3)
						scl_iic <= 1'b0;
					else if(clk_cnt=='d8)
						scl_iic <= 1'b1;
					else if(clk_cnt<'d8)begin
						if(!SDA)
							ack_flag <= 1'b1;
						else
							ack_flag <= ack_flag;
					end
				end
				W_data:begin
					clk_cnt <= clk_cnt - 1'b1;
					if(clk_cnt=='d0)begin
						clk_cnt  <= 'd11;
						TxCnt    <= TxCnt - 1'b1;
						if(TxCnt=='d0)begin
							TxCnt    <= 3'd7;
							sda_gate <= read;
							state    <= Ack_1;
						end
						else 
							state <= W_data;
					end
					else if(clk_cnt=='d1)
						sda_iic <= 1'b0;
					else if(clk_cnt=='d3)
						scl_iic <= 1'b0;
					else if(clk_cnt=='d8)
						scl_iic <= 1'b1;
					else if(clk_cnt=='d9)
						sda_iic <= Txdata[TxCnt];
				end
				Ack_1:begin
					clk_cnt <= clk_cnt - 1'b1;
					if(clk_cnt=='d0)begin
						if(ack_flag)begin
							clk_cnt  <= 'hB;
							sda_gate <= write;
							ack_flag <= ~ack_flag;
							state <= stop;
						end
						else begin
							clk_cnt <= 'd2;
							state <= Ack_1;
						end
					end
					else if(clk_cnt=='d3)
						scl_iic <= 1'b0;
					else if(clk_cnt=='d8)
						scl_iic <= 1'b1;
					else if(clk_cnt<'d8)begin
						if(!SDA)
							ack_flag <= 1'b1;
						else
							ack_flag <= ack_flag;
					end
				end
				R_data:begin
					clk_cnt  <= clk_cnt - 1'b1;
					if(clk_cnt=='d0)begin
						clk_cnt  <= 'hB;
						RxCnt    <= RxCnt - 1'b1;
						if(RxCnt=='h8)begin
							sda_iic  <= 1'b0;
							sda_gate <= write;
							state    <= NAck_1;
						end
						else if(RxCnt=='h0)begin
							RxCnt    <= 4'hF;
							sda_gate <= write;
							state    <= NAck_2;
						end
						else 
							state <= R_data;
					end
					else if(clk_cnt=='d3)
						scl_iic <= 1'b0;
					else if(clk_cnt=='d8)
						scl_iic <= 1'b1;
					else if(clk_cnt=='d6)
						Rxdata[RxCnt] <= SDA;
				end
				NAck_1:begin
					clk_cnt <= clk_cnt - 1'b1;
					sda_iic <= 1'b0;
					if(clk_cnt=='d0)begin
						clk_cnt  <= 'hB;
						sda_gate <= read;
						state    <= R_data;
					end
					else if(clk_cnt=='d3)
						scl_iic <= 1'b0;
					else if(clk_cnt=='d8)
						scl_iic <= 1'b1;
				end
				NAck_2:begin
					clk_cnt <= clk_cnt - 1'b1;
					if(clk_cnt>1)
						sda_iic <= 1'b1;
					else
						sda_iic <= 1'b0;
					
					if(clk_cnt=='d0)begin
						clk_cnt  <= 'hB;
						sda_gate <= write;
						state    <= stop;
					end
					else if(clk_cnt=='d3)
						scl_iic <= 1'b0;
					else if(clk_cnt=='d8)
						scl_iic <= 1'b1;
				end
				stop:begin
					clk_cnt <= clk_cnt - 1'b1;	
					if(clk_cnt=='d0)begin
						clk_cnt <= 'hB;
						state   <= IDLE;
					end
					else if(clk_cnt=='d6)
						sda_iic <= 1'b1;
					else if(clk_cnt=='d8)
						scl_iic <= 1'b1;
				end
			endcase
		end
	end
//---------------------------------------------------//
endmodule 