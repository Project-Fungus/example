/* ARM assembly Raspberry PI  */
/*  program sha1-1.s   */
/* use with library openssl */
/* link with gcc option  -lcrypto -lssl  */

/* REMARK 1 : this program use routines in a include file 
   see task Include a file language arm assembly 
   for the routine affichageMess conversion10 
   see at end of this program the instruction include */

/* for constantes see task include a file in arm assembly */
/************************************/
/* Constantes                       */
/************************************/
.include "../constantes.inc"

.equ SHA_DIGEST_LENGTH, 20

/*******************************************/
/* Fichier des macros                       */
/********************************************/
.include "../../ficmacros.s"

/*********************************/
/* Initialized data              */
/*********************************/
.data
szMessRosetta:        .asciz "Rosetta Code"
                      .equ LGMESSROSETTA, . - szMessRosetta - 1
szCarriageReturn:     .asciz "\n"
szMessSup64:          .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                      .ascii "abcdefghijklmnopqrstuvwxyz"
                      .asciz "1234567890AZERTYUIOP"
                      .equ LGMESSSUP64, . - szMessSup64 - 1
szMessTest2:          .asciz "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
                      .equ LGMESSTEST2,  . - szMessTest2 - 1

/*********************************/
/* UnInitialized data            */
/*********************************/
.bss
.align 4
szMessResult:              .skip 24
sZoneConv:                 .skip 24
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                                      @ entry of program 

    ldr r0,iAdrszMessRosetta
    mov r1,#LGMESSROSETTA
    ldr r2,iAdrszMessResult
    bl SHA1                                @ appel fonction openssl 
    ldr r0,iAdrszMessResult
    bl displaySHA1

100:                                       @ standard end of the program 
    mov r0, #0                             @ return code
    mov r7, #EXIT                          @ request to exit program
    svc #0                                 @ perform the system call
 
iAdrszMessRosetta:        .int szMessRosetta
iAdrszCarriageReturn:     .int szCarriageReturn
iAdrszMessResult:         .int szMessResult
iAdrsZoneConv:            .int sZoneConv
iAdrszMessSup64:          .int szMessSup64
iAdrszMessTest2:          .int szMessTest2
/******************************************************************/
/*     display hash  SHA1                         */ 
/******************************************************************/
/* r0 contains the address of hash  */
displaySHA1:
    push {r1-r3,lr}                  @ save  registres
    mov r3,r0
    mov r2,#0
