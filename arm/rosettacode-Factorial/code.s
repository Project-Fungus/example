/* ARM assembly Raspberry PI  */
/*  program factorial.s   */

/* Constantes    */
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ WRITE,  4     @ Linux syscall

/*********************************/
/* Initialized data              */
/*********************************/
.data
szMessLargeNumber:   .asciz "Number N to large. \n"
szMessNegNumber:      .asciz "Number N is negative. \n"

szMessResult:  .ascii "Resultat = "      @ message result
sMessValeur:   .fill 12, 1, ' '
                   .asciz "\n"
/*********************************/
/* UnInitialized data            */
/*********************************/
.bss 
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                @ entry of program 
    push {fp,lr}      @ saves 2 registers 

    mov r0,#-5
    bl factorial
    mov r0,#10
    bl factorial
    mov r0,#20
    bl factorial


100:   @ standard end of the program 
    mov r0, #0                  @ return code
    pop {fp,lr}                 @restaur 2 registers
    mov r7, #EXIT              @ request to exit program
    swi 0                       @ perform the system call


/********************************************/
/*     calculation                         */
/********************************************/
/* r0 contains number N */
factorial:
    push {r1,r2,lr}    	@ save  registres 
    cmp r0,#0
    blt 99f
    beq 100f
    cmp r0,#1
    beq 100f
    bl calFactorial
    cmp r0,#-1          @ overflow ?
    beq 98f
    ldr r1,iAdrsMessValeur                
    bl conversion10       @ call function with 2 parameter (r0,r1)
    ldr r0,iAdrszMessResult
    bl affichageMess            @ display message
    b 100f

98:   @ display error message
    ldr r0,iAdrszMessLargeNumber
    bl affichageMess
    b 100f
99:  @ display error message
    ldr r0,iAdrszMessNegNumber
    bl affichageMess

100:
    pop {r1,r2,lr}    			@ restaur registers 
    bx lr	        			@ return  
iAdrszMessNegNumber:       .int szMessNegNumber
iAdrszMessLargeNumber:	    .int szMessLargeNumber
iAdrsMessValeur:            .int sMessValeur	
iAdrszMessResult:          .int szMessResult
/******************************************************************/
/*     calculation                         */ 
/******************************************************************/
/* r0 contains the number N */
calFactorial:
    cmp r0,#1          @ N = 1 ?
    bxeq lr           @ yes -> return 
    push {fp,lr}    		@ save  registers 
    sub sp,#4           @ 4 byte on the stack 
    mov fp,sp           @ fp <- start address stack
    str r0,[fp]                    @ fp contains  N
    sub r0,#1          @ call function with N - 1
    bl calFactorial
    cmp r0,#-1         @ error overflow ?
    beq 100f         @ yes -> return
    ldr r1,[fp]       @ load N
    umull r0,r2,r1,r0   @ multiply result by N 
    cmp r2,#0           @ r2 is the hi rd  if <> 0 overflow
    movne r0,#-1      @ if overflow  -1 -> r0

100:
    add sp,#4            @ free 4 bytes on stack
    pop {fp,lr}    			@ restau2 registers 
    bx lr	        		@ return  

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
/******************************************************************/
/*     Converting a register to a decimal                                 */ 
/******************************************************************/
/* r0 contains value and r1 address area   */
conversion10:
    push {r1-r4,lr}    /* save registers */ 
    mov r3,r1
    mov r2,#10

1:	   @ start loop
    bl divisionpar10 @ r0 <- dividende. quotient ->r0 reste -> r1
    add r1,#48        @ digit	
    strb r1,[r3,r2]  @ store digit on area
    sub r2,#1         @ previous position
    cmp r0,#0         @ stop if quotient = 0 */
    bne 1b	          @ else loop
    @ and move spaves in first on area
    mov r1,#' '   @ space	
2:	
    strb r1,[r3,r2]  @ store space in area
    subs r2,#1       @ @ previous position
    bge 2b           @ loop if r2 >= zéro 

100:	
    pop {r1-r4,lr}    @ restaur registres 
    bx lr	          @return
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
   push {r2-r4}   /* save registers  */
   mov r4,r0 
   ldr r3, .Ls_magic_number_10 /* r1 <- magic_number */
   smull r1, r2, r3, r0   /* r1 <- Lower32Bits(r1*r0). r2 <- Upper32Bits(r1*r0) */
   mov r2, r2, ASR #2     /* r2 <- r2 >> 2 */
   mov r1, r0, LSR #31    /* r1 <- r0 >> 31 */
   add r0, r2, r1         /* r0 <- r2 + r1 */
   add r2,r0,r0, lsl #2   /* r2 <- r0 * 5 */
   sub r1,r4,r2, lsl #1   /* r1 <- r4 - (r2 * 2)  = r4 - (r0 * 10) */
   pop {r2-r4}
   bx lr                  /* leave function */
   .align 4
.Ls_magic_number_10: .word 0x66666667