name "Base Converter"

.model small

.stack 100h

.data

    input db 20 dup('@')
    binary db 20 dup('#')
    output db 20 dup('$')
    
    input_size dw 0
    binary_size dw 0
    
    from dw 0
    to dw 0
    
    enter_from db 10, 13, 'Please enter the source base ([B]inary, [O]ctal, [D]ecimal, [H]exadicimal): $'
    enter_to db 10, 13, 'Please enter the target base ([B]inary, [O]ctal, [D]ecimal, [H]exadicimal): $' 
    enter_num db 10, 13, 'Please enter the integer: $'
    num_is db 10, 13, 'Integer in new base is: $'
    same_base db 10, 13, 'Source and target bases cannot be the same! Exiting.$'
    
    invalid_from db 10, 13, 'Invalid source base specified!$'
    invalid_to db 10, 13, 'Invalid target base specified!$' 

.code

mov ax, @data
mov ds, ax
mov ax, 0

main proc
    
    input_from_base:
    
    mov ah, 9
    lea dx, enter_from
    int 21h
    
    mov ah, 1
    int 21h
    
    call validate_base
    
    cmp al, 0
    jne valid_from_base
    
    mov ah, 9
    lea dx, invalid_from
    int 21h
    jmp input_from_base
    
    valid_from_base:
    
    mov from, al
    
    input_to_base:
    
    mov ah, 9
    lea dx, enter_to
    int 21h
    
    mov ah, 1
    int 21h
    
    call validate_base
    
    cmp al, 0
    jne valid_to_base
    
    mov ah, 9
    lea dx, invalid_to
    int 21h
    jmp input_to_base
    
    valid_to_base:
    
    mov ah, 0
    mov to, al
    
    cmp from, ax
    jne input_integer
    
    mov ah, 9
    lea dx, same_base
    int 21h
    .exit
    
    input_integer:
    
    mov ah, 9
    lea dx, enter_num
    int 21h
    
    call scan_num
    call input_to_binary
    call binary_to_output
    
    mov ah, 9
    lea dx, num_is
    int 21h
    
    mov si, 0
    
    output_start:
    
    mov dl, output[si]
    
    cmp dl, '$'
    je output_end
    
    mov dh, 0
    mov ah, 2
    int 21h
    
    inc si
    jmp output_start
    
    output_end:
    
    .exit
    
main endp

validate_base proc
    
    cmp al, 'b'
    je valid_b
    
    cmp al, 'B'
    je valid_b
    
    cmp al, 'o'
    je valid_o
    
    cmp al, 'O'
    je valid_o
    
    cmp al, 'd'
    je valid_d
    
    cmp al, 'D'
    je valid_d
    
    cmp al, 'h'
    je valid_h
    
    cmp al, 'H'
    je valid_h
    
    mov al, 0
    ret
    
    valid_b:
    
    mov al, 'b'
    ret
    
    valid_o:
    
    mov al, 'o'
    ret
    
    valid_d:
    
    mov al, 'd'
    ret
    
    valid_h:  
    
    mov al, 'h'
    ret
    
validate_base endp

scan_num proc
    
    mov si, 0
    
    scan:
    
    mov ah, 1
    int 21h
    
    cmp al, 13
    je scan_end
    
    call validate_num
    
    cmp bh, 0
    je invalid_num
    
    mov input[si], al
    inc si
    jmp scan
    
    invalid_num:
    
    mov ah, 2
    mov dx, 8
    int 21h
    
    mov ah, 2
    mov dx, 0
    int 21h
    
    mov ah, 2
    mov dx, 8
    int 21h
    
    jmp scan
    
    scan_end:
    
    mov input_size, si
    ret
    
scan_num endp

validate_num proc
    
    cmp al, '0'
    jl invalid_valid_num
    
    cmp from, 'b'
    je check_binary
    
    cmp from, 'o'
    je check_octal
    
    cmp from, 'd'
    je check_decimal
    
    cmp from, 'h'
    je check_hexadecimal
    
    valid_valid_num:
    
    mov bh, 1
    ret
    
    invalid_valid_num:
    
    mov bh, 0
    ret
    
    check_hexadecimal:
    
    cmp al, 'a'
    je valid_valid_num    
    
    cmp al, 'A'
    je valid_valid_num
    
    cmp al, 'b'
    je valid_valid_num
    
    cmp al, 'B'
    je valid_valid_num
    
    cmp al, 'c'
    je valid_valid_num
    
    cmp al, 'C'
    je valid_valid_num
    
    cmp al, 'd'
    je valid_valid_num
    
    cmp al, 'D'
    je valid_valid_num
    
    cmp al, 'e'
    je valid_valid_num
    
    cmp al, 'E'
    je valid_valid_num
    
    cmp al, 'f'
    je valid_valid_num
    
    cmp al, 'F'
    je valid_valid_num
    
    check_decimal:
    
    cmp al, '9'
    jle valid_valid_num
    
    check_octal:
    
    cmp al, '7'
    jle valid_valid_num
    
    check_binary:
    
    cmp al, '1'
    jle valid_valid_num
    
    jmp invalid_valid_num
    
