----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel B�scones Garcia
--		-David Pe�as G�mez
--		-��igo Zunzunegui Monterrubio
-- 
--	divprod.vhd:

-- multiplicador 32x32. Salen hi y lo con los 32 bits m�s y menos significativos 
-- respectivamente del resultado de 64 bits
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


entity multiplicador is
    Port ( in_1 : in  std_logic_vector (31 downto 0);
           in_2 : in  std_logic_vector (31 downto 0);
           high : out  std_logic_vector (31 downto 0); --parte m�s significativa de la multiplicaci�n, o resto
           low : out  std_logic_vector (31 downto 0)); --parte menos significactiva de la multiplicaci�n, o cociente
end multiplicador;

architecture Behavioral of multiplicador is
	signal producto: std_logic_vector (63 downto 0);
begin
	--process para cacular los resultados de divisi�n y multiplicaci�n en cuanto cambien las entradas
	operar: process(in_1,in_2)
	begin
		producto <= in_1 * in_2;
	end process operar;
	
	--process para asignar los resultados a la salida en funci�n de si hacemos divisi�n o mltiplicaci�n;
	asignar: process(producto)
	begin
		high <= producto(63 downto 32);
		low <= producto(31 downto 0);
	end process asignar;

end Behavioral;

