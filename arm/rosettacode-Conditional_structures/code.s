/* ARM assembly Raspberry PI  */
/*  program condstr.s   */

/* Constantes    */
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ WRITE,  4     @ Linux syscall
/* Initialized data */
.data
szMessTest1: .asciz "The test 1 is equal.\n"
szMessTest1N: .asciz "The test 1 is not equal.\n"
szMessTest2: .asciz "The test 2 is equal.\n"
szMessTest2N: .asciz "The test 2 is not equal.\n"
szMessTest3: .asciz "The test 3 is <.\n"
szMessTest3N: .asciz "The test 3 is >.\n"
szMessTest4: .asciz "The test 4 is <=.\n"
szMessTest4N: .asciz "The test 4 is >.\n"
szMessTest5: .asciz "The test 5 is negative.\n"
szMessTest5N: .asciz "The test 5 is positive ou equal 0.\n"
szMessTest6: .asciz "Test 6 : carry is off.\n"
szMessTest6N: .asciz "Test 6 : carry is set.\n"
szMessTest7: .asciz "Test 7 : no overflow.\n"
szMessTest7N: .asciz "Test 7 : overflow.\n"
szMessTest8: .asciz "Test 8 : then.\n"
szMessTest8N: .asciz "Test 8 : else.\n"

/* UnInitialized data */
.bss 

/*  code section */
.text
.global main 
main:                /* entry of program  */
    push {fp,lr}    /* saves 2 registers */

    @ test equal zero, not equal zero 
    @movs r1,#0      @ comments
    movs r1,#1          @  @ s --> flags   and uncomments
    ldreq r0,iAdrszMessTest1
    ldrne r0,iAdrszMessTest1N
    bl affichageMess
	
    @ test equal 5, not equal 5 
    @mov r1,#5
    mov r1,#10
    cmp r1,#5
    ldreq r0,iAdrszMessTest2
    ldrne r0,iAdrszMessTest2N
    bl affichageMess
	
    @ test < 5,  > 5  SIGNED
    mov r1,#-10
    @mov r1,#10
    cmp r1,#5
    ldrlt r0,iAdrszMessTest3
    ldrgt r0,iAdrszMessTest3N
    bl affichageMess
	
    @ test < 5,  > 5  UNSIGNED
    @mov r1,#-10
    mov r1,#2
    cmp r1,#5
    ldrls r0,iAdrszMessTest4
    ldrhi r0,iAdrszMessTest4N
    bl affichageMess
	
    @ test < 0,  > 0 
    @movs r1,#-10
    movs r1,#2     @ s --> flags
    ldrmi r0,iAdrszMessTest5
    ldrpl r0,iAdrszMessTest5N
    bl affichageMess
	
    @ carry off carry on
    @mov r1,#-10     @ for carry set
    @mov r1,#10  @ for carry off
    mov r1,#(2<<30) - 1   @ for carry off
    adds r1,#20    @ s --> flags
    ldrcc r0,iAdrszMessTest6    @ carry clear
    ldrcs r0,iAdrszMessTest6N   @ carry set
    bl affichageMess

    @ overflow off overflow on
    @mov r1,#-10     @ for not overflow 
    @mov r1,#10  @ for not overflow
    mov r1,#(2<<30) - 1  @ for overflow 
    adds r1,#20    @ s --> flags
    ldrvc r0,iAdrszMessTest7    @ overflow off
    ldrvs r0,iAdrszMessTest7N   @ overflow on
    bl affichageMess

    @ other if then else
    mov r1,#5  @ for then
    @mov r1,#20  @ for else
    cmp r1,#10   
    ble 1f         @ less or equal 
    @bge 1f      @ greather or equal
    @else
    ldr r0,iAdrszMessTest8N    @ overflow off
    bl affichageMess
    b 2f
1:   @ then
   ldr r0,iAdrszMessTest8    @ overflow off
    bl affichageMess
2:
 
100:   /* standard end of the program */
    mov r0, #0                  @ return code
    pop {fp,lr}                 @restaur 2 registers
    mov r7, #EXIT              @ request to exit program
    swi 0                       @ perform the system call
iAdrszMessTest1:		.int szMessTest1
iAdrszMessTest1N:		.int szMessTest1N
iAdrszMessTest2:		.int szMessTest2
iAdrszMessTest2N:		.int szMessTest2N
iAdrszMessTest3:		.int szMessTest3
iAdrszMessTest3N:		.int szMessTest3N
iAdrszMessTest4:		.int szMessTest4
iAdrszMessTest4N:		.int szMessTest4N
iAdrszMessTest5:		.int szMessTest5
iAdrszMessTest5N:		.int szMessTest5N
iAdrszMessTest6:		.int szMessTest6
iAdrszMessTest6N:		.int szMessTest6N
iAdrszMessTest7:		.int szMessTest7
iAdrszMessTest7N:		.int szMessTest7N
iAdrszMessTest8:		.int szMessTest8
iAdrszMessTest8N:		.int szMessTest8N
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