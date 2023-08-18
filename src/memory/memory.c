#include "memory.h"

void *memset(void *start, int c, size_t size)
{
    char *start_ptr = (char *)start;
    for (int i = 0; i < size; i++)
    {
        start_ptr[i] = c;
    }
    return start;
}
