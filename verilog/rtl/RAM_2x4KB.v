module RAM_2x4KB (
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
    input   [10:0]   A;

    wire    [31:0]  Do_0, Do_1;

    DFFRAM_4KB #(.COLS(4)) RAM0 (
    `ifdef USE_POWER_PINS
            .VPWR(VPWR),
            .VGND(VGND),
    `endif
                .CLK(CLK),
                .WE(WE),
                .EN(~A[10]),
                .Di(Di),
                .Do(Do_0),
                .A(A[9:0])
            );
    
    DFFRAM_4KB #(.COLS(4)) RAM1 (
    `ifdef USE_POWER_PINS
            .VPWR(VPWR),
            .VGND(VGND),
    `endif
                .CLK(CLK),
                .WE(WE),
                .EN(A[10]),
                .Di(Di),
                .Do(Do_1),
                .A(A[9:0])
            );

    assign Do = A[10] ? Do_1 : Do_0;

endmodule