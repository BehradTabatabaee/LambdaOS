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

protected_reached: ; setting the registers
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp
    jmp $

times 510-($-$$) db 0
dw 0xAA55
