#ifndef IDT_H
#define IDT_H
#include <stdint.h>

struct interrupt_descriptor
{
    uint16_t first_offset; // offset bits 0-8
    uint16_t segment_selector;
    uint8_t zero;            // does nothing
    uint8_t type_attributes; // descriptor type and attributes
    uint16_t second_offset;  // offset bits 16-31
} __attribute__((packed));

// idt register
struct idtr
{
    uint16_t limit; // size of idt - 1
    uint32_t base;  // address of the start of the idt
} __attribute__((packed));

void idt_init();

#endif