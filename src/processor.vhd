----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	processor.vhd:

-- Procesador MIPS
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;


entity processor is
	generic (
		ROMW: integer := 6;	--anchura de dirección de ROM
		PCW:	integer := 1;	--anchura de comando para periférico
		PAW:	integer := 2;  --anchura de dirección de periférico
		romfile : string := "colors.data"
	);
	port(
		clk, reset: in std_logic;
		mem_in, alu_out, alu_in1, ban_in, alu_in2 : out std_logic_vector(31 downto 0);
      banco_registros : out registros;
		ban_addr : out std_logic_vector(4 downto 0);
		pc_in, pc_out: out std_logic_vector(15 downto 0);
		--periféricos
		peridata_out:	out std_logic_vector(15 downto 0);
		pericommand:	out std_logic_vector(PCW-1 downto 0);
		perinumber:		out std_logic_vector(PAW-1 downto 0);
		peridata_in:	in  std_logic_vector(31 downto 0);
		perEnable:		out std_logic;
		--datos extra para el display
		blocks_addr_out: out addr_table;
		flags_out: out std_logic_vector(7 downto 0);
		mem_state: out std_logic_vector(3 downto 0);
		hits_out,fails_out: out std_logic_vector(15 downto 0)
	);
end processor;

architecture Behavioral of processor is

	--DECLARACIÓN DE COMPONENTES QUE REDECLARAN BIBLIOTECAS

	component bancoRegistros is
		port(
			ra_address, rb_address, rw_address : in std_logic_vector (4 downto 0);
			bus_write : in std_logic_vector (31 downto 0);
			regWrite,clk : in std_logic;
			busA,busB : out std_logic_vector(31 downto 0);
			banco_registros : out registros
		);
	end component bancoRegistros;
	
	component completaceros is
		port(
			entrada : in std_logic_vector (4 downto 0);
			salida : out std_logic_vector (31 downto 0)
		);
	end component completaceros;
	


	--SEÑALES

	--ROM
	signal salida_rom: std_logic_vector (31 downto 0);
	--CONTROL
	signal regDst, ALUsrc, regInput: std_logic_vector (1 downto 0);
	signal regWrite, memWrite, memRead , memop, dataReady: std_logic;
	signal ctr_control_ALU : aluOP;
	signal ctr_branch : branchCtrl;
	--MUX3A1 entrada address banco registros
	signal write_address : std_logic_vector (4 downto 0);
	--BANCO DE REGISTROS
	signal entrada_banco,salida_banco_A, salida_banco_B: std_logic_vector (31 downto 0);
	signal bank_register : registros;
	signal reg_write_enable: std_logic;
	--Extensor signo y shifters de antes de la alu
	signal inmm_ext, inmm_shift, inmm_ceros, alu_input_2: std_logic_vector (31 downto 0);
	--CONTROL DE LA ALU
	signal ctr_ALU: operacion;
	--ALU
	signal menor,mayor,igual: std_logic;
	signal alu_output: std_logic_vector(31 downto 0);
	--MEMORIA
	signal memoria_datos_out: std_logic_vector(31 downto 0);
	--PC
	signal pc_mas_1,pc_mas_inmm, pc_sig, pc_act: std_logic_vector(ROMW-1 downto 0);
	signal pc_control: std_logic_vector(1 downto 0);
	signal pc_32: std_logic_vector(31 downto 0);
	signal pc_enable: std_logic;
	signal pc_to_rom: std_logic_vector(ROMW-1 downto 0);
	--PERIFÉRICOS: todas las señales van cableadas directas a/desde los puertos de entrada
	
	
	
