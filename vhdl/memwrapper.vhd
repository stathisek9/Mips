library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.all;
use work.types.all;

entity memwrapper is

  port (
    clk    : in  bit_t;
    wData  : in  word_t;
    addr   : in  word_t;
    rw_n   : in  bit_t;
    memReq : in  bit_t;
    rdy    : out bit_t;
    rData  : out word_t);

end memwrapper;

architecture behavioral of memwrapper is

  component ST_SPHDL_160x32m8_L
    generic (
      Words                     : natural;
      Bits                      : natural;
      Addr                      : natural;
      mux                       : natural;
      ConfigFault               : boolean;
      max_faults                : natural;
      Fault_file_name           : string;
      MEM_INITIALIZE            : boolean;
      BinaryInit                : integer;
      InitFileName              : string;
      Corruption_Read_Violation : boolean;
      InstancePath              : string;
      Debug_mode                : string);
    port (
      Q       : out std_logic_vector(31 downto 0);
      RY      : out std_logic;
      CK      : in  std_logic;
      CSN     : in  std_logic;
      TBYPASS : in  std_logic;
      WEN     : in  std_logic;
      A       : in  std_logic_vector(7 downto 0);
      D       : in  std_logic_vector(31 downto 0));
  end component;

  constant Words                     : natural := 160;
  constant Bits                      : natural := 32;
  constant AddrSIZE                  : natural := 8;
  constant mux                       : natural := 8;
  constant ConfigFault               : boolean := false;
  constant max_faults                : natural := 20;
  constant Fault_file_name           : string  := "ST_SPHDL_160x32m8_L_faults.txt";
  constant MEM_INITIALIZE            : boolean := false;
  constant BinaryInit                : integer := 0;
  constant InitFileName              : string  := "ST_SPHDL_160x32m8_L.cde";
  constant Corruption_Read_Violation : boolean := true;
  constant InstancePath              : string  := "ST_SPHDL_160x32m8_L";
  constant Debug_mode                : string  := "ALL_WARNING_MODE";

  signal rdy_i   : bit_t;
  signal CSN     : bit_t;
  signal TBYPASS : bit_t;
  signal A       : memAddr_t;
  
  
begin  -- behavioral
  ST_SPHDL_160x32m8_L_1 : ST_SPHDL_160x32m8_L
    generic map (
      Words                     => Words,
      Bits                      => Bits,
      Addr                      => AddrSIZE,
      mux                       => mux,
      ConfigFault               => ConfigFault,
      max_faults                => max_faults,
      Fault_file_name           => Fault_file_name,
      MEM_INITIALIZE            => MEM_INITIALIZE,
      BinaryInit                => BinaryInit,
      InitFileName              => InitFileName,
      Corruption_Read_Violation => Corruption_Read_Violation,
      InstancePath              => InstancePath,
      Debug_mode                => Debug_mode)
    port map (
      Q       => rData,
      RY      => rdy_i,
      CK      => clk,
      CSN     => CSN,
      TBYPASS => TBYPASS,
      WEN     => rw_n,
      A       => A,
      D       => wData);

  rdy <= rdy_i;

  CSN <= not(memReq);

  A <= Addr(9 downto 2);

  TBYPASS <= '0';
end behavioral;
