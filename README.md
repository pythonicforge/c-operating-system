# C Operating System

A bare-bones operating system built from scratch using C, Assembly, and GRUB.

**Status:** 🚀 Bootloader working | Kernel running | VGA framebuffer display enabled

---

## Table of Contents

- [Project Overview](#project-overview)
- [Current Capabilities](#current-capabilities)
- [Architecture & Boot Process](#architecture--boot-process)
- [Project Structure](#project-structure)
- [Core Components](#core-components)
- [Building & Running](#building--running)
- [Development Journey](#development-journey)
- [Technology Stack](#technology-stack)
- [Future Roadmap](#future-roadmap)
- [Learning Resources](#learning-resources)

---

## Project Overview

This project documents my journey into **low-level systems programming** and **operating system development**. Rather than building a complete, feature-rich OS immediately, the focus is on understanding and implementing the fundamental concepts one layer at a time.

### Primary Goals

- Understand how computers bootstrap and hand off control to custom code
- Learn assembly language and CPU architecture hands-on
- Build a kernel that can execute in protected mode
- Implement core OS features (memory management, interrupts, I/O) incrementally
- Create a solid foundation for OS development knowledge

### Key Achievements (Current Stage)

✅ **Multiboot-compliant kernel** that GRUB can load  
✅ **ELF kernel image** properly formatted and loadable  
✅ **Protected mode execution** with custom CPU instructions  
✅ **VGA framebuffer output** for text display  
✅ **C kernel entry point** (`kmain`) with assembly bootstrap  
✅ **Successful boot** in Bochs emulator  

---

## Current Capabilities

The operating system can currently:

1. **Boot via GRUB bootloader** – Uses the Multiboot specification for standard bootloader compatibility
2. **Load kernel ELF executable** – Kernel is properly formatted and linked as an ELF binary
3. **Execute custom assembly code** – Control transfers to the assembly entry point in `loader.s`
4. **Display text on screen** – Writes directly to VGA memory at 0xB8000
5. **Execute C code** – Main kernel logic runs in the `kmain()` function
6. **Run in protected mode** – CPU executes in 32-bit protected mode with segmentation enabled

---

## Architecture & Boot Process

### Boot Sequence

```
BIOS Power-On
    ↓
BIOS Firmware (loads MBR)
    ↓
GRUB Bootloader (reads ISO, finds Multiboot header)
    ↓
GRUB loads kernel.elf into memory (0x00100000)
    ↓
GRUB jumps to entry point (loader symbol)
    ↓
Assembly Entry Point (loader.s)
    ├─ Validates Multiboot magic number
    ├─ Sets up CPU registers
    ├─ Calls C kernel entry point
    ↓
C Kernel (kmain.c)
    ├─ Initializes framebuffer
    ├─ Displays messages
    ├─ Enters idle loop
```

### Memory Layout

```
Address Space (32-bit Protected Mode):
0x00000000 - 0x000003FF  │ Interrupt Vector Table (IVT) - Legacy
0x00000400 - 0x000004FF  │ BIOS Data Area
0x00000500 - 0x0009FBFF  │ Conventional Memory (free)
0x00100000 (1MB)         │ ← Kernel loaded here by GRUB
0xB8000                  │ ← VGA text memory (used for display)
0xC0000000+              │ Higher half (future: kernel space)
```

### Multiboot Header

The kernel includes a Multiboot header that GRUB recognizes:

```asm
MAGIC_NUMBER equ 0x1BADB002
FLAGS equ 0x00000000
CHECKSUM equ -(MAGIC_NUMBER + FLAGS)

ALIGN 4
dd MAGIC_NUMBER
dd FLAGS
dd CHECKSUM
```

This header allows the bootloader to:
- Identify the kernel as Multiboot-compliant
- Determine where to load the kernel
- Know what mode to put the CPU in
- Pass boot information to the kernel

---

## Project Structure

```
c-operating-system/
├── README.md                 # This file - comprehensive project documentation
├── Makefile                  # Build automation and compilation rules
├── LICENSE                   # GPL v3.0 license
├── .gitignore               # Git exclusions (build artifacts, binaries, etc.)
│
├── loader.s                 # Assembly entry point (Multiboot, CPU setup)
├── kmain.c                  # C kernel main function
├── io.s                     # Low-level I/O assembly functions
├── io.h                     # I/O function declarations
├── fb.c                     # Framebuffer (VGA) driver implementation
├── link.ld                  # Linker script (memory layout configuration)
│
├── bochsrc.txt             # Bochs emulator configuration
│
└── iso/                     # ISO image directory (for bootable disk)
    └── boot/
        └── grub/
            └── menu.lst    # GRUB boot menu configuration
```

### File Descriptions

#### `loader.s` – Assembly Entry Point
**Purpose:** Handles CPU bootstrap and prepares environment for C kernel

**Contents:**
- Multiboot header with magic number and flags
- `loader` symbol (CPU entry point)
- CPU register initialization
- Stack setup
- Call to `kmain()`
- Infinite loop for error/idle state

**Key Code:**
```asm
loader:
    mov esp, KERNEL_STACK_TOP
    call kmain
    jmp loader  ; Infinite loop if kmain returns
```

#### `kmain.c` – C Kernel Entry Point
**Purpose:** Main kernel logic in C

**Current Implementation:**
```c
void kmain() {
    fb_write("Hi from my kernel!", 18);
    while (1) { }  // Idle loop
}
```

**Future:** Will grow to initialize interrupt handlers, device drivers, and process management.

#### `fb.c` / `io.h` – VGA Framebuffer Driver
**Purpose:** Provides text output functionality

**Features:**
- Direct VGA memory access (0xB8000)
- Character and color attribute writing
- Text positioning and scrolling support
- Simple string output functions

**Key Functions:**
```c
void fb_write(const char *buf, unsigned int len);
void fb_write_cell(unsigned int i, char c, unsigned char fg, unsigned char bg);
```

#### `io.s` – Low-Level I/O Assembly
**Purpose:** Assembly wrappers for I/O port operations

**Functions:**
- CPU port read/write operations
- Used for serial debugging, keyboard input, etc.

#### `link.ld` – Linker Script
**Purpose:** Defines memory layout and section organization

**Configuration:**
```ld
ENTRY(loader)          ; Start execution at 'loader'
SECTIONS {
    . = 0x00100000;    ; Load kernel at 1MB boundary
    /* Text, data, BSS sections */
}
```

**Why 1MB?** Standard location for OS kernels in protected mode; avoids BIOS/convention memory.

#### `bochsrc.txt` – Emulator Configuration
**Purpose:** Configures Bochs emulator behavior

**Settings:**
- Memory size (32MB default)
- CPU configuration
- ROM/BIOS images
- Boot device (CD-ROM)
- ISO image path
- Logging options

#### `Makefile` – Build System
**Purpose:** Automates compilation and linking

**Targets:**
- `make` – Build the kernel
- `make run` – Run in Bochs emulator
- `make iso` – Create bootable ISO
- `make clean` – Remove build artifacts

**Build Process:**
```
Assemble loader.s → loader.o
Compile kmain.c → kmain.o
Compile fb.c → fb.o
Compile io.s → io.o
Link with link.ld → kernel.elf
Create ISO with GRUB → os.iso
```

#### `iso/boot/grub/menu.lst` – GRUB Configuration
**Purpose:** Boot menu and kernel loading instructions

**Example:**
```text
title OS
kernel /boot/kernel.elf
```

---

## Core Components

### 1. **Bootstrap Assembly (loader.s)**

Responsible for:
- Validating Multiboot magic number (0x1BADB002)
- CPU register initialization
- Stack pointer setup
- Calling the C kernel
- Handling errors gracefully

**Protection:** If `kmain()` returns unexpectedly, the CPU enters an infinite loop rather than executing undefined memory.

### 2. **C Kernel (kmain.c)**

Entry point for high-level kernel logic:
- Framebuffer initialization
- Console output
- Idle loop (for now)

**Future expansion:** Device initialization, interrupt setup, process management, memory allocation.

### 3. **VGA Framebuffer Driver (fb.c)**

Provides text output via direct memory access:
- Writes characters to screen positions
- Manages foreground/background colors
- Supports basic text formatting

**Technical Details:**
- VGA text memory at address 0xB8000
- Each character occupies 2 bytes: [ASCII code][color attributes]
- Screen: 80 columns × 25 rows = 2000 characters
- Color format: 4-bit foreground + 4-bit background

### 4. **Linker Script (link.ld)**

Controls kernel memory organization:
- Sets kernel load address (1MB boundary)
- Aligns sections (.text, .data, .bss)
- Defines memory regions
- Symbols for kernel bounds

**Why Important:** Ensures the kernel loads at an address GRUB and the CPU expect, and keeps sections properly aligned.

### 5. **I/O Assembly (io.s)**

Low-level port I/O operations:
- Read from I/O ports (inb, inw, ind)
- Write to I/O ports (outb, outw, outd)
- Interrupt enable/disable

**Usage:** Needed for keyboard, serial port, and other hardware access.

---

## Building & Running

### Prerequisites

- GCC toolchain (cross-compiler for i386)
- NASM or AS (assembler)
- GNU LD (linker)
- GRUB 2 (bootloader)
- Bochs (emulator for testing)
- xorriso (for ISO creation)

### Installation (Ubuntu/Debian)

```bash
sudo apt-get install gcc-multilib nasm xorriso qemu
# For Bochs: sudo apt-get install bochs bochs-sdl
```

### Building the Kernel

```bash
# Compile and link
make

# Create bootable ISO
make iso

# Run in emulator
make run

# Clean build artifacts
make clean
```

### Running in Bochs

After `make run`, Bochs opens with the kernel executing. You should see:
- Bootloader messages
- Kernel startup
- "Hi from my kernel!" message on screen

Press `Ctrl+C` in the terminal or close the Bochs window to exit.

---

## Development Journey

### Phase 1: Boot & Execution ✅ (Current)
- [x] Multiboot header implementation
- [x] GRUB bootloader integration
- [x] Kernel entry point in assembly
- [x] Protected mode activation
- [x] Simple C kernel
- [x] VGA text output

### Phase 2: Display & I/O 🔄 (In Progress)
- [x] VGA framebuffer basics
- [ ] Scrolling and line wrapping
- [ ] Cursor positioning
- [ ] Color support
- [ ] Serial port debugging

### Phase 3: Interrupts
- [ ] Interrupt Descriptor Table (IDT)
- [ ] Keyboard input handling
- [ ] System calls
- [ ] Exception handling

### Phase 4: Memory Management
- [ ] Physical memory detection
- [ ] Paging setup
- [ ] Virtual memory
- [ ] Memory allocator (malloc/free)

### Phase 5: Processes & Multitasking
- [ ] Process/task structure
- [ ] Context switching
- [ ] Process scheduling
- [ ] Simple shell

### Phase 6: File System
- [ ] File system driver (FAT16, ext2, etc.)
- [ ] Directory structure
- [ ] File I/O operations
- [ ] Persistent storage

---

## Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Boot** | GRUB 2 | Multiboot-compliant bootloader |
| **CPU Mode** | x86 Protected Mode | 32-bit execution, segmentation |
| **Kernel Language** | C (with Assembly) | Portable, maintainable code |
| **Entry Point** | x86-64 Assembly | Bootstrap, CPU setup |
| **Build** | GNU Make | Automation |
| **Compilation** | GCC i386 toolchain | Cross-compilation |
| **Linking** | GNU LD + custom linker script | Memory layout control |
| **Display** | VGA Text Mode | Screen output |
| **Emulation** | Bochs | Testing and debugging |
| **Boot Medium** | ISO 9660 | Bootable image format |
| **License** | GPL v3.0 | Open-source |

### Language Composition

- **C:** 36.1% – Core kernel logic and drivers
- **Makefile:** 32.2% – Build system automation
- **Assembly:** 20.4% – CPU bootstrap and low-level I/O
- **Linker Script:** 11.3% – Memory layout and section organization

---

## Future Roadmap

### Short Term (Next 1-2 weeks)
- [ ] Enhance VGA driver with scrolling
- [ ] Add simple debugging/logging functions
- [ ] Implement serial port output for logs
- [ ] Clean up build system

### Medium Term (Next month)
- [ ] Basic interrupt handling (IRQ0/Timer)
- [ ] Keyboard input handling
- [ ] Memory detection and initialization
- [ ] Paging setup (virtual memory basics)

### Long Term (2-3 months+)
- [ ] Process/task management
- [ ] Context switching and scheduling
- [ ] File system support
- [ ] Shell/command interpreter
- [ ] Standard C library (newlib integration)
- [ ] Network support (ambitious!)

---

## Learning Resources

### Recommended Reading

- **"Operating Systems: Three Easy Pieces"** (free online) – Foundational OS concepts
- **"OSDev.org Wiki"** – Practical OS development tutorials
- **"Intel x86 Architecture Reference"** – CPU instruction set and modes
- **"GRUB Manual"** – Bootloader configuration and Multiboot spec
- **"The Linux Kernel"** – Real-world kernel implementation reference

### Key Specifications

- **Multiboot Specification** – Bootloader interface standard
- **Intel 386+ Architecture** – CPU modes, segmentation, paging
- **ELF Format** – Executable and Linkable Format for binaries
- **VGA Standard** – Text and graphics mode specifications

### Online Communities

- **OSDev.org Forums** – Active OS development community
- **GitHub Discussions** – Project-specific questions
- **Stack Overflow** – Specific technical issues with [os-dev] tag

---

## Contributing & Feedback

This is a personal learning project, but feedback, suggestions, and discussions are welcome!

**To contribute:**
1. Fork the repository
2. Create a feature branch
3. Make improvements or add documentation
4. Submit a pull request with a clear description

**To report issues:**
- Open a GitHub Issue with detailed reproduction steps
- Include error messages and environment information

---

## License

This project is licensed under the **GNU General Public License v3.0** – see the [LICENSE](LICENSE) file for details.

**Why GPL v3?** It ensures that any improvements or derivatives remain open-source and free for the community to benefit from.

---

## Acknowledgments

This project draws inspiration and knowledge from:
- The OSDev.org community and tutorials
- Operating systems textbooks and research
- The Linux kernel source code
- University OS development courses

---

## Quick Links

| Link | Purpose |
|------|---------|
| [OSDev.org](https://wiki.osdev.org/) | OS development knowledge base |
| [Multiboot Spec](https://www.gnu.org/software/grub/manual/multiboot/multiboot.html) | Bootloader standard |
| [Bochs Emulator](http://bochs.sourceforge.net/) | x86 emulator |
| [x86 Assembly Guide](https://www.cs.uaf.edu/2015/fall/cs301/reference/x86-64-asm.html) | Assembly reference |
| [GNU LD Documentation](https://sourceware.org/binutils/docs/ld/) | Linker script reference |

---

**Last Updated:** June 2026  
**Repository:** [github.com/pythonicforge/c-operating-system](https://github.com/pythonicforge/c-operating-system)  
**Status:** 🔧 Active Development
