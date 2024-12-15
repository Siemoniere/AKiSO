%include	'functions.asm'
SECTION .data
msg1	db	'Podaj ciag cyfr: ', 0h
msg2	db	'Wynik to: ', 0h

SECTION .bss
sinput:		resb	255

SECTION .text
global _start
_start:
    ;printujemy polecenie
    mov		eax, msg1
    call	sprint

    ;wczytujemy dane ktore przechowujemy w sinput
    mov		edx, 255
    mov		ecx, sinput
    mov		ebx, 0
    mov		eax, 3
    int		80h

    ; Dodajemy null-terminator na końcu wczytanego ciągu
    mov		byte [sinput + eax - 1], 0

    ;pod edx podstawiamy liczbe cyfr i zerujemy ebx
    mov		eax, sinput
    call	slen
    mov		edx, eax
    xor		ebx, ebx

loop:
    cmp		edx, 0 ;dopóki długosc nie wynosi zero to dalej dodajemy poszczegolne ctyfry
    jz		finish

    mov		ecx, sinput
    dec		edx
    add		ecx, edx

    movzx	eax, byte [ecx]
    sub		eax, '0'
    add		ebx, eax

    jmp		loop

;printujemy wynik
finish:
    mov		eax, msg2
    call	sprint
    mov		eax, ebx
    call	iprintLF
    ;konczymy
    call	quit