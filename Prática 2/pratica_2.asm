Org 00h

rs equ p1.3
e equ p1.2 
	Main:
		clr rs
		call FuncS ;Modo de 4 bits
		call DispC	;Liga display e cursor
		call EntryM ;Deslocamento a direita	
	Next:
		call ScanKey ;Varre tecla
		setb rs
		clr a
		mov a, r7
		call SendC ;Mostra tecla pressionada
		cjne  r7, #'#', Next
	Fim: 
		sjmp Fim

clk:
	setb p1.2
	clr p1.2
ret

delay:
	mov r0, #50
	djnz r0, $
ret

FuncS:
			clr rs
			mov p1, #20h; Modo de 4 bits - LCD
			call clk
			call delay
			call clk
			mov p1, #80h
			call clk
			call delay
		Ret

DispC:
			mov p1, #00h
			call clk
			mov p1, #0f0h
			call clk
			call delay
		Ret

EntryM: 
			mov p1, #00h
			call clk
			mov p1, #60h
			call clk
			call delay
		Ret

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

stop:
	jmp $

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
	
end
		
