----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	sumaresta.vhd:

-- sumador/restador para la ALU. Saca además bits de control con información
-- sobre el resultado obtenido
-- ignora desbordamientos en cuyo caso el resultado no es determinado
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sumaresta is
	port (in_1, in_2: in std_logic_vector (31 downto 0);
			control: in std_logic; --0 suma 1 resta
			output: out std_logic_vector (31 downto 0);
			mayor, menor, igual: out std_logic);
end sumaresta;

architecture Behavioral of sumaresta is

signal resultado : std_logic_vector (31 downto 0);

begin
	--process para sumar o restar
	operar: process (in_1, in_2, control)
	begin
		if control = '0' then
			resultado <= std_logic_vector(signed(in_1) + signed(in_2));
		else
			resultado <= std_logic_vector(signed(in_1) - signed(in_2));
		end if;
	end process operar;

	--process para poner los flags a su valor adecuado y la salida también
	comparar_y_asignar: process (resultado)
	begin
		--poner bit de igual a 1 o 0 (igual o distinto)
		if resultado = "00000000000000000000000000000000" then
			igual <= '1';
		else
			igual <= '0';
		end if;
		--bit de mayor a 1 (mayor) o 0 (menor o igual)
		if resultado > "00000000000000000000000000000000" and resultado(31) = '0' then
			mayor <= '1';
		else
			mayor <= '0';
		end if;
		--bit de menor a 1 (menor) o 1 (mayor o igual)
		menor <= resultado(31);
		output <= resultado;
	end process comparar_y_asignar;
	
end Behavioral;

