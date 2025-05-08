	bits 16
	org 7c00h

start:
	cli
	xor ax, ax 
	mov ds, ax 
	mov es, ax 
	mov ax, 0x03
	int 0x10

	;; reading sectors from disk
	mov ah, 0x02		; BIOS function to read disk sectors
	mov al, 3		; sectors to read
	mov ch, 0		; cylinder (0)
	mov dh, 0		; header (0)
	mov cl, 2 		; starting sector number (2)
	mov bx, 0x500		; the address in memory where the data will be loaded (0x0000:0x0500)
	int 0x13		; BIOS interrupt for reading disk sectors
	jc diskerr		; if the carry flag (CF) is set, a read error has occurred
	;; jumping to loaded code
	jmp 0x500		; jump to address 0x0000:0x0500 (where the data is loaded)

diskerr:
	mov si, errmsg
	mov di, 0xb800
	call puts
	jmp $

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

errmsg: db 'Disk read error', 0
	
	times 510-($-$$) db 0  
	dw 0aa55h
