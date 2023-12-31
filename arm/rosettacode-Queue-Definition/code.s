/* ARM assembly Raspberry PI  */
/*  program defqueue.s   */

/* Constantes    */
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ WRITE,  4     @ Linux syscall

.equ  NBMAXIELEMENTS,    100

/*******************************************/
/* Structures                               */
/********************************************/
/* example structure  for value of item  */
    .struct  0
value_ident:                     @ ident
    .struct  value_ident + 4 
value_value1:                    @ value 1 
    .struct  value_value1 + 4 
value_value2:                    @ value 2
    .struct  value_value2 + 4 
value_fin:
/* example structure  for queue  */
    .struct  0
queue_ptdeb:                     @ begin pointer of item
    .struct  queue_ptdeb + 4 
queue_ptfin:                     @ end pointer of item
    .struct  queue_ptfin + 4 
queue_stvalue:                   @ structure of value item
    .struct  queue_stvalue + (value_fin * NBMAXIELEMENTS)
queue_fin:


/*********************************/
/* Initialized data              */
/*********************************/
.data
szMessEmpty:       .asciz "Empty queue. \n"
szMessNotEmpty:    .asciz "Not empty queue. \n"
szMessError:       .asciz "Error detected !!!!. \n"
szMessResult:      .ascii "Ident :"                    @ message result
sMessIdent:        .fill 11, 1, ' '
                    .ascii " value 1 :"
sMessValue1:       .fill 11, 1, ' '
                    .ascii " value 2 :"
sMessValue2:       .fill 11, 1, ' '
                    .asciz "\n"

szCarriageReturn:  .asciz "\n"
/*********************************/
/* UnInitialized data            */
/*********************************/
.bss 
.align 4
Queue1:                .skip queue_fin      @ queue memory place 
stItem:                .skip value_fin      @ value item memory place
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                                       @ entry of program 
    ldr r0,iAdrQueue1                       @ queue structure address
    bl isEmpty
    cmp r0,#0
    beq 1f
    ldr r0,iAdrszMessEmpty
    bl affichageMess                        @ display message empty
    b 2f
1:
    ldr r0,iAdrszMessNotEmpty
    bl affichageMess                        @ display message not empty
2:
    @ init item 1
    ldr r0,iAdrstItem
    mov r1,#1
    str r1,[r0,#value_ident]
    mov r1,#11
    str r1,[r0,#value_value1]
    mov r1,#12
    str r1,[r0,#value_value2]

    ldr r0,iAdrQueue1                       @ queue structure address
    ldr r1,iAdrstItem
    bl pushQueue                            @ add item in queue
    cmp r0,#-1                              @ error ?
    beq 99f
    @ init item 2
    ldr r0,iAdrstItem
    mov r1,#2
    str r1,[r0,#value_ident]
    mov r1,#21
    str r1,[r0,#value_value1]
    mov r1,#22
    str r1,[r0,#value_value2]

    ldr r0,iAdrQueue1                       @ queue structure address
    ldr r1,iAdrstItem
    bl pushQueue                            @ add item in queue
    cmp r0,#-1
    beq 99f
    ldr r0,iAdrQueue1                       @ queue structure address
    bl isEmpty
    cmp r0,#0                               @ not empty
    beq 3f
    ldr r0,iAdrszMessEmpty
    bl affichageMess                        @ display message empty
    b 4f
3:
    ldr r0,iAdrszMessNotEmpty
    bl affichageMess                        @ display message not empty

4:
    ldr r0,iAdrQueue1                       @ queue structure address
    bl popQueue                             @ return address item
    cmp r0,#-1                              @ error ?
    beq 99f
    mov r2,r0                               @ save item pointer 
    ldr r0,[r2,#value_ident]
    ldr r1,iAdrsMessIdent                   @ display ident
    bl conversion10                         @ decimal conversion
    ldr r0,[r2,#value_value1]
    ldr r1,iAdrsMessValue1                  @ display value 1
    bl conversion10                         @ decimal conversion
    ldr r0,[r2,#value_value2]
    ldr r1,iAdrsMessValue2                  @ display value 2
    bl conversion10                         @ decimal conversion
    ldr r0,iAdrszMessResult
    bl affichageMess                        @ display message
    b 4b                                    @ loop

99:
    @ error
    ldr r0,iAdrszMessError
    bl affichageMess       
100:                                        @ standard end of the program 
    mov r0, #0                              @ return code
    mov r7, #EXIT                           @ request to exit program
    svc #0                                  @ perform the system call

iAdrQueue1:               .int Queue1
iAdrstItem:               .int stItem
iAdrszMessError:          .int szMessError
iAdrszMessEmpty:          .int szMessEmpty
iAdrszMessNotEmpty:       .int szMessNotEmpty
iAdrszMessResult:         .int szMessResult
iAdrszCarriageReturn:     .int szCarriageReturn
iAdrsMessIdent:           .int sMessIdent
iAdrsMessValue1:          .int sMessValue1
iAdrsMessValue2:          .int sMessValue2
/******************************************************************/
/*     test if queue empty                                        */ 
/******************************************************************/
/* r0 contains the address of queue structure */
isEmpty:
    push {r1,r2,lr}                         @ save  registres
    ldr r1,[r0,#queue_ptdeb]                @ begin pointer 
    ldr r2,[r0,#queue_ptfin]                @ begin pointer 
    cmp r1,r2
    moveq r0,#1                             @ empty queue
    movne r0,#0                             @ not empty
    pop {r1,r2,lr}                          @ restaur registers 
    bx lr                                   @ return  
/******************************************************************/
/*     add item  in queue                                         */ 
/******************************************************************/
/* r0 contains the address of queue structure */
/* r1 contains the address of item            */
pushQueue:
    push {r1-r4,lr}                         @ save  registres
    add r2,r0,#queue_stvalue                @ address of values structure
    ldr r3,[r0,#queue_ptfin]                @ end pointer
    add r2,r3                               @ free address of queue
    ldr r4,[r1,#value_ident]                @ load ident item
    str r4,[r2,#value_ident]                @ and store in queue
    ldr r4,[r1,#value_value1]               @ idem
    str r4,[r2,#value_value1]
    ldr r4,[r1,#value_value2]
    str r4,[r2,#value_value2]
    add r3,#value_fin
    cmp r3,#value_fin * NBMAXIELEMENTS
    moveq r0,#-1                            @ error
    beq 100f
    str r3,[r0,#queue_ptfin]                @ store new end pointer
100:
    pop {r1-r4,lr}                          @ restaur registers 
    bx lr                                   @ return 
/******************************************************************/
/*     pop queue                                                  */ 
/******************************************************************/
/* r0 contains the address of queue structure */
popQueue:
    push {r1,r2,lr}                         @ save  registres
    mov r1,r0                               @ control if empty queue
    bl isEmpty
    cmp r0,#1                               @ yes -> error
    moveq r0,#-1
    beq 100f
    mov r0,r1
    ldr r1,[r0,#queue_ptdeb]                @ begin pointer 
    add r2,r0,#queue_stvalue                @ address of begin values item
    add r2,r1                               @ address of item
    add r1,#value_fin
    str r1,[r0,#queue_ptdeb]                @ store nex begin pointer
    mov r0,r2                               @ return pointer item
100:
    pop {r1,r2,lr}                          @ restaur registers 
    bx lr                                   @ return  
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