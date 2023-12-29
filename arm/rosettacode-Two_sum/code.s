/* ARM assembly Raspberry PI  */
/*  program twosum.s   */

 /* REMARK 1 : this program use routines in a include file 
   see task Include a file language arm assembly 
   for the routine affichageMess conversion10 
   see at end of this program the instruction include */
/* for constantes see task include a file in arm assembly */
/************************************/
/* Constantes                       */
/************************************/
.include "../constantes.inc"

/*********************************/
/* Initialized data              */
/*********************************/
.data
szMessResult:         .asciz "Result : ["
szMessResult1:        .asciz ","
szMessResult2:        .asciz "]\n"
szMessStart:          .asciz "Program 32 bits start.\n"
szCarriageReturn:     .asciz "\n"
szMessErreur:         .asciz "No soluce ! \n"

tabArray:       .int 0, 2, 11, 19, 90
.equ TABARRAYSIZE,    (. - tabArray) / 4
/*********************************/
/* UnInitialized data            */
/*********************************/
.bss
sZoneConv:             .skip 24
sZoneConv1:             .skip 24
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                            @ entry of program 
    ldr r0,iAdrszMessStart
    bl affichageMess
    ldr r0,iAdrtabArray
    mov r1,#21
    bl rechTwoNumbers
    cmp r0,#-1                   @ no soluce
    beq 100f
    mov r2,r1
    ldr r1,iAdrsZoneConv
    bl conversion10              @ decimal conversion
    mov r3,#0
    strb r3,[r1,r0]
    mov r0,r2
    ldr r1,iAdrsZoneConv1
    bl conversion10              @ decimal conversion
    mov r3,#0
    strb r3,[r1,r0]
    mov r0,#5                   @ number string to display
    ldr r1,iAdrszMessResult
    ldr r2,iAdrsZoneConv         @ insert conversion in message
    ldr r3,iAdrszMessResult1
    ldr r4,iAdrsZoneConv1
    push {r4}
    ldr r4,iAdrszMessResult2
    push {r4}
    bl displayStrings            @ display message
    add sp,#8
100:                              @ standard end of the program 
    mov r0, #0                    @ return code
    mov r7, #EXIT                 @ request to exit program
    svc #0                        @ perform the system call
iAdrszCarriageReturn:        .int szCarriageReturn
iAdrsZoneConv:               .int sZoneConv
iAdrsZoneConv1:               .int sZoneConv1
iAdrszMessResult:            .int szMessResult
iAdrszMessResult1:           .int szMessResult1
iAdrszMessResult2:           .int szMessResult2
iAdrszMessErreur:            .int szMessErreur
iAdrszMessStart:             .int szMessStart
iAdrtabArray:                .int tabArray
/******************************************************************/
/*     search two numbers from sum                                */ 
/******************************************************************/
/*  r0  array addressr */
/*  r1  sum  */
/*  r0 return fist index  */
/*  r1 return second index  */
rechTwoNumbers:
    push {r2-r7,lr}            @ save registers
    mov r3,#0                  @ init result
 1:                            @ loop
    ldr r4,[r0,r3,lsl #2]      @ load first number
    mov r5,r3                  @ indice2
 2:
    ldr r6,[r0,r5,lsl #2]      @ load 2th number
    add r7,r6,r4               @ add the two numbers 
    cmp r7,r1                  @ equal to origin
    beq 3f                     @ yes -> ok
    add r5,r5,#1               @ increment indice2
    cmp r5,#TABARRAYSIZE       @ end ?
    blt 2b                     @ no -> loop
    add r3,r3,#1               @ increment indice1
    cmp r3,#TABARRAYSIZE - 1   @ end ?
    blt 1b                     @ no loop 
                               @ not found
    ldr r0,iAdrszMessErreur
    bl affichageMess
    mov r0,#-1
    mov r1,#-1
    b 100f                     @ end
 3:
    mov r0,r3                  @ return results
    mov r1,r5
 100:
    pop {r2-r7,pc}
/***************************************************/
/*   display multi strings                    */
/***************************************************/
/* r0  contains number strings address */
/* r1 address string1 */
/* r2 address string2 */
/* r3 address string3 */
/* other address on the stack */
/* thinck to add  number other address * 4 to add to the stack */
displayStrings:            @ INFO:  displayStrings
    push {r1-r4,fp,lr}     @ save des registres
    add fp,sp,#24          @ save paraméters address (6 registers saved * 4 bytes)
    mov r4,r0              @ save strings number
    cmp r4,#0              @ 0 string -> end
    ble 100f
    mov r0,r1              @ string 1
    bl affichageMess
    cmp r4,#1              @ number > 1
    ble 100f
    mov r0,r2
    bl affichageMess
    cmp r4,#2
    ble 100f
    mov r0,r3
    bl affichageMess
    cmp r4,#3
    ble 100f
    mov r3,#3
    sub r2,r4,#4
1:                         @ loop extract address string on stack
    ldr r0,[fp,r2,lsl #2]
    bl affichageMess
    subs r2,#1
    bge 1b
100:
    pop {r1-r4,fp,pc}


/***************************************************/
/*      ROUTINES INCLUDE                           */
/***************************************************/
.include "../affichage.inc"

Program 32 bits start.
Result : [1,3]