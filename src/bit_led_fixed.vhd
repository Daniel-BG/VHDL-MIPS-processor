----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	bit_led_fixed.vhd:

-- Pixel de tamaño configurable en pantalla, con valor on fijo
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;



entity bit_led_fixed is
	generic	(
				--posición superior izquierda
				X: integer := 0;
				Y: integer := 0;
				--anchura y altura
				HEIGHT: integer := 5;
				WIDTH: integer := 5
				);
	port		(
				cX,cY: in std_logic_vector(8 downto 0);
				--enable cuando estamos dentro del pixel
				enable: out std_logic
				);
end bit_led_fixed;

architecture Behavioral of bit_led_fixed is

begin

en_on: process(cX,cY)
	begin
		if cX >= X and cX <= X+WIDTH-1 and cY >= Y and cY <= Y+HEIGHT-1 then
			enable <= '1';
		else
			enable <= '0';
		end if;
	end process;
	

end Behavioral;

