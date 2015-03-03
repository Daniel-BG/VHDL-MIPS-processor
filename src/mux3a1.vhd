----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	mux3a1.vhd:

-- Mux 3a1
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


-- cuando el control sea 10 o 11, el resultado será la tercera salida

entity mux3a1 is
	generic (N: integer := 32);
	port(
		in_0,in_1,in_2: in std_logic_vector (N-1 downto 0);
		salida : out std_logic_vector (N-1 downto 0);
		control : in std_logic_vector (1 downto 0)
	);
end mux3a1;

architecture Behavioral of mux3a1 is
begin

	asig : process(control, in_1,in_2,in_0)
	begin
		case control is
			when "00"	=> salida <= in_0;
			when "01"	=> salida <= in_1;
			when others => salida <= in_2;
		end case;
	end process;

end Behavioral;

