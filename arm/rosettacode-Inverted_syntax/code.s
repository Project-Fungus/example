MOV R0,R3    ;copy R3 to R0
ADD R2,R1,R5 ;add R1 to R5 and store the result in R2.

STR r0,[r4] ;store the contents of R0 into the memory location specified by R4.

STMFD sp!,{r0-r12,lr} ;push r0 thru r12 and the link register
LDMFD sp!,{r0-r12,pc} ;pop r0 thru r12, and the value that was in the link register is popped into the program counter.