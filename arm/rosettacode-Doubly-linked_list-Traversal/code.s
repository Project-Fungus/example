/* ARM assembly Raspberry PI  */
/*  program transDblList.s   */
/* REMARK 1 : this program use routines in a include file 
   see task Include a file language arm assembly 
   for the routine affichageMess conversion10S 
   see at end of this program the instruction include */

/* Constantes    */
.equ STDOUT, 1                           @ Linux output console
.equ EXIT,   1                           @ Linux syscall
.equ READ,   3
.equ WRITE,  4

/*******************************************/
/* Structures                               */
/********************************************/
/* structure Doublylinkedlist*/
    .struct  0
dllist_head:                    @ head node
    .struct  dllist_head + 4
dllist_tail:                    @ tail node
    .struct  dllist_tail  + 4
dllist_fin:
/* structure Node Doublylinked List*/
    .struct  0
NDlist_next:                    @ next element
    .struct  NDlist_next + 4 
NDlist_prev:                    @ previous element
    .struct  NDlist_prev + 4 
NDlist_value:                   @ element value or key
    .struct  NDlist_value + 4 
NDlist_fin:
/* Initialized data */
.data
szMessInitListe:         .asciz "List initialized.\n"
szMessListInv:           .asciz "Display list inverse :\n"
szCarriageReturn:        .asciz "\n"
szMessErreur:            .asciz "Error detected.\n"
/* datas message display */
szMessResult:            .ascii "Result value :"
sValue:                  .space 12,' '
                         .asciz "\n"
/* UnInitialized data */
.bss 
dllist1:              .skip dllist_fin    @ list memory place 

/*  code section */
.text
.global main 
main: 
    ldr r0,iAdrdllist1
    bl newDList                      @ create new list
    ldr r0,iAdrszMessInitListe
    bl affichageMess
    ldr r0,iAdrdllist1               @ list address
    mov r1,#10                       @ value
    bl insertHead                    @ insertion at head
    cmp r0,#-1
    beq 99f
    ldr r0,iAdrdllist1
    mov r1,#20
    bl insertTail                    @ insertion at tail
    cmp r0,#-1
    beq 99f
    ldr r0,iAdrdllist1               @ list address
    mov r1,#10                       @ value to after insered
    mov r2,#15                       @ new value
    bl insertAfter
    cmp r0,#-1
    beq 99f
    ldr r0,iAdrdllist1               @ list address
    mov r1,#20                       @ value to after insered
    mov r2,#25                       @ new value
    bl insertAfter
    cmp r0,#-1
    beq 99f
    ldr r0,iAdrdllist1
    bl transHeadTail                 @ display value head to tail
    ldr r0,iAdrszMessListInv
    bl affichageMess
    ldr r0,iAdrdllist1
    bl transTailHead                 @ display value tail to head
    b 100f
99:
    ldr r0,iAdrszMessErreur
    bl affichageMess
100:                                 @ standard end of the program
    mov r7, #EXIT                    @ request to exit program
    svc 0                            @ perform system call
