/* ARM assembly Raspberry PI  */
/*  program binarydigit.s   */

/* Constantes    */
.equ STDOUT, 1
.equ WRITE,  4
.equ EXIT,   1
/* Initialized data */
.data

sMessAffBin: .ascii "The decimal value  "
sZoneDec: .space 12,' '
             .ascii " should produce an output of "
sZoneBin: .space 36,' '
              .asciz "\n"

/*  code section */
.text
.global main 
main:                /* entry of program  */
    push {fp,lr}    /* save des  2 registres */
    mov r0,#5
    ldr r1,iAdrsZoneDec
    bl conversion10S    @ decimal conversion
    bl conversion2      @ binary conversion and display résult
    mov r0,#50
    ldr r1,iAdrsZoneDec
    bl conversion10S
    bl conversion2
    mov r0,#-1
    ldr r1,iAdrsZoneDec
    bl conversion10S
    bl conversion2
    mov r0,#1
    ldr r1,iAdrsZoneDec
    bl conversion10S
    bl conversion2

100:   /* standard end of the program */
    mov r0, #0                  @ return code
    pop {fp,lr}                 @restaur 2 registers
    mov r7, #EXIT              @ request to exit program
    swi 0                       @ perform the system call
iAdrsZoneDec: .int sZoneDec
/******************************************************************/
/*     register conversion in binary                              */ 
/******************************************************************/
/* r0 contains the register */
conversion2:
    push {r0,lr}     /* save  registers */  
    push {r1-r5} /* save others registers */
    ldr r1,iAdrsZoneBin   @ address reception area
    clz r2,r0    @ number of left zeros bits 
    rsb r2,#32   @ number of significant bits
    mov r4,#' '  @ space
    add r3,r2,#1 @ position counter in reception area
1:
    strb r4,[r1,r3]   @ space in other location of reception area
    add r3,#1
    cmp r3,#32         @ end of area ?
    ble 1b            @ no! loop
    mov r3,r2    @ position counter of the written character
2:               @ loop 
    lsrs r0,#1    @ shift right one bit with flags
    movcc r4,#48  @ carry clear  => character 0
    movcs r4,#49  @ carry set   => character 1 
    strb r4,[r1,r3]  @ character in reception area at position counter
    sub r3,r3,#1     @ 
    subs r2,r2,#1   @  0 bits ?
    bgt 2b          @ no!  loop
    
    ldr r0,iAdrsZoneMessBin
    bl affichageMess
    
100:
    pop {r1-r5}  /* restaur others registers */
    pop {r0,lr}
    bx lr	
iAdrsZoneBin: .int sZoneBin	   
iAdrsZoneMessBin: .int sMessAffBin

/******************************************************************/
/*     display text with size calculation                         */ 
/******************************************************************/
/* r0 contains the address of the message */
affichageMess:
    push {fp,lr}    			/* save  registres */ 
    push {r0,r1,r2,r7}    		/* save others registres */
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
    pop {r0,r1,r2,r7}     		/* restaur others registres */
    pop {fp,lr}    				/* restaur des  2 registres */ 
    bx lr	        			/* return  */	
/***************************************************/
/*   conversion registre en décimal   signé  */
/***************************************************/
/* r0 contient le registre   */
/* r1 contient l adresse de la zone de conversion */
conversion10S:
    push {fp,lr}    /* save des  2 registres frame et retour */
    push {r0-r5}   /* save autres registres  */
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
    pop {r0-r5}   /*restaur des autres registres */
    pop {fp,lr}   /* restaur des  2 registres frame et retour  */
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
    push {r2-r4}   /* save others registers  */
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