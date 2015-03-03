----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	shifter.vhd:

-- Añade 16 ceros a la derecha de una señal de 16 bits
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity shifter16 is
port(
	entrada : in std_logic_vector (15 downto 0);
	salida : out std_logic_vector (31 downto 0)
);
end shifter16;

architecture Behavioral of shifter16 is
begin

salida <= entrada & "0000000000000000";

end Behavioral;

