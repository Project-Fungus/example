/* ARM assembly Raspberry PI  */
/*  program binsearch.s   */

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
sMessResult:        .ascii "Value find at index : "
sMessValeur:        .fill 11, 1, ' '            @ size => 11
szCarriageReturn:   .asciz "\n"
sMessRecursif:      .asciz "Recursive search : \n"
sMessNotFound:      .asciz "Value not found. \n"

.equ NBELEMENTS,      9
TableNumber:	     .int   4,6,7,10,11,15,22,30,35

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
    mov r0,#4                                   @ search first value
    ldr r1,iAdrTableNumber                      @ address number table
    mov r2,#NBELEMENTS                          @ number of élements 
    bl bSearch
    ldr r1,iAdrsMessValeur                      @ display value
    bl conversion10                             @ call function
    ldr r0,iAdrsMessResult
    bl affichageMess                            @ display message

    mov r0,#11                                  @ search median value
    ldr r1,iAdrTableNumber
    mov r2,#NBELEMENTS
    bl bSearch
    ldr r1,iAdrsMessValeur                      @ display value
    bl conversion10                             @ call function
    ldr r0,iAdrsMessResult
    bl affichageMess                            @ display message

    mov r0,#12                                  @value not found
    ldr r1,iAdrTableNumber
    mov r2,#NBELEMENTS
    bl bSearch
    cmp r0,#-1
    bne 2f
    ldr r0,iAdrsMessNotFound
    bl affichageMess 
    b 3f
2:
    ldr r1,iAdrsMessValeur                      @ display value
    bl conversion10                             @ call function
    ldr r0,iAdrsMessResult
    bl affichageMess                            @ display message
3:
    mov r0,#35                                  @ search last value
    ldr r1,iAdrTableNumber
    mov r2,#NBELEMENTS
    bl bSearch
    ldr r1,iAdrsMessValeur                      @ display value
    bl conversion10                             @ call function
    ldr r0,iAdrsMessResult
    bl affichageMess                            @ display message
/****************************************/
/*       recursive                      */
/****************************************/
    ldr r0,iAdrsMessRecursif
    bl affichageMess                            @ display message

    mov r0,#4                                   @ search first value
    ldr r1,iAdrTableNumber
    mov r2,#0                                   @ low index of elements
    mov r3,#NBELEMENTS - 1                      @ high index of elements
    bl bSearchR
    ldr r1,iAdrsMessValeur                      @ display value
    bl conversion10                             @ call function
    ldr r0,iAdrsMessResult
    bl affichageMess                            @ display message
   
    mov r0,#11
    ldr r1,iAdrTableNumber
    mov r2,#0
    mov r3,#NBELEMENTS - 1
    bl bSearchR
    ldr r1,iAdrsMessValeur                      @ display value
    bl conversion10                             @ call function
    ldr r0,iAdrsMessResult
    bl affichageMess                            @ display message
    
    mov r0,#12
    ldr r1,iAdrTableNumber
    mov r2,#0
    mov r3,#NBELEMENTS - 1
    bl bSearchR
    cmp r0,#-1
    bne 2f
    ldr r0,iAdrsMessNotFound
    bl affichageMess 
    b 3f
2:
    ldr r1,iAdrsMessValeur                      @ display value
    bl conversion10                             @ call function
    ldr r0,iAdrsMessResult
    bl affichageMess                            @ display message
3:
    mov r0,#35
    ldr r1,iAdrTableNumber
    mov r2,#0
    mov r3,#NBELEMENTS - 1
    bl bSearchR
    ldr r1,iAdrsMessValeur                      @ display value
    bl conversion10                             @ call function
    ldr r0,iAdrsMessResult
    bl affichageMess                            @ display message

100:                                            @ standard end of the program 
    mov r0, #0                                  @ return code
    mov r7, #EXIT                               @ request to exit program
    svc #0                                      @ perform the system call

iAdrsMessValeur:          .int sMessValeur
iAdrszCarriageReturn:     .int szCarriageReturn
iAdrsMessResult:          .int sMessResult
iAdrsMessRecursif:        .int sMessRecursif
iAdrsMessNotFound:        .int sMessNotFound
iAdrTableNumber:          .int TableNumber

