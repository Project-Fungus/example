create file helloword.s   
   compile it with : as -o helloword.o helloword.s
   link  it with   : ld -o helloword helloword.o -e main
   execute it      :  helloword


/* ARM assembly Raspberry PI  */
/*  program helloword.s   */
.data
szMessage: .asciz "Hello world. \n"   
.equ LGMESSAGE, . -  szMessage  @ compute length of message
.text
.global main 
main:	
    mov r0, #1                  @ output std linux
    ldr r1, iAdrMessage         @ adresse of message
    mov r2, #LGMESSAGE          @ sizeof(message) 
    mov r7, #4                  @ select system call 'write' 
    swi #0                      @ perform the system call 
 
    mov r0, #0                  @ return code
    mov r7, #1                  @ request to exit program
    swi 0 
iAdrMessage: .int szMessage