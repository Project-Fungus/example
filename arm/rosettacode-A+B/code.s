arm-linux-gnueabi-as src.s -o src.o && arm-linux-gnueabi-gcc -static src.o -o run && qemu-arm run

.text
.global main
.extern printf
.extern scanf

main:
        push {lr}
        ldr r0, =scanf_lit
        ldr r1, =num_a
        ldr r2, =num_b
        bl scanf             // scanf("%d %d", &num_a, &num_b);
        ldr r0, =printf_lit
        ldr r1, =num_a
        ldr r1, [r1]
        ldr r2, =num_b
        ldr r2, [r2]
        add r1, r1, r2
        bl printf            // printf("%d\n", num_a + num_b);
        pop {pc}

.data
scanf_lit:      .asciz "%d %d"
printf_lit:     .asciz "%d\n"
.align 4
.bss
num_a:  .skip 4
num_b:  .skip 4

as -o ab.o ab.S
ld -o a.out ab.o

.data
   .align   2
   .code 32

.section .rodata
   .align   2
   .code 32

overflow_msg:  .ascii  "Invalid number. Overflow.\n"
overflow_msglen = . - overflow_msg
bad_input_msg:  .ascii  "Invalid input. NaN.\n"
bad_input_msglen = . - bad_input_msg
range_err_msg:  .ascii  "Value out of range.\n"
range_err_msglen = . - range_err_msg
io_error_msg:  .ascii  "I/O error.\n"
io_error_msglen = . - range_err_msg

sys_exit  = 1
sys_read  = 3
sys_write = 4
max_rd_buf = 14
lf = 10
m10_9 = 0x3b9aca00
maxval = 1000
minval = -1000

.text

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ void main()
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   .align   2
   .code 32
   .type _start STT_FUNC
   .global _start
_start:
   stmfd   sp!, {r4,r5,lr}

.read_lhs:
   ldr r0, =max_rd_buf
   bl readint
   mov r4, r0
   bl printint
   mov r0, r4
   bl range_check

.read_rhs:
   ldr r0, =max_rd_buf
   bl readint
   mov r5, r0
   bl printint
   mov r0, r5
   bl range_check

.sum_and_print:
   adds r0, r4, r5
   bvs overflow
   bl printint

