/* ARM assembly Raspberry PI  */
/*  program nroot.s   */
/* compile with option -mfpu=vfpv3 -mfloat-abi=hard */ 
/* link with gcc. Use C function for display float */  

/* Constantes               */
.equ EXIT,   1                         @ Linux syscall

/* Initialized data */
.data
szFormat1:         .asciz " %+09.15f\n"
.align 4
iNumberA:          .int 1024

/* UnInitialized data */
.bss 
.align 4

/*  code section */
.text
.global main 
main:                                   @ entry of program
    push {fp,lr}                        @ saves registers

    /* root 10ieme de 1024  */
    ldr r0,iAdriNumberA                 @ number address
    ldr r0,[r0]
    vmov s0,r0                          @ 
    vcvt.f64.s32 d0, s0                 @conversion in float single précision (32 bits)
    mov r0,#10                          @ N
    bl nthRoot
    ldr r0,iAdrszFormat1                @ format
    vmov r2,r3,d0
    bl printf                           @ call C function !!!
                                        @ Attention register dn lost !!!
    /* square root of 2   */ 
    vmov.f64 d1,#2.0                    @ conversion 2 in float register d1
    mov r0,#2                           @ N
    bl nthRoot
    ldr r0,iAdrszFormat1                @ format
    vmov r2,r3,d0
    bl printf                           @ call C function !!!

100:                                    @ standard end of the program
    mov r0, #0                          @ return code
    pop {fp,lr}                         @restaur  registers
    mov r7, #EXIT                       @ request to exit program
    swi 0                               @ perform the system call

iAdrszFormat1:           .int szFormat1
iAdriNumberA:            .int iNumberA

/******************************************************************/
/*     compute  nth root                                          */ 
/******************************************************************/
/* r0 contains N   */
/* d0 contains the value                 */
/* d0 return result                      */
nthRoot:
    push {r1,r2,lr}                    @ save  registers 
    vpush {d1-d8}                         @ save float registers
    FMRX    r1,FPSCR                   @ copy FPSCR into r1
    BIC     r1,r1,#0x00370000          @ clears STRIDE and LEN
    FMXR    FPSCR,r1                   @ copy r1 back into FPSCR

    vmov s2,r0                         @ 
    vcvt.f64.s32 d6, s2                @ N conversion in float double précision (64 bits)
    sub r1,r0,#1                       @ N - 1
    vmov s8,r1                         @ 
    vcvt.f64.s32 d4, s8                @conversion in float double précision (64 bits)
    vmov.f64 d2,d0                     @ a = A
    vdiv.F64 d3,d0,d6                  @ b = A/n
    adr r2,dfPrec                      @ load précision
    vldr d8,[r2]                  
1:                                     @ begin loop
    vmov.f64 d2,d3                     @ a <- b
    vmul.f64 d5,d3,d4                  @ (N-1)*b

    vmov.f64 d1,#1.0                   @ constante 1 -> float
    mov r2,#0                          @ loop indice
2:                                     @ compute pow (n-1)
    vmul.f64 d1,d1,d3                  @ 
    add r2,#1
    cmp r2,r1                          @ n -1 ?
    blt 2b                             @ no -> loop
    vdiv.f64 d7,d0,d1                  @ A / b pow (n-1)
    vadd.f64 d7,d7,d5                  @ + (N-1)*b
    vdiv.f64 d3,d7,d6                  @ / N -> new b
    vsub.f64 d1,d3,d2                  @ compute gap
    vabs.f64 d1,d1                     @ absolute value
    vcmp.f64 d1,d8                     @ compare float maj FPSCR
    fmstat                             @ transfert FPSCR -> APSR
                                       @ or use VMRS APSR_nzcv, FPSCR
    bgt 1b                             @ if gap > précision -> loop 
    vmov.f64 d0,d3                     @ end return result in d0

100:
    vpop {d1-d8}                       @ restaur float registers
    pop {r1,r2,lr}                     @ restaur arm registers
    bx lr
dfPrec:            .double 0f1E-10     @ précision