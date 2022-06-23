library ieee;
use ieee.std_logic_1164.all;

entity tb_system is
   port (
      clk_i   : in  std_logic;
      rst_i   : in  std_logic
   );
end entity tb_system;

architecture simulation of tb_system is

   signal clk : std_logic;
   signal rst : std_logic;

begin

   i_sim_clk : entity work.sim_clk
      port map (
         clk_o => clk,
         rst_o => rst
      ); -- i_sim_clk

   i_system : entity work.system
      port map (
         clk_i => clk,
         rst_i => rst
      ); -- i_system

end architecture simulation;

