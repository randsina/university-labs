.model small

.486

.stack 256
	LOCALS

.data
	; числовые константы
	sign_bit              equ 10000000000000000000000000000000b ; первый знаковый бит
	except_sign_bit       equ 01111111111111111111111111111111b ; первый знаковый бит
	all_order_bits        equ 01111111100000000000000000000000b ; 8 битов порядка
	
	epsilon	      equ 6 ; точность вывода (до 39)	
	
	true  equ 1
	
	error_incorrect_coefficients equ 3
	error_any_root               equ 4

	; строковые константы
	string_enter_a   db "Type number A - $"
	string_enter_b   db "Type number B - $"
	string_enter_c   db "Type number C - $"
	string_try_again db "incorrect float value. try again => $"
	
	string_overflow       db "overflow! $"
	
	string_no_roots               db "D < 0. No roots! $"
	string_incorrect_coefficients db "Incorrect coefficients! $"
	string_any_root               db "X in (-inf .. +inf) $"
	
	string_x1 db "X1 - $"
	string_x2 db "X2 - $"
	
	string_crlf      db 13, 10, "$"
	string_point     db ".$"
	string_delimiter db " - $"
	
	; входные и выходные данные процедур
	A      dd 0
	B      dd 0
	C      dd 0
	X1     dd 0
	X2     dd 0
	roots_count dd 0
	
	four dd 01000000100000000000000000000000b ; 4
	half dd 00111111000000000000000000000000b ; 0.5
	
	; переменные для работы процедур ввода-вывода числа
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

float_input proc c ; выход datain - ввод вещественного числа
	uses eax, ebx, ecx, edx
	xor bx, bx
	xor si,si
	mov mexfl, 0
	lea dx, buf
	mov [buf], 61	;61кол-во символов ограничено тридцатьі
	mov ah, 0ah
	int 21h
	lea si,[buf+2]	;адрес первого значимого символа в строке	
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
	puts string_crlf
	puts string_overflow
@@exit:	
	puts string_crlf
	ret
float_input endp

float_input_correct proc ; выход eax - ввод вещественного числа с проверкой корректности
	
float_input_correct_start:

	call float_input
	cmp iscorrect, true
	je float_input_correct_end
	
	ffree
	puts string_try_again

	jmp float_input_correct_start
	
float_input_correct_end:
	mov eax,datain
ret
float_input_correct endp

puts_number proc ; используется в float_output
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

puts_int proc ; используется в float_output
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

readline proc ; ожидание нажатия enter
    push eax
    call float_input
    pop eax
    ret
readline endp

writeint proc ; вход ax - вывод целого числа
	push ax
	push bx
	push cx
	push dx	 
	
	xor cx, cx ; обнуляем счетчик
	mov bx, 10 ; делитель для выделения цифр числа

	test ax, first_bit
	jz writepush
	push ax
	mov dl, '-'
	mov ah, 02h
	int 21h
	pop ax
	neg ax
		
	; заносим цифры числа в стек
writepush:                          
	xor dx, dx
	div bx
	push dx ; последнюю цифру - в стек
	inc cx
	cmp ax, 0
	jne writepush
	
	; достаем из стека цифры и выводим
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

float_output proc ; вход eax - вывод вещественного числа в экспоненциальной форме
	push eax
	and eax, all_order_bits
	xor eax, all_order_bits
	cmp eax, 0 ; инфинити
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
float_output	endp

bin_output proc ; вход eax - вывод вещественного числа в двоичной форме
	push eax
	push cx
	push dx
	mov cx, 0
	ll11:
	mov leftbit, 0 ;получаем крайний левый бит обоих чисел
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
	mov leftbit, 0 ;получаем крайний левый бит обоич чисел
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
	mov leftbit, 0 ;получаем крайний левый бит обоич чисел
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

puts_eax proc ; вход eax - вывод в двоичной форме
	call bin_output
	puts string_delimiter
	call float_output
	puts string_crlf
	ret
puts_eax endp

solve_quadratic_equation proc c
    uses eax, ebx, ecx, edx
	
	finit ; инициализация сопроцессора
	
	; проверка коэффициентов на 0
	
	test A, except_sign_bit
	jnz find_discriminant
	
zero_a:	;  A = 0
	test B, except_sign_bit
	jz zero_b
	
	; решаем (BX + C = 0)
	fld B             ; st(1) = B
	fld C             ; st(0) = C,
	fchs              ; st(0) = -C,
	fdiv st(0), st(1) ; st(0) = -C/B 
	fst X1            ; сохраняем x1 из st(0)
	
	mov roots_count, 1
	jmp solve_end
	