/******************************************************************/
/*     binary search   iterative                                  */ 
/******************************************************************/
/* r0 contains the value to search */
/* r1 contains the adress of table */
/* r2 contains the number of elements */
/* r0 return index or -1 if not find */
bSearch:
    push {r2-r5,lr}                                 @ save registers
    mov r3,#0                                       @ low index
    sub r4,r2,#1                                    @ high index = number of elements - 1
1:
    cmp r3,r4
    movgt r0,#-1                                    @not found
    bgt 100f
    add r2,r3,r4                                    @ compute (low + high) /2
    lsr r2,#1
    ldr r5,[r1,r2,lsl #2]                           @ load value of table at index r2
    cmp r5,r0
    moveq r0,r2                                     @ find !!!
    beq 100f
    addlt r3,r2,#1                                  @ lower -> index low = index + 1
    subgt r4,r2,#1                                  @ bigger -> index high = index - 1
    b 1b                                            @ and loop
100:
    pop {r2-r5,lr}
    bx lr                       @ return 
/******************************************************************/
/*     binary search   recursif                                  */ 
/******************************************************************/
/* r0 contains the value to search */
/* r1 contains the adress of table */
/* r2 contains the low index of elements */
/* r3 contains the high index of elements */
/* r0 return index or -1 if not find */
bSearchR:
    push {r2-r5,lr}                                  @ save registers
    cmp r3,r2                                        @ index high < low ?
    movlt r0,#-1                                     @ yes -> not found
    blt 100f

    add r4,r2,r3                                     @ compute (low + high) /2
    lsr r4,#1
    ldr r5,[r1,r4,lsl #2]                            @ load value of table at index r4
    cmp r5,r0
    moveq r0,r4                                      @ find !!!
    beq 100f 

    bgt 1f                                           @ bigger ?
    add r2,r4,#1                                     @ no new search with low = index + 1
    bl bSearchR
    b 100f
1:                                                   @ bigger
    sub r3,r4,#1                                     @ new search with high = index - 1
    bl bSearchR
100:
    pop {r2-r5,lr}
    bx lr                                            @ return 
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
    pop {r0,r1,r2,r7,lr}                           @ restaur des  2 registres
    bx lr                                          @ return  
/******************************************************************/
/*     Converting a register to a decimal unsigned                */ 
/******************************************************************/
/* r0 contains value and r1 address area   */
/* r0 return size of result (no zero final in area) */
/* area size => 11 bytes          */
.equ LGZONECAL,   10
conversion10:
    push {r1-r4,lr}                                 @ save registers 
    mov r3,r1
    mov r2,#LGZONECAL

1:	                                            @ start loop
    bl divisionpar10U                               @unsigned  r0 <- dividende. quotient ->r0 reste -> r1
    add r1,#48                                      @ digit
    strb r1,[r3,r2]                                 @ store digit on area
    cmp r0,#0                                       @ stop if quotient = 0 
    subne r2,#1                                     @ else previous position
    bne 1b	                                    @ and loop
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
    mov r0,r4                                        @ result length 
    mov r1,#' '                                      @ space
3:
    strb r1,[r3,r4]                                  @ store space in area
    add r4,#1                                        @ next position
    cmp r4,#LGZONECAL
    ble 3b                                           @ loop if r4 <= area size

100:
    pop {r1-r4,lr}                                   @ restaur registres 
    bx lr                                            @return

/***************************************************/
/*   division par 10   unsigned                    */
/***************************************************/
/* r0 dividende   */
/* r0 quotient */	
/* r1 remainder  */
divisionpar10U:
    push {r2,r3,r4, lr}
    mov r4,r0                                        @ save value
    //mov r3,#0xCCCD                                 @ r3 <- magic_number lower  raspberry 3
    //movt r3,#0xCCCC                                @ r3 <- magic_number higter raspberry 3
    ldr r3,iMagicNumber                              @ r3 <- magic_number    raspberry 1 2
    umull r1, r2, r3, r0                             @ r1<- Lower32Bits(r1*r0) r2<- Upper32Bits(r1*r0) 
    mov r0, r2, LSR #3                               @ r2 <- r2 >> shift 3
    add r2,r0,r0, lsl #2                             @ r2 <- r0 * 5 
    sub r1,r4,r2, lsl #1                             @ r1 <- r4 - (r2 * 2)  = r4 - (r0 * 10)
    pop {r2,r3,r4,lr}
    bx lr                                            @ leave function 
iMagicNumber:  	.int 0xCCCCCCCD