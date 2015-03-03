----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	bit_led_matrix.vhd:

-- MATRIZ de NxM LEDS genérica situable en cualquier posición de la pantalla.
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;



entity bit_led_matrix is
	generic	(
					X: integer := 0;			--posición esquina superior izquierda (X)
					Y: integer := 0;			--posición esquina superior izquierda (Y)
					HEIGHT: integer := 4;	--altura de cada pixel de la matrix
					WIDTH: integer := 6;		--anchura de cada pixel
					N: integer := 8;			--numero de columnas
					M: integer := 8;			--numero de filas
					HGAP: integer := 2;		--espaciado entre columnas (pixeles en blanco)
					VGAP: integer := 4		--espaciado entre filas (pixeles en blanco)
				);
	port		(
					--bits que deciden si se encenderan o no las salidas. La matriz empieza en la esquina
					--superior izquierda (bit mas significativo) y se mueve hacia la derecha y abajo, en ese orden
					bits: in std_logic_vector(N*M-1 downto 0); 
					--coordenadas actuales de la pantalla
					cX,cY: in std_logic_vector(8 downto 0);
					--enabled_on = 1 cuando la coordenada actual esté dentro de un pixel y el bit de ese pixel sea 1
					--enabled_off = 1 en el mismo caso, pero con pixel = 0
					--cuando la coordenada actual no coincide con la de ningún pixel, ambas valen cero
					enabled_on, enabled_off: out std_logic
				);
end bit_led_matrix;

architecture Behavioral of bit_led_matrix is

	signal cuadrados_on, cuadrados_off: std_logic_vector(M-1 downto 0);



begin

	--generate de todas las celdas de la matriz
	gen_on_off: 
		for i in 0 to M-1 generate
			u: entity work.bit_led_array 	
									generic map	(X,Y+(HEIGHT+VGAP)*i,HEIGHT,WIDTH,N,HGAP)
									port map		(bits((N*(M-i)-1) downto (N*(M-1-i))),cX,cY,cuadrados_on(i),cuadrados_off(i));
		end generate gen_on_off;
		
	--OR entre todas las enable_on de los pixeles individuales
	enable_cuad_on: process(cuadrados_on)
		begin
			if cuadrados_on = conv_std_logic_vector(0,N) then
				enabled_on <= '0';
			else
				enabled_on <= '1';
			end if;
		end process;
		
	--OR entre todas las enable_off de los pixeles individuales
	enable_cuad_off: process(cuadrados_off)
		begin
			if cuadrados_off = conv_std_logic_vector(0,N) then
				enabled_off <= '0';
			else
				enabled_off <= '1';
			end if;
		end process;

end Behavioral;

