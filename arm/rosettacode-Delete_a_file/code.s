/* ARM assembly Raspberry PI  */
/*  program deleteFic.s   */

/* REMARK 1 : this program use routines in a include file 
   see task Include a file language arm assembly 
   for the routine affichageMess conversion10 
   see at end of this program the instruction include */
/***************************************************************/
/* File Constantes  see task Include a file for arm assembly   */
/***************************************************************/
.include "../constantes.inc"

.equ RMDIR,  0x28
.equ UNLINK, 0xA
/******************************************/
/* Initialized data                       */
/******************************************/
.data
szMessDeleteDirOk:   .asciz "Delete directory Ok.\n"
szMessErrDeleteDir:  .asciz "Unable delete dir. \n"
szMessDeleteFileOk:  .asciz "Delete file Ok.\n"
szMessErrDeleteFile: .asciz "Unable delete file. \n"

szNameDir:          .asciz "Docs"
szNameFile:         .asciz "input.txt"

/******************************************/
/* UnInitialized data                     */
/******************************************/
.bss 
/******************************************/
/*  code section                          */
/******************************************/
.text
.global main 
main:                           @ entry of program 
    @ delete file
    ldr r0,iAdrszNameFile       @ file name

    mov r7,#UNLINK              @ code call system delete file
    svc #0                      @ call systeme 
    cmp r0,#0                   @ error ?
    blt 99f
    ldr r0,iAdrszMessDeleteFileOk @ delete file OK 
    bl affichageMess
                                @ delete directory
    ldr r0,iAdrszNameDir        @ directory name
    mov r7, #RMDIR              @ code call system delete directory 
    swi #0                      @ call systeme 
    cmp r0,#0                   @ error ?
    blt 98f
    ldr r0,iAdrszMessDeleteDirOk @ display  message ok directory
    bl affichageMess
                                @ end Ok
    b 100f

98:                             @ display error message delete directory 
    ldr r0,iAdrszMessErrDeleteDir
    bl affichageMess
    b 100f
99:                             @ display error message delete file 
    ldr r0,iAdrszMessErrDeleteFile
    bl affichageMess
    b 100f
100:                            @ standard end of the program 
    mov r0, #0                  @ return code
    mov r7, #EXIT               @ request to exit program
    swi 0                       @ perform the system call
iAdrszMessDeleteDirOk:        .int szMessDeleteDirOk
iAdrszMessErrDeleteDir:       .int szMessErrDeleteDir
iAdrszMessDeleteFileOk:       .int szMessDeleteFileOk
iAdrszNameFile:               .int szNameFile
iAdrszMessErrDeleteFile:      .int szMessErrDeleteFile
iAdrszNameDir:                .int szNameDir
/***************************************************/
/*      ROUTINES INCLUDE                 */
/***************************************************/
.include "../affichage.inc"