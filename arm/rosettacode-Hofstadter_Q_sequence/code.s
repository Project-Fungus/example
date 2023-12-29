.text
.global _start
_start:	ldr	r6,=qs			@ R6 = base register for Q array
	@@@	Write first 2 elements
	mov	r0,#1			@ Q(1) and Q(2) are 1
	strh	r0,[r6,#4]
	strh	r0,[r6,#8]
	@@@ 	Generate 100 thousand elements
	mov	r1,#0x86A0		
	movt	r1,#1			@ 0x186A0 = 100.000
	mov	r0,#3			@ Starting at element 3
1:	sub	r2,r0,#1		@ r2 = n-1
	ldr	r2,[r6,r2,lsl#2]	@ r2 = Q[r2]
	sub	r2,r0,r2		@ r2 = n-Q[r2]
	ldr	r2,[r6,r2,lsl#2]	@ r2 = Q[r2]
	sub	r3,r0,#2		@ r3 = n-2
	ldr	r3,[r6,r3,lsl#2]	@ r3 = Q[r3]
	sub	r3,r0,r3		@ r3 = n-Q[r3]
	ldr	r3,[r6,r3,lsl#2]	@ r3 = Q[r3]
	add	r2,r2,r3		@ r2 += r3
	str	r2,[r6,r0,lsl#2]	@ Q[n] = r2
	add	r0,r0,#1		@ n++
	cmp	r0,r1
	bls	1b			@ If r0<=r1, generate next
	@@@	Print first 10 elements
	ldr 	r1,=f10m
	bl	pstr
	mov	r8,#1			@ Start at element 1
1:	ldr	r0,[r6,r8,lsl#2]	@ Grab current element
	bl	pnum			@ Print it
	ldr	r1,=space		@ Print a space
	bl 	pstr
	add	r8,r8,#1
	cmp	r8,#10			@ Keep going until 10 elements printed
	bls	1b 
	ldr 	r1,=nl 			@ Print newline
	bl	pstr
	@@@	Print 1000th element
	ldr	r1,=f1000m
	bl	pstr
	mov	r8,#1000		@ Grab 1000th element
	ldr	r0,[r6,r8,lsl#2]
	bl	pnum
	ldr	r1,=nl 			@ Print newline
	bl	pstr
	@@@	Find how many times a member is less than its preceding term
	mov	r0,#0 			@ counter
	mov	r1,#0x86A0		@ max element
	movt	r1,#1 
	mov	r2,#1			@ value of previous element
	mov	r3,#2			@ number of current element
2:	ldr	r4,[r6,r3,lsl#2]	@ get value of current element
	cmp	r2,r4			@ if previous more than current
	addhi	r0,r0,#1		@ then increment counter
	mov	r2,r4			@ current el is now prevous el
	add	r3,r3,#1		@ increment element index
	cmp	r3,r1			@ are we there yet?
	bls 	2b			@ if not, keep going
	bl	pnum			@ otherwise, print the number
	ldr	r1,=ltermm		@ and the corresponding message
	bl	pstr
	mov	r0,#0			@ and then exit
	mov	r7,#1
	swi	#0
	@@@	Print a length-prefixed string (in r1)
pstr:	push	{r7,lr}			@ Save syscall and link registers
	mov	r0,#1			@ 1 = stdout
	ldrb	r2,[r1],#1		@ Get length and advance r1
	mov	r7,#4			@ Write
	swi	#0
	pop	{r7,pc}
	@@@	Print unsigned number in r0 using Linux
pnum:	push	{r7,lr}			@ Save syscall and link registers
	ldr	r7,=qs			@ May as well use R7 as buffer pointer
1:	mov	r1,#10			@ Div-mod by 10
	bl	divmod
	add	r1,r1,#'0		@ This makes an ASCII digit
	strb	r1,[r7,#-1]!		@ Store it in the buffer
	tst	r0,r0 			@ Are there more digits?
	bne	1b			@ If so, calculate them
	mov	r0,#1			@ 1 = stdout
	mov	r1,r7			@ Start of number in R1
	ldr	r2,=qs			@ Calculate length
	sub	r2,r2,r1
	mov	r7,#4			@ 4 = write
	swi	#0 
	pop	{r7,pc}
	@@@	Division routine: r0=r0/r1, r1=r0%r1
divmod:	mov	r2,#0			@ R2 = counter
1:	cmp	r1,r0			@ Double R1 until R1>R0
	lslls	r1,r1,#1
	addls	r2,r2,#1
	bls	1b
	mov	r3,#0
2:	lsl	r3,r3,#1
	subs	r0,r0,r1		@ Trial subtraction
	addhs	r3,r3,#1		@ If it worked, mark
	addlo	r0,r0,r1		@ If it didn't, undo
	lsr	r1,r1,#1		@ Halve R1
	subs	r2,r2,#1		@ Decrement counter
	bhs	2b			@ Keep going until zero
	mov	r1,r0			@ R1 = modulus
	mov	r0,r3			@ R0 = quotient
	bx	lr
.data
space:	.ascii	"\x1 "
nl:	.ascii 	"\x1\n"
f10m:	.ascii	"\x18The first 10 terms are: "
f1000m:	.ascii	"\x14The 1000th term is: "
ltermm:	.ascii	"' terms were preceded by a larger term.\n"
.bss
.align  4
	.space	8			@ Buffer for number output
qs:     .space  4 * 100001 		@ One word per term


The first 10 terms are: 1 1 2 3 3 4 5 5 6 6
The 1000th term is: 502
49798 terms were preceded by a larger term.