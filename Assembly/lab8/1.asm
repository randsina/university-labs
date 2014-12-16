.model small
.stack 100h
.data
	a dd 0
	b dd 0
	e dd 0
	h dd 0
	n dd 0
	k dd 0
	x dd 0
	temp dd 0
	store db 255 dup(?)
	
	message_n db "   | n = ", '$'
	message_x db "   x = ", '$'
	message_yx db "   Y(x) = ", '$'
	message_sx db "   S(x) = ", '$'
	message_enter_a db 0ah, 0dh, "a = ", '$'
	message_enter_b db "b = ", '$'
	message_enter_h db "h = ", '$'
	message_enter_e db "e = ", '$'
	message_too_big db "too big", '$'
	new_line db 0ah, 0dh, '$'

	two dd       01000000000000000000000000000000b
	four dd 	 01000000100000000000000000000000b
.code
.386



GetFloat proc near
	push dx si
	push bp
	mov  bp, sp
	push 10
	push 0

	xor si, si								; В si храним знак
	fldz									; Начнём накапливать число. Сначала это ноль

	mov ah, 01h								; Вводим первый символ. Это может быть минус
	int 21h		
	cmp al, '-'		
	jne short GPlus		

	inc si									; Если это минус, запоминаем это

GLoopInt:		
	mov ah, 01h 							; и вводим следующую цифру.
	int 21h		

GPlus:										; Если введена точка, то пора переходить к формированию дробной части
	cmp al, '.'		
	je short GComma							; Ну а если нет, то проверим, что ввели цифру

	cmp al, 39h		
	ja short GNotNumberInt		
	sub al, 30h		
	jb short GNotNumberInt		
	mov [bp - 4], al						; Cохраним её во временной ячейке и допишем к текущему результату справа,

	fimul word ptr [bp - 2]					; То есть умножим уже имеющееся число на десять
	fiadd word ptr [bp - 4]					; И прибавим только что обретённую цифру
	jmp short GLoopInt						; И так, пока не надоест

GComma:
	fld1									; Если собрались вводить дробную часть, то запасёмся единицей

GLoopFloat:
	mov ah, 01h								; Вводим нечто
	int 21h

	cmp al, 39h								; Если это не цифра, сдаёмся.
	ja short GNotNumberFloat	
	sub al, 30h	
	jb short GNotNumberFloat	

	mov [bp - 4], al						; Иначе сохраняем её во временной ячейке,
	fidiv word ptr [bp - 2]					; получаем очередную отрицательную степень десятки,
	fld st(0)								; дублируем её,
	fimul word ptr [bp - 4]					; помножаем на введённую цифру, тем самым получая её на нужном месте,
	faddp st(2), st							; и добавляем к текущему результату

	jmp short GLoopFloat					; Опять-таки, пока не надоест

GNotNumberFloat:							; Если ввод дробной части закончен, нам больше не нужна степень десятки.
	fstp st(0)

GNotNumberInt:
	test si, si								; Осталось вспомнить про знак.
	jz short GFinish
	fchs

GFinish:
	leave
	pop si dx
	ret
GetFloat endp



WriteFloat proc near
	push ax cx dx
	fsave store
	frstor store
	push bp
	mov bp, sp
	push 10
	push 0
	
	ftst								; Проверяем число на знак, и если оно отрицательное,
	fstsw ax
	sahf
	jnc WPositive

	mov ah, 02h							; то выводим минус
	mov dl, '-'
	int 21h

	fchs								; и оставляем модуль числа

WPositive:
	fld1								; Отделим целую часть от дробной
	fld st(1)
	fprem 								; Остаток от деления на единицу даст дробную часть.
	fsub st(2), st 						; Если вычесть её из исходного числа, получится целая часть.
	fxch st(2)		
	xor cx, cx							; Сначала поработаем с целой частью. Считать количество цифр будем в CX.

WLoopInt:         		
	fidiv word ptr [bp - 2]				; Поделим целую часть на десять,
	fxch st(1)
	fld st(1)

	fprem								; отделим дробную часть - очередную справа цифру целой части исходного числа,

	fsub st(2), st						; от чатсного оставим только целую часть

	fimul word ptr [bp - 2]				; и сохраним цифру
	fistp word ptr [bp - 4]	
	inc cx	

	push word ptr [bp - 4]				; в стеке.
	fxch st(1)	

	ftst								; Так будем повторять, пока от целой части не останется ноль.
	fstsw ax
	sahf
	jnz short WLoopInt

	mov ah, 02h								; Теперь выведем её.

