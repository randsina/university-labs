.model small
.stack 100h
.data
	enterNumber1 db "Enter the number 1 ", 13, 10, "$"
	enterNumber2 db "Enter the number 2 ", 13, 10, "$"
	errorText db "Overflow!", 13, 10, "$"
	str_number1_is db "number 1 = $"
	str_number2_is db "number 2 = $"
	str_result_is db "result = $"
	newLine db 13, 10, "$"
	number1 dw ?
	number2 dw ?
	first_bit equ 1000000000000000b
	last_bit  equ 0000000000000001b
	transfer db ?
	digit1 db ?
	digit2 db ?
	temp db ?
	ans dw ?
	canOverflow db ?
	wasOverflow db ?
	sign db ?
	res1 dw ?
	res2 dw ?
.code

EnterNumber PROC           
	push bx
	push cx
	push dx
	push di
	push si
	
	xor bx, bx 
	xor cx, cx 
	mov di, 10 
	xor si, si 

read_start:
	mov ah, 07h 
	int 21h      
	
	cmp al, 13 
	je read_finish   
	cmp al, 8    
	je read_back
	cmp al, 27
	je read_esc

	cmp al, '-' 
	je read_minus
	             
	cmp al, '0' 
	jl read_start
	cmp al, '9' 
	jg read_start	
       
read_digit:                                  
	push ax
	mov ax, bx    
	imul di 
	pop dx
	jo read_start 
	
	xor dh, dh 
	sub dl, '0' 
	add ax, dx   
	jno read_all_right
	
	cmp ax, 32768
	jnz read_start 
	cmp si, 1 
	jnz read_start 
	
read_all_right:
	mov bx, ax   
	add dl, '0' 
 
    	mov ah, 02h    
    	int 21h

    	inc cx 	
	jmp read_start 

read_back:                                      
    cmp cx, 0 
    je read_start
    
    cmp cx, 1 
    jne read_back_minus

    xor si, si

read_back_minus:
    call BackSpace 
    dec cx
	                                   
	cmp bx, 0 
	je read_start
	
	mov ax, bx
	xor dx, dx
	idiv di 
	mov bx, ax
 
	jmp read_start

read_esc:
    call BackSpace     
    loop read_esc 
    
    xor bx, bx
    xor si, si

	jmp read_start 

read_minus:            
	cmp cx, 0 
	jne read_start
	
	mov si, 1
	
	mov dl, al
	mov ah, 02h   
    int 21h
    inc cx
    
	jmp read_start
	
read_finish:	   
	mov ax, bx
	
	cmp si, 0 
	je read_finish_plus
	not ax
	
	push bx
	push dx
	
	mov bx, last_bit
	call BitSummary
	mov ax, dx
	
	pop dx
	pop bx

read_finish_plus:

	pop si
	pop di
	pop dx
	pop cx
	pop bx

	RET   
EnterNumber ENDP

backspace proc
	push ax
	push dx 
	
	mov dl, 8 
	mov ah, 02h   
	int 21h 
	
	mov dl, ' ' 
	mov ah, 02h   
	int 21h 
	
	mov dl, 8 
	mov ah, 02h   
	int 21h
	
	pop dx 
	pop ax   	
	ret
backspace endp

BitSummary PROC
	push ax
	push bx
	push cx
	
	xor dx, dx
	xor cx, cx 
	mov si, 0 
	
main_cycle:
	shr ax, 1 
	jnc ax_zero 
	
	shr bx, 1 
	jnc bx1_zero 
	
	cmp cx, 0 
	jnz carry_bit1
	mov cx, 1 
	jmp next_bit 
carry_bit1:
	call WriteBit 
	jmp next_bit 
bx1_zero:
	cmp cx, 0 
	jnz next_bit 
	
	call WriteBit 
	jmp next_bit 
	
ax_zero:
	shr bx, 1 
	jnc bx2_zero
	
	cmp cx, 0 
	jnz next_bit 
	
	call WriteBit 

bx2_zero:
	cmp cx, 0 
	jnz carry_bit2
	jmp next_bit 
carry_bit2:
	call WriteBit
	mov cx, 0 
	jmp next_bit 
