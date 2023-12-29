/* ARM assembly Raspberry PI  */
/*  program integerSort.s  with selection sort */
 
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
TableNumber:      .int   1,3,6,2,5,9,10,8,4,7
#TableNumber:     .int   10,9,8,7,6,5,4,3,2,1
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
 
1:
    ldr r0,iAdrTableNumber                         @ address number table
    mov r1,#0
    mov r2,#NBELEMENTS                             @ number of élements 
    bl selectionSort
    ldr r0,iAdrTableNumber                         @ address number table
    bl displayTable
 
    ldr r0,iAdrTableNumber                         @ address number table
    mov r1,#NBELEMENTS                             @ number of élements 
    bl isSorted                                    @ control sort
    cmp r0,#1                                      @ sorted ?
    beq 2f                                    
    ldr r0,iAdrszMessSortNok                       @ no !! error sort
    bl affichageMess
    b 100f
2:                                                 @ yes
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
/*         selection sort                                              */ 
/******************************************************************/
/* r0 contains the address of table */
/* r1 contains the first element    */
/* r2 contains the number of element */
selectionSort:
    push {r1-r7,lr}                                        @ save registers
    mov r3,r1                                              @ start index i
    sub r7,r2,#1                                           @ compute n - 1
1:                                                         @ start loop
    mov r4,r3
    add r5,r3,#1                                           @ init index 2
2: 
    ldr r1,[r0,r4,lsl #2]                                  @ load value A[mini]
    ldr r6,[r0,r5,lsl #2]                                  @ load value A[j]
    cmp r6,r1                                              @ compare value
    movlt r4,r5                                            @ j -> mini
    add r5,#1                                              @ increment index j
    cmp r5,r2                                              @ end ?
    blt 2b                                                 @ no -> loop
    cmp r4,r3                                              @ mini <> j ?
    beq 3f                                                 @ no
    ldr r1,[r0,r4,lsl #2]                                  @ yes swap A[i] A[mini]
    ldr r6,[r0,r3,lsl #2]
    str r1,[r0,r3,lsl #2]
    str r6,[r0,r4,lsl #2]
3:
    add r3,#1                                              @ increment i
    cmp r3,r7                                              @ end ?
    blt 1b                                                 @ no -> loop 
 
100:
    pop {r1-r7,lr}
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
    bl conversion10                                    @ décimal conversion 
    ldr r0,iAdrsMessResult
    ldr r1,iAdrsZoneConv                               @ insert conversion
    bl strInsertAtCharInc
    bl affichageMess                                   @ display message
    add r3,#1
    cmp r3,#NBELEMENTS - 1
    ble 1b
    ldr r0,iAdrszCarriageReturn
    bl affichageMess
100:
    pop {r0-r3,lr}
    bx lr
iAdrsZoneConv:           .int sZoneConv
/***************************************************/
/*      ROUTINES INCLUDE                           */
/***************************************************/
.include "../affichage.inc"