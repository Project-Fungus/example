Correction program 15/11/2020 

/* ARM assembly Raspberry PI  */
/*  program abbrEasy.s   */
/* store list of command in a file */
/* and run the program  abbrEasy command.file */

/* REMARK 1 : this program use routines in a include file 
   see task Include a file language arm assembly 
   for the routine affichageMess conversion10 
   see at end of this program the instruction include */
/* for constantes see task include a file in arm assembly */
/************************************/
/* Constantes                       */
/************************************/
.include "../constantes.inc"

.equ STDIN,  0     @ Linux input console
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ READ,   3     @ Linux syscall
.equ WRITE,  4     @ Linux syscall
.equ OPEN,   5     @ Linux syscall
.equ CLOSE,  6     @ Linux syscall

.equ O_RDWR,    0x0002        @ open for reading and writing

.equ SIZE,           4
.equ NBBOX,          SIZE * SIZE
.equ BUFFERSIZE,   1000
.equ NBMAXIELEMENTS, 100

/*********************************/
/* Initialized data              */
/*********************************/
.data
szMessTitre:            .asciz "Nom du fichier : "
szCarriageReturn:      .asciz "\n"
szMessErreur:          .asciz "Error detected.\n"
szMessErrBuffer:       .asciz "buffer size too less !!"
szMessErrorAbr:        .asciz "*error*"
szMessInput:           .asciz "Enter command (or quit to stop) : "
szCmdQuit:              .asciz "QUIT"
szValTest1:            .asciz "Quit"
szValTest2:            .asciz "Rep"
/*********************************/
/* UnInitialized data            */
/*********************************/
.bss
.align 4
sZoneConv:      .skip 24
iAdrFicName:    .skip 4
iTabAdrCmd:     .skip 4 * NBMAXIELEMENTS 
sBufferCmd:     .skip BUFFERSIZE
sBuffer:        .skip BUFFERSIZE
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                            @ INFO: main
    mov r0,sp                    @ stack address for load parameter
    bl traitFic                  @ read file and store value in array
    cmp r0,#-1
    beq 100f                     @ error ?
    ldr r0,iAdriTabAdrCmd
    bl controlLoad
1:
    ldr r0,iAdrszMessInput       @ display input message
    bl affichageMess
    mov r0,#STDIN                @ Linux input console
    ldr r1,iAdrsBuffer           @ buffer address 
    mov r2,#BUFFERSIZE           @ buffer size 
    mov r7, #READ                @ request to read datas
    svc 0                        @ call system
    sub r0,r0,#1
    mov r2,#0
    strb r2,[r1,r0]              @ replace character 0xA by zéro final
    ldr r0,iAdrsBuffer   
    ldr r1,iAdriTabAdrCmd
    bl controlCommand            @ control text command
    mov r2,r0
    bl affichageMess
    ldr r0,iAdrszCarriageReturn
    bl affichageMess
    mov r0,r2
    ldr r1,iAdrszCmdQuit         @ command quit ?
    bl comparStrings
    cmp r0,#0
    beq 100f                     @ yes -> end
    b 1b                         @ else loop

99:
    ldr r0,iAdrszMessErrBuffer
    bl affichageMess
100:                                 @ standard end of the program 
    mov r0, #0                       @ return code
    mov r7, #EXIT                    @ request to exit program
    svc #0                           @ perform the system call
 
iAdrszCarriageReturn:      .int szCarriageReturn
iAdrszMessErrBuffer:       .int szMessErrBuffer
iAdrsZoneConv:             .int sZoneConv
iAdrszMessInput:           .int szMessInput
iAdrszCmdQuit:             .int szCmdQuit
/******************************************************************/
/*      control abbrevation command                               */ 
/******************************************************************/
/* r0 contains string input command */
/* r1 contains address table string command */
controlCommand:                   @ INFO: controlCommand
    push {r1-r8,lr}               @ save  registers
    mov r8,r0
    mov r9,r1
    bl computeLength              @ length input command
    mov r4,r0                     @ save length input
    mov r2,#0                     @ indice
    mov r3,#0                     @ find counter
