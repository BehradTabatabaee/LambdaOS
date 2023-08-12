ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code_segment - gdt_start ; gdt code segment offset
DATA_SEG equ gdt_data_segment - gdt_start ; gdt data segment offset

; gotta fill the first 36 bytes so that the bios wont overwrite them for us

_start:
    jmp short start
    nop

times 33 db 0

start:
    jmp 0:real_start

real_start:
    cli ; clear interrupts
    
    ; setting all of the segments to 0x7c0 cuz thats the location bios expects our bootloader to be

    mov ax,0x00
    mov es,ax
    mov ds,ax
    mov ss,ax
    mov sp,0x7c00

    sti ; set interrupts

.protected_mode:
    cli
    lgdt[gdt_descriptor]
    mov eax,cr0
    or eax,0x1
    mov cr0,eax
    jmp CODE_SEG:protected_reached

; GDT
gdt_start: ; created to calculate the gdt size

null_descriptor: ; fill the first 4 bytes with 0
    dd 0x0
    dd 0x0

gdt_code_segment:
    dw 0xffff ; segment limit, set to the maximum
    dw 0
    db 0
    db 0x9a ; access byte
    db 11001111b ; flags
    db 0

gdt_data_segment:
    dw 0xffff ; segment limit, set to the maximum
    dw 0
    db 0
    db 0x92 ; access byte
    db 11001111b ; flags
    db 0

gdt_end: ; created to calculate the gdt size

gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; size
    dd gdt_start ; offset

[BITS 32]

protected_reached: ; gotta load our kernel from the hard
    mov eax, 1 ; load from sector 1
    mov ecx, 100 ; for a total of 100 sectors
    mov edi, 0x0100000 ; into the address of edi
    call ata_lba_read
    jmp CODE_SEG:0x0100000

ata_lba_read: ; gotta send the LBA information to cpu buses
    mov ebx, eax  ; backup the LBA which is a 512 bytes sector
    ; sending the highest 8 bits of the LBA
    shr eax, 24 ; shift the eax register 24 bits to the right to get the highest 8 bits
    or eax, 0xE0 ; select the master drive
    mov dx, 0x1F6
    out dx, al ; sent the highest 8 bits

    ; sending number of sectors to read
    mov eax, ecx
    mov dx, 0x1F2
    out dx, al ; sent the number of sectors to read

    mov eax, ebx ; restore the backup LBA so we can send the remainder
    mov dx, 0x1F3
    out dx, al ; sent another 8 bits

    mov eax, ebx ; restoring the backup LBA so we can send the remainder
    mov dx, 0x1F4
    shr eax , 8
    out dx, al ; and another 8 bits

    mov eax, ebx ; restoring the backup LBA so we can send the remainder
    mov dx, 0x1F5
    shr eax, 16 ; getting the last 8 bits 
    out dx, al ; finished sending the LBA to cpu buses

    mov dx, 0x1F7 ; command port
    mov al, 0x20 ; read with retry
    out dx, al

.next_sector:
    push ecx

.try_again:
    mov dx, 0x1F7
    in al, dx
    test al, 8
    jz .try_again

    ; read 256 words at a time
    mov ecx, 256
    mov dx, 0x1F0
    rep insw ; read a word from the port 0x1F0 and store it into edi for 256 times
    pop ecx
    loop .next_sector
    ; finished reading sectors
    ret

times 510-($-$$) db 0
dw 0xAA55
