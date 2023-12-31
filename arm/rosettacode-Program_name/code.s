/* ARM assembly Raspberry PI  */
/*  program namepgm.s   */
/* Constantes    */
.equ STDOUT, 1
.equ WRITE,  4
.equ EXIT,   1
/* Initialized data */
.data
szMessage: .asciz "Program : "       @ 
szRetourLigne: .asciz "\n"


.text
.global main 
main:	
    push {fp,lr}    /* save des  2 registres */
    add fp,sp,#8    /* fp <- adresse début */
    ldr r0, iAdrszMessage         @ adresse of message
    bl affichageMess            @ call function
    ldr r0,[fp,#4]                 @ recup name of program in command line
    bl affichageMess            @ call function
    ldr r0, iAdrszRetourLigne         @ adresse of message
    bl affichageMess            @ call function
 
 /* fin standard du programme */
    mov r0, #0                  @ return code
    pop {fp,lr}                 @restaur des  2 registres 
    mov r7, #EXIT              @ request to exit program
    swi 0                       @ perform the system call
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
        mov r7, #WRITE                  /* code de l appel systeme "write" */
        swi #0                      /* appel systeme */
	pop {r0,r1,r2,r7}     /* restaur des autres registres */
	pop {fp,lr}    /* restaur des  2 registres */ 
        bx lr	        /* retour procedure */