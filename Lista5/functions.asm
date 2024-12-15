;------------------------------------------
; void iprint(Integer number)
; Integer printing function (itoa)
iprint:
    push    eax
    push    ecx
    push    edx
    push    esi
    mov     ecx, 0; licznik znakow do wypisania
 
divideLoop:
    inc     ecx
    mov     edx, 0
    mov     esi, 10
    idiv    esi; dzielimy eax przez esi
    add     edx, 48
    push    edx; kladziemy reszte na stos
    cmp     eax, 0; nie dzielimy wiecej gdy eax==0
    jnz     divideLoop
 
printLoop:
    dec     ecx
    mov     eax, esp; kladziemy eax na stos
    call    sprint          ; call our string print function
    pop     eax; usuwamy ze stosu wypisany znak
    cmp     ecx, 0
    jnz     printLoop
 
    pop     esi
    pop     edx
    pop     ecx
    pop     eax
    ret
 
;------------------------------------------
; void iprintLF(Integer number)
; Integer printing function with linefeed (itoa)
iprintLF:
    call    iprint
 
    push    eax
    mov     eax, 0Ah
    push    eax
    mov     eax, esp ;ustawiamy eax na aktualny adres stosu
    call    sprint
    pop     eax
    pop     eax
    ret
 
;------------------------------------------
; int slen(String message)
; String length calculation function
slen:
    push    ebx
    cmp     eax, 0         ; sprawdź, czy wskaźnik nie jest pusty
    jz      finished       ; jeśli pusty, długość wynosi 0
    mov     ebx, eax

nextchar:
    cmp     byte [eax], 0  ; sprawdź, czy napotkano null-terminator
    jz      finished
    inc     eax
    jmp     nextchar

finished:
    sub     eax, ebx       ; oblicz długość (adres końca - początek)
    pop     ebx
    ret
 
;------------------------------------------
; void sprint(String message)
; String printing function
sprint:
    push    edx
    push    ecx
    push    ebx
    push    eax
    call    slen
 
    mov     edx, eax ;w edx siedzi dlugosc
    pop     eax
 
    mov     ecx, eax ;w ecx dajemy przywracanego stringa
    mov     ebx, 1 ;STDOUT
    mov     eax, 4 ;SYS_WRITE
    int     80h
 
    pop     ebx
    pop     ecx
    pop     edx
    ret
 
;------------------------------------------
; void sprintLF(String message)
; String printing with line feed function
sprintLF:
    call    sprint
 
    push    eax
    mov     eax, 0AH
    push    eax
    mov     eax, esp
    call    sprint
    pop     eax
    pop     eax
    ret
 
;------------------------------------------
; void exit()
; Exit program and restore resources
quit:
    mov     ebx, 0
    mov     eax, 1 ;SYS_EXIT
    int     80h
    ret

;-------------------------------------------
;void is_first(Integer number)

is_first:
    push	eax
    push	ecx
    push	ebx
    push	esi
    mov		esi, eax
    mov		ebx, 2 ;zaczynamy iterowac od 2 do liczby spawdzanej

check:
    cmp		ebx, esi
    jae		print
    xor		edx, edx
    mov		eax, esi
    div		ebx
    test	edx, edx ;sprawdza czy ecx!=0
    jz		end
    inc		ebx
    jmp		check

print:
    mov		eax, esi
    call	iprintLF

end:
    pop		esi
    pop		ebx
    pop		ecx
    pop		eax
    ret