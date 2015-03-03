----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	peripherals.vhd:

-- interfaz para la conexión de periféricos con el procesador. recibe tanto datos
-- como comandos para un periférico dado por otro índice de entrada. mediante 
-- enable se indica si se quiere interactuar o no con cada periférico conectado
-- (si bien es éste y no el controlador quién toma la decisión).
-- Los comandos afectan sólo al periférico seleccionado y dependen de su
-- implementación.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.tipos.all;


entity peripherals is
	generic (
		ADDW: integer := 2;	--anchura de las direcciones de los periféricos (log_2(PERN))
		PCW: integer := 10
	);
	port (
		peridata_in: in std_logic_vector(15 downto 0);		--dato de entrada para el periférico seleccionado
		pericommand: in std_logic_vector(PCW-1 downto 0);	--anchura de los comandos (cambiará según los periféricos que se usen)
		perinumber: in std_logic_vector(ADDW-1 downto 0);	--número de periférico sobre el que se interactúa
		peridata_out: out std_logic_vector(31 downto 0);	--dato de salida del periférico seleccionado
		clk,enable: in std_logic;									--reloj general y enable del periférico en uso
																			--enable 1 si se hace algo, 0 si no se hace nada
		-- adquiridas de los periféricos
		ps2clk, ps2data: in std_logic;
		cX,cY: in std_logic_vector(8 downto 0);
		screenclk: in std_logic;
		rgb_enable: out std_logic;
		rgb_out: out std_logic_vector(8 downto 0)
	);
end peripherals;

architecture Behavioral of peripherals is

	constant PERN: integer := 4;	--número de periféricos conectados
	constant UPERNE: integer := 4;--número de periféricos que necesitan enable
	

	type outputarray is array(0 to PERN-1) of std_logic_vector(31 downto 0);
	signal outputs: outputarray;
	
	signal perindex: integer range 0 to PERN-1;
	

	
	signal enabled: std_logic_vector(UPERNE-1 downto 0);
	
	
	signal ascii_code_new: std_logic;
	signal ascii_code: std_logic_vector(6 downto 0);
	
	
begin
	
	gen_enabled: for i in 0 to UPERNE-1 generate
		enabled(i) <= '1' when 
								perinumber = std_logic_vector(to_unsigned(i,ADDW)) and 
								enable = '1' 
							else '0';
	end generate gen_enabled;
	
	-- periféricos que necesitan enable
	rng: entity work.rngperipheral 
		port map (peridata_in, pericommand(0),outputs(0),clk,enabled(0));
	timer: entity work.timerperipheral 
		port map (pericommand(0),outputs(1), clk, enabled(1));
	--screenbuffer: ss_buffer port map (peridata_in, pericommand(4 downto 0), outputs(2), clk, enabled(2),ss_data);
	screenbuffer: entity work.GPU 
		generic map (194, 230,9) 
		port map(cX,cY,pericommand(9 downto 5),pericommand(4 downto 0),
			peridata_in(8 downto 0),enabled(2),
			screenclk,rgb_out,rgb_enable);
	outputs(2) <= "00000000000000000000000000000000";
	keyboard: entity work.ps2_keyboard_to_ascii 
		generic map(781250,2) 
		port map (clk,ps2clk,ps2data,ascii_code_new,ascii_code,enabled(3));
	outputs(3) <= "000000000000000000000000" & ascii_code_new & ascii_code;
	-- periféricos que NO necesitan enable (poner SIEMPRE después de los que si 
	-- necesitan enable (en outputs (i) también deben ir después). Y poner UPERNE al valor adecuado

	
	-- ((ANTIGUO)) keyboard: keyboardperipheral port map (ps2data, ps2clk, outputs(2), clk, enabled(2));


	-- salida del periférico seleccionado
	perindex <= to_integer(ieee.numeric_std.unsigned(perinumber));
	peridata_out <= outputs(perindex);

end Behavioral;

