.model small

.486

.stack 256
	LOCALS

.data
	; �������� ���������
	sign_bit              equ 10000000000000000000000000000000b 
	except_sign_bit       equ 01111111111111111111111111111111b 
	all_mantissa_bits     equ 00000000011111111111111111111111b ; 23 ���� ��������
	all_order_bits        equ 01111111100000000000000000000000b ; 8 ����� �������
	last_order_bit        equ 00000000100000000000000000000000b
	epsilon	      equ 6 ; �������� ������ (�� 39)	
	mantissa_size equ 23
	
	true  equ 1
	false equ 0
	
	error_overflow        equ 1
	error_underflow       equ 2
	error_plus_infinity   equ 3
	error_minus_infinity  equ 4

	; ��������� ���������
	string_enter_x   db "Type number x - $"
	string_enter_y   db "Type number y - $"
	string_try_again db "Invalid value, try again => $"
	
	string_overflow       db "overflow! $"
	string_underflow      db "underflow! $"
	string_plus_infinity  db "+infinity! $"
	string_minus_infinity db "-infinity! $"
	
	string_x         db "x - $"
	string_y         db "y - $"
	string_sum	     db "+ - $"
	string_sub       db "- - $"
	string_mul       db "* - $"
	string_div       db "/ - $"
	
	string_newline   db 13, 10, "$"
	string_point     db ".$"
	string_delimiter db " - $"

	; ������� � �������� ������ ��������
	X      dd 0
	Y      dd 0
	result dd 0
	is_wrong db 0
	
	; ����������, ������������ � ����������
	order db 0
	sign  dd 0
	
	pr     db 0 ; ������� ���������� ��������
	resmin db 0 ; ����
	
	; ���������� ��� ������ �������� �����-������ �����
	cmfl dw 0
	mfl dw 0	
	expf dw 0	
	mexfl dw 0 	
	tenconst dt 10
	minusconst dt -1
	symb dw 0
	tenpow db 0
	buf db 50 dup (?)
	datain dd 0
	dataout dt 0
	iscorrect db 0
	leftbit dw 0
	first_bit equ 1000000000000000b	

.code

puts macro string
	push ax
	push dx
	mov ah, 9h
	lea dx, string
	int 21h
	pop dx
	pop ax
endm

number_input proc c ; ����� eax - ���� ������������� �����
	uses eax, ebx, ecx, edx
	xor bx, bx
	xor si,si
	mov mexfl, 0
	lea dx, buf
	mov [buf], 61	;61 ���-�� �������� ���������� ��������
	mov ah, 0ah
	int 21h
	lea si,[buf+2]	;����� ������� ��������� ������� � ������	
	mov cmfl, 0
	mov mfl, 0
	mov iscorrect, 0
ln0:
	cld 
	lodsb
	cmp al, 101
	jne ln333
	mov expf, 1
	jmp ln2
ln333:
	cmp al,45
	jne ln34
	mov mfl, 1
	jmp ln0
ln34:
	cmp al,46
	jne ln1
	mov cmfl, 1
	jmp ln0	
ln1:
	cmp al, 13
	je ln2
	cmp cmfl, 1
	jne ln0
	inc tenpow
	jmp ln0
ln2:		
	fldz
	lea si,[buf+2]	
step1:
	cld
	lodsb
	cmp al,45
	je step1
	cmp al,46
	je step1
	cmp al, 101
	je step11
	cmp al, 13
	je step2
	cmp al,48
	jb step1
	cmp al,57
	ja step1
	fbld tenconst
	fmul
	mov iscorrect, 1	
	mov byte ptr[symb], al
	sub symb,'0'
	fiadd symb
	jmp step1
step01:
	xor bx, bx
	mov bl, 0
step11:
	cld 
	lodsb
	cmp al,45
	jne ex11
	cmp mexfl, 0
	jne step11
	mov mexfl, 1
	jmp step11
ex11:
	cmp al, 13
	je stepq
	cmp al,38
	jb step11
	cmp al,57
	ja step11
	sub al,'0'
	mov dl, al
	mov al, 10
	mul bl
	add al, dl
	mov bl, al
	jmp step11
stepq:
	cmp mexfl, 1
	je stepz
	jmp step2
stepz:
	add tenpow, bl
	mov bl, 0
