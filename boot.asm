bits 16
      org 7c00h

start:
      cli
      xor ax, ax 
      mov ds, ax 
      mov es, ax 
      mov ax, 0x03
      int 0x10
      mov ah, 0x0e
      mov al, 'A'
      int 0x10

hang:
      jmp hang

times 510-($-$$) db 0  
      dw 0aa55h
