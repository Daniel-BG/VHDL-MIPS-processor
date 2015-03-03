----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	seven_segment.vhd:

-- 7 segmentos genérico para altura y anchura. El tamaño de cada segmento será
-- dependiente de éstos pero siempre de 1 de ancho (o alto) si está orientado
-- horizontal o verticalmente respectivamente.
-- Recibe 7 bits para los segmentos, con la configuración "6543210", correspondiendo
-- éstos de la siguiente manera:
--
-- X6666X
-- 1XXXX5
-- 1XXXX5
-- X0000X
-- 2XXXX4
-- 2XXXX4
-- X3333X
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;




entity seven_segment is
	generic (
		--coordenadas en pantalla del componente (esquina superior izquierda)
		X: integer := 0;
		Y: integer := 0;
		--la altura final será HEIGHT*2+1
		HEIGHT: integer := 3;
		--anchura del componente
		WIDTH: integer := 6
	);
	port (
		--posición actual del barrido de la pantalla
		cX, cY: std_logic_vector(8 downto 0);
		--bits de entrada al 7 segmentos
		bits: in std_logic_vector(6 downto 0);
		--salida que indica si se debe pintar o no el componente dependiendo de cX y cY
		enabled: out std_logic
	);
end seven_segment;

architecture Behavioral of seven_segment is
begin
	enableoutput: process(cX,cY,bits)
	begin
		if cX > X and cX < X+WIDTH-1 then									--SEGMENTOS HORIZONTALES
			if cY = Y and bits(6) = '1' then									--superior
				enabled <= '1';
			elsif cY = Y+HEIGHT and bits(0) = '1' then					--central
				enabled <= '1';
			elsif cY = Y+2*HEIGHT and bits(3) = '1' then					--inferior
				enabled <= '1';
			else
				enabled <= '0';
			end if;
		elsif cX = X then															--SEGMENTOS VERTICALES IZDA
			if cY > Y and cY < Y+HEIGHT and bits(1) = '1' then			--izda superior
				enabled <= '1';
			elsif cY > Y+HEIGHT and cY < Y+2*HEIGHT and bits(2) = '1' then	--izda inferior
				enabled <= '1';
			else
				enabled <= '0';
			end if;
		elsif cX = X+WIDTH-1	then												--SEGMENTOS VERTICALES DCHA
			if cY > Y and cY < Y+HEIGHT and bits(5) = '1' then			--dcha superior
				enabled <= '1';
			elsif cY > Y+HEIGHT and cY < Y+2*HEIGHT and bits(4) = '1' then	--dcha inferior
				enabled <= '1';
			else
				enabled <= '0';
			end if;
		else
			enabled <= '0';
		end if;
	end process;
end Behavioral;

