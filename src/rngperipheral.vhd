----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel B�scones Garcia
--		-David Pe�as G�mez
--		-��igo Zunzunegui Monterrubio
-- 
--	rngperipheral.vhd:

-- perif�rico que genera n�meros aleatorios tras cada acceso a �l. Es decir, tras
-- un acceso, en el ciclo siguiente no se obtendr� el mismo valor
-- COMANDOS:
--		0: funcionamiento habitual
--		1: resetear a peridata_in el rng
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rngperipheral is
	port (
		peridata_in: in std_logic_vector(15 downto 0);
		pericommand: in std_logic;
		peridata_out: out std_logic_vector(31 downto 0);
		clk,enable: in std_logic
	);
end rngperipheral;

architecture Behavioral of rngperipheral is
	signal data: std_logic_vector(31 downto 0) := "01010010101010010100001010001010";
	signal nextbit: std_logic;
	
begin
	-- c�lculo del siguiente bit mediante el polinomio x^32 + x^22 + x^2 + x^1 + 1
	nextbit <= data(31) xnor data(21) xnor data(1) xnor data(0);

	-- actualizaci�n del siguiente estado (cada vez que llega el reloj)
	update: process (clk, enable)
	begin
		if rising_edge(clk) and enable = '1' then
			if pericommand = '1' then
				data <= "0000000000000000" & peridata_in;
			else
				data <= data(30 downto 0) & nextbit;
			end if;
		end if;
	end process update;
	
	-- colocaci�n del dato en la salida 
	peridata_out <= data;

end Behavioral;

