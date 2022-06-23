library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;
use std.textio.all;

entity ram is
   generic (
      G_INIT_FILE : string := "";
      G_RAM_STYLE : string := "block";
      G_ADDR_SIZE : integer;
      G_DATA_SIZE : integer
   );
   port (
      clk_i       : in  std_logic;
      addr_i      : in  std_logic_vector(G_ADDR_SIZE-1 downto 0);
      wr_en_i     : in  std_logic := '0';
      wr_data_i   : in  std_logic_vector(G_DATA_SIZE-1 downto 0) := (others => '0');
      rd_data_o   : out std_logic_vector(G_DATA_SIZE-1 downto 0) := (others => '0')
   );
end entity ram;

architecture synthesis of ram is

   type mem_t is array (0 to 2**G_ADDR_SIZE-1) of std_logic_vector(G_DATA_SIZE-1 downto 0);

   -- This reads the ROM contents from a text file
   impure function InitRamFromFile(RamFileName : in string) return mem_t is
      type char_file_t is file of character;
      FILE char_file : char_file_t;
      variable char_v : character;
      variable ram : mem_t := (others => (others => '0'));
   begin
      if RamFileName /= "" then
         file_open(char_file, RamFileName, read_mode);
         for i in mem_t'range loop
            read(char_file, char_v);
            ram(i) := to_stdlogicvector(character'pos(char_v), 8);
            if endfile(char_file) then
               return ram;
            end if;
         end loop;
      end if;
      return ram;
   end function;

   -- Initial memory contents
   signal mem : mem_t := InitRamFromFile(G_INIT_FILE);

begin

   p_a : process (clk_i)
   begin
      if rising_edge(clk_i) then
         rd_data_o <= mem(to_integer(addr_i));
         if wr_en_i = '1' then
            mem(to_integer(addr_i)) <= wr_data_i;
         end if;
      end if;
   end process p_a;

end architecture synthesis;

