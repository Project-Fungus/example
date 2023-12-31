/* ARM assembly Raspberry PI  */
/*  program rechMax.s   */

/* Constantes    */
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ WRITE,  4     @ Linux syscall

/*********************************/
/* Initialized data              */
/*********************************/
.data
szMessResult:  .ascii "Max number is = "      @ message result
sMessValeur:   .fill 12, 1, ' '
                  .ascii " rank = "
sMessRank:   .fill 12, 1, ' '
                  .ascii " address (hexa) = "
sMessAddress:   .fill 12, 1, ' '
                   .asciz "\n"
				   
tTableNumbers:    .int   50
                      .int 12
                      .int -1000
                      .int 40
                      .int 255
                      .int 60
                      .int 254
.equ NBRANKTABLE,   (. - tTableNumbers) / 4  @ number table posts

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

    ldr r1,iAdrtTableNumbers
    mov r2,#0
    ldr r4,[r1,r2,lsl #2]
    mov r3,r2
    add r2,#1
1:
    cmp r2,#NBRANKTABLE
	bge 2f
	ldr r0,[r1,r2,lsl #2]
	cmp r0,r4
	movgt r4,r0
	movgt r3,r2
	add r2,#1
	b 1b
	
2:
    mov r0,r4
    ldr r1,iAdrsMessValeur                
    bl conversion10S       @ call conversion
    mov r0,r3
    ldr r1,iAdrsMessRank                
    bl conversion10       @ call conversion
    ldr r0,iAdrtTableNumbers
    add r0,r3,lsl #2
    ldr r1,iAdrsMessAddress                
    bl conversion16       @ call conversion
    ldr r0,iAdrszMessResult
    bl affichageMess            @ display message

 


100:   @ standard end of the program 
    mov r0, #0                  @ return code
    pop {fp,lr}                 @restaur 2 registers
    mov r7, #EXIT              @ request to exit program
    swi 0                       @ perform the system call
iAdrtTableNumbers:    .int  tTableNumbers
iAdrsMessValeur:      .int sMessValeur
iAdrsMessRank:         .int sMessRank
iAdrsMessAddress:     .int sMessAddress
iAdrszMessResult:     .int szMessResult

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
/*     Converting a register to hexadecimal                      */ 
/******************************************************************/
/* r0 contains value and r1 address area   */
conversion16:
    push {r1-r4,lr}    /* save registers */ 
    mov r2,#28         @ start bit position
    mov r4,#0xF0000000    @ mask
    mov r3,r0      @ save entry value
1:	   @ start loop
    and r0,r3,r4   @value register and mask
    lsr r0,r2      @ move right 
    cmp r0,#10      @ compare value
    addlt r0,#48        @ <10  ->digit	
    addge r0,#55        @ >10  ->letter A-F
    strb r0,[r1],#1  @ store digit on area and + 1 in area address
    lsr r4,#4       @ shift mask 4 positions
    subs r2,#4         @  counter bits - 4 <= zero  ?
    bge 1b	          @  no -> loop
    @end
    pop {r1-r4,lr}    @ restaur registres 
    bx lr             @return
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
/*  Converting a register to a signed decimal      */
/***************************************************/
/* r0 contains value and r1 area address    */
conversion10S:
    push {r0-r4,lr}    @ save registers
    mov r2,r1       /* debut zone stockage */
    mov r3,#'+'     /* par defaut le signe est + */
    cmp r0,#0       @ negative number ? 
    movlt r3,#'-'   @ yes
    mvnlt r0,r0     @ number inversion
    addlt r0,#1   
    mov r4,#10       @ length area
1:  @ start loop
    bl divisionpar10
    add r1,#48   @ digit
    strb r1,[r2,r4]  @ store digit on area
    sub r4,r4,#1      @ previous position
    cmp r0,#0          @ stop if quotient = 0
    bne 1b	

    strb r3,[r2,r4]  @ store signe 
    subs r4,r4,#1    @ previous position
    blt  100f        @ if r4 < 0 -> end

    mov r1,#' '   @ space	
2:
    strb r1,[r2,r4]  @store byte space
    subs r4,r4,#1    @ previous position
    bge 2b           @ loop if r4 > 0
100: 
    pop {r0-r4,lr}   @ restaur registers
    bx lr  
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