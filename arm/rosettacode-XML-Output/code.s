/* ARM assembly Raspberry PI  */
/*  program outputXml.s   */

/* Constantes    */
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ WRITE,  4     @ Linux syscall


/*********************************/
/* Initialized data              */
/*********************************/
.data
szMessEndpgm:      .asciz "Normal end of program.\n" 
szFileName:        .asciz "file2.xml" 
szFileMode:        .asciz "w"
szMessError:       .asciz "Error detected !!!!. \n"
szName1:           .asciz "April"
szName2:           .asciz "Tam O'Shanter"
szName3:           .asciz "Emily"
szRemark1:         .asciz "Bubbly: I'm > Tam and <= Emily"
szRemark2:         .asciz "Burns: \"When chapman billies leave the street ...\""
szRemark3:         .asciz "Short & shrift"
szVersDoc:         .asciz "1.0"
szLibCharRem:      .asciz "CharacterRemarks"
szLibChar:         .asciz "Character"

//szLibExtract:    .asciz "Student"
szLibName:         .asciz "Name"
szCarriageReturn:  .asciz "\n"

tbNames:           .int szName1              @ area of pointer string name
                   .int szName2
                   .int szName3
                   .int 0                    @ area end
tbRemarks:         .int szRemark1            @ area of pointer string remark
                   .int szRemark2
                   .int szRemark3
                   .int 0                    @ area end
/*********************************/
/* UnInitialized data            */
/*********************************/
.bss 
.align 4

/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                                     @ entry of program 
    ldr r0,iAdrszVersDoc
    bl xmlNewDoc                          @ create doc
    mov r9,r0                             @ doc address
    mov r0,#0
    ldr r1,iAdrszLibCharRem
    bl xmlNewNode                         @ create root node
    mov r8,r0                             @ node characterisation address
    mov r0,r9                             @ doc
    mov r1,r8                             @ node root
    bl xmlDocSetRootElement
    ldr r4,iAdrtbNames
    ldr r5,iAdrtbRemarks
    mov r6,#0                             @ loop counter
