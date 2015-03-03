--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:56:20 02/21/2014
-- Design Name:   
-- Module Name:   C:/hlocal/MIPS_COMPUTER_V2/testcache.vhd
-- Project Name:  MIPS_COMPUTER_V2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: CACHE
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY testcache IS
END testcache;
 
ARCHITECTURE behavior OF testcache IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT CACHE
    PORT(
         p_data_in : IN  std_logic_vector(31 downto 0);
         p_data_out : OUT  std_logic_vector(31 downto 0);
         p_addr_in : IN  std_logic_vector(9 downto 0);
         m_data_in : IN  std_logic_vector(127 downto 0);
         m_data_out : OUT  std_logic_vector(127 downto 0);
         m_addr_out : OUT  std_logic_vector(7 downto 0);
         clk : IN  std_logic;
         writeEnable : IN  std_logic;
         readEnable : IN  std_logic;
         dataReady : OUT  std_logic;
         requestSave : OUT  std_logic;
         blocks_addr_out : OUT  addr_table;
         flags_out : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal p_data_in : std_logic_vector(31 downto 0) := (others => '0');
   signal p_addr_in : std_logic_vector(9 downto 0) := (others => '0');
   signal m_data_in : std_logic_vector(127 downto 0) := (others => '0');
   signal clk : std_logic := '0';
   signal writeEnable : std_logic := '0';
   signal readEnable : std_logic := '0';

 	--Outputs
   signal p_data_out : std_logic_vector(31 downto 0);
   signal m_data_out : std_logic_vector(127 downto 0);
   signal m_addr_out : std_logic_vector(7 downto 0);
   signal dataReady : std_logic;
   signal requestSave : std_logic;
   signal blocks_addr_out : addr_table;
   signal flags_out : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: CACHE PORT MAP (
          p_data_in => p_data_in,
          p_data_out => p_data_out,
          p_addr_in => p_addr_in,
          m_data_in => m_data_in,
          m_data_out => m_data_out,
          m_addr_out => m_addr_out,
          clk => clk,
          writeEnable => writeEnable,
          readEnable => readEnable,
          dataReady => dataReady,
          requestSave => requestSave,
          blocks_addr_out => blocks_addr_out,
          flags_out => flags_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		m_data_in <= (others => '1');
      wait for clk_period*10;
		writeEnable <= '1';
		
		for i in 0 to 127 loop
			p_addr_in <= conv_std_logic_vector(i,10);
			p_data_in <= conv_std_logic_vector(i,32);
			wait for clk_period*10;
		end loop;

      -- insert stimulus here 

      wait;
   end process;

END;
