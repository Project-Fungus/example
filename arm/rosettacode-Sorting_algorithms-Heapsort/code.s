/* ARM assembly Raspberry PI  */
/*  program heapSort.s   */
/* look Pseudocode begin this task  */
 
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
szMessSortOk:       .asciz "Table sorted.\n"
szMessSortNok:      .asciz "Table not sorted !!!!!.\n"
sMessResult:        .ascii "Value  : "
sMessValeur:        .fill 11, 1, ' '            @ size => 11
szCarriageReturn:  .asciz "\n"
 
.align 4
iGraine:  .int 123456
.equ NBELEMENTS,      10
TableNumber:	     .int   1,3,6,2,5,9,10,8,4,7
#TableNumber:	     .int   10,9,8,7,6,5,4,3,2,1
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
 
1:
    ldr r0,iAdrTableNumber                      @ address number table
    mov r1,#NBELEMENTS                           @ number of élements 
    bl heapSort
    ldr r0,iAdrTableNumber                      @ address number table
    bl displayTable
 
    ldr r0,iAdrTableNumber                      @ address number table
    mov r1,#NBELEMENTS                           @ number of élements 
    bl isSorted                                   @ control sort
    cmp r0,#1                                       @ sorted ?
    beq 2f                                    
    ldr r0,iAdrszMessSortNok                    @ no !! error sort
    bl affichageMess
    b 100f
2:                                                  @ yes
    ldr r0,iAdrszMessSortOk
    bl affichageMess
100:                                               @ standard end of the program 
    mov r0, #0                                      @ return code
    mov r7, #EXIT                                  @ request to exit program
    svc #0                                         @ perform the system call
 
iAdrsMessValeur:          .int sMessValeur
iAdrszCarriageReturn:    .int szCarriageReturn
iAdrsMessResult:          .int sMessResult
iAdrTableNumber:          .int TableNumber
iAdrszMessSortOk:         .int szMessSortOk
iAdrszMessSortNok:        .int szMessSortNok
/******************************************************************/
/*     control sorted table                                   */ 
/******************************************************************/
/* r0 contains the address of table */
/* r1 contains the number of elements  > 0  */
/* r0 return 0  if not sorted   1  if sorted */
isSorted:
    push {r2-r4,lr}                                    @ save registers
    mov r2,#0
    ldr r4,[r0,r2,lsl #2]
1:
    add r2,#1
    cmp r2,r1
    movge r0,#1
    bge 100f
    ldr r3,[r0,r2, lsl #2]
    cmp r3,r4
    movlt r0,#0
    blt 100f
    mov r4,r3
    b 1b
100:
    pop {r2-r4,lr}
    bx lr                                              @ return 
/******************************************************************/
/*         heap sort                                              */ 
/******************************************************************/
/* r0 contains the address of table */
/* r1 contains the number of element */
heapSort:
    push {r2,r3,r4,lr}                                    @ save registers
    bl heapify                                          @ first place table in max-heap order
    sub r3,r1,#1
1:
    cmp r3,#0
    ble 100f
    mov r1,#0                                             @ swap the root(maximum value) of the heap with the last element of the heap)
    mov r2,r3
    bl swapElement
    sub r3,#1
    mov r1,#0
    mov r2,r3                                             @ put the heap back in max-heap order
    bl siftDown
    b 1b

100:
    pop {r2,r3,r4,lr}
    bx lr                                              @ return 
/******************************************************************/
/*      place table in max-heap order                             */ 
/******************************************************************/
/* r0 contains the address of table */
/* r1 contains the number of element */
heapify:
    push {r1,r2,r3,r4,lr}                                    @ save registers
    mov r4,r1
    sub r3,r1,#2
    lsr r3,#1
1:
    cmp r3,#0
    blt 100f
    mov r1,r3
    sub r2,r4,#1
    bl siftDown
    sub r3,#1
    b 1b
100:
    pop {r1,r2,r3,r4,lr}
    bx lr                                              @ return 
/******************************************************************/
/*     swap two elements of table                                  */ 
/******************************************************************/
/* r0 contains the address of table */
/* r1 contains the first index */
/* r2 contains the second index */
swapElement:
    push {r3,r4,lr}                                    @ save registers
    ldr r3,[r0,r1,lsl #2]                              @ swap number on the table
    ldr r4,[r0,r2,lsl #2]
    str r4,[r0,r1,lsl #2]
    str r3,[r0,r2,lsl #2]

100:
    pop {r3,r4,lr}
    bx lr                                              @ return 
 
/******************************************************************/
/*     put the heap back in max-heap order                        */ 
/******************************************************************/
/* r0 contains the address of table */
/* r1 contains the first index */
/* r2 contains the last index */
siftDown:
    push {r1-r7,lr}                                    @ save registers
                                                       @ r1 = root = start
    mov r3,r2                                          @ save last index
1:
    lsl r4,r1,#1
    add r4,#1
    cmp r4,r3
    bgt 100f
    add r5,r4,#1
    cmp r5,r3
    bgt 2f
    ldr r6,[r0,r4,lsl #2]                              @ compare elements on the table
    ldr r7,[r0,r5,lsl #2]
    cmp r6,r7
    movlt r4,r5
2:
    ldr r7,[r0,r4,lsl #2]                              @ compare elements on the table
    ldr r6,[r0,r1,lsl #2]                              @ root
    cmp r6,r7
    bge 100f
    mov r2,r4                                          @ and r1 is root
    bl swapElement
    mov r1,r4                                          @ root = child
    b 1b

100:
    pop {r1-r7,lr}
    bx lr                                              @ return  

/******************************************************************/
/*      Display table elements                                */ 
/******************************************************************/
/* r0 contains the address of table */
displayTable:
    push {r0-r3,lr}                                    @ save registers
    mov r2,r0                                          @ table address
    mov r3,#0
1:                                                     @ loop display table
    ldr r0,[r2,r3,lsl #2]
    ldr r1,iAdrsMessValeur                             @ display value
    bl conversion10                                    @ call function
    ldr r0,iAdrsMessResult
    bl affichageMess                                   @ display message
    add r3,#1
    cmp r3,#NBELEMENTS - 1
    ble 1b
    ldr r0,iAdrszCarriageReturn
    bl affichageMess
100:
    pop {r0-r3,lr}
    bx lr
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
    push {r1-r4,lr}                                 @ save registers 
    mov r3,r1
    mov r2,#LGZONECAL
 
1:	                                            @ start loop
    bl divisionpar10U                               @ unsigned  r0 <- dividende. quotient ->r0 reste -> r1
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