----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
-- screen.vhd:

-- pantalla de 32x32 colocable en cualquier sitio de la pantalla. 
-- los pixeles son de 2x4 con huecos de igual tamaño entre medias
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;



entity screen is
	generic	(
					X: integer := 0;			--posición esquina superior izquierda (X)
					Y: integer := 0			--posición esquina superior izquierda (Y)
				);
	port		(
					--bits que deciden si se encenderan o no las salidas. La matriz empieza en la esquina
					--superior izquierda (bit mas significativo) y se mueve hacia la derecha y abajo, en ese orden
					bits: in registros; 
					--coordenadas actuales de la pantalla
					cX,cY: in std_logic_vector(8 downto 0);
					--enabled_on = 1 cuando la coordenada actual esté dentro de un pixel y el bit de ese pixel sea 1
					--enabled_off = 1 en el mismo caso, pero con pixel = 0
					--cuando la coordenada actual no coincide con la de ningún pixel, ambas valen cero
					enabled_on, enabled_off: out std_logic
				);
end screen;

architecture Behavioral of screen is
	--anchura de pixel:2
	--altura de pixel:4
	--separacion horizontal:2
	--separacion vertical:4
	signal relativex: std_logic_vector(7 downto 0);
	signal relativey: std_logic_vector(6 downto 0);
	signal xcoord, ycoord: std_logic_vector(5 downto 0);
	signal overX, overY: std_logic;
	signal inspace: std_logic;
	
	signal posen_on, posen_off: std_logic;
	
begin

	relativex <= std_logic_vector(unsigned(cX(8 downto 1)) - unsigned(conv_std_logic_vector(X/2,8)));
	relativey <= std_logic_vector(unsigned(cY(8 downto 2)) - unsigned(conv_std_logic_vector(Y/4,7)));
	xcoord <= relativex(5 downto 0);
	ycoord <= relativey(5 downto 0);
	--eliminación de warnings con esta señal
	
	inspace <= '1' when xcoord(0) = '1' or ycoord(0) = '1' else '0';
	overX <= '1' when to_integer(unsigned(cX)) < X or not (relativex(7 downto 6) = "00") else '0';
	overY <= '1' when to_integer(unsigned(cY)) < Y or relativey(6) = '1' else '0';
	
	posen_on <= '1' when 
		--bits(to_integer(unsigned(xcoord(5 downto 1))))(to_integer(unsigned(ycoord(5 downto 1)))) = '1'
		bits(to_integer(unsigned(ycoord(5 downto 1))))(31-to_integer(unsigned(xcoord(5 downto 1)))) = '1'
		else '0';
	posen_off <= '1' when posen_on = '0' else '0';
	
	update_output: process(posen_on, posen_off, inspace, overX,overY) 
	begin
		if (inspace = '1' or overX = '1' or overY = '1') then
			enabled_on <= '0';
			enabled_off <= '0';
		else
			enabled_on <= posen_on;
			enabled_off <= posen_off;
		end if;
	end process;
	
end Behavioral;

