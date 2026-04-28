[bits 16]
[org 0x7c00]

start:
    mov [boot_drive], dl    ; BIOS stores boot drive in DL
    mov bp, 0x9000          ; Set up stack
    mov sp, bp

    call load_kernel        ; Load kernel from disk
    call switch_to_pm       ; Switch to 32-bit mode
    jmp $                   ; Hang if something fails

%include "gdt.asm"          ; Define your GDT here
%include "switch_to_64.asm" ; Code to handle the jump to Long Mode

[bits 32]
begin_pm:
    ; 1. Setup Paging (Required for 64-bit)
    ; 2. Enable PAE
    ; 3. Switch to Long Mode
    ; 4. Jump to the 64-bit kernel code at 0x1000
    jmp 0x1000

load_kernel:
    mov bx, 0x1000          ; Destination address
    mov dh, 2               ; Number of sectors to read
    mov dl, [boot_drive]
    ; BIOS Read Sectors function...
    ret

boot_drive db 0
times 512-2-($-$$) db 0
dw 0xaa55                   ; Boot signature