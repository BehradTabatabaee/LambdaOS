#include "io/io.h"
#include "disk.h"
#include "memory/memory.h"
#include "config.h"
#include "status.h"

struct disk disk;

int disk_read_sector(int lba, int total, void *buffer)
{
    // sending out total, lba and read command to the ports
    // since lba is a 32 bit address, we've gotta send it in 4 8 bit parts
    // for more information, read the boot.asm file inside src/boot
    outb(0x1F6, (lba >> 24) | 0xE0);
    outb(0x1F2, total);
    outb(0x1F3, (unsigned char)(lba & 0xff));
    outb(0x1F4, (unsigned char)(lba >> 8));
    outb(0x1F5, (unsigned char)(lba >> 16));
    outb(0x1F7, 0x20);

    unsigned short *ptr = (unsigned short *)buffer; // reading two bytes at a time
    for (int i = 0; i < total; i++)
    {
        // wait for the buffer to be ready
        char c = insb(0x1F7); // read one byte from the port
        // wait until the bit 3 is set
        while (!(c & 0x08))
        {
            c = insb(0x1F7);
        }

        // copy from hard disk to memory
        for (int j = 0; j < 256; j++)
        {
            *ptr = insw(0x1F0);
            ptr++;
        }
    }
    return 0;
}

void disk_search_and_init()
{
    memset(&disk, 0, sizeof(disk));
    disk.type = LAMBDAOS_DISK_TYPE_REAL;
    disk.sector_size = LAMBDAOS_SECTOR_SIZE;
}

struct disk *disk_get(int index)
{
    if (index != 0)
    {
        return 0; // invalid disk, return null
    }

    return &disk;
}

int disk_read_block(struct disk *idisk, unsigned int lba, int total, void *buf)
{
    if (idisk != &disk)
    {
        return -EIO;
    }

    return disk_read_sector(lba, total, buf);
}