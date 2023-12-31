/* ARM assembly Raspberry PI  */
/*  program logicoper.s   */
/* Constantes    */
.equ STDOUT, 1
.equ WRITE,  4
.equ EXIT,   1
/* Initialized data */
.data
szMessResultAnd:   .asciz "Result of And : \n"
szMessResultOr:    .asciz "Result of Or : \n"
szMessResultEor:   .asciz "Result of Exclusive Or : \n"
szMessResultNot:   .asciz "Result of Not : \n"
szMessResultClear: .asciz "Result of Bit Clear : \n"

sMessAffBin: .ascii "Register value : "
sZoneBin:    .space 36,' '
             .asciz "\n"

/* code section */
.text
.global main 
main:                /* entry of program  */
    push {fp,lr}     /* save 2 registers */

    mov r0,#0b1100      @ binary value 1
    mov r1,#0b0110      @ binary value 2
    bl logicfunc

100:   @ standard end of the program 
    mov r0,#0                   @ return code
    pop {fp,lr}                 @ restore 2 registers
    mov r7,#EXIT                @ request to exit program
    swi 0                       @ perform the system call

/******************************************************************/
/*     logics functions                              */ 
/******************************************************************/
/* r0 contains the first value */
/* r1 contains the second value */
logicfunc:
    push {r2,lr}                     @ save  registers 
    mov r2,r0                        @ save value 1 in r2 
    ldr r0,iAdrszMessResultAnd       @ and
    bl affichageMess
    mov r0,r2                        @ load value 1 in r0
    and r0,r1
    bl affichage2
    ldr r0,iAdrszMessResultOr        @ or
    bl affichageMess
    mov r0,r2
    orr r0,r1
    bl affichage2
    ldr r0,iAdrszMessResultEor       @ exclusive or
    bl affichageMess
    mov r0,r2
    eor r0,r1
    bl affichage2
    ldr r0,iAdrszMessResultNot       @ not
    bl affichageMess
    mov r0,r2
    mvn r0,r1
    bl affichage2
    ldr r0,iAdrszMessResultClear     @ bit clear
    bl affichageMess
    mov r0,r2
    bic r0,r1
    bl affichage2
100:
    pop {r2,lr}                      @ restore registers 
    bx lr	
iAdrszMessResultAnd:    .int szMessResultAnd
iAdrszMessResultOr:     .int szMessResultOr
iAdrszMessResultEor:    .int szMessResultEor
iAdrszMessResultNot:    .int szMessResultNot
iAdrszMessResultClear:  .int szMessResultClear
/******************************************************************/
/*     register display in binary                              */ 
/******************************************************************/
/* r0 contains the register */
affichage2:
    push {r0,lr}     /* save registers */  
    push {r1-r5}     /* save other registers */
    mrs r5,cpsr      /* saves state register in r5 */
    ldr r1,iAdrsZoneBin
    mov r2,#0         @ read bit position counter
    mov r3,#0         @ position counter of the written character
1:                @ loop 
    lsls r0,#1        @ left shift  with flags
    movcc r4,#48      @ flag carry off   character '0'
    movcs r4,#49      @ flag carry on    character '1'
    strb r4,[r1,r3]   @ character ->   display zone
    add r2,r2,#1      @ + 1 read bit position counter
    add r3,r3,#1      @ + 1 position counter of the written character
    cmp r2,#8         @ 8 bits read
    addeq r3,r3,#1    @ + 1 position counter of the written character
    cmp r2,#16        @ etc
    addeq r3,r3,#1
    cmp r2,#24
    addeq r3,r3,#1
    cmp r2,#31        @ 32 bits shifted ?
    ble 1b            @ no -> loop

    ldr r0,iAdrsZoneMessBin    @ address of message result
    bl affichageMess           @ display result
    
100:
    msr cpsr,r5    /* restore state register */
    pop {r1-r5}    /* restore other registers */
    pop {r0,lr}
    bx lr	
iAdrsZoneBin: .int sZoneBin	   
iAdrsZoneMessBin: .int sMessAffBin

/******************************************************************/
/*     display text with size calculation                         */ 
/******************************************************************/
/* r0 contains the address of the message */
affichageMess:
    push {fp,lr}    			/* save registers */ 
    push {r0,r1,r2,r7}    		/* save others registers */
    mov r2,#0   				/* counter length */
1:      	            /* loop length calculation */
    ldrb r1,[r0,r2]  			/* read byte start position + index */
    cmp r1,#0       			/* if 0 it's over */
    addne r2,r2,#1   			/* else add 1 to the length */
    bne 1b          			/* and loop */
                                /* so here r2 contains the length of the message */
    mov r1,r0        			/* address message in r1 */
    mov r0,#STDOUT      		/* code to write to the standard output */
    mov r7,#WRITE               /* "write" system call */
    swi #0                      /* system call */
    pop {r0,r1,r2,r7}     		/* restore other registers */
    pop {fp,lr}    				/* restore 2 registers */ 
    bx lr	        			/* return */