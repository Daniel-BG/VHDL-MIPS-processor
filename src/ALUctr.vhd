----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	ALUctr.vhd:

-- control de opreación para la ALU
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.tipos.all;

entity ALUctr is
	port( funct : in std_logic_vector (5 downto 0);
			ALUop : in tipos.aluOP;
			ALUcontrol : out tipos.operacion);
end ALUctr;

architecture Behavioral of ALUctr is

begin
ALUcontrol_assig : process (ALUop,funct)
begin
	case ALUop is
		when ctrlALU_add => ALUcontrol <= op_add;
		when ctrlALU_sub => ALUcontrol <= op_sub;
      when ctrlALU_and => ALUcontrol <= op_and;
      when ctrlALU_or  => ALUcontrol <= op_or;
      when ctrlALU_xor => ALUcontrol <= op_xor;
		when ctrlALU_sll => ALUcontrol <= op_sll;
		when ctrlALU_srl => ALUcontrol <= op_srl;
		when ctrlALU_sra => ALUcontrol <= op_sra;
		when others => --aquí dejamos que dependa del campo funct ya que no forzamos la operación
			case funct is
				when f_sllv	=> ALUcontrol <= op_sll;	-- SLLV (actúa como SLL)
				when f_srlv => ALUcontrol <= op_srl;	-- SLRV (actúa como SRL)
				when f_srav => ALUcontrol <= op_sra;	-- SRAV (actúa como SRA)
				when f_mult => ALUcontrol <= op_mult;	-- MULT
				when f_add	=> ALUcontrol <= op_add;	-- ADD
				when f_sub	=> ALUcontrol <= op_sub;	-- SUB
				when f_and	=> ALUcontrol <= op_and;	-- AND
				when f_or	=> ALUcontrol <= op_or;		-- OR
				when f_xor	=> ALUcontrol <= op_xor;	-- XOR
				when f_nor	=> ALUcontrol <= op_nor;	-- NOR
				when others => ALUcontrol <= op_add; 	-- op por defecto
			end case;
	end case;
end process;


end Behavioral;

