%include	'functions.asm'
SECTION .data
msg1	db	'Podaj ciag cyfr: ', 0h ; db to dane typu bajt - idealne dla ASCII
msg2	db	'Wynik to: ', 0h

SECTION .bss ; niezainicjalizowane zmienne statyczne - block started by symbol
sinput:		resb	255 ;resb rezerwuje bajty - tutaj w liczbie 255

SECTION .text
global _start
_start:
    ;printujemy polecenie
    mov		eax, msg1
    call	sprint

    ;wczytujemy dane ktore przechowujemy w sinput
    mov		edx, 255
    mov		ecx, sinput
    mov		ebx, 0 ;czytanie z STDIN
    mov		eax, 3 ;SYS_READ
    int		80h

    ; Dodajemy null-terminator na końcu wczytanego ciągu - zastepujemy go zamiast \n
    mov		byte [sinput + eax - 1], 0

    ;pod edx podstawiamy liczbe cyfr i zerujemy ebx
    mov		eax, sinput
    call	slen
    mov		edx, eax
    xor		ebx, ebx

loop:
    cmp		edx, 0 ;dopóki długosc nie wynosi zero to dalej dodajemy poszczegolne ctyfry
    jz		finish

    mov		ecx, sinput ;ustawiamy adres ecx na poczatek napisu
    dec		edx
    add		ecx, edx

    movzx	eax, byte [ecx] ;movzx zamiast mv bo zalezy nam na wyczyszczeniu wyzszych bitow aby koinwersja byla poprawna
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