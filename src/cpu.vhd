library ieee;
use ieee.std_logic_1164.all;

entity cpu is
   port (
      clk_i   : in  std_logic;
      rst_i   : in  std_logic;
      addr_o  : out std_logic_vector(15 downto 0);
      data_o  : out std_logic_vector(7 downto 0);
      data_i  : in  std_logic_vector(7 downto 0);
      rdwr_o  : out std_logic
   );
end entity cpu;

architecture synthesis of cpu is

   signal pipe_rom_addr : std_logic_vector(14 downto 0);
   signal stage1        : std_logic_vector(15 downto 0);
   signal stage2        : std_logic_vector(15 downto 0);

begin

   ----------------------------------
   -- Instantiate Pipeline ROMs
   ----------------------------------

   i_pipeline_roms : entity work.pipeline_roms
      port map (
         clk_i    => clk_i,
         addr_i   => pipe_rom_addr,
         stage1_o => stage1,
         stage2_o => stage2
      );

   -- ALU

   -- Registers

end architecture synthesis;

