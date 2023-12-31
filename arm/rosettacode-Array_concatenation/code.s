/* ARM assembly Raspberry PI  */
/*  program concAreaString.s   */

/* Constantes    */
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ WRITE,  4     @ Linux syscall
.equ NBMAXITEMS,  20   @ 
/* Initialized data */
.data
szMessLenArea: .ascii "The length of area 3  is : "
sZoneconv:		 .fill 12,1,' '
szCarriageReturn:  .asciz "\n"

/* areas strings  */
szString1:  .asciz "Apples"
szString2:  .asciz "Oranges"
szString3:  .asciz "Pommes"
szString4:  .asciz "Raisins"
szString5:  .asciz "Abricots"

/* pointer items area 1*/
tablesPoi1:
pt1_1:		.int szString1
pt1_2:   .int szString2
ptVoid_1:		.int 0

/* pointer items area 2*/
tablesPoi2:
pt2_1:		.int szString3
pt2_2:   	.int szString4
pt2_3:   	.int szString5
ptVoid_2:		.int 0

/* UnInitialized data */
.bss 
tablesPoi3:    .skip   4 * NBMAXITEMS

/*  code section */
.text
.global main 
main:                /* entry of program  */
    push {fp,lr}    /* saves 2 registers */

    @ copy area 1 ->  area 3
    ldr r1,iAdrtablesPoi1  @ begin pointer area 1
    ldr r3,iAdrtablesPoi3  @ begin pointer area 3
    mov r0,#0    @ counter
1:
    ldr r2,[r1,r0,lsl #2]    @ read string pointer address item r0 (4 bytes by pointer)
    cmp r2,#0                @ is null ?
    strne r2,[r3,r0,lsl #2]    @ no store pointer in area 3
    addne r0,#1             @ increment counter
    bne 1b                  @ and loop
    @ copy area 2 ->  area 3
    ldr r1,iAdrtablesPoi2  @ begin pointer area 2
    ldr r3,iAdrtablesPoi3  @ begin pointer area 3
    mov r4,#0    @ counter area 2
2:        @ r0 contains the first void item in area 3
    ldr r2,[r1,r4,lsl #2]    @ read string pointer address item r0 (4 bytes by pointer)
    cmp r2,#0                @ is null ?
    strne r2,[r3,r0,lsl #2]    @ no store pointer in area 3
    addne r0,#1             @ increment counter
    addne r4,#1             @ increment counter
    bne 2b                  @ and loop
	
	@ count items number in area 3 
    ldr r1,iAdrtablesPoi3  @ begin pointer table 
    mov r0,#0    @ counter
3:              @ begin loop
    ldr r2,[r1,r0,lsl #2]    @ read string pointer address item r0 (4 bytes by pointer)
    cmp r2,#0                @ is null ?
    addne r0,#1             @ no increment counter
    bne 3b                  @ and loop
 
    ldr r1,iAdrsZoneconv   @ conversion decimal
    bl conversion10S
    ldr r0,iAdrszMessLenArea
    bl affichageMess

100:   /* standard end of the program */
    mov r0, #0                  @ return code
    pop {fp,lr}                 @restaur 2 registers
    mov r7, #EXIT              @ request to exit program
    swi 0                       @ perform the system call
iAdrtablesPoi1:		.int tablesPoi1
iAdrtablesPoi2:		.int tablesPoi2
iAdrtablesPoi3:		.int tablesPoi3
iAdrszMessLenArea:  .int szMessLenArea
iAdrsZoneconv:		.int  sZoneconv
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

/***************************************************/
/*   conversion register signed décimal     */
/***************************************************/
/* r0 contient le registre   */
/* r1 contient l adresse de la zone de conversion */
conversion10S:
    push {r0-r5,lr}    /* save des registres */
    mov r2,r1       /* debut zone stockage */
    mov r5,#'+'     /* par defaut le signe est + */
    cmp r0,#0       /* nombre négatif ? */
    movlt r5,#'-'     /* oui le signe est - */
    mvnlt r0,r0       /* et inversion en valeur positive */
    addlt r0,#1
    mov r4,#10   /* longueur de la zone */
1: /* debut de boucle de conversion */
    bl divisionpar10 /* division  */
    add r1,#48        /* ajout de 48 au reste pour conversion ascii */	
    strb r1,[r2,r4]  /* stockage du byte en début de zone r5 + la position r4 */
    sub r4,r4,#1      /* position précedente */
    cmp r0,#0     
    bne 1b	       /* boucle si quotient different de zéro */
    strb r5,[r2,r4]  /* stockage du signe à la position courante */
    subs r4,r4,#1   /* position précedente */
    blt  100f         /* si r4 < 0  fin  */
    /* sinon il faut completer le debut de la zone avec des blancs */
    mov r3,#' '   /* caractere espace */	
2:
    strb r3,[r2,r4]  /* stockage du byte  */
    subs r4,r4,#1   /* position précedente */
    bge 2b        /* boucle si r4 plus grand ou egal a zero */
100:  /* fin standard de la fonction  */
    pop {r0-r5,lr}   /*restaur desregistres */
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
   bx lr                  /* leave function */
.Ls_magic_number_10: .word 0x66666667