.text
    .global _start
_start:
    mov r0, #0
    mov r7, #1
    svc #0

ProgramStart:
b ProgramStart ;don't do this on a real game boy, you'll drain the batteries faster than usual.