/* ARM assembly Raspberry PI  */
/*  program adrvar.s   */

/* Constantes    */
.equ STDOUT, 1
.equ WRITE,  4
.equ EXIT,   1
/* Initialized data */
.data
szMessage:      .asciz "Hello. \n "       @ message
szRetourLigne:  .asciz "\n"
iValDeb:        .int 5      @ value 5 in array of 4 bytes
/* No Initialized data */
.bss
iValeur:     .skip  4     @ reserve 4 bytes in memory

.text
.global main 
main:	
        ldr r0,=szMessage          @ adresse of message  short program
	bl affichageMess            @ call function
	                                @  or
	ldr r0,iAdrszMessage         @ adresse of message big program (size code > 4K)
        bl affichageMess            @ call function
	
	ldr r1,=iValDeb              @ adresse of variable -> r1  short program
	ldr r0,[r1]                    @ value of iValdeb  -> r0
	ldr r1,iAdriValDeb           @ adresse of variable -> r1  big program
	ldr r0,[r1]                    @ value of iValdeb  -> r0

	
	/* set variables  */
	ldr r1,=iValeur               @ adresse of variable -> r1  short program
	str r0,[r1]                     @ value of r0 ->  iValeur
	ldr r1,iAdriValeur           @ adresse of variable -> r1  big program
	str r0,[r1]                     @ value of r0 ->  iValeur
 
 
 /* end of  program */
    mov r0, #0                  @ return code
    mov r7, #EXIT              @ request to exit program
    swi 0                       @ perform the system call
iAdriValDeb:  .int iValDeb	
iAdriValeur:  .int iValeur	
iAdrszMessage: .int szMessage
iAdrszRetourLigne: .int szRetourLigne	
/******************************************************************/
/*     affichage des messages   avec calcul longueur              */ 
/******************************************************************/
/* r0 contient l adresse du message */
affichageMess:
	push {fp,lr}    /* save des  2 registres */ 
	push {r0,r1,r2,r7}    /* save des autres registres */
	mov r2,#0   /* compteur longueur */
1:	      /*calcul de la longueur */
    ldrb r1,[r0,r2]  /* recup octet position debut + indice */
	cmp r1,#0       /* si 0 c est fini */
	beq 1f
	add r2,r2,#1   /* sinon on ajoute 1 */
	b 1b
1:	/* donc ici r2 contient la longueur du message */
	mov r1,r0        /* adresse du message en r1 */
	mov r0,#STDOUT      /* code pour écrire sur la sortie standard Linux */
    mov r7, #WRITE                  /* code de l appel systeme 'write' */
    swi #0                      /* appel systeme */
	pop {r0,r1,r2,r7}     /* restaur des autres registres */
	pop {fp,lr}    /* restaur des  2 registres */ 
    bx lr	        /* retour procedure */