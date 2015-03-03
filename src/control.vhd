----------------------------------------------------------------------------------
-- NOT (Number One Toc)
-- 	-Daniel Báscones Garcia
--		-David Peñas Gómez
--		-Íñigo Zunzunegui Monterrubio
-- 
--	control.vhd:

-- Generador de señales de control para los diferentes componentes del procesador
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.tipos.all;

--out r1 r2 inmm
-- guardo en r2+inmm lo que diga r1
--111011 00010 00001 inmm


--in r1 r2 inmm
-- quiero escribir en r1 y leer de donde diga r2+inmm, por ello r1 va en el segundo lugar para
-- ser escrito
--110011 00010 00001 inmm

entity control is	
	port (
		controlIn : in std_logic_vector (5 downto 0);
		regDst,ALUsrc,regInput : out std_logic_vector (1 downto 0);
		regWrite,memWrite,memRead, perEnable: out std_logic;
		ctr_control_ALU : out aluOP;
		ctr_branch : out branchCtrl
   );
end control;

architecture Behavioral of control is
	--señales de control apiñadas en un vector para comodidad de programación
	signal ctrl_signals : std_logic_vector (9 downto 0);
begin

calcula_senyales: process (controlIn)
begin
	case controlIn is
		-- regDst1 | regDst0 | ALUsrc0 | ALUscr1 | RegInput0 | RegInput1 | RegWrite | MemWrite | MemRead | PerEnable
		-- regDst:	0 -> I(20-16) 
		--				1 -> I(15-11)  
		--				2 -> "11111"
		-- ALUsrc:  0 -> salida B banco
		--				1 -> inmediato extendido
		--				2 -> inmediato << 16
		--				3 -> 0 & inmediato (4 downto 0)
		-- reginput:0 -> alu out
		--				1 -> memoria datos out
		--				2 -> pc
		--				3 -> periférico
		
		when c_jr	=> ctrl_signals <= "0000000000"; ctr_control_ALU <= ctrlALU_funct;ctr_branch <= b_reg;
		when c_jalr	=> ctrl_signals <= "1000101000"; ctr_control_ALU <= ctrlALU_funct;ctr_branch <= b_reg;
		when c_bal	=> ctrl_signals <= "1000101000"; ctr_control_ALU <= ctrlALU_funct;ctr_branch <= b_always;
		when c_blt	=> ctrl_signals <= "0000000000"; ctr_control_ALU <= ctrlALU_sub;	ctr_branch <= b_lt;
		when c_bge	=> ctrl_signals <= "0000000000"; ctr_control_ALU <= ctrlALU_sub;	ctr_branch <= b_ge;
		when c_beq	=> ctrl_signals <= "0000000000"; ctr_control_ALU <= ctrlALU_sub;	ctr_branch <= b_eq;
		when c_bne	=> ctrl_signals <= "0000000000"; ctr_control_ALU <= ctrlALU_sub;	ctr_branch <= b_ne;
		when c_ble	=> ctrl_signals <= "0000000000"; ctr_control_ALU <= ctrlALU_sub;	ctr_branch <= b_le;
		when c_bgt	=> ctrl_signals <= "0000000000"; ctr_control_ALU <= ctrlALU_sub;	ctr_branch <= b_gt;
		
		when c_ori	=> ctrl_signals <= "0001001000"; ctr_control_ALU <= ctrlALU_or;	ctr_branch <= b_never;
		when c_andi	=> ctrl_signals <= "0001001000"; ctr_control_ALU <= ctrlALU_and;	ctr_branch <= b_never;
		when c_xori	=> ctrl_signals <= "0001001000"; ctr_control_ALU <= ctrlALU_xor;	ctr_branch <= b_never;
		when c_addi	=> ctrl_signals <= "0001001000"; ctr_control_ALU <= ctrlALU_add;	ctr_branch <= b_never;
		when c_slli	=> ctrl_signals <= "0011001000"; ctr_control_ALU <= ctrlALU_sll;	ctr_branch <= b_never;
		when c_srli	=> ctrl_signals <= "0011001000"; ctr_control_ALU <= ctrlALU_srl;	ctr_branch <= b_never;
		when c_srai	=> ctrl_signals <= "0011001000"; ctr_control_ALU <= ctrlALU_sra;	ctr_branch <= b_never;
		when c_lui	=> ctrl_signals <= "0010001000"; ctr_control_ALU <= ctrlALU_add;	ctr_branch <= b_never;
		
		when c_lw	=> ctrl_signals <= "0001011010"; ctr_control_ALU <= ctrlALU_add;	ctr_branch <= b_never;
		when c_sw	=> ctrl_signals <= "0001000100"; ctr_control_ALU <= ctrlALU_add;	ctr_branch <= b_never;
		
		when c_in	=> ctrl_signals <= "0001111001"; ctr_control_ALU <= ctrlALU_add;	ctr_branch <= b_never;
		when c_out	=> ctrl_signals <= "0001000001"; ctr_control_ALU <= ctrlALU_add;	ctr_branch <= b_never;
		
		when c_alu	=> ctrl_signals <= "0100001000"; ctr_control_ALU <= ctrlALU_funct;ctr_branch <= b_never;
		when others => ctrl_signals <= "0000000000"; ctr_control_ALU <= ctrlALU_add; 	ctr_branch <= b_never;-- ni escritura en memoria ni registros ni nada
		end case;
	end process;
   
   -- asignamos la señal intermedia a las salidas del control.
	asigna_salidas : process (ctrl_signals)
	begin
		regDst	<= ctrl_signals(9 downto 8);
		ALUsrc	<= ctrl_signals(7 downto 6);
		regInput <= ctrl_signals(5 downto 4);
		regWrite	<= ctrl_signals(3);
		memWrite	<= ctrl_signals(2);
		memRead	<= ctrl_signals(1);
		perEnable<= ctrl_signals(0);
	end process;
	
end Behavioral;

