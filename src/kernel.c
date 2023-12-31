#include "kernel.h"
#include <stdint.h>
#include <stddef.h>
#include "idt/idt.h"
#include "io/io.h"
#include "memory/heap/kheap.h"
#include "memory/paging/paging.h"
#include "disk/disk.h"

uint16_t *video_mem = (uint16_t *)(0xB8000);
uint16_t terminal_row = 0;
uint16_t terminal_col = 0;

uint16_t terminal_create_little_endian_character(char a, char color)
{
    return ((color << 8) | a);
}

void terminal_print_char_with_coordinates(int x, int y, char a, char color)
{
    video_mem[(y * VGA_WIDTH) + x] = terminal_create_little_endian_character(a, color);
}

void terminal_print_char_without_coordinates(char a, char color)
{
    if (a == '\n')
    {
        terminal_col = 0;
        terminal_row += 1;
        return;
    }
    terminal_print_char_with_coordinates(terminal_col, terminal_row, a, color);
    terminal_col += 1;
    if (terminal_col >= VGA_WIDTH)
    {
        terminal_col = 0;
        terminal_row += 1;
    }
}

void init_terminal()
{
    for (int y = 0; y < VGA_HEIGHT; y++)
    {
        for (int x = 0; x < VGA_WIDTH; x++)
        {
            terminal_print_char_with_coordinates(x, y, ' ', 0);
        }
    }
}

size_t strlen(const char *str)
{
    size_t len = 0;
    while (str[len])
    {
        len++;
    }
    return len;
}

void terminal_print_string(const char *str, char color)
{
    size_t len = strlen(str);
    for (int i = 0; i < len; i++)
    {
        terminal_print_char_without_coordinates(str[i], color);
    }
}

static struct paging_4gb_chunk *kernel_chunk = 0;
void kernel_main()
{
    init_terminal();
    terminal_print_string("Hello World!\nIm A Fucking God!\n", 2);

    // initializing kernel's heap
    kheap_init();

    // search and initialize the disks
    disk_search_and_init();

    // initializing the interrupt descriptor table
    idt_init();

    // set up paging
    kernel_chunk = paging_new_4gb(PAGING_IS_WRITEABLE | PAGING_IS_PRESENT | PAGING_ACCESS_FROM_ALL);

    // switch to kernel paging chunk
    paging_switch(paging_4gb_chunk_get_directory(kernel_chunk));

    // enable paging
    enable_paging();

    // enabling the interrupts
    enable_interrupts();
}
