-------------------------------------------------------------------------------
-- Title      : Testbench for design "mips_core"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : mips_core_tb.vhd
-- Author     : Henrik Ljunger  <ael10hlj@kalv.fransg.eit.lth.se>
-- Company    : 
-- Created    : 2015-05-04
-- Last update: 2015-05-26
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2015 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-05-04  1.0      ael10hlj        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

-------------------------------------------------------------------------------

entity mips_core_tb is

end mips_core_tb;

-------------------------------------------------------------------------------

architecture coreTest of mips_core_tb is

  component mips_core
    port (
      clk        : in  bit_t;
      rst        : in  bit_t;
      iRdata     : in  word_t;
      memHold    : in  bit_t;
      dReadData  : in  word_t;
      iAddr      : out word_t;
      dAddr      : out word_t;
      dRw_n      : out bit_t;
      dReq       : out bit_t;
      dWriteData : out word_t);
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

  signal rInstruction, nextInstruction : word_t;
  signal rData, nextData               : word_t;

  signal clk : bit_t;
  signal rst : bit_t;

  signal iRdata : word_t;
  signal iaddr  : word_t;
  signal idata  : word_t;
  signal irw    : bit_t;
  signal ireq   : bit_t;
  signal ihold  : bit_t;

  signal memhold : bit_t;

  signal dReadData  : word_t;
  signal dWriteData : word_t;
  signal daddr      : word_t;
  signal ddata      : word_t;
  signal drw_n      : bit_t;
  signal dreq       : bit_t;
  signal dhold      : bit_t;

  signal dreq_i, drw_n_i : bit_t;
  signal flushAddr       : word_t;
  signal daddr_i         : word_t;

  signal dmemData : word_t;
  signal readData : bit_t;

  constant clk_period : time := 50 ns;
  -- clock

  constant filename   : string  := "branch_test.log";
  constant memsize    : natural := 2048;
  constant n          : natural := 0;
  constant Tclock     : time    := 50 ns;
  constant read_delay : time    := 0 ns;
  constant mem_loadI  : string  := "inst";
  constant base_addrI : word_t  := X"00400000";
  constant mem_loadD  : string  := "data";
  constant base_addrD : word_t  := X"10010000";

begin  -- coreTest

  -- component instantiation
  mips_core_1 : mips_core
    port map (
      clk        => clk,
      rst        => rst,
      iRdata     => iRdata,
      memHold    => memHold,
      dReadData  => dReadData,
      iAddr      => iAddr,
      dAddr      => dAddr,
      dRw_n      => dRw_n,
      dReq       => dReq,
      dWriteData => dWriteData);

  -- clock generation
  CLK_PROC : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process CLK_PROC;



  -- waveform generation
  WaveGen_Proc : process
    variable tmpaddr : word_t := base_addrD;
  begin
    -- insert signal assignments here
    rst      <= '1';
    memhold  <= '0';
    readData <= '0';
    wait for clk_period;
    wait until Clk = '1';
    rst      <= '0';
    wait for 20 us;
    readData <= '1';
    MEM_READ_LOOP : for i in 0 to 32 loop
      flushAddr <= tmpaddr;
      wait for clk_period;
      tmpaddr   := std_logic_vector(unsigned(tmpaddr) + 4);
    end loop;  -- i

    wait;
  end process WaveGen_Proc;

  REG_PROC : process(clk)
  begin
    if clk = '1' and clk'event then
      rInstruction <= nextInstruction;
      rData        <= nextData;
      if rst = '1' then
        rInstruction <= (others => '0');
        rData        <= (others => '0');
      end if;
    end if;
  end process REG_PROC;

  MEM_TO_CORE_PROC : process(rData, rInstruction)
  begin
    iRdata    <= rInstruction;
    dReadData <= rData;
  end process MEM_TO_CORE_PROC;

  I_PROC : process(idata)
  begin
    irw             <= '1';
    ireq            <= '1';
    idata           <= (others => 'Z');
    nextInstruction <= idata;
  end process I_PROC;

  D_PROC : process(dAddr, dWriteData, ddata, dreq, drw_n, flushAddr, readData)
    -- variable tmpAddr : word_t := base_addrD;
  begin
    ddata    <= (others => 'Z');
    nextData <= (others => '0');
    daddr_i  <= dAddr;
    dreq_i   <= '1';
    drw_n_i  <= drw_n;
    if readData = '1' then
      dAddr_i  <= flushAddr;
      dreq_i   <= '1';
      drw_n_i  <= '1';
      nextData <= ddata;
    else
      if dreq = '1' then
        if drw_n = '1' then             -- read
          nextData <= ddata;
        elsif drw_n = '0' then          -- write
          ddata <= dWriteData;
        end if;
      end if;
    end if;
  end process D_PROC;

  memI : mem2
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
      addr  => iaddr,
      data  => idata,
      rw    => irw,
      req   => ireq,
      hold  => ihold);

  memD : mem2
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
      addr  => daddr_i,
      data  => ddata,
      rw    => drw_n_i,
      req   => dreq_i,
      hold  => dhold);
end coreTest;

-------------------------------------------------------------------------------

configuration mips_core_tb_coreTest_cfg of mips_core_tb is
  for coreTest
  end for;
end mips_core_tb_coreTest_cfg;

-------------------------------------------------------------------------------
