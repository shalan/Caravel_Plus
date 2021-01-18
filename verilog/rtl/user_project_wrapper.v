`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * An example user project is provided in this wrapper.  The
 * example should be removed and replaced with the actual
 * user project.
 *
 *-------------------------------------------------------------
 */

`define MPRJ_IO_PADS 38

module user_project_wrapper (
`ifdef USE_POWER_PINS
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oen,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7.
    inout [`MPRJ_IO_PADS-8:0] analog_io,

    // Independent clock (on independent integer divider)
    input   user_clock2
);

    /*--------------------------------------*/
    /* User project is instantiated  here   */
    /*--------------------------------------*/

    wire [3:0] WE;
    wire EN;
    wire  [31:0]  Di;
    wire  [31:0]  Do;
    wire  [12:0]   A;

    Caravel_RAM_24KB_wb wb (
        // Wishbone Interface
        .wb_clk_i(wb_clk_i),
        .wb_rst_i(wb_rst_i),

        .wb_adr_i(wbs_adr_i),
        .wb_dat_i(wbs_dat_i),
        .wb_sel_i(wbs_sel_i),
        .wb_we_i(wbs_we_i),
        .wb_cyc_i(wbs_cyc_i),
        .wb_stb_i(wbs_stb_i),

        .wb_ack_o(wbs_ack_o),
        .wb_dat_o(wbs_dat_o),

        // Memory Interface
        .WE(WE),
        .EN(EN),
        .Di(Di),
        .Do(Do),
        .A(A)
    );

    Caravel_RAM_24KB ram (
    `ifdef USE_POWER_PINS
        .VPWR(vccd1),	// User area 1 1.8V power
        .VGND(vssd1),	// User area 1 digital ground
    `endif

	// MGMT core clock and reset
        .CLK(wb_clk_i),
        .WE(WE),
        .EN(EN),
        .Di(Di),
        .Do(Do),
        .A(A)
    );

endmodule	// user_project_wrapper
`default_nettype wire
