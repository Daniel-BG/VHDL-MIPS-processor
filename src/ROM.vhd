----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	ROM.vhd:

-- ROM genérica de N: bits para las direcciones y M: direcciones
-- 32 bits de ancho siempre
-- lectura SÍNCRONA
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use work.tipos;


entity ROM is
	generic (
		N: integer := 6;
		filePath : string := "bolinga.data"
	);
	port(
		data_out : out std_logic_vector(31 downto 0);
		address : in std_logic_vector(N-1 downto 0);
		clk : in std_logic
	);
end ROM;

architecture Behavioral of ROM is
	-- tipo registros que es array de M-1 posiciones tamaño 32
	type memoria is array (0 to 2**N-1) of bit_vector(31 downto 0); 
	
	-- función para la carga de memoria
	impure function init_mem_from_file (file_name : in string) return memoria is 
		file		mem_file			: text is in file_name; 
		variable	mem_file_line	: line; 
		variable	mem				: memoria; 
	begin 
		for i in memoria'range loop 
			readline	(mem_file,			mem_file_line); 
			read		(mem_file_line,	mem(i)); 
		end loop; 
		return mem; 
	end function; 
	
	-- contenido de la memoria en sí
	constant memoria_rom : memoria := init_mem_from_file(filePath); 
begin
	-- lectura síncrona de la memoria
	lectura_banco : process (clk)
		begin
			if clk'event and clk = '1' then
				data_out <= to_stdlogicvector(memoria_rom(to_integer(unsigned(address))));
			end if;
	end process;
	


end Behavioral;

