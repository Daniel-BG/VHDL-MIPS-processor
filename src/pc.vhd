----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel B�scones Garcia
--		-David Pe�as G�mez
--		-��igo Zunzunegui Monterrubio
-- 
--	pc.vhd:

-- registro que guarda el PC, con funci�n de reset tambi�n para reiniciar el 
-- ordenador. Adem�s saca el pc que deberia ir a la rom para lectura de la
-- siguiente instrucci�n
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity pc is
	generic (
			WIDTH: integer := 6
		);
	port(
			pcIn: in std_logic_vector (WIDTH-1 downto 0);
			clk,reset,enable: in std_logic;
			pcOut: out std_logic_vector (WIDTH-1 downto 0);
			pc_to_rom: out std_logic_vector (WIDTH-1 downto 0)
		);
end pc;

architecture Behavioral of pc is

	signal pc_out: std_logic_Vector(WIDTH-1 downto 0);
	
begin
	-- se�al intermedia para poder referenciarla en pc_to_rom
	pcOut <= pc_out;

	-- entrada de PC a la ROM, que depende de si se avanza el PC o no.
	-- en caso de no avanzarlo, debemos cargar la misma instrucci�n actual (pc_act)
	-- en caso contrario, la del pc_sig.
	pc_to_rom	<= pc_out(WIDTH-1 downto 0) when enable = '0' 
						else pcIn(WIDTH-1 downto 0);

	-- actualizaci�n de PC
	update: process (clk,reset)
	begin
		if reset = '1' then
			pc_out <= (others => '0');
		else
			if rising_edge(clk) then
				if enable = '1' then
					pc_out <= pcIn;	
				end if;
			end if;
		end if;
	end process;

end Behavioral;

