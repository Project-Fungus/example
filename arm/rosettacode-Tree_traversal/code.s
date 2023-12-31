/* ARM assembly Raspberry PI  */
/*  program deftree2.s   */

/* Constantes    */
.equ STDOUT, 1                           @ Linux output console
.equ EXIT,   1                           @ Linux syscall
.equ READ,   3
.equ WRITE,  4

.equ NBVAL,    9

/*******************************************/
/* Structures                               */
/********************************************/
/* structure tree     */
    .struct  0
tree_root:                             @ root pointer
    .struct  tree_root + 4 
tree_size:                             @ number of element of tree
    .struct  tree_size + 4 
tree_fin:
/* structure node tree */
    .struct  0
node_left:                             @ left pointer
    .struct  node_left + 4 
node_right:                            @ right pointer
    .struct  node_right + 4 
node_value:                            @ element value
    .struct  node_value + 4 
node_fin:
/* structure queue*/
    .struct  0
queue_begin:                           @ next pointer
    .struct  queue_begin + 4 
queue_end:                             @ element value
    .struct  queue_end + 4 
queue_fin:
/* structure node queue    */
    .struct  0
queue_node_next:                       @ next pointer
    .struct  queue_node_next + 4 
queue_node_value:                      @ element value
    .struct  queue_node_value + 4 
queue_node_fin:
/* Initialized data */
.data
szMessInOrder:        .asciz "inOrder :\n"
szMessPreOrder:       .asciz "PreOrder :\n"
szMessPostOrder:      .asciz "PostOrder :\n"
szMessLevelOrder:     .asciz "LevelOrder :\n"
szCarriageReturn:     .asciz "\n"
/* datas error display */
szMessErreur:         .asciz "Error detected.\n"
/* datas message display */
szMessResult:         .ascii "Element value :"
sValue:               .space 12,' '
                      .asciz "\n"

/* UnInitialized data */
.bss 
stTree:               .skip tree_fin    @ place to structure tree
stQueue:              .skip queue_fin   @ place to structure queue
/*  code section */
.text
.global main 
main: 
    mov r1,#1                           @ node tree value
