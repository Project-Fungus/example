/* ARM assembly Raspberry PI  */
/*  program integerName.s   */ 

/* REMARK 1 : this program use routines in a include file 
   see task Include a file language arm assembly 
   for the routine affichageMess conversion10 
   see at end of this program the instruction include */
/* for constantes see task include a file in arm assembly */
/************************************/
/* Constantes                       */
/************************************/
.include "../constantes.inc"

.equ MAXI,   127

/*********************************/
/* Initialized data              */
/*********************************/
.data
sMessResult:        .asciz "Total  : @  \n"
szMessError:        .asciz "Number too large !!.\n"
szCarriageReturn:   .asciz "\n"
/*********************************/
/* UnInitialized data            */
/*********************************/
.bss
sZoneConv:        .skip 24
tbNames:          .skip 4 * MAXI
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                                 @ entry of program 
    
    mov r0,#5
    bl functionG
    
    mov r0,#23
    bl functionG

    mov r0,#123
    bl functionG
    
    mov r0,#1234
    bl functionG
    
100:                                  @ standard end of the program 
    mov r0, #0                        @ return code
    mov r7, #EXIT                     @ request to exit program
    svc #0                            @ perform the system call
 
iAdrszCarriageReturn:     .int szCarriageReturn
iAdrsMessResult:          .int sMessResult
iAdrtbNames:               .int tbNames
iAdrsZoneConv:            .int sZoneConv
/******************************************************************/
/*            compute function G                                 */ 
/******************************************************************/
/* r0 contains N */
functionG:
    push {r1-r3,lr}              @ save registers
    cmp r0,#MAXI + 1
    bge 2f
    mov r3,r0
    mov r2,#1
1:                               @ loop compute every item
    mov r0,r2
    bl computeNumber
    add r2,r2,#1
    cmp r2,r3
    ble 1b
 
    ldr r1,iAdrsZoneConv         @ result display
    bl conversion10              @ call decimal conversion
    ldr r0,iAdrsMessResult
    ldr r1,iAdrsZoneConv         @ insert conversion in message
    bl strInsertAtCharInc
    bl affichageMess
    mov r0,#0
    b 100f
2:
    ldr r0,iAdrszMessError
    bl affichageMess
    mov r0,#-1
100:
    pop {r1-r3,lr}
    bx lr                         @ return 
iAdrszMessError:         .int szMessError
/******************************************************************/
/*            random door test strategy                           */ 
/******************************************************************/
/* r0 contains N */
computeNumber:
    push {r1-r7,lr}              @ save registers
    ldr r6,iAdrtbNames           @ table address
    mov r1,#1
    str r1,[r6]                  @ init item 0
    mov r1,#0
    str r1,[r6,r0,lsl #2]        @ init item N
    mov r2,#1                    @ indice
1:
    add r3,r2,r2, lsl #1
    sub r4,r3,#1
    mul r4,r2,r4
    lsr r4,r4,#1
    subs r3,r0,r4                @ compute new indice
    blt 90f
    tst r2,#1                    @ indice owen ?
    beq 2f
    ldr r4,[r6,r3,lsl #2]
    ldr r5,[r6,r0,lsl #2]
    add r5,r5,r4                 @ addition
    str r5,[r6,r0,lsl #2]
    b 3f
2:                               @ else substrac
    ldr r4,[r6,r3,lsl #2]
    ldr r5,[r6,r0,lsl #2]
    sub r5,r5,r4
    str r5,[r6,r0,lsl #2]
3:
    subs r3,r3,r2                @ compute new indice
    blt 90f
    
    tst r2,#1                    @ owen ?
    beq 4f
    ldr r4,[r6,r3,lsl #2]
    ldr r5,[r6,r0,lsl #2]
    add r5,r5,r4
    str r5,[r6,r0,lsl #2]
    b 5f
4:
    ldr r4,[r6,r3,lsl #2]
    ldr r5,[r6,r0,lsl #2]
    sub r5,r5,r4
    str r5,[r6,r0,lsl #2]
5:
    add r2,r2,#1
    cmp r2,r0
    ble 1b
90:
   ldr r0,[r6,r0,lsl #2]         @ return last item of table
100:
    pop {r1-r7,lr}
    bx lr                        @ return 

/***************************************************/
/*      ROUTINES INCLUDE                           */
/***************************************************/
.include "../affichage.inc"

Total  : 7
Total  : 1255
Total  : 2552338241
Number too large !!.