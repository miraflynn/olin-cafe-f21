# Pong overview

# Registers
# x0/zero  :   zero
# x1/ra    :   return address
# x2/sp    :   stack pointer
# x3/gp    :   global pointer
# x4/tp    :   thread pointer
# x5/t0    :   TEMP: Ball X (320)
# x6/t1    :   TEMP: Ball Y (240)
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
# STEP  : Do one full game loop of the thing
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


RESET: 
    and t0, zero, zero
    and t1, zero, zero
    and t2, zero, zero
    # beq zero, zero, RESET

STEP: 
    and t6, zero, zero


MOVE: 
    and t6, zero, zero
    # lui t3, 0
    beq t2, t6, STEP_0 # 24
    #addi t6, t6, 1
    #beq t2, t6, STEP_1
    #addi t6, t6, 1
    #beq t2, t6, STEP_2
    #addi t6, t6, 1
    #beq t2, t6, STEP_3
    #addi t6, t6, 1
    #beq t2, t6, STEP_4
    #addi t6, t6, 1
    #beq t2, t6, STEP_5
    #addi t6, t6, 1
    #beq t2, t6, STEP_6
    #addi t6, t6, 1
    #beq t2, t6, STEP_7 # 80


# +X   
STEP_0: 
    addi t0, t0, 2
    #beq zero, zero, DRAW
    beq zero, zero, STEP_0
    
# +X, +Y
STEP_1: 
    addi t0, t0, 1
    addi t1, t1, 1
    beq zero, zero, DRAW

# +Y
STEP_2: 
    addi t1, t1, 2
    beq zero, zero, DRAW

# -X, +Y
STEP_3: 
    addi t0, t0, -1
    addi t1, t1, 1
    beq zero, zero, DRAW

# -X
STEP_4: 
    addi t0, t0, -2 # 128
    beq zero, zero, DRAW

# -X, -Y
STEP_5: 
    addi t0, t0, -1
    addi t1, t1, -1
    beq zero, zero, DRAW

# -Y
STEP_6: 
    and t6, zero, zero # 148
    addi t1, t1, -2
    lui t3, 0
    beq zero, zero, DRAW # 156

# -Y, +X
STEP_7: 
    addi t0, t0, 1
    addi t1, t1, -1
    beq zero, zero, DRAW


DRAW: 
    and t3, zero, zero
    lui s0, 0 # 172
    #beq zero, zero, DRAW
    #beq zero, zero, RESET
#    and t6, zero, zero # t6 = 0
#    addi t5, zero, 75 # t5 = 75
#    slli t5, t5, 10 # t5 = 76800 (320*240)
#    LOOP_START: 
#        sw t0, 0(zero)
#        addi t6, t6, 1 # t6 = t6 + 1
#        blt t6, t5, LOOP_START
#    beq zero, zero, DRAW