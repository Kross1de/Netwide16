bits 16
      org 7c00h

start:
      cli
      xor ax, ax 
      mov ds, ax 
      mov es, ax 
      mov ax, 0x03
      int 0x10
      mov si, message
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

message: db 'hello, world', 0

times 510-($-$$) db 0  
      dw 0aa55h