WLoopPrint:			
	pop dx			
	add dl, 30h								; Вытаскиваем очередную цифру, переводим её в символ и выводим.
	int 21h			

	loop WLoopPrint							; И так, пока не выведем все цифры.

	fstp st(0)								; Итак, теперь возьмёмся за дробную часть, для начала проверив её существование.
	fxch st(1)
	ftst
	fstsw ax
	sahf
	jz short WFinish

	mov ah, 02h								; Если она всё-таки ненулевая, выведем точку
	mov dl, '.'	
	int 21h	

	mov cx, 8								; и не более 8 цифр дробной части

WLoopFloat:
	fimul word ptr [bp - 2]					; Помножим дрообную часть на десять,
	fxch st(1)
	fld st(1)
	fprem									; отделим целую часть - очередную слева цифру дробной части исходного числа,
	fsub st(2), st							; оставим от произведения лишь дробную часть,
	fxch st(2)

	fistp word ptr [bp - 4]					; сохраним полученную цифру во временной ячейке

	mov ah, 02h								; и сразу выведем
	mov dl, [bp - 4]
	add dl, 30h
	int 21h

	fxch st(1)								; Теперь, если остаток дробной части ненулевой
	ftst
	fstsw ax
	sahf

	loopnz WLoopFloat						; и мы вывели менее шести цифр, продолжим

WFinish:
	fstp st(0)								; Итак, число выведено. Осталось убрать мусор из стеков.
	fstp st(0)

	leave
	frstor store
	pop dx cx ax
	ret
WriteFloat endp


fpower		proc
		; st0=X, st1=Y

		ftst                   ; st0=X=0 ?
		fstsw	ax
		sahf
		jz	@@Zero         ; Да, результат = 0 (CF=NC=0, кстати!)
		mov	bl,ah          ; BL and 1=1 при X<0, 0 при X>0 (исп-ся после получения результата)
		ja	@@PositiveX    ; Если X>0, то никаких проверок нам больше не надо

		fxch                   ; Обмен st0 <-> st1 (st0=Y, st1=X)
		fld	st(0)          ; st2=st1=X, st1=st0=Y, st0=st0=Y
		frndint                ; st0=Round(st0)=Round(Y)
		fcomp                  ; Сраниваем st0 и st1; st0=st1=Y, st1=st2=X, st3=пусто
		fstsw	ax             ; В AH флаг ZF=ZR=1 при целом Y
		sahf                   ; Y целое?
		jnz	@@Error        ; Нет, отрицательные числа нельзя возводить в нецелую степень!

		fld1
		fld1
		fadd                   ; st2=st1=X, st1=st0=Y, st0=2
		fld	st(1)          ; st3=st2=X, st2=st1=Y, st1=st0=2, st0=st1=Y
		fprem                  ; st0=st0 mod st1=Y mod 2
		ftst                   ; st0=0 (Y mod 2=0, т.е. чётное) ?
		fstsw	ax             ; В AH флаг ZF=ZR=1 при чётном Y (CF=NC=0, кстати!)
		fstp	st(0)          ; Удаляем остаток от деления
		fstp	st(0)          ; Удаляем число 2 (st0), st0=st1=Y, st1=st2=X, st2=пусто
		fxch                   ; Обмен st0 <-> st1 (st0=X, st1=Y)
@@PositiveX:
		fabs                   ; st0=|st0|=|X|
		fyl2x                  ; st0 = st1*log2(st0) = Y*log2(|X|)
		fld	st(0)          ; st1=st0
		frndint                ; st0=Round(st0)
		fsub	st(1),st(0)    ; st1=st1-st0
		fld1                   ; st1=st0, st0=1
		fscale                 ; st0=st0*2^st1
		fstp	st(1)          ; Удаляем st1
		fincstp                ; st7=st0, st0=st1
		f2xm1                  ; st0=(2^st0)-1
		fmul	st(0),st(7)    ; st0=st0*st7
		fdecstp                ; st1=st0, st0=st7
		fadd                   ; st0=st0+st1, st0=пусто
		; Результат в st0 !!!

		test	bl,1           ; X<0 ? (CF=NC=0, кстати!)
		jz	@@End          ; Нет, завершаем
		sahf                   ; Y чётное
		jz	@@End          ; Да, завершаем
		fchs                   ; Если X<0, а Y нечётное, то меняем знак результата
@@End:		ret                    ; Выходим!
@@Error:
		fldz                   ; Заносим 0
		fstp	st(1)          ; Удаляем X
		stc                    ; CF=CY=1 - ошибка
@@Zero:
		fstp	st(1)          ; Удаляем Y
		ret                    ; Выходим!

fpower		endp



PrintNumber PROC
	pusha									; Приготовления
	
	test ax, 1000000000000000b				; Отрицательное ли наше число
	jns PrintNumberNotNeg
	neg ax									; Если да - то меняем знак, и работаем, как с обычным
	push ax
	mov dl, '-'								; Вдобавок выведем минус
	mov ah, 02h
	int 21h	
	pop ax
	
