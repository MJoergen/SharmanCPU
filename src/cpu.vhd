library ieee;
use ieee.std_logic_1164.all;

entity cpu is
   port (
      clk_i     : in  std_logic;
      rst_i     : in  std_logic;
      addr_o    : out std_logic_vector(15 downto 0);
      wr_data_o : out std_logic_vector(7 downto 0);
      rd_data_i : in  std_logic_vector(7 downto 0);
      wr_en_o   : out std_logic
   );
end entity cpu;

architecture synthesis of cpu is

   -- 16-bit registers
   signal register_pcra0            : std_logic_vector(15 downto 0);
   signal register_pcra1            : std_logic_vector(15 downto 0);
   signal register_sp               : std_logic_vector(15 downto 0);
   signal register_si               : std_logic_vector(15 downto 0);
   signal register_di               : std_logic_vector(15 downto 0);
   signal register_tx               : std_logic_vector(15 downto 0);

   -- 8-bit registers
   signal register_a                : std_logic_vector(7 downto 0);
   signal register_b                : std_logic_vector(7 downto 0);
   signal register_c                : std_logic_vector(7 downto 0);
   signal register_d                : std_logic_vector(7 downto 0);

   -- Busses
   signal bus_addr                  : std_logic_vector(15 downto 0);
   signal bus_xfer                  : std_logic_vector(15 downto 0);
   signal bus_main                  : std_logic_vector(7 downto 0);
   signal bus_lhs                   : std_logic_vector(7 downto 0);
   signal bus_rhs                   : std_logic_vector(7 downto 0);

   -- Control signals
   signal addrsel                   : std_logic_vector(2 downto 0);
   signal control_pcra0_assertaddr  : std_logic;
   signal control_pcra1_assertaddr  : std_logic;
   signal control_sp_assertaddr     : std_logic;
   signal control_si_assertaddr     : std_logic;
   signal control_di_assertaddr     : std_logic;
   signal control_tx_assertaddr     : std_logic;

   signal mainbus_assert            : std_logic_vector(3 downto 0);
   signal control_reg_a_assert      : std_logic;   -- 1
   signal control_reg_b_assert      : std_logic;   -- 2
   signal control_reg_c_assert      : std_logic;   -- 3
   signal control_reg_d_assert      : std_logic;   -- 4
   signal control_reg_const_assert  : std_logic;   -- 5
   signal control_reg_tl_assert     : std_logic;   -- 6
   signal control_reg_th_assert     : std_logic;   -- 7
   signal control_alu_assert        : std_logic;   -- 8
   signal control_dev9_assert       : std_logic;   -- 9
   signal control_dev10_assert      : std_logic;   -- 10
   signal control_dev11_assert      : std_logic;   -- 11
   signal control_dev12_assert      : std_logic;   -- 12
   signal control_dev13_assert      : std_logic;   -- 13
   signal control_dev14_assert      : std_logic;   -- 14
   signal control_membridge_assert  : std_logic;   -- 15

   signal mainbus_load              : std_logic_vector(3 downto 0);
   signal control_reg_a_load        : std_logic;   -- 1
   signal control_reg_b_load        : std_logic;   -- 2
   signal control_reg_c_load        : std_logic;   -- 3
   signal control_reg_d_load        : std_logic;   -- 4
   signal control_reg_const_load    : std_logic;   -- 5
   signal control_reg_tl_load       : std_logic;   -- 6
   signal control_reg_th_load       : std_logic;   -- 7
   signal control_alu_load          : std_logic;   -- 8
   signal control_dev9_load         : std_logic;   -- 9
   signal control_dev10_load        : std_logic;   -- 10
   signal control_dev11_load        : std_logic;   -- 11
   signal control_dev12_load        : std_logic;   -- 12
   signal control_dev13_load        : std_logic;   -- 13
   signal control_dev14_load        : std_logic;   -- 14
   signal control_membridge_load    : std_logic;   -- 15

   signal inc_pcra                  : std_logic_vector(1 downto 0);
   signal control_pcra0_inc         : std_logic;
   signal control_pcra1_inc         : std_logic;

   signal inc_spsidi                : std_logic_vector(1 downto 0);
   signal control_sp_inc            : std_logic;
   signal control_si_inc            : std_logic;
   signal control_di_inc            : std_logic;

   signal xfer_assert               : std_logic_vector(2 downto 0);
   signal control_pcra0_assertxfer  : std_logic;
   signal control_pcra1_assertxfer  : std_logic;
   signal control_sp_assertxfer     : std_logic;
   signal control_si_assertxfer     : std_logic;
   signal control_di_assertxfer     : std_logic;
   signal control_tx_assertxfer     : std_logic;

   signal xfer_loaddec              : std_logic_vector(3 downto 0);
   signal control_pcra0_loadxfer    : std_logic;
   signal control_pcra1_loadxfer    : std_logic;
   signal control_sp_loadxfer       : std_logic;
   signal control_si_loadxfer       : std_logic;
   signal control_di_loadxfer       : std_logic;
   signal control_tx_loadxfer       : std_logic;
   signal control_pcra0_dec         : std_logic;
   signal control_pcra1_dec         : std_logic;
   signal control_sp_dec            : std_logic;
   signal control_si_dec            : std_logic;
   signal control_di_dec            : std_logic;

   -- Flags
   constant C_FLAGS_OVERLOW         : natural := 0;
   constant C_FLAGS_SIGN            : natural := 1;
   constant C_FLAGS_ZERO            : natural := 2;
   constant C_FLAGS_CARRYA          : natural := 3;
   constant C_FLAGS_CARRYL          : natural := 4;
   constant C_FLAGS_PCRA_FLIP       : natural := 5;
   constant C_FLAGS_RESET           : natural := 6;

   signal flags                     : std_logic_vector(6 downto 0) := (others => '0');

   subtype  R_PIPE1_LHS         is natural range  1 downto  0;
   subtype  R_PIPE1_RHS         is natural range  3 downto  2;
   subtype  R_PIPE1_ALUOP       is natural range  7 downto  4;
   subtype  R_PIPE1_XLD         is natural range 11 downto  8;
   subtype  R_PIPE1_XA          is natural range 14 downto 12;
   constant R_PIPE1_FETCH_SUPP  :  natural := 15;

   subtype  R_PIPE2_MAIN_ASSERT is natural range  3 downto  0;
   subtype  R_PIPE2_MAIN_LOAD   is natural range  7 downto  4;
   subtype  R_PIPE2_INC_SPSIDI  is natural range  9 downto  8;
   subtype  R_PIPE2_ADDRSEL     is natural range 12 downto 10;
   constant R_PIPE2_BUSREQUEST  :  natural := 13;
   constant R_PIPE2_PCRA_FLIP   :  natural := 14;
   constant R_PIPE2_BREAK       :  natural := 15;

   signal pipe_rom_addr             : std_logic_vector(14 downto 0);
   signal stage0                    : std_logic_vector(15 downto 0);
   signal stage1                    : std_logic_vector(15 downto 0);
   signal stage2                    : std_logic_vector(15 downto 0);

   signal instr                     : std_logic_vector(7 downto 0);

