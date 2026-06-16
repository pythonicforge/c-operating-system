global outb
global inb

; void outb(unsigned short port, unsigned char data)
outb:
    mov al, [esp + 8]
    mov dx, [esp + 4]
    out dx, al
    ret

; unsigned char inb(unsigned short port)
inb:
    mov dx, [esp + 4]
    in  al, dx
    ret
