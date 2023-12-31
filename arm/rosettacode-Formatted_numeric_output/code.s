/* ARM assembly Raspberry PI  */
/*  program formatNum.s   */
/* use C library printf  ha, ha, ha !!! */
/* Constantes               */
.equ EXIT,   1                         @ Linux syscall
/* Initialized data */
.data
szFormat1:         .asciz " %09.3f\n"
.align 4
sfNumber:          .double  0f-7125E-3
sfNumber1:         .double  0f7125E-3

/* UnInitialized data */
.bss 
.align 4

/*  code section */
.text
.global main 
main:                                   @ entry of program
    push {fp,lr}                        @ saves registers

    ldr r0,iAdrszFormat1                @ format
    ldr r1,iAdrsfNumber                 @ number address
    ldr r2,[r1]                         @ load first 4 bytes
    ldr r3,[r1,#4]                      @ load last 4 bytes
    bl printf                           @ call C function !!!
    ldr r0,iAdrszFormat1
    ldr r1,iAdrsfNumber1
    ldr r2,[r1]
    ldr r3,[r1,#4]
    bl printf



100:                                    @ standard end of the program
    mov r0, #0                          @ return code
    pop {fp,lr}                         @restaur  registers
    mov r7, #EXIT                       @ request to exit program
    swi 0                               @ perform the system call

iAdrszFormat1:           .int szFormat1
iAdrsfNumber:            .int sfNumber
iAdrsfNumber1:           .int sfNumber1