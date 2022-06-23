library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

entity reg_16bit_xfer is
   port (
      clk_i            : in  std_logic;
      load_main_low_i  : in  std_logic;
      load_main_high_i : in  std_logic;
      load_xfer_i      : in  std_logic;
      main_i           : in  std_logic_vector(7 downto 0);
      xfer_i           : in  std_logic_vector(15 downto 0);
      val_o            : out std_logic_vector(15 downto 0)
   );
end entity reg_16bit_xfer;

architecture synthesis of reg_16bit_xfer is

   signal val : std_logic_vector(15 downto 0);

begin

   p_val : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if load_xfer_i = '1' then
            val <= xfer_i;
         end if;

         if load_main_low_i = '1' then
            val(7 downto 0) <= main_i;
         end if;

         if load_main_high_i = '1' then
            val(15 downto 8) <= main_i;
         end if;
      end if;
   end process p_val;

   val_o <= val;

end architecture synthesis;