.main_exit:
   mov r0, #0
   bl exit
   ldmfd   sp!, {r4,r5,pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ Read from stdin until we encounter a non-digit, or we have read bytes2rd digits.
@@ Ignore leading spaces.
@@ Return value to the caller converted to a signed int.
@@ We read positive values, but if we read a leading '-' sign, we convert the
@@ return value to two's complement.
@@ The argument is max number of bytes to read from stdin.
@@ int readint(int bytes2rd)
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   .align   2
   .code 32
   .type readint STT_FUNC
   .global readint
readint:
   stmfd   sp!, {r4,r5,r6,r7,lr}
   @@@@@@@@@@@@@@@
   @@ r0 : #0 for stdin arg to read.
   @@ r1 : ptr to current pos in local buffer.
   @@ r2 : #1 to read one byte at a time.
   @@ r3,r7 : tmp.
   @@ r4 : number of bytes read.
   @@ r5 : value of current byte.
   @@ r6 : 0 while we are reading leading spaces.
   @@@@@@@@@@@@@@@
   sub sp, sp, r0
   mov r1, sp
   mov r3, #0
   push {r3}        @ sp,#4: local var @isnegative. return in r1. Default value is 0/false. Positive number.
   push {r0}        @ sp,#0: local var @maxbytes. const.
   mov r2, #1
   mov r4, #0

   mov r6, #0
   b .rd
@ we get here if r6 is 0.
@ if space, goto .rd.
@ else set r6 to 1 and goto .noleading.
.leadchk:
   mov r0, r5
   bl isspace
   cmp r0, #1
   beq .rd

.sign_chk:
   mov r0, r5
   push {r1}
   bl issign
   cmp r0, #1
   streq r0, [sp,#8]   @ sp,#4 + 4 for the pushed r1.
   movhi r1, #0
   strhi r1, [sp,#8]   @ sp,#4 + 4 for the pushed r1.
   pop {r1}
   bhs .rd

   mov r6, #1
   b .noleading

.rd:
   mov r0, #0
   bl read
   cmp r0, #1
   bne .sum_digits_eof  @ eof
   mov r5, #0
   ldrb r5, [r1]
   cmp r6, #0
   beq .leadchk

.noleading:
   mov r0, r5
   bl isdigit
   cmp r0, #1
   bne .sum_digits_nan @ r5 is non-digit

   add r4, r4, #1
   add r1, r1, #1
   @ max chars to read is received in arg[0], stored in local var at sp.
   @ Only 10 can be valid, so the default of 12 leaves space for separator.
   ldr r3, [sp]
   cmp r4, r3
   beq .sum_digits_maxrd  @ max bytes read.
   b .rd


   @@@@@@@@@@@@@@@
   @ We have read r4 (0..arg[0](default 12)) digits when we get here. Go through them
   @ and add/mul them together to calculate a number.
   @ We multiply and add the digits in reverse order to simplify the multiplication.
   @@@@@@@@@@@@@@@
   @ r0: return value.
   @ r1: local variable for read buffer.
   @ r2: tmp for conversion.
   @ r3,r6,r7: tmp
   @ r4: number of chars we have read.
   @ r5: multiplier 1,10,100.
   @@@@@@@@@@@@@@@
.sum_digits_nan:
   mov r0, r5
   bl isspace
   cmp r0, #1
   bne bad_input
.sum_digits_maxrd:
.sum_digits_eof:
   mov r0, #0
   mov r5, #1
.count:
   cmp r4, #0
   beq .readint_ret
   sub r4, r4, #1
   sub r1, #1
   ldrb r2, [r1]
   sub r2, r2, #48
   mov r3, r2

   @ multiply r3 (char value of digit) with r5 (multiplier).
   @ possible overflow.
   @ MI means negative.
   @ smulls multiples two signed 32 bit vals and returns a 64 bit result.
   @ If we get anything in r7, the value has overflowed.
   @ having r2[31] set is overflow too.
   smulls r2, r7, r3, r5
   cmp r7, #0
   bne overflow
   cmp r2, #0
   bmi overflow

   @@ possible overflow.
   adds r0, r0, r2
   bvs overflow
   bmi overflow

   @@ end of array check.
   @@ check is needed here too, for large numbers, since 10 billion is not a valid 32 bit val.
   cmp r4, #0
   beq .readint_ret

   @@ multiple multiplier by 10.
   @@ possible overflow.
   @@ too many digits is input. happens if input is more than 10 digits.
   mov r3, #10
   mov r6, r5
   smulls r5, r7, r3, r6
   cmp r7, #0
   bne overflow
   cmp r5, #0
   bmi overflow
   b .count

.readint_ret:
   ldr r1, [sp,#4] @ read isnegative value.
   cmp r1, #0
   rsbne r0, r0, #0
   pop {r2}
   add sp, sp, #4
   add sp, sp, r2
   ldmfd   sp!, {r4,r5,r6,r7,pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ int isdigit(int)
@@ #48..#57 ascii range for '0'..'9'.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   .align   2
   .code 32
   .type isdigit STT_FUNC
   .global isdigit
isdigit:
   stmfd   sp!, {r1,lr}
   cmp r0, #48
   blo .o_range
   cmp r0, #57
   bhi .o_range
   mov r0, #1
   ldmfd   sp!, {r1,pc}
.o_range:
   mov r0, #0
   ldmfd   sp!, {r1,pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ int isspace(int)
@@ ascii space = 32, tab = 9, newline 10, cr = 13.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   .align   2
   .code 32
   .type isspace STT_FUNC
   .global isspace
isspace:
   stmfd   sp!, {lr}
   cmp   r0, #32
   cmpne r0, #9
   cmpne r0, #10
   cmpne r0, #13
   beq .is_space
   mov r0, #0
   ldmfd   sp!, {pc}
.is_space:
   mov r0, #1
   ldmfd   sp!, {pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ Return value is 1 for '-' 2 for '+'.
@@ int isspace(int)
@@ '+' = 43 and '-' = 45.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   .align   2
   .code 32
   .type issign STT_FUNC
   .global issign
issign:
   stmfd   sp!, {lr}
   cmp   r0, #43
   beq .plus_sign
   cmp r0, #45
   beq .minus_sign
   mov r0, #0
   ldmfd   sp!, {pc}
.plus_sign:
   mov r0, #2
   ldmfd   sp!, {pc}
.minus_sign:
   mov r0, #1
   ldmfd   sp!, {pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ ARGS:
@@ r0 : in out arg (current int value)
@@ r1 : in out arg (ptr to current pos in buffer)
@@ r2 : in arg (const increment. 1000_000_000, 100_000_000, 10_000_000, 1000_000, 100_000, 10_000, 1000, 100, 10, 1.)
@@
@@ r4 : tmp local. Outer scope must init to #10 and count down to #0.
@@      Special case is INTMAX. Must init to 5 if r4 >= 1000_000_000 (0x3b9aca00 = m10_9).
@@ r5: tmp
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   .align   2
   .code 32
   .type get_digit STT_FUNC
   .global get_digit
get_digit:
   stmfd  sp!, {r2,r4,r5,lr}
   ldr r5, =m10_9
   cmp r2, r5
   movlo r4, #10
   movhs r4, #5
.get_digit_loop:
   sub r4, #1
   mul r5, r4, r2
   cmp r0, r5
   blo .get_digit_loop
   sub r0, r5
   add r4, r4, #48
   strb r4, [r1], #1
   ldmfd   sp!, {r2,r4,r5,pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ A quick way to divide (numbers evenly divisible by 10) by 10.
@@ Most ARM cpus don't have a divide instruction,
@@ so this will always work.
@@ A generic div function is long and not needed here.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   .align   2
.div_r2_10:
   stmfd   sp!, {r0,r1,r3,lr}
   mov r0, #1
   mov r1, #10
.find_x:
   mul r3, r0, r1;
   cmp r3, r2
   movlo r0, r3
   blo .find_x
   mov r2, r0
   ldmfd   sp!, {r0,r1,r3,pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   .align   2
.print_neg_sign:
   stmfd   sp!, {r0,r1,r2,lr}
   @ 45 = '-'
   mov r1, #45
   push {r1}
   mov r2, #1
   @ r1 is ptr to our local variable (holding '-').
   mov r1, sp
   mov r0, #1
   bl write
   cmp r0, #0
   blne io_error
   pop {r1}
   ldmfd   sp!, {r0,r1,r2,pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ void printint(int val)
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   .align   2
   .code 32
   .type printint STT_FUNC
   .global printint
printint:
   stmfd   sp!, {r4,r5,r6,lr}
   mov r1, #1
   ands r1, r1, r0, LSR #31
   rsbne r0, r0, #0
   blne .print_neg_sign
   sub sp, sp, #20
   mov r1, sp
   mov r3, sp

   ldr r2, =m10_9
.getc_loop:
   bl get_digit
   cmp r2, #1
   beq .exit_getc_loop
   bl .div_r2_10
   b .getc_loop
.exit_getc_loop:
   ldr r0, =lf
   strb r0, [r1], #1

   sub r2, r1, r3
   mov r1, r3
   mov r0, #1
   bl write
   cmp r0, #0
   blne io_error
   add sp, sp, #20
   ldmfd   sp!, {r4,r5,r6,pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   .align   2
range_check:
   stmfd   sp!, {r4,r5,lr}
   ldr r4, =minval
   ldr r5, =maxval
   cmp   r4, #0
   cmpeq r5, #0
   beq .skip_range_check
   cmp r0, r4
   bllt range_err
   cmp r0, r5
   blgt range_err
.skip_range_check:
   ldmfd   sp!, {r4,r5,pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ void range_err()
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   .align   2
range_err:
   stmfd   sp!, {lr}
   ldr r2, =range_err_msglen
   ldr r1, =range_err_msg
   mov r0, #2
   bl write
   mov   r0, #-1
   bl exit
   ldmfd   sp!, {pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ void overflow()
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   .align   2
overflow:
   stmfd   sp!, {lr}
   ldr r2, =overflow_msglen
   ldr r1, =overflow_msg
   mov r0, #2
   bl write
   mov   r0, #-1
   bl exit
   ldmfd   sp!, { pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ void bad_input()
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   .align   2
bad_input:
   stmfd   sp!, {lr}
   ldr r2, =bad_input_msglen
   ldr r1, =bad_input_msg
   mov r0, #2
   bl write
   mov   r0, #-1
   bl exit
   ldmfd   sp!, {pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ void io_error()
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   .align   2
io_error:
   stmfd   sp!, {lr}
   ldr r2, =io_error_msglen
   ldr r1, =io_error_msg
   mov r0, #2
   bl write
   mov   r0, #-1
   bl exit
   ldmfd   sp!, {pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ void exit(int)
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   .align   2
   .code 32
   .type _start STT_FUNC
   .global exit
exit:
   stmfd   sp!, {r7, lr}
   ldr r7, =sys_exit
   svc #0
   ldmfd   sp!, {r7, pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ int write(int fd,char*buf,int len)
@ Return 0 if we successfully write all bytes. Otherwise return the error code.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   .align   2
   .code 32
   .type _start STT_FUNC
   .global write
write:
   stmfd   sp!, {r4,r7, lr}
   mov r4, r2
.wr_loop:
   ldr r7, =sys_write
   svc #0
   @ If r0 is negative, it is more than r4 with LO (unsigned <).
   cmp r0, r4
   sublo r4, r0
   blo .wr_loop
   moveq r0, #0
   ldmfd   sp!, {r4,r7, pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ int read(int fd,char*buf,int len)
@ Return number of bytes successfully read. Ignore errors.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   .align   2
   .code 32
   .type _start STT_FUNC
   .global read
read:
   stmfd   sp!, {r7, lr}
   ldr r7, =sys_read
   svc #0
   cmp r0, #0
   movlt r0, #0
   ldmfd   sp!, {r7, pc}