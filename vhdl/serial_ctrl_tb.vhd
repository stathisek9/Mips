-------------------------------------------------------------------------------
-- Title      : Testbench for design "serial_ctrl"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : serial_ctrl_tb.vhd
-- Author     :   <HenkeH@HENKEH-DATOR>
-- Company    : 
-- Created    : 2015-05-31
-- Last update: 2015-05-31
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2015 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-05-31  1.0      HenkeH  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.types.all;

-------------------------------------------------------------------------------

entity serial_ctrl_tb is

end entity serial_ctrl_tb;

-------------------------------------------------------------------------------

architecture serial_tb of serial_ctrl_tb is

  component serial_ctrl is
    port (
      clk      : in  bit_t;
      rst      : in  bit_t;
      extHold  : in  bit_t;
      extDataR : in  byte_t;
      extReq   : out bit_t;
      extRw    : out bit_t;
      extAddr  : out byte_t;
      extDataW : out byte_t;
      extAck   : out bit_t;
      extBurst : out bit_t;
      intReq   : in  bit_t;
      intRw    : in  bit_t;
      intDataW : in  word_t;
      intDataR : out word_t;
      intAck   : out bit_t;
      intBurst : in  bit_t;
      intAddr  : in  word_t;
      intRdy   : out bit_t);
  end component serial_ctrl;
  
  -- component ports
  signal clk      : bit_t;
  signal rst      : bit_t;
  signal extHold  : bit_t;
  signal extDataR : byte_t;
  signal extReq   : bit_t;
  signal extRw    : bit_t;
  signal extAddr  : byte_t;
  signal extDataW : byte_t;
  signal extAck   : bit_t;
  signal extBurst : bit_t;
  signal intReq   : bit_t;
  signal intRw    : bit_t;
  signal intDataW : word_t;
  signal intDataR : word_t;
  signal intAck   : bit_t;
  signal intBurst : bit_t;
  signal intAddr  : word_t;
  signal intRdy   : bit_t;

  -- clock
  constant clk_period : time := 10 ns;

begin  -- architecture serial_tb

  -- component instantiation
  DUT : serial_ctrl
    port map (
      clk      => clk,
      rst      => rst,
      extHold  => extHold,
      extDataR => extDataR,
      extReq   => extReq,
      extRw    => extRw,
      extAddr  => extAddr,
      extDataW => extDataW,
      extAck   => extAck,
      extBurst => extBurst,
      intReq   => intReq,
      intRw    => intRw,
      intDataW => intDataW,
      intDataR => intDataR,
      intAck   => intAck,
      intBurst => intBurst,
      intAddr  => intAddr,
      intRdy   => intRdy);

  -- clock generation
  CLK_PROC : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;
  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here
    rst <= '1';
    extHold <= '0';
    extDataR <= BYTE_ZERO;
    intReq <= '0';
    intRw <= '1';
    intDataW <= WORD_ZERO;
    intBurst <= '0';
    intAddr <= WORD_ZERO;
    wait for clk_period;
    wait until Clk = '1';
    rst <= '0';

    intAddr <= x"01001110";
    intDataW <= x"BBA00010";

    wait for clk_period;
    intReq <= '1';
    intRw <= '0';

    wait until intAck = '1';
    intReq <= '0';
    intRw <= '1';
    wait for clk_period;
    intAddr <= x"f1AC0010";
    intReq <= '1';
    wait for clk_period*4;
    extDataR <= x"01";
    wait for clk_period;
    extDataR <= x"ff";
    wait for clk_period;
    extDataR <= x"AC";
    wait for clk_period;
    extDataR <= x"11";
    intAddr <= x"ff009845";
    wait for clk_period*5;
    extDataR <= x"13";
    wait for clk_period;
    extDataR <= x"37";
    wait for clk_period;
    extDataR <= x"15";
    wait for clk_period;
    extDataR <= x"55";
    wait for clk_period;
    intrw <= '0';
    intAddr <= x"ABCDEF03";
    intDataW <= x"ABBADEF1";
    wait for clk_period;

    wait until extAck = '1';
    intReq <= '0';

    wait;
  end process WaveGen_Proc;



end architecture serial_tb;

-------------------------------------------------------------------------------

configuration serial_ctrl_tb_serial_tb_cfg of serial_ctrl_tb is
  for serial_tb
  end for;
end serial_ctrl_tb_serial_tb_cfg;

-------------------------------------------------------------------------------
