[BITS 16]                        ; Specify 16-bit mode for real-mode operation
[ORG 500h]                       ; Set origin to 0x0500, where bootloader loads the kernel

start:
    mov ax, 0x12                 ; Set AX to 0x12 (BIOS video mode: 640x480, 16 colors)
    int 0x10                     ; Call BIOS interrupt 0x10 to set video mode
    mov si, hello_msg            ; Load address of hello message into SI
    call print_string_green      ; Call print_string to display welcome message
    call shell                   ; Call shell to start command-line interface

hang:
    jmp hang                     ; Infinite loop to halt execution

; Function to print a null-terminated string in green on black background
print_string_green:
    mov ah, 0x0E        ; BIOS teletype function (print character and advance cursor)
    mov bh, 0x00        ; Set display page to 0 (default video page)
    mov bl, 0x0A        ; Set color attribute: light green (0x0A) foreground, black background
.print_char:
    lodsb               ; Load next character from DS:SI into AL, increment SI
    cmp al, 0           ; Check if character is null (end of string)
    je .done            ; If null, jump to .done to exit
    int 0x10            ; Call BIOS interrupt 0x10 to print character in AL with color in BL
    jmp .print_char     ; Loop to print next character
.done:
    ret                 ; Return to caller
    
; Function to print a null-terminated string in cyan on black background
print_string_cyan:
    mov ah, 0x0E        ; BIOS teletype function (print character and advance cursor)
    mov bh, 0x00        ; Set display page to 0 (default video page)
    mov bl, 0x0B        ; Set color attribute: light cyan (0x0B) foreground, black background
.print_char:
    lodsb               ; Load next character from DS:SI into AL, increment SI
    cmp al, 0           ; Check if character is null (end of string)
    je .done            ; If null, jump to .done to exit
    int 0x10            ; Call BIOS interrupt 0x10 to print character in AL with color in BL
    jmp .print_char     ; Loop to print next character
.done:
    ret                 ; Return to caller

print_string:           ; Define the label for the print_string function
    mov ah, 0x0E        ; Set AH to 0x0E (BIOS teletype output function)
    mov bh, 0x00        ; Set BH to 0x00 (display page 0)
    mov bl, 0x0F        ; Set BL to 0x0F (white text on black background)
.print_char:            ; Label for the character printing loop
    lodsb               ; Load byte from DS:SI into AL, increment SI
    cmp al, 0           ; Compare AL with 0 (check for null terminator)
    je .done            ; If AL is 0, jump to .done (end of string)
    int 0x10            ; Call BIOS interrupt 0x10 to print character in AL
    jmp .print_char     ; Jump back to .print_char to process next character
.done:                  ; Label for the end of the function
    ret                 ; Return to caller
    
; Function to print a null-terminated string in red on black background
print_string_red:
    mov ah, 0x0E        ; BIOS teletype function (print character and advance cursor)
    mov bh, 0x00        ; Set display page to 0 (default video page)
    mov bl, 0x055FC     ; Set color attribute: red (0x04) foreground, black background
.print_char:
    lodsb               ; Load next character from DS:SI into AL, increment SI
    cmp al, 0           ; Check if character is null (end of string)
    je .done            ; If null, jump to .done to exit
    int 0x10            ; Call BIOS interrupt 0x10 to print character in AL with color in BL
    jmp .print_char     ; Loop to print next character
.done:
    ret                 ; Return to caller

shell:
    mov si, prompt               ; Load address of prompt string into SI
    call print_string            ; Call print_string to display prompt
    call read_command            ; Call read_command to get user input
    call print_newline           ; Call print_newline to add a newline
    call execute_command         ; Call execute_command to process input
    jmp shell                    ; Loop back to shell for next command

print_newline:
    mov ah, 0x0E                 ; Set AH to 0x0E (BIOS teletype output function)
    mov al, 0x0D                 ; Set AL to carriage return (0x0D)
    int 0x10                     ; Call BIOS interrupt 0x10 to move cursor to start of line
    mov al, 0x0A                 ; Set AL to line feed (0x0A)
    int 0x10                     ; Call BIOS interrupt 0x10 to move cursor down
    ret                          ; Return from print_newline function

read_command:
    mov di, command_buffer       ; Set DI to address of command buffer
    xor cx, cx                   ; Clear CX (tracks number of characters)
