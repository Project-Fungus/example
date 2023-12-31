/* ARM assembly Raspberry PI  */
/*  program factorst.s   */

/* Constantes    */
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ WRITE,  4     @ Linux syscall
/* Initialized data */
.data
szMessDeb: .ascii "Factors of :"
sMessValeur:   .fill 12, 1, ' '
                   .asciz "are : \n"
sMessFactor:   .fill 12, 1, ' '
                   .asciz "\n"
szCarriageReturn:  .asciz "\n"

/* UnInitialized data */
.bss 

/*  code section */
.text
.global main 
main:                /* entry of program  */
    push {fp,lr}    /* saves 2 registers */
 
    mov r0,#100
    bl factors
    mov r0,#97
    bl factors
    ldr r0,iNumber
    bl factors

    
100:   /* standard end of the program */
    mov r0, #0                  @ return code
    pop {fp,lr}                 @restaur 2 registers
    mov r7, #EXIT              @ request to exit program
    swi 0                       @ perform the system call

iNumber: .int 32767
iAdrszCarriageReturn:  .int  szCarriageReturn
/******************************************************************/
/*     calcul factors of number                                  */ 
/******************************************************************/
/* r0 contains the number */
factors:
    push {fp,lr}    			/* save  registres */ 
    push {r1-r6}    		/* save others registers */
    mov r5,r0    @ limit calcul
    ldr r1,iAdrsMessValeur   @ conversion register in decimal string
    bl conversion10S
    ldr r0,iAdrszMessDeb     @ display message
    bl affichageMess
    mov r6,#1    @ counter loop
1:   @ loop 
    mov r0,r5    @ dividende
    mov r1,r6    @ divisor
    bl division
    cmp r3,#0    @ remainder = zero ?
    bne 2f
    @ display result if yes
    mov r0,r6
    ldr r1,iAdrsMessFactor
    bl conversion10S
    ldr r0,iAdrsMessFactor
    bl affichageMess
2:
    add r6,#1      @ add 1 to loop counter
    cmp r6,r5      @ <=  number ?
    ble 1b        @ yes loop
100:
    pop {r1-r6}     		/* restaur others registers */
    pop {fp,lr}    				/* restaur des  2 registres */ 
    bx lr	        			/* return  */
iAdrsMessValeur: .int sMessValeur
iAdrszMessDeb: .int szMessDeb
iAdrsMessFactor: .int sMessFactor
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
/*=============================================*/
/* division integer unsigned                */
/*============================================*/
division:
    /* r0 contains N */
    /* r1 contains D */
    /* r2 contains Q */
    /* r3 contains R */
    push {r4, lr}
    mov r2, #0                 /* r2 ? 0 */
    mov r3, #0                 /* r3 ? 0 */
    mov r4, #32                /* r4 ? 32 */
    b 2f
1:
    movs r0, r0, LSL #1    /* r0 ? r0 << 1 updating cpsr (sets C if 31st bit of r0 was 1) */
    adc r3, r3, r3         /* r3 ? r3 + r3 + C. This is equivalent to r3 ? (r3 << 1) + C */
 
    cmp r3, r1             /* compute r3 - r1 and update cpsr */
    subhs r3, r3, r1       /* if r3 >= r1 (C=1) then r3 ? r3 - r1 */
    adc r2, r2, r2         /* r2 ? r2 + r2 + C. This is equivalent to r2 ? (r2 << 1) + C */
2:
    subs r4, r4, #1        /* r4 ? r4 - 1 */
    bpl 1b            /* if r4 >= 0 (N=0) then branch to .Lloop1 */
 
    pop {r4, lr}
    bx lr	

/***************************************************/
/*   conversion register in string décimal signed  */
/***************************************************/
/* r0 contains the register   */
/* r1 contains address of conversion area */
conversion10S:
    push {fp,lr}    /* save registers frame and return */
    push {r0-r5}   /* save other registers  */
    mov r2,r1       /* early storage area */
    mov r5,#'+'     /* default sign is + */
    cmp r0,#0       /* négatif number ? */
    movlt r5,#'-'     /* yes sign is - */
    mvnlt r0,r0       /* and inverse in positive value */
    addlt r0,#1
    mov r4,#10   /* area length */
1: /* conversion loop */
    bl divisionpar10 /* division  */
    add r1,#48        /* add 48 at remainder for conversion ascii */	
    strb r1,[r2,r4]  /* store byte area r5 + position r4 */
    sub r4,r4,#1      /* previous position */
    cmp r0,#0     
    bne 1b	       /* loop if quotient not equal zéro */
    strb r5,[r2,r4]  /* store sign at current position  */
    subs r4,r4,#1   /* previous position */
    blt  100f         /* if r4 < 0  end  */
    /* else complete area with space */
    mov r3,#' '   /* character space */	
2:
    strb r3,[r2,r4]  /* store  byte  */
    subs r4,r4,#1   /* previous position */
    bge 2b        /* loop if r4 greather or equal zero */
100:  /*  standard end of function  */
    pop {r0-r5}   /*restaur others registers */
    pop {fp,lr}   /* restaur des  2 registers frame et return  */
    bx lr   

/***************************************************/
/*   division par 10   signé                       */
/* Thanks to http://thinkingeek.com/arm-assembler-raspberry-pi/*  
/* and   http://www.hackersdelight.org/            */
/***************************************************/
/* r0 contient le dividende   */
/* r0 retourne le quotient */	
/* r1 retourne le reste  */
divisionpar10:	
  /* r0 contains the argument to be divided by 10 */
   push {r2-r4}   /* save autres registres  */
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