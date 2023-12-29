/* ARM assembly Raspberry PI  */
/*  program abbrAuto.s   */
/* store list of day in a file listDays.txt*/
/* and run the program  abbrAuto listDays.txt */

/* REMARK 1 : this program use routines in a include file 
   see task Include a file language arm assembly 
   for the routine affichageMess conversion10 
   see at end of this program the instruction include */
/* for constantes see task include a file in arm assembly */
/************************************/
/* Constantes                       */
/************************************/
.include "../constantes.inc"

.equ STDIN,  0     @ Linux input console
.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ READ,   3     @ Linux syscall
.equ WRITE,  4     @ Linux syscall
.equ OPEN,   5     @ Linux syscall
.equ CLOSE,  6     @ Linux syscall

.equ O_RDWR,    0x0002        @ open for reading and writing

.equ BUFFERSIZE,   10000
.equ NBMAXIDAYS, 7

/*********************************/
/* Initialized data              */
/*********************************/
.data
szMessTitre:            .asciz "Nom du fichier : "
szCarriageReturn:      .asciz "\n"
szMessErreur:          .asciz "Error detected.\n"
szMessErrBuffer:       .asciz "buffer size too less !!"
szSpace:               .asciz " "
/*********************************/
/* UnInitialized data            */
/*********************************/
.bss
.align 4
sZoneConv:      .skip 24
iAdrFicName:    .skip 4
iTabAdrDays:    .skip 4 * NBMAXIDAYS 
iTabAdrDays2:   .skip 4 * NBMAXIDAYS 
sBufferDays:    .skip BUFFERSIZE
sBuffer:        .skip BUFFERSIZE
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                                @ INFO: main
    mov r0,sp                        @ stack address for load parameter
    bl traitFic                      @ read file and process 

100:                                 @ standard end of the program 
    mov r0, #0                       @ return code
    mov r7, #EXIT                    @ request to exit program
    svc #0                           @ perform the system call
 
iAdrszCarriageReturn:      .int szCarriageReturn
//iAdrszMessErrBuffer:       .int szMessErrBuffer
iAdrsZoneConv:             .int sZoneConv


/******************************************************************/
/*     read file                                                   */ 
/******************************************************************/
/* r0 contains address stack begin           */
traitFic:                             @ INFO: traitFic
    push {r1-r8,fp,lr}                @ save  registers
    mov fp,r0                         @  fp <- start address
    ldr r4,[fp]                       @ number of Command line arguments
    cmp r4,#1
    movle r0,#-1
    ble 99f
    add r5,fp,#8                      @ second parameter address 
    ldr r5,[r5]
    ldr r0,iAdriAdrFicName
    str r5,[r0]
    ldr r0,iAdrszMessTitre
    bl affichageMess                  @ display string
    mov r0,r5
    bl affichageMess 
    ldr r0,iAdrszCarriageReturn
    bl affichageMess                  @ display carriage return

    mov r0,r5                         @ file name
    mov r1,#O_RDWR                    @ flags    
    mov r2,#0                         @ mode 
    mov r7, #OPEN                     @ call system OPEN 
    svc 0 
    cmp r0,#0                         @ error ?
    ble 99f
    mov r8,r0                         @ File Descriptor
    ldr r1,iAdrsBufferDays             @ buffer address
    mov r2,#BUFFERSIZE                @ buffer size
    mov r7,#READ                      @ read file
    svc #0
    cmp r0,#0                         @ error ?
    blt 99f
    @ extraction datas
    ldr r1,iAdrsBufferDays             @ buffer address
    add r1,r0
    mov r0,#0                         @ store zéro final
    strb r0,[r1] 
    ldr r0,iAdriTabAdrDays             @ key string command table
    ldr r1,iAdrsBufferDays             @ buffer address
    bl extracDatas
                                      @ close file
    mov r0,r8
    mov r7, #CLOSE 
    svc 0 
    mov r0,#0
    b 100f
99:                                   @ error
    ldr r1,iAdrszMessErreur           @ error message
    bl   displayError
    mov r0,#-1
