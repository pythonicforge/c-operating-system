global loader

MAGIC_NUMBER equ 0x1BADB002
FLAGS equ 0x0
CHECKSUM equ -(MAGIC_NUMBER + FLAGS)
KERNEL_STACK_SIZE equ 4096

section .multiboot
align 4
    dd MAGIC_NUMBER
    dd FLAGS
    dd CHECKSUM

section .bss
align 4
kernel_stack:
    resb KERNEL_STACK_SIZE
kernel_stack_top:

section .text
loader:
    extern kmain
    mov esp, kernel_stack_top
    call kmain

.loop:
    jmp .loop
