----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	alu.vhd:

-- alu para 32x32 bits. Suma resta mult shifts operaciones lógicas
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.tipos.all;

entity alu is
port(	in_1,in_2: in std_logic_vector (31 downto 0);
		control: in tipos.operacion;
		out_igual, out_mayor, out_menor: out std_logic;
		result: out std_logic_vector (31 downto 0));
end alu;

architecture Behavioral of alu is
	--division y multiplicación
	signal low,high: std_logic_vector(31 downto 0);
	--operaciones lógicas
	signal control_logicunit: std_logic_vector (3 downto 0);
	signal output_logicunit: std_logic_vector (31 downto 0);
	--shifts
	component shiftunit is
		port (input: in std_logic_vector(31 downto 0);
				shift_amount: in std_logic_vector(4 downto 0);
				logic_or_arith, left_or_right: in std_logic; --logic_or_arith: 1 logic 0 arith; left_or_right: 1 left 0 right
				output: out std_logic_vector (31 downto 0));
	end component shiftunit;
	signal logic_or_arith, left_or_right: std_logic;
	signal output_shiftunit: std_logic_vector (31 downto 0);
	--sumas y restas
	signal control_sumaresta, mayor, menor, igual: std_logic;
	signal output_sumaresta: std_logic_vector (31 downto 0);

begin
	--componentes utilizados
	modulo_prod: entity work.multiplicador port map(in_1, in_2, high, low);
	modulo_logico: entity work.logicunit port map(in_1, in_2, control_logicunit, output_logicunit);
	modulo_shift: shiftunit port map(in_1, in_2(4 downto 0), logic_or_arith, left_or_right, output_shiftunit);
	modulo_sumaresta: entity work.sumaresta port map (in_1, in_2, control_sumaresta, output_sumaresta, mayor, menor, igual);
	
	--salidas de la alu quedan cableadas tal cual
	out_mayor <= mayor;
	out_menor <= menor;
	out_igual <= igual;
	
	
asignacion: process (control, output_sumaresta, output_shiftunit, output_logicunit, low,high)
begin
	--control del sumador
	if control = op_add then
		control_sumaresta <= '0';
	else
		control_sumaresta <= '1';
	end if;
	--control de unidad lógica
	if control = op_and then
		control_logicunit <= "1000";
	elsif control = op_or then
		control_logicunit <= "1110";
	elsif control = op_xor then
		control_logicunit <= "0110";
	else 
		control_logicunit <= "0001";
	end if;
	--control de unidad de shift
	if control = op_sll then
		logic_or_arith	<= '1';
		left_or_right	<= '1';
	elsif control = op_srl then
		logic_or_arith	<= '1';
		left_or_right	<= '0';
	else
		logic_or_arith	<= '0';
		left_or_right	<= '0'; --da igual 0 o 1 pero le asignamos algo para que no salga u
	end if;

	--control del resultado
	case control is
		when op_add => 	result <= output_sumaresta;
		when op_sub => 	result <= output_sumaresta;
		when op_mult => 	result <= low;
		when op_mult_hi =>result <= high;
		when op_and =>		result <= output_logicunit;
		when op_or =>		result <= output_logicunit;
		when op_xor =>		result <= output_logicunit;
		when op_nor =>		result <= output_logicunit;
		when op_sll =>		result <= output_shiftunit;
		when op_srl =>		result <= output_shiftunit;
		when op_sra =>		result <= output_shiftunit;
		when others =>		result <= "11111111000000000000000011111111"; --salida por defecto si la operación no es reconocida
	end case;
end process;


end Behavioral;

