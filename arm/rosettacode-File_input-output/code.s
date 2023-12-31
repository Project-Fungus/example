/* ARM assembly Raspberry PI  */
/*  program readwrtfile.s   */

/*********************************************/
/*constantes                                */
/********************************************/
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ READ,   3
.equ WRITE,  4
.equ OPEN,   5
.equ CLOSE,  6
.equ CREATE,  8
/*  file */
.equ O_RDWR,	0x0002		@ open for reading and writing 

.equ TAILLEBUF,  1000
/*********************************/
/* Initialized data              */
/*********************************/
.data
szMessErreur: .asciz "Erreur ouverture fichier input.\n"
szMessErreur4: .asciz "Erreur création fichier output.\n"
szMessErreur1: .asciz "Erreur fermeture fichier.\n"
szMessErreur2: .asciz "Erreur lecture fichier.\n"
szMessErreur3: .asciz "Erreur d'écriture dans fichier de sortie.\n"
szRetourligne: .asciz  "\n"
szMessErr: .ascii	"Error code : "
sDeci: .space 15,' '
         .asciz "\n"

szNameFileInput:	.asciz "input.txt"
szNameFileOutput:	.asciz "output.txt"

/*******************************************/
/* DONNEES NON INITIALISEES                */
/*******************************************/ 
.bss
sBuffer:  .skip TAILLEBUF 

/**********************************************/
/* -- Code section                            */
/**********************************************/
.text            
.global main    
main:
    push {fp,lr}    /* save registers */

    ldr r0,iAdrszNameFileInput   @ file name
    mov r1,#O_RDWR                   @  flags   
    mov r2,#0                         @ mode 
    mov r7,#OPEN                     @ call system OPEN
    swi #0 
    cmp r0,#0        @ open error ?
    ble erreur
    mov r8,r0               @ save File Descriptor
    ldr r1,iAdrsBuffer   @ buffer address 
    mov r2,#TAILLEBUF     @ buffer size
    mov r7, #READ          @ call system  READ
    swi 0 
    cmp r0,#0            @ read error ?
    ble erreur2
    mov r2,r0            @ length read characters

    /* close imput file */
    mov r0,r8     @ Fd  
    mov r7, #CLOSE      @ call system CLOSE
    swi 0 
    cmp r0,#0            @ close error ?
    blt erreur1

    @ create output file 
    ldr r0,iAdrszNameFileOutput   @ file name
    ldr r1,iFicMask1                 @ flags 
    mov r7, #CREATE                  @ call system create file
    swi 0 
    cmp r0,#0                         @ create error ?
    ble erreur4
    mov r0,r8                       @ file descriptor
    ldr r1,iAdrsBuffer
    @ et r2 contains the length to write 
    mov r7, #WRITE                 @ select system call 'write'
    swi #0                        @ perform the system call 
    cmp r0,#0                      @ error write ?
    blt erreur3

    @ close output file 
    mov r0,r8    @ Fd  fichier 
    mov r7, #CLOSE    @  call system CLOSE
    swi #0 
    cmp r0,#0      @ error close ?
    blt erreur1
    mov r0,#0     @ return code OK
    b 100f
erreur:
    ldr r1,iAdrszMessErreur 
    bl   afficheerreur   
    mov r0,#1       @ error return code
    b 100f
erreur1:	
    ldr r1,iAdrszMessErreur1   
    bl   afficheerreur  
    mov r0,#1       @ error return code
    b 100f
erreur2:
    ldr r1,iAdrszMessErreur2   
    bl   afficheerreur  
    mov r0,#1       @ error return code
    b 100f
erreur3:
    ldr r1,iAdrszMessErreur3   
    bl   afficheerreur  
    mov r0,#1       @ error return code
    b 100f
erreur4:
    ldr r1,iAdrszMessErreur4
    bl   afficheerreur   
    mov r0,#1       @ error return code
    b 100f

100:		@ end program
    pop {fp,lr}   /* restaur des  2 registres */
    mov r7, #EXIT /* appel fonction systeme pour terminer */
    swi 0 
iAdrszNameFileInput:	.int szNameFileInput
iAdrszNameFileOutput:	.int szNameFileOutput
iAdrszMessErreur:		.int szMessErreur
iAdrszMessErreur1:		.int szMessErreur1
iAdrszMessErreur2:		.int szMessErreur2
iAdrszMessErreur3:		.int szMessErreur3
iAdrszMessErreur4:		.int szMessErreur4
iAdrsBuffer:				.int sBuffer
iFicMask1: 				.octa 0644
/******************************************************************/
/*     display text with size calculation                         */ 
/******************************************************************/
/* r0 contains the address of the message */
affichageMess:
    push {r0,r1,r2,r7,lr}    			/* save  registres */ 
    mov r2,#0   				/* counter length */
1:      /* loop length calculation */
    ldrb r1,[r0,r2]  			/* read octet start position + index */
    cmp r1,#0       			/* if 0 its over */
    addne r2,r2,#1   			/* else add 1 in the length */
    bne 1b          			/* and loop */
                                /* so here r2 contains the length of the message */
    mov r1,r0        			/* address message in r1 */
    mov r0,#STDOUT      		/* code to write to the standard output Linux */
    mov r7, #WRITE             /* code call system "write" */
    swi #0                      /* call systeme */
    pop {r0,r1,r2,r7,lr}    	/* restaur des  2 registres */ 
    bx lr	        			/* return  */
/***************************************************/
/*   display error message                         */
/***************************************************/
/* r0 contains error code  r1  address error message */
afficheerreur:
   push {r1-r2,lr}    @ save registers
    mov r2,r0         @ save error code
    mov r0,r1         @ address error message
    bl affichageMess   @ display error message
    mov r0,r2         @ error code
    ldr r1,iAdrsDeci    @ result address
    bl conversion10S
    ldr r0,iAdrszMessErr @ display error code
    bl affichageMess
    pop {r1-r2,lr}    @ restaur registers 
    bx lr              @ return function
iAdrszMessErr:   .int szMessErr
iAdrsDeci:		.int sDeci

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
    bl divisionPar10R 
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
/*   division for 10 fast unsigned                 */
/***************************************************/
@ r0 contient le dividende
@ r0 retourne le quotient
@ r1 retourne le reste
divisionPar10R:
    push {r2,lr}         @ save  registers
    sub r1, r0, #10        @ calcul de r0 - 10 
    sub r0, r0, r0, lsr #2  @ calcul de r0 - (r0 /4)
    add r0, r0, r0, lsr #4  @ calcul de (r0-(r0/4))+ ((r0-(r0/4))/16
    add r0, r0, r0, lsr #8  @ etc ...
    add r0, r0, r0, lsr #16
    mov r0, r0, lsr #3
    add r2, r0, r0, asl #2
    subs r1, r1, r2, asl #1    @ calcul (N-10) - (N/10)*10
    addpl r0, r0, #1          @ regul quotient
    addmi r1, r1, #10         @ regul reste
    pop {r2,lr}
    bx lr