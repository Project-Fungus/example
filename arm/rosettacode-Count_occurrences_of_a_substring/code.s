/* ARM assembly Raspberry PI  */
/*  program strcptsub.s   */

/************************************/
/* Constantes                       */
/************************************/
/* for this file see task include a file in language ARM assembly*/
.include "../constantes.inc"

/************************************/
/* Initialized data                 */
/************************************/
.data
szMessResult:         .asciz "Result: "
szString:             .asciz "the three truths" 
szSubString:          .asciz "th"
szString1:             .asciz "ababababab" 
szSubString1:          .asciz "abab"
szCarriageReturn:     .asciz "\n"
szMessStart:          .asciz "Program 32 bits start.\n"
/************************************/
/* UnInitialized data               */
/************************************/
.bss 
sZoneConv:            .skip 24
/************************************/
/*  code section                    */
/************************************/
.text
.global main   
main:                      @ entry of program
    ldr r0,iAdrszMessStart
    bl affichageMess
    ldr r0,iAdrszString
    ldr r1,iAdrszSubString
    bl countSubString
    ldr r0,iAdrszString1
    ldr r1,iAdrszSubString1
    bl countSubString

100:                       @ standard end of the program
    mov r0, #0             @ return code
    mov r7, #EXIT          @ request to exit program
    svc 0                  @ perform the system call
iAdrszString:             .int szString
iAdrszSubString:          .int szSubString
iAdrszString1:            .int szString1
iAdrszSubString1:         .int szSubString1
iAdrsZoneConv:            .int sZoneConv
iAdrszMessResult:         .int szMessResult
iAdrszCarriageReturn:     .int szCarriageReturn
iAdrszMessStart:          .int szMessStart
/***************************************************/
/*   count sub string of string                    */
/***************************************************/
/* r0 contains a string */
/* r1 contains a substring */
/* r0 return substring count */
countSubString:
    push {r1-r7,lr}      @ save registers
    mov r4,#0            @ counter
    mov r3,#0            @ index string
    Mov r5,#0            @ index substring
1:
    ldrb r6,[r0,r5]      @ load byte of string
    ldrb r7,[r1,r3]      @ load byte of substring
    cmp r6,r7            @ compare byte
    bne 2f               @ not equal
    cmp r6,#0            @ string end ?
    beq 3f               @ yes 
    add r5,r5,#1         @ else increment index
    add r3,r3,#1
    b 1b                 @ and loop
2:                       @ characters not equal
    cmp r6,#0            @ end string ?
    beq 4f
    cmp r7,#0            @ end substring ?
    addeq r4,r4,#1       @ yes -> increment counter 
    mov r3,#0            @ raz index substring
    add r5,r5,#1         @ increment string index
    b 1b                 @ and loop
3:                       @ end string and end substring
    add r4,r4,#1         @ increment counter
4:                       @ result display
    mov r0,r4
    ldr r1,iAdrsZoneConv
    bl conversion10
    ldr r0,iAdrszMessResult
    bl affichageMess
    ldr r0,iAdrsZoneConv
    bl affichageMess
    ldr r0,iAdrszCarriageReturn
    bl affichageMess
    
    mov r0,r4
 100:
    pop {r1-r7,pc}  
/***************************************************/
/*      ROUTINES INCLUDE                           */
/***************************************************/
/* for this file see task include a file in language ARM assembly*/
.include "../affichage.inc"

Program 32 bits start.
Result: 3
Result: 2