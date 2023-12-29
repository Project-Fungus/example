.global main

message:
    .asciz "Hello world!\n"
    .align 4

main:
    ldr r0, =message
    bl printf

    mov r7, #1
    swi 0

 Developed on an Acorn A5000 with RISC OS 3.10 (30 Apr 1992)
 Using the assembler contained in ARM BBC BASIC V version 1.05 (c) Acorn 1989

The Acorn A5000 is the individual computer used to develop the code,
the code is applicable to all the Acorn Risc Machines (ARM)
produced by Acorn and the StrongARM produced by digital.

 In the BBC BASIC part of the program I have included:
    OS_WriteC  = &00
    OS_WriteO  = &02
    OS_NewLine = &03
 this is so I can write SWI OS_WriteC etc instead of SWI &0 to make the assembler more legible

 (a) method1 - output the text character by character until the terminating null (0) is seen

     .method1_vn00
           ADR     R8  , method1_string    \ the ARM does not have an ADR instruction
                                           \ the assembler will work out how far the data item
                                           \ is from here (in this case a +ve relative offset)
                                           \ and so will produce an ADD R8 , PC, offset to method1_string
                                           \ a magic trick by the ARM assembler

     .method1_loop
           LDRB     R0  , [R8], #1         \ load the byte found at address in R8 into R0
                                           \ then post increment the address in R8 in preparation
                                           \ for the next byte (the #1 is my choice for the increment)
           CMP      R0  , #0               \ has the terminating null (0) been reached
           SWINE    OS_WriteC              \ when not the null output the character in R0
                                           \ (every opportunity to have a SWINE in your program should be taken)
           BNE      method1_loop           \ go around the loop for the next character if not reached the null

           SWI      OS_NewLine             \ up to you if you want a newline

           MOVS     PC  , R14              \ return
                                           \ when I call an operating system function it no longer operates
                                           \ in 'user mode' and it has its own R14, and anyway the operating system
                                           \ is too polite to write rubbish into this return address


     .method1_string
           EQUS "Hello world!"             \ the string to be output
           EQUB &00                        \ a terminating null (0)
           ALIGN                           \ tell the assembler to ensure that the next item is on a word boundary




 (b) method2 - get the supplied operating system to do the work

     .method2_vn00
           ADR     R0   , method2_string   \ the ARM does not have an ADR instruction
                                           \ the assembler will work out how far the data item
                                           \ is from here (in this case a +ve relative offset)
                                           \ and so will produce an ADD R0 , PC, offset to method2_string
                                           \ a magic trick by the ARM assembler

           SWI      OS_WriteO              \ R0 = pointer to null-terminated string to write

           SWI      OS_NewLine             \ up to you if you want a newline

           MOVS    PC   , R14              \ return
 
     .method2_string
           EQUS "hELLO WORLD!"             \ the string to be output
           EQUB &00                        \ a terminating null (0)
           ALIGN                           \ tell the assembler to ensure that the next item is on a word boundary