--   signal alu_lhs                   : std_logic_vector(7 downto 0);
--   signal alu_rhs                   : std_logic_vector(7 downto 0);
--   signal alu_oper                  : std_logic_vector(1 downto 0);
--   signal alu_flags_in              : std_logic_vector(6 downto 0);
--   signal alu_result                : std_logic_vector(7 downto 0);
--   signal alu_flags_out             : std_logic_vector(6 downto 0);

begin

   ----------------------------------
   -- Instantiate 16-bit registers
   ----------------------------------

   i_reg_16bit_updownload_pcra0 : entity work.reg_16bit_updownload
      port map (
         clk_i    => clk_i,
         clear_i  => flags(C_FLAGS_RESET),
         load_i   => control_pcra0_loadxfer,
         inc_i    => control_pcra0_inc,
         dec_i    => control_pcra0_dec,
         xfer_i   => bus_xfer,
         val_o    => register_pcra0
      ); -- i_reg_16bit_updownload_pcra0

   i_reg_16bit_updownload_pcra1 : entity work.reg_16bit_updownload
      port map (
         clk_i    => clk_i,
         clear_i  => flags(C_FLAGS_RESET),
         load_i   => control_pcra1_loadxfer,
         inc_i    => control_pcra1_inc,
         dec_i    => control_pcra1_dec,
         xfer_i   => bus_xfer,
         val_o    => register_pcra1
      ); -- i_reg_16bit_updownload_pcra1

   i_reg_16bit_updownload_sp : entity work.reg_16bit_updownload
      port map (
         clk_i    => clk_i,
         clear_i  => flags(C_FLAGS_RESET),
         load_i   => control_sp_loadxfer,
         inc_i    => control_sp_inc,
         dec_i    => control_sp_dec,
         xfer_i   => bus_xfer,
         val_o    => register_sp
      ); -- i_reg_16bit_updownload_sp

   i_reg_16bit_updownload_si : entity work.reg_16bit_updownload
      port map (
         clk_i    => clk_i,
         clear_i  => flags(C_FLAGS_RESET),
         load_i   => control_si_loadxfer,
         inc_i    => control_si_inc,
         dec_i    => control_si_dec,
         xfer_i   => bus_xfer,
         val_o    => register_si
      ); -- i_reg_16bit_updownload_si

   i_reg_16bit_updownload_di : entity work.reg_16bit_updownload
      port map (
         clk_i    => clk_i,
         clear_i  => flags(C_FLAGS_RESET),
         load_i   => control_di_loadxfer,
         inc_i    => control_di_inc,
         dec_i    => control_di_dec,
         xfer_i   => bus_xfer,
         val_o    => register_di
      ); -- i_reg_16bit_updownload_di

   i_reg_16_tx : entity work.reg_16bit_xfer
      port map (
         clk_i            => clk_i,
         load_main_high_i => control_di_loadxfer,
         load_main_low_i  => control_di_loadxfer,
         load_xfer_i      => control_di_loadxfer,
         xfer_i           => bus_xfer,
         main_i           => bus_main,
         val_o            => register_tx
      ); -- i_reg_16_tx


   ----------------------------------
   -- Instantiate 8-bit registers
   ----------------------------------

   i_reg_8bit_generalpurpose_a : entity work.reg_8bit_generalpurpose
      port map (
         clk_i  => clk_i,
         load_i => control_reg_a_load,
         main_i => bus_main,
         val_o  => register_a
      ); -- i_reg_8bit_generalpurpose_a

   i_reg_8bit_generalpurpose_b : entity work.reg_8bit_generalpurpose
      port map (
         clk_i  => clk_i,
         load_i => control_reg_b_load,
         main_i => bus_main,
         val_o  => register_b
      ); -- i_reg_8bit_generalpurpose_b

   i_reg_8bit_generalpurpose_c : entity work.reg_8bit_generalpurpose
      port map (
         clk_i  => clk_i,
         load_i => control_reg_c_load,
         main_i => bus_main,
         val_o  => register_c
      ); -- i_reg_8bit_generalpurpose_c

   i_reg_8bit_generalpurpose_d : entity work.reg_8bit_generalpurpose
      port map (
         clk_i  => clk_i,
         load_i => control_reg_d_load,
         main_i => bus_main,
         val_o  => register_d
      ); -- i_reg_8bit_generalpurpose_d


   ----------------------------------
   -- Instantiate buses
   ----------------------------------

   p_bus_xfer : process (all)
   begin
      bus_xfer <= (others => 'U');
      if    control_pcra0_assertxfer = '1' then bus_xfer <= register_pcra0;
      elsif control_pcra1_assertxfer = '1' then bus_xfer <= register_pcra1;
      elsif control_sp_assertxfer    = '1' then bus_xfer <= register_sp;
      elsif control_si_assertxfer    = '1' then bus_xfer <= register_si;
      elsif control_di_assertxfer    = '1' then bus_xfer <= register_di;
      elsif control_tx_assertxfer    = '1' then bus_xfer <= register_tx;
      end if;
   end process p_bus_xfer;

   p_bus_addr : process (all)
   begin
      bus_addr <= (others => '0');
      if    control_pcra0_assertaddr = '1' then bus_addr <= register_pcra0;
      elsif control_pcra1_assertaddr = '1' then bus_addr <= register_pcra1;
      elsif control_sp_assertaddr    = '1' then bus_addr <= register_sp;
      elsif control_si_assertaddr    = '1' then bus_addr <= register_si;
      elsif control_di_assertaddr    = '1' then bus_addr <= register_di;
      elsif control_tx_assertaddr    = '1' then bus_addr <= register_tx;
      end if;
   end process p_bus_addr;

   p_bus_main : process (all)
   begin
      bus_main <= (others => 'U');
      if    control_reg_a_assert     = '1' then bus_main <= register_a;
      elsif control_reg_b_assert     = '1' then bus_main <= register_b;
      elsif control_reg_c_assert     = '1' then bus_main <= register_c;
      elsif control_reg_d_assert     = '1' then bus_main <= register_d;
