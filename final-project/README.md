# Pong: CompArch Final Project
### Mira Flynn

## Notes
This project was written and tested using [RARS](https://github.com/TheThirdOne/rars), a RISC-V assembler and simulator. I haven't tested with anything else, so I only claim that this works specifically using this software.

All code for the project is in [`/olin-cafe-f21/final-project/asm/pong.s`](asm/pong.s). I did not copy specific code into this README, as I wanted to focus more on the overall structure of the project. Comments in the code help explain some of the finer details of these mechanics, so I'd recommend that you also take a look at the code.

## Project Overview
My goal with this project was to partially recreate Pong using RISC-V assembly code. I initially planned to implement this using the FPGA and touchscreen display that we'd previously used in CompArch, but I ended up implementing this with a RISC-V simulator instead. The minimum viable product I selected was having a ball bounce between two sides of the screen. I ended up going a bit beyond this and achieving a ball that can travel in 8 directions (4 cardinal and 4 diagonal), interacting with walls correctly no matter which direction. 

## Implementation

### Reset
The code starts with a reset, which sets the ball's position to the middle of the screen, sets the direction, and loops through all memory addresses of the display to write black. Writing black to each pixel isn't strictly necessary as the bitmap display contains a reset functionality, but is good to have just in case.

### Loop Structure
To move the ball, the loop has 3 major components. First, the location of the ball is overwritten with black. (`STEP` label in the code). This is substantially faster than redrawing the whole screen each loop. Next, the movement of the ball is calculated. (`MOVE` label in the code). Last, the ball is redrawn at its new location. (`DRAW` label in the code). There is then a delay before starting a new loop.

### Display Mechanics
My project has a ball that bounces around inside a 512x256 pixel bitmap display, provided by RARS. The bitmap display has a memory address for each pixel, with the first pixel at memory address `0x10010000` by default. The color for each pixel is defined by the lower 24 bits of its memory address value, with each RGB color channel using 8 bits of that memory. 

### Ball Representation
The ball behavior is defined using two variables. The first variable is position, stored in register `T0`. The position is stored as a memory address corresponding to the center pixel of the ball on the screen. I initially chose XY coordinates to represent the position, but decided to switch to directly storing a memory address to make drawing simpler by eliminating conversion between XY coordinates and memory addresses. The other variable controlling ball behavior is direction, stored in register `T2`. Direction should be within 0 to 7, each corresponding to a direction. (Direction being stored in `T2` rather than `T1` is a byproduct of the previous XY position storage, and `T1` was used to hold the number to add to or subtract from the position to move the ball up or down by a full display row.)

### Drawing
Drawing (or erasing) the ball is simple because the ball is already stored as a memory address. That memory address is directly modified to progressively move it in a 3x3 square around the initial location, ending back at the memory address where it started. At each memory address, the color is drawn. This allows drawing to take only 19 instructions, rather than hundreds of thousands to redraw the entire display. It is also substantially simpler than converting between XY position and memory address, although that could also be done comparatively quickly. The drawing process is the same for erasing, with the only difference being to write black to each pixel rather than white. After the ball is redrawn in the new location, a loop that does nothing but count to a large number is run to make the ball move at a human-scale speed.

### Moving
Moving and especially bouncing are the most complicated aspects of this code. When moving left or right, the ball is moving between pixels that neighbor in memory addresses. When moving up or down, the ball is moving between rows, which are further apart in memory. This maps to a horizontal movement of 1 pixel being accomplished by adding or subtracting 4 to the position, and a vertical movement of 1 pixel being accomplished by adding or subtracting 4\*512 to the memory address. 4\*512 is too large to be an immediate, so its value is stored in a register for easy use. Diagonal movements are one horizontal and one vertical movement, while cardinal movements are two pixels of movement. This was so that if I did go further, a ball traveling straight would move towards the opponent's side faster than a ball traveling diagonally.

To have the ball bounce, there are 3 basic conditions to check. If the ball goes past the top wall, its memory address will go below `0x10010000`, the first memory address of the screen. (This can be seen in lines 276-284). If the ball goes past the bottom wall, its memory address will go above the maximum memory address of the screen. (This can be seen in lines 153-165). If the ball goes past the edge of the screen traveling horizontally, the condition is a bit tougher to check because it goes to another valid memory address, rather than leaving a range of addresses. I checked this by taking the `and` of the position and `2^11-1`, which is the position of the ball within a row. I then take the amount of memory for the ball to move a row and subtract the position within a row. If the difference between these is less than 16, then the ball is near or at the edge of the screen. Taking the difference rather than checking for equality is necessary as the ball can move two pixels in one move. (This can be seen in lines 220-226).

For each movement direction, there are only one or two walls that can be hit. I therefore can check all applicable conditions after each move and update the direction depending on which wall is hit. Knowing what direction the ball is moving and which wall gets hit is enough to know which direction to bounce. Additionally, when a wall is hit, the move is undone. This is necessary for the horizontal bounces, as the ball will get stuck bouncing in between two directions because the bounce condition is the same for both sides of the screen. The vertical bounces are also undone for consistency. 

## Speedbumps
There were several speedbumps I encountered along this project. (A speedbump is just something that slows me down but doesn't prevent me from finishing the project, as opposed to a roadblock that stops me from completing something). The largest one was a bug I found in either the assembler or the CPU. This resulted in branches not always going to the correct instruction. Because of this, I decided to use RARS rather than continue working with the FPGA CPU. Several other minor speedbumps were my lack of time due to finals and such, as well as my lack of experience with any sort of assembly code. 

## Project Code
All code for the project is in [`/olin-cafe-f21/final-project/asm/pong.s`](asm/pong.s). The FPGA CPU code is all present in `/final-project/`, although I did not end up using it. All the other work in the folder is a direct copy of the final demo files from lab 3.