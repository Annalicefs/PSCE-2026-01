Org 0h

rs equ p1.3
e equ p1.2 

Main:
    clr rs
    call FuncS  ; Modo de 4 bits
    call DispC  ; Liga display e cursor
    call EntryM ; Deslocamento a direita

ResetCofre:
    ; Limpa o display (Comando 01h)
    clr rs
    mov A, #01h
    call SendC
    call DelayLongo ; Precisa de um tempinho extra para limpar a tela

    ; Posiciona o cursor na 1a linha (Comando 80h)
    clr rs
    mov A, #80h
    call SendC

    ; Mostra a mensagem inicial
    mov DPTR, #MsgPrompt
    call PrintString

    ; Prepara ponteiros para ler os 4 digitos
    mov R0, #30h ; R0 será o ponteiro para a RAM (endereços 30h a 33h)
    mov R1, #4   ; Contador para 4 teclas

ReadLoop:
    call ScanKey  ; Varre teclado, salva a tecla no R7
    mov A, R7
    mov @R0, A    ; Salva o dígito digitado na RAM
    inc R0

    ; Mostra '*' no lugar do número para esconder a senha
    setb rs
    mov A, #'*'
    call SendC

    djnz R1, ReadLoop ; Volta até ler os 4 dígitos

    ; --- Verifica a Senha (Senha fixada em "1234") ---
    mov A, 30h
    cjne A, #'1', WrongPass
    mov A, 31h
    cjne A, #'2', WrongPass
    mov A, 32h
    cjne A, #'3', WrongPass
    mov A, 33h
    cjne A, #'4', WrongPass

RightPass:
    ; Senha Correta
    clr rs
    mov A, #0C0h ; Posiciona cursor no começo da 2a linha
    call SendC

    mov DPTR, #MsgOk
    call PrintString
    sjmp WaitReset

WrongPass:
    ; Senha Incorreta
    clr rs
    mov A, #0C0h ; Posiciona cursor no começo da 2a linha
    call SendC

    mov DPTR, #MsgErro
    call PrintString

WaitReset:
    ; Trava o sistema até que a tecla '#' seja pressionada para reiniciar
    call ScanKey
    mov A, R7
    cjne A, #'#', WaitReset
    sjmp ResetCofre

; ====================================================
; FUNÇÕES NOVAS DE STRING E DELAY EXTRAS
; ====================================================

PrintString:
    clr A
    movc A, @A+DPTR
    jz EndString
    setb rs
    call SendC
    inc DPTR
    sjmp PrintString
EndString:
    ret

DelayLongo:
    mov R2, #20
DL1:
    call delay
    djnz R2, DL1
    ret

; ====================================================
; FUNÇÕES ORIGINAIS DO SEU CÓDIGO
; ====================================================

clk:
    setb p1.2
    clr p1.2
    ret

delay:
    mov r6, #50
    djnz r6, $
    ret

FuncS:
    clr rs
    mov p1, #20h; Modo de 4 bits - LCD
    call clk
    call delay
    call clk
    mov p1, #80h; LCD de 2 linhas
    call clk
    call delay
    ret

DispC:
    mov p1, #00h
    call clk
    mov p1, #0f0h; Liga LCD e cursor
    call clk
    call delay
    ret

EntryM: ;Deslocamento a direita
    mov p1, #00h
    call clk
    mov p1, #60h
    call clk
    call delay
    ret

SendC:
    mov C, Acc.7
    mov P1.7, C

    mov C, Acc.6
    mov P1.6, C

    mov C, Acc.5
    mov P1.5, C

    mov C, Acc.4
    mov P1.4, C
    call clk

    mov C, Acc.3
    mov P1.7, C

    mov C, Acc.2
    mov P1.6, C

    mov C, Acc.1
    mov P1.5, C

    mov C, Acc.0
    mov P1.4, C
    call clk
    call delay
    ret

ScanKey:
    clr P0.3
    call Icode0; Varre coluna
    setb P0.3
    JB F0, Done

    clr p0.2
    call Icode1
    setb P0.2
    JB F0, Done

    clr p0.1
    call Icode2
    setb P0.1
    JB F0, Done

    clr p0.0
    call Icode3
    setb P0.0
    JB F0, Done
    JMP ScanKey

done:
    clr f0
    ret

Icode0:
    jnb P0.4, keyc03
    jnb P0.5, keyc13
    jnb P0.6, keyc23
    ret

Icode1:
    jnb P0.4, keyc02
    jnb P0.5, keyc12
    jnb P0.6, keyc22
    ret

Icode2:
    jnb P0.4, keyc01
    jnb P0.5, keyc11
    jnb P0.6, keyc21
    ret

Icode3:
    jnb P0.4, keyc00
    jnb P0.5, keyc10
    jnb P0.6, keyc20
    ret

keyc03:
    setb f0
    call ESPSOL
    mov r7, #'3'
    ret

keyc13:
    setb f0
    call ESPSOL
    mov r7, #'2'
    ret

keyc23:
    setb f0
    call ESPSOL
    mov r7, #'1'
    ret

keyc02:
    setb f0
    call ESPSOL
    mov r7, #'6'
    ret

keyc12:
    setb f0
    call ESPSOL
    mov r7, #'5'
    ret

keyc22:
    setb f0
    call ESPSOL
    mov r7, #'4'
    ret

keyc01:
    setb f0
    call ESPSOL
    mov r7, #'9'
    ret

keyc11:
    setb f0
    call ESPSOL
    mov r7, #'8'
    ret

keyc21:
    setb f0
    call ESPSOL
    mov r7, #'7'
    ret

keyc00:
    setb f0
    call ESPSOL
    mov r7, #'#'
    ret

keyc10:
    setb f0
    call ESPSOL
    mov r7, #'0'
    ret

keyc20:
    setb f0
    call ESPSOL
    mov r7, #'*'
    ret

ESPSOL:
    mov a, p0
    anl a, #070h
    cjne a, #070h, ESPSOL 

    mov TMOD, #01h
    mov TH0, #8ah
    mov TL0, #0d0h
    setb tr0
    jnb tf0, $
    clr tr0
    clr tf0
    ret

; ====================================================
; STRINGS / MENSAGENS (Terminam sempre com 0)
; ====================================================
MsgPrompt: DB 45h, 6Eh, 74h, 65h, 72h, 20h, 50h, 49h, 4Eh, 3Ah, 00h
MsgOk: DB 41h, 63h, 63h, 65h, 73h, 73h, 20h, 47h, 72h, 61h, 6Eh, 74h, 65h, 64h, 00h
MsgErro: DB 41h, 63h, 63h, 65h, 73h, 73h, 20h, 44h, 65h, 6Eh, 69h, 65h, 64h, 00h
end
