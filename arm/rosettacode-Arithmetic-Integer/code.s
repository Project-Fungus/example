/* ARM assembly Raspberry PI  */
/*  program arith.s   */
/* Constantes    */
.equ STDOUT, 1
.equ WRITE,  4
.equ EXIT,   1

/***********************/
/* Initialized data */
/***********************/
.data
szMessError:      .asciz " Two numbers in command line please ! \n"       @ message
szRetourLigne: .asciz "\n"
szMessResult:  .asciz "Resultat "      @ message result
sMessValeur:   .fill 12, 1, ' '
                   .asciz "\n"
szMessAddition: .asciz "addition :"
szMessSoustraction: .asciz "soustraction :"
szMessMultiplication: .asciz "multiplication :"
szMessDivision: .asciz "division :"
szMessReste: .asciz "reste :"
   
/***********************/				   
/* No Initialized data */
/***********************/
.bss
iValeur:  .skip  4     @ reserve 4 bytes in memory

.text
.global main 
main:
    push {fp,lr}                @ save des  2 registres
    add fp,sp,#8                @ fp <- adresse début
    ldr r0,[fp]                 @ recup number of parameter in command line
    cmp r0,#3
    blt error
    ldr r0,[fp,#8]              @ adresse of 1er number
    bl conversionAtoD
    mov r3,r0
    ldr r0,[fp,#12]             @ adresse of 2eme number
    bl conversionAtoD
    mov r4,r0
    @ addition
    add r0,r3,r4
    ldr r1,iAdrsMessValeur      @ result in r0
    bl conversion10S            @ call function with 2 parameter (r0,r1)
    ldr r0,iAdrszMessResult
    bl affichageMess            @ display message
    ldr r0,iAdrszMessAddition
    bl affichageMess            @ display message
    ldr r0,iAdrsMessValeur
    bl affichageMess            @ display message
    @ soustraction
    sub r0,r3,r4
    ldr r1,=sMessValeur                 
    bl conversion10S            @ call function with 2 parameter (r0,r1)
    ldr r0,iAdrszMessResult
    bl affichageMess            @ display message
    ldr r0,iAdrszMessSoustraction
    bl affichageMess            @ display message
    ldr r0,iAdrsMessValeur
    bl affichageMess            @ display message

    @ multiplication
    mul r0,r3,r4
    ldr r1,=sMessValeur                 
    bl conversion10S            @ call function with 2 parameter (r0,r1)
    ldr r0,iAdrszMessResult
    bl affichageMess            @ display message
    ldr r0,iAdrszMessMultiplication
    bl affichageMess            @ display message
    ldr r0,iAdrsMessValeur
    bl affichageMess            @ display message
   
    @ division 
    mov r0,r3
    mov r1,r4
    bl division
    mov r0,r2                   @ quotient
    ldr r1,=sMessValeur                 
    bl conversion10S            @ call function with 2 parameter (r0,r1)
    ldr r0,iAdrszMessResult
    bl affichageMess            @ display message
    ldr r0,iAdrszMessDivision
    bl affichageMess            @ display message
    ldr r0,iAdrsMessValeur
    bl affichageMess            @ display message

    mov r0,r3                   @ remainder
    ldr r1,=sMessValeur                 
    bl conversion10S            @ call function with 2 parameter (r0,r1)
    ldr r0,iAdrszMessResult
    bl affichageMess            @ display message
    ldr r0,iAdrszMessReste
    bl affichageMess            @ display message
    ldr r0,iAdrsMessValeur
    bl affichageMess            @ display message
 
    mov r0, #0                  @ return code
    b 100f
error:
    ldr r0,iAdrszMessError
    bl affichageMess            @ call function with 1 parameter (r0)
    mov r0, #1                  @ return code
100: /* end of  program */
    mov r7, #EXIT               @ request to exit program
    swi 0                       @ perform the system call
iAdrsMessValeur: .int sMessValeur	
iAdrszMessResult: .int szMessResult
iAdrszMessError: .int szMessError
iAdrszMessAddition: .int szMessAddition
iAdrszMessSoustraction: .int szMessSoustraction
iAdrszMessMultiplication: .int szMessMultiplication
iAdrszMessDivision: .int szMessDivision
iAdrszMessReste: .int szMessReste
/******************************************************************/
/*     affichage des messages   avec calcul longueur              */ 
/******************************************************************/
/* r0 contient l adresse du message */
affichageMess:
    push {fp,lr}        /* save des  2 registres */ 
    push {r0,r1,r2,r7}  /* save des autres registres */
    mov r2,#0           /* compteur longueur */
1:                      /*calcul de la longueur */
    ldrb r1,[r0,r2]     /* recup octet position debut + indice */
    cmp r1,#0           /* si 0 c est fini */
    beq 1f
    add r2,r2,#1        /* sinon on ajoute 1 */
    b 1b
1:                      /* donc ici r2 contient la longueur du message */
    mov r1,r0           /* adresse du message en r1 */
    mov r0,#STDOUT      /* code pour écrire sur la sortie standard Linux */
    mov r7, #WRITE      /* code de l appel systeme 'write' */
    swi #0              /* appel systeme */
    pop {r0,r1,r2,r7}   /* restaur des autres registres */
    pop {fp,lr}         /* restaur des  2 registres */ 
    bx lr	        /* retour procedure */	
/***************************************************/
/*   conversion registre en décimal   signé  */
/***************************************************/
/* r0 contient le registre   */
/* r1 contient l adresse de la zone de conversion */
conversion10S:
    push {fp,lr}      /* save des  2 registres frame et retour */
    push {r0-r5}      /* save autres registres  */
    mov r2,r1         /* debut zone stockage */
    mov r5,#'+'       /* par defaut le signe est + */
    cmp r0,#0         /* nombre négatif ? */
    movlt r5,#'-'     /* oui le signe est - */
    mvnlt r0,r0       /* et inversion en valeur positive */
    addlt r0,#1
    mov r4,#10       /* longueur de la zone */
1:                   /* debut de boucle de conversion */
    bl divisionpar10 /* division  */
    add r1,#48       /* ajout de 48 au reste pour conversion ascii */	
    strb r1,[r2,r4]  /* stockage du byte en début de zone r5 + la position r4 */
    sub r4,r4,#1     /* position précedente */
    cmp r0,#0     
    bne 1b	     /* boucle si quotient different de zéro */
    strb r5,[r2,r4]  /* stockage du signe à la position courante */
    subs r4,r4,#1    /* position précedente */
    blt  100f        /* si r4 < 0  fin  */
                     /* sinon il faut completer le debut de la zone avec des blancs */
    mov r3,#' '      /* caractere espace */	
2:
    strb r3,[r2,r4]  /* stockage du byte  */
    subs r4,r4,#1    /* position précedente */
    bge 2b           /* boucle si r4 plus grand ou egal a zero */
100:                 /* fin standard de la fonction  */
    pop {r0-r5}      /*restaur des autres registres */
    pop {fp,lr}      /* restaur des  2 registres frame et retour  */
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
/******************************************************************/
/*     Conversion d une chaine en nombre stocké dans un registre  */ 
/******************************************************************/
/* r0 contient l adresse de la zone terminée par 0 ou 0A */
conversionAtoD:
    push {fp,lr}      /* save des  2 registres */ 
    push {r1-r7}      /* save des autres registres */
    mov r1,#0
    mov r2,#10        /* facteur */
    mov r3,#0         /* compteur */
    mov r4,r0         /* save de l adresse dans r4 */
    mov r6,#0         /* signe positif par defaut */
    mov r0,#0         /* initialisation à 0 */ 
1:                    /* boucle d élimination des blancs du debut */
    ldrb r5,[r4,r3]   /* chargement dans r5 de l octet situé au debut + la position */
    cmp r5,#0         /* fin de chaine -> fin routine */
    beq 100f
    cmp r5,#0x0A      /* fin de chaine -> fin routine */
    beq 100f
    cmp r5,#' '       /* blanc au début */
    bne 1f            /* non on continue */
    add r3,r3,#1      /* oui on boucle en avançant d un octet */
    b 1b
1:
    cmp r5,#'-'       /* premier caracteres est -    */
    moveq r6,#1       /* maj du registre r6 avec 1 */
    beq 3f            /* puis on avance à la position suivante */
2:                    /* debut de boucle de traitement des chiffres */
    cmp r5,#'0'       /* caractere n est pas un chiffre */
    blt 3f
    cmp r5,#'9'       /* caractere n est pas un chiffre */
    bgt 3f
                      /* caractère est un chiffre */
    sub r5,#48
    ldr r1,iMaxi      /*verifier le dépassement du registre  */  
    cmp r0,r1
    bgt 99f
    mul r0,r2,r0     /* multiplier par facteur */
    add r0,r5        /* ajout à r0 */
3:
    add r3,r3,#1     /* avance à la position suivante */
    ldrb r5,[r4,r3]  /* chargement de l octet */
    cmp r5,#0        /* fin de chaine -> fin routine */
    beq 4f
    cmp r5,#10       /* fin de chaine -> fin routine */
    beq 4f
    b 2b             /* boucler */ 
4:
    cmp r6,#1        /* test du registre r6 pour le signe */
    bne 100f
    mov r1,#-1
    mul r0,r1,r0    /* si negatif, on multiplie par -1 */
    b 100f
99:                 /* erreur de dépassement */
    ldr r1,=szMessErrDep
    bl   afficheerreur 
    mov r0,#0       /* en cas d erreur on retourne toujours zero */
100:
    pop {r1-r7}     /* restaur des autres registres */
    pop {fp,lr}     /* restaur des  2 registres */ 
    bx lr           /* retour procedure */	
/* constante programme */	
iMaxi: .int 1073741824	
szMessErrDep:  .asciz  "Nombre trop grand : dépassement de capacite de 32 bits. :\n"
.align 4
/*=============================================*/
/* division entiere non signée                */
/*============================================*/
division:
    /* r0 contains N */
    /* r1 contains D */
    /* r2 contains Q */
    /* r3 contains R */
    push {r4, lr}
    mov r2, #0              /* r2 ? 0 */
    mov r3, #0              /* r3 ? 0 */
    mov r4, #32             /* r4 ? 32 */
    b 2f
1:
    movs r0, r0, LSL #1    /* r0 ? r0 << 1 updating cpsr (sets C if 31st bit of r0 was 1) */
    adc r3, r3, r3         /* r3 ? r3 + r3 + C. This is equivalent to r3 ? (r3 << 1) + C */
 
    cmp r3, r1             /* compute r3 - r1 and update cpsr */
    subhs r3, r3, r1       /* if r3 >= r1 (C=1) then r3 ? r3 - r1 */
    adc r2, r2, r2         /* r2 ? r2 + r2 + C. This is equivalent to r2 ? (r2 << 1) + C */
2:
    subs r4, r4, #1        /* r4 ? r4 - 1 */
    bpl 1b                 /* if r4 >= 0 (N=0) then branch to .Lloop1 */
 
    pop {r4, lr}
    bx lr