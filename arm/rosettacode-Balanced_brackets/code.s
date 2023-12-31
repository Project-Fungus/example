.data

balanced_message:
  .ascii "OK\n"

unbalanced_message:
  .ascii "NOT OK\n"


.text

.equ balanced_msg_len, 3
.equ unbalanced_msg_len, 7


BalancedBrackets:

  mov r1, #0
  mov r2, #0
  mov r3, #0

  process_bracket:
    ldrb r2, [r0, r1]

    cmp r2, #0
    beq evaluate_balance

    cmp r2, #'['
    addeq r3, r3, #1
    
    cmp r2, #']'
    subeq r3, r3, #1

    cmp r3, #0
    blt unbalanced

    add r1, r1, #1
    b process_bracket

  evaluate_balance:
    cmp r3, #0
    beq balanced

    unbalanced:
       ldr r1, =unbalanced_message
       mov r2, #unbalanced_msg_len
       b display_result

    balanced:
       ldr r1, =balanced_message
       mov r2, #balanced_msg_len

    display_result:
      mov r7, #4
      mov r0, #1
      svc #0

      mov pc, lr