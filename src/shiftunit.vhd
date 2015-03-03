----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	shiftunit.vhd:

-- unidad de shift
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.numeric_bit.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;




--En caso de ser un shift lógico, se hará a izquierda o derecha según el valor de left_or_right
--En caso de ser aritmético, se hará a la derecha ignorando el valor de left_or_right

entity shiftunit is
	port (input: in std_logic_vector(31 downto 0);
			shift_amount: in unsigned (4 downto 0);
			logic_or_arith, left_or_right: in std_logic; 
				--logic_or_arith: 1 logic 0 arith
				--left_or_right: 1 left 0 right
			output: out std_logic_vector (31 downto 0));
end shiftunit;

architecture Behavioral of shiftunit is

begin

process (input, shift_amount, logic_or_arith, left_or_right)
begin
	if logic_or_arith = '1' then
		if left_or_right = '1' then
			output <= to_stdlogicvector(to_bitvector(input) sll to_integer(shift_amount));
		else
			output <= to_stdlogicvector(to_bitvector(input) srl to_integer(shift_amount));
		end if;
	else
		output <= to_stdlogicvector(to_bitvector(input) sra to_integer(shift_amount));
	end if;
end process;


end Behavioral;

	