1:
    ldr r0,iAdrstTree                   @ structure tree address
    bl insertElement                    @ add element value r1
    cmp r0,#-1
    beq 99f
    add r1,#1                           @ increment value
    cmp r1,#NBVAL                       @ end ?
    ble 1b                              @ no -> loop

    ldr r0,iAdrszMessPreOrder
    bl affichageMess
    ldr r3,iAdrstTree                   @ tree root address (begin structure)
    ldr r0,[r3,#tree_root]
    ldr r1,iAdrdisplayElement           @ function to execute
    bl preOrder

    ldr r0,iAdrszMessInOrder
    bl affichageMess
    ldr r3,iAdrstTree
    ldr r0,[r3,#tree_root]
    ldr r1,iAdrdisplayElement           @ function to execute
    bl inOrder

    ldr r0,iAdrszMessPostOrder
    bl affichageMess
    ldr r3,iAdrstTree
    ldr r0,[r3,#tree_root]
    ldr r1,iAdrdisplayElement           @ function to execute
    bl postOrder

    ldr r0,iAdrszMessLevelOrder
    bl affichageMess
    ldr r3,iAdrstTree
    ldr r0,[r3,#tree_root]
    ldr r1,iAdrdisplayElement           @ function to execute
    bl levelOrder
    b 100f
99:                                     @ display error
    ldr r0,iAdrszMessErreur
    bl affichageMess
100:                                    @ standard end of the program
    mov r7, #EXIT                       @ request to exit program
    svc 0                               @ perform system call
iAdrszMessInOrder:         .int szMessInOrder
iAdrszMessPreOrder:        .int szMessPreOrder
iAdrszMessPostOrder:       .int szMessPostOrder
iAdrszMessLevelOrder:      .int szMessLevelOrder
iAdrszMessErreur:          .int szMessErreur
iAdrszCarriageReturn:      .int szCarriageReturn
iAdrstTree:                .int stTree
iAdrstQueue:               .int stQueue
iAdrdisplayElement:        .int displayElement
/******************************************************************/
/*     insert element in the tree                                 */ 
/******************************************************************/
/* r0 contains the address of the tree structure */
/* r1 contains the value of element              */
/* r0 returns address of element or - 1 if error */
insertElement:
    push {r1-r7,lr}                   @ save  registers 
    mov r4,r0
    mov r0,#node_fin                  @ reservation place one element
    bl allocHeap
    cmp r0,#-1                        @ allocation error
    beq 100f
    mov r5,r0
    str r1,[r5,#node_value]           @ store value in address heap
    mov r1,#0
    str r1,[r5,#node_left]            @ init left pointer with zero
    str r1,[r5,#node_right]           @ init right pointer with zero
    ldr r2,[r4,#tree_size]            @ load tree size
    cmp r2,#0                         @ 0 element ?
    bne 1f
    str r5,[r4,#tree_root]            @ yes -> store in root
    b 4f
1:                                    @ else search free address in tree
    ldr r3,[r4,#tree_root]            @ start with address root
    add r6,r2,#1                      @ increment tree size
    clz r7,r6                         @ compute zeroes left bits
    add r7,#1                         @ for sustract the first left bit
    lsl r6,r7                         @ shift number in left 
2:
    lsls r6,#1                        @ read left bit
    bcs 3f                            @ is 1 ?
    ldr r1,[r3,#node_left]            @ no store node address in left pointer
    cmp r1,#0                         @ if equal zero
    streq r5,[r3,#node_left]
    beq 4f
    mov r3,r1                         @ else loop with next node
    b 2b
3:                                    @ yes 
    ldr r1,[r3,#node_right]           @ store node address in right pointer
    cmp r1,#0                         @ if equal zero
    streq r5,[r3,#node_right]
    beq 4f
    mov r3,r1                         @ else loop with next node
    b 2b
4:
    add r2,#1                         @ increment tree size
    str r2,[r4,#tree_size]
100:
    pop {r1-r7,lr}                    @ restaur registers
    bx lr                             @ return
/******************************************************************/
/*     preOrder                                  */ 
/******************************************************************/
/* r0 contains the address of the node */
/* r1 function address                 */
preOrder:
    push {r1-r2,lr}                       @ save  registers 
    cmp r0,#0
    beq 100f
    mov r2,r0
    blx r1                                @ call function

    ldr r0,[r2,#node_left]
    bl preOrder
    ldr r0,[r2,#node_right]
    bl preOrder
100:
    pop {r1-r2,lr}                        @ restaur registers
    bx lr       
/******************************************************************/
/*     inOrder                                  */ 
/******************************************************************/
/* r0 contains the address of the node */
/* r1 function address                 */
inOrder:
    push {r1-r3,lr}                    @ save  registers 
    cmp r0,#0
    beq 100f
    mov r3,r0
    mov r2,r1
    ldr r0,[r3,#node_left]
    bl inOrder
    mov r0,r3
    blx r2                             @ call function

    ldr r0,[r3,#node_right]
    mov r1,r2
    bl inOrder
100:
    pop {r1-r3,lr}                     @ restaur registers
    bx lr                              @ return
/******************************************************************/
/*     postOrder                                  */ 
/******************************************************************/
/* r0 contains the address of the node */
/* r1 function address                 */
postOrder:
    push {r1-r3,lr}                    @ save  registers 
    cmp r0,#0
    beq 100f
    mov r3,r0
    mov r2,r1
    ldr r0,[r3,#node_left]
    bl postOrder

    ldr r0,[r3,#node_right]
    mov r1,r2
    bl postOrder
    mov r0,r3
    blx r2                            @ call function
100:
    pop {r1-r3,lr}                    @ restaur registers
    bx lr                             @ return
/******************************************************************/
/*     levelOrder                                  */ 
/******************************************************************/
/* r0 contains the address of the node */
/* r1 function address                 */
levelOrder:
    push {r1-r4,lr}                       @ save  registers 
    cmp r0,#0
    beq 100f
    mov r2,r1
    mov r1,r0
    ldr r0,iAdrstQueue                    @ adresse queue
    bl enqueueNode                        @ queue the node
1:                                        @ begin loop
    ldr r0,iAdrstQueue
    bl isEmptyQueue                       @ is queue empty
    cmp r0,#0
    beq 100f                              @ yes -> end
    ldr r0,iAdrstQueue
    bl dequeueNode
    mov r3,r0                             @ save node
    blx r2                                @ call function
    ldr r4,[r3,#node_left]                @ left node ok ?
    cmp r4,#0
    beq 2f                                @ no
    ldr r0,iAdrstQueue                    @ yes -> enqueue
    mov r1,r4
    bl enqueueNode
2:
    ldr r4,[r3,#node_right]               @ right node ok ?
    cmp r4,#0
    beq 3f                                @ no
    ldr r0,iAdrstQueue                    @ yes -> enqueue
    mov r1,r4
    bl enqueueNode
3:
    b 1b                                  @ and loop

100:
    pop {r1-r4,lr}                        @ restaur registers
    bx lr                                 @ return
/******************************************************************/
/*     display node                                               */ 
/******************************************************************/
/* r0 contains node  address          */
displayElement:
    push {r1,lr}                       @ save  registers 
    ldr r0,[r0,#node_value]
    ldr r1,iAdrsValue
    bl conversion10S
    ldr r0,iAdrszMessResult
    bl affichageMess
100:
    pop {r1,lr}                        @ restaur registers
    bx lr                              @ return
iAdrszMessResult:          .int szMessResult
iAdrsValue:                .int sValue
/******************************************************************/
/*     enqueue node                                  */ 
/******************************************************************/
/* r0 contains the address of the queue */
/* r1 contains the value of element  */
/* r0 returns address of element or - 1 if error */
enqueueNode:
    push {r1-r5,lr}                       @ save  registers 
    mov r4,r0
    mov r0,#queue_node_fin                @ allocation place heap
    bl allocHeap
    cmp r0,#-1                            @ allocation error
    beq 100f
    mov r5,r0                             @ save heap address
    str r1,[r5,#queue_node_value]         @ store node value 
    mov r1,#0
    str r1,[r5,#queue_node_next]          @ init pointer next
    ldr r0,[r4,#queue_end]
    cmp r0,#0
    strne r5,[r0,#queue_node_next]
    streq r5,[r4,#queue_begin]
    str r5,[r4,#queue_end]
    mov r0,#0
    pop {r1-r5,lr}
    bx lr                             @ return
/******************************************************************/
/*     dequeue node                                  */ 
/******************************************************************/
/* r0 contains the address of the queue */
/* r0 returns address of element or - 1 if error */
dequeueNode:
    push {r1-r5,lr}                       @ save  registers 
    ldr r4,[r0,#queue_begin]
    ldr r5,[r4,#queue_node_value]
    ldr r6,[r4,#queue_node_next]
    str r6,[r0,#queue_begin]
    cmp r6,#0
    streq r6,[r0,#queue_end]
    mov r0,r5
100:
    pop {r1-r5,lr}
    bx lr                             @ return
/******************************************************************/
/*     dequeue node                                  */ 
/******************************************************************/
/* r0 contains the address of the queue */
/* r0 returns 0 if empty else 1  */
isEmptyQueue:
    ldr r0,[r0,#queue_begin]
    cmp r0,#0
    movne r0,#1
    bx lr                             @ return
/******************************************************************/
/*     memory allocation on the heap                                  */ 
/******************************************************************/
/* r0 contains the size to allocate */
/* r0 returns address of memory heap or - 1 if error */
/* CAUTION : The size of the allowance must be a multiple of 4  */
allocHeap:
    push {r5-r7,lr}                   @ save  registers 
    @ allocation
    mov r6,r0                         @ save size
    mov r0,#0                         @ read address start heap
    mov r7,#0x2D                      @ call system 'brk'
    svc #0
    mov r5,r0                         @ save address heap for return
    add r0,r6                         @ reservation place for size
    mov r7,#0x2D                      @ call system 'brk'
    svc #0
    cmp r0,#-1                        @ allocation error
    movne r0,r5                       @ return address memory heap
    pop {r5-r7,lr}                    @ restaur registers
    bx lr                             @ return
/******************************************************************/
/*     display text with size calculation                         */ 
/******************************************************************/
/* r0 contains the address of the message */
affichageMess:
    push {r0,r1,r2,r7,lr}                       @ save  registers 
    mov r2,#0                                   @ counter length */
1:                                              @ loop length calculation
    ldrb r1,[r0,r2]                             @ read octet start position + index 
    cmp r1,#0                                   @ if 0 its over
    addne r2,r2,#1                              @ else add 1 in the length
    bne 1b                                      @ and loop 
                                                @ so here r2 contains the length of the message 
    mov r1,r0                                   @ address message in r1 
    mov r0,#STDOUT                              @ code to write to the standard output Linux
    mov r7, #WRITE                              @ code call system "write" 
    svc #0                                      @ call system
    pop {r0,r1,r2,r7,lr}                        @ restaur registers
    bx lr                                       @ return
/***************************************************/
/*  Converting a register to a signed decimal      */
/***************************************************/
/* r0 contains value and r1 area address    */
conversion10S:
    push {r0-r4,lr}       @ save registers
    mov r2,r1             @ debut zone stockage
    mov r3,#'+'           @ par defaut le signe est +
    cmp r0,#0             @ negative number ? 
    movlt r3,#'-'         @ yes
    mvnlt r0,r0           @ number inversion
    addlt r0,#1
    mov r4,#10            @ length area
1:                        @ start loop
    bl divisionpar10U
    add r1,#48            @ digit
    strb r1,[r2,r4]       @ store digit on area
    sub r4,r4,#1          @ previous position
    cmp r0,#0             @ stop if quotient = 0
    bne 1b	

    strb r3,[r2,r4]       @ store signe 
    subs r4,r4,#1         @ previous position
    blt  100f             @ if r4 < 0 -> end

    mov r1,#' '           @ space
2:
    strb r1,[r2,r4]       @store byte space
    subs r4,r4,#1         @ previous position
    bge 2b                @ loop if r4 > 0
100: 
    pop {r0-r4,lr}        @ restaur registers
    bx lr  
/***************************************************/
/*   division par 10   unsigned                    */
/***************************************************/
/* r0 dividende   */
/* r0 quotient    */
/* r1 remainder   */
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

PreOrder :
Element value :         +1
Element value :         +2
Element value :         +4
Element value :         +8
Element value :         +9
Element value :         +5
Element value :         +3
Element value :         +6
Element value :         +7
inOrder :
Element value :         +8
Element value :         +4
Element value :         +9
Element value :         +2
Element value :         +5
Element value :         +1
Element value :         +6
Element value :         +3
Element value :         +7
PostOrder :
Element value :         +8
Element value :         +9
Element value :         +4
Element value :         +5
Element value :         +2
Element value :         +6
Element value :         +7
Element value :         +3
Element value :         +1
LevelOrder :
Element value :         +1
Element value :         +2
Element value :         +3
Element value :         +4
Element value :         +5
Element value :         +6
Element value :         +7
Element value :         +8
Element value :         +9