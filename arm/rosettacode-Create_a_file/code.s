/* ARM assembly Raspberry PI  */
/*  program createDirFic.s   */

/* Constantes    */
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall   exit Program
.equ WRITE,  4     @ Linux syscall  write FILE
.equ MKDIR, 0x27  @ Linux Syscal  create directory
.equ CHGDIR, 0xC  @ Linux Syscal  change directory
.equ CREATE, 0x8 @ Linux Syscal  create file
.equ CLOSE,   0x6  @ Linux Syscal  close file
/* Initialized data */
.data
szMessCreateDirOk: .asciz "Create directory Ok.\n"
szMessErrCreateDir: .asciz "Unable create directory. \n"
szMessErrChangeDir: .asciz "Unable change directory. \n"
szMessCreateFileOk: .asciz "Create file Ok.\n"
szMessErrCreateFile: .asciz "Unable create file. \n"
szMessErrCloseFile: .asciz "Unable close file. \n"

szNameDir: .asciz "Dir1"
szNameFile:  .asciz "file1.txt"


/* UnInitialized data */
.bss 

/*  code section */
.text
.global main 
main:                @ entry of program 
    push {fp,lr}        @ saves registers 
	@ create directory
    ldr r0,iAdrszNameDir   @ directory name
    mov r1,#0775                 @ mode (in octal zero is important !!)
    mov r7, #MKDIR             @ code call system create directory 
    swi #0                      @ call systeme 
    cmp r0,#0             @ error ?
    bne 99f

   @ display  message ok directory
    ldr r0,iAdrszMessCreateDirOk
    bl affichageMess
    @ change directory
    ldr r0,iAdrszNameDir   @ directory name
    mov r7, #CHGDIR             @ code call system change directory 
    swi #0                      @ call systeme 
    cmp r0,#0     @ error ?
    bne 98f
    @ create file
    ldr r0,iAdrszNameFile   @ directory name
    mov r1,#0755                 @ mode (in octal zero is important !!)
    mov r2,#0
    mov r7,#CREATE             @ code call system create file
    swi #0                      @ call systeme 
    cmp r0,#0             @ error ?
    ble 97f
    mov r8,r0     @ save File Descriptor 
    @ display  message ok file
    ldr r0,iAdrszMessCreateFileOk
    bl affichageMess

    @ close file
    mov r0,r8       @ Fd 
    mov r7, #CLOSE @ close file
    swi 0 
    cmp r0,#0
    bne 96f
    @ end Ok
    b 100f
96:
    @ display error message close file 
    ldr r0,iAdrszMessErrCloseFile
    bl affichageMess
    b 100f
97:
    @ display error message create file 
    ldr r0,iAdrszMessErrCreateFile
    bl affichageMess
    b 100f
98:
    @ display error message change directory 
    ldr r0,iAdrszMessErrChangeDir
    bl affichageMess
    b 100f
99: 
    @ display error message create directory 
    ldr r0,iAdrszMessErrCreateDir
    bl affichageMess
    b 100f
100:   @ standard end of the program 
    mov r0, #0                  @ return code
    pop {fp,lr}                 @restaur 2 registers
    mov r7, #EXIT              @ request to exit program
    swi 0                       @ perform the system call
iAdrszMessCreateDirOk:		.int szMessCreateDirOk
iAdrszMessErrCreateDir:	.int szMessErrCreateDir
iAdrszMessErrChangeDir:	.int szMessErrChangeDir
iAdrszMessCreateFileOk:	.int szMessCreateFileOk
iAdrszNameFile:				.int szNameFile
iAdrszMessErrCreateFile:	.int szMessErrCreateFile
iAdrszMessErrCloseFile:	.int szMessErrCloseFile

iAdrszNameDir:				.int szNameDir
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