100:
    pop {r1-r8,fp,lr}                 @ restaur registers 
    bx lr                             @return
iAdriAdrFicName:              .int iAdrFicName
iAdrszMessTitre:              .int szMessTitre
iAdrszMessErreur:             .int szMessErreur
iAdrsBuffer:                  .int sBuffer
iAdrsBufferDays:              .int sBufferDays
iAdriTabAdrDays:              .int iTabAdrDays
/******************************************************************/
/*     extrac lines file buffer                                   */ 
/******************************************************************/
/* r0 contains strings address           */
/* r1 contains buffer address         */
extracDatas:                     @ INFO: extracDatas
    push {r1-r8,lr}              @ save  registers
    mov r7,r0
    mov r6,r1
    mov r2,#0                    @ string buffer indice
    mov r4,r1                    @ start string
    mov r5,#0                    @ string index
1:
    ldrb r3,[r6,r2]
    cmp r3,#0
    beq 4f                       @ end
    cmp r3,#0xA
    beq 2f
    cmp r3,#' '                  @ end string
    beq 3f
    add r2,#1
    b 1b
2:
    mov r3,#0
    strb r3,[r6,r2]
    ldrb r3,[r6,r2]
    cmp r3,#0xD
    addeq r2,#2
    addne r2,#1
    mov r0,r4                   @ store last day of line in table
    str r4,[r7,r5,lsl #2]
    mov r0,r5                   @ days number
    bl traitLine                @ process a line of days
    mov r5,#0                   @ new line
    b 5f
 
3:
    mov r3,#0
    strb r3,[r6,r2]
    add r2,#1
4:  
    mov r0,r4
    str r4,[r7,r5,lsl #2]
    add r5,#1
5:                              @ supress spaces 
    ldrb r3,[r6,r2]
    cmp r3,#0
    beq 100f
    cmp r3,#' '
    addeq r2,r2,#1
    beq 5b
    
    add r4,r6,r2                 @ new start address
    b 1b
100:
    pop {r1-r8,lr}               @ restaur registers 
    bx lr                        @return
    
/******************************************************************/
/*     processing a line                                          */ 
/******************************************************************/
/* r0 contains days number in table   */
traitLine:                    @ INFO: traitLine
    push {r1-r12,lr}           @ save  register
    cmp r0,#1                 @ one day ?
    bgt 1f                    @ no

    ldr r0,iAdrszCarriageReturn @ yes display empty line
    bl affichageMess
    b 100f
1:                            @ line OK
    mov r6,r0                 @ days number
    ldr r0,iAdriTabAdrDays
    ldr r1,iAdriTabAdrDays2
    mov r2,#0
11:                           @ copy days table into other for display final
    ldr r3,[r0,r2,lsl #2]
    str r3,[r1,r2,lsl #2]
    add r2,#1
    cmp r2,r6
    ble 11b
    ldr r0,iAdriTabAdrDays    @ and sort first table
    mov r1,#0
    add r2,r6,#1
    bl insertionSort
    
    mov r8,#1                 @ abbrevations counter
    ldr r12,iAdriTabAdrDays
    mov r2,#0
    ldr r10,[r12,r2,lsl #2]   @ load first sorting day
    mov r11,#0
    mov r3,#1
2:                            @ begin loop
    ldr r4,[r12,r3,lsl #2]    @ load other day
    @ 1er lettre identique
    mov r0,r10                @ day1
    mov r1,r4                 @ day 2
    mov r2,#0                 @ position 0
    bl compareChar
    cmp r0,#0                 @ first letter equal ?
    movne r10,r4              @ no -> move day 2 in day 1
    bne 6f
3:                            @ if equal
    mov r7,r1                 @ characters length (1,2,3)
    mov r11,#1                @ letters position
4:                            @ loop to compare letters days
    mov r0,r10
    mov r1,r4
    mov r2,r7
    bl compareChar
    cmp r0,#0
    bne 5f
    cmp r5,#0                 @ if end
    beq 5f
    add r7,r7,r1              @ next character
    add r11,r11,#1            @ count letter
    b 4b
5:
    add r11,r11,#1            @ increment letters position
    cmp r11,r8                @ and store if > position précedente
    movgt r8,r11
    mov r10,r4                 @ and day1 = day2
    
6:               
    add r3,r3,#1              @ increment day
    cmp r3,r6                 
    ble 2b                    @ and loop
    
    mov r0,r8                 @ display position letter
    ldr r1,iAdrsZoneConv
    bl conversion10
    mov r2,#0
    strb r2,[r1,r0]
    ldr r0,iAdrsZoneConv
    bl affichageMess
    ldr r0,iAdrszSpace
    bl affichageMess
    ldr r0,iAdriTabAdrDays2   @ and display list origine days
    mov r1,r6
    bl displayListDays
    
100:
    pop {r1-r12,lr}              @ restaur registers 
    bx lr                        @return 
iAdrszSpace:          .int szSpace
iAdriTabAdrDays2:     .int iTabAdrDays2
/******************************************************************/
/*     comparison character unicode                               */ 
/******************************************************************/
/* r0 contains address first string            */
/* r1 contains address second string */
/* r2 contains the character position to compare  */
/* r0 return 0 if equal 1 if > -1 if < */
/* r1 return character S1 size in octet if equal */
/* r2 return character S2 size in octet */
compareChar:
    push {r3-r8,lr}              @ save  registers
    ldrb r3,[r0,r2]
    ldrb r4,[r1,r2]
    cmp r3,r4                    @ compare first byte
    movlt r0,#-1
    movgt r0,#1 
    bne 100f
    and r3,#0b11100000           @ 3 bytes ?
    cmp r3,#0b11100000
    bne 1f
    add r2,#1
    ldrb r3,[r0,r2]
    ldrb r4,[r1,r2]
    cmp r3,r4
    movlt r0,#-1
    movgt r0,#1 
    bne 100f
    add r2,#1
    ldrb r3,[r0,r2]
    ldrb r4,[r1,r2]
    cmp r3,r4
    movlt r0,#-1
    movgt r0,#1 
    bne 100f
    mov r0,#0
    mov r1,#3
    b 100f
1:
    and r3,#0b11100000           @ 2 bytes ?
    cmp r3,#0b11000000
    bne 2f
    add r2,#1
    ldrb r3,[r0,r2]
    ldrb r4,[r1,r2]
    cmp r3,r4
    movlt r0,#-1
    movgt r0,#1 
    bne 100f
    mov r0,#0
    mov r1,#2
    b 100f
2:                              @ 1 byte
    mov r0,#0
    mov r1,#1

100:
    pop {r3-r8,lr}              @ restaur registers 
    bx lr                       @return
/******************************************************************/
/*     control load                                      */ 
/******************************************************************/
/* r0 contains string table           */
/* r1 contains days number */
displayListDays:
    push {r1-r8,lr}              @ save  registers
    mov r5,r0
    mov r2,#0
1:
    cmp r2,r1
    bgt 2f
    ldr r0,[r5,r2,lsl #2]
    bl affichageMess
    ldr r0,iAdrszSpace
    bl affichageMess
    add r2,r2,#1
    b 1b
2:
    ldr r0,iAdrszCarriageReturn
    bl affichageMess
100:
    pop {r1-r8,lr}               @ restaur registers 
    bx lr                        @return
/************************************/       
/* Strings case sensitive comparisons  */
/************************************/      
/* r0 et r1 contains the address of strings */
/* return 0 in r0 if equals */
/* return -1 if string r0 < string r1 */
/* return 1  if string r0 > string r1 */
comparStrings:
    push {r1-r4}             @ save des registres
    mov r2,#0                @ counter
1:    
    ldrb r3,[r0,r2]          @ byte string 1
    ldrb r4,[r1,r2]          @ byte string 2
    cmp r3,r4
    movlt r0,#-1             @ small
    movgt r0,#1              @ greather
    bne 100f                 @ not equals
    cmp r3,#0                @ 0 end string
    moveq r0,#0              @ equal 
    beq 100f                 @ end string
    add r2,r2,#1             @ else add 1 in counter
    b 1b                     @ and loop
100:
    pop {r1-r4}
    bx lr   
/******************************************************************/
/*         insertion sort                                              */ 
/******************************************************************/
/* r0 contains the address of table */
/* r1 contains the first element    */
/* r2 contains the number of element */
insertionSort:
    push {r1-r6,lr}                    @ save registers
    mov r6,r0
    add r3,r1,#1                       @ start index i
1:                                     @ start loop
    ldr r1,[r6,r3,lsl #2]              @ load value A[i]
    sub r5,r3,#1                       @ index j
2:
    ldr r4,[r6,r5,lsl #2]              @ load value A[j]
    mov r0,r4
    bl comparStrings
    cmp r0,#1                          @ compare value
    bne 3f
    add r5,#1                          @ increment index j
    str r4,[r6,r5,lsl #2]              @ store value A[j+1]
    subs r5,#2                         @ j = j - 1
    bge 2b                             @ loop if j >= 0
3:
    add r5,#1                          @ increment index j
    str r1,[r6,r5,lsl #2]              @ store value A[i] in A[j+1]
    add r3,#1                          @ increment index i
    cmp r3,r2                          @ end ?
    blt 1b                             @ no -> loop

100:
    pop {r1-r6,lr}
    bx lr   
/***************************************************/
/*      ROUTINES INCLUDE                           */
/***************************************************/
.include "../affichage.inc"

Nom du fichier : listDays.txt
2 Sunday Monday Tuesday Wednesday Thursday Friday Saturday
2 Sondag Maandag Dinsdag Woensdag Donderdag Vrydag Saterdag
4 E_djelë E_hënë E_martë E_mërkurë E_enjte E_premte E_shtunë
2 Ehud Segno Maksegno Erob Hamus Arbe Kedame
5 Al_Ahad Al_Ithinin Al_Tholatha'a Al_Arbia'a Al_Kamis Al_Gomia'a Al_Sabit
4 Guiragui Yergou_shapti Yerek_shapti Tchorek_shapti Hink_shapti Ourpat Shapat
2 domingu llunes martes miércoles xueves vienres sábadu
2 Bazar_gÜnÜ Birinci_gÜn Çkinci_gÜn ÜçÜncÜ_gÜn DÖrdÜncÜ_gÜn Bes,inci_gÜn Altòncò_gÜn
6 Igande Astelehen Astearte Asteazken Ostegun Ostiral Larunbat
4 Robi_bar Shom_bar Mongal_bar Budhh_bar BRihashpati_bar Shukro_bar Shoni_bar
2 Nedjelja Ponedeljak Utorak Srijeda Cxetvrtak Petak Subota
5 Disul Dilun Dimeurzh Dimerc'her Diriaou Digwener Disadorn
2 nedelia ponedelnik vtornik sriada chetvartak petak sabota
12 sing_kei_yaht sing_kei_yat sing_kei_yee sing_kei_saam sing_kei_sie sing_kei_ng sing_kei_luk
4 Diumenge Dilluns Dimarts Dimecres Dijous Divendres Dissabte
16 Dzeenkk-eh Dzeehn_kk-ehreh Dzeehn_kk-ehreh_nah_kay_dzeeneh Tah_neesee_dzeehn_neh Deehn_ghee_dzee-neh Tl-oowey_tts-el_dehlee Dzeentt-ahzee
6 dy_Sul dy_Lun dy_Meurth dy_Mergher dy_You dy_Gwener dy_Sadorn
2 Dimanch Lendi Madi Mèkredi Jedi Vandredi Samdi
2 nedjelja ponedjeljak utorak srijeda cxetvrtak petak subota
2 nede^le ponde^lí úterÿ str^eda c^tvrtek pátek sobota
2 Sondee Mondee Tiisiday Walansedee TOOsedee Feraadee Satadee
2 s0ndag mandag tirsdag onsdag torsdag fredag l0rdag
2 zondag maandag dinsdag woensdag donderdag vrijdag zaterdag
2 Diman^co Lundo Mardo Merkredo ^Jaùdo Vendredo Sabato
1 pÜhapäev esmaspäev teisipäev kolmapäev neljapäev reede laupäev

7 Diu_prima Diu_sequima Diu_tritima Diu_quartima Diu_quintima Diu_sextima Diu_sabbata
2 sunnudagur mánadagur tÿsdaguy mikudagur hósdagur friggjadagur leygardagur
2 Yek_Sham'beh Do_Sham'beh Seh_Sham'beh Cha'har_Sham'beh Panj_Sham'beh Jom'eh Sham'beh
2 sunnuntai maanantai tiistai keskiviiko torsktai perjantai lauantai
2 dimanche lundi mardi mercredi jeudi vendredi samedi
4 Snein Moandei Tiisdei Woansdei Tonersdei Freed Sneon
2 Domingo Segunda_feira Martes Mércores Joves Venres Sábado
2 k'vira orshabati samshabati otkhshabati khutshabati p'arask'evi shabati
2 Sonntag Montag Dienstag Mittwoch Donnerstag Freitag Samstag
2 Kiriaki' Defte'ra Tri'ti Teta'rti Pe'mpti Paraskebi' Sa'bato
3 ravivaar somvaar mangalvaar budhvaar guruvaar shukravaar shanivaar
6 pópule pó`akahi pó`alua pó`akolu pó`ahá pó`alima pó`aono
7 Yom_rishon Yom_sheni Yom_shlishi Yom_revi'i Yom_chamishi Yom_shishi Shabat
3 ravivara somavar mangalavar budhavara brahaspativar shukravara shanivar
3 vasárnap hétfö kedd szerda csütörtök péntek szombat
2 Sunnudagur Mánudagur ╞riδjudagur Miδvikudagar Fimmtudagur FÖstudagur Laugardagur
2 sundio lundio mardio merkurdio jovdio venerdio saturdio
3 Minggu Senin Selasa Rabu Kamis Jumat Sabtu
2 Dominica Lunedi Martedi Mercuridi Jovedi Venerdi Sabbato
4 Dé_Domhnaigh Dé_Luain Dé_Máirt Dé_Ceadaoin Dé_ardaoin Dé_hAoine Dé_Sathairn
2 domenica lunedí martedí mercoledí giovedí venerdí sabato
2 Nichiyou_bi Getzuyou_bi Kayou_bi Suiyou_bi Mokuyou_bi Kin'you_bi Doyou_bi
1 Il-yo-il Wol-yo-il Hwa-yo-il Su-yo-il Mok-yo-il Kum-yo-il To-yo-il
7 Dies_Dominica Dies_Lunæ Dies_Martis Dies_Mercurii Dies_Iovis Dies_Veneris Dies_Saturni
3 sve-tdien pirmdien otrdien tresvdien ceturtdien piektdien sestdien
2 Sekmadienis Pirmadienis Antradienis Trec^iadienis Ketvirtadienis Penktadienis S^es^tadienis
3 Wangu Kazooba Walumbe Mukasa Kiwanuka Nnagawonye Wamunyi
12 xing-_qi-_rì xing-_qi-_yi-. xing-_qi-_èr xing-_qi-_san-. xing-_qi-_sì xing-_qi-_wuv. xing-_qi-_liù
3 Jedoonee Jelune Jemayrt Jecrean Jardaim Jeheiney Jesam
3 Jabot Manre Juje Wonje Taije Balaire Jarere
5 geminrongo minòmishi mártes mièrkoles misheushi bèrnashi mishábaro
2 Ahad Isnin Selasa Rabu Khamis Jumaat Sabtu
2 sφndag mandag tirsdag onsdag torsdag fredag lφrdag
7 lo_dimenge lo_diluns lo_dimarç lo_dimèrcres lo_dijòus lo_divendres lo_dissabte
4 djadomingo djaluna djamars djarason djaweps djabièrna djasabra
2 Niedziela Poniedzial/ek Wtorek S,roda Czwartek Pia,tek Sobota
3 Domingo segunda-feire terça-feire quarta-feire quinta-feire sexta-feira såbado
1 Domingo Lunes martes Miercoles Jueves Viernes Sabado
2 Duminicª Luni Mart'i Miercuri Joi Vineri Sâmbªtª
2 voskresenie ponedelnik vtornik sreda chetverg pyatnitsa subbota
4 Sunday Di-luain Di-màirt Di-ciadain Di-ardaoin Di-haoine Di-sathurne
2 nedjelja ponedjeljak utorak sreda cxetvrtak petak subota
5 Sontaha Mmantaha Labobedi Laboraro Labone Labohlano Moqebelo
2 Iridha- Sandhudha- Anga.haruwa-dha- Badha-dha- Brahaspa.thindha- Sikura-dha- Sena.sura-dha-
2 nedel^a pondelok utorok streda s^tvrtok piatok sobota
2 Nedelja Ponedeljek Torek Sreda Cxetrtek Petek Sobota
2 domingo lunes martes miércoles jueves viernes sábado
2 sonde mundey tude-wroko dride-wroko fode-wroko freyda Saturday
7 Jumapili Jumatatu Jumanne Jumatano Alhamisi Ijumaa Jumamosi
2 söndag måndag tisdag onsdag torsdag fredag lordag
2 Linggo Lunes Martes Miyerkoles Huwebes Biyernes Sabado
6 Lé-pài-jít Pài-it Pài-jï Pài-sañ Pài-sì Pài-gÖ. Pài-lák
7 wan-ar-tit wan-tjan wan-ang-kaan wan-phoet wan-pha-ru-hat-sa-boh-die wan-sook wan-sao
5 Tshipi Mosupologo Labobedi Laboraro Labone Labotlhano Matlhatso
6 Pazar Pazartesi Sali Çar,samba Per,sembe Cuma Cumartesi
2 nedilya ponedilok vivtorok sereda chetver pyatnytsya subota
8 Chu?_Nhâ.t Thú*_Hai Thú*_Ba Thú*_Tu* Thú*_Na'm Thú*_Sáu Thú*_Ba?y
6 dydd_Sul dyds_Llun dydd_Mawrth dyds_Mercher dydd_Iau dydd_Gwener dyds_Sadwrn
3 Dibeer Altine Talaata Allarba Al_xebes Aljuma Gaaw
7 iCawa uMvulo uLwesibini uLwesithathu uLuwesine uLwesihlanu uMgqibelo
2 zuntik montik dinstik mitvokh donershtik fraytik shabes
7 iSonto uMsombuluko uLwesibili uLwesithathu uLwesine uLwesihlanu uMgqibelo
7 Dies_Dominica Dies_Lunæ Dies_Martis Dies_Mercurii Dies_Iovis Dies_Veneris Dies_Saturni
11 Bazar_gÜnÜ Bazar_ærtæsi Çærs,ænbæ_axs,amò Çærs,ænbæ_gÜnÜ CÜmæ_axs,amò CÜmæ_gÜnÜ CÜmæ_Senbæ
2 Sun Moon Mars Mercury Jove Venus Saturn
2 zondag maandag dinsdag woensdag donderdag vrijdag zaterdag
2 KoseEraa GyoOraa BenEraa Kuoraa YOwaaraa FeEraa Memenaa
5 Sonntag Montag Dienstag Mittwoch Donnerstag Freitag Sonnabend
1 Domingo Luns Terza_feira Corta_feira Xoves Venres Sábado
7 Dies_Solis Dies_Lunae Dies_Martis Dies_Mercurii Dies_Iovis Dies_Veneris Dies_Sabbatum
12 xing-_qi-_tiàn xing-_qi-_yi-. xing-_qi-_èr xing-_qi-_san-. xing-_qi-_sì xing-_qi-_wuv. xing-_qi-_liù
4 djadomingu djaluna djamars djarason djaweps djabièrnè djasabra
2 Killachau Atichau Quoyllurchau Illapachau Chaskachau Kuychichau Intichau