module barrido (clk1k, fil);
input clk1k;
output reg [3:0] fil = 4'b0000;
reg [1:0] selec;

always @(posedge clk1k)begin
selec = selec + 1;
	case(selec)
		2'b00: fil = 4'b0001;
		2'b01: fil = 4'b0010;
		2'b10: fil = 4'b0100;
		2'b11: fil = 4'b1000;
	endcase
end
endmodule
