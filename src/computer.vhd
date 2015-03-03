----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	computer.vhd:

-- Módulo general que une el procesador con los periféricos, para poder visualizar
-- su funcionamiento en la FPGA
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;

--números de los bloques guardados
--flags de los bloques guardados

--ENTITY
entity computer is
	generic (
		ROM_WIDTH:		integer := 8;	--anchura de direcciones de la ROM
		PER_COM_WID:	integer := 10;	--anchura de comando para periférico
		PER_ADD_WID:	integer := 2;	--anchura de dirección de periférico
		CLOCK_DIV:		integer := 7;	--el reloj irá a 100MHZ/2^CLOCK_DIV. 7 es el mínimo teórico
		romfile : string := "spaceship.data" --ROM_WIDTH debe ser igual a 2^(numero lineas) del archivo
	);
	port
	(
		reset: in std_logic;
		clk: in std_logic;
		hsyncb: inout std_logic;
		vsyncb: out std_logic;
		rgb: out std_logic_vector(8 downto 0);
		ps2clk, ps2data: in std_logic
	);
end computer;

architecture Behavioral of computer is

	--Señales que interconectan los componentes
	signal ban_addr: std_logic_vector(4 downto 0);
	signal mem_in, ban_in, alu_in1, alu_in2, alu_out: std_logic_vector(31 downto 0);
	signal pc_in, pc_out: std_logic_vector(15 downto 0);
	--signal banco_reg: std_logic_vector(1023 downto 0);
	signal banco_reg_p: registros;
	signal blocks: std_logic_vector(39 downto 0);
	signal blocks_p: addr_table;
	signal flags: std_logic_vector(7 downto 0);
	signal mem_state: std_logic_Vector(3 downto 0);
	signal hits,fails: std_logic_vector(15 downto 0);
	--reloj secundario que controla la frecuencia del procesador
	signal clock: std_logic;
	signal contador: std_logic_vector(CLOCK_DIV-1 downto 0);
	--periféricos
	signal peridata_out:	std_logic_vector(15 downto 0);
	signal pericommand:	std_logic_vector(PER_COM_WID-1 downto 0);
	signal perinumber:	std_logic_vector(PER_ADD_WID-1 downto 0);
	signal peridata_in:	std_logic_vector(31 downto 0);
	signal perEnable:		std_logic;
	signal cX,cY,rgb_gpu: std_logic_vector(8 downto 0);
	signal rgb_enable: std_logic;

begin
	--Conversión de array 32x32 a array 1024x1
	--translate_reg:
	--	for i in 0 to 31 generate
	--		banco_reg(((32-i)*32-1) downto ((31-i)*32)) <= banco_reg_p(i);
	--	end generate;
	--conversión de array 5x8 a 40x1
	translate_blocks:
		for i in 0 to 7 generate
			blocks((5*(i+1)-1) downto (5*i)) <= blocks_p(7-i);
		end generate;
	--reductor de frecuencia para ver el funcionamiento del procesador en tiempo aceptable
	divisor: process(clk, contador, reset)
		begin
			if reset = '1' then
				contador <= (others => '0');
			elsif rising_edge(clk) then
				contador <= contador + 1;
			end if;
		end process;
	
	--reloj del procesador = 100.000.000/2^(X+1) siendo X el numero entre paréntesis	
	--para que funcione el controlador de teclado: 100.000.000/128 => x=6 ~1MHZ
	clock <= contador(CLOCK_DIV-1); 
	
	--processorclock: process(contador, pause)
	--	begin
	--		if pause = '1' and contador(24) = '0' then 
				--añadimos el and con contador para que sólo pause al estar en el cero, en
				--cuyo caso clock no fluctuará entre 0 y 1 ininterrumpidamente (en teoría, claro)
	--			clock <= '0';
	--		else
	--			clock <= contador(24);
	--		end if;
	--	end process;
	
	--Puenteo de componentes
	controlador_pantalla: entity work.vgacore 
		port map(reset,contador(2),hsyncb,vsyncb,rgb,
					ban_addr,mem_in,ban_in,alu_in1,alu_in2,alu_out,
					pc_in,pc_out,banco_reg_p,
					blocks,flags,mem_state,
					hits,fails,
					cX,cY,
					rgb_enable,rgb_gpu);

	microchip: entity work.processor 
		generic map
				  (ROM_WIDTH, PER_COM_WID, PER_ADD_WID,romfile)
		port map(clock,reset,
					mem_in,alu_out,alu_in1,ban_in,alu_in2,
					banco_reg_p,
					ban_addr,
					pc_in,pc_out,
					peridata_out,pericommand,perinumber,peridata_in,perEnable,
					blocks_p,flags,mem_state,
					hits,fails);

	perifericos: entity work.peripherals
		generic map
				  (PER_ADD_WID,PER_COM_WID)
		port map(peridata_out,
					pericommand,
					perinumber,
					peridata_in,
					clock,perEnable,
					ps2clk, ps2data,
					cX,cY,
					contador(2),
					rgb_enable,rgb_gpu);

end Behavioral;

