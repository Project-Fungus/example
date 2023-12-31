/* ARM assembly Raspberry PI  */
/*  program afficheList.s   */

/* Constantes    */
.equ STDOUT, 1                           @ Linux output console
.equ EXIT,   1                           @ Linux syscall
.equ READ,   3
.equ WRITE,  4

.equ NBELEMENTS,      100              @ list size

/*******************************************/
/* Structures                               */
/********************************************/
/* structure linkedlist*/
    .struct  0
llist_next:                            @ next element
    .struct  llist_next + 4 
llist_value:                           @ element value
    .struct  llist_value + 4 
llist_fin:
/* Initialized data */
.data
szMessInitListe:         .asciz "List initialized.\n"
szCarriageReturn:        .asciz "\n"
/* datas error display */
szMessErreur:            .asciz "Error detected.\n"
/* datas message display */
szMessResult:            .ascii "Element No :"
sNumElement:             .space 12,' '
                         .ascii " value :  "
sValue:                  .space 12,' '
                         .asciz "\n"

/* UnInitialized data */
.bss 
lList1:              .skip llist_fin * NBELEMENTS    @ list memory place 
/*  code section */
.text
.global main 
main: 
    ldr r0,iAdrlList1
    mov r1,#0                           @ list init
    str r1,[r0,#llist_next]
    ldr r0,iAdrszMessInitListe
    bl affichageMess
    ldr r0,iAdrlList1
    mov r1,#2
    bl insertElement                    @ add element value 2
    ldr r0,iAdrlList1
    mov r1,#5
    bl insertElement                    @ add element value 5
    @                                   @ display elements of list
    ldr r3,iAdrlList1
    mov r2,#0                           @ ident element
1:
    ldr r0,[r3,#llist_next]             @ end list ?
    cmp r0,#0
    beq 100f                            @ yes
    add r2,#1
    mov r0,r2                           @ display No element and value
    ldr r1,iAdrsNumElement
    bl conversion10S
    ldr r0,[r3,#llist_value]
    ldr r1,iAdrsValue
    bl conversion10S
    ldr r0,iAdrszMessResult
    bl affichageMess
    ldr r3,[r3,#llist_next]             @ next element
    b 1b                                @ and loop
100:                                    @ standard end of the program
    mov r7, #EXIT                       @ request to exit program
    svc 0                               @ perform system call
iAdrszMessInitListe:       .int szMessInitListe
iAdrszMessErreur:          .int szMessErreur
iAdrszCarriageReturn:      .int szCarriageReturn
iAdrlList1:                .int lList1
iAdrszMessResult:          .int szMessResult
iAdrsNumElement:           .int sNumElement
iAdrsValue:                .int sValue

/******************************************************************/
/*     insert element at end of list                          */ 
/******************************************************************/
/* r0 contains the address of the list */
/* r1 contains the value of element  */
/* r0 returns address of element or - 1 if error */
insertElement:
    push {r1-r3,lr}                       @ save  registers 
    mov r2,#llist_fin * NBELEMENTS
    add r2,r0                             @ compute address end list
1:                                        @ start loop 
    ldr r3,[r0,#llist_next]               @ load next pointer
    cmp r3,#0                             @ = zero
    movne r0,r3                           @ no -> loop with pointer
    bne 1b
    add r3,r0,#llist_fin                  @ yes -> compute next free address
    cmp r3,r2                             @ > list end 
    movge r0,#-1                          @ yes -> error
    bge 100f
    str r3,[r0,#llist_next]               @ store next address in current pointer
    str r1,[r0,#llist_value]              @ store element value
    mov r1,#0
    str r1,[r3,#llist_next]               @ init next pointer in next address

100:
    pop {r1-r3,lr}                        @ restaur registers
    bx lr                                 @ return
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