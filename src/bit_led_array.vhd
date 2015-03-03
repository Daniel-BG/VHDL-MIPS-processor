----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	bit_led_array.vhd:

-- Array genérico de N pixels de largo para situar en la pantalla de la VGA
-- Puede ser tanto orientado vertical como horizontal
--
-----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


entity bit_led_array is
	generic	(
					--Posición de la esquina superior izquierda del componente
					X: integer := 0;
					Y: integer := 0;
					--altura y anchura de los píxeles individuales
					HEIGHT: integer := 4;
					WIDTH: integer := 6;
					--numero de celdas
					N: integer := 8;
					--separación entre celdas
					GAP: integer := 2;
					--si se colocan en horizontal o en vertical (false)
					isHorizontal: boolean := true
				);
	port		(
					--bits que indican si cada pixel está encendido o no (de arriba hacia abajo
					--o de izquierda a derecha, dependiendo de isHorizontal)
					bits: in std_logic_vector(N-1 downto 0);
					--coordenada actual VGA
					cX,cY: in std_logic_vector(8 downto 0);
					--enabled_on = 1 cuando la coordenada actual esté dentro de un pixel y el bit de ese pixel sea 1
					--enabled_off = 1 en el mismo caso, pero con pixel = 0
					--cuando la coordenada actual no coincide con la de ningún pixel, ambas valen cero
					enabled_on, enabled_off: out std_logic
				);
end bit_led_array;

architecture Behavioral of bit_led_array is

signal cuadrados_on, cuadrados_off: std_logic_vector(N-1 downto 0);


begin

	--generate de las celdas, bien en horizontal o en vertical
	gen_on_off: 
		for i in 0 to N-1 generate
			hor: if isHorizontal generate
					u: entity work.bit_led 	
									generic map	(X+(WIDTH+GAP)*i,Y,HEIGHT,WIDTH)
									port map		(bits(N-1-i),cX,cY,cuadrados_on(i),cuadrados_off(i));
			end generate;
			ver: if not isHorizontal generate
					u: entity work.bit_led 
									generic map	(X,Y+(HEIGHT+GAP)*i,HEIGHT,WIDTH)
									port map		(bits(N-1-i),cX,cY,cuadrados_on(i),cuadrados_off(i));
			end generate;
		end generate gen_on_off;
		
	--OR de las activaciones de enable_on
	enable_cuad_on: process(cuadrados_on)
		begin
			if cuadrados_on = conv_std_logic_vector(0,N) then
				enabled_on <= '0';
			else
				enabled_on <= '1';
			end if;
		end process;
		
	--OR de las activaciones de enable_off
	enable_cuad_off: process(cuadrados_off)
		begin
			if cuadrados_off = conv_std_logic_vector(0,N) then
				enabled_off <= '0';
			else
				enabled_off <= '1';
			end if;
		end process;

end Behavioral;

