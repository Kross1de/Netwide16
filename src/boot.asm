bits 16                          ; Specify 16-bit mode for real-mode operation
org 7c00h                        ; Set origin to 0x7C00, where BIOS loads the bootloader

start:
    cli                          ; Disable interrupts to prevent interference during setup
    xor ax, ax                   ; Clear AX register by XORing it with itself
    mov ds, ax                   ; Set data segment (DS) to 0
    mov es, ax                   ; Set extra segment (ES) to 0
    mov ss, ax                   ; Set stack segment (SS) to 0
    mov sp, 0x7C00               ; Set stack pointer to just below bootloader

    ;; Set video mode
    mov ax, 0x12                 ; Set AX to 0x12 (BIOS video mode: 640x480, 16 colors)
    int 0x10                     ; Call BIOS interrupt 0x10 to set video mode

    ;; Perform CPU check
    mov si, cpu_check_msg        ; Load CPU check message
    call puts                    ; Display checking message
    call check_cpu               ; Check CPU compatibility
    jc cpu_error                 ; Jump to cpu_error if check fails
    mov si, success_msg          ; Load success message
    call puts                    ; Display success message

    ;; Perform RAM check
    mov si, ram_check_msg        ; Load RAM check message
    call puts                    ; Display checking message
    call check_ram               ; Check available RAM
    jc ram_error                 ; Jump to ram_error if insufficient RAM
    mov si, success_msg          ; Load success message
    call puts                    ; Display success message

    ;; Perform disk check
    mov si, disk_check_msg       ; Load disk check message
    call puts                    ; Display checking message
    call check_disk              ; Check disk availability
    jc diskerr                   ; Jump to diskerr if disk check fails
    mov si, success_msg          ; Load success message
    call puts                    ; Display success message

    ;; Reading sectors from disk
    mov si, loading_msg          ; Load kernel loading message
    call puts                    ; Display loading message
    mov ah, 0x02                 ; Set AH to 0x02 (BIOS function to read disk sectors)
    mov al, 3                    ; Set AL to 3 (number of sectors to read)
    mov ch, 0                    ; Set CH to 0 (cylinder number)
    mov dh, 0                    ; Set DH to 0 (head number)
    mov cl, 2                    ; Set CL to 2 (starting sector number)
    mov bx, 0x500                ; Set BX to 0x0500 (memory address to load sectors)
    int 0x13                     ; Call BIOS interrupt 0x13 to read disk sectors
    jc diskerr                   ; Jump to diskerr label if carry flag is set
    mov si, success_msg          ; Load success message
    call puts                    ; Display success message
    mov si, wait_for_key 
    call puts
    call wait_key
    ;; Jumping to loaded code
    jmp 0x500                    ; Jump to 0x0500 to execute the loaded kernel code

check_cpu:
    pushf                        ; Save flags
    push ax                      ; Save AX
    mov ax, 0x2401               ; Try to enable A20 line (simple CPU feature check)
    int 0x15                     ; Call BIOS interrupt 0x15
    jc .cpu_fail                 ; If carry flag set, CPU check failed
    pop ax                       ; Restore AX
    popf                         ; Restore flags
    clc                          ; Clear carry flag (success)
    ret
.cpu_fail:
    pop ax                       ; Restore AX
    popf                         ; Restore flags
    stc                          ; Set carry flag (failure)
    ret

check_ram:
    push ax                      ; Save AX
    push bx                      ; Save BX
    mov ah, 0x88                 ; BIOS function to get extended memory size
    int 0x15                     ; Call BIOS interrupt 0x15
    jc .ram_fail                 ; If carry flag set, RAM check failed
    cmp ax, 1024                 ; Check if at least 1MB of extended memory
    jb .ram_fail                 ; If below 1MB, fail
    pop bx                       ; Restore BX
    pop ax                       ; Restore AX
    clc                          ; Clear carry flag (success)
    ret
.ram_fail:
    pop bx                       ; Restore BX
    pop ax                       ; Restore AX
    stc                          ; Set carry flag (failure)
    ret

check_disk:
    push ax                      ; Save AX
    push dx                      ; Save DX
    mov ah, 0x08                 ; BIOS function to get drive parameters
    mov dl, 0x80                 ; Check first hard disk
    int 0x13                     ; Call BIOS interrupt 0x13
    jc .disk_fail                ; If carry flag set, disk check failed
    cmp dl, 0                    ; Check if any disks are present
    je .disk_fail                ; If no disks, fail
    pop dx                       ; Restore DX
    pop ax                       ; Restore AX
    clc                          ; Clear carry flag (success)
    ret
.disk_fail:
    pop dx                       ; Restore DX
    pop ax                       ; Restore AX
    stc                          ; Set carry flag (failure)
    ret

wait_key:
    mov ah, 0x00                 ; BIOS function to read keyboard input
    int 0x16                     ; Wait for key press
    ret                          ; Return after key press

cpu_error:
    mov si, cpu_errmsg           ; Load address of CPU error message
    call puts                    ; Display error message
    jmp $                        ; Infinite loop to halt

ram_error:
    mov si, ram_errmsg           ; Load address of RAM error message
    call puts                    ; Display error message
    jmp $                        ; Infinite loop to halt

diskerr:
    mov si, disk_errmsg          ; Load address of disk error message
    call puts                    ; Display error message
    jmp $                        ; Infinite loop to halt

puts:
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x1F
.print_char:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .print_char
.done:
    ret

cpu_check_msg db 'Checking CPU...', 13, 10, 0        ; CPU check message
ram_check_msg db 'Checking RAM...', 13, 10, 0        ; RAM check message
disk_check_msg db 'Checking disk...', 13, 10, 0      ; Disk check message
loading_msg db 'Loading kernel...', 13, 10, 0        ; Kernel loading message
success_msg db 'Success', 13, 10, 0                  ; Success message
cpu_errmsg db 'CPU check failed', 13, 10, 0          ; CPU error message
ram_errmsg db 'Insufficient RAM', 13, 10, 0          ; RAM error message
disk_errmsg db 'Disk read error', 13, 10, 0          ; Disk error message
wait_for_key db 'Press any key', 13, 10, 0           ; Wait for key

times 510-($-$$) db 0                        ; Fill remaining space up to 510 bytes with zeros
dw 0xAA55                                    ; Add boot signature (0xAA55)
