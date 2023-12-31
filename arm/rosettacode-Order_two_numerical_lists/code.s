/* ARM assembly Raspberry PI  */
/*  program orderlist.s   */

/* Constantes    */
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ WRITE,  4     @ Linux syscall

/*********************************/
/* Initialized data              */
/*********************************/
.data
szMessResult1:      .asciz "List1 < List2 \n"           @ message result
szMessResult2:      .asciz "List1 => List2 \n"           @ message result
szCarriageReturn:  .asciz "\n"

iTabList1:         .int  1,2,3,4,5
.equ NBELEMENTS1,   (. - iTabList1) /4
iTabList2:         .int  1,2,1,5,2,2
.equ NBELEMENTS2,   (. - iTabList2) /4
iTabList3:         .int  1,2,3,4,5
.equ NBELEMENTS3,   (. - iTabList3) /4
iTabList4:         .int  1,2,3,4,5,6
.equ NBELEMENTS4,   (. - iTabList4) /4
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
    ldr r0,iAdriTabList1
    mov r1,#NBELEMENTS1
    ldr r2,iAdriTabList2
    mov r3,#NBELEMENTS2
    bl listeOrder
    cmp r0,#0                               @ false ?
    beq 1f                                  @ yes
    ldr r0,iAdrszMessResult1                @ list 1 < list 2
    bl affichageMess                        @ display message
    b 2f
1:
    ldr r0,iAdrszMessResult2
    bl affichageMess                        @ display message

2:
    ldr r0,iAdriTabList1
    mov r1,#NBELEMENTS1
    ldr r2,iAdriTabList3
    mov r3,#NBELEMENTS3
    bl listeOrder
    cmp r0,#0                               @ false ?
    beq 3f                                  @ yes
    ldr r0,iAdrszMessResult1                @ list 1 < list 2
    bl affichageMess                        @ display message
    b 4f
3:
    ldr r0,iAdrszMessResult2
    bl affichageMess                        @ display message
4:
    ldr r0,iAdriTabList1
    mov r1,#NBELEMENTS1
    ldr r2,iAdriTabList4
    mov r3,#NBELEMENTS4
    bl listeOrder
    cmp r0,#0                               @ false ?
    beq 5f                                  @ yes
    ldr r0,iAdrszMessResult1                @ list 1 < list 2
    bl affichageMess                        @ display message
    b 6f
5:
    ldr r0,iAdrszMessResult2
    bl affichageMess                        @ display message
6:
100:                                        @ standard end of the program 
    mov r0, #0                              @ return code
    mov r7, #EXIT                           @ request to exit program
    svc #0                                  @ perform the system call
iAdriTabList1:             .int iTabList1
iAdriTabList2:             .int iTabList2
iAdriTabList3:             .int iTabList3
iAdriTabList4:             .int iTabList4
iAdrszMessResult1:        .int szMessResult1
iAdrszMessResult2:        .int szMessResult2
iAdrszCarriageReturn:     .int szCarriageReturn
/******************************************************************/
/*     display text with size calculation                         */ 
/******************************************************************/
/* r0 contains the address of list 1 */
/* r1 contains list 1 size           */
/* r2 contains the address of list 2 */
/* r3 contains list 2 size           */
/* r0 returns 1 if list1 < list2     */
/* r0 returns 0 else                 */
listeOrder:
    push {r1-r7,lr}                   @ save  registres
    cmp r1,#0                         @ list 1 size = zero ?
    moveq r0,#-1                      @ yes -> error
    beq 100f
    cmp r3,#0                         @ list 2 size = zero ?
    moveq r0,#-2                      @ yes -> error
    beq 100f
    mov r4,#0                         @ index list 1
    mov r5,#0                         @ index list 2
1:
    ldr r6,[r0,r4,lsl #2]             @ load list 1 element
    ldr r7,[r2,r5,lsl #2]             @ load list 2 element
    cmp r6,r7                         @ compar
    movgt r0,#0                       @ list 1 > list 2 ?
    bgt 100f
    beq 2f                            @ list 1 = list 2
    add r4,#1                         @ increment index 1
    cmp r4,r1                         @ end list ?
    movge r0,#1                       @ yes -> ok list 1 < list 2
    bge 100f
    b 1b                              @ else loop
2:
    add r4,#1                         @ increment index 1
    cmp r4,r1                         @ end list ?
    bge 3f                            @ yes -> verif size
    add r5,#1                         @ else increment index 2
    cmp r5,r3                         @ end list 2 ?
    movge r0,#0                       @ yes -> list 2 < list 1
    bge 100f
    b 1b                              @ else loop
3:
   cmp r1,r3                          @ compar size
   movge r0,#0                        @ list 2 < list 1
   movlt r0,#1                        @ list 1 < list 2
100:
    pop {r1-r7,lr}                    @ restaur registers
    bx lr                             @ return  
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