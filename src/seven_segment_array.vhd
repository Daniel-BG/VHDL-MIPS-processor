----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	seven_segment_array.vhd:

-- Array de 7 segmentos genérico colocable en cualquier lugar de la pantalla.
-- altura, anchura, separación entre segmentos configurable.
-- recibe array de bits (7xnumero segmentos) que indican, 7 a 7, los segmentos
-- de cada display individual. De izquierda a derecha en el sentido de las agujas
-- del reloj empezando por arriba.
--
--	EJEMPLO: Con 2 segmentos, (7x2=14 bits), al enviar
--	"11101111111110" veremos escrito "AO" (los 7 primeros son la A y los 7 segundos
-- la O. 

-- Referirse a seven_segment.vhd para más información
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;



entity seven_segment_array is
	generic (
		--esquina superior izquierda del componente
		X: integer := 0;
		Y: integer := 0;
		--número de 7 segmentos que hay
		N: integer := 1;
		--altura y anchura. (la altura final será 2*HEIGHT+1
		HEIGHT: integer := 3;
		WIDTH: integer := 6;
		--espacio entre 7 segmentos
		GAP: integer := 1
	);
	port (
		--coordenada actual en pantalla
		cX, cY: std_logic_vector(8 downto 0);
		--bits para los 7 segmentos
		bits: in std_logic_vector(N*7-1 downto 0);
		--si se debe pintar o no el componente
		enabled: out std_logic
	);
end seven_segment_array;

architecture Behavioral of seven_segment_array is

	--Señal que contiene un bit por cada siete segmentos para indicar si está encendido cada uno
	signal segment_enabled: std_logic_vector(N-1 downto 0);

begin
	--Generate de los N segmentos
	gen_7_seg: for i in 0 to N-1 generate
		u: entity work.seven_segment 	
			generic map(X+(WIDTH+GAP)*i,Y,HEIGHT,WIDTH)
			port map(cX,cY,bits((7*(N-i)-1) downto (7*(N-1-i))),segment_enabled(i));
	end generate gen_7_seg;

	--OR entre los enable de todos los componentes
	enable_out: process(segment_enabled)
	begin
		if segment_enabled = conv_std_logic_vector(0,N) then
			enabled <= '0';
		else
			enabled <= '1';
		end if;
	end process;

end Behavioral;

