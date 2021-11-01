module shift_right_logical(in,shamt,out);
parameter N = 32; // only used as a constant! Don't feel like you need to a shifter for arbitrary N.

//port definitions
input  wire [N-1:0] in;    // A 32 bit input
input  wire [$clog2(N)-1:0] shamt; // Amount we shift by.
output wire [N-1:0] out;  // Output.
generate
  genvar i;
  for(i = 0; i < N; i++) begin : right_shift_logical
    mux32 MUX_0 (
        .in0(0+i < N ? in[0+i] : 1'b0), 
        .in1(1+i < N ? in[1+i] : 1'b0), 
        .in2(2+i < N ? in[2+i] : 1'b0), 
        .in3(3+i < N ? in[3+i] : 1'b0), 
        .in4(4+i < N ? in[4+i] : 1'b0), 
        .in5(5+i < N ? in[5+i] : 1'b0), 
        .in6(6+i < N ? in[6+i] : 1'b0), 
        .in7(7+i < N ? in[7+i] : 1'b0), 
        .in8(8+i < N ? in[8+i] : 1'b0), 
        .in9(9+i < N ? in[9+i] : 1'b0), 
        .in10(10+i < N ? in[10+i] : 1'b0), 
        .in11(11+i < N ? in[11+i] : 1'b0), 
        .in12(12+i < N ? in[12+i] : 1'b0), 
        .in13(13+i < N ? in[13+i] : 1'b0), 
        .in14(14+i < N ? in[14+i] : 1'b0), 
        .in15(15+i < N ? in[15+i] : 1'b0), 
        .in16(16+i < N ? in[16+i] : 1'b0), 
        .in17(17+i < N ? in[17+i] : 1'b0), 
        .in18(18+i < N ? in[18+i] : 1'b0), 
        .in19(19+i < N ? in[19+i] : 1'b0), 
        .in20(20+i < N ? in[20+i] : 1'b0), 
        .in21(21+i < N ? in[21+i] : 1'b0), 
        .in22(22+i < N ? in[22+i] : 1'b0), 
        .in23(23+i < N ? in[23+i] : 1'b0), 
        .in24(24+i < N ? in[24+i] : 1'b0), 
        .in25(25+i < N ? in[25+i] : 1'b0), 
        .in26(26+i < N ? in[26+i] : 1'b0), 
        .in27(27+i < N ? in[27+i] : 1'b0), 
        .in28(28+i < N ? in[28+i] : 1'b0), 
        .in29(29+i < N ? in[29+i] : 1'b0), 
        .in30(30+i < N ? in[30+i] : 1'b0), 
        .in31(31+i < N ? in[31+i] : 1'b0),
        .switch(shamt), 
        .out(out[i])
    );
  end
endgenerate

// Gati told me the obvious thing (look at the textbook), but otherwise no help.


endmodule
