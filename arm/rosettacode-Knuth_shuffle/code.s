/* ARM assembly Raspberry PI  */
/*  program knuthShuffle.s   */

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
sMessResult:      .ascii "Value  : "
sMessValeur:       .fill 11, 1, ' '            @ size => 11
szCarriageReturn: .asciz "\n"

.align 4
iGraine:  .int 123456
.equ NBELEMENTS,      10
TableNumber:	     .int   1,2,3,4,5,6,7,8,9,10

/*********************************/
/* UnInitialized data            */
/*********************************/
.bss  
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                                           @ entry of program 
    ldr r0,iAdrTableNumber                      @ address number table
    mov r1,#NBELEMENTS                          @ number of élements 
    bl knuthShuffle
    ldr r2,iAdrTableNumber
    mov r3,#0
1:                                              @ loop display table
    ldr r0,[r2,r3,lsl #2]
    ldr r1,iAdrsMessValeur                      @ display value
    bl conversion10                             @ call function
    ldr r0,iAdrsMessResult
    bl affichageMess                            @ display message
    add r3,#1
    cmp r3,#NBELEMENTS - 1
    ble 1b

    ldr r0,iAdrszCarriageReturn
    bl affichageMess   
    /*    2e shuffle             */
    ldr r0,iAdrTableNumber                     @ address number table
    mov r1,#NBELEMENTS                         @ number of élements 
    bl knuthShuffle
    ldr r2,iAdrTableNumber
    mov r3,#0
2:                                             @ loop display table
    ldr r0,[r2,r3,lsl #2]
    ldr r1,iAdrsMessValeur                     @ display value
    bl conversion10                            @ call function
    ldr r0,iAdrsMessResult
    bl affichageMess                           @ display message
    add r3,#1
    cmp r3,#NBELEMENTS - 1
    ble 2b

100:                                            @ standard end of the program 
    mov r0, #0                                  @ return code
    mov r7, #EXIT                               @ request to exit program
    svc #0                                      @ perform the system call

iAdrsMessValeur:          .int sMessValeur
iAdrszCarriageReturn:     .int szCarriageReturn
iAdrsMessResult:          .int sMessResult
iAdrTableNumber:          .int TableNumber

/******************************************************************/
/*     Knuth Shuffle                                             */ 
/******************************************************************/
/* r0 contains the address of table */
/* r1 contains the number of elements */
knuthShuffle:
    push {r2-r5,lr}                                    @ save registers
    mov r5,r0                                          @ save table address
    mov r2,#0                                          @ start index
1:
    mov r0,r2                                          @ generate aleas
    bl genereraleas
    ldr r3,[r5,r2,lsl #2]                              @ swap number on the table
    ldr r4,[r5,r0,lsl #2]
    str r4,[r5,r2,lsl #2]
    str r3,[r5,r0,lsl #2]
    add r2,#1                                           @ next number
    cmp r2,r1                                           @ end ?
    blt 1b                                              @ no -> loop

100:
    pop {r2-r5,lr}
    bx lr                                               @ return 

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
/*     Converting a register to a decimal unsigned                */ 
/******************************************************************/
/* r0 contains value and r1 address area   */
/* r0 return size of result (no zero final in area) */
/* area size => 11 bytes          */
.equ LGZONECAL,   10
conversion10:
    push {r1-r4,lr}                                @ save registers 
    mov r3,r1
    mov r2,#LGZONECAL

1:	                                           @ start loop
    bl divisionpar10U                              @unsigned  r0 <- dividende. quotient ->r0 reste -> r1
    add r1,#48                                     @ digit
    strb r1,[r3,r2]                                @ store digit on area
    cmp r0,#0                                      @ stop if quotient = 0 
    subne r2,#1                                    @ else previous position
    bne 1b	                                   @ and loop
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

/***************************************************/
/*   division par 10   unsigned                    */
/***************************************************/
/* r0 dividende   */
/* r0 quotient */	
/* r1 remainder  */
divisionpar10U:
    push {r2,r3,r4, lr}
    mov r4,r0                                          @ save value
    //mov r3,#0xCCCD                                   @ r3 <- magic_number lower  raspberry 3
    //movt r3,#0xCCCC                                  @ r3 <- magic_number higter raspberry 3
    ldr r3,iMagicNumber                                @ r3 <- magic_number    raspberry 1 2
    umull r1, r2, r3, r0                               @ r1<- Lower32Bits(r1*r0) r2<- Upper32Bits(r1*r0) 
    mov r0, r2, LSR #3                                 @ r2 <- r2 >> shift 3
    add r2,r0,r0, lsl #2                               @ r2 <- r0 * 5 
    sub r1,r4,r2, lsl #1                               @ r1 <- r4 - (r2 * 2)  = r4 - (r0 * 10)
    pop {r2,r3,r4,lr}
    bx lr                                              @ leave function 
iMagicNumber:  	.int 0xCCCCCCCD
/***************************************************/
/*   Generation random number                  */
/***************************************************/
/* r0 contains limit  */
genereraleas:
    push {r1-r4,lr}                                    @ save registers 
    ldr r4,iAdriGraine
    ldr r2,[r4]
    ldr r3,iNbDep1
    mul r2,r3,r2
    ldr r3,iNbDep1
    add r2,r2,r3
    str r2,[r4]                                        @ maj de la graine pour l appel suivant 
    cmp r0,#0
    beq 100f
    mov r1,r0                                          @ divisor
    mov r0,r2                                          @ dividende
    bl division
    mov r0,r3                                          @ résult = remainder
  
100:                                                   @ end function
    pop {r1-r4,lr}                                     @ restaur registers
    bx lr                                              @ return
/*****************************************************/
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
    mov r2, #0                                         @ init quotient
    mov r3, #0                                         @ init remainder
    mov r4, #32                                        @ init counter bits
    b 2f
1:                                                     @ loop 
    movs r0, r0, LSL #1                                @ r0 <- r0 << 1 updating cpsr (sets C if 31st bit of r0 was 1)
    adc r3, r3, r3                                     @ r3 <- r3 + r3 + C. This is equivalent to r3 ? (r3 << 1) + C 
    cmp r3, r1                                         @ compute r3 - r1 and update cpsr 
    subhs r3, r3, r1                                   @ if r3 >= r1 (C=1) then r3 <- r3 - r1 
    adc r2, r2, r2                                     @ r2 <- r2 + r2 + C. This is equivalent to r2 <- (r2 << 1) + C 
2:
    subs r4, r4, #1                                    @ r4 <- r4 - 1 
    bpl 1b                                             @ if r4 >= 0 (N=0) then loop
    pop {r4, lr}
    bx lr