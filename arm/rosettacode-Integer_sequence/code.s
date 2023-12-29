.text
.global main

@ An ARM program that keeps incrementing R0 forever
@
@ If desired, a call to some 'PRINT' routine --
@ which would depend on the OS -- could be included

main:
        mov   r0,   #0          @ start with R0 = 0
        
repeat:
        @ call to 'PRINT' routine
        add   r0,   r0,   #1    @ increment R0
        b     repeat            @ unconditional branch

 
 Developed on an Acorn A5000 with RISC OS 3.10 (30 Apr 1992)
 Using the assembler contained in ARM BBC BASIC V version 1.05 (c) Acorn 1989

The Acorn A5000 is the individual computer used to develop the code,
the code is applicable to all the Acorn Risc Machines (ARM)
produced by Acorn and the StrongARM produced by digital.

 
 Investigation (a)
    If all that was needed was to increment without doing the required display part of the task
    then:
 
       .a_loop
             ADDS   R0 , R0, #1
             ADCS   R1 , R1, #0
             ADCS   R2 , R2, #0
             ADCS   R3 , R3, #0
             B      a_loop
    will count a 128 bit number
 
 Investigation (b)
    How long does it take?
 
       .b_loop_01                      \ took 71075 cs = 11.85 mins
             ADDS   R0, R0, #1         \ only a single ADD in the loop - unable to get the pipeline going
             B      B_loop_01
 
       .b_loop_04                      \ took 31100 cs = 5.18 mins
             ADDS   R0, R0, #1         \ with four instructions within the loop
             ADDS   R0, R0, #1
             ADDS   R0, R0, #1
             ADDS   R0, R0, #1
             B      B_loop_04
 
       .b_loop_16                      \ took 21112 cs = 3.52 mins
             ADDS   R0, R0, #1         \ with sixteen instructions within the loop
 
             followed by a further 15 ADDS instructions
 
             B      B_loop_16
 
    so there clearly is a time advantage to putting enough inline instructions to make the pipeline effective
 
    But beware - for a 64 bit number (paired ADDS and ADCS) it took 38903 cs = 6.48 mins to count to only 32 bits,
                 a 128 bit number will take 4,294,967,296 * 4,294,967,296 * 4,294,967,296 times 6.48 mins.
                 My pet rock will tell you how long that took as it will have evolved into a sentient being by then.
 
 
 
 The task
       Producing a solution in say 64 bits or 128 bits is trivial when only looking at the increment.
       Hovever the display part of the task is very difficult.
 
       So instead go for BCD in as many bits as required. This makes the increment more involved, but
       the display part of the task becomes manageable.
 
 So a solution is:
 
 .bcd_32bits_vn02
 
       MOV     R4   , #0               \ if eventually 4 registers each with 8 BCD
       MOV     R5   , #0               \ then 32 digits total
       MOV     R6   , #0
       MOV     R7   , #0
 
       MOV     R8   , #0               \ general workspace
       MOV     R9   , #0               \ a flag in the display - either doing leading space or digits
 
       MVN     R10    #&0000000F       \ preset a mask of &FFFFFFF0
                                       \ preset in R10 as the ARM has a very limited
                                       \ range of immediate literals
       MOV     R11  , #&F              \ preset so can be used in AND etc together with shifts
 
       B       bcd_32bits_loop_vn02    \ intentionally jump to inside the loop as this
                                       \ single branch saves the need for multiple branches
                                       \ later on (every branch resets the instruction pipeline)
 
       \ the repeated blocks of code could be extracted into routines, however as they are small
       \ I have decided to keep them as inline code as I have decided that the improved execution
       \ from better use of the pipeline is greater than the small overall code size
 
 
 .bcd_32bits_display_previous_number_vn02
       MOV     R9   , #0               \ start off with leading spaces (when R9<>0 output "0" instead)
 
       ANDS    R8   , R11 , R4, LSR#28 \ extract just the BCD in bits 28 to 31 of R4
       MOVNE   R9   , #1               \ if the BCD is non-zero then stop doing leading spaces
       CMP     R9   , #0               \ I could not find a way to eliminate this CMP
       MOVEQ   R0   , #&20             \ leading space
       ORRNE   R0   , R8  , #&30       \ digit 0 to 9 all ready for output
       SWI     OS_WriteC               \ output the byte in R0
 
       ANDS    R8   , R11 , R4, LSR#24 \ extract just the BCD in bits 24 to 27 of R4
       MOVNE   R9   , #1
       CMP     R9   , #0
       MOVEQ   R0   , #&20
       ORRNE   R0   , R8  , #&30
       SWI     OS_WriteC
 
       ANDS    R8   , R11 , R4, LSR#20 \ extract just the BCD in bits 20 to 23 of R4
       MOVNE   R9   , #1
       CMP     R9   , #0
       MOVEQ   R0   , #&20
       ORRNE   R0   , R8  , #&30
       SWI     OS_WriteC
 
       ANDS    R8   , R11 , R4, LSR#16 \ extract just the BCD in bits 16 to 19 of R4
       MOVNE   R9   , #1
       CMP     R9   , #0
       MOVEQ   R0   , #&20
       ORRNE   R0   , R8  , #&30
       SWI     OS_WriteC
 
       ANDS    R8   , R11 , R4, LSR#12 \ extract just the BCD in bits 12 to 15 of R4
       MOVNE   R9   , #1
       CMP     R9   , #0
       MOVEQ   R0   , #&20
       ORRNE   R0   , R8  , #&30
       SWI     OS_WriteC
 
       ANDS    R8   , R11 , R4, LSR#8  \ extract just the BCD in bits 8 to 11 of R4
       MOVNE   R9   , #1
       CMP     R9   , #0
       MOVEQ   R0   , #&20
       ORRNE   R0   , R8  , #&30
       SWI     OS_WriteC
 
       ANDS    R8   , R11 , R4, LSR#4  \ extract just the BCD in bits 4 to 7 of R4
       MOVNE   R9   , #1
       CMP     R9   , #0
       MOVEQ   R0   , #&20
       ORRNE   R0   , R8  , #&30
       SWI     OS_WriteC
 
       \ have reached the l.s. BCD - so will always output a digit, never a space
       AND     R8   , R11 , R4         \ extract just the BCD in bits 0 to 3 of R4
       ORR     R0   , R8  , #&30       \ digits 0 to 9 all ready for output
       SWI     OS_WriteC               \ output the byte in R0
 
       MOV     R0   , #&13             \ carriage return
       SWI     OS_WriteC
       MOV     R0   , #&10             \ line feed
       SWI     OS_WriteC
 
 
       \ there is no need for a branch instruction here
       \ instead just fall through to the next increment
 
 
 .bcd_32bits_loop_vn02
       ADD     R4   , R4  , #1         \ increment the l.s. BCD in bits 0 to 3
       AND     R8   , R4  , #&F        \ extract just the BCD nibble after increment
       CMP     R8   , #10              \ has it reached 10?
                                       \ if not then about to branch to the display code
       BLT     bcd_32bits_display_previous_number_vn02
 
       \ have reached 10
 
       ANDEQ   R4   , R4  , R10        \ R10 contains &FFFFFFF0 so the BCD is set to 0
                                       \ but now need to add in the carry to the next BCD
                                       \ I have noticed that the EQ is superfluous here
                                       \ but it does no harm
 
 
       \ now work with the nibble in bits 4 to 7 (bit 31 is m.s. and bit 0 is l.s.)
       MOV     R4   , R4  , ROR #4     \ rotate R4 right by 4 bits
       ADD     R4   , R4  , #1         \ add in the carry
       AND     R8   , R4  , #&F        \ extract just the BCD nibble after carry added
       CMP     R8   , #10              \ has it reached 10?
                                       \ if less than 10 then rotate back to correct place
                                       \ then branch to the display code
       MOVLT   R4   , R4  , ROR #28    \ finished adding in carry - rotate R4 right by 32-4=28 bits
       BLT     bcd_32bits_display_previous_number_vn02
 
       \ yet another carry
 
       ANDEQ   R4   , R4  , R10        \ R10 contains &FFFFFFF0 so the BCD is set to 0
                                       \ but now need to add in the carry to the next BCD
 
 
       \ now work with the nibble in bits 8 to 11 (bit 31 is m.s. and bit 0 is l.s.)
       MOV     R4   , R4  , ROR #4     \ rotate R4 right by 4 bits
       ADD     R4   , R4  , #1         \ add in the carry
       AND     R8   , R4  , #&F        \ extract just the BCD nibble after carry added
       CMP     R8   , #10              \ has it reached 10?
                                       \ if less than 10 then rotate back to correct place
                                       \ then branch to the display code
       MOVLT   R4   , R4  , ROR #24    \ finished adding in carry - rotate R4 right by 32-8=24 bits
       BLT     bcd_32bits_display_previous_number_vn02
 
       \ yet another carry
 
       ANDEQ   R4   , R4  , R10
 
       \ now work with the nibble in bits 12 to 15 (bit 31 is m.s. and bit 0 is l.s.)
       MOV     R4   , R4  , ROR #4
       ADD     R4   , R4  , #1
       AND     R8   , R4  , #&F
       CMP     R8   , #10
 
       MOVLT   R4   , R4  , ROR #20    \ finished adding in carry - rotate R4 right by 32-12=20 bits
       BLT     bcd_32bits_display_previous_number_vn02
 
       \ yet another carry
 
       ANDEQ   R4   , R4  , R10
 
       \ now work with the nibble in bits 16 to 19 (bit 31 is m.s. and bit 0 is l.s.)
       MOV     R4   , R4  , ROR #4
       ADD     R4   , R4  , #1
       AND     R8   , R4  , #&F
       CMP     R8   , #10
 
       MOVLT   R4   , R4  , ROR #16    \ finished adding in carry - rotate R4 right by 32-16=16 bits
       BLT     bcd_32bits_display_previous_number_vn02
 
       \ yet another carry
 
       ANDEQ   R4   , R4  , R10
 
       \ now work with the nibble in bits 20 to 23 (bit 31 is m.s. and bit 0 is l.s.)
       MOV     R4   , R4  , ROR #4
       ADD     R4   , R4  , #1
       AND     R8   , R4  , #&F
       CMP     R8   , #10
 
       MOVLT   R4   , R4  , ROR #12    \ finished adding in carry - rotate R4 right by 32-20=12 bits
       BLT     bcd_32bits_display_previous_number_vn02
 
       \ yet another carry
 
       ANDEQ   R4   , R4  , R10
 
       \ now work with the nibble in bits 24 to 27 (bit 31 is m.s. and bit 0 is l.s.)
       MOV     R4   , R4  , ROR #4
       ADD     R4   , R4  , #1
       AND     R8   , R4  , #&F
       CMP     R8   , #10
 
       MOVLT   R4   , R4  , ROR #8     \ finished adding in carry - rotate R4 right by 32-24=8 bits
       BLT     bcd_32bits_display_previous_number_vn02
 
       \ yet another carry
 
       ANDEQ   R4   , R4  , R10
 
       \ now work with the nibble in bits 28 to 31 (bit 31 is m.s. and bit 0 is l.s.)
       MOV     R4   , R4  , ROR #4
       ADD     R4   , R4  , #1
       AND     R8   , R4  , #&F
       CMP     R8   , #10
 
       MOVLT   R4   , R4  , ROR #4     \ finished adding in carry - rotate R4 right by 32-28=4 bits
       BLT     bcd_32bits_display_previous_number_vn02
 
       \ yet another carry
 
       ANDEQ   R4   , R4  , R10
 
       \ to continue the carry needs to be added to the next register (probably R5) if more than 8 BCD are required
       \ if yet more than 16 BCD then continue to the next register (R6)
       \ the extra code required will be as above but using R5 (or R6) instead of R4
 
 
       MOVS    PC   , R14              \ return