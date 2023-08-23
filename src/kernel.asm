[BITS 32]
global _start
extern kernel_main
CODE_SEG equ 0x08
DATA_SEG equ 0x10

_start: ; setting the registers
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp

    ; enabling the A20 Line
    in al, 0x92
    or al, 2
    out 0x92, al

    ; remapping the master PIC
    mov al, 00010001b
    out 0x20, al ; tell master PIC to initialize 
    mov al, 0x20; interrupt 0x20 is where master ISR should start
    out 0x21, al
    mov al, 00000001b
    out 0x21, al
    ; master PIC remapped
    
    call kernel_main
    jmp $

times 512-($-$$) db 0
