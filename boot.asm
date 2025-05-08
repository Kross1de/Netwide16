bits 16                          ; Specify 16-bit mode for real-mode operation
org 7c00h                        ; Set origin to 0x7C00, where BIOS loads the bootloader

start:
    cli                          ; Disable interrupts to prevent interference during setup
    xor ax, ax                   ; Clear AX register by XORing it with itself
    mov ds, ax                   ; Set data segment (DS) to 0
    mov es, ax                   ; Set extra segment (ES) to 0
    mov ax, 0x03                 ; Set AX to 0x03 (BIOS video mode: 80x25 text mode)
    int 0x10                     ; Call BIOS interrupt 0x10 to set video mode

    ;; reading sectors from disk
    mov ah, 0x02                 ; Set AH to 0x02 (BIOS function to read disk sectors)
    mov al, 3                    ; Set AL to 3 (number of sectors to read)
    mov ch, 0                    ; Set CH to 0 (cylinder number)
    mov dh, 0                    ; Set DH to 0 (head number)
    mov cl, 2                    ; Set CL to 2 (starting sector number)
    mov bx, 0x500                ; Set BX to 0x0500 (memory address to load sectors: 0x0000:0x0500)
    int 0x13                     ; Call BIOS interrupt 0x13 to read disk sectors
    jc diskerr                   ; Jump to diskerr label if carry flag is set (indicating read error)
    ;; jumping to loaded code
    jmp 0x500                    ; Jump to 0x0500 to execute the loaded kernel code

diskerr:
    mov si, errmsg               ; Load address of error message string into SI
    mov di, 0xb800               ; Set DI to 0xB800 (video memory for text mode)
    call puts                    ; Call puts function to display error message
    jmp $                        ; Infinite loop to halt execution

puts:
    mov ah, 0x0e                 ; Set AH to 0x0E (BIOS teletype output function)
    .putc:
    lodsb                        ; Load byte from [SI] into AL and increment SI
    cmp al, 0                    ; Compare AL with 0 (check for null terminator)
    je .done                     ; If null, jump to .done to return
    int 0x10                     ; Call BIOS interrupt 0x10 to print character in AL
    jmp .putc                    ; Loop back to print next character
    .done:
    ret                          ; Return from puts function

errmsg: db 'Disk read error', 0  ; Define error message string, null-terminated

times 510-($-$$) db 0            ; Fill remaining space up to 510 bytes with zeros
dw 0aa55h                        ; Add boot signature (0xAA55) at bytes 511-512
