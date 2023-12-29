/* ARM assembly Raspberry PI  */
/*  program pancakeSort.s  */
 
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
szMessSortOk:       .asciz "Table sorted.\n"
szMessSortNok:      .asciz "Table not sorted !!!!!.\n"
sMessResult:        .asciz "Value  : @ \n"
sMessCounter:       .asciz "sorted in  @ flips \n"
szCarriageReturn:   .asciz "\n"
 
.align 4
#TableNumber:      .int   1,11,3,6,2,5,9,10,8,4,7
TableNumber:       .int   10,9,8,7,6,5,4,3,2,1
                   .equ NBELEMENTS, (. - TableNumber) / 4
/*********************************/
/* UnInitialized data            */
/*********************************/
.bss
sZoneConv:            .skip 24
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                                              @ entry of program 
 
    ldr r0,iAdrTableNumber                         @ address number table
    mov r1,#0                                      @ first element
    mov r2,#NBELEMENTS                             @ number of élements 
    mov r10,#0                                     @ flips counter
    bl pancakeSort
    ldr r0,iAdrTableNumber                         @ address number table
    bl displayTable
    mov r0,r10                                     @ display counter
    ldr r1,iAdrsZoneConv                           @ 
    bl conversion10S                               @ décimal conversion 
    ldr r0,iAdrsMessCounter
    ldr r1,iAdrsZoneConv                           @ insert conversion
    bl strInsertAtCharInc
    bl affichageMess                               @ display message
    
 
    ldr r0,iAdrTableNumber                         @ address number table
    mov r1,#NBELEMENTS                             @ number of élements 
    bl isSorted                                    @ control sort
    cmp r0,#1                                      @ sorted ?
    beq 1f                                    
    ldr r0,iAdrszMessSortNok                       @ no !! error sort
    bl affichageMess
    b 100f
1:                                                 @ yes
    ldr r0,iAdrszMessSortOk
    bl affichageMess
100:                                               @ standard end of the program 
    mov r0, #0                                     @ return code
    mov r7, #EXIT                                  @ request to exit program
    svc #0                                         @ perform the system call
 
iAdrszCarriageReturn:     .int szCarriageReturn
iAdrsMessResult:          .int sMessResult
iAdrTableNumber:          .int TableNumber
iAdrszMessSortOk:         .int szMessSortOk
iAdrszMessSortNok:        .int szMessSortNok
iAdrsMessCounter:         .int sMessCounter
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
/*         flip                                                   */ 
/******************************************************************/
/* r0 contains the address of table */
/* r1 contains first start index
/* r2 contains the number of elements  */
/* r3 contains the position of flip   */ 
flip:
    push {r1-r6,lr}               @ save registers
    add r10,r10,#1                @ flips counter
    cmp r3,r2
    subge r3,r2,#1                @ last index if position >= size
    mov r4,r1
1:
    cmp r1,r3
    bge 100f
    ldr r5,[r0,r1,lsl #2]         @ load value first  index 
    ldr r6,[r0,r3,lsl #2]         @ load value position index
    str r6,[r0,r1,lsl #2]         @ inversion
    str r5,[r0,r3,lsl #2]         @ 
    sub r3,r3,#1
    add r1,r1,#1
    b 1b
100:
    pop {r1-r6,lr}
    bx lr                          @ return 
/******************************************************************/
/*         pancake sort                                                   */ 
/******************************************************************/
/* r0 contains the address of table */
/* r1 contains first start index
/* r2 contains the number of elements  */
pancakeSort:
    push {r1-r9,lr}            @ save registers
    sub r7,r2,#1
1:
    mov r5,r1                  @ index
    mov r4,#0                  @ max
    mov r3,#0                  @ position
    mov r8,#0                  @ top sorted
    ldr r9,[r0,r5,lsl #2]      @ load value A[i-1]
2:
   ldr r6,[r0,r5,lsl #2]       @ load value 
   cmp r6,r4                   @ compare max
   movge r4,r6
   movge r3,r5
   cmp r6,r9                   @ cmp A[i] A[i-1] sorted ?
   movlt r8,#1                 @ no 
   mov r9,r6                   @  A[i-1] = A[i]
   add r5,r5,#1                @ increment index
   cmp r5,r7                   @ end
   ble 2b
   cmp r8,#0                   @ sorted ?
   beq 100f                    @ yes -> end
   cmp r3,r7                   @ position ok ?
   beq 3f                      @ yes
   cmp r3,#0                   @ first position ?
   blne flip                   @ flip if not greather in first position
   mov r3,r7                   @ and flip the whole stack
   bl flip                     @ 
3:  
   subs r7,r7,#1               @ decrement number of pancake
   bge 1b                      @ and loop
100:
    pop {r1-r9,lr}
    bx lr                      @ return 

 
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
    ldr r1,iAdrsZoneConv                               @ 
    bl conversion10S                                    @ décimal conversion 
    ldr r0,iAdrsMessResult
    ldr r1,iAdrsZoneConv                               @ insert conversion
    bl strInsertAtCharInc
    bl affichageMess                                   @ display message
    add r3,#1
    cmp r3,#NBELEMENTS - 1
    ble 1b
    ldr r0,iAdrszCarriageReturn
    bl affichageMess
    mov r0,r2
100:
    pop {r0-r3,lr}
    bx lr
iAdrsZoneConv:           .int sZoneConv
/***************************************************/
/*      ROUTINES INCLUDE                           */
/***************************************************/
.include "../affichage.inc"