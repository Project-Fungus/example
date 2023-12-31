/* ARM assembly Raspberry PI  */
/*  program comparNumber.s   */

/* Constantes    */
.equ BUFFERSIZE,   100
.equ STDIN,  0     @ Linux input console
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ READ,   3     @ Linux syscall
.equ WRITE,  4     @ Linux syscall
/* Initialized data */
.data
szMessNum1: .asciz "Enter number 1 : \n"
szMessNum2: .asciz "Enter number 2: \n"
szMessEqual: .asciz "Number 1 and number 2 are equals.\n"
szMessSmall: .asciz "Number 1 smaller than number 2.\n"
szMessLarge: .asciz "Number 1 larger than number 2.\n"
szCarriageReturn:  .asciz "\n"

/* UnInitialized data */
.bss 
sBuffer:    .skip    BUFFERSIZE

/*  code section */
.text
.global main 
main:                /* entry of program  */
    push {fp,lr}    /* saves 2 registers */
    ldr r0,iAdrszMessNum1 @ message address
    ldr r1,iAdrsBuffer   @ buffer address 
    mov r2,#BUFFERSIZE
    bl numberEntry
    mov r5,r0               @ save number 1 -> r5
    ldr r0,iAdrszMessNum2  @ message address
	ldr r1,iAdrsBuffer   @ buffer address 
	mov r2,#BUFFERSIZE
    bl numberEntry
	cmp r5,r0         @ compar number 1 and number 2
    beq equal
	blt small
	bgt large
	@ never !!
	b 100f
equal:
    ldr r0,iAdrszMessEqual    @ message address 
	b aff
small:
    ldr r0,iAdrszMessSmall    @ message address 
	b aff
large:
    ldr r0,iAdrszMessLarge    @ message address 
	b aff
aff:
    bl affichageMess      @ display message
 
    
100:   /* standard end of the program */
    mov r0, #0                  @ return code
    pop {fp,lr}                 @restaur 2 registers
    mov r7, #EXIT              @ request to exit program
    swi 0                       @ perform the system call

iAdrszMessNum1:  .int szMessNum1
iAdrszMessNum2: .int  szMessNum2
iAdrszMessEqual: .int szMessEqual
iAdrszMessSmall: .int szMessSmall
iAdrszMessLarge: .int szMessLarge
iAdrsBuffer:   .int  sBuffer
iAdrszCarriageReturn:  .int  szCarriageReturn
/******************************************************************/
/*     Number entry with display message and conversion number    */ 
/******************************************************************/
/* r0 contains message address */
/* r1 contains buffer address 
/* r2 contains buffersize     */
/* r0 return a number          */
numberEntry:
    push {fp,lr}         @ save  registres */ 
    push {r4,r6,r7}          @ save others registers 
    mov r4,r1              @ save buffer address -> r4
    bl affichageMess
    mov r0,#STDIN         @ Linux input console
    //ldr r1,iAdrsBuffer   @ buffer address 
    //mov r2,#BUFFERSIZE   @ buffer size 
    mov r7, #READ         @ request to read datas
    swi 0                  @ call system
    mov r1,r4              @ buffer address 
    mov r2,#0                @ end of string
    strb r2,[r1,r0]         @ store byte at the end of input string (r0
    @ 
    mov r0,r4              @ buffer address
    bl conversionAtoD    @ conversion string in number in r0
	
100:
    pop {r4,r6,r7}     		/* restaur others registers */
    pop {fp,lr}    				/* restaur des  2 registres */ 
    bx lr	        			/* return  */
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

 /******************************************************************/
/*     Convert a string to a number stored in a registry          */ 
/******************************************************************/
/* r0 contains the address of the area terminated by 0 or 0A */
/* r0 returns a number                           */
conversionAtoD:
    push {fp,lr}         @ save 2 registers 
    push {r1-r7}         @ save others registers 
    mov r1,#0
    mov r2,#10           @ factor 
    mov r3,#0            @ counter 
    mov r4,r0            @ save address string -> r4 
    mov r6,#0            @ positive sign by default 
    mov r0,#0            @ initialization to 0 
1:     /* early space elimination loop */
    ldrb r5,[r4,r3]     @ loading in r5 of the byte located at the beginning + the position 
    cmp r5,#0            @ end of string -> end routine
    beq 100f
    cmp r5,#0x0A        @ end of string -> end routine
    beq 100f
    cmp r5,#' '          @ space ? 
    addeq r3,r3,#1      @ yes we loop by moving one byte 
    beq 1b
    cmp r5,#'-'          @ first character is -    
    moveq r6,#1         @  1 -> r6
    beq 3f              @ then move on to the next position 
2:   /* beginning of digit processing loop */
    cmp r5,#'0'          @ character is not a number 
    blt 3f
    cmp r5,#'9'          @ character is not a number
    bgt 3f
    /* character is a number */
    sub r5,#48
    ldr r1,iMaxi       @ check the overflow of the register    
    cmp r0,r1
    bgt 99f            @ overflow error
    mul r0,r2,r0         @ multiply par factor 10 
    add r0,r5            @ add to  r0 
3:
    add r3,r3,#1         @ advance to the next position 
    ldrb r5,[r4,r3]     @ load byte 
    cmp r5,#0            @ end of string -> end routine
    beq 4f
    cmp r5,#0x0A            @ end of string -> end routine
    beq 4f
    b 2b                 @ loop 
4:
    cmp r6,#1            @ test r6 for sign 
    moveq r1,#-1
    muleq r0,r1,r0       @ if negatif, multiply par -1 
    b 100f
99:  /* overflow error */
    ldr r0,=szMessErrDep
    bl   affichageMess
    mov r0,#0      @ return  zero  if error
100:
    pop {r1-r7}          @ restaur other registers 
    pop {fp,lr}          @ restaur   2 registers 
    bx lr                 @return procedure 
/* constante program */	
iMaxi: .int 1073741824	
szMessErrDep:  .asciz  "Too large: overflow 32 bits.\n"