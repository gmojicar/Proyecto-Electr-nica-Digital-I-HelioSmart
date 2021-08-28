module led0(mode, clk, pwm, parametro, parametromanual, presencia);

input[15:0] parametro;
input clk;
input [3:0] mode;
input [2:0] parametromanual;
input [9:0] presencia;
output reg pwm;
reg [27:0] contador = 0;
reg [15:0] numero;
reg [5:0]lms = 30;
wire [15:0] param=parametro/'d10;

always@(posedge clk) begin
	contador=contador+1;
	if (contador>numero)begin
	contador=0;
	pwm = ~pwm;
	end
	
	if (contador<lms) pwm = 1;
	else pwm =0;
	
end

always@(*)begin
if(presencia<100)begin
	lms <= 'd30;
	if (mode == 4'b0001) begin
		case(parametromanual)

//		///   15: numero <= 'd1000;
//		  /// 14: numero <= 'd1000;
//		  /// 13: numero <= 'd1000;
//		   ///12: numero <= 'd1000;
//		   ///11: numero <= 'd1000;
//		   ///10: numero <= 'd1000;
//		   ///9: numero <= 'd1000;
//			///8: numero <= 'd1000;
//		   ///7: numero <= 'd1000;
//		   ///6: numero <= 'd1000;
//		   ///5: numero <= 'd1000;



//			7: numero <= 'd30;
//			6: numero <= 'd60;
//			5: numero <= 'd80;
//			4: numero <= 'd120;
//			3: numero <= 'd150;
//			2: numero <= 'd300;
//			1: numero <= 'd400;
//			0: numero <= 'd1000;
			
			
			
//		/	4'h1: numero <= 'd10000;
//		/	4'h5: numero <= 'd1000;
//		/	4'h9: numero <= 'd100;
//		/	4'hd: numero <= 'd10;

			7: numero <= 'd300;
			6: numero <= 'd600;
			5: numero <= 'd800;
			4: numero <= 'd1200;
			3: numero <= 'd1500;
			2: numero <= 'd3000;
			1: numero <= 'd4000;
			0: numero <= 'd10000;

			default: numero <= numero;

		endcase
	end
	else if (mode == 4'b0010) begin
		if (parametro<30000)begin
		numero <= parametro;
		end
		else begin
		lms<='d0;
		end
	end
	else begin
		lms <= 'd0;
	end
end
else begin
lms <= 'd0;
//numero <= 'd162000000000000;
end
end

endmodule