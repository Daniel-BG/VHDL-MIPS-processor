----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel B�scones Garcia
--		-David Pe�as G�mez
--		-��igo Zunzunegui Monterrubio
-- 
--	logicunit.vhd:

-- unidad l�gica del procesador. Capaz de realizar las 16 funciones l�gicas ante
-- dos entradas de 1 bit
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity logicunit is
	port (in_1, in_2 : in std_logic_vector(31 downto 0);
			control: in std_logic_vector (3 downto 0);
			output: out std_logic_vector (31 downto 0));
	end logicunit;
architecture Behavioral of logicunit is
begin
		
	bitgen: for i in 0 to 31 generate
	--con control introducimos la tabla de verdad que queremos aplicar a los bits de in_1 e in_2,
	--con cada combinaci�n de la tabla de verdad hacemos la and con control(i), y �sta ser� la salida i�sima.
	--control(0) para 00, control(1) para 01, control(2) para 10, control(3) para 11, siguiendo el valor decimal de la tabla de verdad
		output(i) <= 	(not(in_1(i))	and not(in_2(i))	and control(0))
						or (not(in_1(i))	and in_2(i)			and control(1))
						or (in_1(i)			and not(in_2(i))	and control(2))
						or (in_1(i)			and in_2(i)			and control(3));
	end generate;

end Behavioral;

