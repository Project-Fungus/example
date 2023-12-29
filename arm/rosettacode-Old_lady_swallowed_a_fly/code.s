.global _start
_start:	eor	r8,r8,r8	@ Verse counter
verse:	add	r8,r8,#1	@ Next verse
	ldr	r1,=lady	@ There was an old lady who swallowed...
	bl	pstr
	mov	r2,r8
	bl	pbeast		@ <an animal>
	ldr	r1,=comma
	bl	pstr
	mov	r2,r8
	bl	pverse		@ Print the corresponding verse
	cmp	r8,#1		@ First verse?
	beq	verse		@ Then we're not swallowing anything yet
	cmp	r8,#8		@ Otherwise, is the lady dead yet?
	moveq	r7,#1		@ If so, stop.	
	swieq	#0
	mov	r9,r8		@ Otherwise, start swallowing
swallo:	ldr	r1,=swa1	@ She swallowed the ...	
	bl	pstr
	mov	r2,r9		@ <current animal>
	bl	pbeast
	ldr	r1,=swa2	@ ...to catch the...
	bl	pstr
	sub	r9,r9,#1
	mov	r2,r9		@ <previous animal>
	bl	pbeast
	ldr	r1,=comma
	bl	pstr
	cmp	r9,#2		@ Print the associated verse for 2 and 1
	movle	r2,r9
	blle 	pverse
	cmp	r9,#1		@ Last animal?
	bgt	swallo		@ If not, keep swallowing
	b	verse		@ But if so, next verse
pverse:	ldr	r1,=verses	@ Print verse R2 
	b	pstrn
pbeast:	ldr	r1,=beasts	@ Print animal R2 
pstrn:	ldrb	r0,[r1],#1	@ R2'th string from R1 - get byte
	tst	r0,r0		@ Zero yet?
	bne	pstrn 		@ If not keep going
	subs	r2,r2,#1	@ Is this the right string?
	bne	pstrn		@ If not keep going
@ Print 0-terminated string starting at R1 using Linux.
pstr:	mov	r2,r1		@ Find end
1:	ldrb	r0,[r2],#1	@ Get current byte
	tst	r0,r0		@ Zero yet?
	bne	1b		@ If not keep scanning
	sub	r2,r2,r1	@ Calculate string length
	mov	r0,#1		@ 1 = Linux stdout
	mov	r7,#4		@ 4 = Linux write syscall
	push	{lr}		@ Keep link register
	swi 	#0		@ Do syscall 
	pop	{lr}		@ Restore link register
	bx	lr
lady:	.ascii	"There was an old lady who swallowed a "
beasts:	.ascii	"\0fly\0spider\0bird\0cat\0dog\0goat\0cow\0horse"
verses:	.ascii	"\0I don't know why she swallowed that fly - "
	.ascii	"Perhaps she'll die.\n\n"
	.ascii	"\0That wiggled and jiggled and tickled inside her!\n"
	.ascii	"\0How absurd to swallow a bird\n"
	.ascii	"\0Imagine that! She swallowed a cat!\n"
	.ascii	"\0What a hog to swallow a dog\n"
	.ascii	"\0She just opened her throat and swallowed that goat\n"
	.ascii	"\0I don't know how she swallowed that cow\n"
	.asciz	"\0She's dead, of course.\n"
swa1:	.asciz	"She swallowed the "
swa2:	.asciz	" to catch the "
comma:	.asciz	",\n"