step2:
	cmp tenpow, 0
	je step3
	fbld tenconst
	fdiv 
	dec tenpow
	jmp step2 	
step3:
	cmp bl, 0
	je step35
	fbld tenconst
	fmul
	dec bl
	jmp step3
step35:
	cmp mfl, 1
	jne step4
	fbld minusconst
	fmul	
step4:
	fstp datain 
	mov	ecx, datain
	or ecx, 80000000h
	cmp  ecx, 0FF800000h
	jnz  @@exit
	mov	iscorrect, 0
	puts string_newline
	puts string_overflow
@@exit:	
	puts string_newline
	ret
number_input endp

number_input_correct proc ; ����� eax - ���� ������������� ����� � ��������� ������������
	
number_input_correct_start:
	call number_input
	cmp iscorrect, true
	je number_input_correct_end
	
	ffree
	puts string_try_again

	jmp number_input_correct_start
	
number_input_correct_end:
	mov eax,datain
ret
number_input_correct endp

puts_number proc ; ������������ � number_output
	pusha
	
	push	ax
	fxch		st(0)
	ftst
	fstsw		ax
	sahf
	fxch		st(0)
	pop		ax
	
	jnc		@@great_than_zero
	
	fabs
	
	push		ax
	push		dx
	mov		ah, 2h
	mov		dl, '-'
	int		21h
 
	pop		dx
	pop		ax
	
@@great_than_zero:	
	fld1
	fld		st(1)
	fprem
	fxch		st(1)
	ffree		st(0)
	fincstp
	fsub		st(1), st(0)
	fxch		st(1)

	mov		cx, 9
	fld1
	fld1
@@fld_10:
	fadd		st(1), st(0)	
	loop		@@fld_10

	ffree		st(0)
	fincstp

	push 		bp	
	mov 		bp, sp
	push 		0
	xor		cx, cx

@@division:
	inc		cx
	fdiv		st(1), st(0)
	fld1	
	fcomp		st(2)
	fstsw		ax
	cmp cx, 60
	je @@popa2
	sahf		
	jz		@@division
	jc		@@division			

@@multiply:
	fmul		st(1), st(0)
	fld1
	fld		st(2)
	fprem		
	fsubr		st(0), st(3)
	fist		word ptr [bp - 2]
	mov		ah, 02h
	mov		dl, byte ptr [bp - 2]
	add		dl, '0'
	int		21h
	fsubp		st(3), st(0)
	ffree		st(0)
	fincstp
	loop		@@multiply
		
	fxch		st(1)
	ffree		st(0)
	fincstp	
	
	puts string_point

	mov		cx, epsilon
@@multiply1:
	fmul		st(1), st(0)
	fld1
	fld		st(2)
	fprem		
	fld		st(3)
	fsubrp	st(1), st(0)
	fist		word ptr [bp - 2]
	mov		ah, 02h
	mov		dl, byte ptr [bp - 2]
	add		dl, '0'
	int		21h
	fsubp		st(3), st(0)
	ffree		st(0)
	fincstp
	
	push		ax
	fxch		st(1)
	ftst
	fstsw		ax
	sahf
	fxch		st(1)		
	pop		ax

	loop		@@multiply1	
	pop		ax
	pop		bp

	ffree		st(0)
	fincstp
	ffree		st(0)
	fincstp
	@@popaopa:
	popa
	ret
	@@popa2:
	puts string_overflow
	jmp @@popaopa
puts_number	endp

puts_int proc ; ������������ � number_output
	pusha								
	pushf
	mov		eax, ebx
	xor ebx, ebx
	mov 		bx, 10
	xor 		cx, cx
	
@@metka1:							
	xor 		edx, edx
	div 		bx
	add 		dl, '0'
	push 		dx
	inc 		cl
	cmp 		ax, 0
	jnz 		@@metka1
	mov 		ah, 2
@@metka2:							
	pop 		dx
	int 		21h
	loop 		@@metka2
	popf
	popa
	ret
puts_int endp

readline proc ; �������� ������� enter
    push eax
    call number_input
    pop eax
    ret
readline endp

writeint proc ; ���� ax - ����� ������ �����
	push ax
	push bx
	push cx
	push dx	 
	
	xor cx, cx ; �������� �������
	mov bx, 10 ; �������� ��� ��������� ���� �����

	test ax, first_bit
	jz writepush
	push ax
	mov dl, '-'
	mov ah, 02h
	int 21h
	pop ax
	neg ax
		
	; ������� ����� ����� � ����
