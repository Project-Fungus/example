/* ARM assembly Raspberry PI  */
/*  program integer.s   */

/* Constantes    */
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ WRITE,  4     @ Linux syscall

/*********************************/
/* Initialized data              */
/*********************************/
.data
iNumberBinaire: .int 0b1100100
iNumberOctal:    .int  0144
iNumberDecimal: .int 100
iNumberHexa:     .int 0x64


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
    ldr r0,iAdriNumberBinaire   @ number address 
    ldr r0,[r0]                     @ load number
    ldr r1,iAdrsMessValeur                
    bl conversion10       @ call function with 2 parameter (r0,r1)
    ldr r0,iAdrszMessResult
    bl affichageMess            @ display message
    ldr r0,iAdriNumberOctal
    ldr r0,[r0]
    ldr r1,iAdrsMessValeur                
    bl conversion10       @ call function with 2 parameter (r0,r1)
    ldr r0,iAdrszMessResult
    bl affichageMess            @ display message
   ldr r0,iAdriNumberDecimal
    ldr r0,[r0]
    ldr r1,iAdrsMessValeur                
    bl conversion10       @ call function with 2 parameter (r0,r1)
    ldr r0,iAdrszMessResult
    bl affichageMess            @ display message
    ldr r0,iAdriNumberHexa
    ldr r0,[r0]
    ldr r1,iAdrsMessValeur                
    bl conversion10       @ call function with 2 parameter (r0,r1)
    ldr r0,iAdrszMessResult
    bl affichageMess            @ display message

100:   @ standard end of the program 
    mov r0, #0                  @ return code
    pop {fp,lr}                 @restaur 2 registers
    mov r7, #EXIT              @ request to exit program
    svc #0                       @ perform the system call
iAdriNumberBinaire:	.int iNumberBinaire
iAdriNumberOctal:		.int iNumberOctal
iAdriNumberDecimal:	.int iNumberDecimal
iAdriNumberHexa:		.int iNumberHexa
iAdrsMessValeur:		.int sMessValeur
iAdrszMessResult:		.int szMessResult

/******************************************************************/
/*     display text with size calculation                         */ 
/******************************************************************/
/* r0 contains the address of the message */
affichageMess:
    push {r0,r1,r2,r7,lr}    			/* save  registres */ 
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
    svc #0                      /* call systeme */
    pop {r0,r1,r2,r7,lr}    				/* restaur des  2 registres */ 
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