library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package tipos is
   type registros is array (0 to 31) of std_logic_vector(31 downto 0); -- tipo registros que es array de 32 posiciones tamaño palabr
	type registros_sin_z is array (1 to 31) of std_logic_vector(31 downto 0); -- tipo registros que es array de 32 posiciones tamaño palabr
	type addr_table is array (0 to 7) of std_logic_vector(4 downto 0); --(no es 7 downto 0 pues eso va implícito en la situación física de la memoria)
	type operacion is (op_add,op_sub,op_mult,op_mult_hi,op_div,op_and,op_or,op_xor,op_nor,op_sll,op_srl,op_sra);
   type aluOP is (ctrlALU_sll, ctrlALU_srl, ctrlALU_sra, ctrlALU_add, ctrlALU_sub, ctrlALU_xor, ctrlALU_and, ctrlALU_or, ctrlALU_funct);
	type branchCtrl is (b_eq,b_ne,b_le,b_ge,b_gt,b_lt,b_always,b_never,b_reg);
	--small screen array
	type ss_array is array(0 to 15) of std_logic_vector(15 downto 0);
	
	
	-- CONSTANTES CODIGO DE OPERACIÓN (CAMPO opcode)
	constant c_jr: 	std_logic_vector (5 downto 0) := "010000"; 	-- JR (actúa como ADD)
	constant c_jalr:	std_logic_vector (5 downto 0) := "010001";	-- JALR
	CONSTANT c_bal: 	std_logic_vector (5 downto 0) := "010101"; -- saltar y enlazar 
	CONSTANT c_blt: 	std_logic_vector (5 downto 0) := "010110"; -- saltar si menor estricto
	CONSTANT c_bge: 	std_logic_vector (5 downto 0) := "010111"; -- saltar si mayor estricto
	CONSTANT c_beq: 	std_logic_vector (5 downto 0) := "000100"; -- salto si igual
	CONSTANT c_bne: 	std_logic_vector (5 downto 0) := "000101"; -- salto si distinto
	CONSTANT c_ble: 	std_logic_vector (5 downto 0) := "000110"; -- salto si menor o igual
	CONSTANT c_bgt: 	std_logic_vector (5 downto 0) := "000111"; -- salto si mayor o igual
		
	CONSTANT c_addi:	std_logic_vector (5 downto 0) := "001000"; -- suma con inmediato
	constant c_slli: 	std_logic_vector (5 downto 0) := "001001"; 	-- SLL
	constant c_srli: 	std_logic_vector (5 downto 0) := "001010"; 	-- SRL
	constant c_srai: 	std_logic_vector (5 downto 0) := "001011"; 	-- SRA
	CONSTANT c_andi:	std_logic_vector (5 downto 0) := "001100"; -- and con inmediato
	CONSTANT c_ori: 	std_logic_vector (5 downto 0) := "001101";	-- or con inmediato
	CONSTANT c_xori:	std_logic_vector (5 downto 0) := "001110"; -- xor con inmediato
	CONSTANT c_lui: 	std_logic_vector (5 downto 0) := "001111"; -- carga superior con inmediato

	CONSTANT c_lw: 	std_logic_vector (5 downto 0) := "100011"; -- cargar palabra
	CONSTANT c_sw: 	std_logic_vector (5 downto 0) := "101011"; -- guardar palabra
	
	constant c_in:		std_logic_vector (5 downto 0) := "111111"; -- entrada periférico
	constant c_out:	std_logic_vector (5 downto 0) := "111110"; -- salida periférico
	
	CONSTANT c_alu: 	std_logic_vector (5 downto 0) := "000000"; -- activación del campo funct

	
	-- CONSTANTES CODIGO DE FUNCION (CAMPO funct)
	constant f_sllv : std_logic_vector (5 downto 0) := "000100";	-- SLLV (actúa como SLL)
	constant f_srlv : std_logic_vector (5 downto 0) := "000110";	-- SLLV (actúa como SRL)
	constant f_srav : std_logic_vector (5 downto 0) := "000111";	-- SRAV (actúa como SRA)
	constant f_mult : std_logic_vector (5 downto 0) := "011000";	-- MULT
	constant f_add : std_logic_vector (5 downto 0) := "100000"; 	-- ADD
	constant f_sub : std_logic_vector (5 downto 0) := "100010";		-- SUB
	constant f_and : std_logic_vector (5 downto 0) := "100100";		-- AND
	constant f_or : std_logic_vector (5 downto 0) := "100101";		-- OR
	constant f_xor : std_logic_vector (5 downto 0) := "100110";		-- XOR
	constant f_nor : std_logic_vector (5 downto 0) := "100111";		-- NOR

end package tipos;