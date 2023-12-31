.text
.global _start
_start:
    ldr r0, =example_numbers
    bl test_number

    add r1, r0, #1
    bl length
    add r0, r1, r0
    bl test_number
    
    add r1, r0, #1
    bl length
    add r0, r1, r0
    bl test_number
    
    add r1, r0, #1
    bl length
    add r0, r1, r0
    bl test_number

    mov r0, #0
    mov r7, #1
    swi 0

test_number:
    push {r0, lr}
    bl print_string

    bl luhn_test
    cmp r0, #1
    ldreq r0, =valid_message
    ldrne r0, =invalid_message
    bl print_string
    pop {r0, lr}
    mov pc, lr



print_string:
    push {r0-r7, lr}
    mov r1, r0   @ string to print
    bl length
    mov r2, r0   @ length of string
    mov r0, #1   @ write to stdout
    mov r7, #4   @ SYS_WRITE
    swi 0        @ call system interupt
    pop {r0-r7, lr}
    mov pc, lr

@ r0 address of credit card number string
@ returns result in r0
luhn_test:
    push {r1-r7, lr}
    mov r1, r0
    bl isNumerical            @ check if string is a number
    cmp r0, #1
    bne .luhn_test_end        @ exit if not number
    mov r0, r1 
    ldr r1, =reversed_string  @ address to store reversed string
    bl reverse                @ reverse string
    push {r0}
    bl length   @ get length of string
    mov r4, r0  @ store string length in r4 
    pop {r0}
    mov r2, #0  @ string index
    mov r6, #0  @ sum of odd digits
    mov r7, #0  @ sum of even digits
    .loadNext:
        ldrb r3, [r1, r2]         @ load byte into r3
        sub r3, #'0'              @ convert letter to digit
        and r5, r2, #1            @ test if index is even or odd
        cmp r5, #0
        beq .odd_digit
        bne .even_digit
        .odd_digit:
            add r6, r3              @ add digit to sum if odd
            b .continue             @ skip next step
        .even_digit:
            lsl r3, #1              @ multiply digit by 2
            cmp r3, #10             @ sum digits
            subge r3, #10           @ get digit in 1s place
            addge r3, #1            @ add 1 for the 10s place
            add r7, r3              @ add digit sum to the total
            
        .continue: 
        add r2, #1                @ increment digit index
        cmp r2, r4                @ check if at end of string
        blt .loadNext

    add r0, r6, r7                @ add even and odd sum
    mov r3, r0                    @ copy sum to r3
    ldr r1, =429496730            @ (2^32-1)/10
    sub r0, r0, r0, lsr #30       @ divide by 10
    umull r2, r0, r1, r0
    mov r1, #10
    mul r0, r1                    @ multiply the r0 by 10 to see if divisible
    cmp r0, r3                    @ compare with the original value in r3
    .luhn_test_end:
    movne r0, #0                  @ return false if invalid card number
    moveq r0, #1                  @ return true if valid card number
    pop {r1-r7, lr}
    mov pc, lr
    
length:
    push {r1-r2, lr}
    mov r2, r0              @ start of string address
    .loop:
        ldrb r1, [r2], #1   @ load byte from address r2 and increment
        cmp r1, #0          @ check for end of string
        bne .loop           @ load next byte if not 0
    sub r0, r2, r0          @ subtract end of string address from start
    sub r0, #1              @ end of line from count
    pop {r1-r2, lr}
    mov pc, lr

@ reverses a string
@ r0 address of string to reverse
@ r1 address to store reversed string
reverse:
    push {r0-r5, lr}
    push {r0, lr}
    bl length                @ get length of string to reverse
    mov r3, r0               @ backword index
    pop {r0, lr}
    mov r4, #0               @ fowrard index
    .reverse_next:
        sub r3, #1           @ decrement backword index
        ldrb r5, [r0, r3]    @ load byte from original string at index
        strb r5, [r1, r4]    @ copy byte to reversed string
        add r4, #1           @ increment fowrard index
        cmp r3, #0           @ check if any characters are left
        bge .reverse_next

    mov r5, #0
    strb r5, [r1, r4]  @ write null byte to terminate reversed string
    pop {r0-r5, lr}
    mov pc, lr

isNumerical:
    push {r1, lr}
    .isNumerical_checkNext:
        ldrb r1, [r0], #1
        cmp r1, #0
        beq .isNumerical_true
        cmp r1, #'0'
        blt .isNumerical_false
        cmp r1, #'9'
        bgt .isNumerical_false
        b .isNumerical_checkNext
    .isNumerical_false:
        mov r0, #0
        b .isNumerical_end
    .isNumerical_true:
        mov r0, #1
    .isNumerical_end:
    pop {r1, lr}
    mov pc, lr


.data
valid_message:
    .asciz " valid card number\n"
invalid_message:
    .asciz " invalid card number\n"

reversed_string:
    .space 32

example_numbers:
    .asciz "49927398716"
    .asciz "49927398717"
    .asciz "1234567812345678"
    .asciz "1234567812345670"