----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	timerperipheral.vhd:

-- periférico con contador que incrementa en 1 cada vez que pasa un ciclo de reloj
-- por él
-- COMANDOS:
--		0: funcionamiento habitual
--		1: resetear a cero el contador
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;



entity timerperipheral is
	port (
		pericommand: in std_logic;
		peridata_out: out std_logic_vector(31 downto 0);
		clk,enable: in std_logic
	);
end timerperipheral;

architecture Behavioral of timerperipheral is
	signal currenttime: integer := 0;
begin

	update: process(clk) 
	begin
		if rising_edge(clk) then
			if (enable = '1' and pericommand = '1') then
				currenttime <= 0;
			else
				currenttime <= currenttime + 1;
			end if;
		end if;
	end process update;
	
	peridata_out <= conv_std_logic_vector(currenttime,32);

end Behavioral;

