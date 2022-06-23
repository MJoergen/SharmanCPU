library ieee;
use ieee.std_logic_1164.all;

entity system is
   port (
      clk_i   : in  std_logic;
      rst_i   : in  std_logic
   );
end entity system;

architecture synthesis of system is

   signal addr    : std_logic_vector(15 downto 0);
   signal wr_data : std_logic_vector(7 downto 0);
   signal rd_data : std_logic_vector(7 downto 0);
   signal wr_en   : std_logic;

begin

   ------------------------
   -- Instantiate CPU
   ------------------------

   i_cpu : entity work.cpu
      port map (
         clk_i   => clk_i,
         rst_i   => rst_i,
         addr_o  => addr,
         data_o  => wr_data,
         data_i  => rd_data,
         rdwr_o  => wr_en
      ); -- i_cpu


   ------------------------
   -- Instantiate RAM
   ------------------------

   i_ram : entity work.ram
      generic map (
         G_ADDR_SIZE => 16,
         G_DATA_SIZE => 8
      )
      port map (
         clk_i     => clk_i,
         addr_i    => addr,
         wr_en_i   => wr_en,
         wr_data_i => wr_data,
         rd_data_o => rd_data
      );

   -- TBD: Add UART
   -- TBD: Add VGA

end architecture synthesis;

