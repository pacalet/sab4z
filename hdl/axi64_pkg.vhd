--
-- Copyright (C) Telecom ParisTech
-- 
-- This file must be used under the terms of the CeCILL. This source
-- file is licensed as described in the file COPYING, which you should
-- have received as part of this distribution. The terms are also
-- available at:
-- http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
--

library ieee;
use ieee.std_logic_1164.all;

package axi64_pkg is

  ------------------------------------------------
  -- Bit-widths of AXI fields as seen by the PL --
  ------------------------------------------------

  -- Common to all AXI interfaces
  constant axi_l: positive := 8;  -- len bit width
  constant axi_b: positive := 2;  -- burst bit width
  constant axi_p: positive := 3;  -- prot bit width
  constant axi_c: positive := 4;  -- cache bit width
  constant axi_r: positive := 2;  -- resp bit width
  constant axi_q: positive := 4;  -- qos bit width
  constant axi_s: positive := 3;  -- size bit width
  constant axi_m: positive := 8;  -- strb bit width
  constant axi_d: positive := 8 * axi_m; -- data bit width

  constant axi_af: positive := 31; -- address bit width (full AXI interfaces)
  constant axi_al: positive := 12; -- address bit width (AXI lite interface)
  constant axi_is: positive := 16; -- id bit width (slave interfaces)
  constant axi_im: positive := 6;  -- id bit width (master interface)

  constant axi_resp_okay:   std_ulogic_vector(axi_r - 1 downto 0) := "00";
  constant axi_resp_exokay: std_ulogic_vector(axi_r - 1 downto 0) := "01";
  constant axi_resp_slverr: std_ulogic_vector(axi_r - 1 downto 0) := "10";
  constant axi_resp_decerr: std_ulogic_vector(axi_r - 1 downto 0) := "11";

  constant axi_burst_fixed: std_ulogic_vector(axi_b - 1 downto 0) := "00";
  constant axi_burst_incr:  std_ulogic_vector(axi_b - 1 downto 0) := "01";
  constant axi_burst_wrap:  std_ulogic_vector(axi_b - 1 downto 0) := "10";
  constant axi_burst_res:   std_ulogic_vector(axi_b - 1 downto 0) := "11";

  -----------------------------------------------------------
  -- AXI ports. M2S: Master to slave. S2M: Slave to master --
  -----------------------------------------------------------

  type s0_axi_m2s_t is record
    -- Read address channel
    araddr:  std_ulogic_vector(axi_al - 1 downto 0);
    arprot:  std_ulogic_vector(axi_p - 1 downto 0);
    arvalid: std_ulogic;
    -- Read data channel
    rready:  std_ulogic;
    -- Write address channel
    awaddr:  std_ulogic_vector(axi_al - 1 downto 0);
    awprot:  std_ulogic_vector(axi_p - 1 downto 0);
    awvalid: std_ulogic;
    -- Write data channel
    wdata:   std_ulogic_vector(axi_d - 1 downto 0);
    wstrb:   std_ulogic_vector(axi_m - 1 downto 0);
    wvalid:  std_ulogic;
    -- Write response channel
    bready:  std_ulogic;
  end record;

  type s0_axi_s2m_t is record
    -- Read address channel
    arready: std_ulogic;
    -- Read data channel
    rdata:   std_ulogic_vector(axi_d - 1 downto 0);
    rresp:   std_ulogic_vector(axi_r - 1 downto 0);
    rvalid:  std_ulogic;
    -- Write address channel
    awready: std_ulogic;
    -- Write data channel
    wready:  std_ulogic;
    -- Write response channel
    bvalid:  std_ulogic;
    bresp:   std_ulogic_vector(axi_r - 1 downto 0);
  end record;

  type s1_axi_m2s_t is record
    -- Read address channel
    arid:    std_ulogic_vector(axi_is - 1 downto 0);
    araddr:  std_ulogic_vector(axi_af - 1 downto 0);
    arlen:   std_ulogic_vector(axi_l - 1 downto 0);
    arsize:  std_ulogic_vector(axi_s - 1 downto 0);
    arburst: std_ulogic_vector(axi_b - 1 downto 0);
    arlock:  std_ulogic;
    arcache: std_ulogic_vector(axi_c - 1 downto 0);
    arprot:  std_ulogic_vector(axi_p - 1 downto 0);
    arqos:   std_ulogic_vector(axi_q - 1 downto 0);
    arvalid: std_ulogic;
    -- Read data channel
    rready:  std_ulogic;
    -- Write address channel
    awid:    std_ulogic_vector(axi_is - 1 downto 0);
    awaddr:  std_ulogic_vector(axi_af - 1 downto 0);
    awlen:   std_ulogic_vector(axi_l - 1 downto 0);
    awsize:  std_ulogic_vector(axi_s - 1 downto 0);
    awburst: std_ulogic_vector(axi_b - 1 downto 0);
    awlock:  std_ulogic;
    awcache: std_ulogic_vector(axi_c - 1 downto 0);
    awprot:  std_ulogic_vector(axi_p - 1 downto 0);
    awqos:   std_ulogic_vector(axi_q - 1 downto 0);
    awvalid: std_ulogic;
    -- Write data channel
    wdata:   std_ulogic_vector(axi_d - 1 downto 0);
    wstrb:   std_ulogic_vector(axi_m - 1 downto 0);
    wlast:   std_ulogic;
    wvalid:  std_ulogic;
    -- Write response channel
    bready:  std_ulogic;
  end record;

  type s1_axi_s2m_t is record
    -- Read address channel
    arready: std_ulogic;
    -- Read data channel
    rid:     std_ulogic_vector(axi_is - 1 downto 0);
    rdata:   std_ulogic_vector(axi_d - 1 downto 0);
    rresp:   std_ulogic_vector(axi_r - 1 downto 0);
    rlast:   std_ulogic;
    rvalid:  std_ulogic;
    -- Write address channel
    awready: std_ulogic;
    -- Write data channel
    wready:  std_ulogic;
    -- Write response channel
    bid:     std_ulogic_vector(axi_is - 1 downto 0);
    bvalid:  std_ulogic;
    bresp:   std_ulogic_vector(axi_r - 1 downto 0);
  end record;

  type m_axi_m2s_t is record
    -- Read address channel
    arid:    std_ulogic_vector(axi_im - 1 downto 0);
    araddr:  std_ulogic_vector(axi_af - 1 downto 0);
    arlen:   std_ulogic_vector(axi_l - 1 downto 0);
    arsize:  std_ulogic_vector(axi_s - 1 downto 0);
    arburst: std_ulogic_vector(axi_b - 1 downto 0);
    arlock:  std_ulogic;
    arcache: std_ulogic_vector(axi_c - 1 downto 0);
    arprot:  std_ulogic_vector(axi_p - 1 downto 0);
    arqos:   std_ulogic_vector(axi_q - 1 downto 0);
    aruser:  std_ulogic;
    arvalid: std_ulogic;
    -- Read data channel
    rready:  std_ulogic;
    -- Write address channel
    awid:    std_ulogic_vector(axi_im - 1 downto 0);
    awaddr:  std_ulogic_vector(axi_af - 1 downto 0);
    awlen:   std_ulogic_vector(axi_l - 1 downto 0);
    awsize:  std_ulogic_vector(axi_s - 1 downto 0);
    awburst: std_ulogic_vector(axi_b - 1 downto 0);
    awlock:  std_ulogic;
    awcache: std_ulogic_vector(axi_c - 1 downto 0);
    awprot:  std_ulogic_vector(axi_p - 1 downto 0);
    awqos:   std_ulogic_vector(axi_q - 1 downto 0);
    awuser:  std_ulogic;
    awvalid: std_ulogic;
    -- Write data channel
    wdata:   std_ulogic_vector(axi_d - 1 downto 0);
    wstrb:   std_ulogic_vector(axi_m - 1 downto 0);
    wlast:   std_ulogic;
    wvalid:  std_ulogic;
    -- Write response channel
    bready:  std_ulogic;
  end record;

  type m_axi_s2m_t is record
    -- Read address channel
    arready: std_ulogic;
    -- Read data channel
    rid:     std_ulogic_vector(axi_im - 1 downto 0);
    rdata:   std_ulogic_vector(axi_d - 1 downto 0);
    rresp:   std_ulogic_vector(axi_r - 1 downto 0);
    rlast:   std_ulogic;
    rvalid:  std_ulogic;
    -- Write address channel
    awready: std_ulogic;
    -- Write data channel
    wready:  std_ulogic;
    -- Write response channel
    bid:     std_ulogic_vector(axi_im - 1 downto 0);
    bvalid:  std_ulogic;
    bresp:   std_ulogic_vector(axi_r - 1 downto 0);
  end record;

  function to_m_axi_m2s_t(s: s1_axi_m2s_t) return m_axi_m2s_t;
  function to_s1_axi_s2m_t(s: m_axi_s2m_t) return s1_axi_s2m_t;

