/* Programme assembleur ARM Raspberry */
/* Assembleur ARM Raspberry  : Vincent Leboulou */
/* Blog : http://assembleurarmpi.blogspot.fr/  */
/* modèle B 512MO   */
 
/************************************/
/* Constantes                       */
/************************************/
.equ STDIN,     0     @ Linux input console
.equ STDOUT,    1     @ Linux output console
.equ EXIT,      1     @ Linux syscall
.equ READ,      3     @ Linux syscall
.equ WRITE,     4     @ Linux syscall
.equ IOCTL,     0x36  @ Linux syscall
.equ SIGACTION, 0x43  @ Linux syscall
.equ SYSPOLL,   0xA8  @ Linux syscall

.equ TCGETS,    0x5401
.equ TCSETS,    0x5402
.equ ICANON,    2
.equ ECHO,     10
.equ POLLIN,    1

.equ SIGINT,   2    @ Issued if the user sends an interrupt signal (Ctrl + C)
.equ SIGQUIT,  3    @ Issued if the user sends a quit signal (Ctrl + D)
.equ SIGTERM, 15    @ Software termination signal (sent by kill by default)
.equ SIGTTOU, 22    @ 

.equ TAILLEBUFFER,   10


/*******************************************/
/* Structures                               */
/********************************************/
/* structure termios see doc linux*/
    .struct  0
term_c_iflag:                    @ input modes
    .struct  term_c_iflag + 4 
term_c_oflag:                    @ output modes
    .struct  term_c_oflag + 4 
term_c_cflag:                    @ control modes
    .struct  term_c_cflag + 4 
term_c_lflag:                    @ local modes
    .struct  term_c_lflag + 4 
term_c_cc:                       @ special characters
    .struct  term_c_cc + 20      @ see length if necessary 
term_fin:

/* structure sigaction see doc linux */
    .struct  0
sa_handler:
    .struct  sa_handler + 4 
sa_mask:
    .struct  sa_mask + 4 
sa_flags:
    .struct  sa_flags + 4 
sa_sigaction:
    .struct  sa_sigaction + 4 
sa_fin:

/* structure poll see doc linux */
    .struct  0
poll_fd:                            @   File Descriptor
    .struct  poll_fd + 4 
poll_events:                        @  events mask
    .struct  poll_events + 4 
poll_revents:                       @ events returned
    .struct  poll_revents + 4 
poll_fin:

/*********************************/
/* Initialized data              */
/*********************************/
.data
szMessPgmOk:        .asciz "End program OK.\n"
szMessErreur:       .asciz "Error detected.\n"
sMessResult:        .ascii "Value  : "
sMessValeur:        .fill 11, 1, ' '            @ size => 11
szCarriageReturn:   .asciz "\n"
/*************************************************/
szMessErr: .ascii	"Error code hexa : "
sHexa: .space 9,' '
         .ascii "  decimal :  "
sDeci: .space 15,' '
         .asciz "\n"
szMessKey:             .ascii  "Value key ==>"
sHexaKey: .space 9,' '
        .asciz "\n"
.align 4

/*********************************/
/* UnInitialized data            */
/*********************************/
.bss  
.align 4
iEnd:           .skip 4                        @ 0 loop  1 = end loop
iTouche:        .skip 4                        @ value key pressed
stOldtio:       .skip term_fin                 @ old terminal state
stCurtio:       .skip term_fin                 @ current terminal state
stSigAction:    .skip sa_fin                   @ area signal structure
stSigAction1:   .skip sa_fin
stPoll1:        .skip poll_fin                 @ area poll structure
stPoll2:        .skip poll_fin

/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                                            @ entry of program 
 
    /* read terminal state */
    mov r0,#STDIN                                @ input console
    mov r1,#TCGETS
    ldr r2,iAdrstOldtio
    mov r7, #IOCTL                               @ call system Linux
    svc #0 
    cmp r0,#0                                    @ error ?
    beq 1f
    ldr r1,iAdrszMessErreur                      @ error message
    bl   displayError
    b 100f