--      elsif control_reg_const_assert = '1' then bus_main <= register_const;
      elsif control_reg_tl_assert    = '1' then bus_main <= register_tx(7 downto 0);
      elsif control_reg_th_assert    = '1' then bus_main <= register_tx(15 downto 8);
--      elsif control_alu_assert       = '1' then bus_main <= alu_mainbus;
--      elsif control_dev9_assert      = '1' then bus_main <= dev9;
--      elsif control_dev10_assert     = '1' then bus_main <= dev10;
--      elsif control_dev11_assert     = '1' then bus_main <= dev11;
--      elsif control_dev12_assert     = '1' then bus_main <= dev12;
--      elsif control_dev13_assert     = '1' then bus_main <= dev13;
--      elsif control_dev14_assert     = '1' then bus_main <= dev14;
--      elsif control_membridge_assert = '1' then bus_main <= membridge;
      end if;
   end process p_bus_main;


   ----------------------------------
   -- Instantiate Bus Control Logic
   ----------------------------------

   control_reg_a_assert     <= '1' when mainbus_assert = "0001" else '0';
   control_reg_b_assert     <= '1' when mainbus_assert = "0010" else '0';
   control_reg_c_assert     <= '1' when mainbus_assert = "0011" else '0';
   control_reg_d_assert     <= '1' when mainbus_assert = "0100" else '0';
   control_reg_const_assert <= '1' when mainbus_assert = "0101" else '0';
   control_reg_tl_assert    <= '1' when mainbus_assert = "0110" else '0';
   control_reg_th_assert    <= '1' when mainbus_assert = "0111" else '0';
   control_alu_assert       <= '1' when mainbus_assert = "1000" else '0';
   control_dev9_assert      <= '1' when mainbus_assert = "1001" else '0';
   control_dev10_assert     <= '1' when mainbus_assert = "1010" else '0';
   control_dev11_assert     <= '1' when mainbus_assert = "1011" else '0';
   control_dev12_assert     <= '1' when mainbus_assert = "1100" else '0';
   control_dev13_assert     <= '1' when mainbus_assert = "1101" else '0';
   control_dev14_assert     <= '1' when mainbus_assert = "1110" else '0';
   control_membridge_assert <= '1' when mainbus_assert = "1110" else '0';

   control_reg_a_load       <= '1' when mainbus_load = "0001" else '0';
   control_reg_b_load       <= '1' when mainbus_load = "0010" else '0';
   control_reg_c_load       <= '1' when mainbus_load = "0011" else '0';
   control_reg_d_load       <= '1' when mainbus_load = "0100" else '0';
   control_reg_const_load   <= '1' when mainbus_load = "0101" else '0';
   control_reg_tl_load      <= '1' when mainbus_load = "0110" else '0';
   control_reg_th_load      <= '1' when mainbus_load = "0111" else '0';
   control_alu_load         <= '1' when mainbus_load = "1000" else '0';
   control_dev9_load        <= '1' when mainbus_load = "1001" else '0';
   control_dev10_load       <= '1' when mainbus_load = "1010" else '0';
   control_dev11_load       <= '1' when mainbus_load = "1011" else '0';
   control_dev12_load       <= '1' when mainbus_load = "1100" else '0';
   control_dev13_load       <= '1' when mainbus_load = "1101" else '0';
   control_dev14_load       <= '1' when mainbus_load = "1110" else '0';
   control_membridge_load   <= '1' when mainbus_load = "1110" else '0';

   control_pcra0_inc        <= '1' when inc_pcra = "00" else '0';
   control_pcra1_inc        <= '1' when inc_pcra = "01" else '0';

   control_sp_inc           <= '1' when inc_spsidi = "01" else '0';
   control_si_inc           <= '1' when inc_spsidi = "10" else '0';
   control_di_inc           <= '1' when inc_spsidi = "11" else '0';

   control_pcra0_assertxfer <= '1' when xfer_assert = "001" else '0';
   control_pcra1_assertxfer <= '1' when xfer_assert = "010" else '0';
   control_sp_assertxfer    <= '1' when xfer_assert = "011" else '0';
   control_si_assertxfer    <= '1' when xfer_assert = "100" else '0';
   control_di_assertxfer    <= '1' when xfer_assert = "101" else '0';
   control_tx_assertxfer    <= '1' when xfer_assert = "110" else '0';

   control_pcra0_loadxfer   <= '1' when xfer_loaddec = "0001" else '0';
   control_pcra1_loadxfer   <= '1' when xfer_loaddec = "0010" else '0';
   control_sp_loadxfer      <= '1' when xfer_loaddec = "0011" else '0';
   control_si_loadxfer      <= '1' when xfer_loaddec = "0100" else '0';
   control_di_loadxfer      <= '1' when xfer_loaddec = "0101" else '0';
   control_tx_loadxfer      <= '1' when xfer_loaddec = "0110" else '0';
   control_pcra0_dec        <= '1' when xfer_loaddec = "1001" else '0';
   control_pcra1_dec        <= '1' when xfer_loaddec = "1010" else '0';
   control_sp_dec           <= '1' when xfer_loaddec = "1011" else '0';
   control_si_dec           <= '1' when xfer_loaddec = "1100" else '0';
   control_di_dec           <= '1' when xfer_loaddec = "1101" else '0';

   control_pcra0_assertaddr <= '1' when addrsel = "001" else '0';
   control_pcra1_assertaddr <= '1' when addrsel = "010" else '0';
   control_sp_assertaddr    <= '1' when addrsel = "011" else '0';
   control_si_assertaddr    <= '1' when addrsel = "100" else '0';
   control_di_assertaddr    <= '1' when addrsel = "101" else '0';
   control_tx_assertaddr    <= '1' when addrsel = "110" else '0';

   inc_pcra <= stage2(R_PIPE2_BUSREQUEST) & flags(C_FLAGS_PCRA_FLIP);
   flags(C_FLAGS_PCRA_FLIP) <= stage2(R_PIPE2_PCRA_FLIP);
   flags(C_FLAGS_RESET)     <= rst_i;

   mainbus_assert <= stage2(R_PIPE2_MAIN_ASSERT);
   mainbus_load   <= stage2(R_PIPE2_MAIN_LOAD);
   inc_spsidi     <= stage2(R_PIPE2_INC_SPSIDI);
   addrsel        <= stage2(R_PIPE2_ADDRSEL);


   ----------------------------------
   -- Instantiate Pipeline ROMs
   ----------------------------------

   pipe_rom_addr <= flags & instr;

   i_pipeline_roms : entity work.pipeline_roms
      port map (
         clk_i    => clk_i,
         addr_i   => pipe_rom_addr,
         stage1_o => stage1,
         stage2_o => stage2
      );


--   ----------------------------------
--   -- Instantiate ALU
--   ----------------------------------
--
--   i_alu : entity work.alu
--      port map (
--         clk_i       => clk_i,
--         lhs_i       => alu_lhs,
--         rhs_i       => alu_rhs,
--         oper_i      => alu_oper,
--         flags_in_i  => alu_flags_in,
--         result_o    => alu_result,
--         flags_out_o => alu_flags_out
--      ); -- i_alu



   addr_o  <= bus_addr;
   wr_en_o <= '0';
   instr   <= rd_data_i;

end architecture synthesis;

