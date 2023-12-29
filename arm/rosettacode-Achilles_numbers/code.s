/* ARM assembly Raspberry PI  */
/*  program achilleNumber.s   */

 /* REMARK 1 : this program use routines in a include file 
   see task Include a file language arm assembly 
   for the routine affichageMess conversion10 
   see at end of this program the instruction include */
/* for constantes see task include a file in arm assembly */
/************************************/
/* Constantes                       */
/************************************/
.include "../constantes.inc"
.equ NBFACT,    33
.equ MAXI,      50
.equ MAXI1,     20
.equ MAXI2,     1000000

/*********************************/
/* Initialized data              */
/*********************************/
.data
szMessNumber:       .asciz " @ "
szCarriageReturn:   .asciz "\n"
szErrorGen:         .asciz "Program error !!!\n"
szMessPrime:        .asciz "This number is prime.\n"
szMessTitAchille:   .asciz "First 50 Achilles Numbers:\n"
szMessTitStrong:    .asciz "First 20 Strong Achilles Numbers:\n"
szMessDigitsCounter: .asciz "Numbers with @ digits : @ \n"
/*********************************/
/* UnInitialized data            */
/*********************************/
.bss  
sZoneConv:           .skip 24
tbZoneDecom:         .skip 8 * NBFACT          // factor 4 bytes, number of each factor 4 bytes
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                             @ entry of program 
    ldr r0,iAdrszMessTitAchille
    bl affichageMess
    mov r4,#1                      @ start number
    mov r5,#0                      @ total counter
    mov r6,#0                      @ line display counter
1: 
    mov r0,r4
    bl controlAchille
    cmp r0,#0                      @ achille number ?
    beq 2f                         @ no
    mov r0,r4
    ldr r1,iAdrsZoneConv
    bl conversion10                @ call décimal conversion
    ldr r0,iAdrszMessNumber
    ldr r1,iAdrsZoneConv           @ insert conversion in message
    bl strInsertAtCharInc
    bl affichageMess               @ display message
    add r5,r5,#1                   @ increment counter
    add r6,r6,#1                   @ increment indice line display
    cmp r6,#10                     @ if = 10  new line
    bne 2f
    mov r6,#0
    ldr r0,iAdrszCarriageReturn
    bl affichageMess 
2:
    add r4,r4,#1                   @ increment number
    cmp r5,#MAXI
    blt 1b                         @ and loop
    
    ldr r0,iAdrszMessTitStrong
    bl affichageMess
    mov r4,#1                      @ start number
    mov r5,#0                      @ total counter
    mov r6,#0

3: 
    mov r0,r4
    bl controlAchille
    cmp r0,#0
    beq 4f
    mov r0,r4
    bl computeTotient
    bl controlAchille
    cmp r0,#0
    beq 4f
    mov r0,r4
    ldr r1,iAdrsZoneConv
    bl conversion10                  @ call décimal conversion
    ldr r0,iAdrszMessNumber
    ldr r1,iAdrsZoneConv             @ insert conversion in message
    bl strInsertAtCharInc
    bl affichageMess                 @ display message
    add r5,r5,#1
    add r6,r6,#1
    cmp r6,#10
    bne 4f
    mov r6,#0
    ldr r0,iAdrszCarriageReturn
    bl affichageMess 
4:
    add r4,r4,#1
    cmp r5,#MAXI1
    blt 3b
    
    ldr r3,icstMaxi2
    mov r4,#1                      @ start number
    mov r6,#0                      @ total counter 2 digits
    mov r7,#0                      @ total counter 3 digits
    mov r8,#0                      @ total counter 4 digits
    mov r9,#0                      @ total counter 5 digits
    mov r10,#0                     @ total counter 6 digits
5: 
    mov r0,r4
    bl controlAchille
    cmp r0,#0
    beq 6f
    
    mov r0,r4
    ldr r1,iAdrsZoneConv
    bl conversion10             @ call décimal conversion r0 return digit number
    cmp r0,#6
    addeq r10,r10,#1
    beq 6f
    cmp r0,#5
    addeq r9,r9,#1
    beq 6f
    cmp r0,#4
    addeq r8,r8,#1
    beq 6f
    cmp r0,#3
    addeq r7,r7,#1
    beq 6f
    cmp r0,#2
    addeq r6,r6,#1
    beq 6f
