/* ARM assembly Raspberry PI  */
/*  program defList.s   */

/* Constantes    */
.equ STDOUT, 1                           @ Linux output console
.equ EXIT,   1                           @ Linux syscall
.equ READ,   3
.equ WRITE,  4

.equ NBELEMENTS,      100                @ list size

/*******************************************/
/* Structures                               */
/********************************************/
/* structure linkedlist*/
    .struct  0
llist_next:                             @ next element
    .struct  llist_next + 4 
llist_value:                            @ element value
    .struct  llist_value + 4 
llist_fin:
/* Initialized data */
.data
szMessInitListe:         .asciz "List initialized.\n"
szCarriageReturn:        .asciz "\n"
/* datas error display */
szMessErreur:            .asciz "Error detected.\n"

/* UnInitialized data */
.bss 
lList1:                  .skip llist_fin * NBELEMENTS    @ list memory place 

/*  code section */
.text
.global main 
main: 
    ldr r0,iAdrlList1
    mov r1,#0
    str r1,[r0,#llist_next]
    ldr r0,iAdrszMessInitListe
    bl affichageMess

100:                                    @ standard end of the program
    mov r7, #EXIT                       @ request to exit program
    svc 0                               @ perform system call
iAdrszMessInitListe:       .int szMessInitListe
iAdrszMessErreur:          .int szMessErreur
iAdrszCarriageReturn:      .int szCarriageReturn
iAdrlList1:                .int lList1
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