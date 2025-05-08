[BITS 16]
[ORG 800h]

start:
    mov ax, 0x12
    int 0x10

    mov si, hello
    call print_string

    mov ah, 0x00
    int 0x16

    jmp 500h

print_string:
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x0F
.print_char:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .print_char
.done:
    ret

hello db 'Hello, world!', 0      
