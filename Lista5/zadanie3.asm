%include	'functions.asm'
SECTION .data
liczba	dd	123456
wynik	db	"00000000", 0
SECTION .text
global _start
_start:
    mov		eax, [liczba]
    mov		ebx, wynik
    mov		ecx, 8; dlugosc 32-bitowej liczby

loop:
    mov		edx, eax
    and		edx, 0xF
    add		dl, '0'
    cmp		dl, '9'
    jbe		nie_litera
    add		dl, 7; od A do F dla powyzej 9
nie_litera:
    mov		byte [ebx + ecx -1], dl
    shr		eax, 4
    loop loop

    mov		eax, wynik
    call	sprintLF
    call	quit