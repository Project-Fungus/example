/* ARM assembly Raspberry PI  */
/*  program dnsquery.s   */

/************************************/
/* Constantes                       */
/************************************/
.equ STDIN, 0         @ Linux input console
.equ STDOUT, 1        @ Linux output console

.equ EXIT,   1         @ Linux syscall END PROGRAM
.equ FORK,   2         @ Linux syscall
.equ READ,   3         @ Linux syscall
.equ WRITE,  4         @ Linux syscall
.equ OPEN,   5         @ Linux syscall
.equ CLOSE,  6         @ Linux syscall
.equ EXECVE, 0xB      @ Linux syscall
.equ PIPE,   0x2A     @ Linux syscall
.equ DUP2,   0x3F        @ Linux syscall
.equ WAIT4,  0x72     @ Linux syscall

.equ WUNTRACED,   2   @ Wait, return status of stopped child
.equ TAILLEBUFFER,  500
/*********************************/
/* Initialized data              */
/*********************************/
.data
szCarriageReturn:    .asciz "\n"
szMessFinOK:          .asciz "Fin normale du programme. \n"
szMessError:          .asciz "Error occured !!!"
szCommand:             .asciz "/usr/bin/host"  @ command host
szNameHost:            .asciz "www.kame.net"   @ string query name
.align 4
stArg1:                 .int szCommand           @ address command
                          .int szNameHost          @ address argument
                          .int 0,0                   @ zeroes

/*********************************/
/* UnInitialized data            */
/*********************************/
.bss  
.align 4
iStatusThread:      .skip 4
pipefd:               .skip 8
sBuffer:              .skip  TAILLEBUFFER
stRusage:             .skip TAILLEBUFFER
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                                           @ entry of program 
    /* création pipe  */
    ldr r0,iAdrpipefd                          @ FDs address
    mov r7, #PIPE                               @ create pipe
    svc 0                                        @ call system Linux
    cmp r0,#0                                    @ error  ?
    blt 99f

    /* create child thread */
    mov r0,#0
    mov r7, #FORK                                @ call system
    svc #0 
    cmp r0,#0                                     @ error ?
    blt 99f
    bne parent                                  @ if <> zero r0 contains father pid
                                                  @ else is the child
/****************************************/
/*  Child thread                       */
/****************************************/
    /* redirection sysout -> pipe */ 
    ldr r0,iAdrpipefd
    ldr r0,[r0,#4]
    mov r7, #DUP2                                @ call system linux 
    mov r1, #STDOUT                             @
    svc #0
    cmp r0,#0                                    @ error ?
    blt 99f

    /* run command host      */
    ldr r0, iAdrszCommand                    @ r0 = address de "/usr/bin/host"
    ldr r1,iAdrstArg1                         @ address argument 1
    mov r2,#0
    mov r7, #EXECVE                            @ call system linux (execve)
    svc #0                                      @ if ok -> no return !!!
    b 100f                                      @ never exec this label
/****************************************/
/*  Father thread                       */
/****************************************/
parent:	
    mov r4,r0                                     @ save child pid
1:                                                @ loop child signal
    mov r0,r4
    ldr r1,iAdriStatusThread                  @ return status thread
    mov r2,#WUNTRACED                           @ flags 
    ldr r3,iAdrstRusage                        @ return structure thread
    mov r7, #WAIT4                               @ Call System 
    svc #0 
    cmp r0,#0                                    @ error ?
    blt 99f
    @ recup status 
    ldr r0,iAdriStatusThread                 @ analyse status
    ldrb r0,[r0]                                @ firest byte
    cmp r0,#0                                    @ normal end thread ?
    bne 1b                                      @ loop

    /* close entry pipe */ 
    ldr r0,iAdrpipefd
    mov r7,#CLOSE                               @ call system
    svc #0 

    /* read datas pipe */ 
    ldr r0,iAdrpipefd
    ldr r0,[r0]
    ldr r1,iAdrsBuffer                        @ buffer address
    mov r2,#TAILLEBUFFER                      @ buffer size
    mov r7, #READ                               @ call system
    svc #0 
    ldr r0,iAdrsBuffer                        @ display buffer
    bl affichageMess

    ldr r0,iAdrszMessFinOK                   @ display message Ok
    bl affichageMess
    mov r0, #0                                   @ return code
    b 100f
99:
    ldr r0,iAdrszMessError                   @ erreur
    bl affichageMess
    mov r0, #1                                   @ return code
    b 100f
100:                                            @ standard end of the program 
    mov r7, #EXIT                               @ request to exit program
    svc #0                                      @ perform the system call

iAdrszCarriageReturn:      .int szCarriageReturn
iAdrszMessFinOK:            .int szMessFinOK
iAdrszMessError:            .int szMessError
iAdrsBuffer:                 .int sBuffer
iAdrpipefd:                  .int pipefd
iAdrszCommand:              .int szCommand
iAdrstArg1:                  .int stArg1
iAdriStatusThread:         .int iStatusThread
iAdrstRusage:                .int stRusage


/******************************************************************/
/*     display text with size calculation                         */ 
/******************************************************************/
/* r0 contains the address of the message */
affichageMess:
    push {r0,r1,r2,r7,lr}                          @ save  registres
    mov r2,#0                                      @ counter length 
1:                                                 @ loop length calculation 
    ldrb r1,[r0,r2]                               @ read octet start position + index 
    cmp r1,#0                                      @ if 0 its over 
    addne r2,r2,#1                                @ else add 1 in the length 
    bne 1b                                        @ and loop 
                                                   @ so here r2 contains the length of the message 
    mov r1,r0                                      @ address message in r1 
    mov r0,#STDOUT                                @ code to write to the standard output Linux 
    mov r7, #WRITE                                @ code call system "write" 
    svc #0                                        @ call systeme 
    pop {r0,r1,r2,r7,lr}                           @ restaur des  2 registres */ 
    bx lr                                          @ return