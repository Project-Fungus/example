/* ARM assembly Raspberry PI  */
/*  program commandLine.s   */

/* Constantes    */
.equ STDOUT, 1                         @ Linux output console
.equ EXIT,   1                         @ Linux syscall
.equ WRITE,  4                         @ Linux syscall
/* Initialized data */
.data
szCarriageReturn:  .asciz "\n"

/* UnInitialized data */
.bss 
.align 4

/*  code section */
.text
.global main 
main:                                   @ entry of program
    push {fp,lr}                        @ saves registers
    add fp,sp,#8                        @  fp <- start address
    ldr r4,[fp]                         @ number of Command line arguments
    add r5,fp,#4                        @ first parameter address 
    mov r2,#0                           @ init loop counter
loop:
    ldr r0,[r5,r2,lsl #2]               @ string address parameter
    bl affichageMess                    @ display string
    ldr r0,iAdrszCarriageReturn
    bl affichageMess                    @ display carriage return
    add r2,#1                           @ increment counter
    cmp r2,r4                           @ number parameters ?
    blt loop                            @ loop

100:                                    @ standard end of the program
    mov r0, #0                          @ return code
    pop {fp,lr}                         @restaur  registers
    mov r7, #EXIT                       @ request to exit program
    swi 0                               @ perform the system call

iAdrszCarriageReturn:    .int szCarriageReturn


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
    pop {r0,r1,r2,r7,lr}                           @ restaur 2 registres
    bx lr                                          @ return