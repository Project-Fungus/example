/* ARM assembly Raspberry PI  */
/*  program loopbreak.s   */

/* Constantes    */
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ WRITE,  4     @ Linux syscall

/*********************************/
/* Initialized data              */
/*********************************/
.data
szMessEndLoop: .asciz "loop break with value : \n"
szMessResult:  .ascii "Resultat = "      @ message result
sMessValeur:   .fill 12, 1, ' '
                   .asciz "\n"
.align 4
iGraine:  .int 123456
/*********************************/
/* UnInitialized data            */
/*********************************/
.bss 
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                @ entry of program 
    push {fp,lr}      @ saves 2 registers 
1:    @ begin loop 
    mov r4,#20
2:
    mov r0,#19
    bl genereraleas               @ generate number
    cmp r0,#10                       @ compar value
    beq 3f                         @ break if equal
    ldr r1,iAdrsMessValeur     @ display value
    bl conversion10             @ call function with 2 parameter (r0,r1)
    ldr r0,iAdrszMessResult
    bl affichageMess            @ display message
    subs r4,#1                   @ decrement counter
    bgt 2b                      @ loop if greather
    b 1b                          @ begin loop one
	
3:
    mov r2,r0             @ save value
    ldr r0,iAdrszMessEndLoop
    bl affichageMess            @ display message
    mov r0,r2
    ldr r1,iAdrsMessValeur                
    bl conversion10       @ call function with 2 parameter (r0,r1)
    ldr r0,iAdrszMessResult
    bl affichageMess            @ display message

100:   @ standard end of the program 
    mov r0, #0                  @ return code
    pop {fp,lr}                 @restaur 2 registers
    mov r7, #EXIT              @ request to exit program
    svc #0                       @ perform the system call

iAdrsMessValeur:          .int sMessValeur
iAdrszMessResult:         .int szMessResult
iAdrszMessEndLoop:        .int szMessEndLoop
/******************************************************************/
/*     display text with size calculation                         */ 
/******************************************************************/
/* r0 contains the address of the message */
affichageMess:
    push {r0,r1,r2,r7,lr}      @ save  registres
    mov r2,#0                  @ counter length 
1:      @ loop length calculation 
    ldrb r1,[r0,r2]           @ read octet start position + index 
    cmp r1,#0                  @ if 0 its over 
    addne r2,r2,#1            @ else add 1 in the length 
    bne 1b                    @ and loop 
                                @ so here r2 contains the length of the message 
    mov r1,r0        			@ address message in r1 
    mov r0,#STDOUT      		@ code to write to the standard output Linux 
    mov r7, #WRITE             @ code call system "write" 
    svc #0                      @ call systeme 
    pop {r0,r1,r2,r7,lr}        @ restaur des  2 registres */ 
    bx lr                       @ return  
/******************************************************************/
/*     Converting a register to a decimal                                 */ 
/******************************************************************/
/* r0 contains value and r1 address area   */
conversion10:
    push {r1-r4,lr}    @ save registers 
    mov r3,r1
    mov r2,#10

1:	   @ start loop
    bl divisionpar10 @ r0 <- dividende. quotient ->r0 reste -> r1
    add r1,#48        @ digit	
    strb r1,[r3,r2]  @ store digit on area
    sub r2,#1         @ previous position
    cmp r0,#0         @ stop if quotient = 0 */
    bne 1b	          @ else loop
    @ and move spaces in first on area
    mov r1,#' '   @ space	
2:	
    strb r1,[r3,r2]  @ store space in area
    subs r2,#1       @ @ previous position
    bge 2b           @ loop if r2 >= zéro 

100:	
    pop {r1-r4,lr}    @ restaur registres 
    bx lr	          @return
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
    push {r2-r4}   /* save registers  */
    mov r4,r0 
    mov r3,#0x6667   @ r3 <- magic_number  lower
    movt r3,#0x6666  @ r3 <- magic_number  upper
    smull r1, r2, r3, r0   @ r1 <- Lower32Bits(r1*r0). r2 <- Upper32Bits(r1*r0) 
    mov r2, r2, ASR #2     /* r2 <- r2 >> 2 */
    mov r1, r0, LSR #31    /* r1 <- r0 >> 31 */
    add r0, r2, r1         /* r0 <- r2 + r1 */
    add r2,r0,r0, lsl #2   /* r2 <- r0 * 5 */
    sub r1,r4,r2, lsl #1   /* r1 <- r4 - (r2 * 2)  = r4 - (r0 * 10) */
    pop {r2-r4}
    bx lr                  /* leave function */

/***************************************************/
/*   Generation random number                  */
/***************************************************/
/* r0 contains limit  */
genereraleas:
    push {r1-r4,lr}    @ save registers 
    ldr r4,iAdriGraine
    ldr r2,[r4]
    ldr r3,iNbDep1
    mul r2,r3,r2
    ldr r3,iNbDep1
    add r2,r2,r3
    str r2,[r4]     @ maj de la graine pour l appel suivant 

    mov r1,r0        @ divisor
    mov r0,r2        @ dividende
    bl division
    mov r0,r3       @  résult = remainder
  
100:                @ end function
    pop {r1-r4,lr}   @ restaur registers
    bx lr            @ return
/********************************************************************/
iAdriGraine: .int iGraine	
iNbDep1: .int 0x343FD
iNbDep2: .int 0x269EC3 
/***************************************************/
/* integer division unsigned                       */
/***************************************************/
division:
    /* r0 contains dividend */
    /* r1 contains divisor */
    /* r2 returns quotient */
    /* r3 returns remainder */
    push {r4, lr}
    mov r2, #0                @ init quotient
    mov r3, #0                @ init remainder
    mov r4, #32               @ init counter bits
    b 2f
1:          @ loop 
    movs r0, r0, LSL #1     @ r0 <- r0 << 1 updating cpsr (sets C if 31st bit of r0 was 1)
    adc r3, r3, r3           @ r3 <- r3 + r3 + C. This is equivalent to r3 <- (r3 << 1) + C 
    cmp r3, r1               @ compute r3 - r1 and update cpsr 
    subhs r3, r3, r1        @ if r3 >= r1 (C=1) then r3 <- r3 - r1 
    adc r2, r2, r2           @ r2 <- r2 + r2 + C. This is equivalent to r2 <- (r2 << 1) + C 
2:
    subs r4, r4, #1          @ r4 <- r4 - 1 
    bpl 1b                  @ if r4 >= 0 (N=0) then loop
    pop {r4, lr}
    bx lr