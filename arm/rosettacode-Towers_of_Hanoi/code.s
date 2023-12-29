.text
.global	_start
_start:	mov	r0,#4		@ 4 disks,
	mov	r1,#1		@ from pole 1,
	mov	r2,#2		@ via pole 2,
	mov	r3,#3		@ to pole 3.
	bl	move
	mov	r0,#0		@ Exit to Linux afterwards
	mov	r7,#1
	swi	#0
	@@@	Move r0 disks from r1 via r2 to r3
move:	subs	r0,r0,#1	@ One fewer disk in next iteration
	beq	show		@ If last disk, just print move
	push	{r0-r3,lr}	@ Save all the registers incl. link register
	eor	r2,r2,r3	@ Swap the 'to' and 'via' registers
	eor	r3,r2,r3
	eor	r2,r2,r3
	bl	move		@ Recursive call
	pop	{r0-r3}		@ Restore all the registers except LR
	bl	show		@ Show current move
	eor	r1,r1,r3	@ Swap the 'to' and 'via' registers
	eor	r3,r1,r3
	eor	r1,r1,r3
	pop	{lr}		@ Restore link register
	b	move		@ Tail call
	@@@	Show move
show:	push	{r0-r3,lr}	@ Save all the registers
	add	r1,r1,#'0	@ Write the source pole
	ldr	lr,=spole
	strb	r1,[lr] 
	add	r3,r3,#'0	@ Write the destination pole
	ldr	lr,=dpole
	strb	r3,[lr]
	mov	r0,#1		@ 1 = stdout
	ldr	r1,=moves	@ Pointer to string
	ldr	r2,=mlen	@ Length of string
	mov	r7,#4		@ 4 = Linux write syscall
	swi	#0 		@ Print the move
	pop	{r0-r3,pc}	@ Restore all the registers and return
.data
moves:	.ascii	"Move disk from pole "
spole:	.ascii	"* to pole "
dpole:	.ascii	"*\n"
mlen	=	. - moves


Move disk from pole 1 to pole 2
Move disk from pole 1 to pole 3
Move disk from pole 3 to pole 1
Move disk from pole 1 to pole 2
Move disk from pole 2 to pole 3
Move disk from pole 2 to pole 1
Move disk from pole 1 to pole 2
Move disk from pole 1 to pole 3
Move disk from pole 3 to pole 1
Move disk from pole 3 to pole 2
Move disk from pole 2 to pole 3
Move disk from pole 3 to pole 1
Move disk from pole 1 to pole 2
Move disk from pole 1 to pole 3
Move disk from pole 3 to pole 1