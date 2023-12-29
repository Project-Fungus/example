EndianTest:
mov r0,#0xFF
mov r1,#0x02000000   ;an arbitrary memory location on the Game Boy Advance. 
                     ;(The GBA is always little-endian but this test doesn't use that knowledge to prove it.)
str r0,[r1]          ;on a little-endian CPU a hexdump of 0x02000000 would be: FF 00 00 00
                     ;on a big-endian CPU it would be:                         00 00 00 FF
ldrB r0,[r1]         ;load just the byte at 0x02000000. If the machine is big-endian this will load 00; if little-endian, 0xFF.
cmp r0,#0
beq isBigEndian
;else, do whatever is needed to display "little-endian" to the screen. This part isn't implemented.