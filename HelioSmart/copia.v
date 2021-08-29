module copia(clk, pwm, fil, col, trigg, echo, LCD_RW, LCD_EN, LCD_RS, LCD_DATA, _rst, SCL, SDA, le);

output wire[9:0] le;
input clk;
output pwm;
reg [3:0] numt; //Provisional
//_______________________________v. de ultrasonido_________________________________//
output trigg;
input echo;
//_______________________________v. de LCD_________________________________//
output LCD_RW;        
output LCD_EN;     
output LCD_RS; 
inout [7:0] LCD_DATA; 
//_______________________________v. de teclado_________________________________//
output [3:0] fil;
input [3:0] col;
reg [3:0] modo= 4'b0000;

reg [3:0] mensaje1;
divfreq q(clk, clk1k);

//_______________________________Parámetros_________________________________//
parameter sby = 4'b0000;
parameter auto = 4'b0001;
parameter manual = 4'b0010;


//_______________________________v. de modo_________________________________________________//

reg [3:0] selectmode = 4'b0000;


//_______________________________v. de cambio_______________________________________________//
wire [3:0] num;

//_______________________________modulos teclado_________________________________//
barrido b(clk1k, fil);
convteclado(fil, col, num);
//_______________________________modulos driver auto/manual pwm_________________________________//

led l(mensaje1, clk, pwm, parametro, numt, distancia);

//_______________________________v. bh1750____________________________________________________//
input _rst;
inout SDA, SCL;
wire busy;//
wire [15:0] parametro;//

//__________________________sensor ultrasonico para obtener distancia__________________//
wire [9:0]distancia;
clase c(clk,trigg, echo, distancia);
//---------------------------------------------------//	
	bh1750 #(.Freq_MegaHZ(50))
		U0(
			.sys_clk(clk),
			._rst(_rst),
			.str(1'b1),
			.SCL(SCL),
			.SDA(SDA),
			.data(parametro),
			.busy(busy)
	);
	
always @(*)begin
	numt <= num;
end

reg [1:0]vari = 2'b11;

always @(posedge clk1k)begin
	if (numt==4'ha)begin
		vari <= 2'b01;
	end
	else if(numt == 4'hc)begin
		vari <= 2'b10;
	end
	else begin
		vari <= 2'b11;
	end
end

always @(posedge clk1k)begin
case (modo)
	sby:		begin

				//sby: StandBy		lcd1: Pantalla de bienvenida
				mensaje1 <= 4'b0000;

				if(vari==2'b11)begin
						modo <= sby;
					end
				else if (vari==2'b10)begin
						modo <= manual;
					end
				else if(vari == 2'b01)
					modo <= auto;
				end
				
	auto:		begin
				
				mensaje1 <= 4'b0001;

					if(numt == 4'hf)begin
						modo <= sby;
					end
				else modo <= auto;
				
				end
				
	manual: 	begin

				mensaje1 <= 4'b0010;
	
					if(numt == 4'hf)begin
						modo <= sby;
					end
				else modo <= manual;
				end
				
	default begin
		modo <= sby;
	end
endcase
end

LCD_Top(clk, LCD_RW, LCD_EN, LCD_RS, LCD_DATA, mensaje1);
endmodule
