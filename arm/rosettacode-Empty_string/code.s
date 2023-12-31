/* ARM assembly Raspberry PI  */
/*  program strEmpty.s   */

/* Constantes    */
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ WRITE,  4     @ Linux syscall
/* Initialized data */
.data
szNotEmptyString:   .asciz "String is not empty. \n"
szEmptyString:      .asciz "String is empty. \n"
@ empty string
szString:            .asciz ""   @ with zero final
szString1:           .asciz "A"  @ with zero final

/* UnInitialized data */
.bss 

/*  code section */
.text
.global main 
main:                /* entry of program  */
    push {fp,lr}    /* saves 2 registers */

    @ load string 
    ldr r1,iAdrszString
    ldrb r0,[r1]    @ load first byte of string
    cmp r0,#0        @ compar with zero ?
    bne 1f
    ldr r0,iAdrszEmptyString
    bl affichageMess
    b 2f
1:

    ldr r0,iAdrszNotEmptyString
    bl affichageMess
	/* second string */
2:
    @ load string 1 
    ldr r1,iAdrszString1
    ldrb r0,[r1]        @ load first byte of string
    cmp r0,#0            @ compar with zero ?
    bne 3f
    ldr r0,iAdrszEmptyString
    bl affichageMess
    b 100f
3:
    ldr r0,iAdrszNotEmptyString
    bl affichageMess
    b 100f

100:   /* standard end of the program */
    mov r0, #0                  @ return code
    pop {fp,lr}                 @restaur 2 registers
    mov r7, #EXIT              @ request to exit program
    swi 0                       @ perform the system call
iAdrszString:             .int szString
iAdrszString1:            .int szString1
iAdrszNotEmptyString:   .int szNotEmptyString
iAdrszEmptyString:       .int szEmptyString

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