1:
    ldr r0,[r3,r2,lsl #2]            @ load 4 bytes
    rev r0,r0                        @ reverse bytes
    ldr r1,iAdrsZoneConv
    bl conversion16                  @ conversion hexa
    ldr r0,iAdrsZoneConv
    bl affichageMess
    add r2,r2,#1
    cmp r2,#SHA_DIGEST_LENGTH / 4
    blt 1b                           @ and loop
    ldr r0,iAdrszCarriageReturn
    bl affichageMess                 @ display message
100:
    pop {r1-r3,lr}                   @ restaur registers
    bx lr                            @ return  
/***************************************************/
/*      ROUTINES INCLUDE                 */
/***************************************************/
.include "../affichage.inc"

/* ARM assembly Raspberry PI  */
/*  program sha1.s   */

/* REMARK 1 : this program use routines in a include file 
   see task Include a file language arm assembly 
   for the routine affichageMess conversion10 
   see at end of this program the instruction include */
/* for constantes see task include a file in arm assembly */
/************************************/
/* Constantes                       */
/************************************/
.include "../constantes.inc"

.equ SHA_DIGEST_LENGTH, 20

.include "../../ficmacros.s"

/*********************************/
/* Initialized data              */
/*********************************/
.data
szMessRosetta:        .asciz "Rosetta Code"
szMessTest1:           .asciz "abc" 
szMessSup64:           .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                       .ascii "abcdefghijklmnopqrstuvwxyz"
                       .asciz "1234567890AZERTYUIOP"
szMessTest2:           .asciz "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
szMessFinPgm:          .asciz "Program End ok.\n"
szMessResult:          .asciz "Rosetta Code => "
szCarriageReturn:   .asciz "\n"

/* array constantes Hi */
tbConstHi:           .int 0x67452301       @ H0
                     .int 0xEFCDAB89       @ H1
                     .int 0x98BADCFE       @ H2
                     .int 0x10325476       @ H3
                     .int 0xC3D2E1F0       @ H4
/* array constantes Kt */
tbConstKt:           .int 0x5A827999
                     .int 0x6ED9EBA1
                     .int 0x8F1BBCDC
                     .int 0xCA62C1D6


/*********************************/
/* UnInitialized data            */
/*********************************/
.bss
.align 4
iNbBlocs:                    .skip 4
sZoneConv:                   .skip 24
sZoneResult:                 .skip 24
sZoneTrav:                   .skip 1000
tbH:                         .skip 4 * 5         @ 5 variables H
tbW:                         .skip 4 * 80        @ 80 words W
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                                      @ entry of program 
                      
    ldr r0,iAdrszMessRosetta
    //ldr r0,iAdrszMessTest1
    //ldr r0,iAdrszMessTest2
    //ldr r0,iAdrszMessSup64
    bl computeSHA1                         @ call routine SHA1

    ldr r0,iAdrszMessResult
    bl affichageMess                       @ display message

    ldr r0, iAdrsZoneResult
    bl displaySHA1

    ldr r0,iAdrszMessFinPgm
    bl affichageMess                       @ display message
 

100:                                       @ standard end of the program 
    mov r0, #0                             @ return code
    mov r7, #EXIT                          @ request to exit program
    svc #0                                 @ perform the system call
 
iAdrszCarriageReturn:     .int szCarriageReturn
iAdrszMessResult:         .int szMessResult
iAdrszMessRosetta:        .int szMessRosetta
iAdrszMessTest1:          .int szMessTest1
iAdrszMessTest2:          .int szMessTest2
iAdrsZoneTrav:            .int sZoneTrav
iAdrsZoneConv:            .int sZoneConv
iAdrszMessFinPgm:         .int szMessFinPgm
iAdrszMessSup64:          .int szMessSup64
/******************************************************************/
/*     compute SHA1                         */ 
/******************************************************************/
/* r0 contains the address of the message */
computeSHA1:
    push {r1-r12,lr}         @ save  registres
    ldr r1,iAdrsZoneTrav
    mov r2,#0                @ counter length 
debCopy:                     @ copy string in work area
    ldrb r3,[r0,r2]
    strb r3,[r1,r2]
    cmp r3,#0                    
    addne r2,r2,#1
    bne debCopy
    lsl r6,r2,#3             @ initial message length in bits 
    mov r3,#0b10000000       @ add bit 1 at end of string
    strb r3,[r1,r2]
    add r2,r2,#1             @ length in bytes
    lsl r4,r2,#3             @ length in bits
    mov r3,#0
addZeroes:
    lsr r5,r2,#6
    lsl r5,r5,#6
    sub r5,r2,r5
    cmp r5,#56
    beq storeLength          @ yes -> end add
    strb r3,[r1,r2]          @ add zero at message end
    add r2,#1                @ increment lenght bytes 
    add r4,#8                @ increment length in bits
    b addZeroes
storeLength:
    add r2,#4                @ add four bytes
    rev r6,r6                @ inversion bits initials message length
    str r6,[r1,r2]           @ and store at end
    ldr r7,iAdrtbConstHi     @ constantes H address
    ldr r4,iAdrtbH           @ start area H
    mov r5,#0
loopConst:                   @ init array H with start constantes
    ldr r6,[r7,r5,lsl #2]    @ load constante
    str r6,[r4,r5,lsl #2]    @ and store
    add r5,r5,#1
    cmp r5,#5
    blt loopConst
                             @ split into block of 64 bytes
    add r2,#4                @  TODO : à revoir
    lsr r4,r2,#6             @ blocks number
    ldr r0,iAdriNbBlocs
    str r4,[r0]              @ save block maxi
    mov r7,#0                @ n° de block et r1 contient adresse zone de travail
loopBlock:                   @ begin loop of each block of 64 bytes
    mov r0,r7
    bl inversion             @ inversion each word because little indian
    ldr r3,iAdrtbW           @ working area W address
    mov r6,#0                @ indice t
                             /* r2  address begin each block */
    ldr r1,iAdrsZoneTrav
    add r2,r1,r7,lsl #6      @  compute block begin  indice * 4 * 16
    //vidregtit avantloop
    //mov r0,r2
    //vidmemtit  verifBloc r0 10
loopPrep:                    @ loop for expand 80 words
    cmp r6,#15               @ 
    bgt expand1
    ldr r0,[r2,r6,lsl #2]    @ load byte message
    str r0,[r3,r6,lsl #2]    @ store in first 16 block 
    b expandEnd
expand1:
    sub r8,r6,#3
    ldr r9,[r3,r8,lsl #2]
    sub r8,r6,#8
    ldr r10,[r3,r8,lsl #2]
    eor r9,r9,r10
    sub r8,r6,#14
    ldr r10,[r3,r8,lsl #2]
    eor r9,r9,r10
    sub r8,r6,#16
    ldr r10,[r3,r8,lsl #2]
    eor r9,r9,r10
    ror r9,r9,#31

    str r9,[r3,r6,lsl #2] 
expandEnd:
    add r6,r6,#1
    cmp r6,#80                 @ 80 words ?
    blt loopPrep               @ and loop
    /* COMPUTING THE MESSAGE DIGEST */
    /* r1  area H constantes address */
    /* r3  working area W address  */
    /* r5  address constantes K   */
    /* r6  counter t */
    /* r7  block counter */
    /* r8  a, r9 b, r10 c, r11 d, r12 e */
    //ldr r0,iAdrtbW
    //vidmemtit  verifW80 r0 20
                               @ init variable a b c d e
    ldr r0,iAdrtbH
    ldr r8,[r0]
    ldr r9,[r0,#4]
    ldr r10,[r0,#8]
    ldr r11,[r0,#12]
    ldr r12,[r0,#16]
    
    ldr r1,iAdrtbConstHi
    ldr r5,iAdrtbConstKt
    mov r6,#0
loop80T:                       @ begin loop 80 t
    cmp r6,#19
    bgt T2
    ldr r0,[r5]                @ load constantes k0
    and r2,r9,r10              @ b and c
    mvn r4,r9                  @ not b
    and r4,r4,r11              @ and d
    orr r2,r2,r4
    b T_fin
T2:
    cmp r6,#39             
    bgt T3
    ldr r0,[r5,#4]             @ load constantes k1
    eor r2,r9,r10
    eor r2,r11
    b T_fin
T3:
    cmp r6,#59             
    bgt T4
    ldr r0,[r5,#8]             @ load constantes k2
    and r2,r9,r10
    and r4,r9,r11
    orr r2,r4
    and r4,r10,r11
    orr r2,r4
    b T_fin
T4:
    ldr r0,[r5,#12]            @ load constantes k3
    eor r2,r9,r10
    eor r2,r11
    b T_fin
T_fin:
    ror r4,r8,#27            @ left rotate a to 5
    add r2,r4
    add r2,r12
    ldr r4,[r3,r6,lsl #2]    @ Wt
    add r2,r4
    add r2,r0                @ Kt
    mov r12,r11              @ e = d
    mov r11,r10              @ d = c
    ror r10,r9,#2            @ c
    mov r9,r8                @ b = a
    mov r8,r2                @ nouveau a

    add r6,r6,#1             @ increment t
    cmp r6,#80
    blt loop80T
                             @ other bloc
    add r7,#1                @ increment block
    ldr r0,iAdriNbBlocs
    ldr r4,[r0]              @ restaur maxi block
    cmp r7,r4                @ maxi ?
    bge End
                             @ End block
    ldr r0,iAdrtbH           @ start area H
    ldr r3,[r0]
    add r3,r8
    str r3,[r0]              @ store a in H0
    ldr r3,[r0,#4]
    add r3,r9
    str r3,[r0,#4]           @ store b in H1
    ldr r3,[r0,#8]
    add r3,r10
    str r3,[r0,#8]           @ store c in H2
    ldr r3,[r0,#12]
    add r3,r11
    str r3,[r0,#12]          @ store d in H3
    ldr r3,[r0,#16]
    add r3,r12
    str r3,[r0,#16]          @ store e in H4
    b loopBlock              @  loop

End:
                             @ compute final result
    ldr r0,iAdrtbH           @ start area H
    ldr r2,iAdrsZoneResult
    ldr r1,[r0]
    add r1,r8
    rev r1,r1
    str r1,[r2]
    ldr r1,[r0,#4]
    add r1,r9
    rev r1,r1
    str r1,[r2,#4]
    ldr r1,[r0,#8]
    add r1,r10
    rev r1,r1
    str r1,[r2,#8]
    ldr r1,[r0,#12]
    add r1,r11
    rev r1,r1
    str r1,[r2,#12]
    ldr r1,[r0,#16]
    add r1,r12
    rev r1,r1
    str r1,[r2,#16]
    mov r0,#0                    @ routine OK
100:
    pop {r1-r12,lr}              @ restaur registers
    bx lr                        @ return  
iAdrtbConstHi:            .int tbConstHi
iAdrtbConstKt:            .int tbConstKt
iAdrtbH:                  .int tbH
iAdrtbW:                  .int tbW
iAdrsZoneResult:          .int sZoneResult
iAdriNbBlocs:             .int iNbBlocs
/******************************************************************/
/*     inversion des mots de 32 bits d un bloc                    */ 
/******************************************************************/
/* r0 contains N° block   */
inversion:
    push {r1-r3,lr}                                 @ save registers 
    ldr r1,iAdrsZoneTrav
    add r1,r0,lsl #6                                @ debut du bloc
    mov r2,#0
1:                                                  @ start loop
    ldr r3,[r1,r2,lsl #2]
    rev r3,r3
    str r3,[r1,r2,lsl #2]
    add r2,r2,#1
    cmp r2,#16
    blt 1b
100:
    pop {r1-r3,lr}                                  @ restaur registres 
    bx lr                                           @return
/******************************************************************/
/*     display hash  SHA1                         */ 
/******************************************************************/
/* r0 contains the address of hash  */
displaySHA1:
    push {r1-r3,lr}                @ save  registres
    mov r3,r0
    mov r2,#0
1:
    ldr r0,[r3,r2,lsl #2]          @ load 4 bytes
    rev r0,r0                      @ reverse bytes
    ldr r1,iAdrsZoneConv
    bl conversion16                @ conversion hexa
    ldr r0,iAdrsZoneConv
    bl affichageMess
    add r2,r2,#1
    cmp r2,#SHA_DIGEST_LENGTH / 4
    blt 1b                         @ and loop
    ldr r0,iAdrszCarriageReturn
    bl affichageMess               @ display message
100:
    pop {r1-r3,lr}                 @ restaur registers
    bx lr                          @ return  
/***************************************************/
/*      ROUTINES INCLUDE                           */
/***************************************************/
.include "../affichage.inc"


Rosetta Code => 48C98F7E5A6E736D790AB740DFC3F51A61ABE2B5
Program End ok.