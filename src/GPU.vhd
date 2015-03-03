----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
-- GPU.vhd:

-- GPU de doble búfer que guarda 32x32 píxeles con profundidad de 512 colores
-- Se puede, gracias al doble búfer, leer y escribir en el mismo píxel a la vez
-- Nótese que a la hora de escribir se necesitan dos ciclos, en lugar de uno
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;



entity GPU is
	generic	(
					X: integer := 0;			--posición esquina superior izquierda (X)
					Y: integer := 0;			--posición esquina superior izquierda (Y)
					COLORSIZE: integer := 9	--tamaño del color
				);
	port		(
					--coordenadas actuales de la pantalla VGA
					cX,cY: in std_logic_vector(8 downto 0);
					--coordenadas relativas donde escribir
					wX,wY: in std_logic_vector(4 downto 0);
					color_in: in std_logic_vector(COLORSIZE-1 downto 0);
					write_enable, clk: in std_logic;
					color_out: out std_logic_vector(COLORSIZE-1 downto 0);
					output_enable: out std_logic
				);
end GPU;

architecture Behavioral of GPU is
	--anchura de pixel:2
	--altura de pixel:4
	--separacion horizontal:2
	--separacion vertical:4
	signal relativex: std_logic_vector(8 downto 0);
	signal relativey: std_logic_vector(7 downto 0);
	signal xcoord, ycoord: std_logic_vector(4 downto 0);
	signal overX, overY: std_logic;
	
	signal fulladdr, fulladdrwrite: std_logic_vector(9 downto 0);
	
	type colorarray is array (0 to 1023) of std_logic_vector(COLORSIZE-1 downto 0);
	signal colores1, colores2: colorarray;
	
	signal doublebuffer: std_logic := '0';

	signal color_out1, color_out2: std_logic_vector(COLORSIZE-1 downto 0);
	
begin

	--coordenada relativa en pantalla
	relativex <= std_logic_vector(unsigned(cX) - unsigned(conv_std_logic_vector(X,9)));
	relativey <= std_logic_vector(unsigned(cY(8 downto 1)) - unsigned(conv_std_logic_vector(Y/2,8)));
	--coordenada actual (0-31) del pixel de la pantallita
	--por alguna razón, la x se dibuja desplazada en una unidad. Esto lo arregla
	xcoord <= std_logic_vector(signed(relativex(4 downto 0)) + "00001");
	ycoord <= relativey(4 downto 0);
	
	--flags por si estamos fuera de rango de pantalla
	overX <= '1' when to_integer(unsigned(cX)) < X or not (relativex(8 downto 5) = "0000")	else '0';
	overY <= '1' when to_integer(unsigned(cY)) < Y or not (relativey(7 downto 5) = "000")	else '0';
	

	--concatenamos las dos coordenadas para hacer 1024 posiciones (32x32)
	fulladdr <= xcoord & ycoord;
	fulladdrwrite <= wX & wY;
	
	
	doublebufferprocess: process(clk, write_enable)
	begin
		if rising_edge(clk) then
			doublebuffer <= not(doublebuffer);
		end if;	
	end process;
	
	update_1: process(clk, write_enable)
	begin
		if rising_edge(clk) then
			if doublebuffer = '0' and write_enable = '1' then
				colores1(to_integer(unsigned(fulladdrwrite))) <= color_in;
			else
				color_out1 <= colores1(to_integer(unsigned(fulladdr)));
			end if;
		end if;	
	end process;
	
	update_2: process(clk, write_enable)
	begin
		if rising_edge(clk) then
			if doublebuffer = '1' and write_enable = '1' then
				colores2(to_integer(unsigned(fulladdrwrite))) <= color_in;
			else
				color_out2 <= colores2(to_integer(unsigned(fulladdr)));
			end if;
		end if;	
	end process;
	
	color_out <= color_out1 when doublebuffer = '0' else color_out2;
	
	
	--si están las coordenadas dentro de la pantalla o no
	output_enable <= '0' when (overX = '1' or overY = '1') else '1';
	
end Behavioral;

