	bits 16
	org 500h

start:
	mov ax, 0x03
	int 0x10
	mov si, helloMsg
	call puts
	call hang

puts:
	mov ah, 0x0e
	.putc:
	lodsb
	cmp al, 0
	je .done
	int 0x10
	jmp .putc
	.done:
	ret

hang:
	jmp hang

helloMsg:	db 'Hello from kernel!', 0
