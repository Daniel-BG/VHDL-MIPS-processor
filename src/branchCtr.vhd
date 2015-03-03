----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	branchCtr.vhd:

-- control de saltos para el PC
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.tipos.all;



entity branchCtr is
	port(
		control: in branchCtrl;
		menor,mayor,igual: in std_logic;
		pcControl: out std_logic_vector(1 downto 0)
	);
	end branchCtr;

architecture Behavioral of branchCtr is

begin
	calcularSalida: process (control,menor,mayor,igual)
	begin
		case control is
			when b_always	=> pcControl <= "01";
			when b_reg 		=> pcControl <= "00";
			when b_eq		=> if igual = '1' then
										pcControl <= "01";
									else
										pcControl <= "10";
									end if;
			when b_ne		=> if igual = '0' then
										pcControl <= "01";
									else
										pcControl <= "10";
									end if;
			when b_lt		=> if menor = '1' then
										pcControl <= "01";
									else
										pcControl <= "10";
									end if;
			when b_gt		=> if mayor = '1' then
										pcControl <= "01";
									else
										pcControl <= "10";
									end if;
			when b_le		=> if menor = '1' or igual = '1' then
										pcControl <= "01";
									else
										pcControl <= "10";
									end if;
			when b_ge		=> if mayor = '1' or igual = '1' then
										pcControl <= "01";
									else
										pcControl <= "10";
									end if;
			when others 	=> pcControl <= "10";
		end case;
	end process;


end Behavioral;

