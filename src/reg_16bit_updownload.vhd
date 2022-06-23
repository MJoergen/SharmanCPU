library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

entity reg_16bit_updownload is
   port (
      clk_i    : in  std_logic;
      clear_i  : in  std_logic;
      load_i   : in  std_logic;
      inc_i    : in  std_logic;
      dec_i    : in  std_logic;
      carry_o  : out std_logic;
      borrow_o : out std_logic;
      xfer_i   : in  std_logic_vector(15 downto 0);
      val_o    : out std_logic_vector(15 downto 0)
   );
end entity reg_16bit_updownload;

architecture synthesis of reg_16bit_updownload is

   signal val : std_logic_vector(15 downto 0);

begin

   p_val : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if inc_i = '1' then
            val <= val + 1;
         end if;

         if dec_i = '1' then
            val <= val - 1;
         end if;

         if load_i = '1' then
            val <= xfer_i;
         end if;

         if clear_i = '1' then
            val <= (others => '0');
         end if;
      end if;
   end process p_val;

   val_o <= val;

   carry_o  <= '1' when val = 0 else '0';
   borrow_o <= '1' when val = 2**16-1 else '0';

end architecture synthesis;

