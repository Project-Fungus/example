/* ARM assembly Raspberry PI  */
/*  program perfectNumber.s   */

 /* REMARK 1 : this program use routines in a include file 
   see task Include a file language arm assembly 
   for the routine affichageMess conversion10 
   see at end of this program the instruction include */
/* for constantes see task include a file in arm assembly */
/************************************/
/* Constantes                       */
/************************************/
.include "../constantes.inc"

.equ MAXI,      1<<31

/*********************************/
/* Initialized data              */
/*********************************/
.data
sMessResultPerf:    .asciz "Perfect  : @ \n"
szCarriageReturn:   .asciz "\n"

/*********************************/
/* UnInitialized data            */
/*********************************/
.bss  
sZoneConv:                  .skip 24
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                             @ entry of program 
    mov r2,#2                     @ begin first number
1:                                @ begin loop 
    mov r5,#1                     @ sum
    mov r4,#2                     @ first divisor 1
2:
    udiv r0,r2,r4                 @ compute divisor 2
    mls r3,r0,r4,r2               @ remainder
    cmp r3,#0
    bne 3f                        @ remainder = 0 ?
    add r5,r5,r0                  @ add divisor 2
    add r5,r5,r4                  @ add divisor 1
3:
    add r4,r4,#1                  @ increment divisor
    cmp r4,r0                     @ divisor 1  < divisor 2
    blt 2b                        @ yes -> loop
    cmp r2,r5                     @ compare number and divisors sum
    bne 4f                        @ not equal
    mov r0,r2                     @ equal -> display
    ldr r1,iAdrsZoneConv
    bl conversion10               @ call décimal conversion
    ldr r0,iAdrsMessResultPerf
    ldr r1,iAdrsZoneConv          @ insert conversion in message
    bl strInsertAtCharInc
    bl affichageMess              @ display message
4: 
    add r2,#2                     @ no perfect number odd < 10 puis 1500
    cmp r2,#MAXI                  @ end ?
    blo 1b                        @ no -> loop

100:                              @ standard end of the program 
    mov r0, #0                    @ return code
    mov r7, #EXIT                 @ request to exit program
    svc #0                        @ perform the system call
iAdrszCarriageReturn:    .int szCarriageReturn
iAdrsMessResultPerf:     .int sMessResultPerf
iAdrsZoneConv:           .int sZoneConv  

/***************************************************/
/*      ROUTINES INCLUDE                           */
/***************************************************/
.include "../affichage.inc"

Perfect  : 6
Perfect  : 28
Perfect  : 496
Perfect  : 8128
Perfect  : 33550336