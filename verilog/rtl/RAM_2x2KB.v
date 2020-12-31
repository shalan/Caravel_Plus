module RAM_2x2KB (
    CLK,
    WE,
    EN,
    Di,
    Do,
    A
);
    input           CLK;
    input   [3:0]   WE;
    input           EN;
    input   [31:0]  Di;
    output  [31:0]  Do;
    input   [9:0]   A;

    wire    [31:0]  Do_0, Do_1;

    DFFRAM_2kb #(.COLS(2)) RAM0 (
                .CLK(CLK),
                .WE(WE),
                .EN(~A[9]),
                .Di(Di),
                .Do(Do_0),
                .A(A[8:0])
            );
    
    DFFRAM_2kb #(.COLS(2)) RAM1 (
                .CLK(CLK),
                .WE(WE),
                .EN(A[9]),
                .Di(Di),
                .Do(Do_1),
                .A(A[8:0])
            );

    assign Do = A[9] ? Do_1 : Do_0;

endmodule