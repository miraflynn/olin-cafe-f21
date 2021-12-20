# Pong overview

# Registers
# x0/zero  :   zero
# x1/ra    :   return address
# x2/sp    :   stack pointer
# x3/gp    :   global pointer
# x4/tp    :   thread pointer
# x5/t0    :   TEMP: Ball Memory Pos
# x6/t1    :   TEMP: 1 row of memory
# x7/t2    :   TEMP: Ball Direction
# x8/s0/fp :   saved register/frame pointer
# x9/s1    :   saved register
# x10/a0   :   function argument / return value
# x11/a1   :   function argument / return value
# x12/a2   :   function argument
# x13/a3   :   function argument
# x14/a4   :   function argument
# x15/a5   :   function argument
# x16/a6   :   function argument
# x17/a7   :   function argument
# x18/s2   :   saved register
# x19/s3   :   saved register
# x20/s4   :   saved register
# x21/s5   :   saved register
# x22/s6   :   saved register
# x23/s7   :   saved register
# x24/s8   :   saved register
# x25/s9   :   saved register
# x26/s10  :   saved register
# x27/s11  :   saved register
# x28/t3   :   TEMP
# x29/t4   :   TEMP
# x30/t5   :   TEMP
# x31/t6   :   TEMP

# My Functions

# RESET : Set everything to a starting configuration
# STEP  : Do one full game loop of the thing. The STEP label only draws black over the ball location, and then moves onto MOVE. STEP is just where each loop starts.
# MOVE  : Move the ball
# DRAW  : Draw the frame to the screen

# The ball moves according to t2, ball direction. Ball direction is 0-7, which indicates one of 8 directions. Ball can move 2 spaces in one direction, or one space in two directions.
# 0: +X
# 1: +X, +Y
# 2: +Y
# 3: -X, +Y
# 4: -X
# 5: -X, -Y
# 6: -Y
# 7: -Y, +X

# +X: add 1 row to memory address
# +Y: add 4 to memory address

RESET: 
    addi t0, zero, 0
    lui t0, 1
    slli t0, t0, 16
    addi t6, zero, 1
    slli t6, t6, 16
    add t0, t0, t6 # t0 = 0x10010000
    # 0x10010000 is the memory address of the first pixel of the display
    
    addi, t1, zero, 16 
    slli, t1, t1, 14 # t1 = 256 rows of memory address
    add t0, t0, t1 # t0 = 256 rows into memory
    addi t0, t0, -1024 # t0 = 255 rows and 256 columns into memory
    # The display is 512 rows by 256 columns, so this location is one of the middle 4 pixels of the display
    
    addi, t1, zero, 16 
    slli, t1, t1, 7 # t1 = 0x00000800 = 1 row of memory address
    
    addi t2, zero, 5 # set starting direction
    
    # Draw all 0s to display
    lui t3, 1
    slli t3, t3, 16
    addi t6, zero, 1
    slli t6, t6, 16
    add t3, t3, t6 # t3 = 0x10010000
    
    and t6, zero, zero # t6 = 0
    #addi t5, zero, 75 # t5 = 75
    #slli t5, t5, 10 # t5 = 76800 (320*240)
    # This was for the hardware display, which I'm not using

    addi t5, zero, 1 # t5 = 1
    slli t5, t5, 17 # t5 = 131072 (512*256)
    #addi t4, zero, 255 # reset board to blue
    addi t4, zero, 0 # reset board to black
    RESET_LOOP_START: 
        sw t4, (t3) # This writes the value of t4 into the memory address stored in t3.
        addi t3, t3, 4 # go to next memory address
        addi t6, t6, 1 # t6 = t6 + 1
        blt t6, t5, RESET_LOOP_START
       
STEP: 
    addi t6, zero, 0 # color 0x00000000 = Black
    # mem position +0 row, +0 col
    sub t0, t0, t1 # mem position -1 row, +0 col
    sw t6, (t0) # set color t6
    addi t0, t0, -4 # mem position -1 row, -1 col
    sw t6, (t0) # set color t6
    addi t0, t0, 8 # mem position -1 row, +1 col
    sw t6, (t0) # set color t6
    add t0, t0, t1 # mem position +0 row, + 1 col
    sw t6, (t0) # set color t6
    add t0, t0, t1 # mem position +1 row, + 1 col
    sw t6, (t0) # set color t6
    addi t0, t0, -4 # mem position +1 row, +0 col
    sw t6, (t0) # set color t6
    addi t0, t0, -4 # mem position +1 row, -1 col
    sw t6, (t0) # set color t6
    sub t0, t0, t1 # mem position +0 row, -1 col
    sw t6, (t0) # set color t6
    addi t0, t0, 4 # mem position +0 row, +0 col
    sw t6, (t0) # set color t6