1:
    mov r0,r8
    ldr r1,[r9,r2,lsl #2]         @ load a item
    cmp r1,#0                     @ end ?
    beq 5f
    bl comparStringSpe            @ 
    cmp r0,#0                     @ no found other search
    beq 4f
    mov r6,#0
    mov r5,#0
2:                                @ loop count capital letters 
    ldrb r0,[r1,r6]
    cmp r0,#0
    beq 3f
    tst r0,#0x20                  @ capital letter ?
    addeq r5,r5,#1
    add r6,r6,#1
    b 2b
3:
    cmp r4,r5                     @ input < command capital letters
    blt 4f                        @ no correct
    
    add r3,r3,#1                  @ else increment counter
    mov r7,r1                     @ and save address command
4:
    add r2,r2,#1                  @ increment indice
    b 1b                          @ and loop
5:
    cmp r3,#1                     @ no find or multiple find ?
    bne 99f                       @ error 
                                  @ one find
    mov r0,r7                     @ length command table
    bl computeLength
    cmp r4,r0                     @ length input > command ?
    bgt 99f                       @ error

    mov r4,#0x20                  @ 5 bit to 1
    mov r2,#0
6:
    ldrb r3,[r7,r2]
    cmp r3,#0
    beq 7f
    bic r3,r3,r4                  @ convert to capital letter
    strb r3,[r8,r2]
    add r2,r2,#1
    b 6b
7:
    strb r3,[r8,r2]
    mov r0,r8                     @ return string input address
    b 100f
99:
    ldr r0,iAdrszMessErrorAbr     @ return string "error"
100:
    pop {r1-r8,lr}                @ restaur registers 
    bx lr                         @return
iAdrszMessErreur:           .int szMessErreur
iAdrszMessErrorAbr:         .int szMessErrorAbr
/******************************************************************/
/*     comparaison first letters String                                          */ 
/******************************************************************/
/* r0 contains first String   */
/* r1 contains second string */
/* r0 return 0 if not find else returns number letters OK */
comparStringSpe:
    push {r1-r6,lr}           @ save  register
    mov r2,#0
1:
    ldrb r3,[r0,r2]           @ input
    orr r4,r3,#0x20           @ convert capital letter
    ldrb r5,[r1,r2]           @ table
    orr r6,r5,#0x20           @ convert capital letter
    cmp r4,r6
    bne 2f
    cmp r3,#0
    beq 3f
    add r2,r2,#1
    b 1b 
2:
   cmp r3,#0                  @ fist letters Ok
   beq 3f
   mov r0,#0                  @ no ok
   b 100f
3:
   mov r0,r2
100:
    pop {r1-r6,lr}                     @ restaur registers 
    bx lr                        @return
/******************************************************************/
/*     compute length  String                                          */ 
/******************************************************************/
/* r0 contains  String   */
/* r0 return length */ 
computeLength:                   @ INFO: functionFN
    push {r1-r2,lr}              @ save  register
    mov r1,#0
1:
    ldrb r2,[r0,r1]
    cmp r2,#0                    @ end ?
    moveq r0,r1                  @ return length in r0
    beq 100f
    add r1,r1,#1
    b 1b
100:
    pop {r1-r2,lr}               @ restaur registers 
    bx lr                        @return 

/******************************************************************/
/*     read file                                                   */ 
/******************************************************************/
/* r0 contains address stack begin           */
traitFic:                             @ INFO: traitFic
    push {r1-r8,fp,lr}                @ save  registers
    mov fp,r0                         @  fp <- start address
    ldr r4,[fp]                       @ number of Command line arguments
    cmp r4,#1
    movle r0,#-1
    ble 99f
    add r5,fp,#8                      @ second parameter address 
    ldr r5,[r5]
    ldr r0,iAdriAdrFicName
    str r5,[r0]
    ldr r0,iAdrszMessTitre
    bl affichageMess                  @ display string
    mov r0,r5
    bl affichageMess 
    ldr r0,iAdrszCarriageReturn
    bl affichageMess                  @ display carriage return

    mov r0,r5                         @ file name
    mov r1,#O_RDWR                    @ flags    
    mov r2,#0                         @ mode 
    mov r7, #OPEN                     @ call system OPEN 
    svc 0 
    cmp r0,#0                         @ error ?
    ble 99f
    mov r8,r0                         @ File Descriptor
    ldr r1,iAdrsBufferCmd             @ buffer address
    mov r2,#BUFFERSIZE                @ buffer size
    mov r7,#READ                      @ read file
    svc #0
    cmp r0,#0                         @ error ?
    blt 99f
    @ extraction datas
    ldr r1,iAdrsBufferCmd             @ buffer address
    add r1,r0
    mov r0,#0                         @ store zéro final
    strb r0,[r1] 
    ldr r0,iAdriTabAdrCmd             @ key string command table
    ldr r1,iAdrsBufferCmd             @ buffer address
    bl extracDatas
                                      @ close file
    mov r0,r8
    mov r7, #CLOSE 
    svc 0 
    mov r0,#0
    b 100f
99:                                   @ error
    ldr r1,iAdrszMessErreur           @ error message
    bl   displayError
    mov r0,#-1
100:
    pop {r1-r8,fp,lr}                 @ restaur registers 
    bx lr                             @return
iAdriAdrFicName:              .int iAdrFicName
iAdrszMessTitre:              .int szMessTitre
iAdrsBuffer:                  .int sBuffer
iAdrsBufferCmd:               .int sBufferCmd
iAdriTabAdrCmd:               .int iTabAdrCmd
/******************************************************************/
/*     extrac digit file buffer                                   */ 
/******************************************************************/
/* r0 contains strings address           */
/* r1 contains buffer address         */
extracDatas:                     @ INFO: extracDatas
    push {r1-r8,lr}              @ save  registers
    mov r7,r0
    mov r6,r1
    mov r2,#0                    @ string buffer indice
    mov r4,r1                    @ start string
    mov r5,#0                    @ string index
    //vidregtit debextrac
1:
    ldrb r3,[r6,r2]
    cmp r3,#0
    beq 4f                       @ end
    cmp r3,#0xA
    beq 2f
    cmp r3,#' '                  @ end string
    beq 3f
    add r2,#1
    b 1b
2:
    mov r3,#0
    strb r3,[r6,r2]
    ldrb r3,[r6,r2]
    cmp r3,#0xD
    addeq r2,#2
    addne r2,#1
    b 4f
 
3:
    mov r3,#0
    strb r3,[r6,r2]
    add r2,#1
4:  
    mov r0,r4
    str r4,[r7,r5,lsl #2]
    add r5,#1
5:
    ldrb r3,[r6,r2]
    cmp r3,#0
    beq 100f
    cmp r3,#' '
    addeq r2,r2,#1
    beq 5b
    
    add r4,r6,r2                 @ new start address
    b 1b
100:
    pop {r1-r8,lr}               @ restaur registers 
    bx lr                        @return
/******************************************************************/
/*     control load                                      */ 
/******************************************************************/
/* r0 contains string table           */
controlLoad:
    push {r1-r8,lr}              @ save  registers
    mov r5,r0
    mov r1,#0
1:
    ldr r0,[r5,r1,lsl #2]
    cmp r0,#0
    beq 100f
    bl affichageMess
    ldr r0,iAdrszCarriageReturn
    bl affichageMess
    add r1,r1,#1
    b 1b
    
100:
    pop {r1-r8,lr}               @ restaur registers 
    bx lr                        @return
/************************************/       
/* Strings case sensitive comparisons  */
/************************************/      
/* r0 et r1 contains the address of strings */
/* return 0 in r0 if equals */
/* return -1 if string r0 < string r1 */
/* return 1  if string r0 > string r1 */
comparStrings:
    push {r1-r4}             @ save des registres
    mov r2,#0                @ counter
1:    
    ldrb r3,[r0,r2]          @ byte string 1
    ldrb r4,[r1,r2]          @ byte string 2
    cmp r3,r4
    movlt r0,#-1             @ small
    movgt r0,#1              @ greather
    bne 100f                 @ not equals
    cmp r3,#0                @ 0 end string
    moveq r0,#0              @ equal 
    beq 100f                 @ end string
    add r2,r2,#1             @ else add 1 in counter
    b 1b                     @ and loop
100:
    pop {r1-r4}
    bx lr   
/***************************************************/
/*      ROUTINES INCLUDE                           */
/***************************************************/
.include "../affichage.inc"

Enter command (or quit to stop) : riG
RIGHT
Enter command (or quit to stop) : rePEAT
REPEAT
Enter command (or quit to stop) : copies
*error*
Enter command (or quit to stop) : put
PUT
Enter command (or quit to stop) : mo
MOVE
Enter command (or quit to stop) : rest
RESTORE
Enter command (or quit to stop) : types
*error*
Enter command (or quit to stop) : fup.
*error*
Enter command (or quit to stop) : 6
*error*
Enter command (or quit to stop) : poweRin
POWERINPUT
Enter command (or quit to stop) : quit
QUIT