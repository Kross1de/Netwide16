[BITS 16]
[ORG 500h]

start:
	mov ax, 0x03
	int 0x10

	mov si, hello_msg     
	call print_string

	call shell

hang:
	jmp hang              

print_string:
	mov ah, 0x0E          
	.print_char:
	lodsb                 
	cmp al, 0             
	je .done              
	int 0x10              
	jmp .print_char       
	.done:
	ret

shell:
	mov si, prompt
	call print_string
	call read_command
	call print_newline
	call execute_command
	jmp shell

print_newline:
	mov ah, 0x0E
	mov al, 0x0D
	int 0x10
	mov al, 0x0A
	int 0x10
	ret

read_command:
	mov di, command_buffer
	xor cx, cx
	.read_loop:
	mov ah, 0x00
	int 0x16
	cmp al, 0x0D
	je .done_read
	cmp al, 0x08
	je .handle_backspace
	cmp cx, 255
	jge .done_read
	stosb
	mov ah, 0x0E
	mov bl, 0x1F
	int 0x10
	inc cx
	jmp .read_loop

	.handle_backspace:
	cmp di, command_buffer
	je .read_loop
	dec di
	dec cx
	mov ah, 0x0E
	mov al, 0x08
	int 0x10
	mov al, ' '
	int 0x10
	mov al, 0x08
	int 0x10
	jmp .read_loop

	.done_read:
	mov byte [di], 0
	ret

execute_command:
	mov si, command_buffer
	mov di, help_str
	call compare_strings
	je do_help

	mov si, command_buffer
	mov di, cls_str
	call compare_strings
	je do_cls

	call unknown_command
	ret

compare_strings:
	xor cx, cx
	.next_char:
	lodsb
	cmp al, [di]
	jne .not_equal
	cmp al, 0
	je .equal
	inc di
	jmp .next_char
	.not_equal:
	ret
	.equal:
	ret

do_help:
	mov si, help_message
	call print_string
	ret

do_cls:
	call clear_screen
	ret

unknown_command:
	mov si, unknown_msg
	call print_string
	call print_newline
	ret

clear_screen:
	mov ax, 0x03
	int 0x10
	ret

hello_msg 	db 'Hello from kernel!', 13, 10, 0   
help_str 	db 'help', 0
cls_str 	db 'cls', 0
help_message 	db "Commands: help, cls", 13, 10, 0
prompt 		db '> ', 0
command_buffer  db 25 dup(0)
unknown_msg 	db 'Unknown command.', 0
