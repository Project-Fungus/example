/* ARM assembly Raspberry PI  */
/*  program countoctal.s   */
 
/************************************/
/* Constantes                       */
/************************************/
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ WRITE,  4     @ Linux syscall

/*********************************/
/* Initialized data              */
/*********************************/
.data
sMessResult:        .ascii "Count : "
sMessValeur:        .fill 11, 1, ' '            @ size => 11
szCarriageReturn:   .asciz "\n"


/*********************************/
/* UnInitialized data            */
/*********************************/
.bss  
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                                             @ entry of program 
    mov r4,#0                                     @ loop indice
1:                                                @ begin loop
    mov r0,r4
    ldr r1,iAdrsMessValeur
    bl conversion8                                @ call conversion octal
    ldr r0,iAdrsMessResult
    bl affichageMess                              @ display message
    add r4,#1
    cmp r4,#64
    ble 1b


100:                                              @ standard end of the program 
    mov r0, #0                                    @ return code
    mov r7, #EXIT                                 @ request to exit program
    svc #0                                        @ perform the system call
 
iAdrsMessValeur:          .int sMessValeur
iAdrszCarriageReturn:     .int szCarriageReturn
iAdrsMessResult:          .int sMessResult

/******************************************************************/
/*     display text with size calculation                         */ 
/******************************************************************/
/* r0 contains the address of the message */
affichageMess:
    push {r0,r1,r2,r7,lr}                          @ save  registres
    mov r2,#0                                      @ counter length 
1:                                                 @ loop length calculation 
    ldrb r1,[r0,r2]                                @ read octet start position + index 
    cmp r1,#0                                      @ if 0 its over 
    addne r2,r2,#1                                 @ else add 1 in the length 
    bne 1b                                         @ and loop 
                                                   @ so here r2 contains the length of the message 
    mov r1,r0                                      @ address message in r1 
    mov r0,#STDOUT                                 @ code to write to the standard output Linux 
    mov r7, #WRITE                                 @ code call system "write" 
    svc #0                                         @ call systeme 
    pop {r0,r1,r2,r7,lr}                           @ restaur des  2 registres */ 
    bx lr                                          @ return  
/******************************************************************/
/*     Converting a register to octal                             */ 
/******************************************************************/
/* r0 contains value and r1 address area   */
/* r0 return size of result (no zero final in area) */
/* area size => 11 bytes          */
.equ LGZONECAL,   10
conversion8:
    push {r1-r4,lr}                                 @ save registers 
    mov r3,r1
    mov r2,#LGZONECAL
 
1:                                                  @ start loop
    mov r1,r0
    lsr r0,#3                                       @ / by 8
    sub r1,r0,lsl #3                                @ compute remainder r1 - (r0 * 8)
    add r1,#48                                      @ digit
    strb r1,[r3,r2]                                 @ store digit on area
    cmp r0,#0                                       @ stop if quotient = 0 
    subne r2,#1                                     @ else previous position
    bne 1b                                          @ and loop
                                                    @ and move digit from left of area
    mov r4,#0
2:
    ldrb r1,[r3,r2]
    strb r1,[r3,r4]
    add r2,#1
    add r4,#1
    cmp r2,#LGZONECAL
    ble 2b
                                                      @ and move spaces in end on area
    mov r0,r4                                         @ result length 
    mov r1,#' '                                       @ space
3:
    strb r1,[r3,r4]                                   @ store space in area
    add r4,#1                                         @ next position
    cmp r4,#LGZONECAL
    ble 3b                                            @ loop if r4 <= area size
 
100:
    pop {r1-r4,lr}                                    @ restaur registres 
    bx lr                                             @return