writepush:                          
	xor dx, dx
	div bx
	push dx ; ��������� ����� - � ����
	inc cx
	cmp ax, 0
	jne writepush
	
	; ������� �� ����� ����� � �������
writepop:       
	pop dx
	add dl, '0'
	mov ah, 02h
	int 21h
	loop writepop

	pop dx
	pop cx
	pop bx
	pop ax
	ret
writeint endp

number_output proc ; ���� eax - ����� ������������� ����� � ���������������� �����
	push eax
	and eax, all_order_bits
	xor eax, all_order_bits
	cmp eax, 0 ; infinity
	jne not_infinty
	pop eax
	puts string_overflow
	ret	
	
not_infinty:
	pop eax
	
	pusha
	push eax
	mov datain, eax
	fld datain
	fstp dataout
	fld dataout

	sub		sp, 94
	mov		bp, sp
	FSAVE	[bp]
	
	fld		tbyte ptr [bp + 14]
	ftst	
	push		ax
	fstsw		ax
	sahf		
	pop		ax
	
	jnz 		@@not_null
	call		puts_number
	jmp		@@exit		

@@not_null:
	ftst	
	push		ax
	fstsw		ax
	sahf		
	pop		ax
	jnc		@@greater_zero
	push		ax
	push		dx
	
	mov		ah, 2h
	mov		dl, '-'
	int		21h

	pop		dx
	pop		ax

	fabs
@@greater_zero:
	push		ax
	fld1
	fcomp		st(1)
	fstsw		ax
	sahf
	pop		ax
	
	jz		$ + 4	
	jnc		@@below_one
	
	push		ax
	push		cx
	mov		cx, 9

	fld1
	fld1
@@fld_10:
	fadd		st(1), st(0)
	loop		@@fld_10
	
	pop		cx
	
	ffree		st(0)
	fincstp
	fcomp		st(1)
	fstsw		ax
	sahf
	pop		ax
	
	jc		@@greater_ten

	call	puts_number
	jmp		@@exit

@@below_one:
	push	cx
	mov		cx, 9
	
	fld1
	fld1
@@fld_10_1:
	fadd		st(1), st(0)
	loop		@@fld_10_1
	ffree		st(0)
	fincstp
	pop		cx
	
	push		bx
	xor		bx, bx
	
@@multiply:
	inc		bx
	fmul		st(1), st(0)

	push		ax
	fld1
	fcomp		st(2)
	fstsw		ax
	sahf
	pop		ax

	jnc		@@multiply
	
	ffree		st(0)
	fincstp
	call		puts_number
	
	push		ax
	push		dx
	
	mov		ah, 2h
	mov		dl, 'e'
	int		21h
	mov		dl, '-'
	int		21h
	
	pop		dx
	pop		ax
	
	call		puts_int
	
	pop		bx
	
	jmp		@@exit
	
@@greater_ten:	
	push		cx
	mov		cx, 9
	
	fld1
	fld1
@@fld_10_2:
	fadd		st(1), st(0)
	loop		@@fld_10_2
	ffree		st(0)
	fincstp
	pop		cx
	
	push		bx
	xor		bx, bx

@@division:
	inc		bx
	fdiv		st(1), st(0)

	push		cx
	mov		cx, 9
	fld1
	fld1
@@fld_10_3:
	fadd		st(1), st(0)
	loop		@@fld_10_3

	ffree		st(0)
	fincstp
	pop		cx
	
	push		ax
	fcomp		st(2)
	fstsw		ax
	sahf
	pop		ax

	jz		@@division
	jc		@@division
	
	ffree		st(0)
	fincstp
	
	call		puts_number
	
	push		ax
	push		dx
	
	mov		ah, 2h
	mov		dl, 'e'
	int		21h
	
	pop		dx
	pop		ax
	
	call		puts_int
	
	pop		bx

@@exit:
	mov		bp, sp
	FRSTOR	[bp]
	add		sp, 94
	
	pop eax
	popa
	ret
number_output	endp

