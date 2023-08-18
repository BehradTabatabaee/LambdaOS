#ifndef KERNEL_H
#define KERNEL_H
#define VGA_HEIGHT 20
#define VGA_WIDTH 80
void kernel_main();
void terminal_print_string(const char *str, char color);
#endif