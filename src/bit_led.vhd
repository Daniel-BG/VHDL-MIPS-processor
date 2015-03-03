----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	bit_led.vhd:

-- Pixel de tamaño configurable en pantalla
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;



entity bit_led is
	generic	(
				--posición superior izquierda
				X: integer := 0;
				Y: integer := 0;
				--anchura y altura
				HEIGHT: integer := 5;
				WIDTH: integer := 5
				);
	port		(
				--entrada (1 iluminado 0 no), coordenada actual
				input: in std_logic;
				cX,cY: in std_logic_vector(8 downto 0);
				--enable on es 1 si el pixel está en zona de dibujo y encendido
				--enable off es 1 en el mismo caso, pero cuando input = '0'
				enable_on, enable_off: out std_logic
				);
end bit_led;

architecture Behavioral of bit_led is

begin

en_on: process(input,cX,cY)
	begin
		if cX >= X and cX <= X+WIDTH-1 and cY >= Y and cY <= Y+HEIGHT-1 then
			if input = '1' then
				enable_on	<= '1';
				enable_off	<= '0';
			else
				enable_on	<= '0';
				enable_off	<= '1';
			end if;
		else
			enable_on	<= '0';
			enable_off	<= '0';
		end if;
	end process;
	

end Behavioral;

