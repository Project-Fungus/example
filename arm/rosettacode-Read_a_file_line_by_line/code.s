/* ARM assembly Raspberry PI  */
/*  program readfile.s   */

/* Constantes    */
.equ STDOUT, 1                           @ Linux output console
.equ EXIT,   1                           @ Linux syscall
.equ READ,   3
.equ WRITE,  4
.equ OPEN,   5
.equ CLOSE,  6

.equ O_RDWR,  0x0002                    @ open for reading and writing

.equ BUFFERSIZE,          100
.equ LINESIZE,            100

/*******************************************/
/* Structures                               */
/********************************************/
/* structure read file*/
    .struct  0
readfile_Fd:                           @ File descriptor
    .struct  readfile_Fd + 4 
readfile_buffer:                       @ read buffer
    .struct  readfile_buffer + 4 
readfile_buffersize:                   @ buffer size
    .struct  readfile_buffersize + 4 
readfile_line:                         @ line buffer 
    .struct  readfile_line + 4 
readfile_linesize:                     @ line buffer size
    .struct  readfile_linesize + 4 
readfile_pointer:
    .struct  readfile_pointer + 4      @ read pointer  (init to buffer size + 1)
readfile_end:
/* Initialized data */
.data
szFileName:              .asciz "fictest.txt"
szCarriageReturn:        .asciz "\n"
/* datas error display */
szMessErreur:        .asciz "Error detected.\n"
szMessErr:           .ascii "Error code hexa : "
sHexa:               .space 9,' '
                     .ascii "  decimal :  "
sDeci:               .space 15,' '
                     .asciz "\n"

/* UnInitialized data */
.bss 
sBuffer:             .skip BUFFERSIZE             @ buffer result
szLineBuffer:        .skip LINESIZE
.align 4
stReadFile:          .skip readfile_end

/*  code section */
.text
.global main 
main: 
    ldr r0,iAdrszFileName               @ File name
    mov r1,#O_RDWR                      @  flags
    mov r2,#0                           @ mode
    mov r7,#OPEN                        @ open file
    svc #0 
    cmp r0,#0                           @ error ?
    ble error
    ldr r1,iAdrstReadFile               @ init struture readfile
    str r0,[r1,#readfile_Fd]            @ save FD in structure
    ldr r0,iAdrsBuffer                  @ buffer address
    str r0,[r1,#readfile_buffer]
    mov r0,#BUFFERSIZE                  @ buffer size
    str r0,[r1,#readfile_buffersize]
    ldr r0,iAdrszLineBuffer             @ line buffer address
    str r0,[r1,#readfile_line]
    mov r0,#LINESIZE                    @ line buffer size
    str r0,[r1,#readfile_linesize]
    mov r0,#BUFFERSIZE + 1              @ init read pointer
    str r0,[r1,#readfile_pointer]
1:                                      @ begin read loop
    mov r0,r1
    bl readLineFile
    cmp r0,#0
    beq end                             @ end loop
    blt error

    ldr r0,iAdrszLineBuffer             @  display line
    bl affichageMess
    ldr r0,iAdrszCarriageReturn         @ display line return
    bl affichageMess
    b 1b                                @ and loop

end:
    ldr r1,iAdrstReadFile
    ldr r0,[r1,#readfile_Fd]            @ load FD to structure
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
iAdrszFileName:            .int szFileName
iAdrszMessErreur:          .int szMessErreur
iAdrszCarriageReturn:      .int szCarriageReturn
iAdrstReadFile:            .int stReadFile
iAdrszLineBuffer:          .int szLineBuffer
/******************************************************************/
/*     sub strings  index start  number of characters             */ 
/******************************************************************/
/* r0 contains the address of the structure */
/* r0 returns number of characters or -1 if error */
readLineFile:
    push {r1-r8,lr}                             @ save  registers 
    mov r4,r0                                   @ save structure
    ldr r1,[r4,#readfile_buffer]
    ldr r2,[r4,#readfile_buffersize]
    ldr r5,[r4,#readfile_pointer]
    ldr r6,[r4,#readfile_linesize]
    ldr r7,[r4,#readfile_buffersize]
    ldr r8,[r4,#readfile_line]
    mov r3,#0                                   @ line pointer
    strb r3,[r8,r3]                             @ store zéro in line buffer
    cmp r5,r2                                   @ pointer buffer < buffer size ?
    ble 2f                                      @ no file read
1:                                              @ loop read file
    ldr r0,[r4,#readfile_Fd]
    mov r7,#READ                                @ call system read file
    svc 0 
    cmp r0,#0                                   @ error read or end ?
    ble 100f
    mov r7,r0                                   @ number of read characters
    mov r5,#0                                   @ init buffer pointer

2:                                              @ begin loop copy characters
    ldrb r0,[r1,r5]                             @ load 1 character read buffer
    cmp r0,#0x0A                                @ end line ?
    beq 4f
    strb r0,[r8,r3]                             @ store character in line buffer
    add r3,#1                                   @ increment pointer line
    cmp r3,r6
    movgt r0,#-2                                @ line buffer too small -> error
    bgt 100f
    add r5,#1                                   @ increment buffer pointer
    cmp r5,r2                                   @ end buffer ?
    bge 1b                                      @ yes new read
    cmp r5,r7                                   @ read characters ?
    blt 2b                                      @ no loop
                                                @ final
    cmp r3,#0                                   @ no characters in line buffer ?
    beq 100f
4:
    mov r0,#0
    strb r0,[r8,r3]                             @ store zéro final
    add r5,#1
    str r5,[r4,#readfile_pointer]               @ store pointer in structure
    str r7,[r4,#readfile_buffersize]            @ store number of last characters
    mov r0,r3                                   @ return length of line
100:
    pop {r1-r8,lr}                              @ restaur registers
    bx lr                                       @ return

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
/*   display error message                        */
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