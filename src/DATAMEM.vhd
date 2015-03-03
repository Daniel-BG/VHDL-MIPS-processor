----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	DATAMEM.vhd:

-- memoria de datos con cache y ram. Lectura asíncrona cuando no hay fallo, 
-- escritura síncrona. La cache guarda 8 bloques de 4 palabras de la RAM.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.tipos.all;



entity DATAMEM is
	generic (
		ADDR_WIDTH: integer := 10;
		DATA_WIDTH: integer := 32
	);
	port(
		data_in:	in std_logic_vector(DATA_WIDTH-1 downto 0);
		addr_in: in std_logic_vector(ADDR_WIDTH-1 downto 0);
		clk, writeEnable, readEnable: in std_logic;
		data_out: out std_logic_vector(DATA_WIDTH-1 downto 0);
		dataReady: out std_logic;
		--datos extra para el display
		blocks_addr_out: out addr_table;
		flags_out: out std_logic_vector(7 downto 0);
		mem_state: out std_logic_vector(3 downto 0);
		hits_out,fails_out: out std_logic_vector(15 downto 0)
	);
end DATAMEM;

architecture Behavioral of DATAMEM is

	signal ram_in, ram_out: std_logic_Vector(4*DATA_WIDTH-1 downto 0);
	signal ram_addr: std_logic_Vector(ADDR_WIDTH-3 downto 0);
	signal requestSave: std_logic;
	
begin
	
	ram_mem:	entity work.RAM
		generic map(DATA_WIDTH*4,ADDR_WIDTH-2)
		port map(ram_in, ram_out, ram_addr,clk, requestSave);
	cache_mem: entity work.CACHE
		generic map(ADDR_WIDTH,DATA_WIDTH)
		port map(data_in,data_out,addr_in,
					ram_out,ram_in,ram_addr,
					clk,writeEnable,readEnable,
					dataReady,requestSave,
					blocks_addr_out,flags_out,mem_state,
					hits_out,fails_out);
	
end Behavioral;