MOVE: 
    and t6, zero, zero
    # Go to MOVE_N for whatever N current direction
    beq t2, t6, MOVE_0
    addi t6, t6, 1
    beq t2, t6, MOVE_1
    addi t6, t6, 1
    beq t2, t6, MOVE_2
    addi t6, t6, 1
    beq t2, t6, MOVE_3
    addi t6, t6, 1
    beq t2, t6, MOVE_4
    addi t6, t6, 1
    beq t2, t6, MOVE_5
    addi t6, t6, 1
    beq t2, t6, MOVE_6
    addi t6, t6, 1
    beq t2, t6, MOVE_7 # 80


# +X: add 1 row to memory address
# +Y: add 4 to memory address

# Every move, the memory address is moved and the edge condition(s) are checked. If the edge condition, then undo the move and change direction correctly. Undoing the move makes some of the memory address checking work better, as the condition for left and right side bounce is actually exactly the same (the memory addresses wrap). If the move wasn't undone, then the edge conditions would be more reliant on the direction, so undoing the move makes the code easier. Undoing only takes 2 clock cycles, so it's easier, faster, and not noticeable.
# The movement checks are copy-pasted, as this was easier than writing a function for it.

# +2X   
MOVE_0: 
    add t0, t0, t1 # Move
    add t0, t0, t1
    
    # -X bounce
    addi t3, zero, 0
    lui t3, 1
    slli t3, t3, 16
    addi t4, zero, 1
    slli t4, t4, 16
    add t3, t3, t4 # t3 = 0x10010000
    
    addi, t4, zero, 16 
    slli, t4, t4, 15 # t4 = 512 rows of memory address
    add t3, t3, t4 # t3 = 512 rows into memory
    addi t3, t3, -2048 # t0 = 511 rows into memory
    blt t3, t0, MOVE_0_BOUNCE
    
    beq zero, zero, DRAW
MOVE_0_BOUNCE:
    addi t2, zero, 4
    sub t0, t0, t1
    sub t0, t0, t1
    beq zero, zero, DRAW
    
    
# +X, +Y
MOVE_1: 
    add t0, t0, t1 # Move
    addi t0, t0, 4
    
    # -X bounce
    addi t3, zero, 0
    lui t3, 1
    slli t3, t3, 16
    addi t4, zero, 1
    slli t4, t4, 16
    add t3, t3, t4 # t3 = 0x10010000
    
    addi, t4, zero, 16 
    slli, t4, t4, 15 # t4 = 512 rows of memory address
    add t3, t3, t4 # t3 = 512 rows into memory
    addi t3, t3, -2048 # t0 = 511 rows into memory
    blt t3, t0, MOVE_1_BOUNCEX
    
    # -Y bounce
    addi t4, zero, 2047 # mask for only position in row
    and t3, t0, t4 # t3 = position in row
    sub t3, t1, t3 # t3 = distance from edge
    #ebreak
    addi t4, zero, 16
    blt t3, t4, MOVE_1_BOUNCEY # Bounce if within 16 memory addresses from end
    
    beq zero, zero, DRAW

MOVE_1_BOUNCEX:
    addi t2, zero, 3 # +X, +Y to -X, +Y
    sub t0, t0, t1
    addi t0, t0, -4 # Undo this move
    beq zero, zero, DRAW

MOVE_1_BOUNCEY:
    addi t2, zero, 7 # +X, -Y to +X, -Y
    sub t0, t0, t1
    addi t0, t0, -4 # Undo this move
    beq zero, zero, DRAW

# +2Y
MOVE_2: 
    addi t0, t0, 8
    
    # -Y bounce
    addi t4, zero, 2047 # mask for only position in row
    and t3, t0, t4 # t3 = position in row
    sub t3, t1, t3 # t3 = distance from edge
    #ebreak
    addi t4, zero, 16
    blt t3, t4, MOVE_2_BOUNCE # Bounce if within 16 memory addresses from end
    beq zero, zero, DRAW