bin_output proc ; ���� eax - ����� ������������� ����� � �������� �����
	push eax
	push cx
	push dx
	mov cx, 0
	ll11:
	mov leftbit, 0 ;�������� ������� ����� ��� ����� �����
	shl eax, 1
	jnc not111
	mov leftbit, 1
	not111:		
	push eax
	xor ax, ax
	mov ah, 02h
	mov dx, leftbit
	add dx,'0'
	int 21h
	pop eax
	add cx, 1
	cmp cx, 1
	jne ll11
	
	push ax
	mov ah, 02h
	mov dl,' '
	int 21h
	pop ax
	
	mov cx, 0
	ll12:
	mov leftbit, 0 ;�������� ������� ����� ��� ����� �����
	shl eax, 1
	jnc not112
	mov leftbit, 1
	not112:		
	push eax
	xor ax, ax
	mov ah, 02h
	mov dx, leftbit
	add dx,'0'
	int 21h
	pop eax
	add cx, 1
	cmp cx,8
	jne ll12
	
	push ax
	mov ah, 02h
	mov dl,' '
	int 21h
	pop ax
	
	mov cx, 0
	ll13:
	mov leftbit, 0 ;�������� ������� ����� ��� ����� �����
	shl eax, 1
	jnc not113
	mov leftbit, 1
	not113:		
	push eax
	xor ax, ax
	mov ah, 02h
	mov dx, leftbit
	add dx,'0'
	int 21h
	pop eax
	add cx, 1
	cmp cx,23
	jne ll13
	
	pop dx
	pop cx
	pop eax
	ret
bin_output endp

puts_eax proc ; ���� eax - ����� � �������� ����� � � ����������������
	call bin_output
	puts string_delimiter
	call number_output
	puts string_newline
	ret
puts_eax endp

; ����� ����������� ���������� �������
; ���� result, is_wrong
puts_result proc
	cmp is_wrong, error_overflow
	je puts_result_overflow
	
	cmp is_wrong, error_underflow
	je puts_result_underflow
	
	cmp is_wrong, error_plus_infinity
	je puts_result_plus_infinity
	
	cmp is_wrong, error_minus_infinity
	je puts_result_minus_infinity
	
	push eax
	mov eax, result
	call puts_eax
	pop eax
	ret
	
puts_result_overflow:
	puts string_overflow
	puts string_newline
	ret
	
puts_result_underflow:
	puts string_underflow
	puts string_newline
	ret
	
puts_result_plus_infinity:
	puts string_plus_infinity
	puts string_newline
	ret
	
puts_result_minus_infinity:
	puts string_minus_infinity
	puts string_newline
	ret
puts_result endp

; ����� ���� �����
; ���� X, Y
; ����� result, is_wrong
number_add proc c
	uses eax, ebx, ecx, edx

	; ������������� ������
	mov eax, X
	mov ebx, Y
	mov is_wrong, false
	
	; �������� �� +-0
	mov ecx, eax
	and ecx, except_sign_bit
	cmp ecx, 0
	je addition_return_y
	
	mov ecx, ebx
	and ecx, except_sign_bit
	cmp ecx, 0
	je addition_return_x
	
	; ������������ ��������
	
	; ���������� ��������
	and eax, all_order_bits ; ��������� ������ ���� �������
	shr eax, mantissa_size ; �������� ������� ������
	mov ecx, eax ; � ecx ������ - ������� ����� X
	
	and ebx, all_order_bits
	shr ebx, mantissa_size
	mov edx, ebx ; � edx ������ - ������� ����� Y
	
	; ��������� �������
	mov eax, X
	and eax, all_mantissa_bits ; ��������� ������ ��������
	or eax, last_order_bit ; ������� ����� ��������� "��������������" �������
	; � �ax ������ - �������� ����� X
	
	mov ebx, Y
	and ebx, all_mantissa_bits
	or ebx, last_order_bit
	; � ebx ������ - �������� ����� Y

	; ��������� ��������
	cmp ecx, edx
	jg addition_order_x_greater
	jl addition_order_x_less
	
	; ������� �����
	mov order, cl
	jmp addition_sum_mantissas
	
addition_order_x_greater:
	; ������� ����� X - ������, ��� ������� ����� Y
	; ����������� ������� �������� ����� Y � ������� �������� ����� X
	
	mov order, cl ; ��������� ������� �������� �����
	sub ecx, edx ; ������� ������� ��������
	; � cl ������ - ������� ��������

	shr ebx, cl ; c������� ������ �������� ������� ����� �� ������� ��������
	; ���� ������ �������� ���� ���� �������, ������ ������� �������� ��������
	
	cmp ebx, 0 ; ���� ����� ������ �������� ����� Y ����� ����
	je addition_return_x
	
	jmp addition_sum_mantissas