next_bit:
	inc si 
	cmp si, 16
	jz end_summary
	jmp main_cycle

end_summary: 
	pop cx
	pop bx
	pop ax
	
	RET
BitSummary ENDP

WriteBit PROC               
	push ax
	push cx
	
	mov ax, last_bit 
	mov cx, si 
	shl ax, cl 
	or dx, ax  
 
	pop cx
	pop ax
	
	RET
WriteBit ENDP

WriteNumber proc
	push ax
	push bx
	push cx
	push dx
	mov bx, 10
	xor cx,cx
	
	test ax, first_bit
	jz repeatPush
	
	push ax
	
	mov ah, 2
	mov dx, '-'
	int 21h
	
	pop ax
	neg ax
	
repeatPush:
	xor dx,dx
	div bx
	push dx
	inc cx
	cmp ax, 0
	jne repeatPush

repeatPop: 
	pop dx
	add dl, '0'
	mov ah, 02h
	int 21h
loop repeatPop
	
	pop dx
	pop cx
	pop bx
	pop ax
	
Ret
WriteNumber endp

NextLine proc
push ax
push dx
	lea dx, newLine
	mov ah, 9
	int 21h
pop dx
pop ax
ret
NextLine endp

writebin proc
	push ax
	push cx
	push dx	
	
	mov cx, 0 
		   
	push ax
writeloop:
	pop ax
	cmp cx, 16
	je writeend
	inc cx

	shl ax, 1
	jnc writezero
	
writeone:       
	push ax
	mov dl, '1'
	mov ah, 02h
	int 21h
	jmp writeloop

writezero: 
	push ax      
	mov dl, '0'
	mov ah, 02h
	int 21h
	jmp writeloop
	
writeend:
	pop dx   
	pop cx
	pop ax
	ret
writebin endp
SumProc proc
	push bx
	push cx
	push dx
	push si
	push di
	
	xor dx, dx
	mov canOverflow, 0
	mov wasOverflow, 0
	;проверка на возможное переполнение(не может переполниться, если у чисел разные знаки)
	test ax, first_bit ;получение знака 1 числа
	jz notMinus1 
	mov dl, 1
notMinus1:
	test bx, first_bit ;получение знака 2 числа
	jz notMinus2 
	mov dh, 1
notMinus2:
	xor dl, dh ;сравнение знаков
	test dl, 1
	jnz canNotOverflow ;если знаки разные, то переполнения не будет
	mov canOverflow, 1
	mov sign, dh
canNotOverflow:	

	mov transfer, 0
	mov ans, 0
	mov cx, 16
	
repeatSum:	
	shr ans, 1
		
	shr ax, 1 ;получение следующего бита 1 числа
	mov digit1, 1
	jc digit1_is1 ;в jc находится искомый бит
	mov digit1, 0
digit1_is1:
	shr bx, 1 ;получение следующего бита 2 числа
	mov digit2, 1
	jc digit2_is1 ;в jc находится искомый бит
	mov digit2, 0
digit2_is1:
	
	mov dl, digit1 ;получение результата сложения двух бит
	mov dh, digit2 
	push dx
	xor dl, dh 	;dh xor dl	 
	xor dl, transfer ;dh xor dl xor transfer
	xor dh, dh ;искомы бит в dl, dh нужно обнулить
	shl dx, 15 
	or ans, dx ;прибавление бита к ответу
	
	push ax ;вывод на экран результата текущего сложения
	push dx
	xor dx, dx
	test ans, first_bit ;получение 1 бита
	jz notOne3 
	mov dx, 1
notOne3:
	mov ah, 2
	add dx, '0' ;перевод в символ
	int 21h
	pop dx
	pop ax
	
	pop dx
	mov temp, 0 ;получение переноса
	push dx
	and dl, dh ;(dl and dh)
	or temp, dl  
	pop dx
	and dl, transfer ;(dl and dh) or (dl and transfer)
	or temp, dl
	and dh, transfer ;(dl and dh) or (dl and transfer) or (dh and transfer)
	or temp, dh
	mov dl, temp
	mov transfer, dl ;записывание результата в transfer
	dec cx ;уменьшение счетчика цикла
	jz notRepeat
	jmp repeatSum
