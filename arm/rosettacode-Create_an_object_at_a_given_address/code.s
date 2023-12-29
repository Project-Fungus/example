mov r0,#0x00100000
ldr r1,testData
str r1,[r0]   ;store 0x12345678 at address $100000
bx lr         ;return from subroutine

testData:
     .long 0x12345678    ;VASM uses .long for 32 bit and .word for 16 bit values, unlike most ARM assemblers.

.equ myVariable,0x00100000
mov r0,#myVariable
bl printLong        ;unimplemented printing routine

mov r0,#0x00100000
mov r1,#0
mvn r1,r1     ;flip the bits of r1
str r1,[r0]   ;store 0xFFFFFFFF at address $100000
bx lr         ;return from subroutine