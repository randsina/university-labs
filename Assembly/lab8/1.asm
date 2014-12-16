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

	xor si, si								; � si ������ ����
	fldz									; ����� ����������� �����. ������� ��� ����

	mov ah, 01h								; ������ ������ ������. ��� ����� ���� �����
	int 21h		
	cmp al, '-'		
	jne short GPlus		

	inc si									; ���� ��� �����, ���������� ���

GLoopInt:		
	mov ah, 01h 							; � ������ ��������� �����.
	int 21h		

GPlus:										; ���� ������� �����, �� ���� ���������� � ������������ ������� �����
	cmp al, '.'		
	je short GComma							; �� � ���� ���, �� ��������, ��� ����� �����

	cmp al, 39h		
	ja short GNotNumberInt		
	sub al, 30h		
	jb short GNotNumberInt		
	mov [bp - 4], al						; C������� � �� ��������� ������ � ������� � �������� ���������� ������,

	fimul word ptr [bp - 2]					; �� ���� ������� ��� ��������� ����� �� ������
	fiadd word ptr [bp - 4]					; � �������� ������ ��� ��������� �����
	jmp short GLoopInt						; � ���, ���� �� �������

GComma:
	fld1									; ���� ��������� ������� ������� �����, �� �������� ��������

GLoopFloat:
	mov ah, 01h								; ������ �����
	int 21h

	cmp al, 39h								; ���� ��� �� �����, ������.
	ja short GNotNumberFloat	
	sub al, 30h	
	jb short GNotNumberFloat	

	mov [bp - 4], al						; ����� ��������� � �� ��������� ������,
	fidiv word ptr [bp - 2]					; �������� ��������� ������������� ������� �������,
	fld st(0)								; ��������� �,
	fimul word ptr [bp - 4]					; ��������� �� �������� �����, ��� ����� ������� � �� ������ �����,
	faddp st(2), st							; � ��������� � �������� ����������

	jmp short GLoopFloat					; �����-����, ���� �� �������

GNotNumberFloat:							; ���� ���� ������� ����� ��������, ��� ������ �� ����� ������� �������.
	fstp st(0)

GNotNumberInt:
	test si, si								; �������� ��������� ��� ����.
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
	
	ftst								; ��������� ����� �� ����, � ���� ��� �������������,
	fstsw ax
	sahf
	jnc WPositive

	mov ah, 02h							; �� ������� �����
	mov dl, '-'
	int 21h

	fchs								; � ��������� ������ �����

WPositive:
	fld1								; ������� ����� ����� �� �������
	fld st(1)
	fprem 								; ������� �� ������� �� ������� ���� ������� �����.
	fsub st(2), st 						; ���� ������� � �� ��������� �����, ��������� ����� �����.
	fxch st(2)		
	xor cx, cx							; ������� ���������� � ����� ������. ������� ���������� ���� ����� � CX.

WLoopInt:         		
	fidiv word ptr [bp - 2]				; ������� ����� ����� �� ������,
	fxch st(1)
	fld st(1)

	fprem								; ������� ������� ����� - ��������� ������ ����� ����� ����� ��������� �����,

	fsub st(2), st						; �� �������� ������� ������ ����� �����

	fimul word ptr [bp - 2]				; � �������� �����
	fistp word ptr [bp - 4]	
	inc cx	

	push word ptr [bp - 4]				; � �����.
	fxch st(1)	

	ftst								; ��� ����� ���������, ���� �� ����� ����� �� ��������� ����.
	fstsw ax
	sahf
	jnz short WLoopInt

	mov ah, 02h								; ������ ������� �.

WLoopPrint:			
	pop dx			
	add dl, 30h								; ����������� ��������� �����, ��������� � � ������ � �������.
	int 21h			

	loop WLoopPrint							; � ���, ���� �� ������� ��� �����.

	fstp st(0)								; ����, ������ �������� �� ������� �����, ��� ������ �������� � �������������.
	fxch st(1)
	ftst
	fstsw ax
	sahf
	jz short WFinish

	mov ah, 02h								; ���� ��� ��-���� ���������, ������� �����
	mov dl, '.'	
	int 21h	

	mov cx, 8								; � �� ����� 8 ���� ������� �����

WLoopFloat:
	fimul word ptr [bp - 2]					; �������� �������� ����� �� ������,
	fxch st(1)
	fld st(1)
	fprem									; ������� ����� ����� - ��������� ����� ����� ������� ����� ��������� �����,
	fsub st(2), st							; ������� �� ������������ ���� ������� �����,
	fxch st(2)

	fistp word ptr [bp - 4]					; �������� ���������� ����� �� ��������� ������

	mov ah, 02h								; � ����� �������
	mov dl, [bp - 4]
	add dl, 30h
	int 21h

	fxch st(1)								; ������, ���� ������� ������� ����� ���������
	ftst
	fstsw ax
	sahf

	loopnz WLoopFloat						; � �� ������ ����� ����� ����, ���������

