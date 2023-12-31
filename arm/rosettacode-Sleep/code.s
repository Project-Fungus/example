/* ARM assembly Raspberry PI  */
/*  program sleepAsm.s   */

/* Constantes    */
.equ STDIN,  0                           @ Linux input console
.equ STDOUT, 1                           @ Linux output console
.equ EXIT,   1                           @ Linux syscall
.equ READ,   3                           @ Linux syscall
.equ WRITE,  4                           @ Linux syscall
.equ SLEEP,  0xa2                        @ Linux syscall


.equ BUFFERSIZE,         100
/* Initialized data */
.data
szMessQuest:             .asciz "Enter the time to sleep in seconds : "
szMessError:             .asciz "Error occured.\n" 
szMessSleep:             .asciz "Sleeping Zzzzzzz.\n" 
szMessAwake:             .asciz "Awake!!!\n"

szCarriageReturn:        .asciz "\n"

/* UnInitialized data */
.bss 
.align 4
ZonesAttente:
  iSecondes:      .skip 4
  iMicroSecondes: .skip 4
ZonesTemps:       .skip 8
sBuffer:          .skip BUFFERSIZE

/*  code section */
.text
.global main 
main: 
    ldr r0,iAdrszMessQuest            @ display invite message
    bl affichageMess
    mov r0,#STDIN                     @ input standard linux
    ldr r1,iAdrsBuffer
    mov r2,#BUFFERSIZE
    mov r7,#READ                      @ read input string
    svc 0 
    cmp r0,#0                         @ read error ?
    ble 99f
    @ 
    ldr r0,iAdrsBuffer                @ buffer address
    bl conversionAtoD                 @ conversion string in number in r0

    ldr r1,iAdriSecondes 
    str r0,[r1]                       @ store second number in area
    ldr r0,iAdrszMessSleep            @ display sleeping message
    bl affichageMess
    ldr r0,iAdrZonesAttente           @ delay area
    ldr r1,iAdrZonesTemps             @
    mov r7,#SLEEP                     @ call system SLEEP
    svc 0 
    cmp r0,#0                         @ error sleep ?
    blt 99f
    ldr r0,iAdrszMessAwake            @ display awake message
    bl affichageMess
    mov r0, #0                        @ return code
    b 100f
99:                                   @ display error message
    ldr r0,iAdrszMessError
    bl affichageMess
    mov r0, #1                        @ return code

100:                                  @ standard end of the program
    mov r7, #EXIT                     @ request to exit program
    svc 0                             @ perform system call
iAdrszMessQuest:          .int szMessQuest
iAdrszMessError:          .int szMessError
iAdrszMessSleep:          .int szMessSleep
iAdrszMessAwake:          .int szMessAwake
iAdriSecondes:            .int iSecondes
iAdrZonesAttente:         .int ZonesAttente
iAdrZonesTemps:           .int ZonesTemps
iAdrsBuffer:              .int sBuffer
iAdrszCarriageReturn:     .int szCarriageReturn


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
 /******************************************************************/
/*     Convert a string to a number stored in a registry          */ 
/******************************************************************/
/* r0 contains the address of the area terminated by 0 or 0A */
/* r0 returns a number                           */
conversionAtoD:
    push {fp,lr}         @ save 2 registers 
    push {r1-r7}         @ save others registers 
    mov r1,#0
    mov r2,#10           @ factor 
    mov r3,#0            @ counter 
    mov r4,r0            @ save address string -> r4 
    mov r6,#0            @ positive sign by default 
    mov r0,#0            @ initialization to 0 
1:     /* early space elimination loop */
    ldrb r5,[r4,r3]      @ loading in r5 of the byte located at the beginning + the position 
    cmp r5,#0            @ end of string -> end routine
    beq 100f
    cmp r5,#0x0A         @ end of string -> end routine
    beq 100f
    cmp r5,#' '          @ space ? 
    addeq r3,r3,#1       @ yes we loop by moving one byte 
    beq 1b
    cmp r5,#'-'          @ first character is -    
    moveq r6,#1          @  1 -> r6
    beq 3f               @ then move on to the next position 
2:   /* beginning of digit processing loop */
    cmp r5,#'0'          @ character is not a number 
    blt 3f
    cmp r5,#'9'          @ character is not a number
    bgt 3f
    /* character is a number */
    sub r5,#48
    ldr r1,iMaxi         @ check the overflow of the register    
    cmp r0,r1
    bgt 99f              @ overflow error
    mul r0,r2,r0         @ multiply par factor 10 
    add r0,r5            @ add to  r0 
3:
    add r3,r3,#1         @ advance to the next position 
    ldrb r5,[r4,r3]      @ load byte 
    cmp r5,#0            @ end of string -> end routine
    beq 4f
    cmp r5,#0x0A            @ end of string -> end routine
    beq 4f
    b 2b                 @ loop 
4:
    cmp r6,#1            @ test r6 for sign 
    moveq r1,#-1
    muleq r0,r1,r0       @ if negatif, multiply par -1 
    b 100f
99:  /* overflow error */
    ldr r0,=szMessErrDep
    bl   affichageMess
    mov r0,#0            @ return  zero  if error
100:
    pop {r1-r7}          @ restaur other registers 
    pop {fp,lr}          @ restaur   2 registers 
    bx lr                @return procedure 
/* constante program */	
iMaxi: .int 1073741824	
szMessErrDep:  .asciz  "Too large: overflow 32 bits.\n"
.align 4