.read_loop:
    mov ah, 0x00                 ; Set AH to 0x00 (BIOS keyboard input function)
    int 0x16                     ; Call BIOS interrupt 0x16 to read keypress
    cmp al, 0x0D                 ; Compare AL with carriage return (Enter key)
    je .done_read                ; If Enter, jump to .done_read
    cmp al, 0x08                 ; Compare AL with backspace
    je .handle_backspace         ; If backspace, jump to .handle_backspace
    cmp cx, 255                  ; Compare CX with 255 (max buffer size)
    jge .done_read               ; If buffer full, jump to .done_read
    stosb                        ; Store AL (character) at [DI] and increment DI
    mov ah, 0x0E                 ; Set AH to 0x0E (BIOS teletype output)
    mov bl, 0x1F                 ; Set BL to 0x1F (attribute for colored text)
    int 0x10                     ; Call BIOS interrupt 0x10 to print character
    inc cx                       ; Increment character count
    jmp .read_loop               ; Loop back to read next key

.handle_backspace:
    cmp di, command_buffer       ; Compare DI with start of buffer
    je .read_loop                ; If at start, ignore backspace
    dec di                       ; Move DI back one position
    dec cx                       ; Decrement character count
    mov ah, 0x0E                 ; Set AH to 0x0E (BIOS teletype output)
    mov al, 0x08                 ; Set AL to backspace (move cursor left)
    int 0x10                     ; Call BIOS interrupt 0x10 to move cursor
    mov al, ' '                  ; Set AL to space (overwrite character)
    int 0x10                     ; Call BIOS interrupt 0x10 to print space
    mov al, 0x08                 ; Set AL to backspace again
    int 0x10                     ; Call BIOS interrupt 0x10 to move cursor back
    jmp .read_loop               ; Loop back to read next key

.done_read:
    mov byte [di], 0             ; Null-terminate the command string
    ret                          ; Return from read_command function

execute_command:
    mov si, command_buffer       ; Load address of command buffer into SI
    mov di, help_str             ; Load address of "help" string into DI
    call compare_strings         ; Call compare_strings to check if command is "help"
    je do_help                   ; If equal, jump to do_help
    mov si, command_buffer       ; Reload command buffer address into SI
    mov di, cls_str              ; Load address of "cls" string into DI
    call compare_strings         ; Call compare_strings to check if command is "cls"
    je do_cls                    ; If equal, jump to do_cls
    mov si, command_buffer       ; Reload command buffer address into SI
    mov di, date_str             ; Load address of "date" string into DI
    call compare_strings         ; Call compare_strings to check if command is "date"
    je print_date                ; If equal, jump to print_date
    mov si, command_buffer       ; Reload command buffer address into SI
    mov di, time_str             ; Load address of "time" string into DI
    call compare_strings         ; Call compare_strings to check if command is "time"
    je print_time                ; If equal, jump to print_time
    mov si, command_buffer       ; Reload command buffer address into SI
    mov di, load_str             ; Load address of "load" string into DI
    call compare_strings         ; Call compare_strings to check if command is "load"
    je load_program              ; If equal, jump to load_program
    call unknown_command         ; Call unknown_command for unrecognized input
    ret                          ; Return from execute_command function

compare_strings:
    xor cx, cx                   ; Clear CX (not used but initialized)
.next_char:
    lodsb                        ; Load byte from [SI] into AL and increment SI
    cmp al, [di]                 ; Compare AL with byte at [DI]
    jne .not_equal               ; If not equal, jump to .not_equal
    cmp al, 0                    ; Check if AL is null (end of string)
    je .equal                    ; If null, strings match, jump to .equal
    inc di                       ; Increment DI to compare next character
    jmp .next_char               ; Loop back to compare next character
.not_equal:
    ret                          ; Return (strings don’t match)
.equal:
    ret                          ; Return (strings match)

do_help:
    mov si, help_message         ; Load address of help message into SI
    call print_string            ; Call print_string to display help message
    ret                          ; Return from do_help function

do_cls:
    call clear_screen            ; Call clear_screen to clear the display
    ret                          ; Return from do_cls function

unknown_command:
    mov si, unknown_msg          ; Load address of unknown command message into SI
    call print_string_red        ; Call print_string to display error message
    call print_newline           ; Call print_newline to add a newline
    ret                          ; Return from unknown_command function

clear_screen:
    mov ax, 0x12                 ; Set AX to 0x12 (BIOS video mode: 640x480, 16 colors)
    int 0x10                     ; Call BIOS interrupt 0x10 to clear screen
    ret                          ; Return from clear_screen function                    

