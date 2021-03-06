library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity mips_top is
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
    extDataW  : out byte_t
    );
end mips_top;

architecture structural of mips_top is

  -----------------------------------------------------------------------------
  -- The mips 5-stage pipeline
  -----------------------------------------------------------------------------
  component mips_core is
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
  end component mips_core;

  -----------------------------------------------------------------------------
  -- The memory controller
  -----------------------------------------------------------------------------
  component memctrl is
    port (
      clk       : in  bit_t;
      rst       : in  bit_t;
      dataAck   : in  bit_t;
      extRdy    : in  bit_t;
      IAddr     : in  word_t;
      dAddr     : in  word_t;
      dWData    : in  word_t;
      dRw       : in  bit_t;
      dReq      : in  bit_t;
      memHold   : in  bit_t;
      flushData : in  bit_t;
      memDataR  : in  word_t;
      memAddr   : out word_t;
      memReq    : out bit_t;
      memRw     : out bit_t;
      memDataW  : out word_t;
      coreHold  : out bit_t;
      IData     : out word_t;
      dRData    : out word_t);
  end component memctrl;

  -----------------------------------------------------------------------------
  -- The serial/parallel converter
  -----------------------------------------------------------------------------
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
      intReq   : in  bit_t;
      intRw    : in  bit_t;
      intDataW : in  word_t;
      intDataR : out word_t;
      intAck   : out bit_t;
      intAddr  : in  word_t;
      rdy      : out bit_t);
  end component serial_ctrl;

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------

  signal IAddri     : word_t;
  signal dAddri     : word_t;
  signal dWDatai    : word_t;
  signal dRwi       : bit_t;
  signal dReqi      : bit_t;
  signal flushDatai : bit_t;
  signal coreHoldi  : bit_t;
  signal iRDatai    : word_t;
  signal dRDatai    : word_t;

  signal extHoldi  : bit_t;
  signal extDataRi : byte_t;
  signal extReqi   : bit_t;
  signal extRwi    : bit_t;
  signal extAddri  : byte_t;
  signal extDataWi : byte_t;
  signal extAcki   : bit_t;
  signal intReqi   : bit_t;
  signal intRwi    : bit_t;
  signal intDataWi : word_t;
  signal intDataRi : word_t;
  signal intAcki   : bit_t;
  signal intAddri  : word_t;
  signal rdyi      : bit_t;
begin

  -----------------------------------------------------------------------------
  -- Inputs
  -----------------------------------------------------------------------------
  extHoldi <= extHold;

  flushDatai <= flushData;

  extDataRi <= extDataR;

  -----------------------------------------------------------------------------
  -- Outputs
  -----------------------------------------------------------------------------
  extAddr <= extAddri;

  extReq <= extReqi;

  extRw <= extRwi;

  extDataW <= extDataWi;

  extAck <= extAcki;

  -----------------------------------------------------------------------------
  -- The mips pipeline instance
  -----------------------------------------------------------------------------
  mips_core_1 : mips_core
    port map (
      clk        => clk,
      rst        => rst,
      iRdata     => IRdatai,
      memHold    => coreHoldi,
      dReadData  => dRDatai,
      iAddr      => IAddri,
      dAddr      => dAddri,
      dRw_n      => dRwi,
      dReq       => dReqi,
      dWriteData => dWDatai);

  -----------------------------------------------------------------------------
  -- The memory controller instance
  -----------------------------------------------------------------------------
  memctrl_1 : memctrl
    port map (
      clk       => clk,
      rst       => rst,
      dataAck   => intAcki,
      extRdy    => rdyi,
      iaddr     => IAddri,
      daddr     => dAddri,
      dWData    => dWDatai,
      dRw       => dRwi,
      dReq      => dReqi,
      memHold   => extHoldi,
      flushData => flushDatai,
      memDataR  => intDataRi,
      memAddr   => intAddri,
      memReq    => intReqi,
      memRw     => intRwi,
      memDataW  => intDataWi,
      coreHold  => coreHoldi,
      iData     => iRDatai,
      dRData    => dRDatai);

  -----------------------------------------------------------------------------
  -- The serialparallel converter instance
  -----------------------------------------------------------------------------
  serial_ctrl_1 : serial_ctrl
    port map (
      clk      => clk,
      rst      => rst,
      extHold  => extHoldi,
      extDataR => extDataRi,
      extReq   => extReqi,
      extRw    => extRwi,
      extAddr  => extAddri,
      extDataW => extDataWi,
      extAck   => extAcki,
      intReq   => intReqi,
      intRw    => intRwi,
      intDataW => intDataWi,
      intDataR => intDataRi,
      intAck   => intAcki,
      intAddr  => intAddri,
      rdy      => rdyi);

end structural;

