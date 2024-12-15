%include	'functions.asm'
SECTION .text
global _start
_start:
    mov		eax, 2

loop:
    cmp		eax, 100001
    jz		finish
    call	is_first
    inc		eax
    jmp		loop

finish:
    call	quit