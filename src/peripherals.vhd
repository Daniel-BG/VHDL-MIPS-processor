----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel B�scones Garcia
--		-David Pe�as G�mez
--		-��igo Zunzunegui Monterrubio
-- 
--	peripherals.vhd:

-- interfaz para la conexi�n de perif�ricos con el procesador. recibe tanto datos
-- como comandos para un perif�rico dado por otro �ndice de entrada. mediante 
-- enable se indica si se quiere interactuar o no con cada perif�rico conectado
-- (si bien es �ste y no el controlador qui�n toma la decisi�n).
-- Los comandos afectan s�lo al perif�rico seleccionado y dependen de su
-- implementaci�n.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.tipos.all;


entity peripherals is
	generic (
		ADDW: integer := 2;	--anchura de las direcciones de los perif�ricos (log_2(PERN))
		PCW: integer := 10
	);
	port (
		peridata_in: in std_logic_vector(15 downto 0);		--dato de entrada para el perif�rico seleccionado
		pericommand: in std_logic_vector(PCW-1 downto 0);	--anchura de los comandos (cambiar� seg�n los perif�ricos que se usen)
		perinumber: in std_logic_vector(ADDW-1 downto 0);	--n�mero de perif�rico sobre el que se interact�a
		peridata_out: out std_logic_vector(31 downto 0);	--dato de salida del perif�rico seleccionado
		clk,enable: in std_logic;									--reloj general y enable del perif�rico en uso
																			--enable 1 si se hace algo, 0 si no se hace nada
		-- adquiridas de los perif�ricos
		ps2clk, ps2data: in std_logic;
		cX,cY: in std_logic_vector(8 downto 0);
		screenclk: in std_logic;
		rgb_enable: out std_logic;
		rgb_out: out std_logic_vector(8 downto 0)
	);
end peripherals;

architecture Behavioral of peripherals is

	constant PERN: integer := 4;	--n�mero de perif�ricos conectados
	constant UPERNE: integer := 4;--n�mero de perif�ricos que necesitan enable
	

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
	
	-- perif�ricos que necesitan enable
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
	-- perif�ricos que NO necesitan enable (poner SIEMPRE despu�s de los que si 
	-- necesitan enable (en outputs (i) tambi�n deben ir despu�s). Y poner UPERNE al valor adecuado

	
	-- ((ANTIGUO)) keyboard: keyboardperipheral port map (ps2data, ps2clk, outputs(2), clk, enabled(2));


	-- salida del perif�rico seleccionado
	perindex <= to_integer(ieee.numeric_std.unsigned(perinumber));
	peridata_out <= outputs(perindex);

end Behavioral;

