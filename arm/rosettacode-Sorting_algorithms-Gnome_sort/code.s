/* ARM assembly Raspberry PI  */
/*  program gnomeSort.s  */
 
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
szCarriageReturn:   .asciz "\n"
 
.align 4
#TableNumber:      .int   1,3,6,2,5,9,10,8,4,7
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
    bl gnomeSort
    ldr r0,iAdrTableNumber                         @ address number table
    bl displayTable
 
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
/*         gnome Sort                                          */ 
/******************************************************************/
/* r0 contains the address of table */
/* r1 contains the first element    */
/* r2 contains the number of element */
gnomeSort:
    push {r1-r9,lr}           @ save registers
    sub r2,r2,#1              @ compute end index = n - 1
    add r3,r1,#1              @ index i
    add r7,r1,#2              @ j
1:                            @ start loop 1
    cmp r3,r2
    bgt 100f
    sub r4,r3,#1
    ldr r5,[r0,r3,lsl #2]     @ load value A[j]
    ldr r6,[r0,r4,lsl #2]     @ load value A[j-1]
    cmp r5,r6                 @ compare value
    bge 2f
    str r6,[r0,r3,lsl #2]     @ if smaller inversion
    str r5,[r0,r4,lsl #2] 
    sub r3,r3,#1             @ i = i - 1
    cmp r3,r1
    moveq r3,r7               @ if i = 0  i = j
    addeq r7,r7,#1            @ if i = 0  j = j+1
    b 1b                      @ loop 1
2:
    mov r3,r7                 @ i = j
    add r7,r7,#1              @ j = j + 1
    b 1b                      @ loop 1
 
100:
    pop {r1-r9,lr}
    bx lr                                                  @ return 
 
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