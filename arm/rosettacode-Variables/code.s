/* ARM assembly Raspberry PI  */
/*  program variable.s   */
 
/************************************/
/* Constantes Définition            */
/************************************/
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ WRITE,  4     @ Linux syscall
/*********************************/
/* Initialized data              */
/*********************************/
.data
szString:         .asciz "String définition"
sArea1:            .fill 11, 1, ' '            @ 11 spaces
     @ or
sArea2:            .space 11,' '               @ 11 spaces

cCharac:          .byte '\n'                   @ character
cByte1:            .byte 0b10101               @ 1 byte binary value

hHalfWord1:       .hword   0xFF                @ 2 bytes value hexa
.align 4
iInteger1:      .int 123456                    @  4 bytes value decimal
iInteger3:      .short 0500                    @  4 bytes value octal
iPointer1:      .int 0x4000                    @   4 bytes value hexa
     @ or
iPointer2:      .word 0x4000                   @   4 bytes value hexa
iPointer3:       .int  04000                   @   4 bytes value octal

TabInteger4:     .int  5,4,3,2                 @ Area of 4 integers = 4 * 4 = 16 bytes

iDoubleInt1:     .quad  0xFFFFFFFFFFFFFFFF     @  8 bytes

dfFLOAT1:       .double 0f-31415926535897932384626433832795028841971.693993751E-40 @  Float 8 bytes
sfFLOAT2:       .float  0f-31415926535897932384626433832795028841971.693993751E-40 @  Float 4 bytes (or use .single)

/*********************************/
/* UnInitialized data            */
/*********************************/
.bss  
sBuffer:         .skip  500                       @ 500 bytes values zero
iInteger2:       .skip 4                          @ 4 bytes value zero
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                                             @ entry of program 
    ldr r0,iAdriInteger2                          @ load variable address
    mov r1,#100                                    
    str r1,[r0]                                   @ init variable iInteger2

100:                                              @ standard end of the program 
    mov r0, #0                                    @ return code
    mov r7, #EXIT                                 @ request to exit program
    svc #0                                        @ perform the system call
 
iAdriInteger2:             .int iInteger2         @ variable address iInteger2