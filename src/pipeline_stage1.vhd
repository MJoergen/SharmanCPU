library ieee;
use ieee.std_logic_1164.all;

entity pipeline_stage1 is
   port (
      clk_i            : in  std_logic;
      bus_request_i    : in  std_logic;
      flags_i          : in  std_logic_vector(6 downto 0);
      pipeline_i       : in  std_logic_vector(7 downto 0);

      pipeline_o       : out std_logic_vector(7 downto 0);
      control_o        : out std_logic_vector(15 downto 0)
   );
end entity pipeline_stage1;

architecture synthesis of pipeline_stage1 is

   signal pipeline_d : std_logic_vector(7 downto 0);

begin

   i_pipe1_rom1 : entity work.ram
      generic map (
         G_INIT_FILE => "../roms/Pipe1A.bin",
         G_ADDR_SIZE => 15,
         G_DATA_SIZE => 8
      )
      port map (
         clk_i     => not clk_i,
         addr_i    => flags_i & pipeline_i,
         rd_data_o => control_o(7 downto 0)
      ); -- i_pipeline1_rom1

   i_pipe1_rom2 : entity work.ram
      generic map (
         G_INIT_FILE => "../roms/Pipe1B.bin",
         G_ADDR_SIZE => 15,
         G_DATA_SIZE => 8
      )
      port map (
         clk_i     => not clk_i,
         addr_i    => flags_i & pipeline_i,
         rd_data_o => control_o(15 downto 8)
      ); -- i_pipeline1_rom2

   p_pipeline : process (clk_i)
   begin
      if rising_edge(clk_i) then
         pipeline_d <= pipeline_i;
      end if;
   end process p_pipeline;

   pipeline_o <= pipeline_d when control_o(15) = '0' or bus_request_i = '0' else (others => '0');

end architecture synthesis;

