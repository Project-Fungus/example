/* ARM assembly Raspberry PI  */
/*  program loop1.s   */

/* Constantes    */
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ WRITE,  4     @ Linux syscall
/* Initialized data */
.data
szMessX: .asciz "X"
szCarriageReturn:  .asciz "\n"

/* UnInitialized data */
.bss 

/*  code section */
.text
.global main 
main:                /* entry of program  */
    push {fp,lr}    /* saves 2 registers */

    mov r2,#0       @ counter loop 1
1:       @ loop start 1
    mov r1,#0        @ counter loop 2
2:       @ loop start 2
    ldr r0,iAdrszMessX
    bl affichageMess
    add r1,#1       @ r1 + 1
    cmp r1,r2       @ compare r1 r2
    ble 2b        @ loop label 2 before
    ldr r0,iAdrszCarriageReturn   
    bl affichageMess
    add r2,#1       @ r2 + 1
    cmp r2,#5       @ for five loop
    blt 1b         @ loop label 1 before


100:   /* standard end of the program */
    mov r0, #0                  @ return code
    pop {fp,lr}                 @restaur 2 registers
    mov r7, #EXIT              @ request to exit program
    swi 0                       @ perform the system call

iAdrszMessX:  .int szMessX
iAdrszCarriageReturn:  .int  szCarriageReturn
/******************************************************************/
/*     display text with size calculation                         */ 
/******************************************************************/
/* r0 contains the address of the message */
affichageMess:
    push {fp,lr}    			/* save  registres */ 
    push {r0,r1,r2,r7}    		/* save others registers */
    mov r2,#0   				/* counter length */
1:      	/* loop length calculation */
    ldrb r1,[r0,r2]  			/* read octet start position + index */
    cmp r1,#0       			/* if 0 its over */
    addne r2,r2,#1   			/* else add 1 in the length */
    bne 1b          			/* and loop */
                                /* so here r2 contains the length of the message */
    mov r1,r0        			/* address message in r1 */
    mov r0,#STDOUT      		/* code to write to the standard output Linux */
    mov r7, #WRITE             /* code call system "write" */
    swi #0                      /* call systeme */
    pop {r0,r1,r2,r7}     		/* restaur others registers */
    pop {fp,lr}    				/* restaur des  2 registres */ 
    bx lr	        			/* return  */