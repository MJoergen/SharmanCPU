library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

entity reg_8bit_generalpurpose is
   port (
      clk_i    : in  std_logic;
      load_i   : in  std_logic;
      main_i   : in  std_logic_vector(7 downto 0);
      val_o    : out std_logic_vector(7 downto 0)
   );
end entity reg_8bit_generalpurpose;

architecture synthesis of reg_8bit_generalpurpose is

   signal val : std_logic_vector(7 downto 0);

begin

   p_val : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if load_i = '1' then
            val <= main_i;
         end if;
      end if;
   end process p_val;

   val_o <= val;

end architecture synthesis;

