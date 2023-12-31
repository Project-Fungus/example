/* ARM assembly Raspberry PI  */
/*  program Ycombi.s   */

/* REMARK 1 : this program use routines in a include file 
   see task Include a file language arm assembly 
   for the routine affichageMess conversion10 
   see at end of this program the instruction include */

/* Constantes    */
.equ STDOUT, 1                           @ Linux output console
.equ EXIT,   1                           @ Linux syscall
.equ WRITE,  4                           @ Linux syscall


/*******************************************/
/* Structures                               */
/********************************************/
/* structure function*/
    .struct  0
func_fn:                    @ next element
    .struct  func_fn + 4 
func_f_:                    @ next element
    .struct  func_f_ + 4 
func_num:
    .struct  func_num + 4 
func_fin:

/* Initialized data */
.data
szMessStartPgm:            .asciz "Program start \n"
szMessEndPgm:              .asciz "Program normal end.\n"
szMessError:               .asciz "\033[31mError Allocation !!!\n"

szFactorielle:             .asciz "Function factorielle : \n"
szFibonacci:               .asciz "Function Fibonacci : \n"
szCarriageReturn:          .asciz "\n"

/* datas message display */
szMessResult:            .ascii "Result value :"
sValue:                  .space 12,' '
                         .asciz "\n"

/* UnInitialized data */
.bss 

/*  code section */
.text
.global main 
main:                                           @ program start
    ldr r0,iAdrszMessStartPgm                   @ display start message
    bl affichageMess
    adr r0,facFunc                              @ function factorielle address
    bl YFunc                                    @ create Ycombinator
    mov r5,r0                                   @ save Ycombinator
    ldr r0,iAdrszFactorielle                    @ display message
    bl affichageMess
    mov r4,#1                                   @ loop counter
