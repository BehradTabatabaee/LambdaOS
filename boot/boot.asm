ORG 0
BITS 16
 
_start:
    jmp short start
    nop

times 33 db 0

start:
    jmp 0x7c0:real_start

real_start:
    cli ; clear interrupts
    
    mov eax,0x7c0
    mov es,eax
    mov ds,eax
    mov eax,0x00
    mov ss,eax
    mov sp,0x7c00

    sti ; set interrupts
    call print
    jmp $

print_char:
    mov ah,0x0e
    mov bh,0x00
    mov bl,0x07
    int 0x10
    ret

print:
    mov si, message

.loop:
    lodsb
    cmp al,0
    je .done
    call print_char
    jmp .loop

.done:
    ret

message: db 'Booted Successfully!',0

times 510-($-$$) db 0
dw 0xAA55