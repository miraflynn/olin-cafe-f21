module mux32(input   logic [31:0] d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24, d25, d26, d27, d28, d29, d30, d31,
            input    logic [4:0] s,                     
            output   logic [31:0] y);   
    
    logic [31:0] a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15;
    // logic [3:0] low, high;

    mux2 muxA0(d0, d1, s[0], a0);
    mux2 muxA1(d2, d3, s[0], a1);
    mux2 muxA2(d4, d5, s[0], a2);
    mux2 muxA3(d6, d7, s[0], a3);
    mux2 muxA4(d8, d9, s[0], a4);
    mux2 muxA5(d10, d11, s[0], a5);
    mux2 muxA6(d12, d13, s[0], a6);
    mux2 muxA7(d14, d15, s[0], a7);
    mux2 muxA8(d16, d17, s[0], a8);
    mux2 muxA9(d18, d19, s[0], a9);
    mux2 muxA10(d20, d21, s[0], a10);
    mux2 muxA11(d22, d23, s[0], a11);
    mux2 muxA12(d24, d25, s[0], a12);
    mux2 muxA13(d26, d27, s[0], a13);
    mux2 muxA14(d28, d29, s[0], a14);
    mux2 muxA15(d30, d31, s[0], a15);

    logic [31:0] b0, b1, b2, b3, b4, b5, b6, b7;

    mux2 muxB0(a0, a1, s[1], b0);
    mux2 muxB1(a2, a3, s[1], b1);
    mux2 muxB2(a4, a5, s[1], b2);
    mux2 muxB3(a6, a7, s[1], b3);
    mux2 muxB4(a8, a9, s[1], b4);
    mux2 muxB5(a10, a11, s[1], b5);
    mux2 muxB6(a12, a13, s[1], b6);
    mux2 muxB7(a14, a15, s[1], b7);

    logic [31:0] c0, c1, c2, c3;

    mux2 muxC0(b0, b1, s[2], c0);
    mux2 muxC1(b2, b3, s[2], c1);
    mux2 muxC2(b4, b5, s[2], c2);
    mux2 muxC3(b6, b7, s[2], c3);

    logic [31:0] penult0, penult1;

    mux2 muxD0(c0, c1, s[3], penult0);
    mux2 muxD1(c2, c3, s[3], penult1);
 
    mux2 finalmux(penult0, penult1, s[4], y);
endmodule