validate_num endp

input_to_binary proc
    
    mov si, 0
    mov di, 0
    
    cmp from, 'b'
    je from_binary_start
    
    cmp from, 'o'
    je from_octal_start
    
    cmp from, 'd'
    je from_decimal_start
    
    cmp from, 'h'
    je from_hexadecimal_start
    
    ret
    
    from_binary_start:
    
    cmp input_size, si
    je end_input_to_binary_proc
    
    mov cl, input[si]
    sub cl, 48
    mov binary[di], cl
    inc si
    inc di
    jmp from_binary_start
    
    from_octal_start:
    
    cmp input_size, si
    je end_input_to_binary_proc
    
    mov cl, input[si]
    sub cl, 48
    inc si
    
    cmp cl, 0
    je octal_0
    
    cmp cl, 1
    je octal_1
    
    cmp cl, 2
    je octal_2
    
    cmp cl, 3
    je octal_3
    
    cmp cl, 4
    je octal_4
    
    cmp cl, 5
    je octal_5
    
    cmp cl, 6
    je octal_6
    
    cmp cl, 7
    je octal_7
    
    octal_0:
    
    mov binary[di], 0
    inc di
    mov binary[di], 0
    inc di
    mov binary[di], 0
    inc di
    jmp from_octal_start
    
    octal_1:
    
    mov binary[di], 0
    inc di
    mov binary[di], 0
    inc di
    mov binary[di], 1
    inc di
    jmp from_octal_start
    
    octal_2:
    
    mov binary[di], 0
    inc di
    mov binary[di], 1
    inc di
    mov binary[di], 0
    inc di
    jmp from_octal_start
    
    octal_3:
    
    mov binary[di], 0
    inc di
    mov binary[di], 1
    inc di
    mov binary[di], 1
    inc di
    jmp from_octal_start
    
    octal_4:
    
    mov binary[di], 1
    inc di
    mov binary[di], 0
    inc di
    mov binary[di], 0
    inc di
    jmp from_octal_start
    
    octal_5:
    
    mov binary[di], 1
    inc di
    mov binary[di], 0
    inc di
    mov binary[di], 1
    inc di
    jmp from_octal_start
    
    octal_6:
    
    mov binary[di], 1
    inc di
    mov binary[di], 1
    inc di
    mov binary[di], 0
    inc di
    jmp from_octal_start
    
    octal_7:
    
    mov binary[di], 1
    inc di
    mov binary[di], 1
    inc di
    mov binary[di], 1
    inc di
    jmp from_octal_start
    
    from_decimal_start:
    
    mov si, input_size
    dec si
    
    mov bx, 1
    mov cx, 0
    mov dx, 0
    
    from_decimal_loop:
    
    cmp si, 0
    jl decimal_2_binary
    
    mov ax, bx
    mov dl, input[si]
    sub dl, 48
    mul dx
    add cx, ax
    dec si
    mov ax, bx
    mov dx, 10
    mul dx
    mov bx, ax
    jmp from_decimal_loop
    
    decimal_2_binary:
    
    mov ax, cx
    mov bx, 2
    mov si, 0
    
    decimal_2_binary_loop:
    
    cmp ax, 0
    je reverse_binary
    
    mov dx, 0
    div bx
    mov binary[si], dl
    inc si
    jmp decimal_2_binary_loop
    
    reverse_binary:
    
    mov binary_size, si
    dec si
    mov di, 0
    
    reverse_binary_loop:
    
    cmp si, di
    jle end_reverse_binary_loop
    
    mov ah, binary[si]
    mov al, binary[di]
    mov binary[si], al
    mov binary[di], ah
    inc di
    dec si
    jmp reverse_binary_loop
    
    end_reverse_binary_loop:
    
    ret
    
    from_hexadecimal_start:
    
    cmp input_size, si
    je end_input_to_binary_proc
    mov cl, input[si]
    inc si
    
    cmp cl, '0'
    je hexadecimal_0
    
    cmp cl, '1'
    je hexadecimal_1
    
    cmp cl, '2'
    je hexadecimal_2
    
    cmp cl, '3'
    je hexadecimal_3
    
    cmp cl, '4'
    je hexadecimal_4
    
    cmp cl, '5'
    je hexadecimal_5
    
    cmp cl, '6'
    je hexadecimal_6
    
    cmp cl, '7'
    je hexadecimal_7
    
    cmp cl, '8'
    je hexadecimal_8
    
    cmp cl, '9'
    je hexadecimal_9
    
    cmp cl, 'a'
    je hexadecimal_a
    
    cmp cl, 'A'
    je hexadecimal_a
    
    cmp cl, 'b'
    je hexadecimal_b
    
    cmp cl, 'B'
    je hexadecimal_b
    
    cmp cl, 'c'
    je hexadecimal_c
    
    cmp cl, 'C'
    je hexadecimal_c
    
    cmp cl, 'd'
    je hexadecimal_d
    
    cmp cl, 'D'
    je hexadecimal_d
    
    cmp cl, 'e'
    je hexadecimal_e
    
    cmp cl, 'E'
    je hexadecimal_e
    
    cmp cl, 'f'
    je hexadecimal_f
    
    cmp cl, 'F'
    je hexadecimal_f
    
    hexadecimal_0:
    
    mov binary[di], 0
    inc di
    mov binary[di], 0
    inc di
    mov binary[di], 0
    inc di
    mov binary[di], 0
    inc di
    jmp from_hexadecimal_start
    
    hexadecimal_1:
    
    mov binary[di], 0
    inc di
    mov binary[di], 0
    inc di
    mov binary[di], 0
    inc di
    mov binary[di], 1
    inc di
    jmp from_hexadecimal_start
    
    hexadecimal_2:
    
    mov binary[di], 0
    inc di
    mov binary[di], 0
    inc di
    mov binary[di], 1
    inc di
    mov binary[di], 0
    inc di
    jmp from_hexadecimal_start
    
    hexadecimal_3:
    
    mov binary[di], 0
    inc di
    mov binary[di], 0
    inc di
    mov binary[di], 1
    inc di
    mov binary[di], 1
    inc di
    jmp from_hexadecimal_start
    
    hexadecimal_4:
    
    mov binary[di], 0
    inc di
    mov binary[di], 1
    inc di
    mov binary[di], 0
    inc di
    mov binary[di], 0
    inc di
    jmp from_hexadecimal_start
    
    hexadecimal_5:
    
    mov binary[di], 0
    inc di
    mov binary[di], 1
    inc di
    mov binary[di], 0
    inc di
    mov binary[di], 1
    inc di
    jmp from_hexadecimal_start
    
    hexadecimal_6:
    
    mov binary[di], 0
    inc di
    mov binary[di], 1
    inc di
    mov binary[di], 1
    inc di
    mov binary[di], 0
    inc di
    jmp from_hexadecimal_start
    
    hexadecimal_7:
    
    mov binary[di], 0
    inc di
    mov binary[di], 1
    inc di
    mov binary[di], 1
    inc di
    mov binary[di], 1
    inc di
    jmp from_hexadecimal_start
    
    hexadecimal_8:
    
    mov binary[di], 1
    inc di
    mov binary[di], 0
    inc di
    mov binary[di], 0
    inc di
    mov binary[di], 0
    inc di
    jmp from_hexadecimal_start
    
    hexadecimal_9:
    
    mov binary[di], 1
    inc di
    mov binary[di], 0
    inc di
    mov binary[di], 0
    inc di
    mov binary[di], 1
    inc di
    jmp from_hexadecimal_start
    
    hexadecimal_a:
    
    mov binary[di], 1
    inc di
    mov binary[di], 0
    inc di
    mov binary[di], 1
    inc di
    mov binary[di], 0
    inc di
    jmp from_hexadecimal_start
    
    hexadecimal_b:
    
    mov binary[di], 1
    inc di
    mov binary[di], 0
    inc di
    mov binary[di], 1
    inc di
    mov binary[di], 1
    inc di
    jmp from_hexadecimal_start
    
    hexadecimal_c:
    
    mov binary[di], 1
    inc di
    mov binary[di], 1
    inc di
    mov binary[di], 0
    inc di
    mov binary[di], 0
    inc di
    jmp from_hexadecimal_start
    
    hexadecimal_d:
    
    mov binary[di], 1
    inc di
    mov binary[di], 1
    inc di
    mov binary[di], 0
    inc di
    mov binary[di], 1
    inc di
    jmp from_hexadecimal_start
    
    hexadecimal_e:
    
    mov binary[di], 1
    inc di
    mov binary[di], 1
    inc di
    mov binary[di], 1
    inc di
    mov binary[di], 0
    inc di
    jmp from_hexadecimal_start
    
    hexadecimal_f:
    
    mov binary[di], 1
    inc di
    mov binary[di], 1
    inc di
    mov binary[di], 1
    inc di
    mov binary[di], 1
    inc di
    jmp from_hexadecimal_start
    
    end_input_to_binary_proc:
    
    mov binary_size, di
    ret
    
