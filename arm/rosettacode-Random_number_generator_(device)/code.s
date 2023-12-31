/* ARM assembly Raspberry PI  */
/*  program urandom.s   */

/* Constantes    */
.equ STDOUT, 1                           @ Linux output console
.equ EXIT,   1                           @ Linux syscall
.equ READ,   3
.equ WRITE,  4
.equ OPEN,   5
.equ CLOSE,  6

.equ O_RDONLY, 0                         @ open for reading only

.equ BUFFERSIZE,          4              @ random number 32 bits

/* Initialized data */
.data
szFileName:              .asciz "/dev/urandom"      @ see linux doc 
szCarriageReturn:        .asciz "\n"
/* datas error display */
szMessErreur:        .asciz "Error detected.\n"
szMessErr:           .ascii "Error code hexa : "
sHexa:               .space 9,' '
                     .ascii "  decimal :  "
sDeci:               .space 15,' '
                     .asciz "\n"
/* datas message display */
szMessResult:        .ascii "Random number :"
sValue:              .space 12,' '
                     .asciz "\n"
/* UnInitialized data */
.bss 
sBuffer:             .skip BUFFERSIZE             @ buffer result

/*  code section */
.text
.global main 
main: 
    ldr r0,iAdrszFileName               @ File name
    mov r1,#O_RDONLY                    @  flags
    mov r2,#0                           @ mode
    mov r7,#OPEN                        @ open file
    svc #0 
    cmp r0,#0                           @ error ?
    ble error
    mov r8,r0                           @ save FD
    mov r4,#0                           @ loop counter
1:
    mov r0,r8                           @ File Descriptor
    ldr r1,iAdrsBuffer                  @ buffer address
    mov r2,#BUFFERSIZE                  @ buffer size
    mov r7,#READ                        @ call system read file
    svc 0 
    cmp r0,#0                           @ read error ?
    ble error
    ldr r1,iAdrsBuffer                  @ buffer address
    ldr r0,[r1]                         @ display buffer value
    ldr r1,iAdrsValue
    bl conversion10
    ldr r0,iAdrszMessResult
    bl affichageMess
    add r4,#1                           @ increment counter
    cmp r4,#10                          @ maxi ?
    blt 1b                              @ no -> loop


end:
    mov r0,r8
    mov r7, #CLOSE                      @ call system close file
    svc #0 
    cmp r0,#0
    blt error
    mov r0,#0                           @ return code
    b 100f
error:
    ldr r1,iAdrszMessErreur             @ error message
    bl   displayError
    mov r0,#1                           @ return error code
100:                                    @ standard end of the program
    mov r7, #EXIT                       @ request to exit program
    svc 0                               @ perform system call
iAdrsBuffer:               .int sBuffer
iAdrsValue:                .int sValue
iAdrszMessResult:          .int szMessResult
iAdrszFileName:            .int szFileName
iAdrszMessErreur:          .int szMessErreur
iAdrszCarriageReturn:      .int szCarriageReturn

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
/*   display error message                         */
/***************************************************/
/* r0 contains error code  r1 : message address */
displayError:
    push {r0-r2,lr}                         @ save registers
    mov r2,r0                               @ save error code
    mov r0,r1
    bl affichageMess
    mov r0,r2                               @ error code
    ldr r1,iAdrsHexa
    bl conversion16                         @ conversion hexa
    mov r0,r2                               @ error code
    ldr r1,iAdrsDeci                        @ result address
    bl conversion10S                        @ conversion decimale
    ldr r0,iAdrszMessErr                    @ display error message
    bl affichageMess
100:
    pop {r0-r2,lr}                          @ restaur registers
    bx lr                                   @ return 
iAdrszMessErr:                 .int szMessErr
iAdrsHexa:                     .int sHexa
iAdrsDeci:                     .int sDeci
/******************************************************************/
/*     Converting a register to hexadecimal                      */ 
/******************************************************************/
/* r0 contains value and r1 address area   */
conversion16:
    push {r1-r4,lr}                          @ save registers
    mov r2,#28                               @ start bit position
    mov r4,#0xF0000000                       @ mask
    mov r3,r0                                @ save entry value
1:                                           @ start loop
    and r0,r3,r4                             @ value register and mask
    lsr r0,r2                                @ move right 
    cmp r0,#10                               @ compare value
    addlt r0,#48                             @ <10  ->digit
    addge r0,#55                             @ >10  ->letter A-F
    strb r0,[r1],#1                          @ store digit on area and + 1 in area address
    lsr r4,#4                                @ shift mask 4 positions
    subs r2,#4                               @ counter bits - 4 <= zero  ?
    bge 1b                                   @ no -> loop

100:
    pop {r1-r4,lr}                                     @ restaur registers 
    bx lr     
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