-------------------------------------------------------------------------------
-- Title      : Testbench for design "memctrl"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : memctrl_tb.vhd
-- Author     : Henrik Ljunger  <ael10hlj@gunne.fransg>
-- Company    : 
-- Created    : 2015-05-26
-- Last update: 2015-05-27
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2015 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-05-26  1.0      ael10hlj        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

-------------------------------------------------------------------------------

entity memctrl_tb is

end memctrl_tb;

-------------------------------------------------------------------------------

architecture arch_memctrl_tb of memctrl_tb is

  component memctrl
    port (
      clk      : in    bit_t;
      rst      : in    bit_t;
      iaddr    : in    word_t;
      daddr    : in    word_t;
      dWData   : in    word_t;
      dRw_n    : in    bit_t;
      dReq     : in    bit_t;
      RAMHold  : in    bit_t;
      RAMAddr  : out   word_t;
      RAMreq   : out   bit_t;
      RAMrw_n  : out   bit_t;
      RAMDATA  : inout word_t;
      coreHold : out   bit_t;
      iData    : out   word_t;
      dRData   : out   word_t);
  end component;

  component mem2 is
    generic (
      filename   : string;
      memsize    : natural;
      n          : natural;
      Tclock     : time;
      read_delay : time;
      mem_load   : string;
      base_addr  : word_t);
    port (
      clk   : in    bit_t;
      reset : in    bit_t;
      addr  : in    word_t;
      data  : inout word_t;
      rw    : in    bit_t;
      req   : in    bit_t;
      hold  : out   bit_t);
  end component mem2;

  constant filename   : string  := "fib1.log";
  constant memsize    : natural := 2048;
  constant n          : natural := 0;
  constant Tclock     : time    := 50 ns;
  constant read_delay : time    := 0 ns;
  constant mem_loadI  : string  := "inst";
  constant base_addrI : word_t  := X"00400000";
  constant mem_loadD  : string  := "data";
  constant base_addrD : word_t  := X"10010000";

  -- component ports
  signal clk      : bit_t;
  signal rst      : bit_t;
  signal iaddr    : word_t;
  signal daddr    : word_t;
  signal dWData   : word_t;
  signal dRw_n    : bit_t;
  signal dReq     : bit_t;
  signal RAMHold  : bit_t;
  signal RAMAddr  : word_t;
  signal RAMreq   : bit_t;
  signal RAMrw_n  : bit_t;
  signal RAMDATA  : word_t;
  signal coreHold : bit_t;
  signal iData    : word_t;
  signal dRData   : word_t;

  signal ddata, idata_i                      : word_t;
  signal drw, irw, ireq, dreqi, ihold, dhold : bit_t;
  signal iaddri, daddri                      : word_t;

  -- clock
  constant clk_period : time := 10 ns;


begin  -- memctrl_tb

  -- component instantiation
  DUT : memctrl
    port map (
      clk      => clk,
      rst      => rst,
      iaddr    => iaddr,
      daddr    => daddr,
      dWData   => dWData,
      dRw_n    => dRw_n,
      dReq     => dReq,
      RAMHold  => RAMHold,
      RAMAddr  => RAMAddr,
      RAMreq   => RAMreq,
      RAMrw_n  => RAMrw_n,
      RAMDATA  => RAMDATA,
      coreHold => coreHold,
      iData    => iData,
      dRData   => dRData);

  mem2_I : mem2
    generic map (
      filename   => filename,
      memsize    => memsize,
      n          => n,
      Tclock     => Tclock,
      read_delay => read_delay,
      mem_load   => mem_loadI,
      base_addr  => base_addrI)
    port map (
      clk   => clk,
      reset => rst,
      addr  => iaddri,
      data  => idata_i,
      rw    => irw,
      req   => ireq,
      hold  => ihold);

  mem2_D : mem2
    generic map (
      filename   => filename,
      memsize    => memsize,
      n          => n,
      Tclock     => Tclock,
      read_delay => read_delay,
      mem_load   => mem_loadD,
      base_addr  => base_addrD)
    port map (
      clk   => clk,
      reset => rst,
      addr  => daddri,
      data  => ddata,
      rw    => drw,
      req   => dreqi,
      hold  => dhold);

  CLK_PROC : process
  begin  -- process CLK_PROC
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process CLK_PROC;

  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here
    rst     <= '1';
    iaddr   <= WORD_ZERO;
    daddr   <= WORD_ZERO;
    dreq    <= '1';
    dRw_n   <= '1';
    RAMHold <= '0';
    dWData  <= WORD_ZERO;
    wait for clk_period;
    wait until Clk = '1';
    rst     <= '0';

    wait until coreHold = '0';
    iaddr <= x"0040000C";
    daddr <= x"10010000";
    wait for clk_period;
    iaddr <= x"0040003C";
    daddr <= x"10010004";
    wait for clk_period;
    daddr <= x"10010008";
    dWData <= x"0000ffff";
    drw_n <= '0';
    wait for clk_period;
    daddr <= x"1001000C";
    dWData <= x"00001001";
    wait for clk_period;
    daddr <= x"10010010";
    dWData <= x"10100101";
    wait for clk_period;
    drw_n <= '1';
    daddr <= x"1001000C";
    wait for clk_period;
    daddr <= x"10010010";
    wait for clk_period;
    daddr <= x"10010008";

    wait;
  end process WaveGen_Proc;

  MEM_PROC : process(RAMAddr, RAMDATA, RAMreq, RAMrw_n, ddata, idata_i)
  begin
    ddata   <= (others => 'Z');
    idata_i <= (others => 'Z');
    RAMDATA <= (others => 'Z');
    ireq    <= '0';
    irw     <= '1';
    dreqi   <= '0';
    drw     <= '1';
    iaddri  <= WORD_ZERO;
    daddri  <= WORD_ZERO;

    if RAMreq = '1' then
      if RAMAddr < base_addrD then
        RAMDATA <= idata_i;
        iaddri  <= RAMAddr;
        ireq <= '1';
      else
        dreqi <= '1';
        if RAMrw_n = '1' then
          RAMDATA <= ddata;
          daddri  <= RAMAddr;
        else
          ddata  <= RAMDATA;
          daddri <= RAMAddr;

        end if;
      end if;
    end if;


  end process MEM_PROC;



end arch_memctrl_tb;