MOVE_2_BOUNCE:
    addi t2, zero, 6
    addi t0, t0, -8 # Undo this move
    beq zero, zero, DRAW

# -X, +Y
MOVE_3: 
    sub t0, t0, t1
    addi t0, t0, 4
    
    # +X bounce
    addi t3, zero, 0
    lui t3, 1
    slli t3, t3, 16
    addi t4, zero, 1
    slli t4, t4, 16
    add t3, t3, t4 # t3 = 0x10010000
    
    blt t0, t3, MOVE_3_BOUNCEX
    
    # -Y bounce
    addi t4, zero, 2047 # mask for only position in row
    and t3, t0, t4 # t3 = position in row
    sub t3, t1, t3 # t3 = distance from edge
    #ebreak
    addi t4, zero, 16
    blt t3, t4, MOVE_3_BOUNCEY # Bounce if within 16 memory addresses from end
    
    beq zero, zero, DRAW

MOVE_3_BOUNCEX:
    addi t2, zero, 1 # -X, +Y to +X, +Y
    add t0, t0, t1
    addi t0, t0, -4 # Undo this move
    beq zero, zero, DRAW

MOVE_3_BOUNCEY:
    addi t2, zero, 5 # -X, +Y to -X, -Y
    add t0, t0, t1
    addi t0, t0, -4 # Undo this move
    beq zero, zero, DRAW


# -2X
MOVE_4: 
    sub t0, t0, t1
    sub t0, t0, t1
    
    # +X bounce
    addi t3, zero, 0
    lui t3, 1
    slli t3, t3, 16
    addi t4, zero, 1
    slli t4, t4, 16
    add t3, t3, t4 # t3 = 0x10010000
    
    blt t0, t3, MOVE_4_BOUNCE
    
    beq zero, zero, DRAW
MOVE_4_BOUNCE:
    addi t2, zero, 0
    add t0, t0, t1
    add t0, t0, t1
    beq zero, zero, DRAW

# -X, -Y
MOVE_5: 
    sub t0, t0, t1
    addi t0, t0, -4
    
    # +X bounce
    addi t3, zero, 0
    lui t3, 1
    slli t3, t3, 16
    addi t4, zero, 1
    slli t4, t4, 16
    add t3, t3, t4 # t3 = 0x10010000
    
    blt t0, t3, MOVE_5_BOUNCEX
    
    # +Y bounce
    addi t4, zero, 2047 # mask for only position in row
    and t3, t0, t4 # t3 = position in row
    sub t3, t1, t3 # t3 = distance from edge
    #ebreak
    addi t4, zero, 16
    blt t3, t4, MOVE_5_BOUNCEY # Bounce if within 16 memory addresses from end
    
    beq zero, zero, DRAW

MOVE_5_BOUNCEX:
    addi t2, zero, 7 # -X, -Y to +X, -Y
    add t0, t0, t1
    addi t0, t0, 4 # Undo this move
    beq zero, zero, DRAW
    
MOVE_5_BOUNCEY:
    addi t2, zero, 3 # -X, -Y to -X, +Y
     add t0, t0, t1
    addi t0, t0, 4 # Undo this move
    beq zero, zero, DRAW

# -2Y
MOVE_6: 
    addi t0, t0, -8
    
    # +Y bounce
    addi t4, zero, 2047 # mask for only position in row
    and t3, t0, t4 # t3 = position in row
    sub t3, t1, t3 # t3 = distance from edge
    #ebreak
    addi t4, zero, 16
    blt t3, t4, MOVE_6_BOUNCE # Bounce if within 16 memory addresses from end
    
    beq zero, zero, DRAW
MOVE_6_BOUNCE:
    addi t2, zero, 2
    addi t0, t0, 8 # Undo this move
    beq zero, zero, DRAW

