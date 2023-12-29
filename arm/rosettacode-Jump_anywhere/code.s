MOV PC,R0   ;loads the program counter with the value in R0. (Any register can be used for this)
LDR PC,[R0] ;loads the program counter with the 32-bit value at the memory location specified by R0

PUSH {R0-R12,LR}
POP {R0-R12,PC}

STMFD sp!,{r0-r12,lr}
LDMFD sp!,{r0-r12,pc}