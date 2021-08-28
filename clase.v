module clase (clk, trigg, echo, dist);
input clk;
input echo;
output reg trigg;
output reg [9:0] dist;
reg [26:0] cont;
reg [26:0] cont_t;

initial begin 
	cont = 0;
	trigg = clk;
	dist = 0;
	cont_t = 0;
end

always @(posedge clk) begin
	cont = cont + 1;
	
	if (cont<1024)
		trigg = 1'b1;
	else begin
		trigg = 1'b0;
		
		if (echo == 1)begin
			
			cont_t = cont_t + 1;
			dist = (cont_t*34/200_000)*2;
		
			end
		else if (echo == 0)begin
			
			cont_t = 0;
			
			end
		end
end

endmodule

