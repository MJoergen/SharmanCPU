library ieee;
use ieee.std_logic_1164.all;

entity pipeline_roms is
   port (
      clk_i    : in  std_logic;
      addr_i   : in  std_logic_vector(14 downto 0);
      stage1_o : out std_logic_vector(15 downto 0);
      stage2_o : out std_logic_vector(15 downto 0)
   );
end entity pipeline_roms;

architecture synthesis of pipeline_roms is

begin

   -- Pipeline ROMS
   i_pipe1_rom1 : entity work.ram
      generic map (
         G_INIT_FILE => "Pipe1A.bin",
         G_ADDR_SIZE => 15,
         G_DATA_SIZE => 8
      )
      port map (
         clk_i     => clk_i,
         addr_i    => addr_i,
         rd_data_o => stage1_o(7 downto 0)
      ); -- i_pipeline1_rom1

   i_pipe1_rom2 : entity work.ram
      generic map (
         G_INIT_FILE => "Pipe1B.bin",
         G_ADDR_SIZE => 15,
         G_DATA_SIZE => 8
      )
      port map (
         clk_i     => clk_i,
         addr_i    => addr_i,
         rd_data_o => stage1_o(15 downto 8)
      ); -- i_pipeline1_rom2

   i_pipe2_rom1 : entity work.ram
      generic map (
         G_INIT_FILE => "Pipe2A.bin",
         G_ADDR_SIZE => 15,
         G_DATA_SIZE => 8
      )
      port map (
         clk_i     => clk_i,
         addr_i    => addr_i,
         rd_data_o => stage2_o(7 downto 0)
      ); -- i_pipeline2_rom1

   i_pipe2_rom2 : entity work.ram
      generic map (
         G_INIT_FILE => "Pipe2B.bin",
         G_ADDR_SIZE => 15,
         G_DATA_SIZE => 8
      )
      port map (
         clk_i     => clk_i,
         addr_i    => addr_i,
         rd_data_o => stage2_o(15 downto 8)
      ); -- i_pipeline2_rom2

end architecture synthesis;

