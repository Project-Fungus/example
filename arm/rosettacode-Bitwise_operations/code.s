/* ARM assembly Raspberry PI  */
/*  program binarydigit.s   */
/* Constantes    */
.equ STDOUT, 1
.equ WRITE,  4
.equ EXIT,   1
/* Initialized data */
.data
szMessResultAnd: .asciz "Result of And : \n"
szMessResultOr: .asciz "Result of Or : \n"
szMessResultEor: .asciz "Result of Exclusif Or : \n"
szMessResultNot: .asciz "Result of Not : \n"
szMessResultLsl: .asciz "Result of left shift : \n"
szMessResultLsr: .asciz "Result of right shift : \n"
szMessResultAsr: .asciz "Result of Arithmetic right shift : \n"
szMessResultRor: .asciz "Result of rotate right : \n"
szMessResultRrx: .asciz "Result of rotate right with extend : \n"
szMessResultClear: .asciz "Result of Bit Clear : \n"

sMessAffBin: .ascii "Register value : "
sZoneBin: .space 36,' '
              .asciz "\n"

/*  code section */
.text
.global main 
main:                /* entry of program  */
    push {fp,lr}    /* save des  2 registres */
    ldr r0,iAdrszMessResultAnd
    bl affichageMess
    mov r0,#5
    and r0,#15
    bl affichage2
    ldr r0,iAdrszMessResultOr
    bl affichageMess
    mov r0,#5
    orr r0,#15
    bl affichage2
    ldr r0,iAdrszMessResultEor
    bl affichageMess
    mov r0,#5
    eor r0,#15
    bl affichage2
    ldr r0,iAdrszMessResultNot
    bl affichageMess
    mov r0,#5
    mvn r0,r0
    bl affichage2
    ldr r0,iAdrszMessResultLsl
    bl affichageMess
    mov r0,#5
    lsl r0,#1
    bl affichage2
    ldr r0,iAdrszMessResultLsr
    bl affichageMess
    mov r0,#5
    lsr r0,#1
    bl affichage2
    ldr r0,iAdrszMessResultAsr
    bl affichageMess
    mov r0,#-5
    bl affichage2
    mov r0,#-5
    asr r0,#1
    bl affichage2
    ldr r0,iAdrszMessResultRor
    bl affichageMess
    mov r0,#5
    ror r0,#1
    bl affichage2
    ldr r0,iAdrszMessResultRrx
    bl affichageMess
    mov r0,#5
    mov r1,#15
    rrx r0,r1
    bl affichage2
	ldr r0,iAdrszMessResultClear
    bl affichageMess
	mov r0,#5
    bic r0,#0b100     @  clear 3ieme bit
    bl affichage2
	bic r0,#4          @  clear 3ieme bit  ( 4 = 100 binary)
    bl affichage2

100:   /* standard end of the program */
    mov r0, #0                  @ return code
    pop {fp,lr}                 @restaur 2 registers
    mov r7, #EXIT              @ request to exit program
    swi 0                       @ perform the system call
iAdrszMessResultAnd:  .int szMessResultAnd
iAdrszMessResultOr:  .int szMessResultOr
iAdrszMessResultEor:  .int szMessResultEor
iAdrszMessResultNot:  .int szMessResultNot
iAdrszMessResultLsl:  .int szMessResultLsl
iAdrszMessResultLsr:  .int szMessResultLsr
iAdrszMessResultAsr:  .int szMessResultAsr
iAdrszMessResultRor:  .int szMessResultRor
iAdrszMessResultRrx:  .int szMessResultRrx
iAdrszMessResultClear:  .int szMessResultClear
/******************************************************************/
/*     register display in binary                              */ 
/******************************************************************/
/* r0 contains the register */
affichage2:
    push {r0,lr}     /* save  registers */  
    push {r1-r5} /* save others registers */
    mrs r5,cpsr  /* saves state register in r5 */
    ldr r1,iAdrsZoneBin
    mov r2,#0    @ read bit position counter
    mov r3,#0    @ position counter of the written character
1:               @ loop 
    lsls r0,#1    @ left shift  with flags
    movcc r4,#48  @ flag carry off   character '0'
    movcs r4,#49  @ flag carry on    character '1'
    strb r4,[r1,r3]   @ character ->   display zone
    add r2,r2,#1      @ + 1 read bit position counter
    add r3,r3,#1      @ + 1 position counter of the written character
    cmp r2,#8         @ 8 bits read
    addeq r3,r3,#1   @ + 1 position counter of the written character
    cmp r2,#16         @ etc
    addeq r3,r3,#1
    cmp r2,#24
    addeq r3,r3,#1
    cmp r2,#31        @ 32 bits shifted ?
    ble 1b           @  no -> loop

    ldr r0,iAdrsZoneMessBin   @ address of message result
    bl affichageMess           @ display result
    
100:
    msr cpsr,r5    /*restaur state register */
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
    mov r7, #WRITE             /* code call system write */
    swi #0                      /* call systeme */
    pop {r0,r1,r2,r7}     		/* restaur others registres */
    pop {fp,lr}    				/* restaur des  2 registres */ 
    bx lr	        			/* return  */