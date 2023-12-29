/* ARM assembly Raspberry PI  or android 32 bits */
/*  program AKS.s   */ 

/* REMARK 1 : this program use routines in a include file 
   see task Include a file language arm assembly 
   for the routine affichageMess conversion10 
   see at end of this program the instruction include */
/* for constantes see task include a file in arm assembly */
/************************************/
/* Constantes                       */
/************************************/
.include "../constantes.inc"
.equ MAXI,       32
.equ NUMBERLOOP, 10

/*********************************/
/* Initialized data              */
/*********************************/
.data
szMessResult:        .asciz " (x-1)^@ = "
szMessResult1:       .asciz " @ x^@   "
szMessResPrime:      .asciz "Number @ is prime. \n"
szCarriageReturn:    .asciz "\n"
 
/*********************************/
/* UnInitialized data            */
/*********************************/
.bss
sZoneConv:        .skip 24
iTabCoef:         .skip 4 * MAXI
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                               @ entry of program 

    mov r4,#1
1:                                  @ loop
    mov r0,r4
    bl computeCoef                  @ compute coefficient
    ldr r0,iAdriTabCoef
    mov r0,r4
    bl displayCoef                  @ display coefficient
    add r4,r4,#1
    cmp r4,#NUMBERLOOP
    blt 1b

    mov r4,#1
2:
    mov r0,r4
    bl isPrime                      @ is prime ?
    cmp r0,#1
    bne 3f
    mov r0,r4
    ldr r1,iAdrsZoneConv
    bl conversion10                  @ call decimal conversion
    add r1,r0
    mov r5,#0
    strb r5,[r1]
    ldr r0,iAdrszMessResPrime
    ldr r1,iAdrsZoneConv             @ insert value conversion in message
    bl strInsertAtCharInc
    bl affichageMess
    
3:
    add r4,r4,#1
    cmp r4,#MAXI
    blt 2b
    
100:                                  @ standard end of the program 
    mov r0, #0                        @ return code
    mov r7, #EXIT                     @ request to exit program
    svc #0                            @ perform the system call
 
iAdrszCarriageReturn:     .int szCarriageReturn
iAdrsZoneConv:            .int sZoneConv
iAdriTabCoef:             .int iTabCoef
iAdrszMessResPrime:       .int szMessResPrime
/***************************************************/
/*     display coefficients                        */
/***************************************************/
// r0 contains a number
displayCoef:
    push {r1-r6,lr}             @ save  registers 
    mov r2,r0
    ldr r1,iAdrsZoneConv        @ 
    bl conversion10             @ call decimal conversion
    add r1,r0
    mov r5,#0
    strb r5,[r1]
    ldr r0,iAdrszMessResult
    ldr r1,iAdrsZoneConv        @ insert value conversion in message
    bl strInsertAtCharInc
    bl affichageMess
    ldr r3,iAdriTabCoef
