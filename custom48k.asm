
        org     0

;       RST $00
        di                  ; 0
        jp      START       ; 1 2 3
        defb    0,0,0,0     ; 4 5 6 7
;       RST $08
        defb    0,0,0,0,0,0,0,0
;       RST $10
        defb    0,0,0,0,0,0,0,0
;       RST $18
        defb    0,0,0,0,0,0,0,0
;       RST $20
        defb    0,0,0,0,0,0,0,0
;       RST $28
        defb    0,0,0,0,0,0,0,0
;       RST $30
        defb    0,0,0,0,0,0,0,0
;       RST $38
        defb    0,0,0,0,0,0,0,0

; ======================================================================

START:

        ld      sp, 0
        ld      a, 0x08 + 7
        call    CLS

        ld      bc, $0B02
        ld      hl, DFSTR
        call    PSTR

.r1:    inc     a
        and     7
        out     (254), a
        nop
        nop
        jr      .r1

; Строка
DFSTR:  defb    "ZcasperX, GameZone greetings",0

; ======================================================================
; Вывод строки из HL в BC

PSTR:   ld      a, (hl)
        and     a
        ret     z
        call    PCHAR
        inc     c
        inc     hl
        jr      PSTR

; ======================================================================
; Очистить экран в цвет A

CLS:    ld      bc, 0x02FF
        ld      hl, 0x5800  ; Отсюда копировать
        ld      de, 0x5801  ; Сюда
        ld      (hl), a     ; Байт инициализации
        rrca
        rrca
        rrca
        out     (254), a    ; Цвет бордера
        ldir                ; Копировать из (HL) -> (DE), HL++, DE++
        xor     a
        ld      hl, 0x4000
        ld      de, 0x4001
        ld      bc, 0x17FF
        ldir                ; Очистить графическую область
        ret

; ======================================================================
; Вычислить адрес символа A => HL

SYMADDR:

        push    de
        sub     0x20        ; A = Sym - 0x20
        ld      h, 0        ; HL = A
        ld      l, a
        add     hl, hl
        add     hl, hl
        add     hl, hl      ; HL = A << 3
        ld      de, FONT
        add     hl, de
        pop     de
        ret

; ======================================================================
; Вычисление адреса в видеопамяти по знакоместу
; Вход:  B(Y=0..23), C(X=0..31)
; Выход: HL(адрес)

ACURSOR:

        ld      a, c
        and     0x1f
        ld      l, a        ; L = X & 31
        ld      a, b
        and     0x07        ; Нужно ограничить 3 битами
        rrca                ; Легче дойти с [0..2] до позиции [5..7]
        rrca                ; Если вращать направо
        rrca                ; ... три раза
        or      l           ; Объединив с 0..4 уже готовыми ранее
        ld      l, a        ; Загрузить новый результат в L
        ld      a, b        ; Т.к. Y[3..5] уже на месте
        and     0x18        ; Его двигать даже не надо
        or      0x40        ; Ставим видеоадрес $4000
        ld      h, a        ; И загружаем результат
        ret

; ======================================================================
; Печать символа A в BC
; Вход: B(y=0..23), C(x=0..31) A(символ)

PCHAR:

        push    bc
        push    de
        push    hl
        call    SYMADDR     ; HL=Адрес символа в памяти
        ex      de, hl      ; DE теперь тут
        call    ACURSOR     ; HL=Адрес видеопамяти
        ld      b, 8        ; Повторить 8 раз
.pc1:   ld      a, (de)     ; Прочитать 8 бит
        ld      (hl), a     ; Записать 8 бит
        inc     h           ; Y = Y + 1 согласно модели памяти
        inc     de          ; К следующему байту
        djnz    .pc1        ; Рисовать 8 строк
        pop     hl
        pop     de
        pop     bc
        ret

FONT:   incbin  "src/font.bin"
