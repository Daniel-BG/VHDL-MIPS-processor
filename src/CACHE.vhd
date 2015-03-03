----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel B�scones Garcia
--		-David Pe�as G�mez
--		-��igo Zunzunegui Monterrubio
-- 
--	CACHE.vhd:

-- memoria CACHE de n bits por palabra comunicada con bus de tama�o 4*n con la RAM
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;



entity CACHE is
	generic (
		ADDR_WIDTH: integer := 10;
		DATA_WIDTH: integer := 32
	);
	port(
		--comunicaci�n con procesador
		p_data_in:	in std_logic_vector(DATA_WIDTH-1 downto 0);
		p_data_out: out std_logic_vector(DATA_WIDTH-1 downto 0);
		p_addr_in:	in std_logic_vector(ADDR_WIDTH-1 downto 0);
		--comunicaci�n con memoria
		m_data_in:	in std_logic_vector(DATA_WIDTH*4-1 downto 0);
		m_data_out:	out std_logic_vector(DATA_WIDTH*4-1 downto 0);
		m_addr_out:	out std_logic_vector(ADDR_WIDTH-3 downto 0);
		--se�ales de control
		clk, writeEnable, readEnable:	in std_logic;
		dataReady, requestSave: out std_logic;
		--datos extra para el display
		blocks_addr_out: out addr_table;
		flags_out: out std_logic_vector(7 downto 0);
		mem_state: out std_logic_vector(3 downto 0);
		hits_out,fails_out: out std_logic_vector(15 downto 0)
	);
end CACHE;

architecture Behavioral of CACHE is

	-- tipo registros que es array de 32 posiciones tama�o palabra
	type data_array is array (0 to 31) of std_logic_vector(DATA_WIDTH-1 downto 0); 
	-- se�al intermedia para almacenar contenidos
	signal contents: data_array := (others => (others => '0')); 
	
	-- se�al que guarda qu� bloques hay en memoria cache
	signal blocks: addr_table := (others => (others => '0'));
	-- se�ales auxiliares para escribir menos abajo
	signal in_block: std_logic_vector(2 downto 0);
	signal in_rel_addr: std_logic_vector(4 downto 0);
	
	-- se�al para saber si los bloques en cach� han sido modificados (y por ende
	-- deber�an ser mandados a memoria antes de traer unos nuevos)
	signal flags: std_logic_vector(7 downto 0) := (others => '0');
	
	-- se�al para indicar si hace falta guardar datos
	signal matchPlace: std_logic_vector(7 downto 0) := (others => '0');
	signal matchBlock: std_logic_vector(7 downto 0) := (others => '0');
	signal b_not_ready: std_logic_vector(7 downto 0) := (others => '0');
	signal blocks_ready: std_logic;
	
	-- se�al que guarda las direcciones de la cache de las 4 palabras que forman el bloque de la 
	-- direcci�n actual
	type cache_block_addr is array(0 to 3) of std_logic_vector(4 downto 0);
	signal cblock_addr: cache_block_addr;
	
	-- estados de la memoria
	--	idle: estado de reposo. la cache es capaz de trabajar en tiempo de un ciclo para bloques que tenga
	-- save: guardado de bloque. se manda a la RAM un bloque modificado
	-- fetch: petici�n de bloque a la RAM.
	-- update: actualizaci�n del bloque de la cache con el que devueve la RAM
	type state is (idle,save,fetch,update);
	signal current_state, next_state: state := idle;
	-- FORMATO: Cinco BITS que indican el BLOQUE de memoria, TRES fijos que son los que indican
	-- la posici�n de la cache donde debe ir, y los DOS �ltimos se ignoran ya que al ir de cuatro
	-- en cuatro sabemos que siempre est�n todos
	-- BBBBB PPP XX
	
	
	signal hits: std_logic_vector(15 downto 0):= (others => '0');
	signal fails: std_logic_vector(15 downto 0):= (others => '0');
begin

	assert ADDR_WIDTH > 5
		report "Cache innecesaria para ese ancho de direcciones. H�gala m�s grande o utilice un m�dulo m�s eficiente" 
			severity failure;


	

----------------------
--SE�ALES INTERMEDIAS
	need_for_save: 
		for i in 0 to 7 generate
			matchPlace(i)	<= '1' when p_addr_in(4 downto 2) = conv_std_logic_vector(i,3) else '0';		
			matchBlock(i)	<= '1' when blocks(i) = p_addr_in(ADDR_WIDTH-1 downto 5) else '0';
			--necesitamos escribir a memoria cuando estamos en un bloque de cuatro pero NO es el nuestro
			--solo habr� un bloque que no est� listo, precisamente en el que nos tocar�a escribir
			b_not_ready(i)	<= matchPlace(i) and not(matchBlock(i));
		end generate;

	gen_curr_block:
		for i in 0 to 3 generate
			cblock_addr(i) <= p_addr_in(4 downto 2) & conv_std_logic_vector(i,2);
		end generate;
	
	in_block		<= p_addr_in(4 downto 2);
	in_rel_addr	<= p_addr_in(4 downto 0);
	
	--debug
	mem_state(0)<= '1' when current_state = idle else '0';
	mem_state(1)<= '1' when current_state = save else '0';
	mem_state(2)<= '1' when current_state = fetch else '0';
	mem_state(3)<= '1' when current_state = update else '0';
