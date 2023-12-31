/* ARM assembly Raspberry PI  */
/*  program ending.s   */

/* Constantes               */
.equ EXIT,   1                          @ Linux syscall

/* Initialized data */
.data

/*  code section */
.text
.global main 
main:                                   @ entry of program
    push {fp,lr}                        @ saves registers

OK:
    @ end program OK 
    mov r0, #0                          @ return code
    b 100f
NONOK:
    @ if error detected end program no ok
    mov r0, #1                          @ return code
100:                                    @ standard end of the program
    pop {fp,lr}                         @restaur  registers
    mov r7, #EXIT                       @ request to exit program
    swi 0                               @ perform the system call Linux