notRepeat:
	mov ax, ans
	
	xor dx, dx
	test canOverflow, 1 ;проверка на переполнение
	jz canNotOverflow2
	test ax, first_bit ;получение знака результата
	jz notMinus4 
	mov dl, 1
notMinus4:
	xor dl, sign ;проверка, изменился ли знак
	test dl, 1
	jz canNotOverflow2
	jmp IsOverflow
canNotOverflow2:	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
ret
IsOverflow:
	mov	wasOverflow, 1
	pop di
	pop si
	pop dx
	pop cx
	pop bx
ret
SumProc endp

SubProc proc
	push bx
		
	not bx ;инвертирует биты числа
	push ax
	mov ax, 1 
	call SumProc ;прибавляет к нему 1
	call NextLine
	call NextLine
	mov bx, ax
	pop ax
	call SumProc ; считает разность
	
	pop bx
ret
SubProc endp

;результат: ax - первая часть результата (показывает, есть ли переполнение), bx - вторая часть результата
multiply proc
    push cx
    push dx  
    push di
    push si
	
	; если ах = -32768, то поменять его местами с bx
	cmp ax, first_bit
	jne IsNotMin
	xchg ax, bx
IsNotMin:
	
	mov di, ax ;в bx множитель(Q), в di множимое (M)
    mov ax, 0  ; A
    mov dl, 0  ; Q[-1]
	
    mov cx, 16 ; счетчик
main_loop:
				; находим Q[0]
    mov dh, 1	
    test bx, 1	
    jnz q0_one	
    mov dh, 0	
q0_one:			
	
    
    cmp dh, dl ; сравнение dh(Q[0]) и dl(Q[-1])
    je make_shift
    jg Is_1_0
    
    add ax, di 
    jmp make_shift

Is_1_0: 
    sub ax, di
    
make_shift:
    sar ax, 1 ; арифметическиq сдвиг вправо (с сохранением знака), выдвигаемый бит помещается в cf
    rcr bx, 1 ; циклический сдвиг вправо, бит слева берется из флага cf
              ; выдвигаемый бит помещается в cf
              			  
    jc q1_Is_1	; получаем Q[-1] из cf
				;is 0
    mov dl, 0	
    jmp q1_end	
q1_Is_1:		
    mov dl, 1	
q1_end:      	
	loop main_loop  
								;проверка на переполнение
    test bx, first_bit					
    jz res_is_positive										
								;result is negative 				
    not ax						
res_is_positive: 				
    cmp ax, 0					
    je check_overflow_end		
    mov ax, 1 					;было переполнение
check_overflow_end:				
	          
    pop si
    pop di
    pop dx
    pop cx
    ret
multiply endp

start:
	mov AX, @data
	mov DS, AX

	mov ah, 9
	lea dx, enterNumber1
	int 21h
	call EnterNumber	
	
	push ax
	
	call NextLine
	mov ah, 9
	lea dx, enterNumber2
	int 21h
	
	pop number1
	
	call EnterNumber	
	mov number2, ax

	call NextLine
	mov ax, number1 ;выводим на экран числа в двоичном представлении
	call NextLine
; вывод строки 'number 1 = '
	push ax
	push dx
	mov ah, 9
	lea dx, str_number1_is
	int 21h
	pop dx
	pop ax

	call writebin	
	call NextLine
	push ax
	mov ax, number2
; вывод строки 'number 2 = '
	push ax
	push dx
	mov ah, 9
	lea dx, str_number2_is
	int 21h
	pop dx
	pop ax

	call writebin
	call NextLine
	pop ax			
	mov bx, number2 
		
	call multiply	; выполняем умножение
	cmp ax, 0		;проверяем на переполнение			
    je was_not_overflow	
    mov ah, 9
	lea dx, errorText
	int 21h
	call NextLine
	jmp was_overflow
was_not_overflow:
	call NextLine	
	mov ax, bx
; вывод строки 'result = '
	push ax
	push dx
	mov ah, 9
	lea dx, str_result_is
	int 21h
	pop dx
	pop ax

	call WriteNumber
	call NextLine
	call WriteBin
	call NextLine
was_overflow:	
		
	mov AH, 4ch
	int 21h
end start
