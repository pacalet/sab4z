--
-- Copyright (C) Telecom ParisTech
-- Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paristech.fr)
-- 
-- This file must be used under the terms of the CeCILL. This source
-- file is licensed as described in the file COPYING, which you should
-- have received as part of this distribution. The terms are also
-- available at:
-- http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sab4z_sim is
end entity sab4z_sim;

architecture sim of sab4z_sim is

  signal aclk: std_ulogic;  -- Clock
  signal aresetn: std_ulogic;  -- Synchronous, active low, reset
  signal btn: std_ulogic;  -- Command button
  signal sw: std_ulogic_vector(3 downto 0); -- Slide switches
  signal led: std_ulogic_vector(3 downto 0); -- LEDs

  signal s0_axi_araddr: std_ulogic_vector(29 downto 0);
  signal s0_axi_arprot: std_ulogic_vector(2 downto 0);
  signal s0_axi_arvalid: std_ulogic;
  signal s0_axi_rready: std_ulogic;
  signal s0_axi_awaddr: std_ulogic_vector(29 downto 0);
  signal s0_axi_awprot: std_ulogic_vector(2 downto 0);
  signal s0_axi_awvalid: std_ulogic;
  signal s0_axi_wdata: std_ulogic_vector(31 downto 0);
  signal s0_axi_wstrb: std_ulogic_vector(3 downto 0);
  signal s0_axi_wvalid: std_ulogic;
  signal s0_axi_bready: std_ulogic;
  signal s0_axi_arready: std_ulogic;
  signal s0_axi_rdata: std_ulogic_vector(31 downto 0);
  signal s0_axi_rresp: std_ulogic_vector(1 downto 0);
  signal s0_axi_rvalid: std_ulogic;
  signal s0_axi_awready: std_ulogic;
  signal s0_axi_wready: std_ulogic;
  signal s0_axi_bresp: std_ulogic_vector(1 downto 0);
  signal s0_axi_bvalid: std_ulogic;

  signal s1_axi_arid: std_ulogic_vector(5 downto 0);
  signal s1_axi_araddr: std_ulogic_vector(29 downto 0);
  signal s1_axi_arlen: std_ulogic_vector(3 downto 0);
  signal s1_axi_arsize: std_ulogic_vector(2 downto 0);
  signal s1_axi_arburst: std_ulogic_vector(1 downto 0);
  signal s1_axi_arlock: std_ulogic_vector(1 downto 0);
  signal s1_axi_arcache: std_ulogic_vector(3 downto 0);
  signal s1_axi_arprot: std_ulogic_vector(2 downto 0);
  signal s1_axi_arqos: std_ulogic_vector(3 downto 0);
  signal s1_axi_arvalid: std_ulogic;
  signal s1_axi_rready: std_ulogic;
  signal s1_axi_awid: std_ulogic_vector(5 downto 0);
  signal s1_axi_awaddr: std_ulogic_vector(29 downto 0);
  signal s1_axi_awlen: std_ulogic_vector(3 downto 0);
  signal s1_axi_awsize: std_ulogic_vector(2 downto 0);
  signal s1_axi_awburst: std_ulogic_vector(1 downto 0);
  signal s1_axi_awlock: std_ulogic_vector(1 downto 0);
  signal s1_axi_awcache: std_ulogic_vector(3 downto 0);
  signal s1_axi_awprot: std_ulogic_vector(2 downto 0);
  signal s1_axi_awqos: std_ulogic_vector(3 downto 0);
  signal s1_axi_awvalid: std_ulogic;
  signal s1_axi_wid: std_ulogic_vector(5 downto 0);
  signal s1_axi_wdata: std_ulogic_vector(31 downto 0);
  signal s1_axi_wstrb: std_ulogic_vector(3 downto 0);
  signal s1_axi_wlast: std_ulogic;
  signal s1_axi_wvalid: std_ulogic;
  signal s1_axi_bready: std_ulogic;
  signal s1_axi_arready: std_ulogic;
  signal s1_axi_rid: std_ulogic_vector(5 downto 0);
  signal s1_axi_rdata: std_ulogic_vector(31 downto 0);
  signal s1_axi_rresp: std_ulogic_vector(1 downto 0);
  signal s1_axi_rlast: std_ulogic;
  signal s1_axi_rvalid: std_ulogic;
  signal s1_axi_awready: std_ulogic;
  signal s1_axi_wready: std_ulogic;
  signal s1_axi_bid: std_ulogic_vector(5 downto 0);
  signal s1_axi_bresp: std_ulogic_vector(1 downto 0);
  signal s1_axi_bvalid: std_ulogic;

  signal m_axi_arid: std_ulogic_vector(5 downto 0);
  signal m_axi_araddr: std_ulogic_vector(31 downto 0);
  signal m_axi_arlen: std_ulogic_vector(3 downto 0);
  signal m_axi_arsize: std_ulogic_vector(2 downto 0);
  signal m_axi_arburst: std_ulogic_vector(1 downto 0);
  signal m_axi_arlock: std_ulogic_vector(1 downto 0);
  signal m_axi_arcache: std_ulogic_vector(3 downto 0);
  signal m_axi_arprot: std_ulogic_vector(2 downto 0);
  signal m_axi_arqos: std_ulogic_vector(3 downto 0);
  signal m_axi_arvalid: std_ulogic;
  signal m_axi_rready: std_ulogic;
  signal m_axi_awid: std_ulogic_vector(5 downto 0);
  signal m_axi_awaddr: std_ulogic_vector(31 downto 0);
  signal m_axi_awlen: std_ulogic_vector(3 downto 0);
  signal m_axi_awsize: std_ulogic_vector(2 downto 0);
  signal m_axi_awburst: std_ulogic_vector(1 downto 0);
  signal m_axi_awlock: std_ulogic_vector(1 downto 0);
  signal m_axi_awcache: std_ulogic_vector(3 downto 0);
  signal m_axi_awprot: std_ulogic_vector(2 downto 0);
  signal m_axi_awqos: std_ulogic_vector(3 downto 0);
  signal m_axi_awvalid: std_ulogic;
  signal m_axi_wid: std_ulogic_vector(5 downto 0);
  signal m_axi_wdata: std_ulogic_vector(31 downto 0);
  signal m_axi_wstrb: std_ulogic_vector(3 downto 0);
  signal m_axi_wlast: std_ulogic;
  signal m_axi_wvalid: std_ulogic;
  signal m_axi_bready: std_ulogic;
  signal m_axi_arready: std_ulogic;
  signal m_axi_rid: std_ulogic_vector(5 downto 0);
  signal m_axi_rdata: std_ulogic_vector(31 downto 0);
  signal m_axi_rresp: std_ulogic_vector(1 downto 0);
  signal m_axi_rlast: std_ulogic;
  signal m_axi_rvalid: std_ulogic;
  signal m_axi_awready: std_ulogic;
  signal m_axi_wready: std_ulogic;
  signal m_axi_bid: std_ulogic_vector(5 downto 0);
  signal m_axi_bresp: std_ulogic_vector(1 downto 0);
  signal m_axi_bvalid: std_ulogic;

  signal eos: boolean := false;

