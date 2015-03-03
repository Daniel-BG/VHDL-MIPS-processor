----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel B�scones Garcia
--		-David Pe�as G�mez
--		-��igo Zunzunegui Monterrubio
-- 
--	completaceros.vhd:

-- A�ade 27 ceros a la izquierda de 5 bits hasta tener 32
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


entity completaceros is
port(
	entrada : in std_logic_vector (4 downto 0);
	salida : out std_logic_vector (31 downto 0)
);
end completaceros;

architecture Behavioral of completaceros is

begin

salida <= conv_std_logic_vector(0,27) & entrada;

end Behavioral;

