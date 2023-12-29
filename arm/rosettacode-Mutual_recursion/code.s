.text
.global _start
	@@@	Implementation of F(n), n in R0. n is considered unsigned.
F:	tst	r0,r0		@ n = 0?
	moveq	r0,#1		@ In that case, the result is 1
	bxeq	lr		@ And we can return to the caller
	push	{r0,lr}		@ Save link register and argument to stack
	sub	r0,r0,#1	@ r0 -= 1    = n-1
	bl	F		@ r0 = F(r0) = F(n-1)
	bl	M		@ r0 = M(r0) = M(F(n-1))
	pop	{r1,lr}		@ Restore link register and argument in r1
	sub	r0,r1,r0	@ Result is n-F(M(n-1))
	bx	lr		@ Return to caller.

	@@@	Implementation of M(n), n in R0. n is considered unsigned.
M:	tst	r0,r0		@ n = 0?
	bxeq	lr		@ In that case the result is also 0; return.
	push	{r0,lr}		@ Save link register and argument to stack
	sub	r0,r0,#1	@ r0 -= 1    = n-1
	bl	M		@ r0 = M(r0) = M(n-1)
	bl	F		@ r0 = M(r0) = F(M(n-1))
	pop	{r1,lr}		@ Restore link register and argument in r1
	sub	r0,r1,r0	@ Result is n-M(F(n-1))
	bx	lr		@ Return to caller

	@@@	Print F(0..15) and M(0..15)
_start:	ldr	r1,=fmsg	@ Print values for F
	ldr	r4,=F
	bl	prfn
	ldr	r1,=mmsg	@ Print values for M
	ldr	r4,=M
	bl	prfn
	mov	r7,#1		@ Exit process
	swi	#0
	
	@@@	Helper function for output: print [r1], then [r4](0..15)
	@@@	This assumes [r4] preserves r3 and r4; M and F do.
prfn:	push	{lr}		@ Keep link register
	bl	pstr		@ Print the string
	mov	r3,#0		@ Start at 0
1:	mov	r0,r3		@ Call the function in r4 with current number	
	blx	r4
	add	r0,r0,#'0	@ Make ASCII digit
	ldr	r1,=dgt		@ Store in digit string
	strb	r0,[r1]
	ldr	r1,=dstr	@ Print result
	bl	pstr
	add	r3,r3,#1	@ Next number
	cmp	r3,#15		@ Keep going up to and including 15
	bls	1b
	ldr	r1,=nl		@ Print newline afterwards
	bl	pstr
	pop	{pc}		@ Return to address on stack
	@@@	Print length-prefixed string r1 to stdout
pstr:	push	{lr}		@ Keep link register
	mov	r0,#1		@ stdout = 1
	ldrb	r2,[r1],#1	@ r2 = length prefix
	mov	r7,#4		@ 4 = write syscall
	swi	#0
	pop	{pc}		@ Return to address on stack
.data
fmsg:	.ascii	"\3F: "
mmsg:	.ascii	"\3M: "
dstr:	.ascii	"\2"
dgt:	.ascii	"* "
nl:	.ascii 	"\1\n"


F: 1 1 2 2 3 3 4 5 5 6 6 7 8 8 9 9
M: 0 0 1 2 2 3 4 4 5 6 6 7 7 8 9 9