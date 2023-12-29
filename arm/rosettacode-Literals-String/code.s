/* ARM assembly Raspberry PI  */
/*  program stringsEx.s   */

/* Constantes    */
.equ STDOUT, 1                           @ Linux output console
.equ EXIT,   1                           @ Linux syscall
.equ WRITE,  4                           @ Linux syscall

/* Initialized data */
.data
szMessString:            .asciz "String with final zero \n"
szMessString1:           .string "Other string with final zero \n"
sString:                 .ascii "String without final zero"
                         .byte 0             @ add final zero for display
sLineSpaces:             .byte '>'
                         .fill 10,1,' '      @ 10 spaces
                         .asciz "<\n"        @ add <, CR and final zero for display
sSpaces1:                .space 10,' '       @ other 10 spaces
                         .byte 0             @ add final zero for display
sCharA:                  .space 10,'A'       @ curious !! 10 A with space instruction
                         .asciz "\n"         @ add CR and final zero for display

cChar1:                  .byte 'A'           @ character A
cChar2:                  .byte 0x41          @ character A

szCarriageReturn:        .asciz "\n"

/* UnInitialized data */
.bss 

/*  code section */
.text
.global main 
main: 

    ldr r0,iAdrszMessString
    bl affichageMess                            @ display message
    ldr r0,iAdrszMessString1
    bl affichageMess
    ldr r0,iAdrsString
    bl affichageMess
    ldr r0,iAdrszCarriageReturn
    bl affichageMess
    ldr r0,iAdrsLineSpaces
    bl affichageMess
    ldr r0,iAdrsCharA
    bl affichageMess

100:                                            @ standard end of the program
    mov r0, #0                                  @ return code
    mov r7, #EXIT                               @ request to exit program
    svc 0                                       @ perform system call
iAdrszMessString:         .int szMessString
iAdrszMessString1:        .int szMessString1
iAdrsString:              .int sString
iAdrsLineSpaces:          .int sLineSpaces
iAdrszCarriageReturn:     .int szCarriageReturn
iAdrsCharA:               .int sCharA

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