input_to_binary endp

binary_to_output proc
    
    mov si, 0
    mov di, 0
    
    cmp to, 'b'
    je to_binary_start
    
    cmp to, 'o'
    je to_octal_start
    
    cmp to, 'd'
    je to_decimal_start
    
    cmp to, 'h'
    je to_hexadecimal_start

    to_binary_start:
    
    cmp binary_size, si
    je end_binary_to_output_proc
    
    mov ah, binary[si]
    add ah, 48
    mov output[di], ah
    inc si
    inc di
    jmp to_binary_start
    
    to_octal_start:
    
    mov ax, binary_size
    mov bx, 3
    mov dx, 0
    div bx
    
    call shift_binary_array
    
    mov si, 0
    mov di, 0
    
    binary_2_octal_loop:
    
    cmp si, binary_size
    jge end_binary_to_output_proc
    
    cmp binary[si], 1
    je octal_1xx
    jmp octal_0xx
    
    octal_1xx:
    
    inc si
    
    cmp binary[si], 1
    je octal_11x
    jmp octal_10x
    
    octal_0xx:
    
    inc si
    
    cmp binary[si], 1
    je octal_01x
    jmp octal_00x
    
    octal_11x:
    
    inc si
    
    cmp binary[si], 1
    je octal_111
    jmp octal_110
    
    octal_10x:
    
    inc si
    
    cmp binary[si], 1
    je octal_101
    jmp octal_100
    
    octal_01x:
    
    inc si
    
    cmp binary[si], 1
    je octal_011
    jmp octal_010
    
    octal_00x:
    
    inc si
    
    cmp binary[si], 1
    je octal_001
    jmp octal_000
    
    octal_000:
    
    mov output[di], '0'
    jmp binary_2_octal_loop_interim
    
    octal_001:
    
    mov output[di], '1'
    jmp binary_2_octal_loop_interim
    
    octal_010:
    
    mov output[di], '2'
    jmp binary_2_octal_loop_interim
    
    octal_011:
    
    mov output[di], '3'
    jmp binary_2_octal_loop_interim
    
    octal_100:
    
    mov output[di], '4'
    jmp binary_2_octal_loop_interim
    
    octal_101:
    
    mov output[di], '5'
    jmp binary_2_octal_loop_interim
    
    octal_110:
    
    mov output[di], '6'
    jmp binary_2_octal_loop_interim
    
    octal_111:
    
    mov output[di], '7'
    jmp binary_2_octal_loop_interim
    
    binary_2_octal_loop_interim:
    
    inc si
    inc di
    
    jmp binary_2_octal_loop
    
    to_decimal_start:
    
    mov si, binary_size
    dec si
    mov bx, 1
    mov cx, 0
    
    binary_2_decimal_loop:
    
    cmp si, 0
    jl break_decimal
    
    mov ax, 0
    mov al, binary[si]
    mul bx
    add cx, ax
    mov ax, bx
    mov dx, 2
    mul dx
    mov bx, ax
    dec si
    jmp binary_2_decimal_loop
    
    break_decimal:
    
    mov si, 0
    mov ax, cx
    mov bx, 10
    
    break_decimal_loop:
    
    cmp ax, 0
    je reverse_output
    
    mov dx, 0
    div bx
    add dl, 48
    mov output[si], dl
    inc si
    jmp break_decimal_loop
    
    reverse_output:
    
    dec si
    mov di, 0
    
    reverse_output_loop:
    
    cmp si, di
    jle end_binary_to_output_proc
    
    mov ah, output[si]
    mov al, output[di]
    mov output[si], al
    mov output[di], ah
    inc di
    dec si
    jmp reverse_output_loop
    
    to_hexadecimal_start:
    
    mov ax, binary_size
    mov bx, 4
    mov dx, 0
    div bx
    
    call shift_binary_array
    
    mov si, 0
    mov di, 0
    
    binary_2_hex_loop:
    
    cmp si, binary_size
    jge end_binary_to_output_proc
    
    cmp binary[si], 1
    je hex_1xxx
    jmp hex_0xxx
    
    hex_1xxx:
    
    inc si
    
    cmp binary[si], 1
    je hex_11xx
    jmp hex_10xx
    
    hex_0xxx:
    
    inc si
    
    cmp binary[si], 1
    je hex_01xx
    jmp hex_00xx
    
    hex_11xx:
    
    inc si
    
    cmp binary[si], 1
    je hex_111x
    jmp hex_110x
    
    hex_10xx:
    
    inc si
    
    cmp binary[si], 1
    je hex_101x
    jmp hex_100x
    
    hex_01xx:
    
    inc si
    
    cmp binary[si], 1
    je hex_011x
    jmp hex_010x
    
    hex_00xx:
    
    inc si
    
    cmp binary[si], 1
    je hex_001x
    jmp hex_000x
    
    hex_111x:
    
    inc si
    
    cmp binary[si], 1
    je hex_1111
    jmp hex_1110
    
    hex_110x:
    
    inc si
    
    cmp binary[si], 1
    je hex_1101
    jmp hex_1100
    
    hex_101x:
    
    inc si
    
    cmp binary[si], 1
    je hex_1011
    jmp hex_1010
    
    hex_100x:
    
    inc si
    
    cmp binary[si], 1
    je hex_1001
    jmp hex_1000
    
    hex_011x:
    
    inc si
    
    cmp binary[si], 1
    je hex_0111
    jmp hex_0110
    
    hex_010x:
    
    inc si
    
    cmp binary[si], 1
    je hex_0101
    jmp hex_0100
    
    hex_001x:
    
    inc si
    
    cmp binary[si], 1
    je hex_0011
    jmp hex_0010
    
    hex_000x:
    
    inc si
    
    cmp binary[si], 1
    je hex_0001
    jmp hex_0000
    
    hex_0000:
    
    mov output[di], '0'
    jmp binary_2_hex_loop_interim
    
    hex_0001:
    
    mov output[di], '1'
    jmp binary_2_hex_loop_interim
    
    hex_0010:
    
    mov output[di], '2'
    jmp binary_2_hex_loop_interim
    
    hex_0011:
    
    mov output[di], '3'
    jmp binary_2_hex_loop_interim
    
    hex_0100:
    
    mov output[di], '4'
    jmp binary_2_hex_loop_interim
    
    hex_0101:
    
    mov output[di], '5'
    jmp binary_2_hex_loop_interim
    
    hex_0110:
    
    mov output[di], '6'
    jmp binary_2_hex_loop_interim
    
    hex_0111:
    
    mov output[di], '7'
    jmp binary_2_hex_loop_interim
    
    hex_1000:
    
    mov output[di], '8'
    jmp binary_2_hex_loop_interim
    
    hex_1001:
    
    mov output[di], '9'
    jmp binary_2_hex_loop_interim
    
    hex_1010:
    
    mov output[di], 'A'
    jmp binary_2_hex_loop_interim
    
    hex_1011:
    
    mov output[di], 'B'
    jmp binary_2_hex_loop_interim
    
    hex_1100:
    
    mov output[di], 'C'
    jmp binary_2_hex_loop_interim
    
    hex_1101:
    
    mov output[di], 'D'
    jmp binary_2_hex_loop_interim
    
    hex_1110:
    
    mov output[di], 'E'
    jmp binary_2_hex_loop_interim
    
    hex_1111:
    
    mov output[di], 'F'
    jmp binary_2_hex_loop_interim
    
    binary_2_hex_loop_interim:
    
    inc si
    inc di
    
    jmp binary_2_hex_loop
    
    end_binary_to_output_proc:
    
    ret
    
binary_to_output endp 

shift_binary_array proc
    
    mov si, binary_size
    
    cmp dx, 0
    je shift_array_loop_end
    
    sub bx, dx
    mov di, bx
    add di, si
    
    mov binary_size, di
    dec si
    dec di
    
    shift_array_loop:
    
    cmp si, 0
    jl shift_array_loop_end
    
    mov ah, binary[si]
    mov binary[di], ah
    mov binary[si], 0
    
    dec si
    dec di
    
    jmp shift_array_loop
    
    shift_array_loop_end:
    
    ret 
    
shift_binary_array endp    