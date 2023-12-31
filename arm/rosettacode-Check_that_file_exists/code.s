/* ARM assembly Raspberry PI  */
/*  program verifFic.s   */

/* Constantes    */
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ WRITE,  4     @ Linux syscall
.equ OPEN,   5     @ Linux syscall
.equ CLOSE, 6     @ Linux syscall

.equ O_RDWR,	0x0002		/* open for reading and writing */

/*******************************************/
/* Fichier des macros                       */
/********************************************/
.include "../../ficmacros.s"

/* Initialized data */
.data
szMessFound1:     .asciz "File 1 found.\n"
szMessFound2:     .asciz "File 2 found.\n"
szMessNotFound1: .asciz "File 1 not found.\n"
szMessNotFound2: .asciz "File 2 not found.\n"
szMessNotAuth2:   .asciz "File 2 permission denied.\n"
szCarriageReturn: .asciz "\n"

/* areas strings  */
szFicName1:  .asciz "test1.txt"
szFicName2:  .asciz "/debian-binary"


/* UnInitialized data */
.bss 

/*  code section */
.text
.global main 
main:                /* entry of program  */
    push {fp,lr}    /* saves 2 registers */

    /*************************************
     open file 1
    ************************************/
    ldr r0,iAdrszFicName1    @ file name
    mov r1,#O_RDWR             @ flags    
    mov r2,#0                    @ mode 
    mov r7, #OPEN               @ call system OPEN 
    swi 0 
    cmp r0,#0    @ error ?
    ble 1f
    mov r1,r0    @ FD
    ldr r0,iAdrszMessFound1
    bl affichageMess
    @ close file
    mov r0,r1   @ Fd 
    mov r7, #CLOSE 
    swi 0 
    b 2f
1:
    ldr r0,iAdrszMessNotFound1
    bl affichageMess
2:
    /*************************************
     open file 2
    ************************************/
    ldr r0,iAdrszFicName2    @ file name 
    mov r1,#O_RDWR   @  flags    
    mov r2,#0         @ mode 
    mov r7, #OPEN    @ call system OPEN 
    swi 0 
    vidregtit verif
    cmp r0,#-13    @ permission denied 
    beq 4f
    cmp r0,#0    @ error ? 
    ble 3f
    mov r1,r0    @ FD
    ldr r0,iAdrszMessFound2
    bl affichageMess
    @ close file
    mov r0,r1   @ Fd 
    mov r7, #CLOSE 
    swi 0 
    b 100f
3:
    ldr r0,iAdrszMessNotFound2
    bl affichageMess
    b 100f
4:
    ldr r0,iAdrszMessNotAuth2
    bl affichageMess
100:   /* standard end of the program */
    mov r0, #0                  @ return code
    pop {fp,lr}                 @restaur 2 registers
    mov r7, #EXIT              @ request to exit program
    swi 0                       @ perform the system call
iAdrszFicName1:			.int szFicName1
iAdrszFicName2:			.int szFicName2
iAdrszMessFound1:		.int szMessFound1
iAdrszMessFound2:		.int szMessFound2
iAdrszMessNotFound1: 	.int szMessNotFound1
iAdrszMessNotFound2: 	.int szMessNotFound2
iAdrszMessNotAuth2:	.int szMessNotAuth2
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