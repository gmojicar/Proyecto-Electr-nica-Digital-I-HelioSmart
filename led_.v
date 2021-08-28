module led_(mode, sys_clk, pwm, parametro, parametromanual, distancia);

input [9:0] distancia;
input[15:0] parametro;
input [3:0] mode;
input [3:0] parametromanual;

wire [15:0]param = parametro/'d10;

reg [15:0] numero;

input sys_clk;
output reg pwm;
reg [27:0] contador = 0;
parameter lms = 250;

always @(posedge sys_clk) begin

	contador = contador + 1;
	if (contador>500-numero)begin
		contador=0;
		pwm = ~pwm;
		end
		if (contador<lms) pwm =0;
	else pwm = 1;
	
end

always @(*) begin

	if(distancia<'d100)begin
		if (mode == 4'b0010) begin
		case (parametromanual)
		9:numero <= 'd40;
		8:numero <= 'd120;
		7:numero <= 'd180;
		6:numero <= 'd210;
		5:numero <= 'd230;
		4:numero <= 'd240;
		3:numero <= 'd247;
		2:numero <= 'd250;
		default begin
		numero <= 'd495;
		end
		endcase
	end
		else if (mode == 4'b0001)begin
			if(parametro>4500)begin
				numero <= 'd495;
			end
			else
				numero <= param;
			
		end
		else
			numero <= 'd495;
		end
	else numero <= 'd495;
end
endmodule