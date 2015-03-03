----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	vga.vhd:

-- Controlador de pantalla VGA para la FPGA
-- Originalmente proporcionados en las prácticas de TOC por Marcos Sánchez
-- Modificado a medida para el proyecto
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;

entity vgacore is
	port
	(
		reset: in std_logic;	
		clock: in std_logic;
		hsyncb: inout std_logic;	
		vsyncb: out std_logic;	
		rgb: out std_logic_vector(8 downto 0); 
		ban_addr: in std_logic_vector(4 downto 0);
		mem_in, ban_in, alu_in1, alu_in2, alu_out: in std_logic_vector(31 downto 0);
		pc_in, pc_out: in std_logic_vector(15 downto 0);
		banco_registros: in registros;
		blocks_addr_in: in std_logic_vector(39 downto 0);
		flags_in: in std_logic_vector(7 downto 0);
		mem_state: in std_logic_vector(3 downto 0);
		hits_in,fails_in: in std_logic_vector(15 downto 0);
		cX,cY: out std_logic_vector(8 downto 0);
		rgb_enable: in std_logic;
		rgb_in: in std_logic_vector(8 downto 0)
	);
end vgacore;

architecture vgacore_arch of vgacore is



	signal hcnt: std_logic_vector(8 downto 0);	-- horizontal pixel counter
	signal vcnt: std_logic_vector(9 downto 0);	-- vertical line counter
	--vectores de pintado de cada objeto. Cada vector corresponde a un color diferente
	signal sso_vec: std_logic_vector(11 downto 0):= (others => '0');
	signal ssc1_vec,ssc2_vec: std_logic_vector(12 downto 0):= (others => '0');
	--señales OR de los vectores de arriba
	signal sso,ssc1,ssc2,ssc3,sscred,sscgreen: std_logic;

	constant xPos: integer := 30;
	constant yPos: integer := 30;
	
	function reverse_vector (a: in std_logic_vector) return std_logic_vector is
		variable result: std_logic_vector(a'RANGE);
		alias aa: std_logic_vector(a'REVERSE_RANGE) is a;
	begin
		for i in aa'RANGE loop
			result(i) := aa(i);
		end loop;
		return result;
	end;

begin
	A: process(clock,reset)
	begin
		-- reset asynchronously clears pixel counter
		if reset='1' then
			hcnt <= "000000000";
		-- horiz. pixel counter increments on rising edge of dot clock
		elsif (clock'event and clock='1') then
			-- horiz. pixel counter rolls-over after 381 pixels
			if hcnt<380 then
				hcnt <= hcnt + 1;
			else
				hcnt <= "000000000";
			end if;
		end if;
	end process;

	B: process(hsyncb,reset)
	begin
		-- reset asynchronously clears line counter
		if reset='1' then
			vcnt <= "0000000000";
		-- vert. line counter increments after every horiz. line
		elsif (hsyncb'event and hsyncb='1') then
			-- vert. line counter rolls-over after 528 lines
			if vcnt<527 then
				vcnt <= vcnt + 1;
			else
				vcnt <= "0000000000";
			end if;
		end if;
	end process;

	C: process(clock,reset)
	begin
		-- reset asynchronously sets horizontal sync to inactive
		if reset='1' then
			hsyncb <= '1';
		-- horizontal sync is recomputed on the rising edge of every dot clock
		elsif (clock'event and clock='1') then
			-- horiz. sync is low in this interval to signal start of a new line
			if (hcnt>=291 and hcnt<337) then
				hsyncb <= '0';
			else
				hsyncb <= '1';
			end if;
		end if;
	end process;

	D: process(hsyncb,reset)
	begin
		-- reset asynchronously sets vertical sync to inactive
		if reset='1' then
			vsyncb <= '1';
		-- vertical sync is recomputed at the end of every line of pixels
		elsif (hsyncb'event and hsyncb='1') then
			-- vert. sync is low in this interval to signal start of a new frame
			if (vcnt>=490 and vcnt<492) then
				vsyncb <= '0';
			else
				vsyncb <= '1';
			end if;
		end if;
	end process;


	--CABLEADO DE COMPONENTES EN PANTALLA


	--Salida de la memoria de instrucciones
	mem_i_tag: entity work.seven_segment_array 	
		generic map(xPos,yPos,3,3,5,2)
		port map(hcnt,vcnt(8 downto 0),"011000011101101011011",sso_vec(0));
	mem_instruc: entity work.bit_led_array 		
		generic map(xPos+30,yPos,6,3,32,2)
		port map(mem_in,hcnt,vcnt(8 downto 0),ssc1_vec(0),ssc2_vec(0));
		
	--Entrada al banco de registros	
	br_i_tag: entity work.seven_segment_array 	
		generic map(xPos,yPos+10,3,3,5,2)
		port map(hcnt,vcnt(8 downto 0),"001111110001101111011",sso_vec(1));
	br_input: entity work.bit_led_array 			
		generic map(xPos+30,yPos+10,6,3,32,2)
		port map(ban_in,hcnt,vcnt(8 downto 0),ssc1_vec(1),ssc2_vec(1));
	--Dirección de escritura del banco de registros									
	br_d_tag: entity work.seven_segment_array 	
		generic map(xPos,yPos+20,3,3,5,2)
		port map(hcnt,vcnt(8 downto 0),"111011101111010111101",sso_vec(2));
	br_d_input: entity work.bit_led_array 			
		generic map(xPos+30,yPos+20,6,3,5,2)
		port map(ban_addr,hcnt,vcnt(8 downto 0),ssc1_vec(2),ssc2_vec(2));
			
	--Entrada #1 de la ALU		
	alu_i1_tag: entity work.seven_segment_array 
		generic map(xPos,yPos+35,3,3,5,2)
		port map(hcnt,vcnt(8 downto 0),"111011100011100110000",sso_vec(3));
	alu_i_1: entity work.bit_led_array 				
		generic map(xPos+30,yPos+35,6,3,32,2)
		port map(alu_in1,hcnt,vcnt(8 downto 0),ssc1_vec(3),ssc2_vec(3));		
	--Entrada #2 de la ALU
	alu_i2_tag: entity work.seven_segment_array 	
		generic map(xPos,yPos+45,3,3,5,2)
		port map(hcnt,vcnt(8 downto 0),"111011100011101101101",sso_vec(4));
	alu_i_2: entity work.bit_led_array 				
		generic map(xPos+30,yPos+45,6,3,32,2)
		port map(alu_in2,hcnt,vcnt(8 downto 0),ssc1_vec(4),ssc2_vec(4));	
	--Salida de la ALU
	alu_o_tag: entity work.seven_segment_array 	
		generic map(xPos,yPos+55,3,3,5,2)
		port map(hcnt,vcnt(8 downto 0),"111011100011101111110",sso_vec(5));
	alu_o: entity work.bit_led_array 				
		generic map(xPos+30,yPos+55,6,3,32,2)
		port map(alu_out,hcnt,vcnt(8 downto 0),ssc1_vec(5),ssc2_vec(5));	

	--Entrada al PC (PC siguiente)
	pc_i_tag: entity work.seven_segment_array 	
		generic map(xPos,yPos+70,3,3,5,2)
		port map(hcnt,vcnt(8 downto 0),"110011110011100110000",sso_vec(6));
	pc_i: entity work.bit_led_array 					
		generic map(xPos+30,yPos+70,6,3,16,2)
		port map(pc_in,hcnt,vcnt(8 downto 0),ssc1_vec(6),ssc2_vec(6));	
	--Salida del PC (PC actual)
	pc_o_tag: entity work.seven_segment_array 	
		generic map(xPos,yPos+80,3,3,5,2)
		port map(hcnt,vcnt(8 downto 0),"110011110011101111110",sso_vec(7));
	pc_o: entity work.bit_led_array 					
		generic map(xPos+30,yPos+80,6,3,16,2)
		port map(pc_out,hcnt,vcnt(8 downto 0),ssc1_vec(7),ssc2_vec(7));												
				
	--Datos del banco de registros
	bitm: entity work.screen
		generic map(xPos+30,yPos+95)
		port map(banco_registros,hcnt,vcnt(8 downto 0),ssc1_vec(8),ssc2_vec(8));
	--Casillas en blanco cada 4 registros para separarlos
	bitmind: entity work.bit_led_array				
		generic map(xPos+24,yPos+95,4,2,8,28,false)
		port map("11111111",hcnt,vcnt(8 downto 0),sso_vec(8),sso_vec(9));
		
	--Relacionado con la cache
	flags: entity work.bit_led_array
		generic map(xpos+164,ypos+95,4,2,8,4,false)
		port map(reverse_vector(flags_in),hcnt,vcnt(8 downto 0), sscred, sscgreen);
	blocks: entity work.bit_led_matrix
		generic map(xpos+168,ypos+95,4,2,5,8,2,4)
		port map(blocks_addr_in,hcnt,vcnt(8 downto 0), ssc1_vec(9), ssc2_vec(9));
	states: entity work.bit_led_array
		generic map(xpos + 168, ypos + 170,4,2,4,2,true)
		port map(mem_state,hcnt,vcnt(8 downto 0), ssc1_vec(10),ssc2_vec(10));
	
	hits_tag: entity work.seven_segment_array 	
		generic map(xPos,yPos+360,3,3,5,2)
		port map(hcnt,vcnt(8 downto 0),"011011101100001000110",sso_vec(10));
	hits_display: entity work.bit_led_array 			
		generic map(xPos+30,yPos+360,6,3,16,2)
		port map(hits_in,hcnt,vcnt(8 downto 0),ssc1_vec(11),ssc2_vec(11));
	
	fails_tag: entity work.seven_segment_array 	
		generic map(xPos,yPos+370,3,3,5,2)
		port map(hcnt,vcnt(8 downto 0),"100011111101110110000",sso_vec(11));
	fails_display: entity work.bit_led_array 			
		generic map(xPos+30,yPos+370,6,3,16,2)
		port map(fails_in,hcnt,vcnt(8 downto 0),ssc1_vec(12),ssc2_vec(12));
		
									
	--Titulito de la pantalla								
	title: entity work.bit_led_fixed_display
		generic map (xPos,yPos-15,2,1,19,5,0,0,
						"10001010111110111111101101010001010000101010101111101111110001010100000000011000101010000011111")
		port map (hcnt,vcnt(8 downto 0),ssc3);

	--OR entre los vectores de componentes (que indican si están activos o no)
	--para pasarlo a depender de una sola señal
	enable_sso: process(sso_vec)
		begin
			if sso_vec = conv_std_logic_vector(0,12) then
				sso <= '0';
			else
				sso <= '1';
			end if;
		end process;
		
	enable_ssc1: process(ssc1_vec)
		begin
			if ssc1_vec = conv_std_logic_vector(0,13) then
				ssc1 <= '0';
			else
				ssc1 <= '1';
			end if;
		end process;
		
	enable_ssc2: process(ssc2_vec)
		begin
			if ssc2_vec = conv_std_logic_vector(0,13) then
				ssc2 <= '0';
			else
				ssc2 <= '1';
			end if;
		end process;


	--Selección de color para un píxel determinado
	colorear: process(hcnt, vcnt,sso,ssc1,ssc2,ssc3,sscred,sscgreen,rgb_enable,rgb_in)
	begin
		if rgb_enable = '1' then
			rgb<= rgb_in;
		elsif ssc3 = '1' then		--verde (título)
			rgb<="000111000";
		elsif sso = '1' then 		--blanco (letras)
			rgb<="111111111";
		elsif ssc1 = '1' then		--azul (bits con valor 1)
			rgb<="000000111";
		elsif ssc2 = '1' then		--amarillo (bits con valor cero)
			rgb<="111111000";
		elsif sscred = '1' then		--rojo (errores cache)
			rgb<="111000000";
		elsif sscgreen = '1' then	--verde (aciertos cache)
			rgb<="010111010";
		else								--negro (color de fondo cuando no hay nada activo)
			rgb<="000000000";
		end if;
	end process colorear;
	
	cX <= hcnt(8 downto 0);
	cY <= vcnt(8 downto 0);
	
	
end vgacore_arch;