print_date:
    mov si, date_msg             ; Load address of date message into SI
    call print_string            ; Call print_string to display "Current date: "
    pusha                        ; Save all general-purpose registers
    mov ah, 0x04                 ; Set AH to 0x04 (BIOS get RTC date function)
    int 0x1A                     ; Call BIOS interrupt 0x1A to get date
    mov ah, 0x0E                 ; Set AH to 0x0E (BIOS teletype output)
    mov al, dl                   ; Copy day (DL) to AL
    shr al, 4                    ; Shift right to get high nibble
    add al, '0'                  ; Convert to ASCII digit
    int 0x10                     ; Print high nibble of day
    mov al, dl                   ; Reload day
    and al, 0x0F                 ; Mask to get low nibble
    add al, '0'                  ; Convert to ASCII digit
    int 0x10                     ; Print low nibble of day
    mov al, '.'                  ; Set AL to '.' (separator)
    int 0x10                     ; Print separator
    mov al, dh                   ; Copy month (DH) to AL
    shr al, 4                    ; Shift right to get high nibble
    add al, '0'                  ; Convert to ASCII digit
    int 0x10                     ; Print high nibble of month
    mov al, dh                   ; Reload month
    and al, 0x0F                 ; Mask to get low nibble
    add al, '0'                  ; Convert to ASCII digit
    int 0x10                     ; Print low nibble of month
    mov al, '.'                  ; Set AL to '.' (separator)
    int 0x10                     ; Print separator
    mov al, cl                   ; Copy year low byte (CL) to AL
    shr al, 4                    ; Shift right to get high nibble
    add al, '0'                  ; Convert to ASCII digit
    int 0x10                     ; Print high nibble of year
    mov al, cl                   ; Reload year low byte
    and al, 0x0F                 ; Mask to get low nibble
    add al, '0'                  ; Convert to ASCII digit
    int 0x10                     ; Print low nibble of year
    mov si, mt                   ; Load address of newline string into SI
    call print_string            ; Call print_string to add newline
    popa                         ; Restore all general-purpose registers
    ret                          ; Return from print_date function

date_msg db '  Current date: ', 0 ; Define date message string, null-terminated

print_time:
    mov si, time_msg             ; Load address of time message into SI
    call print_string            ; Call print_string to display "Current time: "
    pusha                        ; Save all general-purpose registers
    mov ah, 0x02                 ; Set AH to 0x02 (BIOS get RTC time function)
    int 0x1A                     ; Call BIOS interrupt 0x1A to get time
    mov ah, 0x0E                 ; Set AH to 0x0E (BIOS teletype output)
    mov al, ch                   ; Copy hours (CH) to AL
    shr al, 4                    ; Shift right to get high nibble
    add al, '0'                  ; Convert to ASCII digit
    int 0x10                     ; Print high nibble of hours
    mov al, ch                   ; Reload hours
    and al, 0x0F                 ; Mask to get low nibble
    add al, '0'                  ; Convert to ASCII digit
    int 0x10                     ; Print low nibble of hours
    mov al, ':'                  ; Set AL to ':' (separator)
    int 0x10                     ; Print separator
    mov al, cl                   ; Copy minutes (CL) to AL
    shr al, 4                    ; Shift right to get high nibble
    add al, '0'                  ; Convert to ASCII digit
    int 0x10                     ; Print high nibble of minutes
    mov al, cl                   ; Reload minutes
    and al, 0x0F                 ; Mask to get low nibble
    add al, '0'                  ; Convert to ASCII digit
    int 0x10                     ; Print low nibble of minutes
    mov al, ':'                  ; Set AL to ':' (separator)
    int 0x10                     ; Print Eldest son of a king, sent to conquer a foreign land
    mov si, mt                   ; Load address of newline string into SI
    call print_string            ; Call print_string to add newline
    popa                         ; Restore all general-purpose registers
    ret                          ; Return from print_time function

time_msg db '  Current time: ', 0 ; Define time message string, null-terminated

load_program:
    mov si, load_prompt          ; Load address of load prompt into SI
    call print_string            ; Call print_string to display prompt
    call read_number             ; Call read_number to get sector number
    mov si, mt                   ; Load address of newline string into SI
    call start_program           ; Call start_program to load and execute program
    ret                          ; Return from load_program function

read_number:
    mov di, number_buffer        ; Set DI to address of number buffer
    xor cx, cx                   ; Clear CX (tracks number of digits)
.read_loop:
    mov ah, 0x00                 ; Set AH to 0x00 (BIOS keyboard input function)
    int 0x16                     ; Call BIOS interrupt 0x16 to read keypress
    cmp al, 0x0D                 ; Compare AL with carriage return (Enter key)
    je .done_read                ; If Enter, jump to .done_read
    cmp al, 0x08                 ; Compare AL with backspace
    je .handle_backspace         ; If backspace, jump to .handle_backspace
    cmp cx, 5                    ; Compare CX with 5 (max digits)
    jge .read_loop               ; If max digits reached, ignore input
    cmp al, '0'                  ; Compare AL with '0'
    jb .read_loop                ; If below '0', ignore input
    cmp al, '9'                  ; Compare AL with '9'
    ja .read_loop                ; If above '9', ignore input
    stosb                        ; Store AL (digit) at [DI] and increment DI
    mov ah, 0x0E                 ; Set AH to 0x0E (BIOS teletype output)
    mov bl, 0x1F                 ; Set BL to 0x1F (attribute for colored text)
    int 0x10                     ; Call BIOS interrupt 0x10 to print digit
    inc cx                       ; Increment digit count
    jmp .read_loop               ; Loop back to read next key

