----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	bancoRegistros.vhd:

-- Banco de registros de 32x32. Lectura asincrona. Escritura síncrona.
-- Registro_0 = 0 siempre
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;

entity bancoRegistros is
	port(
		ra_address, rb_address, rw_address : in std_logic_vector (4 downto 0);
		bus_write : in std_logic_vector (31 downto 0);
		regWrite,clk : in std_logic;
		busA,busB : out std_logic_vector(31 downto 0);
      banco_registros : out registros
	);
end bancoRegistros;

architecture Behavioral of bancoRegistros is
	
	signal bank_register : registros; -- señal intermedia para almacenar
	signal mem: registros_sin_z;
	
	subtype writeable_range is integer range 1 to 31; 
	signal selector: writeable_range;
begin
   -- salida para testeo
   banco_registros <= bank_register;
	connect: 
		for i in 1 to 31 generate
			bank_register(i) <= mem(i);
		end generate connect;
	bank_register(0) <= "00000000000000000000000000000000";
	
	
	
	-- escritura en banco
	selector <= to_integer(unsigned(rw_address));
	carga_banco : process (clk)
		begin
			--no permitimos escritura en r0
			if rising_edge(clk) then 
				if regWrite = '1' and (not(rw_address = "00000")) then
					mem(selector) <= bus_write;
				end if;
			end if;
	end process;

	
	busA <= bank_register(to_integer(unsigned(ra_address))); 
	busB <= bank_register(to_integer(unsigned(rb_address)));

end Behavioral;

