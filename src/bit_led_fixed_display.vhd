----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	bit_led_fixed_display.vhd:

-- MATRIZ de NxM LEDS genérica situable en cualquier posición de la pantalla.
-- valor on u off es fijo y no dinámico (como en bit_led_matrix)
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;



entity bit_led_fixed_display is
	generic	(
					X: integer := 0;			--posición esquina superior izquierda (X)
					Y: integer := 0;			--posición esquina superior izquierda (Y)
					HEIGHT: integer := 4;	--altura de cada pixel de la matrix
					WIDTH: integer := 2;		--anchura de cada pixel
					N: integer := 19;			--numero de columnas
					M: integer := 5;			--numero de filas
					HGAP: integer := 0;		--espaciado entre columnas (pixeles en blanco)
					VGAP: integer := 0;		--espaciado entre filas (pixeles en blanco)
					--esta señal entra al revés porque asi lo requiere la generación que se ha implementado
					pixels: std_logic_vector := "11111000001010100011000000000101010001111110111110101010100001010001010110111111101111101010001"
				);
	port		(
					cX,cY: in std_logic_vector(8 downto 0);	
					--enabled cuando agún píxel está bajo las coordenadas cX y cY
					enabled: out std_logic
				);
end bit_led_fixed_display;

architecture Behavioral of bit_led_fixed_display is
	
	function count_sub_ones(s : std_logic_vector; count_end : natural ) return integer is
		variable temp : integer := 0;
	begin
		for i in s'range loop
			if s(i) = '1' then 
				temp := temp + 1; 
			end if;
			if i = count_end then
				exit;
			end if;
		end loop;
		return temp;
	end function count_sub_ones;
	
	function count_ones(s : std_logic_vector) return integer is
		variable temp : integer := 0;
	begin
		for i in s'range loop
			if s(i) = '1' then 
				temp := temp + 1; 
			end if;
		end loop;
		return temp;
	end function count_ones;
	
	signal enabled_comp: std_logic_vector(count_ones(pixels)-1 downto 0);
	

begin

	assert N*M = pixels'length 
		report "Se necesitan tantos pixeles de entradas como N*M casillas hay" 
			severity failure;

	--generate de todas las celdas de la matriz
	gen_cols: 
		for i in 0 to M-1 generate
			gen_rows:
				for j in 0 to N-1 generate
					gen_pixel:
						if pixels(N*i+j) = '1' generate
							u: entity work.bit_led_fixed
								generic map (X+(WIDTH+HGAP)*j,Y+(HEIGHT+VGAP)*i,HEIGHT,WIDTH)
								port map(cX,cY,enabled_comp(count_sub_ones(pixels, N*i+j)-1)); 
						end generate gen_pixel;
				end generate gen_rows;
		end generate gen_cols;
		
	--OR entre todas las enable_on de los pixeles individuales
	enable_cuad_on: process(enabled_comp)
		begin
			if enabled_comp = (enabled_comp'range => '0') then
				enabled <= '0';
			else
				enabled <= '1';
			end if;
		end process;

end Behavioral;

