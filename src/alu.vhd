library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

entity alu is
   port (
      clk_i       : in  std_logic;
      lhs_i       : in  std_logic_vector(7 downto 0);
      rhs_i       : in  std_logic_vector(7 downto 0);
      oper_i      : in  std_logic_vector(1 downto 0);
      flags_in_i  : in  std_logic_vector(6 downto 0);
      result_o    : out std_logic_vector(7 downto 0);
      flags_out_o : out std_logic_vector(6 downto 0)
   );
end entity alu;

architecture synthesis of alu is

   signal lhs_shifted : std_logic_vector(7 downto 0);

begin

   p_shift : process (clk_i)
   begin
      if rising_edge(clk_i) then
         case oper_i is
            when "00"   => lhs_shifted <= lhs_i;
            when "01"   => lhs_shifted <= lhs_i(6 downto 0) & flags_in_i(4);
            when "10"   => lhs_shifted <= flags_in_i(4) & lhs_i(7 downto 1);
            when others => lhs_shifted <= lhs_i;
         end case;
      end if;
   end process p_shift;

   result_o <= lhs_shifted + rhs_i;

end architecture synthesis;

