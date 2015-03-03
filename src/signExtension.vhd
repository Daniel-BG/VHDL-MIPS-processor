----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	signExtension.vhd:

-- extensor de signo genérico desde n hasta m bits
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity signExtension is
	generic (
		inputSize: integer := 16;
		outputSize: integer := 32
	);
   port( 
		entrada : in std_logic_vector (inputSize-1 downto 0);
		salida: out std_logic_vector (outputSize-1 downto 0)
   );
end signExtension;

architecture Behavioral of signExtension is

signal signExtended : std_logic_vector (outputSize-inputSize-1 downto 0);

begin

salida <= signExtended & entrada;  

rellena_extensionSigno : 
for i in 0 to outputSize-inputSize-1 generate	
	signExtended(i) <= entrada(inputSize-1);
end generate rellena_extensionSigno;
  
end Behavioral;