begin

  process
  begin
    aclk <= '0';
    wait for 1 ns;
    aclk <= '1';
    wait for 1 ns;
    if eos then
      wait;
    end if;
  end process;

  process
  begin
    aresetn <= '0';
    for i in 1 to 10 loop
      wait until rising_edge(aclk);
    end loop;
    aresetn <= '1';
    for i in 1 to 10 loop
      wait until rising_edge(aclk);
    end loop;
    report "End of simulation";
    eos <= true;
  end process;

  u0: entity work.sab4z(rtl)
  port map(
    aclk => aclk,
    aresetn => aresetn,
    btn => btn,
    sw => sw,
    led => led,

    s0_axi_araddr => s0_axi_araddr,
    s0_axi_arprot => s0_axi_arprot,
    s0_axi_arvalid => s0_axi_arvalid,
    s0_axi_rready => s0_axi_rready,
    s0_axi_awaddr => s0_axi_awaddr,
    s0_axi_awprot => s0_axi_awprot,
    s0_axi_awvalid => s0_axi_awvalid,
    s0_axi_wdata => s0_axi_wdata,
    s0_axi_wstrb => s0_axi_wstrb,
    s0_axi_wvalid => s0_axi_wvalid,
    s0_axi_bready => s0_axi_bready,
    s0_axi_arready => s0_axi_arready,
    s0_axi_rdata => s0_axi_rdata,
    s0_axi_rresp => s0_axi_rresp,
    s0_axi_rvalid => s0_axi_rvalid,
    s0_axi_awready => s0_axi_awready,
    s0_axi_wready => s0_axi_wready,
    s0_axi_bresp => s0_axi_bresp,
    s0_axi_bvalid => s0_axi_bvalid,

    s1_axi_arid => s1_axi_arid,
    s1_axi_araddr => s1_axi_araddr,
    s1_axi_arlen => s1_axi_arlen,
    s1_axi_arsize => s1_axi_arsize,
    s1_axi_arburst => s1_axi_arburst,
    s1_axi_arlock => s1_axi_arlock,
    s1_axi_arcache => s1_axi_arcache,
    s1_axi_arprot => s1_axi_arprot,
    s1_axi_arqos => s1_axi_arqos,
    s1_axi_arvalid => s1_axi_arvalid,
    s1_axi_rready => s1_axi_rready,
    s1_axi_awid => s1_axi_awid,
    s1_axi_awaddr => s1_axi_awaddr,
    s1_axi_awlen => s1_axi_awlen,
    s1_axi_awsize => s1_axi_awsize,
    s1_axi_awburst => s1_axi_awburst,
    s1_axi_awlock => s1_axi_awlock,
    s1_axi_awcache => s1_axi_awcache,
    s1_axi_awprot => s1_axi_awprot,
    s1_axi_awqos => s1_axi_awqos,
    s1_axi_awvalid => s1_axi_awvalid,
    s1_axi_wid => s1_axi_wid,
    s1_axi_wdata => s1_axi_wdata,
    s1_axi_wstrb => s1_axi_wstrb,
    s1_axi_wlast => s1_axi_wlast,
    s1_axi_wvalid => s1_axi_wvalid,
    s1_axi_bready => s1_axi_bready,
    s1_axi_arready => s1_axi_arready,
    s1_axi_rid => s1_axi_rid,
    s1_axi_rdata => s1_axi_rdata,
    s1_axi_rresp => s1_axi_rresp,
    s1_axi_rlast => s1_axi_rlast,
    s1_axi_rvalid => s1_axi_rvalid,
    s1_axi_awready => s1_axi_awready,
    s1_axi_wready => s1_axi_wready,
    s1_axi_bid => s1_axi_bid,
    s1_axi_bresp => s1_axi_bresp,
    s1_axi_bvalid => s1_axi_bvalid,

    m_axi_arid => m_axi_arid,
    m_axi_araddr => m_axi_araddr,
    m_axi_arlen => m_axi_arlen,
    m_axi_arsize => m_axi_arsize,
    m_axi_arburst => m_axi_arburst,
    m_axi_arlock => m_axi_arlock,
    m_axi_arcache => m_axi_arcache,
    m_axi_arprot => m_axi_arprot,
    m_axi_arqos => m_axi_arqos,
    m_axi_arvalid => m_axi_arvalid,
    m_axi_rready => m_axi_rready,
    m_axi_awid => m_axi_awid,
    m_axi_awaddr => m_axi_awaddr,
    m_axi_awlen => m_axi_awlen,
    m_axi_awsize => m_axi_awsize,
    m_axi_awburst => m_axi_awburst,
    m_axi_awlock => m_axi_awlock,
    m_axi_awcache => m_axi_awcache,
    m_axi_awprot => m_axi_awprot,
    m_axi_awqos => m_axi_awqos,
    m_axi_awvalid => m_axi_awvalid,
    m_axi_wid => m_axi_wid,
    m_axi_wdata => m_axi_wdata,
    m_axi_wstrb => m_axi_wstrb,
    m_axi_wlast => m_axi_wlast,
    m_axi_wvalid => m_axi_wvalid,
    m_axi_bready => m_axi_bready,
    m_axi_arready => m_axi_arready,
    m_axi_rid => m_axi_rid,
    m_axi_rdata => m_axi_rdata,
    m_axi_rresp => m_axi_rresp,
    m_axi_rlast => m_axi_rlast,
    m_axi_rvalid => m_axi_rvalid,
    m_axi_awready => m_axi_awready,
    m_axi_wready => m_axi_wready,
    m_axi_bid => m_axi_bid,
    m_axi_bresp => m_axi_bresp,
    m_axi_bvalid => m_axi_bvalid
  );
end architecture sim;