----------------------

----------------------
--SALIDAS COMBINACIONALES
	-- el dato para memoria siempre est� disponible
	m_data_out	<=		contents(to_integer(ieee.numeric_std.unsigned(cblock_addr(0))))
						&	contents(to_integer(ieee.numeric_std.unsigned(cblock_addr(1))))
						&	contents(to_integer(ieee.numeric_std.unsigned(cblock_addr(2))))
						&	contents(to_integer(ieee.numeric_std.unsigned(cblock_addr(3))));
						
	-- direcci�n para la RAM donde queremos escribir o leer
	m_addr_out	<=	blocks(to_integer(ieee.numeric_std.unsigned(in_block))) & in_block
							when current_state = save
							else p_addr_in(ADDR_WIDTH-1 downto 2);
						
	-- el dato para el procesador siempre esta disponible
	p_data_out	<= contents(to_integer(ieee.numeric_std.unsigned(in_rel_addr)));
	
	-- los bloques est�n listos para lectura/escritura
	blocks_ready<= '1'	when b_not_ready = conv_std_logic_vector(0,8)
								else '0';
	
	-- el dato est� listo si no hiciera falta guardar (es decir, la direcci�n accedida se encuentra en memoria)
	dataReady	<= '1' when current_state = idle and next_state = idle and blocks_ready = '1' else '0';

								
	-- necesitamos guardar si estamos guardando (duh) b_not_ready No es cero
	requestSave <= '1'	when	current_state = save 
								else '0';
----------------------


----------------------
--ACTUALIZACI�N DE CACHE
	update_cache: process (current_state,clk,writeEnable,b_not_ready)
		begin
			if rising_edge(clk) then
				--caso de que traemos un bloque de memoria
				if current_state = update then 
					--actualizamos el bloque entero
					contents(to_integer(ieee.numeric_std.unsigned(cblock_addr(0)))) <= m_data_in(127 downto 96);
					contents(to_integer(ieee.numeric_std.unsigned(cblock_addr(1)))) <= m_data_in(95 downto 64);
					contents(to_integer(ieee.numeric_std.unsigned(cblock_addr(2)))) <= m_data_in(63 downto 32);
					contents(to_integer(ieee.numeric_std.unsigned(cblock_addr(3)))) <= m_data_in(31 downto 0);
					--y actualizamos la direcci�n donde est� el bloque
					blocks(to_integer(ieee.numeric_std.unsigned(in_block)))	<= p_addr_in(ADDR_WIDTH-1 downto 5);
					--y ponemos los flags a cero
					flags(to_integer(ieee.numeric_std.unsigned(in_block)))	<= '0';
				--caso de que escribimos desde el procesador
				elsif current_state = idle and writeEnable = '1' and blocks_ready = '1' then
					contents(to_integer(ieee.numeric_std.unsigned(in_rel_addr)))	<= p_data_in;
					flags(to_integer(ieee.numeric_std.unsigned(in_block)))		<= '1';
				end if;
				
				--ha acertado y actualizamos consecuentemente el contador
				if current_state = idle and (writeEnable = '1' or readEnable = '1') and blocks_ready = '1' then
				--resultado <= std_logic_vector(signed(in_1) + signed(in_2));
					hits <= std_logic_vector(unsigned(hits) + 1);
				end if;
				if current_state = update then
					fails <= std_logic_vector(unsigned(fails) + 1);
				end if;
			end if;
		end process;
----------------------


----------------------
--CONTROL DE ESTADO DE LA MEMORIA
	update_state: process(clk)
		begin
			if rising_edge(clk) then
				current_state <= next_state;
			end if;
		end process;
	
	prepare_next_state: process(current_state, writeEnable, readEnable,blocks_ready)
		begin
			case current_state is
				when idle	=>	if (writeEnable = '1' or readEnable = '1') and not(blocks_ready = '1') then
										--si no tenemos el bloque, 
										if flags(to_integer(ieee.numeric_std.unsigned(in_block))) = '1' then
											--o bien guardamos el actual si ha sido modificado
											next_state <= save;
										else
											--o directamente pasamos a pillar el que queremos
											next_state <= fetch;
										end if;
									else
										next_state <= idle;
									end if;
				when save	=> next_state <= fetch;
				when fetch	=> next_state <= update;
				when update =>	next_state <= idle;
			end case;
		end process;
----------------------
		
----------------------
--EXTRAS DE DATOS PARA PANTALLA
	blocks_addr_out <= blocks;
	flags_out <= flags;
	hits_out <= hits;
	fails_out <= fails;
----------------------


end Behavioral;




