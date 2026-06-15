# C Operating System

My journey into operating system development using C, Assembly, GRUB, and Bochs.

## Overview

This project is my first step into low-level systems programming and operating system development.

The goal is not to build a complete operating system immediately, but to understand how a computer boots, how a kernel is loaded into memory, and how the CPU begins executing my own code.

At the current stage, the project successfully:

* Boots inside the Bochs emulator
* Uses GRUB as a Multiboot-compliant bootloader
* Loads a custom kernel ELF file
* Transfers execution control to my assembly entry point
* Executes custom assembly instructions



## What Happens During Boot

The current boot sequence is:

BIOS
→ GRUB
→ kernel.elf
→ loader entry point
→ custom assembly code

GRUB detects the Multiboot header inside the kernel and loads the ELF executable into memory.

After loading, execution jumps to the `loader` symbol defined as the kernel entry point.

---

## Project Structure

```text
loader.s
link.ld
bochsrc.txt
iso/
└── boot/
    └── grub/
        └── menu.lst
```

### loader.s

Contains:

* Multiboot header
* Kernel entry point
* Initial CPU instructions

Current behavior:

```asm
loader:
    mov eax, 0xCAFEBABE

.loop:
    jmp .loop
```

The kernel writes the value `0xCAFEBABE` into the EAX register and then enters an infinite loop.

This serves as a proof that the CPU successfully reaches and executes my code.

---

### link.ld

The linker script controls how the kernel is laid out in memory.

Key configuration:

```ld
ENTRY(loader)
```

This tells the linker that execution begins at the `loader` symbol.

---

### menu.lst

GRUB configuration file:

```text
title os
kernel /boot/kernel.elf
```

This instructs GRUB to load the kernel ELF image from the ISO.

---

### bochsrc.txt

Configuration file for the Bochs emulator.

It specifies:

* Memory size
* BIOS images
* Boot device
* ISO image
* Logging options

---

## Understanding CAFEBABE

The value:

```text
0xCAFEBABE
```

is a well-known hexadecimal marker frequently used by programmers.

In this project it acts as a recognizable value placed into a CPU register to confirm that execution has reached the kernel entry point.


## Current Status
[x] Multiboot-compliant kernel
[x] GRUB integration
[x] ELF kernel loading
[x] Successful boot in Bochs
[x] Custom assembly execution

### Next Goals

* Write text directly to VGA memory
* Display "Hello World" on screen
* Introduce a C kernel
* Build basic screen output functions
* Create a simple kernel architecture
* Learn memory management fundamentals
* Implement interrupts and keyboard input


## Why This Project Exists

I started this project to learn how computers work below the application level.

Instead of treating the operating system as a black box, this project aims to explore:

* Computer architecture
* Boot processes
* Assembly language
* Memory layout
* Kernel development
* Operating system design

Every feature will be built incrementally while learning the underlying concepts.
