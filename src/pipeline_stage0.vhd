library ieee;
use ieee.std_logic_1164.all;

entity pipeline_stage0 is
   port (
      clk_i            : in  std_logic;
      memdata_i        : in  std_logic_vector(7 downto 0);
      bus_request_i    : in  std_logic;
      fetch_suppress_i : in  std_logic;
      pcra_flip_i      : in  std_logic;
      pipeline_o       : out std_logic_vector(7 downto 0);
      inc_pcpra_o      : out std_logic_vector(1 downto 0)
   );
end entity pipeline_stage0;

architecture synthesis of pipeline_stage0 is

   signal pipe0_latch : std_logic_vector(7 downto 0);
   signal pipe0_out   : std_logic_vector(7 downto 0);

begin

   p_pipe0 : process (clk_i)
   begin
      if rising_edge(clk_i) then
         pipe0_latch <= memdata_i;
      end if;
   end process p_pipe0;

   p_pipe0_out : process (all)
   begin
      case bus_request_i & fetch_suppress_i is
         when "00"   => pipe0_out <= memdata_i;
         when "01"   => pipe0_out <= (others => '0');
         when "10"   => pipe0_out <= (others => '0');
         when "11"   => pipe0_out <= pipe0_latch;
         when others => pipe0_out <= (others => '0');
      end case;
   end process p_pipe0_out;

   pipeline_o  <= pipe0_out;
   inc_pcpra_o <= bus_request_i & pcra_flip_i;

end architecture synthesis;

