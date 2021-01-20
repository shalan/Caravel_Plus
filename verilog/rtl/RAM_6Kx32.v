//`define USE_DFFRAM_BEH
module RAM_6Kx32 (
`ifdef USE_POWER_PINS
    VPWR,
    VGND,
`endif
    CLK,
    WE,
    EN,
    Di,
    Do,
    A
);
`ifdef USE_POWER_PINS
    input VPWR;
    input VGND;
`endif
    input           CLK;
    input   [3:0]   WE;
    input           EN;
    input   [31:0]  Di;
    output  [31:0]  Do;
    input   [12:0]   A;

    localparam BLOCKS=3;

    wire    [BLOCKS-1:0]    _EN_ ;
    wire    [31:0]          _Do_ [BLOCKS-1:0];
    wire    [31:0]          Do_pre;

    generate 
        genvar gi;
        for(gi=0; gi<BLOCKS; gi=gi+1) 

    RAM_2x4KB   RAM (
            `ifdef USE_POWER_PINS
                .VPWR(VPWR),
                .VGND(VGND),
            `endif
                .CLK(CLK),
                .WE(WE),
                .EN(_EN_[gi]),
                .Di(Di),
                .Do(_Do_[gi]),
                .A(A[10:0])
            );
        
    endgenerate 
    
    // The block decoder
    assign _EN_[0] = A[12:11] == 2'd0;
    assign _EN_[1] = A[12:11] == 2'd1;
    assign _EN_[2] = A[12:11] == 2'd2;
    
    // Output Data multiplexor
    assign Do_pre = (A[12:11] == 2'd0) ? _Do_[0] : 
                    (A[12:11] == 2'd1) ? _Do_[1] : 
                    (A[12:11] == 2'd2) ? _Do_[2] : 32'd0;

    sky130_fd_sc_hd__clkbuf_4 DOBUF[31:0] (.X(Do), .A(Do_pre));
    
endmodule