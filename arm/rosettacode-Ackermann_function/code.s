/* ARM assembly Raspberry PI  or android 32 bits */
/*  program ackermann.s   */ 

/* REMARK 1 : this program use routines in a include file 
   see task Include a file language arm assembly 
   for the routine affichageMess conversion10 
   see at end of this program the instruction include */
/* for constantes see task include a file in arm assembly */
/************************************/
/* Constantes                       */
/************************************/
.include "../constantes.inc"
.equ MMAXI,   4
.equ NMAXI,   10

/*********************************/
/* Initialized data              */
/*********************************/
.data
sMessResult:        .asciz "Result for @  @  : @ \n"
szMessError:        .asciz "Overflow !!.\n"
szCarriageReturn:   .asciz "\n"
 
/*********************************/
/* UnInitialized data            */
/*********************************/
.bss
sZoneConv:        .skip 24
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                           @ entry of program 
    mov r3,#0
    mov r4,#0
1:
    mov r0,r3
    mov r1,r4
    bl ackermann
    mov r5,r0
    mov r0,r3
    ldr r1,iAdrsZoneConv        @ else display odd message
    bl conversion10             @ call decimal conversion
    ldr r0,iAdrsMessResult
    ldr r1,iAdrsZoneConv        @ insert value conversion in message
    bl strInsertAtCharInc
    mov r6,r0
    mov r0,r4
    ldr r1,iAdrsZoneConv        @ else display odd message
    bl conversion10             @ call decimal conversion
    mov r0,r6
    ldr r1,iAdrsZoneConv        @ insert value conversion in message
    bl strInsertAtCharInc
    mov r6,r0
    mov r0,r5
    ldr r1,iAdrsZoneConv        @ else display odd message
    bl conversion10             @ call decimal conversion
    mov r0,r6
    ldr r1,iAdrsZoneConv        @ insert value conversion in message
    bl strInsertAtCharInc
    bl affichageMess
    add r4,#1
    cmp r4,#NMAXI
    blt 1b
    mov r4,#0
    add r3,#1
    cmp r3,#MMAXI
    blt 1b
100:                            @ standard end of the program 
    mov r0, #0                  @ return code
    mov r7, #EXIT               @ request to exit program
    svc #0                      @ perform the system call
 
iAdrszCarriageReturn:     .int szCarriageReturn
iAdrsMessResult:          .int sMessResult
iAdrsZoneConv:            .int sZoneConv
/***************************************************/
/*     fonction ackermann              */
/***************************************************/
// r0 contains a number m
// r1 contains a number n
// r0 return résult
ackermann:
    push {r1-r2,lr}             @ save  registers 
    cmp r0,#0
    beq 5f
    movlt r0,#-1               @ error
    blt 100f
    cmp r1,#0
    movlt r0,#-1               @ error
    blt 100f
    bgt 1f
    sub r0,r0,#1
    mov r1,#1
    bl ackermann
    b 100f
1:
    mov r2,r0
    sub r1,r1,#1
    bl ackermann
    mov r1,r0
    sub r0,r2,#1
    bl ackermann
    b 100f
5:
    adds r0,r1,#1
    bcc 100f
    ldr r0,iAdrszMessError
    bl affichageMess
    bkpt
100:
    pop {r1-r2,lr}             @ restaur registers
    bx lr                      @ return
iAdrszMessError:        .int szMessError
/***************************************************/
/*      ROUTINES INCLUDE                           */
/***************************************************/
.include "../affichage.inc"

Result for 0            0            : 1
Result for 0            1            : 2
Result for 0            2            : 3
Result for 0            3            : 4
Result for 0            4            : 5
Result for 0            5            : 6
Result for 0            6            : 7
Result for 0            7            : 8
Result for 0            8            : 9
Result for 0            9            : 10
Result for 1            0            : 2
Result for 1            1            : 3
Result for 1            2            : 4
Result for 1            3            : 5
Result for 1            4            : 6
Result for 1            5            : 7
Result for 1            6            : 8
Result for 1            7            : 9
Result for 1            8            : 10
Result for 1            9            : 11
Result for 2            0            : 3
Result for 2            1            : 5
Result for 2            2            : 7
Result for 2            3            : 9
Result for 2            4            : 11
Result for 2            5            : 13
Result for 2            6            : 15
Result for 2            7            : 17
Result for 2            8            : 19
Result for 2            9            : 21
Result for 3            0            : 5
Result for 3            1            : 13
Result for 3            2            : 29
Result for 3            3            : 61
Result for 3            4            : 125
Result for 3            5            : 253
Result for 3            6            : 509
Result for 3            7            : 1021
Result for 3            8            : 2045
Result for 3            9            : 4093