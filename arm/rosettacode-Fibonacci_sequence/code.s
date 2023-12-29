fibonacci:
        push  {r1-r3}
        mov   r1,  #0
        mov   r2,  #1
        
fibloop:
        mov   r3,  r2
        add   r2,  r1,  r2
        mov   r1,  r3
        sub   r0,  r0,  #1
        cmp   r0,  #1
        bne   fibloop
        
        mov   r0,  r2
        pop   {r1-r3}
        mov   pc,  lr