.handle_backspace:
    cmp cx, 0                    ; Compare CX with 0 (check if buffer empty)
    je .read_loop                ; If empty, ignore backspace
    dec di                       ; Move DI back one position
    dec cx                       ; Decrement digit count
    mov ah, 0x0E                 ; Set AH to 0x0E (BIOS teletype output)
    mov al, 0x08                 ; Set AL to backspace (move cursor left)
    int 0x10                     ; Call BIOS interrupt 0x10 to move cursor
    mov al, ' '                  ; Set AL to space (overwrite digit)
    int 0x10                     ; Call BIOS interrupt 0x10 to print space
    mov al, 0x08                 ; Set AL to backspace again
    int 0x10                     ; Call BIOS interrupt 0x10 to move cursor back
    jmp .read_loop               ; Loop back to read next key

.done_read:
    mov byte [di], 0             ; Null-terminate the number string
    call convert_to_number       ; Call convert_to_number to convert string to number
    ret                          ; Return from read_number function

convert_to_number:
    mov si, number_buffer        ; Load address of number buffer into SI
    xor ax, ax                   ; Clear AX (not used but initialized)
    xor cx, cx                   ; Clear CX (will hold result)
.convert_loop:
    lodsb                        ; Load byte from [SI] into AL and increment SI
    cmp al, 0                    ; Compare AL with 0 (check for null terminator)
    je .done_convert             ; If null, jump to .done_convert
    sub al, '0'                  ; Convert ASCII digit to numeric value
    imul cx, 10                  ; Multiply current result by 10
    add cx, ax                   ; Add new digit to result
    jmp .convert_loop            ; Loop back to process next digit
.done_convert:
    mov [sector_number], cx      ; Store result in sector_number
    ret                          ; Return from convert_to_number function

load_prompt db 'Enter sector number: ', 0 ; Define load prompt string, null-terminated
number_buffer db 6 dup(0)        ; Reserve 6 bytes for number buffer, initialized to 0
sector_number dw 0               ; Reserve 2 bytes for sector number, initialized to 0

start_program:
    pusha                        ; Save all general-purpose registers
    mov ah, 0x02                 ; Set AH to 0x02 (BIOS read disk sectors function)
    mov al, 1                    ; Set AL to 1 (number of sectors to read)
    mov ch, 0                    ; Set CH to 0 (cylinder number)
    mov dh, 0                    ; Set DH to 0 (head number)
    mov cl, [sector_number]      ; Set CL to user-specified sector number
    mov bx, 800h                 ; Set BX to 0x0800 (memory address to load program)
    int 0x13                     ; Call BIOS interrupt 0x13 to read sector
    jc .disk_error               ; If carry flag set, jump to .disk_error
    jmp 800h                     ; Jump to 0x0800 to execute loaded program
    popa                         ; Restore all general-purpose registers (unreachable due to jmp)
    ret                          ; Return from start_program function (unreachable)

.disk_error:
    mov si, disk_error_msg       ; Load address of disk error message into SI
    call print_string            ; Call print_string to display error message
    popa                         ; Restore all general-purpose registers
    ret                          ; Return from start_program function

disk_error_msg db 'Disk read error!', 0 ; Define disk error message string, null-terminated

hello_msg db 'Hello from kernel', 13, 10, 0 ; Define welcome message, null-terminated
help_str db 'help', 0            ; Define "help" command string, null-terminated
cls_str db 'cls', 0              ; Define "cls" command string, null-terminated
date_str db 'date', 0            ; Define "date" command string, null-terminated
time_str db 'time', 0            ; Define "time" command string, null-terminated
load_str db 'load', 0            ; Define "load" command string, null-terminated
mt db 13, 10, 0                  ; Define newline string (CR+LF), null-terminated
help_message db "Commands: help, cls, date, time, load", 13, 10, 0 ; Define help message, null-terminated
prompt db '> ', 0                ; Define command prompt string, null-terminated
command_buffer db 25 dup(0)      ; Reserve 25 bytes for command buffer, initialized to 0
unknown_msg db 'Unknown command.', 0 ; Define unknown command message, null-terminated
