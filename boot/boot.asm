ORG 0
BITS 16

; gotta fill the first 36 bytes so that the bios wont overwrite them for us

_start:
    jmp short start
    nop

times 33 db 0

start:
    jmp 0x7c0:real_start

real_start:
    cli ; clear interrupts
    
    ; setting all of the segments to 0x7c0 cuz thats the location bios expects our bootloader to be

    mov eax,0x7c0
    mov es,eax
    mov ds,eax
    mov eax,0x00
    mov ss,eax
    mov sp,0x7c00

    sti ; set interrupts

    ; reading from hard drive

    mov ah,2 ; read
    mov al,1 ; one sector to read
    mov ch,0 ; cylinder number
    mov cl,2 ; sector number
    mov dh,0 ; head number
    mov bx,buffer ; put the data inside the bx register
    int 0x13 ; bios interrupt for reading from hard disk
    jc error ; jump error if the carry flag is set
    mov si,buffer ; move the buffer to si register so that we can print our message
    call print

    jmp $

error:
    mov si,error_message
    call print
    jmp $

print_char:
    mov ah,0x0e
    int 0x10
    ret

print:
    mov bh,0x00
    mov bl,0x07

.loop:
    lodsb
    cmp al,0
    je .done
    call print_char
    jmp .loop

.done:
    ret

error_message: db 'Failed To Read',0

times 510-($-$$) db 0
dw 0xAA55

buffer:
