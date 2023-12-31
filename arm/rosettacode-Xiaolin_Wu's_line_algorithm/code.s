/* ARM assembly Raspberry PI  */
/*  program xiaolin1.s   */

/* REMARK 1 : this program use routines in a include file 
   see task Include a file language arm assembly 
   for the routine affichageMess displayerror 
   see at end oh this program the instruction include */

/* REMARK 2 : display use a FrameBuffer device : see raspberry pi FrameBuffer documentation
              this solution write directly on the screen of raspberry pi
              other solution is to use X11 windows but X11 has a function drawline !! */

/* REMARK 3 : this program do not respect the convention for use, save and restau registers
              in rhe routine call !!!!   */

/*******************************************/
/* Constantes    */
/*******************************************/
.equ STDOUT,              1     @ Linux output console
.equ EXIT,                1     @ Linux syscall
.equ WRITE,               4     @ Linux syscall
.equ OPEN,                5
.equ CLOSE,               6
.equ IOCTL,               0x36
.equ MMAP,                0xC0
.equ UNMAP,               0x5B
.equ O_RDWR,              0x0002    @ open for reading and writing
.equ MAP_SHARED,          0x01      @ Share changes.
.equ PROT_READ,           0x1       @ Page can be read.
.equ PROT_WRITE,          0x2       @ Page can be written.

/*******************************************/
/* Initialized data                        */
/*******************************************/
.data
szMessErreur:   .asciz "File open error.\n"
szMessErreur1:  .asciz "File close error.\n"
szMessErreur2:  .asciz "File mapping error.\n"
szMessDebutPgm: .asciz "Program start. \n"
szMessFinOK:    .asciz "Normal end program. \n"
szMessErrFix:   .asciz  "Read error info fix framebuffer  \n"
szMessErrVar:   .asciz  "Read error info var framebuffer  \n"
szRetourligne:  .asciz  "\n"
szParamNom:     .asciz "/dev/fb0"         @ FrameBuffer device name
szLigneVar:     .ascii "Variables info : "
sWidth:        .fill 11, 1, ' ' 
                .ascii " * "
sHeight:        .fill 11, 1, ' ' 
                .ascii " Bits par pixel : "
sBits:           .fill 11, 1, ' '
                .asciz  "\n"
/*************************************************/
szMessErr: .ascii	"Error code hexa : "
sHexa: .space 9,' '
         .ascii "  decimal :  "
sDeci: .space 15,' '
         .asciz "\n"
.align 4
/* codes fonction pour la récupération des données fixes et variables */
FBIOGET_FSCREENINFO: .int 0x4602  @ function code for read infos fixes Framebuffer
FBIOGET_VSCREENINFO: .int 0x4600  @ function code for read infos variables Framebuffer

/*******************************************/
/* UnInitialized data */
/*******************************************/ 
.bss
.align 4
fix_info: .skip FBFIXSCinfo_fin                @ memory reserve for structure FSCREENINFO
.align 4
var_info: .skip FBVARSCinfo_fin                @ memory reserve for structure VSCREENINFO
/**********************************************/
/* -- Code section                            */
/**********************************************/
.text
.global main

main:
    ldr r0,iAdrszMessDebutPgm
    bl affichageMess                  @ display message
    ldr r0,iAdrszParamNom             @ frameBuffer device name
    mov r1,#O_RDWR                    @ flags read/write
    mov r2,#0                         @ mode 
    mov r7,#OPEN                      @ open device FrameBuffer 
    svc 0 
    cmp r0,#0                         @ error ?
    ble erreur
    mov r10,r0                        @ save FD du device FrameBuffer in r10
    
    ldr r1,iAdrFBIOGET_VSCREENINFO    @ read variables datas of FrameBuffer
    ldr r1,[r1]                       @ load code function
    ldr r2,iAdrvar_info               @ structure memory address
    mov r7, #IOCTL                    @ call system
    swi 0 
    cmp r0,#0
    blt erreurVar
    ldr r2,iAdrvar_info
    ldr r0,[r2,#FBVARSCinfo_xres]     @ load screen width
    ldr r1,iAdrsWidth                 @ and convert in string for display
    bl conversion10S
    ldr r0,[r2,#FBVARSCinfo_yres]     @ load screen height 
    ldr r1,iAdrsHeight                @ and convert in string for display
    bl conversion10S
    ldr r0,[r2,#FBVARSCinfo_bits_per_pixel]  @ load bits by pixel  
    ldr r1,iAdrsBits                  @ and convert in string for display
    bl conversion10S
    ldr r0,iAdrszLigneVar             @ display result 
    bl affichageMess

    mov r0,r10                        @ FD du FB
    ldr r1,iAdrFBIOGET_FSCREENINFO    @ read fixes datas of FrameBuffe
    ldr r1,[r1]                       @ load code function
    ldr r2,iAdrfix_info               @ structure memory address
    mov r7, #IOCTL                    @ call system
    svc 0 
    cmp r0,#0                         @ error ?
    blt erreurFix
    ldr r0,iAdrfix_info

    ldr r1,iAdrfix_info               @ read size memory for datas
    ldr r1,[r1,#FBFIXSCinfo_smem_len] @ in octets
                                      @ datas mapping
    mov r0,#0
    ldr r2,iFlagsMmap
    mov r3,#MAP_SHARED
    mov r4,r10
    mov r5,#0
    mov r7, #MMAP                     @ 192 call system for mapping
    swi #0 
    cmp r0,#0                         @ error ?
    beq erreur2    
    mov r9,r0                         @ save mapping address in r9
    /*************************************/
    /* display draw                      */
    bl dessin
    /************************************/
    mov r0,r9                         @ mapping close
    ldr r1,iAdrfix_info
    ldr r1,[r1,#FBFIXSCinfo_smem_len] @ mapping memory size
    mov r7,#UNMAP                     @call system 91 for unmapping
    svc #0                            @ error ?
    cmp r0,#0
    blt erreur1    
                                      @ close device FrameBuffer
    mov r0,r10                        @ load FB du device
    mov r7, #CLOSE                    @ call system
    swi 0 
    ldr r0,iAdrszMessFinOK            @ display end message
    bl affichageMess
    mov r0,#0                         @ return code = OK
    b 100f
erreurFix:                            @ display read error datas fix
    ldr r1,iAdrszMessErrFix           @ message address
    bl   displayError                 @ call display
    mov r0,#1                         @ return code = error
    b 100f
erreurVar:                            @ display read error datas var
    ldr r1,iAdrszMessErrVar
    bl   displayError
    mov r0,#1
    b 100f
erreur:                               @ display open error 
    ldr r1,iAdrszMessErreur
    bl   displayError
    mov r0,#1
    b 100f
erreur1:                              @ display unmapped error
    ldr r1,iAdrszMessErreur1
    bl   displayError
    mov r0,#1
    b 100f
erreur2:                              @ display mapped error
    ldr r1,iAdrszMessErreur2
    bl   displayError
    mov r0,#1
    b 100f
100:                                  @ end program
    mov r7, #EXIT
    svc 0 
/************************************/
iAdrszParamNom:           .int szParamNom
iFlagsMmap:               .int PROT_READ|PROT_WRITE
iAdrszMessErreur:         .int szMessErreur
iAdrszMessErreur1:        .int szMessErreur1
iAdrszMessErreur2:        .int szMessErreur2
iAdrszMessDebutPgm:       .int szMessDebutPgm
iAdrszMessFinOK:          .int szMessFinOK
iAdrszMessErrFix:         .int szMessErrFix
iAdrszMessErrVar:         .int szMessErrVar
iAdrszLigneVar:           .int szLigneVar
iAdrvar_info:             .int var_info
iAdrfix_info:             .int fix_info
iAdrFBIOGET_FSCREENINFO:  .int FBIOGET_FSCREENINFO
iAdrFBIOGET_VSCREENINFO:  .int FBIOGET_VSCREENINFO
iAdrsWidth:               .int sWidth
iAdrsHeight:              .int sHeight
iAdrsBits:                .int sBits
/***************************************************/
/*   dessin                  */
/***************************************************/
/* r9 framebuffer memory address   */
dessin:
    push {r1-r12,lr}                  @ save registers
    mov r0,#255                       @ red
    mov r1,#255                       @ green
    mov r2,#255                       @ blue    3 bytes 255 = white
    bl codeRGB                        @ code color RGB  32 bits
    mov r1,r0                         @ background color
    ldr r0,iAdrfix_info               @ load memory mmap size 
    ldr r0,[r0,#FBFIXSCinfo_smem_len]    
    bl coloriageFond                  @
    /* draw line 1  */
    mov r0,#200                       @ X start line
    mov r1,#200                       @ Y start line
    mov r2,#200                       @ X end line
    mov r3,#100                       @ Y end line
    ldr r4,iAdrvar_info
    ldr r4,[r4,#FBVARSCinfo_xres]     @ load screen width
    bl drawLine
    /* draw line 2  */
    mov r0,#200
    mov r1,#200
    mov r2,#200
    mov r3,#300
    ldr r4,iAdrvar_info
    ldr r4,[r4,#FBVARSCinfo_xres]
    bl drawLine
    /* draw line 3  */
    mov r0,#200
    mov r1,#200
    mov r2,#100
    mov r3,#200
    ldr r4,iAdrvar_info
    ldr r4,[r4,#FBVARSCinfo_xres]
    bl drawLine
    /* draw line 4  */
    mov r0,#200
    mov r1,#200
    mov r2,#300
    mov r3,#200
    ldr r4,iAdrvar_info
    ldr r4,[r4,#FBVARSCinfo_xres]
    bl drawLine
    /* draw line 5  */
    mov r0,#200
    mov r1,#200
    mov r2,#100
    mov r3,#100
    ldr r4,iAdrvar_info
    ldr r4,[r4,#FBVARSCinfo_xres]
    bl drawLine
    /* draw line 6  */
    mov r0,#200
    mov r1,#200
    mov r2,#100         
    mov r3,#300
    ldr r4,iAdrvar_info
    ldr r4,[r4,#FBVARSCinfo_xres]
    bl drawLine
    /* draw line 7  */
    mov r0,#200
    mov r1,#200
    mov r2,#300
    mov r3,#300
    ldr r4,iAdrvar_info
    ldr r4,[r4,#FBVARSCinfo_xres]
    bl drawLine
    /* draw line 8  */
    mov r0,#200
    mov r1,#200
    mov r2,#300
    mov r3,#100
    ldr r4,iAdrvar_info
    ldr r4,[r4,#FBVARSCinfo_xres]
    bl drawLine

100:
    pop {r1-r12,lr}                 @ restaur registers
    bx lr                           @ end function

/********************************************************/
/*   set background color                               */
/********************************************************/
/* r0 contains size screen memory  */
/* r1 contains rgb code color      */
/* r9 contains screen memory address */
coloriageFond:
    push {r2,lr}
    mov r2,#0                     @ counter 
1:                                @ begin loop
    str r1,[r9,r2]
    add r2,#4
    cmp r2,r0
    blt 1b
    pop {r2,lr}
    bx lr
/********************************************************/
/*   Xiaolin Wu  line algorithm                        */
/*  no floating point compute,  multiply value for 128  */
/*  for integer compute                                 */
/********************************************************/
/* r0  x1 start line */
/* r1  y1 start line */
/* r2  x2 end line */
/* r3  y2 end line */
/* r4  screen width */
drawLine:
    push {fp,lr}      @ save registers ( no other registers save )
    mov r5,r0         @ save x1
    mov r6,r1         @ save y1
    cmp r2,r5         @ compar x2,x1
    subgt r1,r2,r5
    suble r1,r5,r2    @ compute dx=abs val de x1-x2
    cmp r3,r6         @ compar y2,y1
    subgt r0,r3,r6
    suble r0,r6,r3    @ compute dy = abs val de y1-y2
    cmp r1,r0         @ compare dx , dy
    blt 5f            @ dx < dy
                      @ dx > dy
    cmp r2,r5         @ compare x2,x1
    movlt r8,r5       @ x2 < x1 
    movlt r5,r2       @ swap x2,x1
    movlt r2,r8
    movlt r8,r6       @ swap y2,y1
    movlt r6,r3
    movlt r3,r8
    lsl r0,#7         @ * by 128
    mov r7,r2         @ save x2
    mov r8,r3         @ save y2
    cmp r1,#0         @ divisor = 0 ?
    moveq r10,#128
    beq 1f
    bl division       @ gradient compute (* 128)
    mov r10,r2        @ r10 contient le gradient
1:
    @ display start points
    mov r0,#64
    bl colorPixel
    mov r3,r0              @ RGB color 
    mov r0,r5              @ x1
    mov r1,r6              @ y1
    mov r2,r4              @ screen witdh 
    bl aff_pixel_codeRGB32 @ display pixel
    add r1,#1              @ increment y1
    bl aff_pixel_codeRGB32
    @ display end points
    mov r0,r7              @ x2
    mov r1,r8              @ y2
    bl aff_pixel_codeRGB32
    add r1,#1              @ increment y2 
    bl aff_pixel_codeRGB32
    cmp r8,r6              @ compar y2,y1
    blt 3f                 @ y2 < y1
    mov r4,r5              @ x =  x1 
    lsl r5,r6,#7           @ compute y1 * 128
    add r5,r10             @ compute intery = (y1 * 128 + gradient * 128)
2:                         @ start loop draw line pixels
    lsr r1,r5,#7           @ intery / 128  = y
    lsl r8,r1,#7
    sub r6,r5,r8           @ reminder of intery /128 = brightness
    mov r0,r6
    bl colorPixel          @ compute rgb color brightness
    mov r3,r0              @ rgb color
    mov r0,r4              @ x 
    bl aff_pixel_codeRGB32 @ display pixel 1
    add r1,#1              @ increment y
    rsb r0,r6,#128         @ compute 128 - brightness
    bl colorPixel          @ compute new rgb color
    mov r3,r0
    mov r0,r4
    bl aff_pixel_codeRGB32 @ display pixel 2
    add r5,r10             @ add gradient to intery
    add r4,#1              @ increment x
    cmp r4,r7              @ x < x2
    ble 2b                 @ yes -> loop
    b 100f                 @ else end
3:                         @ y2 < y1  
    mov r4,r7              @ x = x2 
    mov r7,r5              @ save x1
    lsl r5,r8,#7           @ y = y1 * 128 
    add r5,r10             @ compute intery = (y1 * 128 + gradient * 128)
4:
    lsr r1,r5,#7           @ y = ent(intery / 128)
    lsl r8,r1,#7
    sub r8,r5,r8           @ brightness = remainder
    mov r0,r8
    bl colorPixel
    mov r3,r0
    mov r0,r4
    bl aff_pixel_codeRGB32
    add r1,#1
    rsb r0,r8,#128
    bl colorPixel
    mov r3,r0
    mov r0,r4
    bl aff_pixel_codeRGB32
    add r5,r10
    sub r4,#1             @ decrement x
    cmp r4,r7             @ x > x1
    bgt 4b                @ yes -> loop
    b 100f
5:                        @ dx < dy
    cmp r3,r6             @ compare y2,y1
    movlt r8,r5           @ y2 < y1 
    movlt r5,r2           @ swap x1,x2
    movlt r2,r8
    movlt r8,r6           @ swap y1,y2
    movlt r6,r3
    movlt r3,r8
    mov r8,r1             @ swap r0,r1 for routine division
    mov r1,r0
    lsl r0,r8,#7          @ dx * by 128
    mov r7,r2             @ save x2
    mov r8,r3             @ save y2
    cmp r1,#0             @ dy = zero ?
    moveq r10,#128
    beq 6f
    bl division           @  compute gradient * 128
    mov r10,r2            @  gradient -> r10
6:
    @ display start points
    mov r0,#64
    bl colorPixel
    mov r3,r0             @ color pixel
    mov r0,r5             @ x1
    mov r1,r6             @ y1
    mov r2,r4             @ screen width
    bl aff_pixel_codeRGB32
    add r1,#1
    bl aff_pixel_codeRGB32
    @ display end points
    mov r0,r7
    mov r1,r8
    bl aff_pixel_codeRGB32
    add r1,#1
    bl aff_pixel_codeRGB32
    cmp r5,r7                  @ x1 < x2 ?
    blt 8f
    mov r4,r6                  @  y = y1
    lsl r5,#7                  @ compute x1 * 128
    add r5,r10                 @ compute interx
7:
    lsr r1,r5,#7               @ compute x = ent ( interx / 128)
    lsl r3,r1,#7
    sub r6,r5,r3               @ brightness = remainder
    mov r0,r6
    bl colorPixel
    mov r3,r0
    mov r0,r1                  @ new x
    add r7,r0,#1
    mov r1,r4                  @ y
    bl aff_pixel_codeRGB32
    rsb r0,r6,#128
    bl colorPixel
    mov r3,r0
    mov r0,r7                  @ new x + 1
    mov r1,r4                  @ y
    bl aff_pixel_codeRGB32
    add r5,r10
    add r4,#1
    cmp r4,r8
    ble 7b
    b 100f
8:
    mov r4,r8                  @  y = y2
    lsl r5,#7                  @ compute x1 * 128
    add r5,r10                 @ compute interx
9:
    lsr r1,r5,#7               @ compute x
    lsl r3,r1,#7
    sub r8,r5,r3
    mov r0,r8
    bl colorPixel
    mov r3,r0
    mov r0,r1                  @ new x
    add r7,r0,#1
    mov r1,r4                  @ y
    bl aff_pixel_codeRGB32
    rsb r0,r8,#128
    bl colorPixel
    mov r3,r0
    mov r0,r7                  @ new x + 1
    mov r1,r4                  @ y
    bl aff_pixel_codeRGB32
    add r5,r10
    sub r4,#1
    cmp r4,r6
    bgt 9b
    b 100f
100:
    pop {fp,lr}
    bx lr
/********************************************************/
/*   brightness color pixel                              */
/********************************************************/
/* r0 % brightness ( 0 to 128)  */
colorPixel:
    push {r1,r2,lr}    /* save des  2 registres frame et retour */
    cmp r0,#0
    beq 100f
    cmp r0,#128
    mov r0,#127
    lsl r0,#1          @ red = brightness * 2 ( 2 to 254)
    mov r1,r0          @ green = red
    mov r2,r0          @ blue = red
    bl codeRGB         @ compute rgb code color 32 bits
100:
    pop {r1,r2,lr}
    bx lr 

/***************************************************/
/*   display pixels  32 bits                       */
/***************************************************/
/* r9 framebuffer memory address */
/* r0 = x */
/* r1 = y */
/* r2 screen width in pixels */
/* r3 code color RGB 32 bits  */
aff_pixel_codeRGB32:
    push {r0-r4,lr}       @  save registers
                          @ compute location pixel
    mul r4,r1,r2          @ compute y * screen width
    add r0,r0,r4          @ + x
    lsl r0,#2             @ * 4 octets
    str r3,[r9,r0]        @ store rgb code in mmap memory
    pop {r0-r4,lr}        @ restaur registers
    bx lr
/********************************************************/
/*   Code color RGB                                     */
/********************************************************/
/* r0 red r1 green  r2 blue */
/* r0 returns RGB code      */
codeRGB:
    lsl r0,#16               @ shift red color 16 bits
    lsl r1,#8                @ shift green color 8 bits
    eor r0,r1                @ or two colors
    eor r0,r2                @ or 3 colors in r0
    bx lr

/***************************************************/
/*      ROUTINES INCLUDE                 */
/***************************************************/
.include "./affichage.inc"

/***************************************************/
/*      DEFINITION DES STRUCTURES                 */
/***************************************************/
/* structure FSCREENINFO */    
/* voir explication détaillée : https://www.kernel.org/doc/Documentation/fb/api.txt */
    .struct  0
FBFIXSCinfo_id:          /* identification string eg "TT Builtin" */
    .struct FBFIXSCinfo_id + 16  
FBFIXSCinfo_smem_start:    /* Start of frame buffer mem */
    .struct FBFIXSCinfo_smem_start + 4   
FBFIXSCinfo_smem_len:       /* Length of frame buffer mem */
    .struct FBFIXSCinfo_smem_len + 4   
FBFIXSCinfo_type:    /* see FB_TYPE_*        */
    .struct FBFIXSCinfo_type + 4  
FBFIXSCinfo_type_aux:      /* Interleave for interleaved Planes */
    .struct FBFIXSCinfo_type_aux + 4  
FBFIXSCinfo_visual:    /* see FB_VISUAL_*        */
    .struct FBFIXSCinfo_visual + 4  
FBFIXSCinfo_xpanstep:    /* zero if no hardware panning  */
    .struct FBFIXSCinfo_xpanstep + 2      
FBFIXSCinfo_ypanstep:    /* zero if no hardware panning  */
    .struct FBFIXSCinfo_ypanstep + 2 
FBFIXSCinfo_ywrapstep:      /* zero if no hardware ywrap    */
    .struct FBFIXSCinfo_ywrapstep + 4 
FBFIXSCinfo_line_length:    /* length of a line in bytes    */
    .struct FBFIXSCinfo_line_length + 4 
FBFIXSCinfo_mmio_start:     /* Start of Memory Mapped I/O   */
    .struct FBFIXSCinfo_mmio_start + 4     
FBFIXSCinfo_mmio_len:        /* Length of Memory Mapped I/O  */
    .struct FBFIXSCinfo_mmio_len + 4 
FBFIXSCinfo_accel:     /* Indicate to driver which    specific chip/card we have    */
    .struct FBFIXSCinfo_accel + 4 
FBFIXSCinfo_capabilities:     /* see FB_CAP_*            */
    .struct FBFIXSCinfo_capabilities + 4 
FBFIXSCinfo_reserved:     /* Reserved for future compatibility */
    .struct FBFIXSCinfo_reserved + 8    
FBFIXSCinfo_fin:

/* structure VSCREENINFO */    
    .struct  0
FBVARSCinfo_xres:           /* visible resolution        */ 
    .struct FBVARSCinfo_xres + 4  
FBVARSCinfo_yres:          
    .struct FBVARSCinfo_yres + 4 
FBVARSCinfo_xres_virtual:          /* virtual resolution        */
    .struct FBVARSCinfo_xres_virtual + 4 
FBVARSCinfo_yres_virtual:          
    .struct FBVARSCinfo_yres_virtual + 4 
FBVARSCinfo_xoffset:          /* offset from virtual to visible resolution */
    .struct FBVARSCinfo_xoffset + 4 
FBVARSCinfo_yoffset:          
    .struct FBVARSCinfo_yoffset + 4 
FBVARSCinfo_bits_per_pixel:          /* bits par pixel */
    .struct FBVARSCinfo_bits_per_pixel + 4     
FBVARSCinfo_grayscale:          /* 0 = color, 1 = grayscale,  >1 = FOURCC    */
    .struct FBVARSCinfo_grayscale + 4 
FBVARSCinfo_red:          /* bitfield in fb mem if true color, */
    .struct FBVARSCinfo_red + 4 
FBVARSCinfo_green:          /* else only length is significant */
    .struct FBVARSCinfo_green + 4 
FBVARSCinfo_blue:          
    .struct FBVARSCinfo_blue + 4 
FBVARSCinfo_transp:          /* transparency            */
    .struct FBVARSCinfo_transp + 4     
FBVARSCinfo_nonstd:          /* != 0 Non standard pixel format */
    .struct FBVARSCinfo_nonstd + 4 
FBVARSCinfo_activate:          /* see FB_ACTIVATE_*        */
    .struct FBVARSCinfo_activate + 4     
FBVARSCinfo_height:              /* height of picture in mm    */
    .struct FBVARSCinfo_height + 4 
FBVARSCinfo_width:           /* width of picture in mm     */
    .struct FBVARSCinfo_width + 4 
FBVARSCinfo_accel_flags:          /* (OBSOLETE) see fb_info.flags */
    .struct FBVARSCinfo_accel_flags + 4 
/* Timing: All values in pixclocks, except pixclock (of course) */    
FBVARSCinfo_pixclock:          /* pixel clock in ps (pico seconds) */
    .struct FBVARSCinfo_pixclock + 4     
FBVARSCinfo_left_margin:          
    .struct FBVARSCinfo_left_margin + 4 
FBVARSCinfo_right_margin:          
    .struct FBVARSCinfo_right_margin + 4 
FBVARSCinfo_upper_margin:          
    .struct FBVARSCinfo_upper_margin + 4 
FBVARSCinfo_lower_margin:          
    .struct FBVARSCinfo_lower_margin + 4 
FBVARSCinfo_hsync_len:          /* length of horizontal sync    */
    .struct FBVARSCinfo_hsync_len + 4     
FBVARSCinfo_vsync_len:          /* length of vertical sync    */
    .struct FBVARSCinfo_vsync_len + 4 
FBVARSCinfo_sync:          /* see FB_SYNC_*        */
    .struct FBVARSCinfo_sync + 4 
FBVARSCinfo_vmode:          /* see FB_VMODE_*        */
    .struct FBVARSCinfo_vmode + 4 
FBVARSCinfo_rotate:          /* angle we rotate counter clockwise */
    .struct FBVARSCinfo_rotate + 4     
FBVARSCinfo_colorspace:          /* colorspace for FOURCC-based modes */
    .struct FBVARSCinfo_colorspace + 4     
FBVARSCinfo_reserved:          /* Reserved for future compatibility */
    .struct FBVARSCinfo_reserved + 16        
FBVARSCinfo_fin: