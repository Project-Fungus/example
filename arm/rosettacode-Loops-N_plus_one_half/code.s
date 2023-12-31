/* ARM assembly Raspberry PI  */
/*  program loopnplusone.s   */

/* Constantes    */
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ WRITE,  4     @ Linux syscall

/*********************************/
/* Initialized data              */
/*********************************/
.data
szMessResult:      .ascii ""                    @ message result
sMessValeur:       .fill 11, 1, ' '
szMessComma:       .asciz ","
szCarriageReturn:  .asciz "\n"
/*********************************/
/* UnInitialized data            */
/*********************************/
.bss 
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                                       @ entry of program 
    mov r4,#1                               @ loop counter
1:                                          @ begin loop 
    mov r0,r4
    ldr r1,iAdrsMessValeur                  @ display value
    bl conversion10                         @ decimal conversion
    ldr r0,iAdrszMessResult
    bl affichageMess                        @ display message
    ldr r0,iAdrszMessComma
    bl affichageMess                        @ display comma
    add r4,#1                               @ increment counter
    cmp r4,#10                              @ end ?
    blt 1b                                  @ no ->begin loop one
    mov r0,r4
    ldr r1,iAdrsMessValeur                  @ display value
    bl conversion10                         @ decimal conversion
    ldr r0,iAdrszMessResult
    bl affichageMess                        @ display message
    ldr r0,iAdrszCarriageReturn
    bl affichageMess                        @ display return line

100:                                        @ standard end of the program 
    mov r0, #0                              @ return code
    mov r7, #EXIT                           @ request to exit program
    svc #0                                  @ perform the system call

iAdrsMessValeur:          .int sMessValeur
iAdrszMessResult:         .int szMessResult
iAdrszMessComma:          .int szMessComma
iAdrszCarriageReturn:     .int szCarriageReturn
/******************************************************************/
/*     display text with size calculation                         */ 
/******************************************************************/
/* r0 contains the address of the message */
affichageMess:
    push {r0,r1,r2,r7,lr}                   @ save  registres
    mov r2,#0                               @ counter length 
1:                                          @ loop length calculation 
    ldrb r1,[r0,r2]                         @ read octet start position + index 
    cmp r1,#0                               @ if 0 its over 
    addne r2,r2,#1                          @ else add 1 in the length 
    bne 1b                                  @ and loop 
                                            @ so here r2 contains the length of the message 
    mov r1,r0                               @ address message in r1 
    mov r0,#STDOUT                          @ code to write to the standard output Linux 
    mov r7, #WRITE                          @ code call system "write" 
    svc #0                                  @ call systeme 
    pop {r0,r1,r2,r7,lr}                    @ restaur registers */ 
    bx lr                                   @ return  
/******************************************************************/
/*     Converting a register to a decimal                                 */ 
/******************************************************************/
/* r0 contains value and r1 address area   */
.equ LGZONECAL,   10
conversion10:
    push {r1-r4,lr}                         @ save registers 
    mov r3,r1
    mov r2,#LGZONECAL

1:                                          @ start loop
    bl divisionpar10                        @ r0 <- dividende. quotient ->r0 reste -> r1
    add r1,#48                              @ digit
    strb r1,[r3,r2]                         @ store digit on area
    sub r2,#1                               @ previous position
    cmp r0,#0                               @ stop if quotient = 0 
    bne 1b                                  @ else loop
                                            @ end replaces digit in front of area
    mov r4,#0
2:
    ldrb r1,[r3,r2] 
    strb r1,[r3,r4]                         @ store in area begin
    add r4,#1
    add r2,#1                               @ previous position
    cmp r2,#LGZONECAL                       @ end
    ble 2b                                  @ loop
    mov r1,#0                               @ final zero 
    strb r1,[r3,r4]
100:
    pop {r1-r4,lr}                          @ restaur registres 
    bx lr                                   @return
/***************************************************/
/*   division par 10   signé                       */
/* Thanks to http://thinkingeek.com/arm-assembler-raspberry-pi/*  
/* and   http://www.hackersdelight.org/            */
/***************************************************/
/* r0 dividende   */
/* r0 quotient */	
/* r1 remainder  */
divisionpar10:	
  /* r0 contains the argument to be divided by 10 */
    push {r2-r4}                           @ save registers  */
    mov r4,r0  
    mov r3,#0x6667                         @ r3 <- magic_number  lower
    movt r3,#0x6666                        @ r3 <- magic_number  upper
    smull r1, r2, r3, r0                   @ r1 <- Lower32Bits(r1*r0). r2 <- Upper32Bits(r1*r0) 
    mov r2, r2, ASR #2                     @ r2 <- r2 >> 2
    mov r1, r0, LSR #31                    @ r1 <- r0 >> 31
    add r0, r2, r1                         @ r0 <- r2 + r1 
    add r2,r0,r0, lsl #2                   @ r2 <- r0 * 5 
    sub r1,r4,r2, lsl #1                   @ r1 <- r4 - (r2 * 2)  = r4 - (r0 * 10)
    pop {r2-r4}
    bx lr                                  @ return