zero_b: ; B = 0
	test C, except_sign_bit
	jz zero_c
	; (AX^2 + C = 0)
	mov roots_count, error_incorrect_coefficients ; введены некорректные коэффициенты
	jmp solve_end
	
zero_c: ; C = 0
	; (AX^2 + BX = 0)
	mov roots_count, error_any_root ; корень - 0
	jmp solve_end
	
	; нахождение дискриминанта
find_discriminant:
	fld A               ;                                st(0) = A
    fld C               ;                     st(0) = C, st(1) = A
	fld four            ;  st(0) = 4,         st(1) = C, st(2) = A
	fmul st(0), st(1)   ;  st(0) = 4 * C,     st(1) = C, st(2) = A
	fmul st(0), st(2)   ;  st(0) = 4 * C * A, st(1) = C, st(2) = A
	                                                                     
	fld B               ;              st(0) = B, st(1) = 4 * C * A, st(2) = C, st(3) = A
	fld st(0)           ; st(0) = B,   st(1) = B, st(2) = 4 * C * A, st(3) = C, st(4) = A
	fmul st(0), st(0)   ; st(0) = B^2, st(1) = B, st(2) = 4 * C * A, st(3) = C, st(4) = A
	
	fsubrp st(2), st(0) ; st(0) = B^2, st(1) = B, st(2) = B^2 - 4 * C * A, st(3) = C, st(4) = A
	                    ;              st(0) = B, st(1) = D,               st(2) = C, st(3) = A
	
	fxch st(1)          ;            st(0) = D, st(1) = B, st(2) = C, st(3) = A
	fldz                ; st(0) = 0, st(1) = D, st(2) = B, st(3) = C, st(4) = A
	
	; нахождение корней
	
	fcomp st(1)   ; сравниваем дискриминант с нулём из st(0), pop  ; st = D, B, C, A
	fstsw ax      ; сохраняем флаги FPU в регистр ax
	sahf          ; устанавливаем флаги CPU из ah
	je zero_d     ; D = 0
	ja negative_d ; D < 0

	; D > 0    
positive_d:                
	fsqrt			    ; st =        sqrtD, B, C, A
	fld st(0)           ; st = sqrtD, sqrtD, B, C, A
	
	fadd st(0), st(2)   ; st =   sqrtD + B ,         sqrtD, B, C, A
	fchs				; st =  -sqrtD - B,          sqrtD, B, C, A
	fdiv st(0), st(4)	; st = (-sqrtD - B) / A,     sqrtD, B, C, A
	fmul half			; st = (-sqrtD - B) / A / 2, sqrtD, B, C, A
	fstp X1				; st =                       sqrtD, B, C, A
		
	fsub st(0), st(1)	; st =  sqrtD - B,          B, C, A
	fdiv st(0), st(3)	; st = (sqrtD - B) / A,     B, C, A
	fmul half			; st = (sqrtD - B) / A / 2, B, C, A
	fstp X2				; st =                      B, C, A
	mov roots_count, 2
	jmp solve_end
	
	; D = 0
zero_d:
	fld st(1)			; st =  B,         D, B, C, A
	fchs				; st = -B,         D, B, C, A
	fdiv st(0), st(4)   ; st = -B / A,     D, B, C, A
	fmul half			; st = -B / A / 2, D, B, C, A
	fstp X1				; st =             D, B, C, A
	mov roots_count, 1
	jmp solve_end

	; D < 0
negative_d:
	mov roots_count, 0
	jmp solve_end

solve_end:
	ret
solve_quadratic_equation endp

; вывод результата
puts_result proc
	push eax
	
	cmp roots_count, error_any_root
	je main_any_root
	
	cmp roots_count, error_incorrect_coefficients
	je main_incorrect_coefficients
	
	cmp roots_count, 0
	je main_no_roots
	
	puts string_x1
	mov eax, x1
	call float_output
	cmp roots_count, 1
	je main_end
	
	puts string_crlf
	puts string_x2
	mov eax, x2
	call float_output
	jmp main_end
	
main_no_roots:
	puts string_no_roots
	jmp main_end
	
main_any_root:
	puts string_any_root
	jmp main_end
	
main_incorrect_coefficients:
	puts string_incorrect_coefficients
	jmp main_end
	
main_end:
	pop eax
	puts string_crlf
	ret
puts_result endp

; начало программы
start:		
	mov ax, @data
	mov ds, ax
		
; ввод чисел
	puts string_enter_a
	call float_input_correct
	mov A, eax

	puts string_enter_b
	call float_input_correct
	mov B, eax
	
	puts string_enter_c
	call float_input_correct
	mov C, eax
	
; решение квадратного уравнения и вывод результатов
	call solve_quadratic_equation
	call puts_result

	mov ah, 4Ch
	int 21h
end start