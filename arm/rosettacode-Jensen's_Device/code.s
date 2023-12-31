/* ARM assembly Raspberry PI  */
/*  program jensen.s   */
/* compil as with option  -mcpu=<processor> -mfpu=vfpv4 -mfloat-abi=hard  */
/* link with gcc          */

/* Constantes    */
.equ EXIT,   1                           @ Linux syscall
/* Initialized data */
.data

szFormat: .asciz "Result = %.8f \n" 
.align 4

/* UnInitialized data */
.bss 

/*  code section */
.text
.global main 
main: 
    mov r0,#1                                   @ first indice
    mov r1,#100                                 @ last indice
    adr r2,funcdiv                              @ address function
    bl funcSum
    vcvt.f64.f32  d1, s0                        @ conversion double float for print by C
    ldr r0,iAdrszFormat                         @ display format
    vmov r2,r3,d1                               @ parameter function printf for float double
    bl printf                                   @ display float double

100:                                            @ standard end of the program
    mov r0, #0                                  @ return code
    mov r7, #EXIT                               @ request to exit program
    svc 0                                       @ perform system call

iAdrszFormat:             .int szFormat
/******************************************************************/
/*     function sum                                               */ 
/******************************************************************/
/* r0 contains begin  */
/* r1 contains end */
/* r2 contains address function */

/* r0 return result                      */
funcSum:
    push {r0,r3,lr}                       @ save  registers 
    mov r3,r0
    mov r0,#0                             @ init r0
    vmov s3,r0                            @ and s3
    vcvt.f32.s32 s3, s3                   @ convert in float single précision (32bits)
1:                                        @ begin loop
    mov r0,r3                             @ loop indice -> parameter function
    blx r2                                @ call function address in r2
    vadd.f32 s3,s0                        @ addition float
    add r3,#1                             @ increment indice
    cmp r3,r1                             @ end ?
    ble 1b                                @ no loop
    vmov s0,s3                            @ return float result in s0

100:
    pop {r0,r3,lr}                        @ restaur registers
    bx lr                                 @ return
/******************************************************************/
/*     compute 1/r0                                               */ 
/******************************************************************/
/* r0 contains the value                 */
/* r0 return result                      */
funcdiv:
    push {r1,lr}                       @ save  registers 
    vpush {s1}                         @ save float registers
    cmp r0,#0                          @ division by zero -> end
    beq 100f
    ldr r1,fUn                         @ load float constant 1.0
    vmov s0,r1                         @ in float register s3
    vmov s1,r0                         @ 
    vcvt.f32.s32 s1, s1                @conversion in float single précision (32 bits)
    vdiv.f32 s0,s0,s1                  @ division 1/r0
                                       @ and return result in s0
100:
    vpop {s1}                          @ restaur float registers
    pop {r1,lr}                        @ restaur registers
    bx lr                              @ return
fUn:                .float 1