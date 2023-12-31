/* ARM assembly Raspberry PI  */
/*  program inputText.s   */

/* Constantes    */
.equ BUFFERSIZE,   100
.equ STDIN,  0     @ Linux input console
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ READ,   3     @ Linux syscall
.equ WRITE,  4     @ Linux syscall
/* Initialized data */
.data
szMessDeb: .asciz "Enter text : \n"
szMessNum: .asciz "Enter number : \n"
szCarriageReturn:  .asciz "\n"

/* UnInitialized data */
.bss 
sBuffer:    .skip    BUFFERSIZE

/*  code section */
.text
.global main 
main:                /* entry of program  */
    push {fp,lr}    /* saves 2 registers */
    ldr r0,iAdrszMessDeb
    bl affichageMess
    mov r0,#STDIN         @ Linux input console
    ldr r1,iAdrsBuffer   @ buffer address 
    mov r2,#BUFFERSIZE   @ buffer size 
    mov r7, #READ         @ request to read datas
    swi 0                  @ call system
    ldr r1,iAdrsBuffer    @ buffer address 
    mov r2,#0                @ end of string
    strb r2,[r1,r0]         @ store byte at the end of input string (r0 contains number of characters)

    ldr r0,iAdrsBuffer    @ buffer address 
    bl affichageMess
    ldr r0,iAdrszCarriageReturn   
    bl affichageMess

    ldr r0,iAdrszMessNum
    bl affichageMess
    mov r0,#STDIN         @ Linux input console
    ldr r1,iAdrsBuffer   @ buffer address 
    mov r2,#BUFFERSIZE   @ buffer size 
    mov r7, #READ         @ request to read datas
    swi 0                  @ call system
    ldr r1,iAdrsBuffer    @ buffer address 
    mov r2,#0                @ end of string
    strb r2,[r1,r0]         @ store byte at the end of input string (r0
    @ 
    ldr r0,iAdrsBuffer    @ buffer address
    bl conversionAtoD    @ conversion string in number in r0
    
100:   /* standard end of the program */
    mov r0, #0                  @ return code
    pop {fp,lr}                 @restaur 2 registers
    mov r7, #EXIT              @ request to exit program
    swi 0                       @ perform the system call

iAdrszMessDeb:  .int szMessDeb
iAdrszMessNum: .int  szMessNum
iAdrsBuffer:   .int  sBuffer
iAdrszCarriageReturn:  .int  szCarriageReturn
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