PrintNumberNotNeg:	
	mov bx, 10
	xor cx, cx
	xor dx, dx
	
DivideAgain:
	div bx										; Делим на 10, частное - в ax, остаток в dx и в стек
	inc cx
	push dx
	xor dx, dx
	cmp ax, 0									; До тех пор, пока частное не станет равным 0
	ja DivideAgain

	mov ah, 02h
	
PrintSymbol:									; Выводим на экран циклом из стека
	pop dx
	add dl, 30h									; Из цифры - код символа
	int 21h	
	loop PrintSymbol	
	
	popa
	ret
PrintNumber ENDP


Sx proc
	push ecx
	xor ecx, ecx
	
	finit										; Инициализация

	fld x										; Конечный результат для k = 0
	fld x										; x^0
	fld x										; 0!
	
	mov k, 0									; k = 0
	inc ecx

SLoop:
	cmp ecx, n
	ja SExit
	
	inc ecx

	inc k										; Увеличиваем k
	fld four
			fld k
			fmul	; st = 4 * K
			
			

			fld1
			fadd	; st = 4 * K + 1
			fld x	; st = X, 4 * K + 1

			call fpower	; st = X^(4K+1), 4 * k + 1

			fld1		; st = 1, X^(4K+1), 4 * k + 1
			fdivp st(2), st ; st = 1 / (4 * k + 1), X^(4K+1)

			fmul 	; st = 1 / (4 * K + 1) * X^(4K+1)
			

	faddp st(6), st								; Складываем с предыдущим значением
	jmp SLoop
	
SExit:	
	fstp st
	fstp st
	pop ecx										; Выход
	ret
Sx endp


Yx proc	
	finit										; Инициализация

	; Y(x) = 1/4 * ln((1 + x)/(1 - x)) + 1/2 * arctan(x)
	

			fld x
			fld1
			fpatan

			fld1
			fld two  ; st = 1, 2, arctg(x)
			fdiv     ; st = 1/2, arctg(x)

			fmul     ; st = 1/2 * arctg(x)
			
			fld1
			fld four

			fdiv	 ; st = 1/4, 1/2 * arctg(x)
			

			fld1
			fld x
			fsub	 ; st = 1 - X, 1/4, 1/2 * arctg(x)
			
			
			fld x
			fld1
			
			fadd	 ; st = 1 + X, 1 - X, 1/4, 1/2 * arctg(x)
			

			fdiv	 ; st = (1 + X)/(1 - X), 1/4,  1/2 * arctg(x)
			
			fyl2x
			
			fldln2
			
			fmul	 ; st = 1/4 * ln((1 + X)/(1 - X)), 1/2 * arctg(x)
			fchs
			
			fadd	 ; st = 1/4 * ln((1 + X)/(1 - X)) + 1/2 * arctg(x)
	fstp 
	
	;fmulp
	
	ret
Yx endp


CalcN proc
	push eax
	
	finit
	lea dx, message_x
	mov ah, 09h
	int 21h	
	
	fld x
	call WriteFloat
	
	mov n, 0
	
CLoop:
	cmp n, 8000h
	ja CExit

	call Sx
	fstp temp
	call Yx
	fsub temp
	fabs
	
	inc n
	fcom e   
	fstsw ax 
	fwait    
	sahf 
	ja CLoop
	
CExit:
	;dec n
	
	lea dx, message_sx
	mov ah, 09h
	int 21h	
	
	fld temp
	call WriteFloat
	fstp st
	
	call Yx
	
	lea dx, message_yx
	mov ah, 09h
	int 21h
	
	call WriteFloat
	
	lea dx, message_n
	mov ah, 09h
	int 21h
	
	mov eax, n
	cmp eax, 8000h
	je CBig
	
	call PrintNumber
	jmp CFinish

CBig:	
	lea dx, message_too_big
	mov ah, 09h
	int 21h
	
CFinish:
	pop eax
	ret
CalcN endp


start:
	mov ax, @data								; Инициализация
	mov ds, ax

	lea dx, message_enter_a						;   ввести a
	mov ah, 09h
	int 21h

	call GetFloat
	fstp x
	
	lea dx, message_enter_b						;   ввести b
	mov ah, 09h
	int 21h

	call GetFloat
	fstp b
	
	lea dx, message_enter_h						;   ввести h
	mov ah, 09h
	int 21h

	call GetFloat
	fstp h	
	
	lea dx, message_enter_e						;   ввести e
	mov ah, 09h
	int 21h

	call GetFloat
	fstp e	
	
mtable:	
	call CalcN
	
	lea dx, new_line
	mov ah, 09h
	int 21h

	fld x
	fld h
	faddp
	fst x
	
	fcom b
	fstsw ax 
	fwait    
	sahf
	fstp st
	jbe mtable

finish:
	mov ah, 4ch
	int 21h
end start