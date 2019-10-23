/*
 * Copyright (C) 2013-2017 ETH Zurich, University of Bologna
 * All rights reserved.
 *
 * This code is under development and not yet released to the public.
 * Until it is released, the code is under the copyright of ETH Zurich and
 * the University of Bologna, and may contain confidential and/or unpublished
 * work. Any reuse/redistribution is strictly forbidden without written
 * permission from ETH Zurich.
 *
 * Bug fixes and contributions will eventually be released under the
 * SolderPad open hardware license in the context of the PULP platform
 * (http://www.pulp-platform.org), under the copyright of ETH Zurich and the
 * University of Bologna.
 */

`include "ulpsoc_defines.sv"

`ifndef PULP_FPGA_SIM
 `define PULP_FPGA_NETLIST
`endif

module pulpemu
  (
   // LED for VERIFY
   output       LED,
   // FMC pins
   inout        FMC_qspi_sdio0,
   inout        FMC_qspi_sdio1,
   inout        FMC_qspi_sdio2,
   inout        FMC_qspi_sdio3,
   inout        FMC_qspi_csn0,
   inout        FMC_qspi_csn1,
   inout        FMC_qspi_sck,
   inout        FMC_sdio_sdio0,
   inout        FMC_sdio_sdio1,
   inout        FMC_sdio_sdio2,
   inout        FMC_sdio_sdio3,
   inout        FMC_sdio_cs0,
   inout        FMC_sdio_sck,
   inout        FMC_i2c0_sda,
   inout        FMC_i2c0_scl,
   inout        FMC_uart_rx,
   inout        FMC_uart_tx,
   inout        FMC_i2s0_sck,
   inout        FMC_i2s0_ws,
   inout        FMC_i2s0_sdi,
   inout        FMC_i2s1_sdi,
   inout        FMC_cam_pclk,
   inout        FMC_cam_hsync,
   inout        FMC_cam_data0,
   inout        FMC_cam_data1,
   inout        FMC_cam_data2,
   inout        FMC_cam_data3,
   inout        FMC_cam_data4,
   inout        FMC_cam_data5,
   inout        FMC_cam_data6,
   inout        FMC_cam_data7,
   inout        FMC_cam_vsync,
   inout        FMC_jtag_tck,
   inout        FMC_jtag_tdi,
   inout        FMC_jtag_tdo,
   inout        FMC_jtag_tms,
   inout        FMC_jtag_trst,
   inout        FMC_bootmode,
   inout        FMC_reset_n
   );

   // pulpemu top signals
   logic        zynq_clk;
   logic        zynq_rst_n;
   logic        pulp_soc_clk;
   logic        pulp_cluster_clk;

   // reference 32768 Hz clock
   wire         ref_clk;

   //  ███████╗██╗   ██╗███╗   ██╗ ██████╗         ██╗    ██╗██████╗  █████╗ ██████╗ ██████╗ ███████╗██████╗
   //  ╚══███╔╝╚██╗ ██╔╝████╗  ██║██╔═══██╗        ██║    ██║██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
   //    ███╔╝  ╚████╔╝ ██╔██╗ ██║██║   ██║        ██║ █╗ ██║██████╔╝███████║██████╔╝██████╔╝█████╗  ██████╔╝
   //   ███╔╝    ╚██╔╝  ██║╚██╗██║██║▄▄ ██║        ██║███╗██║██╔══██╗██╔══██║██╔═══╝ ██╔═══╝ ██╔══╝  ██╔══██╗
   //  ███████╗   ██║   ██║ ╚████║╚██████╔╝███████╗╚███╔███╔╝██║  ██║██║  ██║██║     ██║     ███████╗██║  ██║
   //  ╚══════╝   ╚═╝   ╚═╝  ╚═══╝ ╚══▀▀═╝ ╚══════╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝╚═╝  ╚═╝

   zynq_wrapper zynq_wrapper_i (
                                // pulp clocks (clk_wiz_clk_out1->cluster, clk_wiz_clk_out2->soc, clk_wiz_clk_out3->per)
                                .pulp_cluster_clk   (pulp_cluster_clk ),
                                .pulp_soc_clk       (pulp_soc_clk     ),
                                .pulp_per_clk       (pulp_per_clk     ),
                                // zynq clock (FCLK0)
                                .zynq_clk           (zynq_clk         ),
                                .zynq_rst_n         (zynq_rst_n       )
                                );



   pulpemu_ref_clk_div
     #(
       .DIVISOR           ( 256  )
       )
   ref_clk_div (
                .clk_i            ( zynq_clk                      ), // FPGA inner clock,  8.388608 MHz
                .rstn_i           ( zynq_rst_n                    ), // FPGA inner reset
                .ref_clk_o        ( ref_clk                       )  // REF clock out
                );

  // 1 socond blink LED
  pulpemu_ref_clk_div
    #(
      .DIVISOR            ( 32768 )
      )
   led_clk_div (
                .clk_i            ( ref_clk                       ),
                .rstn_i           ( zynq_rst_n                    ),
                .ref_clk_o        ( LED                           )
                );


   //  ██████╗ ██╗   ██╗██╗     ██████╗     ██████╗██╗  ██╗██╗██████╗
   //  ██╔══██╗██║   ██║██║     ██╔══██╗   ██╔════╝██║  ██║██║██╔══██╗
   //  ██████╔╝██║   ██║██║     ██████╔╝   ██║     ███████║██║██████╔╝
   //  ██╔═══╝ ██║   ██║██║     ██╔═══╝    ██║     ██╔══██║██║██╔═══╝
   //  ██║     ╚██████╔╝███████╗██║███████╗╚██████╗██║  ██║██║██║
   //  ╚═╝      ╚═════╝ ╚══════╝╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝

   pulp
     #(.CORE_TYPE(CORE_TYPE),
       .USE_FPU(USE_FPU),
       .USE_HWPE(USE_HWPE)
       ) i_pulp
       (
        .zynq_clk_i            ( ref_clk                       ), // FPGA inner clock, 32768 Hz
        .zynq_soc_clk_i        ( pulp_soc_clk                  ), // FPGA inner clock, 50 MHz
        .zynq_cluster_clk_i    ( pulp_cluster_clk              ), // FPGA inner clock, 50 MHz
        .zynq_per_clk_i        ( pulp_per_clk                  ), // FPGA inner clock, 50 MHz

        .pad_spim_sdio0(FMC_qspi_sdio0),
        .pad_spim_sdio1(FMC_qspi_sdio1),
        .pad_spim_sdio2(FMC_qspi_sdio2),
        .pad_spim_sdio3(FMC_qspi_sdio3),
        .pad_spim_csn0(FMC_qspi_csn0),
        .pad_spim_csn1(FMC_qspi_csn1),
        .pad_spim_sck(FMC_qspi_sck),

        .pad_uart_rx(FMC_uart_rx),
        .pad_uart_tx(FMC_uart_tx),

        .pad_cam_pclk(FMC_cam_pclk),
        .pad_cam_hsync(FMC_cam_hsync),
        .pad_cam_data0(FMC_cam_data0),
        .pad_cam_data1(FMC_cam_data0),
        .pad_cam_data2(FMC_cam_data0),
        .pad_cam_data3(FMC_cam_data0),
        .pad_cam_data4(FMC_cam_data0),
        .pad_cam_data5(FMC_cam_data0),
        .pad_cam_data6(FMC_cam_data0),
        .pad_cam_data7(FMC_cam_data0),
        .pad_cam_vsync(FMC_cam_data0),

        .pad_sdio_clk(FMC_sdio_clk),
        .pad_sdio_cmd(FMC_sdio_cmd),
        .pad_sdio_data0(FMC_sdio_data0),
        .pad_sdio_data1(FMC_sdio_data1),
        .pad_sdio_data2(FMC_sdio_data2),
        .pad_sdio_data3(FMC_sdio_data3),

        .pad_i2c0_sda(FMC_i2c0_sda),
        .pad_i2c0_scl(FMC_i2c0_scl),

        .pad_i2s0_sck(FMC_i2s0_sck),
        .pad_i2s0_ws(FMC_i2s0_ws),
        .pad_i2s0_sdi(FMC_i2s0_sdi),
        .pad_i2s1_sdi(FMC_i2s1_sdi),

        .pad_jtag_tck(FMC_jtag_tck),
        .pad_jtag_tdi(FMC_jtag_tdi),
        .pad_jtag_tdo(FMC_jtag_tdo),
        .pad_jtag_tms(FMC_jtag_tms),
        .pad_jtag_trst(FMC_jtag_trst),

        .pad_xtal_in(), // USE zynq_clk_i as ref_clk
        .pad_reset_n(FMC_reset_n),
        .pad_bootmode(FMC_bootmode)  // Boot mode = 0; boot from flash; Boot mode = 1; boot from jtag
        );

endmodule // pulpemu
