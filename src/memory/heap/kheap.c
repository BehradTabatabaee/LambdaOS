#include "kheap.h"
#include "heap.h"
#include "config.h"
#include "kernel.h"

struct heap kernel_heap;
struct heap_table kernel_heap_table;

void kheap_init()
{
    int total_table_entries = LAMBDAOS_HEAP_SIZE_BYTES / LAMBDAOS_HEAP_BLOCK_SIZE;
    kernel_heap_table.entries = (HEAP_BLOCK_TABLE_ENTRY *)(LAMBDAOS_HEAP_TABLE_ADDRESS);
    kernel_heap_table.total_entries = total_table_entries;
    void *end = (void *)(LAMBDAOS_HEAP_ADDRESS + LAMBDAOS_HEAP_SIZE_BYTES);
    int res = heap_create(&kernel_heap, (void *)(LAMBDAOS_HEAP_ADDRESS), end, &kernel_heap_table);
    if (res < 0)
    {
        terminal_print_string("Failed to create heap\n", 4);
    }
}

void *kmalloc(size_t size)
{
    return heap_malloc(&kernel_heap, size);
}

void kfree(void *ptr)
{
    heap_free(&kernel_heap, ptr);
}