iAdrszMessInitListe:       .int szMessInitListe
iAdrszMessErreur:          .int szMessErreur
iAdrszMessListInv:         .int szMessListInv
iAdrszCarriageReturn:      .int szCarriageReturn
iAdrdllist1:               .int dllist1
/******************************************************************/
/*     create new list                         */ 
/******************************************************************/
/* r0 contains the address of the list structure */
newDList:
    push {r1,lr}                         @ save  registers 
    mov r1,#0
    str r1,[r0,#dllist_tail]
    str r1,[r0,#dllist_head]
    pop {r1,lr}                          @ restaur registers
    bx lr                                @ return
/******************************************************************/
/*     list is empty ?                         */ 
/******************************************************************/
/* r0 contains the address of the list structure */
/* r0 return 0 if empty  else return 1 */
isEmpty:
    //push {r1,lr}                         @ save  registers 
    ldr r0,[r0,#dllist_head]
    cmp r0,#0
    movne r0,#1
    //pop {r1,lr}                          @ restaur registers
    bx lr                                @ return
/******************************************************************/
/*     insert value at list head                        */ 
/******************************************************************/
/* r0 contains the address of the list structure */
/* r1 contains value */
insertHead:
    push {r1-r4,lr}                         @ save  registers 
    mov r4,r0                            @ save address
    mov r0,r1                            @ value
    bl createNode
    cmp r0,#-1                           @ allocation error ?
    beq 100f
    ldr r2,[r4,#dllist_head]             @ load address first node
    str r2,[r0,#NDlist_next]             @ store in next pointer on new node
    mov r1,#0
    str r1,[r0,#NDlist_prev]             @ store zero in previous pointer on new node
    str r0,[r4,#dllist_head]             @ store address new node in address head list 
    cmp r2,#0                            @ address first node is null ?
    strne r0,[r2,#NDlist_prev]           @ no store adresse new node in previous pointer
    streq r0,[r4,#dllist_tail]           @ else store new node in tail address
100:
    pop {r1-r4,lr}                          @ restaur registers
    bx lr                                @ return
/******************************************************************/
/*     insert value at list tail                        */ 
/******************************************************************/
/* r0 contains the address of the list structure */
/* r1 contains value */
insertTail:
    push {r1-r4,lr}                         @ save  registers 
    mov r4,r0                               @ save list address
    mov r0,r1                               @ value
    bl createNode                           @ new node
    cmp r0,#-1
    beq 100f                                @ allocation error
    ldr r2,[r4,#dllist_tail]                @ load address last node
    str r2,[r0,#NDlist_prev]                @ store in previous pointer on new node
    mov r1,#0                               @ store null un next pointer
    str r1,[r0,#NDlist_next]
    str r0,[r4,#dllist_tail]                @ store address new node on list tail
    cmp r2,#0                               @ address last node is null ?
    strne r0,[r2,#NDlist_next]              @ no store address new node in next pointer
    streq r0,[r4,#dllist_head]              @ else store in head list
100:
    pop {r1-r4,lr}                          @ restaur registers
    bx lr                                   @ return
/******************************************************************/
/*     insert value after other element                        */ 
/******************************************************************/
/* r0 contains the address of the list structure */
/* r1 contains value to search*/
/* r2 contains value to insert */
insertAfter:
    push {r1-r5,lr}                         @ save  registers 
    mov r4,r0
    bl searchValue                          @ search node with this value in r1
    cmp r0,#-1
    beq 100f                                @ not found -> error
    mov r5,r0                               @ save address of node find
    mov r0,r2                               @ new value
    bl createNode                           @ create new node
    cmp r0,#-1
    beq 100f                                @ allocation error
    ldr r2,[r5,#NDlist_next]                @ load pointer next of find node
    str r0,[r5,#NDlist_next]                @ store new node in pointer next
    str r5,[r0,#NDlist_prev]                @ store address find node in previous pointer on new node
    str r2,[r0,#NDlist_next]                @ store pointer next of find node on pointer next on new node
    cmp r2,#0                               @ next pointer is null ?
    strne r0,[r2,#NDlist_prev]              @ no store address new node in previous pointer 
    streq r0,[r4,#dllist_tail]              @ else store in list tail
100:
    pop {r1-r5,lr}                          @ restaur registers
    bx lr                                @ return
/******************************************************************/
/*     search value                                               */ 
/******************************************************************/
/* r0 contains the address of the list structure */
/* r1 contains the value to search  */
/* r0 return address of node or -1 if not found */
searchValue:
    push {r2,lr}                         @ save  registers 
    ldr r0,[r0,#dllist_head]             @ load first node
1:
    cmp r0,#0                            @ null -> end search not found
    moveq r0,#-1
    beq 100f
    ldr r2,[r0,#NDlist_value]            @ load node value
    cmp r2,r1                            @ equal ?
    beq 100f
    ldr r0,[r0,#NDlist_next]             @ load addresse next node 
    b 1b                                 @ and loop
100:
    pop {r2,lr}                          @ restaur registers
    bx lr                                @ return
/******************************************************************/
/*     transversal for head to tail                                               */ 
/******************************************************************/
/* r0 contains the address of the list structure */
transHeadTail:
    push {r2,lr}                         @ save  registers 
    ldr r2,[r0,#dllist_head]             @ load first node
1:
    ldr r0,[r2,#NDlist_value]
    ldr r1,iAdrsValue
    bl conversion10S
    ldr r0,iAdrszMessResult
    bl affichageMess
    ldr r2,[r2,#NDlist_next]
    cmp r2,#0
    bne 1b
100:
    pop {r2,lr}                          @ restaur registers
    bx lr                                @ return
iAdrszMessResult:          .int szMessResult
iAdrsValue:                .int sValue
/******************************************************************/
/*     transversal for tail to head                                               */ 
/******************************************************************/
/* r0 contains the address of the list structure */
transTailHead:
    push {r2,lr}                         @ save  registers 
    ldr r2,[r0,#dllist_tail]             @ load last node
1:
    ldr r0,[r2,#NDlist_value]
    ldr r1,iAdrsValue
    bl conversion10S
    ldr r0,iAdrszMessResult
    bl affichageMess
    ldr r2,[r2,#NDlist_prev]
    cmp r2,#0
    bne 1b
100:
    pop {r2,lr}                          @ restaur registers
    bx lr                                @ return
/******************************************************************/
/*     Create new node                                            */ 
/******************************************************************/
/* r0 contains the value */
/* r0 return node address or -1 if allocation error*/
createNode:
    push {r1-r7,lr}                         @ save  registers 
    mov r4,r0                            @ save value
    @ allocation place on the heap
    mov r0,#0                                   @ allocation place heap
    mov r7,#0x2D                                @ call system 'brk'
    svc #0
    mov r5,r0                                   @ save address heap for output string
    add r0,#NDlist_fin                            @ reservation place one element
    mov r7,#0x2D                                @ call system 'brk'
    svc #0
    cmp r0,#-1                                  @ allocation error
    beq 100f
    mov r0,r5
    str r4,[r0,#NDlist_value]                   @ store value
    mov r2,#0
    str r2,[r0,#NDlist_next]                    @ store zero to pointer next
    str r2,[r0,#NDlist_prev]                    @ store zero to pointer previous
100:
    pop {r1-r7,lr}                          @ restaur registers
    bx lr                                @ return
/***************************************************/
/*      ROUTINES INCLUDE                 */
/***************************************************/
.include "../affichage.inc"