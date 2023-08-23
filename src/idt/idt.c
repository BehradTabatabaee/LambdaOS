#include "idt.h"
#include "../config.h"
#include "../memory/memory.h"
#include "../kernel.h"
#include "io/io.h"

struct interrupt_descriptor idt[LAMBDAOS_TOTAL_INTERRUPTS];
struct idtr idtr_descriptor;

extern void idt_load(struct idtr *address);
extern void int21h();
extern void no_interrupt();

void int21h_handler()
{
    terminal_print_string("Keyboard Pressed!", 2);
    outb(0x20, 0x20);
}

void no_interrupt_handler()
{
    outb(0x20, 0x20);
}

void set_interrupt(int interrupt_number, void *address)
{
    struct interrupt_descriptor *interrupt = &idt[interrupt_number];
    interrupt->first_offset = (uint32_t)address & 0x0000ffff;
    interrupt->segment_selector = KERNEL_CODE_SEGMENT;
    interrupt->zero = 0x00;
    interrupt->type_attributes = 0xEE;
    interrupt->second_offset = (uint32_t)address >> 16;
}

void interrupt_zero()
{
    terminal_print_string("Divide By Zero Exception!", 2);
}

void idt_init()
{
    memset(idt, 0, sizeof(idt));
    idtr_descriptor.limit = sizeof(idt) - 1;
    idtr_descriptor.base = (uint32_t)idt;

    for (int i = 0; i < LAMBDAOS_TOTAL_INTERRUPTS; i++)
    {
        set_interrupt(i, no_interrupt);
    }

    set_interrupt(0, interrupt_zero);
    set_interrupt(0x21, int21h);
    idt_load(&idtr_descriptor);
}