6:
    
    add r4,r4,#1
    cmp r4,r3
    blt 5b
    mov r0,#2
    mov r1,r6
    bl displayCounter
    mov r0,#3
    mov r1,r7
    bl displayCounter
    mov r0,#4
    mov r1,r8
    bl displayCounter
    mov r0,#5
    mov r1,r9
    bl displayCounter
    mov r0,#6
    mov r1,r10
    bl displayCounter
    b 100f
98:
    ldr r0,iAdrszErrorGen
    bl affichageMess 
100:                              @ standard end of the program 
    mov r0, #0                    @ return code
    mov r7, #EXIT                 @ request to exit program
    svc #0                        @ perform the system call
iAdrszCarriageReturn:    .int szCarriageReturn
iAdrszErrorGen:          .int szErrorGen
iAdrsZoneConv:           .int sZoneConv  
iAdrtbZoneDecom:         .int tbZoneDecom
iAdrszMessNumber:        .int szMessNumber
iAdrszMessTitAchille:    .int szMessTitAchille
iAdrszMessTitStrong:     .int szMessTitStrong
icstMaxi2:               .int MAXI2
/******************************************************************/
/*     display digit counter                        */ 
/******************************************************************/
/* r0 contains limit  */
/* r1 contains counter */
displayCounter:
    push {r1-r3,lr}            @ save  registers 
    mov r2,r1
    ldr r1,iAdrsZoneConv
    bl conversion10             @ call décimal conversion
    ldr r0,iAdrszMessDigitsCounter
    ldr r1,iAdrsZoneConv        @ insert conversion in message
    bl strInsertAtCharInc
    mov r3,r0
    mov r0,r2
    ldr r1,iAdrsZoneConv
    bl conversion10             @ call décimal conversion
    mov r0,r3
    ldr r1,iAdrsZoneConv        @ insert conversion in message
    bl strInsertAtCharInc
    bl affichageMess            @ display message
100:
    pop {r1-r3,pc}             @ restaur registers
iAdrszMessDigitsCounter:   .int szMessDigitsCounter
/******************************************************************/
/*     control if number is Achille number                        */ 
/******************************************************************/
/* r0 contains number  */
/* r0 return 0 if not else return 1 */
controlAchille:
    push {r1-r4,lr}            @ save  registers 
    mov r4,r0
    ldr r1,iAdrtbZoneDecom
    bl decompFact               @ factor decomposition
    cmp r0,#-1
    beq 98f                     @ error ?
    cmp r0,#1                   @ one only factor ?
    moveq r0,#0
    beq 100f
    mov r1,r0
    ldr r0,iAdrtbZoneDecom
    mov r2,r4
    bl controlDivisor
    b 100f
98:
    ldr r0,iAdrszErrorGen
    bl affichageMess 
100:
    pop {r1-r4,pc}             @ restaur registers
