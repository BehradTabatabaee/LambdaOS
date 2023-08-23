section .asm

extern int21h_handler
extern no_interrupt_handler

global no_interrupt
global int21h
global idt_load
global enable_interrupts
global disable_interrupts

enable_interrupts:
    push ebp
    mov ebp, esp
    
    sti

    pop ebp
    ret

disable_interrupts:
    push ebp
    mov ebp,esp

    cli
    
    pop ebp
    ret

idt_load:
    push ebp
    mov ebp, esp

    mov ebx, [ebp+8]
    lidt [ebx]
    
    pop ebp
    ret

int21h:
    cli
    pushad
    call int21h_handler
    popad
    sti
    iret

no_interrupt:
    cli
    pushad
    call no_interrupt_handler
    popad
    sti
    iret 