addition_order_x_less:
	; ������� ����� X - ������, ��� ������� ����� Y
	; ����������� ������� �������� ����� X � ������� �������� ����� Y
	
	mov order, dl ; ��������� ������� �������� �����
	sub edx, ecx ; ������� ������� ��������
	mov cl, dl ; � cl ������ - ������� ��������

	shr eax, cl ; c������� ������ �������� ������� ����� �� ������� ��������
	; ���� ������ �������� ���� ���� �������, ������ ������� �������� ��������
	
	cmp eax, 0 ; ���� ����� ������ �������� ����� X ����� ����
	je addition_return_y
	
	jmp addition_sum_mantissas

	; ���������� �������� � ������ �����
addition_sum_mantissas:
	; ��������� ����� �����
	mov ecx, X
	and ecx, sign_bit ; � ecx ������ - ���� ����� X
	mov edx, Y
	and edx, sign_bit ; � edx ������ - ���� ����� Y
	
	cmp ecx, edx
	jl addition_negative_x
	jg addition_negative_y
	
	; ���� ����� ����� ���������� �����
	add eax, ebx
	
	; ��������� ���� ����������
	mov sign, 0
	cmp ecx, 0 
	je addition_check
	mov sign, 1
	jmp addition_check
	
addition_negative_x: ; ����� X - �������������, ����� Y - �������������
	cmp eax, ebx
	jg addition_negative_x_greater
	mov sign, 0
	sub ebx, eax
	mov eax, ebx
	jmp addition_check
	
addition_negative_x_greater: ; �������� ����� X ������ �������� ����� Y
	mov sign, 1
	sub eax, ebx
	jmp addition_check

addition_negative_y: ; ����� Y - �������������, ����� X - �������������
	cmp ebx, eax
	jg addition_negative_y_greater
	mov sign, 0
	sub eax, ebx
	jmp addition_check

addition_negative_y_greater: ; �������� ����� Y ������ �������� ����� X
	mov sign, 1
	sub ebx, eax
	mov eax, ebx
	jmp addition_check

	; �������� �������� �� 0 � ���������� �������
addition_check:
	cmp eax, 0
	je addition_return_0

	; ��������� ���� ����� �� ��������
	mov ebx, eax
	shr ebx, mantissa_size
	shr ebx, 1
	cmp ebx, 0      	  ; ���� ����� �� �������� ������ ���,
	je addition_normalize ; �� ������� �� ����� �����������
	
	shr eax, 1 ; �������� �������� ������ �� ���
	add order, 1 ; ����������� ������� �� 1
	jc addition_return_overflow ; �������� �� ������������ � �������
	
	; ������������
addition_normalize:
	mov ebx, eax
	and ebx, all_order_bits
	cmp ebx, 0 ; ���� ������� = 0
	jne addition_result
	shl eax, 1
	sub order, 1
	jc addition_return_underflow ; ������ ����������
	jnc addition_normalize
	
	; ������������ ����������
addition_result:
	and eax, all_mantissa_bits ; ������� "��������������" ��� ������� �� ��������
	
	mov ebx, 0
	mov bl, order
	shl ebx, mantissa_size
	or eax, ebx ; ��������� ������� � ����������
	
	mov ecx, sign
	shl ecx, 31 ; ������ ��� ����� � ������� ��� ����������
	or eax, ecx ; ��������� ���� � ����������
	jmp addition_end
	
; ������������ ��������
addition_return_y:
	mov ebx, Y
	mov result, ebx
	ret
	
addition_return_x:
	mov eax, X
	mov result, eax
	ret

addition_return_0:
	mov result, 0
	ret
	
addition_return_overflow:
	mov is_wrong, error_overflow
	ret
	
addition_return_underflow:
	mov is_wrong, error_underflow
	ret
	
addition_end:
	mov result, eax
	ret
number_add endp

; �������� ���� �����
; ���� X, Y
; ����� result, is_wrong
number_sub proc
	push Y ; ��������� �������� ���������� Y � �����
	
	xor Y, sign_bit
	call number_add
	
	pop Y ; ��������������� �������� ���������� Y �� �����

	ret
