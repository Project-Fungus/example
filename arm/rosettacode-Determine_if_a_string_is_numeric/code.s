/* ARM assembly Raspberry PI  */
/*  program strNumber.s   */

/* Constantes    */
.equ STDIN,  0                           @ Linux input console
.equ STDOUT, 1                           @ Linux output console
.equ EXIT,   1                           @ Linux syscall
.equ READ,   3                           @ Linux syscall
.equ WRITE,  4                           @ Linux syscall

.equ BUFFERSIZE,          100


/* Initialized data */
.data
szMessNum: .asciz "Enter number : \n"

szMessError:            .asciz "String is not a number !!!\n"
szMessInteger:          .asciz "String is a integer.\n"
szMessFloat:            .asciz "String is a float.\n"
szMessFloatExp:         .asciz "String is a float with exposant.\n"
szCarriageReturn:       .asciz "\n"

/* UnInitialized data */
.bss 
sBuffer:              .skip BUFFERSIZE

/*  code section */
.text
.global main 
main: 

loop:
    ldr r0,iAdrszMessNum
    bl affichageMess
    mov r0,#STDIN                               @ Linux input console
    ldr r1,iAdrsBuffer                          @ buffer address 
    mov r2,#BUFFERSIZE                          @ buffer size 
    mov r7, #READ                               @ request to read datas
    swi 0                                       @ call system
    ldr r1,iAdrsBuffer                          @ buffer address 
    mov r2,#0                                   @ end of string
    sub r0,#1                                   @ replace character 0xA
    strb r2,[r1,r0]                             @ store byte at the end of input string (r0 contains number of characters)
    ldr r0,iAdrsBuffer
    bl controlNumber                            @ call routine
    cmp r0,#0
    bne 1f
    ldr r0,iAdrszMessError                      @ not a number
    bl affichageMess
    b 5f
1:
    cmp r0,#1
    bne 2f
    ldr r0,iAdrszMessInteger                    @ integer
    bl affichageMess
    b 5f
2:
    cmp r0,#2
    bne 3f
    ldr r0,iAdrszMessFloat                      @ float
    bl affichageMess
    b 5f
3:
    cmp r0,#3
    bne 5f
    ldr r0,iAdrszMessFloatExp                   @ float with exposant
    bl affichageMess
5:
    b loop

100:                                            @ standard end of the program
    mov r0, #0                                  @ return code
    mov r7, #EXIT                               @ request to exit program
    svc 0                                       @ perform system call
iAdrszMessNum:            .int szMessNum
iAdrszMessError:          .int szMessError
iAdrszMessInteger:        .int szMessInteger
iAdrszMessFloat:          .int szMessFloat
iAdrszMessFloatExp:       .int szMessFloatExp
iAdrszCarriageReturn:     .int szCarriageReturn
iAdrsBuffer:              .int sBuffer
/******************************************************************/
/*     control if string is number                          */ 
/******************************************************************/
/* r0 contains the address of the string */
/* r0 return 0 if not a number       */
/* r0 return 1 if integer   eq 12345 or -12345      */
/* r0 return 2 if float     eq 123.45 or 123,45  or -123,45     */
/* r0 return 3 if float with exposant  eq 123.45E30 or -123,45E-30        */
controlNumber:
    push {r1-r4,lr}                       @ save  registers 
    mov r1,#0
    mov r3,#0          @ point counter 
1:
    ldrb r2,[r0,r1]
    cmp r2,#0
    beq 5f
    cmp r2,#' '
    addeq r1,#1
    beq   1b
    cmp r2,#'-'                    @ negative ?
    addeq r1,#1
    beq 2f
    cmp r2,#'+'                    @ positive ?
    addeq r1,#1
2:
    ldrb r2,[r0,r1]                @ control space
    cmp r2,#0                      @ end ?
    beq 5f
    cmp r2,#' '
    addeq r1,#1
    beq 2b
3:
    ldrb r2,[r0,r1]
    cmp r2,#0                 @ end ?
    beq 10f
    cmp r2,#'E'               @ exposant ?
    beq 6f
    cmp r2,#'e'               @ exposant ?
    beq 6f
    cmp r2,#'.'               @ point ?
    addeq r3,#1               @ yes increment counter
    addeq r1,#1
    beq 3b
    cmp r2,#','               @ comma ?
    addeq r3,#1               @ yes increment counter
    addeq r1,#1
    beq 3b
    cmp r2,#'0'               @ control digit < 0
    blt 5f
    cmp r2,#'9'               @ control digit > 0
    bgt 5f
    add r1,#1                 @ no error loop digit
    b 3b
5:                            @ error detected
    mov r0,#0
    b 100f
6:    @ float with exposant
    add r1,#1
    ldrb r2,[r0,r1]
    cmp r2,#0             @ end ?
    moveq r0,#0           @ error
    beq 100f
    cmp r2,#'-'           @ negative exposant ?
    addeq r1,#1
    mov r4,#0             @ nombre de chiffres 
7:
    ldrb r2,[r0,r1]
    cmp r2,#0             @ end ?
    beq 9f
    cmp r2,#'0'           @ control digit < 0
    blt 8f
    cmp r2,#'9'           @ control digit > 0
    bgt 8f
    add r1,#1
    add r4,#1             @ counter digit
    b 7b
8:
    mov r0,#0
    b 100f
9:
    cmp r4,#0             @ number digit exposant = 0 -> error 
    moveq r0,#0           @ erreur
    beq 100f
    cmp r4,#2             @ number digit exposant > 2 -> error 
    movgt r0,#0           @ error
    bgt 100f
    mov r0,#3             @ valid float with exposant
    b 100f
10:
    cmp r3,#0
    moveq r0,#1           @ valid integer
    beq 100f
    cmp r3,#1             @ number of point or comma = 1 ?
    moveq r0,#2           @ valid float
    movgt r0,#0           @ error
100:
    pop {r1-r4,lr}                         @ restaur des  2 registres
    bx lr                                        @ return
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