1:  @ start loop
    mov r0,r4
    bl numFunc                                  @ create number structure
    cmp r0,#-1                                  @ allocation error ?
    beq 99f
    mov r1,r0                                   @ structure number address
    mov r0,r5                                   @ Ycombinator address
    bl callFunc                                 @ call 
    ldr r0,[r0,#func_num]                       @ load result
    ldr r1,iAdrsValue                           @ and convert ascii string
    bl conversion10
    ldr r0,iAdrszMessResult                     @ display result message
    bl affichageMess
    add r4,#1                                   @ increment loop counter
    cmp r4,#10                                  @ end ?
    ble 1b                                      @ no -> loop
/*********Fibonacci  *************/
    adr r0,fibFunc                              @ function factorielle address
    bl YFunc                                    @ create Ycombinator
    mov r5,r0                                   @ save Ycombinator
    ldr r0,iAdrszFibonacci                      @ display message
    bl affichageMess
    mov r4,#1                                   @ loop counter
2:  @ start loop
    mov r0,r4
    bl numFunc                                  @ create number structure
    cmp r0,#-1                                  @ allocation error ?
    beq 99f
    mov r1,r0                                   @ structure number address
    mov r0,r5                                   @ Ycombinator address
    bl callFunc                                 @ call 
    ldr r0,[r0,#func_num]                       @ load result
    ldr r1,iAdrsValue                           @ and convert ascii string
    bl conversion10
    ldr r0,iAdrszMessResult                     @ display result message
    bl affichageMess
    add r4,#1                                   @ increment loop counter
    cmp r4,#10                                  @ end ?
    ble 2b                                      @ no -> loop
    ldr r0,iAdrszMessEndPgm                     @ display end message
    bl affichageMess
    b 100f
99:                                             @ display error message 
    ldr r0,iAdrszMessError
    bl affichageMess
100:                                            @ standard end of the program
    mov r0, #0                                  @ return code
    mov r7, #EXIT                               @ request to exit program
    svc 0                                       @ perform system call
iAdrszMessStartPgm:        .int szMessStartPgm
iAdrszMessEndPgm:          .int szMessEndPgm
iAdrszFactorielle:         .int szFactorielle
iAdrszFibonacci:           .int szFibonacci
iAdrszMessError:           .int szMessError
iAdrszCarriageReturn:      .int szCarriageReturn
iAdrszMessResult:          .int szMessResult
iAdrsValue:                .int sValue
/******************************************************************/
/*     factorielle function                         */ 
/******************************************************************/
/* r0 contains the Y combinator address  */
/* r1 contains the number structure  */
facFunc:
    push {r1-r3,lr}             @ save  registers 
    mov r2,r0                   @ save Y combinator address
    ldr r0,[r1,#func_num]       @ load number
    cmp r0,#1                   @ > 1 ?
    bgt 1f                      @ yes
    mov r0,#1                   @ create structure number value 1
    bl numFunc
    b 100f
1:
    mov r3,r0                   @ save number
    sub r0,#1                   @ decrement number
    bl numFunc                  @ and create new structure number
    cmp r0,#-1                  @ allocation error ?
    beq 100f
    mov r1,r0                   @ new structure number -> param 1
    ldr r0,[r2,#func_f_]        @ load function address to execute
    bl callFunc                 @ call
    ldr r1,[r0,#func_num]       @ load new result
    mul r0,r1,r3                @ and multiply by precedent
    bl numFunc                  @ and create new structure number
                                @ and return her address in r0
100:
    pop {r1-r3,lr}              @ restaur registers
    bx lr                       @ return
/******************************************************************/
/*     fibonacci function                         */ 
/******************************************************************/
/* r0 contains the Y combinator address  */
/* r1 contains the number structure  */
fibFunc:
    push {r1-r4,lr}             @ save  registers 
    mov r2,r0                   @ save Y combinator address
    ldr r0,[r1,#func_num]       @ load number
    cmp r0,#1                   @ > 1 ?
    bgt 1f                      @ yes
    mov r0,#1                   @ create structure number value 1
    bl numFunc
    b 100f
1:
    mov r3,r0                   @ save number
    sub r0,#1                   @ decrement number
    bl numFunc                  @ and create new structure number
    cmp r0,#-1                  @ allocation error ?
    beq 100f
    mov r1,r0                   @ new structure number -> param 1
    ldr r0,[r2,#func_f_]        @ load function address to execute
    bl callFunc                 @ call
    ldr r4,[r0,#func_num]       @ load new result
    sub r0,r3,#2                @ new number - 2
    bl numFunc                  @ and create new structure number
    cmp r0,#-1                  @ allocation error ?
    beq 100f
    mov r1,r0                   @ new structure number -> param 1
    ldr r0,[r2,#func_f_]        @ load function address to execute
    bl callFunc                 @ call
    ldr r1,[r0,#func_num]       @ load new result
    add r0,r1,r4                @ add two results
    bl numFunc                  @ and create new structure number
                                @ and return her address in r0
100:
    pop {r1-r4,lr}              @ restaur registers
    bx lr                       @ return
/******************************************************************/
/*     call function                         */ 
/******************************************************************/
/* r0 contains the address of the function  */
/* r1 contains the address of the function 1 */
callFunc:
    push {r2,lr}                                @ save  registers 
    ldr r2,[r0,#func_fn]                        @ load function address to execute
    blx r2                                      @ and call it
    pop {r2,lr}                                 @ restaur registers
    bx lr                                       @ return
/******************************************************************/
/*     create Y combinator function                         */ 
/******************************************************************/
/* r0 contains the address of the function  */
YFunc:
    push {r1,lr}                                @ save  registers 
    mov r1,#0
    bl newFunc
    cmp r0,#-1                                  @ allocation error ?
    strne r0,[r0,#func_f_]                      @ store function and return in r0
    pop {r1,lr}                                 @ restaur registers
    bx lr                                       @ return
/******************************************************************/
/*     create structure number function                         */ 
/******************************************************************/
/* r0 contains the number  */
numFunc:
    push {r1,r2,lr}                             @ save  registers 
    mov r2,r0                                   @ save number
    mov r0,#0                                   @ function null
    mov r1,#0                                   @ function null
    bl newFunc
    cmp r0,#-1                                  @ allocation error ?
    strne r2,[r0,#func_num]                     @ store number in new structure
    pop {r1,r2,lr}                              @ restaur registers
    bx lr                                       @ return
/******************************************************************/
/*     new function                                               */ 
/******************************************************************/
/* r0 contains the function address   */
/* r1 contains the function address 1   */
newFunc:
    push {r2-r7,lr}                             @ save  registers 
    mov r4,r0                                   @ save address
    mov r5,r1                                   @ save adresse 1
    @ allocation place on the heap
    mov r0,#0                                   @ allocation place heap
    mov r7,#0x2D                                @ call system 'brk'
    svc #0
    mov r3,r0                                   @ save address heap for output string
    add r0,#func_fin                            @ reservation place one element
    mov r7,#0x2D                                @ call system 'brk'
    svc #0
    cmp r0,#-1                                  @ allocation error
    beq 100f
    mov r0,r3
    str r4,[r0,#func_fn]                        @ store address
    str r5,[r0,#func_f_]
    mov r2,#0
    str r2,[r0,#func_num]                       @ store zero to number
100:
    pop {r2-r7,lr}                              @ restaur registers
    bx lr                                       @ return
/***************************************************/
/*      ROUTINES INCLUDE                 */
/***************************************************/
.include "../affichage.inc"

Program start
Function factorielle :
Result value :1
Result value :2
Result value :6
Result value :24
Result value :120
Result value :720
Result value :5040
Result value :40320
Result value :362880
Result value :3628800
Function Fibonacci :
Result value :1
Result value :2
Result value :3
Result value :5
Result value :8
Result value :13
Result value :21
Result value :34
Result value :55
Result value :89
Program normal end.