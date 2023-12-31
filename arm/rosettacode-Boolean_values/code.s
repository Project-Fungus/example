/* ARM assembly Raspberry PI  */
/*  program areaString.s   */

/* Constantes    */
@ The are no TRUE or FALSE constants in ARM Assembly
.equ FALSE,  0      @ or other value
.equ TRUE,   1      @ or other value
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ WRITE,  4     @ Linux syscall
/* Initialized data */
.data
szMessTrue: .asciz "The value is true.\n"
szMessFalse: .asciz "The value is false.\n"

/* UnInitialized data */
.bss 

/*  code section */
.text
.global main 
main:                /* entry of program  */
    push {fp,lr}    /* saves 2 registers */
 
    mov r0,#0
    //mov r0,#1   @uncomment pour other test
    cmp r0,#TRUE
    bne 1f
    @ value true
    ldr r0,iAdrszMessTrue
    bl affichageMess
    b 100f
1:   @ value False
    ldr r0,iAdrszMessFalse
    bl affichageMess
 
100:   /* standard end of the program */
    mov r0, #0                  @ return code
    pop {fp,lr}                 @restaur 2 registers
    mov r7, #EXIT              @ request to exit program
    swi 0                       @ perform the system call
iAdrszMessTrue:		.int szMessTrue
iAdrszMessFalse:		.int szMessFalse
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