# +X, -Y
MOVE_7: 
    add t0, t0, t1
    addi t0, t0, -4
    
    # -X bounce
    addi t3, zero, 0
    lui t3, 1
    slli t3, t3, 16
    addi t4, zero, 1
    slli t4, t4, 16
    add t3, t3, t4 # t3 = 0x10010000
    
    addi, t4, zero, 16 
    slli, t4, t4, 15 # t4 = 512 rows of memory address
    add t3, t3, t4 # t3 = 512 rows into memory
    addi t3, t3, -2048 # t0 = 511 rows into memory
    blt t3, t0, MOVE_7_BOUNCEX
    
    # +Y bounce
    addi t4, zero, 2047 # mask for only position in row
    and t3, t0, t4 # t3 = position in row
    sub t3, t1, t3 # t3 = distance from edge
    #ebreak
    addi t4, zero, 16
    blt t3, t4, MOVE_7_BOUNCEY # Bounce if within 16 memory addresses from end
    
    beq zero, zero, DRAW
    
MOVE_7_BOUNCEX:
    addi t2, zero, 5 # +X, -Y to -X, +Y
    sub t0, t0, t1
    addi t0, t0, 4 # Undo this move
    beq zero, zero, DRAW

MOVE_7_BOUNCEY:
    addi t2, zero, 1 # +X, -Y to +X, +Y
    sub t0, t0, t1
    addi t0, t0, 4 # Undo this move
    beq zero, zero, DRAW

# The draw code is almost exactly the same as the draw black code from STEP. 
DRAW: 
    addi t6, zero, -1 # color 0xFFFFFFFF = White
    # mem position +0 row, +0 col
    sub t0, t0, t1 # mem position -1 row, +0 col
    sw t6, (t0) # set color t6
    addi t0, t0, -4 # mem position -1 row, -1 col
    sw t6, (t0) # set color t6
    addi t0, t0, 8 # mem position -1 row, +1 col
    sw t6, (t0) # set color t6
    add t0, t0, t1 # mem position +0 row, + 1 col
    sw t6, (t0) # set color t6
    add t0, t0, t1 # mem position +1 row, + 1 col
    sw t6, (t0) # set color t6
    addi t0, t0, -4 # mem position +1 row, +0 col
    sw t6, (t0) # set color t6
    addi t0, t0, -4 # mem position +1 row, -1 col
    sw t6, (t0) # set color t6
    sub t0, t0, t1 # mem position +0 row, -1 col
    sw t6, (t0) # set color t6
    addi t0, t0, 4 # mem position +0 row, +0 col
    sw t6, (t0) # set color t6
    
    # This loop does nothing other than take a long time to run. This helps the code run at a human speed. Also, because the movement code happens between when the old position is drawn over with black and the new position is drawn, this means the ball is drawn for a high percent of the time.
    addi t6, zero, 1
    slli t6, t6, 10
    addi t5, zero, 0
    DRAW_DELAY_LOOP:
        addi t5, t5, 1
        blt t5, t6, DRAW_DELAY_LOOP
    
    beq zero, zero, STEP
    
# END doesn't actually do anything, but was a helpful troubleshooting thing.
END:
and zero, zero, zero


# Testing code that I'd used before and now don't want to delete.

#    # Draw all 0s to display
#    lui t3, 1
#    slli t3, t3, 16
#    addi t6, zero, 1
#    slli t6, t6, 16
#    add t3, t3, t6 # t3 = 0x10010000
#    
#    and t6, zero, zero # t6 = 0
#    #addi t5, zero, 75 # t5 = 75
#    #slli t5, t5, 10 # t5 = 76800 (320*240)
#    addi t5, zero, 1 # t5 = 1
#    slli t5, t5, 17 # t5 = 131072 (512*256)
#    LOOP_START_1: 
#        sw zero, (t3)
#        addi t3, t3, 4
#        addi t6, t6, 1 # t6 = t6 + 1
#        blt t6, t5, LOOP_START_1
#    
#    # Draw all 0xFFFFFFFFs to display
#    lui t3, 1
#    slli t3, t3, 16
#    addi t6, zero, 1
#    slli t6, t6, 16
#    add t3, t3, t6
#    
#    and t6, zero, zero # t6 = 0
#    addi t5, zero, 75 # t5 = 75
#    slli t5, t5, 10 # t5 = 76800 (320*240)
#    addi t5, zero, 1 # t5 = 1
#    slli t5, t5, 17 # t5 = 131072 (512*256)
#    addi t4, zero, -1 # t4 = -1 = 0xFFFFFFFF
#    
#
#
#    LOOP_START_2: 
#        sw t4, (t3)
#        addi, t3, t3, 4
#        addi t6, t6, 1 # t6 = t6 + 1
#        blt t6, t5, LOOP_START_2
#        
#    beq zero, zero, DRAW