end package axi64_pkg;

package body axi64_pkg is

  function to_m_axi_m2s_t(s: s1_axi_m2s_t) return m_axi_m2s_t is
    variable res: m_axi_m2s_t;
  begin
    res.arid    := s.arid(axi_im - 1 downto 0);
    res.araddr  := s.araddr;
    res.arlen   := s.arlen;
    res.arsize  := s.arsize;
    res.arburst := s.arburst;
    res.arlock  := s.arlock;
    res.arcache := s.arcache;
    res.arprot  := s.arprot;
    res.arqos   := s.arqos;
    res.aruser  := '0';
    res.arvalid := s.arvalid;
    res.rready  := s.rready;
    res.awid    := s.awid(axi_im - 1 downto 0);
    res.awaddr  := s.awaddr;
    res.awlen   := s.awlen;
    res.awsize  := s.awsize;
    res.awburst := s.awburst;
    res.awlock  := s.awlock;
    res.awcache := s.awcache;
    res.awprot  := s.awprot;
    res.awqos   := s.awqos;
    res.awuser  := '0';
    res.awvalid := s.awvalid;
    res.wdata   := s.wdata;
    res.wstrb   := s.wstrb;
    res.wlast   := s.wlast;
    res.wvalid  := s.wvalid;
    res.bready  := s.bready;
    return res;
  end function to_m_axi_m2s_t;

  function to_s1_axi_s2m_t(s: m_axi_s2m_t) return s1_axi_s2m_t is
    variable res: s1_axi_s2m_t;
  begin
    res.arready := s.arready;
    res.rid     := X"00" & "00" & s.rid;
    res.rdata   := s.rdata;
    res.rresp   := s.rresp;
    res.rlast   := s.rlast;
    res.rvalid  := s.rvalid;
    res.awready := s.awready;
    res.wready  := s.wready;
    res.bid     := X"00" & "00" & s.bid;
    res.bvalid  := s.bvalid;
    res.bresp   := s.bresp;
    return res;
  end function to_s1_axi_s2m_t;

end package body axi64_pkg;
