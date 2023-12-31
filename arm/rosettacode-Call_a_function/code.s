/* ARM assembly Raspberry PI  */
/*  program callfonct.s   */

/* Constantes    */
.equ STDOUT, 1
.equ WRITE,  4
.equ EXIT,   1

/***********************/
/* Initialized data */
/***********************/
.data
szMessage:      .asciz "Hello. \n"       @ message
szRetourLigne: .asciz "\n"
szMessResult:  .ascii "Resultat : "      @ message result
sMessValeur:   .fill 12, 1, ' '
                   .asciz "\n"
/***********************/				   
/* No Initialized data */
/***********************/
.bss
iValeur:  .skip  4     @ reserve 4 bytes in memory

.text
.global main 
main:
    ldr r0,=szMessage          @ adresse of message  short program
    bl affichageMess            @ call function with 1 parameter (r0)

    @ call function with parameters in register
    mov r0,#5
    mov r1,#10
    bl fonction1            @ call function with 2 parameters (r0,r1)
    ldr r1,=sMessValeur                           @ result in r0
    bl conversion10S       @ call function with 2 parameter (r0,r1)
    ldr r0,=szMessResult
    bl affichageMess            @ call function with 1 parameter (r0)

    @ call function with parameters on stack
    mov r0,#5
    mov r1,#10
    push {r0,r1}
    bl fonction2            @ call function with 2 parameters on the stack
                              @ result in r0
    ldr r1,=sMessValeur                 
    bl conversion10S       @ call function with 2 parameter (r0,r1)
    ldr r0,=szMessResult
    bl affichageMess            @ call function with 1 parameter (r0)
 
 
 /* end of  program */
    mov r0, #0                  @ return code
    mov r7, #EXIT              @ request to exit program
    swi 0                       @ perform the system call

/******************************************************************/
/*     call function parameter in register             */ 
/******************************************************************/
/* r0 value one */
/* r1 value two */
/* return in r0 */
fonction1:
    push {fp,lr}    /* save des  2 registres */ 
    push {r1,r2}    /* save des autres registres */
    mov r2,#20
    mul r0,r2
    add r0,r0,r1
    pop {r1,r2}     /* restaur des autres registres */
    pop {fp,lr}    /* restaur des  2 registres */ 
    bx lr           /* retour procedure */	

/******************************************************************/
/*     call function parameter in the stack             */ 
/******************************************************************/
/* return in r0 */
fonction2:
    push {fp,lr}    /* save des  2 registres */ 
    add fp,sp,#8    /* address parameters in the stack*/
    push {r1,r2}    /* save des autres registres */
    ldr r0,[fp]
    ldr r1,[fp,#4]
    mov r2,#-20
    mul r0,r2
    add r0,r0,r1
    pop {r1,r2}     /* restaur des autres registres */
    pop {fp,lr}    /* restaur des  2 registres */ 
    add sp,#8      /* very important, for stack aligned */
    bx lr          /* retour procedure */	

/******************************************************************/
/*     affichage des messages   avec calcul longueur              */ 
/******************************************************************/
/* r0 contient l adresse du message */
affichageMess:
    push {fp,lr}    /* save des  2 registres */ 
    push {r0,r1,r2,r7}    /* save des autres registres */
    mov r2,#0   /* compteur longueur */
1:       /*calcul de la longueur */
    ldrb r1,[r0,r2]  /* recup octet position debut + indice */
    cmp r1,#0       /* si 0 c est fini */
    beq 1f
    add r2,r2,#1   /* sinon on ajoute 1 */
    b 1b
1:  /* donc ici r2 contient la longueur du message */
    mov r1,r0        /* adresse du message en r1 */
    mov r0,#STDOUT      /* code pour écrire sur la sortie standard Linux */
    mov r7, #WRITE                  /* code de l appel systeme 'write' */
    swi #0                      /* appel systeme */
    pop {r0,r1,r2,r7}     /* restaur des autres registres */
    pop {fp,lr}    /* restaur des  2 registres */ 
    bx lr	        /* retour procedure */	
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