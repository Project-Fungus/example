/* ARM assembly Raspberry PI  */
/*  program yingyang.s   */

/* REMARK 1 : this program use routines in a include file 
   see task Include a file language arm assembly 
   for the routine affichageMess conversion10 
   see at end of this program the instruction include */
/***************************************************************/
/* File Constantes  see task Include a file for arm assembly   */
/***************************************************************/
.include "../constantes.inc"

.equ SIZEMAXI,    78

/******************************************/
/* Initialized data                       */
/******************************************/
.data
szMessDebutPgm:          .asciz "Start program.\n"
szMessFinPgm:            .asciz "Program End ok.\n"
szRetourLigne:            .asciz "\n"

szMessErrComm:           .asciz "Incomplete Command line  : yingyang <size> \n"
/******************************************/
/* UnInitialized data                     */
/******************************************/
.bss 
szLine:                .skip SIZEMAXI
/******************************************/
/*  code section                          */
/******************************************/
.text
.global main 
main:                           @ entry of program 
    mov fp,sp                           // copy stack address  register r29 fp
    ldr r0,iAdrszMessDebutPgm
    bl affichageMess
    ldr r0,[fp]                        // parameter number command line
    cmp r0,#1                          // correct ?
    ble erreurCommande                 // error

    add r0,fp,#8                       // address parameter 2
    ldr r0,[r0]
    bl conversionAtoD
    cmp r0,#SIZEMAXI  / 2
    movgt r0,#(SIZEMAXI / 2) - 1       // limit size
    mov r10,r0                         // size
    lsr r11,r10,#1                     // R = size / 2  radius great circle
    mul r9,r11,r11                     // R^2
    lsr r12,r11,#1                     // radius median circle
    lsr r8,r12,#1                      // radius little circle

    mov r2,#0                          // y
    ldr r0,iAdrszLine
1:
    mov r1,#0                          // x
    mov r5,#' '
    mov r3,#SIZEMAXI
11:                             // move spaces in display line
    strb r5,[r0,r1]
    add r1,#1
    cmp r1,r3
    blt 11b
    mov r1,#0                   // x
2:                              // begin loop
    sub r3,r1,r11               // x1 = x - R
    mul r4,r3,r3                // x1^2
    sub r5,r2,r11               // y1 = y - R
    mul r6,r5,r5                // y1^2
    add r6,r4                   // add x1^2 y1^2
    cmp r6,r9                   // compare R^2
    ble 3f
    mov r5,#' '                 // not in great circle
    strb r5,[r0,r1,lsl #1]
    b 20f                
3:                              // compute quadrant
    cmp r1,r11
    bgt 10f                     // x > R
    cmp r2,r11
    bgt 5f                      // y > R
    // quadrant 1  x < R and y < R
    sub r5,r2,r12
    mul r7,r5,r5                // y1^2
    add r7,r4                   // y1^2 + x1^2 
    mul r6,r8,r8                // little r ^2
    cmp r7,r8
    bgt 4f
    mov r5,#' '                 // in little circle
    strb r5,[r0,r1,lsl #1]
    b 20f
4:                              // in other part of great circle
    mov r5,#'.'
    strb r5,[r0,r1,lsl #1]
    b 20f
5:  // quadrant 3  x < R and y > R
    mov r5,#3
    mul r5,r10,r5
    lsr r5,#2        
    sub r6,r2,r5                // y1 - pos little circle (= (size / 3) * 4
    mul r7,r6,r6                // y1^2
    add r7,r4                   // y1^2 + x1^2
    mul r6,r8,r8                // r little
    cmp r7,r8
    bgt 6f
    mov r5,#' '                 // in little circle
    strb r5,[r0,r1,lsl #1]
    b 20f
6:
    mul r6,r12,r12
    cmp r7,r6 
    bge 7f
    mov r5,#'#'                 // in median circle
    strb r5,[r0,r1,lsl #1]
    b 20f
7:
    mov r5,#'.'                 // not in median
    strb r5,[r0,r1,lsl #1]
    b 20f
10:
    cmp r2,r11
    bgt 15f
    // quadrant 2
    sub r5,r2,r12                // y - center little
    mul r6,r5,r5
    add r7,r4,r6
    mul r6,r8,r8
    cmp r7,r6
    bge 11f
    mov r5,#' '                 // in little circle
    strb r5,[r0,r1,lsl #1]
    b 20f
11:
    mul r6,r12,r12
    cmp r7,r6 
    bge 12f
    mov r5,#'.'                 // in median circle
    strb r5,[r0,r1,lsl #1]
    b 20f
12:
    mov r5,#'#'                 // in great circle
    strb r5,[r0,r1,lsl #1]
    b 20f
15:
    // quadrant 4
    mov r5,#3
    mul r5,r10,r5
    lsr r5,#2
    sub r6,r2,r5                // y1 - pos little
    mul r7,r6,r6                // y1^2
    add r7,r4                   // y1^2 + x1^2 
    mul r6,r8,r8                // little r ^2
    cmp r7,r8
    bgt 16f
    mov r5,#' '                 // in little circle
    strb r5,[r0,r1,lsl #1]
    b 20f
16:
    mov r5,#'#'
    strb r5,[r0,r1,lsl #1]
    b 20f
20:
    add r1,#1                    // increment x
    cmp r1,r10                   // size ?
    ble 2b                       // no -> loop
    lsl r1,#1
    mov r5,#'\n'                 // add return line
    strb r5,[r0,r1]
    add r1,#1
    mov r5,#0                    // add final zéro
    strb r5,[r0,r1]
    bl affichageMess             // and display line
    add r2,r2,#1                 // increment y
    cmp r2,r10                   // size ?
    ble 1b                       // no -> loop

    ldr r0,iAdrszMessFinPgm
    bl affichageMess
    b 100f
erreurCommande:
    ldr r0,iAdrszMessErrComm
    bl affichageMess
    mov r0,#1                    // error code
    b 100f
100:                             // standard end of the program 
    mov r0, #0                   // return code
    mov r7, #EXIT                // request to exit program
    svc 0                        // perform the system call
iAdrszMessDebutPgm:         .int szMessDebutPgm
iAdrszMessFinPgm:           .int szMessFinPgm
iAdrszMessErrComm:          .int szMessErrComm
iAdrszLine:                 .int szLine
/***************************************************/
/*      ROUTINES INCLUDE                 */
/***************************************************/
.include "../affichage.inc"

Start program.
                    .
            . . . . . . . # #
        . . . . . . . . . . # # #
      . . . . . . . . . . . . # # #
    . . . . . . .       . . . # # # #
    . . . . . . .       . . . # # # #
  . . . . . . . .       . . . # # # # #
  . . . . . . . . . . . . . . # # # # #
  . . . . . . . . . . . . . # # # # # #
  . . . . . . . . . . . . # # # # # # #
. . . . . . . . . . . # # # # # # # # # #
  . . . . . . . # # # # # # # # # # # #
  . . . . . . # # # # # # # # # # # # #
  . . . . . # # # # # # # # # # # # # #
  . . . . . # # #       # # # # # # # #
    . . . . # # #       # # # # # # #
    . . . . # # #       # # # # # # #
      . . . # # # # # # # # # # # #
        . . . # # # # # # # # # #
            . . # # # # # # #
                    .
Program End ok.