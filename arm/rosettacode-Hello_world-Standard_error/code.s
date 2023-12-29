/* ARM assembly Raspberry PI  */
/*  program hellowordLP.s   */
.data
szMessage: .asciz "Goodbye world. \n "       @ error message
.equ LGMESSAGE, . -  szMessage  @ compute length of message

.text
.global main 
main:	
    mov r0, #2                  @ output error linux
    ldr r1, iAdrMessage         @ adresse of message
    mov r2, #LGMESSAGE          @ sizeof(message) 
    mov r7, #4                  @ select system call 'write' 
    swi #0                      @ perform the system call 
 
    mov r0, #0                  @ return code
    mov r7, #1                  @ request to exit program
    swi #0                       @ perform the system call
iAdrMessage: .int szMessage