1:                                        @ start loop
    mov r0,#0
    ldr r1,iAdrszLibChar                  @ create node
    bl xmlNewNode
    mov r7,r0                             @ node character
                                          @ r0 = node address
    ldr r1,iAdrszLibName
    ldr r2,[r4,r6,lsl #2]                 @ load name string address
    bl xmlNewProp
    ldr r0,[r5,r6,lsl #2]                 @ load remark string address
    bl xmlNewText
    mov r1,r0
    mov r0,r7
    bl xmlAddChild
    mov r0,r8
    mov r1,r7
    bl xmlAddChild
    add r6,#1
    ldr r2,[r4,r6,lsl #2]                  @ load name string address
    cmp r2,#0                              @ = zero ?
    bne 1b                                 @ no -> loop

    ldr r0,iAdrszFileName 
    ldr r1,iAdrszFileMode
    bl fopen                               @ file open
    cmp r0,#0
    blt 99f
    mov r6,r0                              @FD
    mov r1,r9
    mov r2,r8
    bl xmlDocDump                          @ write doc on the file

    mov r0,r6
    bl fclose
    mov r0,r9
    bl xmlFreeDoc
    bl xmlCleanupParser
    ldr r0,iAdrszMessEndpgm
    bl affichageMess
    b 100f
99:
    @ error
    ldr r0,iAdrszMessError
    bl affichageMess       
100:                                       @ standard end of the program 
    mov r0, #0                             @ return code
    mov r7, #EXIT                          @ request to exit program
    svc #0                                 @ perform the system call

iAdrszMessError:          .int szMessError
iAdrszMessEndpgm:         .int szMessEndpgm
iAdrszVersDoc:            .int szVersDoc
iAdrszLibCharRem:         .int szLibCharRem
iAdrszLibChar:            .int szLibChar
iAdrszLibName:            .int szLibName
iAdrtbNames:              .int tbNames
iAdrtbRemarks:            .int tbRemarks
iAdrszCarriageReturn:     .int szCarriageReturn
iStdout:                  .int STDOUT
iAdrszFileName:           .int szFileName
iAdrszFileMode:           .int szFileMode
/******************************************************************/
/*     display text with size calculation                         */ 
/******************************************************************/
/* r0 contains the address of the message */
affichageMess:
    push {r0,r1,r2,r7,lr}                   @ save  registres
    mov r2,#0                               @ counter length 
1:                                          @ loop length calculation 
    ldrb r1,[r0,r2]                         @ read octet start position + index 
    cmp r1,#0                               @ if 0 its over 
    addne r2,r2,#1                          @ else add 1 in the length 
    bne 1b                                  @ and loop 
                                            @ so here r2 contains the length of the message 
    mov r1,r0                               @ address message in r1 
    mov r0,#STDOUT                          @ code to write to the standard output Linux 
    mov r7, #WRITE                          @ code call system "write" 
    svc #0                                  @ call systeme 
    pop {r0,r1,r2,r7,lr}                    @ restaur registers */ 
    bx lr                                   @ return  
/******************************************************************/
/*     Converting a register to a decimal                                 */ 
/******************************************************************/
/* r0 contains value and r1 address area   */
.equ LGZONECAL,   10
conversion10:
    push {r1-r4,lr}                         @ save registers 
    mov r3,r1
    mov r2,#LGZONECAL
1:                                          @ start loop
    bl divisionpar10                        @ r0 <- dividende. quotient ->r0 reste -> r1
    add r1,#48                              @ digit
    strb r1,[r3,r2]                         @ store digit on area
    cmp r0,#0                               @ stop if quotient = 0 
    subne r2,#1                               @ previous position    
    bne 1b                                  @ else loop
                                            @ end replaces digit in front of area
    mov r4,#0
2:
    ldrb r1,[r3,r2] 
    strb r1,[r3,r4]                         @ store in area begin
    add r4,#1
    add r2,#1                               @ previous position
    cmp r2,#LGZONECAL                       @ end
    ble 2b                                  @ loop
    mov r1,#' '
3:
    strb r1,[r3,r4]
    add r4,#1
    cmp r4,#LGZONECAL                       @ end
    ble 3b
100:
    pop {r1-r4,lr}                          @ restaur registres 
    bx lr                                   @return
/***************************************************/
/*   division par 10   signé                       */
/* Thanks to http://thinkingeek.com/arm-assembler-raspberry-pi/*  
/* and   http://www.hackersdelight.org/            */
/***************************************************/
/* r0 dividende   */
/* r0 quotient */
/* r1 remainder  */
divisionpar10:
  /* r0 contains the argument to be divided by 10 */
    push {r2-r4}                           @ save registers  */
    mov r4,r0  
    mov r3,#0x6667                         @ r3 <- magic_number  lower
    movt r3,#0x6666                        @ r3 <- magic_number  upper
    smull r1, r2, r3, r0                   @ r1 <- Lower32Bits(r1*r0). r2 <- Upper32Bits(r1*r0) 
    mov r2, r2, ASR #2                     @ r2 <- r2 >> 2
    mov r1, r0, LSR #31                    @ r1 <- r0 >> 31
    add r0, r2, r1                         @ r0 <- r2 + r1 
    add r2,r0,r0, lsl #2                   @ r2 <- r0 * 5 
    sub r1,r4,r2, lsl #1                   @ r1 <- r4 - (r2 * 2)  = r4 - (r0 * 10)
    pop {r2-r4}
    bx lr                                  @ return

more file2.xml =
<?xml version="1.0"?>
<CharacterRemarks><Character Name="April">Bubbly: I'm > Tam and <= Emily</
Character><Character Name="Tam O'Shanter">Burns: "When chapman billies leave the
 street ..."</Character><Character Name="Emily">Short & shrift</Character></
CharacterRemarks>