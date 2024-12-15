%include	'functions.asm'
SECTION .data
msg1	db	'Suma elementow: ', 0h
msg2	db	'Suma przekatnej: ', 0h
macierz	dd	1, 2, 3, 4, 5, 6, 7, 8, 9 ;tu ustalamy wartosci macierzy 3x3
x	dd	0
y	dd	0
SECTION .text
global _start
_start:

    xor		eax, eax ;eax to wynik
    mov		ecx, 9 ;pod ecx ustalamy ilosc elementow macierzy 3x3
    lea		edx, [macierz] ;pod edx mamy wskaznik do macierzy

loop:
    cmp		ecx, 0
    jz		next
    dec		ecx
    mov		ebx, [edx] ;pod ebx mamy wartosc pod aktualnym adresem edx
    add		eax, ebx
    add		edx, 4 ;przesuwamy o 4 bajty
    jmp		loop

next:
    mov		[x], eax ;sume przekierowujemy do wartosci x
    xor		eax, eax
    mov		ecx, 3 ;ilosc liczb na przekatnej
    lea		edx, [macierz]

;nastepna petla to juz analogia
next_loop:
    cmp		ecx, 0
    jz		finish
    dec		ecx
    mov		ebx, [edx]
    add		eax, ebx
    add		edx, 16; przesuwamy o 4 liczby czyli 4*4=16 bajtow
    jmp		next_loop

finish:
    mov		[y], eax
    mov		eax, msg1
    call	sprint
    mov		eax, [x]
    call	iprintLF
    mov		eax, msg2
    call	sprint
    mov		eax, [y]
    call	iprintLF
    call	quit