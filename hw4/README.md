## Module Implementation

I implemented the adder using the most basic ripple carry adder implementation, which is the slowest option. I wanted to work on the muxes before spending more time on the adder, and didn't end up having time to improve the adder. Most of the adder code is taken from in-class examples.

I implemented the mux32 by first taking the 2 to 1 mux example from the textbook and modifying it to 32 bits. I then made the 32 to 1 mux by using 16 mux2s with the 32 inputs and s[0], 8 mux2s with the previous 16 outputs and s[1], 4 mux2s with those 8 outputs and s[2], 2 mux2s with those 4 outputs and s[3], and 1 mux2 with those 2 outputs and s[4]. This creates a tree formation of 2 to 1 muxes. I wrote this all out on a whiteboard and forgot to take a picture, unfortunately.

## MUX32 Testing

I tested the 32 to 1 mux by modifying the adder testbench. I first set the 32 D inputs to 0 through 31 for easy reading and swept s from 0 to 31. I fixed several errors based on this. I then set the 32 inputs to random numbers and swept s again, which all worked properly. The error counting from the adder test didn't seem to work, and would say that y should be a value from the next batch of randoms. Therefore, I decided to eliminate the assertion and only look at the printed outputs to check that they all work properly.

## Running Tests
To run the tests, run 'make test_add' or 'make test_mux'.