1:
    ldr r0,[r3,r2,lsl #2]
    ldr r1,iAdrsZoneConv        @ 
    bl conversion10S            @ call decimal conversion
2:                              @ removing spaces
    ldrb r6,[r1]
    cmp r6,#' '
    addeq r1,#1
    beq 2b

    ldr r0,iAdrszMessResult1
    bl strInsertAtCharInc
    mov r4,r0
    mov r0,r2
    ldr r1,iAdrsZoneConv        @ else display odd message
    bl conversion10             @ call decimal conversion
    add r1,r0
    mov r5,#0
    strb r5,[r1]
    mov r0,r4
    ldr r1,iAdrsZoneConv        @ insert value conversion in message
    bl strInsertAtCharInc
    bl affichageMess
    subs r2,r2,#1
    bge 1b
    
    ldr r0,iAdrszCarriageReturn
    bl affichageMess
100:
    pop {r1-r6,lr}             @ restaur registers
    bx lr                      @ return
iAdrszMessResult:    .int szMessResult
iAdrszMessResult1:   .int szMessResult1
/***************************************************/
/*     compute coefficient               */
/***************************************************/
// r0 contains a number
computeCoef:
    push {r1-r6,lr}             @ save  registers 
    ldr r1,iAdriTabCoef         @ address coefficient array
    mov r2,#1
    str r2,[r1]                 @ store 1 to coeff [0]
    mov r3,#0                   @ indice 1
1:
    add r4,r3,#1
    mov r5,#1
    str r5,[r1,r4,lsl #2]
    mov r6,r3                   @ indice 2 = indice 1
2:
    cmp r6,#0                   @ zero ? -> end loop
    ble 3f
    sub r4,r6,#1
    ldr r5,[r1,r4,lsl #2]
    ldr r4,[r1,r6,lsl #2]
    sub r5,r5,r4
    str r5,[r1,r6,lsl #2]
    sub r6,r6,#1
    b 2b
3:
    ldr r2,[r1]                 @ inversion coeff [0]
    neg r2,r2
    str r2,[r1]
    add r3,r3,#1
    cmp r3,r0
    blt 1b
    
100:
    pop {r1-r6,lr}             @ restaur registers
    bx lr                      @ return
/***************************************************/
/*     verify number is prime              */
/***************************************************/
// r0 contains a number
isPrime:
    push {r1-r5,lr}             @ save  registers 
    bl computeCoef
    ldr r4,iAdriTabCoef         @ address coefficient array
    ldr r2,[r4]
    add r2,r2,#1
    str r2,[r4]
    ldr r2,[r4,r0,lsl #2]
    sub r2,r2,#1
    str r2,[r4,r0,lsl #2]
    mov r5,r0                  @ number start
    mov r1,r0                  @ divisor
1:
    ldr r0,[r4,r5,lsl #2]      @ load one coeff
    cmp r0,#0                  @ if negative inversion
    neglt r0,r0
    bl division                @ because this routine is number positive only
    cmp r3,#0                  @ remainder = zéro ?
    movne r0,#0                @  if <> no prime
    bne 100f
    subs r5,r5,#1              @ next coef
    bgt 1b
    mov r0,#1                  @ prime
    
100:
    pop {r1-r5,lr}             @ restaur registers
    bx lr                      @ return
/***************************************************/
/*      ROUTINES INCLUDE                           */
/***************************************************/
.include "../affichage.inc"

 (x-1)^1 =  +1 x^1    -1 x^0
 (x-1)^2 =  +1 x^2    -2 x^1    +1 x^0
 (x-1)^3 =  +1 x^3    -3 x^2    +3 x^1    -1 x^0
 (x-1)^4 =  +1 x^4    -4 x^3    +6 x^2    -4 x^1    +1 x^0
 (x-1)^5 =  +1 x^5    -5 x^4    +10 x^3    -10 x^2    +5 x^1    -1 x^0
 (x-1)^6 =  +1 x^6    -6 x^5    +15 x^4    -20 x^3    +15 x^2    -6 x^1    +1 x^0
 (x-1)^7 =  +1 x^7    -7 x^6    +21 x^5    -35 x^4    +35 x^3    -21 x^2    +7 x^1    -1 x^0
 (x-1)^8 =  +1 x^8    -8 x^7    +28 x^6    -56 x^5    +70 x^4    -56 x^3    +28 x^2    -8 x^1    +1 x^0
 (x-1)^9 =  +1 x^9    -9 x^8    +36 x^7    -84 x^6    +126 x^5    -126 x^4    +84 x^3    -36 x^2    +9 x^1    -1 x^0
Number 1 is prime.
Number 2 is prime.
Number 3 is prime.
Number 5 is prime.
Number 7 is prime.
Number 11 is prime.
Number 13 is prime.
Number 17 is prime.
Number 19 is prime.
Number 23 is prime.
Number 29 is prime.
Number 31 is prime.