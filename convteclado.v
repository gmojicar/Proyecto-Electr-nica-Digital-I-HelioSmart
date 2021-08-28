module convteclado(fil, col, num);
input [3:0] fil;
input [3:0] col;
output reg [3:0] num;

always @(*)begin
	if (col == 4'b0001)begin
		case(fil)
			4'b0001: num = 'd1;
			4'b0010: num = 'd4;
			4'b0100: num = 'd7;
			4'b1000: num = 'hf;
		endcase
		end
	if (col == 4'b0010)begin
		case(fil)
			4'b0001: num = 'd2;
			4'b0010: num = 'd5;
			4'b0100: num = 'd8;
			4'b1000: num = 'd0;
		endcase
		end
	if (col == 4'b0100)begin
		case(fil)
			4'b0001: num = 'd3;
			4'b0010: num = 'd6;
			4'b0100: num = 'd9;
			4'b1000: num = 'he;
		endcase
		end
	if (col == 4'b1000)begin
		case(fil)
			4'b0001: num = 'ha;
			4'b0010: num = 'hb;
			4'b0100: num = 'hc;
			4'b1000: num = 'hd;
		endcase
		end
	else begin
		num <= num;
	end
		
end
endmodule