number_sub endp

; ��������� ���� �����
; ���� X, Y
; ����� result, is_wrong
number_mul proc c
	uses eax, ebx, ecx, edx
	
	; ������������� ������
	mov eax, X
	mov ebx, Y
	mov is_wrong, false
	
	; �������� �� 0
	mov ecx, eax
	and ecx, except_sign_bit
	cmp ecx, 0
	je multiply_return_0
	
	mov ecx, ebx
	and ecx, except_sign_bit
	cmp ecx, 0
	je multiply_return_0
	
	; �������� ��������
	
	; ���������� ��������
	and eax, all_order_bits ; ��������� ������ ���� �������
	shr eax, mantissa_size ; �������� ������� ������
	mov ecx, eax ; � ecx ������ - ������� ����� X
	
	and ebx, all_order_bits
	shr ebx, mantissa_size
	mov edx, ebx ; � edx ������ - ������� ����� Y
	
	; �������� ��������
	add ecx, edx ; �������� ��������
	sub ecx, 127 ; ��������� ��������, �.�. ���������� ������� ��� ���� �������
	mov order, cl
	
	; ��������� ������ ����������
	test ecx, first_bit
	jnz multiply_return_underflow ; ����� �������� �������� ��������� ������������� ���������
	                        ; ������ - ������� ������� ��������� ����� � ������ ��������
	
	; ��������� ������������ ��������
	mov edx, all_order_bits
	shr edx, mantissa_size
	not edx ; � edx - ���� ������ (��� �������), ������� ����� (��� ������������ �������)
	test ecx, edx
	jnz multiply_return_overflow

	; ������������ �������
	mov eax, X
	and eax, all_mantissa_bits ; ��������� ������ ��������
	or eax, last_order_bit ; ������� ����� ��������� "��������������" �������
	; � �ax ������ - �������� ����� X
	
	mov ebx, Y
	and ebx, all_mantissa_bits
	or ebx, last_order_bit ; � ebx ������ - �������� ����� Y

	mul ebx ; ��������� � edx:eax

	; ���������� - �������� edx:eax ������ �� ���-�� �������� ��������
	mov cx, mantissa_size
multiply_shift:
	shr edx, 1 ; ����������� ��� � cf
	rcr eax, 1 ; ������� ������������� ��� �� cf
	loop multiply_shift

	; ������������ 
multiply_normalize:
	mov ecx, all_mantissa_bits
	not ecx
	and ecx, eax
	shr ecx, mantissa_size ; � ecx - ��, ��� ����� �� �������� �� eax
	cmp ecx, 1
	je multiply_result ; ����� �� �������� �������� ������ "��������������" �������

	shr eax, 1 ; �������� ����� ������ �� ���
	add order, 1 ; � ��������� ������� �� �������
	jc multiply_return_overflow 
	jmp multiply_normalize

	; ������������ ����������
multiply_result:
	and eax, all_mantissa_bits ; ������� "��������������" ��� ������� �� ��������
	
	mov ebx, 0
	mov bl, order
	shl ebx, mantissa_size
	or eax, ebx ; ��������� ������� � ����������
	
	mov ecx, X
	xor ecx, Y
	and ecx, sign_bit
	or eax, ecx ; ��������� ���� � ����������
	jmp addition_end
	
multiply_return_0:
	mov result, 0
	ret
	
multiply_return_overflow:
	mov is_wrong, error_overflow
	ret
	
multiply_return_underflow:
	mov is_wrong, error_underflow
	ret
	
multiply_end:
	mov result, eax
	ret
number_mul endp

; ������� ���� �����
; ���� X, Y
; ����� result, is_wrong
number_div proc c
	uses eax, ebx, ecx, edx
	
	; ������������� ������
	mov eax, X
	mov ebx, Y
	mov is_wrong, false
	
	; �������� �� 0
	mov ecx, eax
	and ecx, except_sign_bit
	cmp ecx, 0
	je division_return_0
	
	mov ecx, ebx
	and ecx, except_sign_bit
	cmp ecx, 0
	jne division_zero_check_end

	mov ecx, ebx
	xor ecx, eax
	test ecx, sign_bit
	jz division_return_plus_infinity
	jnz division_return_minus_infinity