begin

	-- salidas externas de la entity para debug de la unidad
	alu_out			<= alu_output; 	-- la salida de ALU a la salida de nuestra entity (for testing purposes)
	alu_in1			<= salida_banco_A;-- entrada 1 a la ALU
	alu_in2			<= alu_input_2;	-- entrada 2 a la ALU

	mem_in			<= salida_rom; 	-- salida de la ROM (memoria de instrucciones)

	ban_addr			<= write_address;	-- dirección donde se va a escribir al banco de registros
	banco_registros<= bank_register;	-- banco de registros completo (32x32)
	ban_in			<= entrada_banco;	-- entrada de datos al banco de registros

	pc_in				<= conv_std_logic_vector(0,16-ROMW) & pc_sig;	-- pc siguiente
	pc_out			<= conv_std_logic_vector(0,16-ROMW) & pc_act;	-- pc actual
	

	--mapeo de componentes del procesador (referirse al diagrama pdf para verlo más claro)
	memoria_instruc:	entity work.ROM generic map (ROMW, romfile) port map(salida_rom,pc_to_rom(ROMW-1 downto 0),clk);
	processor_control:entity work.control port map(salida_rom(31 downto 26),regDst,ALUsrc,regInput,regWrite,memWrite, memRead, perEnable,ctr_control_ALU,ctr_branch);
	mux_addr_reg:		entity work.mux3a1 generic map(5) port map(salida_rom(20 downto 16), salida_rom(15 downto 11), "11111", write_address, regDst);
	banco_reg:			bancoRegistros port map(salida_rom(25 downto 21), salida_rom(20 downto 16), write_address, entrada_banco, reg_write_enable, clk, salida_banco_A, salida_banco_B,bank_register);
	extensor_signo:	entity work.signExtension generic map(16,32) port map(salida_rom(15 downto 0), inmm_ext);
	shifter_16:			entity work.shifter16 port map(salida_rom(15 downto 0), inmm_shift);
	addceros_inmm:		completaceros port map(salida_rom(4 downto 0), inmm_ceros);
	mux_in_alu:			entity work.mux4a1 port map(salida_banco_B, inmm_ext, inmm_shift, inmm_ceros, alu_input_2,ALUsrc);
	alu_control:		entity work.ALUctr port map(salida_rom(5 downto 0), ctr_control_ALU, ctr_ALU);
	unidad_alu:			entity work.alu port map(salida_banco_A, alu_input_2, ctr_ALU, igual, mayor, menor, alu_output);
	memoria_datos:		entity work.DATAMEM port map(salida_banco_B,alu_output(9 downto 0),clk,memWrite,memRead,memoria_datos_out,dataReady,blocks_addr_out,flags_out,mem_state,hits_out,fails_out);
	mux_in_reg:			entity work.mux4a1 port map(alu_output, memoria_datos_out, pc_32, peridata_in, entrada_banco, regInput); --potencial fallo en ordenación de entradas
	branch_control:	entity work.branchCtr port map(ctr_branch, menor,mayor,igual,pc_control);
	mux_pc:				entity work.mux3a1 generic map (ROMW) port map(salida_banco_A(ROMW-1 downto 0), pc_mas_inmm, pc_mas_1,pc_sig,pc_control);
	pc_counter:			entity work.pc generic map(ROMW) port map(pc_sig,clk,reset,pc_enable,pc_act,pc_to_rom);

	
	-- señales del PC que van fijas. Diferentes posibilidades según saltos y demás.
	pc_mas_1				<= std_logic_vector(signed(pc_act) + 1);
	pc_mas_inmm			<= conv_std_logic_vector(to_integer(signed(pc_act) + signed(inmm_ext(15 downto 0))),ROMW);
	pc_32 				<= conv_std_logic_vector(0,32-ROMW) & pc_mas_1;
	-- desactivación de PC y registros si la memoria no está lista
	memop					<= memWrite or memRead;
	pc_enable			<= '0' when (dataReady = '0' and memop = '1') else '1';
	reg_write_enable	<= '1' when (regWrite = '1' and pc_enable = '1') else '0';
	
	-- salidas para periféricos (enable y la entrada de periférico están cableadas directamente)
	peridata_out		<= salida_banco_B(31 downto 16);
	pericommand			<= salida_banco_B(PCW-1 downto 0);
	perinumber			<= alu_output(PAW-1 downto 0);

end Behavioral;