1:
    adr r0,sighandler                            @ adresse routine traitement signal
    ldr r1,iAdrstSigAction                       @ adresse structure sigaction
    str r0,[r1,#sa_handler]                      @ maj handler
    mov r0,#SIGINT                               @ signal type
    ldr r1,iAdrstSigAction
    mov r2,#0                                    @ NULL
    mov r7, #SIGACTION                           @ call system
    svc #0 
    cmp r0,#0                                    @ error ?
    bne 98f
    mov r0,#SIGQUIT
    ldr r1,iAdrstSigAction
    mov r2,#0                                    @ NULL
    mov r7, #SIGACTION                           @ call system 
    svc #0 
    cmp r0,#0                                    @ error ?
    bne 98f
    mov r0,#SIGTERM
    ldr r1,iAdrstSigAction
    mov r2,#0                                    @ NULL
    mov r7, #SIGACTION                           @ appel systeme 
    svc #0 
    cmp r0,#0
    bne 98f
    @
    adr r0,iAdrSIG_IGN                           @ address signal igonre function
    ldr r1,iAdrstSigAction1
    str r0,[r1,#sa_handler]
    mov r0,#SIGTTOU                              @invalidate other process signal
    ldr r1,iAdrstSigAction1
    mov r2,#0                                    @ NULL
    mov r7,#SIGACTION                            @ call system 
    svc #0 
    cmp r0,#0
    bne 98f
    @
    /* read terminal current state  */
    mov r0,#STDIN
    mov r1,#TCGETS
    ldr r2,iAdrstCurtio                          @ address current termio
    mov r7,#IOCTL                                @ call systeme 
    svc #0 
    cmp r0,#0                                    @ error ?
    bne 98f
    mov r2,#ICANON | ECHO                        @ no key pressed echo on display
    mvn r2,r2                                    @ and one key 
    ldr r1,iAdrstCurtio
    ldr r3,[r1,#term_c_lflag]
    and r3,r2                                    @ add flags 
    str r3,[r1,#term_c_lflag]                    @ and store
    mov r0,#STDIN                                @ maj terminal current state 
    mov r1,#TCSETS
    ldr r2,iAdrstCurtio
    mov r7, #IOCTL                               @ call system
    svc #0 
    cmp r0,#0
    bne 98f
    @
2:                                               @ loop waiting key
    ldr r0,iAdriEnd                              @ if signal ctrl-c  -> end
    ldr r0,[r0]
    cmp r0,#0
    bne 3f
    ldr r0,iAdrstPoll1                            @ address structure poll
    mov r1,#STDIN
    str r1,[r0,#poll_fd]                          @ maj FD
    mov r1,#POLLIN                                @ action code
    str r1,[r0,#poll_events]
    mov r1,#1                                     @ items number structure poll
    mov r2,#0                                     @ timeout = 0 
    mov r7,#SYSPOLL                               @ call system POLL
    svc #0 
    cmp r0,#0                                     @ key pressed ?
    ble 2b                                        @ no key pressed -> loop
                                                  @ read key
    mov r0,#STDIN                                 @ File Descriptor
    ldr r1,iAdriTouche                            @ buffer address
    mov r2,#TAILLEBUFFER                          @ buffer size
    mov r7,#READ                                  @ read key
    svc #0
    cmp r0,#0                                     @ error ?
    ble 98f
    ldr r2,iAdriTouche                            @ key address
    ldr r0,[r2]
    ldr r1,iAdrsHexaKey
    bl conversion16                               @ conversion hexa
    ldr r0,iAdrszMessKey                          @ display key value in hexa
    bl affichageMess
    ldrb r0,[r2]                                  @ key value
    cmp r0,#113                                   @ saisie q ?
    beq 3f
    cmp r0,#81                                    @ saisie Q ?
    beq 3f
    mov r0,#0
    str r0,[r2]                                   @ raz key area
    b 2b                                          @ loop

3:                                                @ end loop display Ok message
    ldr r0,iAdrszMessPgmOk
    bl affichageMess
    b 99f
98:                                               @ error display
    ldr r1,iAdrszMessErreur                       @ error message
    bl   displayError
99:                                               @ end then restaur begin state terminal
    mov r0,#STDIN
    mov r1,#TCSETS
    ldr r2,iAdrstOldtio
    mov r7,#IOCTL                                 @ call system  
    svc #0
    cmp r0,#0
    beq 100f
    ldr r1,iAdrszMessErreur                       @ error message
    bl   displayError

100:                                              @ standard end of the program 
    mov r0, #0                                    @ return code
    mov r7, #EXIT                                 @ request to exit program
    svc #0                                        @ perform the system call
 
iAdrsMessValeur:          .int sMessValeur
iAdrszMessErreur:         .int szMessErreur
iAdrszCarriageReturn:     .int szCarriageReturn
iAdrstOldtio:             .int stOldtio
iAdrstCurtio:             .int stCurtio
iAdrstSigAction:          .int stSigAction
iAdrstSigAction1:         .int stSigAction1
iAdrszMessPgmOk:          .int szMessPgmOk
iAdrsMessResult:          .int sMessResult
iAdrSIG_IGN:              .int 1
iAdriEnd:                 .int iEnd
iAdrstPoll1:              .int stPoll1
iAdriTouche:              .int iTouche
iAdrszMessKey:            .int szMessKey
iAdrsHexaKey:             .int sHexaKey
/******************************************************************/
/*     traitement du signal                                       */ 
/******************************************************************/
/* r0 contains  */
sighandler:
    push {r0,r1}
    ldr r0,iAdriEnd
    mov r1,#1                 @ maj zone end
    str r1,[r0]
    pop {r0,r1}
    bx lr
/***************************************************/
/*   display error message                         */
/***************************************************/
/* r0 contains error code  r1 : message address */
displayError:
    push {r0-r2,lr}                            @ save registers
    mov r2,r0                               @ save error code
    mov r0,r1
    bl affichageMess
    mov r0,r2                               @ error code
    ldr r1,iAdrsHexa
    bl conversion16                         @ conversion hexa
    mov r0,r2                               @ error code
    ldr r1,iAdrsDeci                        @ result address
    bl conversion10                         @ conversion decimale
    ldr r0,iAdrszMessErr                    @ display error message
    bl affichageMess
100:
    pop {r0-r2,lr}                             @ restaur registers
    bx lr                                   @ return 
iAdrszMessErr:                 .int szMessErr
iAdrsHexa:                     .int sHexa
iAdrsDeci:                     .int sDeci
/******************************************************************/
/*     display text with size calculation                         */ 
/******************************************************************/
/* r0 contains the address of the message */
affichageMess:
    push {r0,r1,r2,r7,lr}                          @ save  registres
    mov r2,#0                                      @ counter length 
1:                                                 @ loop length calculation 
    ldrb r1,[r0,r2]                                @ read octet start position + index 
    cmp r1,#0                                      @ if 0 its over 
    addne r2,r2,#1                                 @ else add 1 in the length 
    bne 1b                                         @ and loop 
                                                   @ so here r2 contains the length of the message 
    mov r1,r0                                      @ address message in r1 
    mov r0,#STDOUT                                 @ code to write to the standard output Linux 
    mov r7, #WRITE                                 @ code call system "write" 
    svc #0                                         @ call systeme 
    pop {r0,r1,r2,r7,lr}                           @ restaur registers
    bx lr                                          @ return  
/******************************************************************/
/*     Converting a register to a decimal unsigned                */ 
/******************************************************************/
/* r0 contains value and r1 address area   */
/* r0 return size of result (no zero final in area) */
/* area size => 11 bytes          */
.equ LGZONECAL,   10
conversion10:
    push {r1-r4,lr}                                 @ save registers 
    mov r3,r1
    mov r2,#LGZONECAL
 
1:                                                  @ start loop
    bl divisionpar10U                               @ unsigned  r0 <- dividende. quotient ->r0 reste -> r1
    add r1,#48                                      @ digit
    strb r1,[r3,r2]                                 @ store digit on area
    cmp r0,#0                                       @ stop if quotient = 0 
    subne r2,#1                                     @ else previous position
    bne 1b                                          @ and loop
                                                    @ and move digit from left of area
    mov r4,#0
2:
    ldrb r1,[r3,r2]
    strb r1,[r3,r4]
    add r2,#1
    add r4,#1
    cmp r2,#LGZONECAL
    ble 2b
                                                      @ and move spaces in end on area
    mov r0,r4                                         @ result length 
    mov r1,#' '                                       @ space
3:
    strb r1,[r3,r4]                                   @ store space in area
    add r4,#1                                         @ next position
    cmp r4,#LGZONECAL
    ble 3b                                            @ loop if r4 <= area size
 
100:
    pop {r1-r4,lr}                                    @ restaur registres 
    bx lr                                             @return
 
/***************************************************/
/*   division par 10   unsigned                    */
/***************************************************/
/* r0 dividende   */
/* r0 quotient */	
/* r1 remainder  */
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
/******************************************************************/
/*     Converting a register to hexadecimal                      */ 
/******************************************************************/
/* r0 contains value and r1 address area   */
conversion16:
    push {r1-r4,lr}                                    @ save registers
    mov r2,#28                                         @ start bit position
    mov r4,#0xF0000000                                 @ mask
    mov r3,r0                                          @ save entry value
1:                                                     @ start loop
    and r0,r3,r4                                       @value register and mask
    lsr r0,r2                                          @ move right 
    cmp r0,#10                                         @ compare value
    addlt r0,#48                                       @ <10  ->digit	
    addge r0,#55                                       @ >10  ->letter A-F
    strb r0,[r1],#1                                    @ store digit on area and + 1 in area address
    lsr r4,#4                                          @ shift mask 4 positions
    subs r2,#4                                         @  counter bits - 4 <= zero  ?
    bge 1b                                             @  no -> loop

100:
    pop {r1-r4,lr}                                     @ restaur registers 
    bx lr                                              @return