WFinish:
	fstp st(0)								; ����, ����� ��������. �������� ������ ����� �� ������.
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
		jz	@@Zero         ; ��, ��������� = 0 (CF=NC=0, ������!)
		mov	bl,ah          ; BL and 1=1 ��� X<0, 0 ��� X>0 (���-�� ����� ��������� ����������)
		ja	@@PositiveX    ; ���� X>0, �� ������� �������� ��� ������ �� ����

		fxch                   ; ����� st0 <-> st1 (st0=Y, st1=X)
		fld	st(0)          ; st2=st1=X, st1=st0=Y, st0=st0=Y
		frndint                ; st0=Round(st0)=Round(Y)
		fcomp                  ; ��������� st0 � st1; st0=st1=Y, st1=st2=X, st3=�����
		fstsw	ax             ; � AH ���� ZF=ZR=1 ��� ����� Y
		sahf                   ; Y �����?
		jnz	@@Error        ; ���, ������������� ����� ������ ��������� � ������� �������!

		fld1
		fld1
		fadd                   ; st2=st1=X, st1=st0=Y, st0=2
		fld	st(1)          ; st3=st2=X, st2=st1=Y, st1=st0=2, st0=st1=Y
		fprem                  ; st0=st0 mod st1=Y mod 2
		ftst                   ; st0=0 (Y mod 2=0, �.�. ������) ?
		fstsw	ax             ; � AH ���� ZF=ZR=1 ��� ������ Y (CF=NC=0, ������!)
		fstp	st(0)          ; ������� ������� �� �������
		fstp	st(0)          ; ������� ����� 2 (st0), st0=st1=Y, st1=st2=X, st2=�����
		fxch                   ; ����� st0 <-> st1 (st0=X, st1=Y)
@@PositiveX:
		fabs                   ; st0=|st0|=|X|
		fyl2x                  ; st0 = st1*log2(st0) = Y*log2(|X|)
		fld	st(0)          ; st1=st0
		frndint                ; st0=Round(st0)
		fsub	st(1),st(0)    ; st1=st1-st0
		fld1                   ; st1=st0, st0=1
		fscale                 ; st0=st0*2^st1
		fstp	st(1)          ; ������� st1
		fincstp                ; st7=st0, st0=st1
		f2xm1                  ; st0=(2^st0)-1
		fmul	st(0),st(7)    ; st0=st0*st7
		fdecstp                ; st1=st0, st0=st7
		fadd                   ; st0=st0+st1, st0=�����
		; ��������� � st0 !!!

		test	bl,1           ; X<0 ? (CF=NC=0, ������!)
		jz	@@End          ; ���, ���������
		sahf                   ; Y ������
		jz	@@End          ; ��, ���������
		fchs                   ; ���� X<0, � Y ��������, �� ������ ���� ����������
@@End:		ret                    ; �������!
@@Error:
		fldz                   ; ������� 0
		fstp	st(1)          ; ������� X
		stc                    ; CF=CY=1 - ������
@@Zero:
		fstp	st(1)          ; ������� Y
		ret                    ; �������!

fpower		endp



PrintNumber PROC
	pusha									; �������������
	
	test ax, 1000000000000000b				; ������������� �� ���� �����
	jns PrintNumberNotNeg
	neg ax									; ���� �� - �� ������ ����, � ��������, ��� � �������
	push ax
	mov dl, '-'								; �������� ������� �����
	mov ah, 02h
	int 21h	
	pop ax
	
PrintNumberNotNeg:	
	mov bx, 10
	xor cx, cx
	xor dx, dx
	
DivideAgain:
	div bx										; ����� �� 10, ������� - � ax, ������� � dx � � ����
	inc cx
	push dx
	xor dx, dx
	cmp ax, 0									; �� ��� ���, ���� ������� �� ������ ������ 0
	ja DivideAgain

	mov ah, 02h
	
PrintSymbol:									; ������� �� ����� ������ �� �����
	pop dx
	add dl, 30h									; �� ����� - ��� �������
	int 21h	
	loop PrintSymbol	
	
	popa
	ret
PrintNumber ENDP


Sx proc
	push ecx
	xor ecx, ecx
	
	finit										; �������������

	fld x										; �������� ��������� ��� k = 0
	fld x										; x^0
	fld x										; 0!
	
	mov k, 0									; k = 0
	inc ecx

SLoop:
	cmp ecx, n
	ja SExit
	
	inc ecx

	inc k										; ����������� k
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
			

	faddp st(6), st								; ���������� � ���������� ���������
	jmp SLoop
	
SExit:	
	fstp st
	fstp st
	pop ecx										; �����
	ret
Sx endp


Yx proc	
	finit										; �������������

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
	mov ax, @data								; �������������
	mov ds, ax

	lea dx, message_enter_a						;   ������ a
	mov ah, 09h
	int 21h

	call GetFloat
	fstp x
	
	lea dx, message_enter_b						;   ������ b
	mov ah, 09h
	int 21h

	call GetFloat
	fstp b
	
	lea dx, message_enter_h						;   ������ h
	mov ah, 09h
	int 21h

	call GetFloat
	fstp h	
	
	lea dx, message_enter_e						;   ������ e
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