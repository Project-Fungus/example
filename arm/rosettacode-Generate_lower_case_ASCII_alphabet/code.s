ProgramStart:
	mov sp,#0x03000000			;Init Stack Pointer
	
	mov r4,#0x04000000  		        ;DISPCNT -LCD Control
	mov r2,#0x403    			;4= Layer 2 on / 3= ScreenMode 3
	str r2,[r4]         	                ;hardware specific routine, activates Game Boy's bitmap mode

	mov r0,#0x61				;ASCII "a"
	mov r2,#ramarea
	mov r1,#26					
	
rep_inc_stosb:                                  ;repeatedly store a byte into memory, incrementing the destination and the value stored
                                                ;    each time.
	strB r0,[r2]
	add r0,r0,#1
	add r2,r2,#1
	subs r1,r1,#1
	bne rep_inc_stosb
	mov r0,#255		
	strB r0,[r2]				;store a 255 terminator into r1
	
	mov r1,#ramarea
	bl PrintString                          ;Prints a 255-terminated string using a pre-defined bitmap font. Code omitted for brevity

forever:
        b forever                               ;halt the cpu