division_zero_check_end:

	; ��������� ��������
	
	; ���������� ��������
	and eax, all_order_bits ; ��������� ������ ���� �������
	shr eax, mantissa_size ; �������� ������� ������
	mov ecx, eax ; � ecx ������ - ������� ����� X
	
	and ebx, all_order_bits
	shr ebx, mantissa_size
	mov edx, ebx ; � edx ������ - ������� ����� Y
	
	; ��������� ��������
	sub ecx, edx ; ��������� ��������
	add ecx, 127 ; �������� ��������, �.�. ���������� ������� ��� ���� �������
	mov order, cl
	
	; ��������� ������ ����������
	test ecx, first_bit
	jnz division_return_underflow ; ����� ��������� �������� ��������� ������������� ���������
	
	; ��������� ������������ ��������
	mov edx, all_order_bits
	shr edx, mantissa_size
	not edx ; � edx - ������� ����� (��� ������������ �������), ���� ������ (��� �������)
	test ecx, edx
	jnz division_return_overflow

	; ������� �������
	
	; ��������� �������
	mov eax, X
	and eax, all_mantissa_bits ; ��������� ������ ��������
	or eax, last_order_bit ; ������� ����� ��������� "��������������" �������
	; � �ax ������ - �������� ����� X
	
	mov ebx, Y
	and ebx, all_mantissa_bits
	or ebx, last_order_bit ; � ebx ������ - �������� ����� Y
	
	; ���������� �������� � ������� �������
	mov edx, 0 ; ������� � edx:eax

	mov ecx, mantissa_size ; �������� �������� ������� ����� �� ������ �������� �����
	division_shift:
	sal eax, 1 ; ����� ����� �� ���� ������
           ; ������ ��� ������ ����������� ����
           ; ����������� ��� - � cf (carry flag)
	rcl edx, 1 ; ����� ����� �� ���� ������
           ; ������ ��� ������ ������� �� ����� cf (���� ��������)
           ; ����������� ��� - � cf
	loop division_shift

	div ebx ; ��������� - � eax

	; ������������
division_normalize:
	mov ecx, all_mantissa_bits
	not ecx
	and ecx, eax
	shr ecx, mantissa_size ; � ecx - ��, ��� ����� �� �������� �� eax
	cmp ecx, 1
	je division_result ; ����� �� �������� �������� ������ "��������������" �������

	shl eax, 1 ; �������� ����� ����� �� ���
	sub order, 1 ; � ��������� ������� �� �������
	jc division_return_underflow ; 
	jmp division_normalize
	
	; ������������ ����������
division_result:
	and eax, all_mantissa_bits ; ������� "��������������" ��� ������� �� ��������
	
	mov ebx, 0
	mov bl, order
	shl ebx, mantissa_size
	or eax, ebx ; ��������� ������� � ����������
	
	mov ecx, X
	xor ecx, Y
	and ecx, sign_bit
	or eax, ecx ; ��������� ���� � ����������
	jmp addition_end
	
division_return_0:
	mov result, 0
	ret
	
division_return_overflow:
	mov is_wrong, error_overflow
	jmp addition_return_0
	
division_return_underflow:
	mov is_wrong, error_underflow
	jmp addition_return_0
	
division_return_plus_infinity:
	mov is_wrong, error_plus_infinity
	ret
	
division_return_minus_infinity:
	mov is_wrong, error_minus_infinity
	ret
	
division_end:
	mov result, eax
	ret
number_div endp

start:		
	mov ax, @data
	mov ds, ax
		
; ���� �����
	puts string_enter_x
	call number_input_correct
	mov X, eax

	puts string_enter_y
	call number_input_correct
	mov Y, eax
	
; ����� ��������� ��������
	puts string_x
	mov eax, X
	call puts_eax

	puts string_y
	mov eax, Y
	call puts_eax
	
; �����
	call number_add ; ���� X, Y; ����� result, is_wrong
	puts string_sum
	call puts_result
	
; ��������
	call number_sub ; ���� X, Y; ����� result, is_wrong
	puts string_sub
	call puts_result
	
; ���������
	call number_mul ; ���� X, Y; ����� result, is_wrong
	puts string_mul
	call puts_result
	
; �������
	call number_div ; ���� a, b; ����� result, isfail
	puts string_div
	call puts_result

; ����� ���������

	mov ah, 4Ch
	int 21h
end start