/******************************************************************/
/*     control divisors function                         */ 
/******************************************************************/
/* r0 contains address of divisors area */
/* r1 contains the number of area items  */
/* r2 contains number  */
controlDivisor:
    push {r1-r10,lr}            @ save  registers 
    cmp r1,#0
    moveq r0,#0
    beq 100f
    mov r6,r1                   @ factors number
    mov r8,r2                   @ save number
    mov r9,#0                   @ indice
    mov r4,r0                   @ save area address
    add r5,r4,r9,lsl #3         @ compute address first factor
    ldr r7,[r5,#4]              @ load first exposant of factor
    add r2,r9,#1
1:
    add r5,r4,r2,lsl #3         @ compute address next factor
    ldr r3,[r5,#4]              @ load exposant of factor
    cmp r3,r7                   @ factor exposant <> ?
    bne 2f                      @ yes -> end verif
    add r2,r2,#1                @ increment indice
    cmp r2,r6                   @ factor maxi ?
    blt 1b                      @ no -> loop
    mov r0,#0
    b 100f                      @ all exposants are equals
2:
    mov r10,r2                  @ save indice
21:
    movlt r2,r7                 @ if r3 < r7 -> inversion
    movlt r7,r3
    movlt r3,r2                 @ r7 is the smaller exposant
    mov r0,r3
    mov r1,r7                   @ r7 < r3 
    bl computePgcd
    cmp r0,#1
    beq 23f                     @ no commun multiple -> ne peux donc pas etre une puissance
22:
    add r10,r10,#1              @ increment indice
    cmp r10,r6                  @ factor maxi ?
    movge r0,#0
    bge 100f                    @ yes -> all exposants are multiples to smaller
    add r5,r4,r10,lsl #3
    ldr r3,[r5,#4]              @ load exposant of next factor
    cmp r3,r7
    beq 22b                     @ for next
    b 21b                       @ for compare the 2 exposants
    
23:
    mov r9,#0                   @ indice
3:
    add r5,r4,r9,lsl #3
    ldr r7,[r5]                 @ load factor
    mul r1,r7,r7                @ factor square
    mov r0,r8                   @ number
    bl division
    cmp r3,#0                   @ remainder null ?
    movne r0,#0
    bne 100f
    
    add r9,#1                   @ other factor
    cmp r9,r6                   @ factors maxi ?
    blt 3b
    mov r0,#1                   @ achille number ok
100:
    pop {r1-r10,lr}             @ restaur registers
    bx lr                       @ return
    
/******************************************/
/* calcul du pgcd                         */
/*****************************************/
/* r0 number one  */
/* r1 number two  */
/* r0 result return */
computePgcd:
    push {r2,lr}       @ save registers
1:
    cmp r0,#0
    ble 2f
    cmp r1,r0
    movgt r2,r0
    movgt r0,r1
    movgt r1,r2
    sub r0,r1
    b 1b
2:    
    mov r0,r1         
    pop {r2,pc}       @ restaur registers
/******************************************************************/
/*     compute totient of number                                  */ 
/******************************************************************/
/* r0 contains number  */
computeTotient:
    push {r1-r5,lr}           @ save  registers 
    mov r4,r0                 @ totient
    mov r5,r0                 @ save number
    mov r1,#0                 @ for first divisor
1:                            @ begin loop
    mul r3,r1,r1              @ compute square
    cmp r3,r5                 @ compare number
    bgt 4f                    @ end 
    add r1,r1,#2              @ next divisor
    mov r0,r5
    bl division      
    cmp r3,#0                 @ remainder null ?
    bne 3f
2:                            @ begin loop 2
    mov r0,r5
    bl division
    cmp r3,#0
    moveq r5,r2               @ new value = quotient
    beq 2b
 
    mov r0,r4                 @ totient
    bl division
    sub r4,r4,r2              @ compute new totient
3:
    cmp r1,#2                 @ first divisor ?
    moveq r1,#1               @ divisor = 1
    b 1b                      @ and loop
4:
    cmp r5,#1                 @ final value > 1
    ble 5f
    mov r0,r4                 @ totient
    mov r1,r5                 @ divide by value
    bl division
    sub r4,r4,r2              @ compute new totient
5:
 
    mov r0,r4
100:
    pop {r1-r5,pc}             @ restaur registers

/******************************************************************/
/*     factor decomposition                                               */ 
/******************************************************************/
/* r0 contains number */
/* r1 contains address of divisors area */
/* r0 return divisors items in table */
decompFact:
    push {r1-r8,lr}            @ save  registers
    mov r5,r1
    mov r8,r0                  @ save number
    bl isPrime                 @ prime ?
    cmp r0,#1
    beq 98f                    @ yes is prime
    mov r4,#0                  @ raz indice
    mov r1,#2                  @ first divisor
    mov r6,#0                  @ previous divisor
    mov r7,#0                  @ number of same divisors
2:
    mov r0,r8                  @ dividende
    bl division                @  r1 divisor r2 quotient r3 remainder
    cmp r3,#0
    bne 5f                     @ if remainder <> zero  -> no divisor
    mov r8,r2                  @ else quotient -> new dividende
    cmp r1,r6                  @ same divisor ?
    beq 4f                     @ yes
    cmp r6,#0                  @ no but is the first divisor ?
    beq 3f                     @ yes 
    str r6,[r5,r4,lsl #2]      @ else store in the table
    add r4,r4,#1               @ and increment counter
    str r7,[r5,r4,lsl #2]      @ store counter
    add r4,r4,#1               @ next item
    mov r7,#0                  @ and raz counter
3:
    mov r6,r1                  @ new divisor
4:
    add r7,r7,#1               @ increment counter
    b 7f                       @ and loop
    
    /* not divisor -> increment next divisor */
5:
    cmp r1,#2                  @ if divisor = 2 -> add 1 
    addeq r1,#1
    addne r1,#2                @ else add 2
    b 2b
    
    /* divisor -> test if new dividende is prime */
7: 
    mov r3,r1                  @ save divisor
    cmp r8,#1                  @ dividende = 1 ? -> end
    beq 10f
    mov r0,r8                  @ new dividende is prime ?
    mov r1,#0
    bl isPrime                 @ the new dividende is prime ?
    cmp r0,#1
    bne 10f                    @ the new dividende is not prime

    cmp r8,r6                  @ else dividende is same divisor ?
    beq 9f                     @ yes
    cmp r6,#0                  @ no but is the first divisor ?
    beq 8f                     @ yes it is a first
    str r6,[r5,r4,lsl #2]      @ else store in table
    add r4,r4,#1               @ and increment counter
    str r7,[r5,r4,lsl #2]      @ and store counter 
    add r4,r4,#1               @ next item
8:
    mov r6,r8                  @ new dividende -> divisor prec
    mov r7,#0                  @ and raz counter
9:
    add r7,r7,#1               @ increment counter
    b 11f
    
10:
    mov r1,r3                  @ current divisor = new divisor
    cmp r1,r8                  @ current divisor  > new dividende ?
    ble 2b                     @ no -> loop
    
    /* end decomposition */ 
11:
    str r6,[r5,r4,lsl #2]      @ store last divisor
    add r4,r4,#1
    str r7,[r5,r4,lsl #2]      @ and store last number of same divisors
    add r4,r4,#1
    lsr r0,r4,#1               @ return number of table items
    mov r3,#0
    str r3,[r5,r4,lsl #2]      @ store zéro in last table item
    add r4,r4,#1
    str r3,[r5,r4,lsl #2]      @ and zero in counter same divisor
    b 100f

    
98: 
    //ldr r0,iAdrszMessPrime
    //bl   affichageMess
    mov r0,#1                   @ return code
    b 100f
99:
    ldr r0,iAdrszErrorGen
    bl   affichageMess
    mov r0,#-1                  @ error code
    b 100f
100:
    pop {r1-r8,lr}              @ restaur registers
    bx lr
iAdrszMessPrime:           .int szMessPrime

/***************************************************/
/*   check if a number is prime              */
/***************************************************/
/* r0 contains the number            */
/* r0 return 1 if prime  0 else */
@2147483647
@4294967297
@131071
isPrime:
    push {r1-r6,lr}    @ save registers 
    cmp r0,#0
    beq 90f
    cmp r0,#17
    bhi 1f
    cmp r0,#3
    bls 80f            @ for 1,2,3 return prime
    cmp r0,#5
    beq 80f            @ for 5 return prime
    cmp r0,#7
    beq 80f            @ for 7 return prime
    cmp r0,#11
    beq 80f            @ for 11 return prime
    cmp r0,#13
    beq 80f            @ for 13 return prime
    cmp r0,#17
    beq 80f            @ for 17 return prime
1:
    tst r0,#1          @ even ?
    beq 90f            @ yes -> not prime
    mov r2,r0          @ save number
    sub r1,r0,#1       @ exposant n - 1
    mov r0,#3          @ base
    bl moduloPuR32     @ compute base power n - 1 modulo n
    cmp r0,#1
    bne 90f            @ if <> 1  -> not prime
 
    mov r0,#5
    bl moduloPuR32
    cmp r0,#1
    bne 90f
    
    mov r0,#7
    bl moduloPuR32
    cmp r0,#1
    bne 90f
    
    mov r0,#11
    bl moduloPuR32
    cmp r0,#1
    bne 90f
    
    mov r0,#13
    bl moduloPuR32
    cmp r0,#1
    bne 90f
    
    mov r0,#17
    bl moduloPuR32
    cmp r0,#1
    bne 90f
80:
    mov r0,#1        @ is prime
    b 100f
90:
    mov r0,#0        @ no prime
100:                 @ fin standard de la fonction 
    pop {r1-r6,lr}   @ restaur des registres
    bx lr            @ retour de la fonction en utilisant lr 
/********************************************************/
/*   Calcul modulo de b puissance e modulo m  */
/*    Exemple 4 puissance 13 modulo 497 = 445         */
/*                                             */
/********************************************************/
/* r0  nombre  */
/* r1 exposant */
/* r2 modulo   */
/* r0 return result  */
moduloPuR32:
    push {r1-r7,lr}    @ save registers  
    cmp r0,#0          @ verif <> zero 
    beq 100f
    cmp r2,#0          @ verif <> zero 
    beq 100f           @ TODO: vérifier les cas erreur
1:
    mov r4,r2          @ save modulo
    mov r5,r1          @ save exposant 
    mov r6,r0          @ save base
    mov r3,#1          @ start result

    mov r1,#0          @ division de r0,r1 par r2
    bl division32R
    mov r6,r2          @ base <- remainder
2:
    tst r5,#1          @  exposant even or odd
    beq 3f
    umull r0,r1,r6,r3
    mov r2,r4
    bl division32R
    mov r3,r2          @ result <- remainder
3:
    umull r0,r1,r6,r6
    mov r2,r4
    bl division32R
    mov r6,r2          @ base <- remainder

    lsr r5,#1          @ left shift 1 bit
    cmp r5,#0          @ end ?
    bne 2b
    mov r0,r3
100:                   @ fin standard de la fonction
    pop {r1-r7,lr}     @ restaur des registres
    bx lr              @ retour de la fonction en utilisant lr    

/***************************************************/
/*   division number 64 bits in 2 registers by number 32 bits */
/***************************************************/
/* r0 contains lower part dividende   */
/* r1 contains upper part dividende   */
/* r2 contains divisor   */
/* r0 return lower part quotient    */
/* r1 return upper part quotient    */
/* r2 return remainder               */
division32R:
    push {r3-r9,lr}    @ save registers
    mov r6,#0          @ init upper upper part remainder  !!
    mov r7,r1          @ init upper part remainder with upper part dividende
    mov r8,r0          @ init lower part remainder with lower part dividende
    mov r9,#0          @ upper part quotient 
    mov r4,#0          @ lower part quotient
    mov r5,#32         @ bits number
1:                     @ begin loop
    lsl r6,#1          @ shift upper upper part remainder
    lsls r7,#1         @ shift upper  part remainder
    orrcs r6,#1        
    lsls r8,#1         @ shift lower  part remainder
    orrcs r7,#1
    lsls r4,#1         @ shift lower part quotient
    lsl r9,#1          @ shift upper part quotient
    orrcs r9,#1
                       @ divisor sustract  upper  part remainder
    subs r7,r2
    sbcs  r6,#0        @ and substract carry
    bmi 2f             @ négative ?
    
                       @ positive or equal
    orr r4,#1          @ 1 -> right bit quotient
    b 3f
2:                     @ negative 
    orr r4,#0          @ 0 -> right bit quotient
    adds r7,r2         @ and restaur remainder
    adc  r6,#0 
3:
    subs r5,#1         @ decrement bit size 
    bgt 1b             @ end ?
    mov r0,r4          @ lower part quotient
    mov r1,r9          @ upper part quotient
    mov r2,r7          @ remainder
100:                   @ function end
    pop {r3-r9,lr}     @ restaur registers
    bx lr  


/***************************************************/
/*      ROUTINES INCLUDE                           */
/***************************************************/
.include "../affichage.inc"

First 50 Achilles Numbers:
 72           108          200          288          392          432          500          648          675          800
 864          968          972          1125         1152         1323         1352         1372         1568         1800
 1944         2000         2312         2592         2700         2888         3087         3200         3267         3456
 3528         3872         3888         4000         4232         4500         4563         4608         5000         5292
 5324         5400         5408         5488         6075         6125         6272         6728         6912         7200
First 20 Strong Achilles Numbers:
 500          864          1944         2000         2592         3456         5000         10125        10368        12348
 12500        16875        19652        19773        30375        31104        32000        33275        37044        40500
Numbers with 2           digits : 1
Numbers with 3           digits : 12
Numbers with 4           digits : 47
Numbers with 5           digits : 192
Numbers with 6           digits : 664