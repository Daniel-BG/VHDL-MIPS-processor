----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	RAM.vhd:

-- memoria RAM con lectura y escritura en bloque de tamaño variable
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.tipos;



entity RAM is
	generic (
		WORD_WIDTH: integer := 128;
		ADDR_SIZE: integer := 8
	);
	port(
		data_in : in std_logic_vector(WORD_WIDTH-1 downto 0);
		data_out : out std_logic_vector(WORD_WIDTH-1 downto 0);
		address : in std_logic_vector(ADDR_SIZE-1 downto 0);
		clk, writeEnable : in std_logic
	);
end RAM;

architecture Behavioral of RAM is
	
	-- array con hueco para todos los datos y señal que lo instancia
	type memoria is array (0 to 2**ADDR_SIZE-1) of std_logic_vector(WORD_WIDTH-1 downto 0); 
	signal data_mem : memoria := (others => (others => '1')) ;

begin

	carga_banco : process (writeEnable,clk)
		begin
			if clk'event and clk = '1' then
				if writeEnable = '1' then
					data_mem(to_integer(unsigned(address))) <= data_in;
				end if;
				data_out <= data_mem(to_integer(unsigned(address)));
			end if;
	end process;
	


end Behavioral;



