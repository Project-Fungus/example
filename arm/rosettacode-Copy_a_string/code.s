/* ARM assembly Raspberry PI  */
/*  program copystr.s   */

/* Constantes    */
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ WRITE,  4     @ Linux syscall
/* Initialized data */
.data
szString: .asciz "ABCDEFGHIJKLMNOPQRSTUVWXYZ\n"

/* UnInitialized data */
.bss 
.align 4
iPtString:   .skip 4
szString1:    .skip 80

/*  code section */
.text
.global main 
main:                /* entry of program  */
    push {fp,lr}    /* saves 2 registers */

    @ display start string 
    ldr r0,iAdrszString
    bl affichageMess
    @ copy pointer string
    ldr r0,iAdrszString
    ldr r1,iAdriPtString
    str r0,[r1]
    @ control
    ldr r1,iAdriPtString
    ldr r0,[r1]
    bl affichageMess
    @ copy string
    ldr r0,iAdrszString    
    ldr r1,iAdrszString1
1:
    ldrb r2,[r0],#1   @ read one byte and increment pointer one byte
    strb r2,[r1],#1   @ store one byte and increment pointer one byte
    cmp r2,#0          @ end of string ?
    bne 1b            @ no -> loop 
    @ control
    ldr r0,iAdrszString1
    bl affichageMess

100:   /* standard end of the program */
    mov r0, #0                  @ return code
    pop {fp,lr}                 @restaur 2 registers
    mov r7, #EXIT              @ request to exit program
    swi 0                       @ perform the system call
iAdrszString:		.int szString
iAdriPtString:		.int iPtString
iAdrszString1:		.int szString1

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