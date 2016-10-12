library ieee, IO65LPHVT_SF_1V8_50A_7M4X0Y2Z;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IO65LPHVT_SF_1V8_50A_7M4X0Y2Z.all;
use work.types.all;

entity mips_topp is
  
  port (
    clk       : inout bit_t;
    rst       : inout bit_t;
    dataFlush : inout bit_t;
    RAMhold   : inout bit_t;
    RAMreq    : inout bit_t;
    RAMrw_n   : inout bit_t;
    RAMack    : inout bit_t;
    RAMaddr   : inout byte_t;
    RAMdataw  : inout byte_t;
    RAMdatar  : inout byte_t
    );

end mips_topp;

architecture structural of mips_topp is

  component mips_top
    port (
      clk       : in  bit_t;
      rst       : in  bit_t;
      extHold   : in  bit_t;
      flushData : in  bit_t;
      extDataR  : in  byte_t;
      extAck    : out bit_t;
      extAddr   : out byte_t;
      extReq    : out bit_t;
      extRw     : out bit_t;
      extDataW  : out byte_t);
  end component;

  component BD2SCARUDQP_1V8_SF_LIN
    port(ZI   : out   std_logic;
         A    : in    std_logic;
         EN   : in    std_logic;
         TA   : in    std_logic;
         TEN  : in    std_logic;
         TM   : in    std_logic;
         PUN  : in    std_logic;
         PDN  : in    std_logic;
         HYST : in    std_logic;
         IO   : inout std_logic);       -- Pad Surface
  end component;

  signal HIGH : bit_t;
  signal LOW  : bit_t;

  signal clki       : bit_t;
  signal rsti       : bit_t;
  signal RAMholdi   : bit_t;
  signal dataFlushi : bit_t;
  signal RAMacki    : bit_t;
  signal RAMreqi    : bit_t;
  signal RAMrwi     : bit_t;
  signal RAMaddri   : byte_t;
  signal RAMdatari  : byte_t;
  signal RAMdatawi  : byte_t;

begin  -- structural

  HIGH <= '1';

  LOW <= '0';
  -----------------------------------------------------------------------------
  -- INPUT
  -----------------------------------------------------------------------------
  clkpad : BD2SCARUDQP_1V8_SF_LIN
    port map (IO  => clk, ZI => clki, A => LOW, EN => HIGH, TA => LOW,
              TEN => HIGH, TM => LOW, PUN => LOW, PDN => LOW, HYST => LOW);

  rstpad : BD2SCARUDQP_1V8_SF_LIN
    port map (IO  => rst, ZI => rsti, A => LOW, EN => HIGH, TA => LOW,
              TEN => HIGH, TM => LOW, PUN => LOW, PDN => LOW, HYST => LOW);

  RAMholdpad : BD2SCARUDQP_1V8_SF_LIN
    port map (IO  => RAMhold, ZI => RAMholdi, A => LOW, EN => HIGH, TA => LOW,
              TEN => HIGH, TM => LOW, PUN => LOW, PDN => LOW, HYST => LOW);

  dataFlushpad : BD2SCARUDQP_1V8_SF_LIN
    port map (IO  => dataFlush, ZI => dataFlushi, A => LOW, EN => HIGH, TA => LOW,
              TEN => HIGH, TM => LOW, PUN => LOW, PDN => LOW, HYST => LOW);
  RAM_DATA_PADSr : for i in 0 to 7 generate
    RAMdatapad : BD2SCARUDQP_1V8_SF_LIN
      port map (IO  => RAMdatar(i), ZI => RAMdatari(i), A => LOW, EN => HIGH, TA => LOW,
                TEN => HIGH, TM => LOW, PUN => LOW, PDN => LOW, HYST => LOW);
  end generate RAM_DATA_PADSr;

  ----------------------------------------------------------------------------
  -- OUTPUT
  ----------------------------------------------------------------------------
  RAMreqpad : BD2SCARUDQP_1V8_SF_LIN
    port map (IO  => RAMreq, A => RAMreqi, EN => LOW, TA => LOW,
              TEN => LOW, TM => LOW, PUN => HIGH, PDN => HIGH, HYST => LOW);
  RAMackpad : BD2SCARUDQP_1V8_SF_LIN
    port map (IO  => RAMack, A => RAMacki, EN => LOW, TA => LOW,
              TEN => LOW, TM => LOW, PUN => HIGH, PDN => HIGH, HYST => LOW);


  RAMrwpad : BD2SCARUDQP_1V8_SF_LIN
    port map (IO  => RAMrw_n, A => RAMrwi, EN => LOW, TA => LOW,
              TEN => LOW, TM => LOW, PUN => HIGH, PDN => HIGH, HYST => LOW);

  RAM_ADDR_PADS : for i in 0 to 7 generate
    RAMaddrpad : BD2SCARUDQP_1V8_SF_LIN
      port map (IO  => RAMaddr(i), A => RAMaddri(i), EN => LOW, TA => LOW,
                TEN => LOW, TM => LOW, PUN => HIGH, PDN => HIGH, HYST => LOW);
  end generate RAM_ADDR_PADS;

  RAM_DATA_PADSw : for i in 0 to 7 generate
    RAMdatapadw : BD2SCARUDQP_1V8_SF_LIN
      port map (IO  => RAMdataw(i), A => RAMdatawi(i), EN => LOW, TA => LOW,
                TEN => LOW, TM => LOW, PUN => HIGH, PDN => HIGH, HYST => LOW);
  end generate RAM_DATA_PADSw;

  mips_top_1 : mips_top
    port map (
      clk       => clki,
      rst       => rsti,
      extHold   => RamHoldi,
      flushData => dataFlushi,
      extDataR  => RAMDataRi,
      extAck    => RAMacki,
      extAddr   => RAMAddri,
      extReq    => RAMReqi,
      extRw     => RAMRwi,
      extDataW  => RAMDataWi);

end structural;
