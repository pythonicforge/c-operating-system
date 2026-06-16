void fb_write(const char *buf, unsigned int len);

void kmain()
{
    fb_write("Hi from my kernel!", 18);

    while (1)
    {
    }
}
