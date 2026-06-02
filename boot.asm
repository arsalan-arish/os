; =============================================================
; Proper Minimal x86_64 UEFI Bootloader (NASM)
; - Correct Microsoft x64 ABI usage
; - Proper stack alignment
; - Correct GOP GUID encoding
; - Retrieves Framebuffer Base Address
; - Gets Memory Map
; - Exits Boot Services
; - Jumps to raw assembly (mov rax, 50)
; =============================================================

BITS 64
DEFAULT REL

SECTION .text
GLOBAL efi_main

; -------------------------------------------------------------
; UEFI Entry
; RCX = ImageHandle
; RDX = EFI_SYSTEM_TABLE*
; -------------------------------------------------------------

efi_main:

    ; Preserve non-volatile registers we use
    push r12
    push r13
    push r14
    push r15

    mov r12, rcx                ; ImageHandle
    mov r13, rdx                ; SystemTable

    ; BootServices = SystemTable->BootServices (offset 96)
    mov r14, [r13 + 96]

; =============================================================
; Locate Graphics Output Protocol (GOP)
; =============================================================

    ; Allocate 16-byte GUID on stack (plus shadow space)
    sub rsp, 40                 ; 32 shadow + 8 alignment

    ; EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID
    ; 9042A9DE-23DC-4A38-96FB-7ADED080516A

    mov dword [rsp],     0x9042A9DE
    mov word  [rsp+4],   0x23DC
    mov word  [rsp+6],   0x4A38

    mov byte  [rsp+8],   0x96
    mov byte  [rsp+9],   0xFB
    mov byte  [rsp+10],  0x7A
    mov byte  [rsp+11],  0xDE
    mov byte  [rsp+12],  0xD0
    mov byte  [rsp+13],  0x80
    mov byte  [rsp+14],  0x51
    mov byte  [rsp+15],  0x6A

    lea rcx, [rsp]              ; GUID*
    xor rdx, rdx                ; Registration = NULL
    lea r8,  [rsp+16]           ; Interface** output

    mov rax, [r14 + 88]         ; BootServices->LocateProtocol
    call rax

    mov r15, [rsp+16]           ; r15 = GOP*

    add rsp, 40

; =============================================================
; Extract Framebuffer Base and GOP Info
; GOP->Mode (offset 24)
; Mode->FrameBufferBase (offset 24)
; Mode->Info (offset 8)
; =============================================================

    mov rax, [r15 + 24]         ; Mode*
    mov rbx, [rax + 24]         ; FrameBufferBase
    mov rcx, [rax + 8]          ; Info*

    mov [framebuffer_addr], rbx

    ; Extract resolution info from Mode->Info
    mov edx, [rcx + 4]          ; HorizontalResolution
    mov [horiz_res], edx

    mov edx, [rcx + 8]          ; VerticalResolution
    mov [vert_res], edx

    mov edx, [rcx + 16]         ; PixelsPerScanLine
    mov [pixels_per_line], edx

; =============================================================
; Get Memory Map
; =============================================================

    sub rsp, 40                 ; shadow + align

    xor rcx, rcx
    xor rdx, rdx
    xor r8,  r8
    xor r9,  r9

    mov rax, [r14 + 56]         ; GetMemoryMap
    call rax

    ; Allocate pool for map (8 KB)
    mov rcx, 8192
    mov rdx, 2                  ; EfiLoaderData
    xor r8, r8

    mov rax, [r14 + 40]         ; AllocatePool
    call rax

    mov rdi, rax                ; buffer

    ; Real GetMemoryMap
    mov rcx, 8192
    mov rdx, rdi
    lea r8,  [rsp]              ; MapKey
    lea r9,  [rsp+8]            ; DescriptorSize

    mov rax, [r14 + 56]
    call rax

; =============================================================
; Exit Boot Services
; =============================================================

    mov rcx, r12                ; ImageHandle
    mov rdx, [rsp]              ; MapKey

    mov rax, [r14 + 64]         ; ExitBootServices
    call rax

    ; Check for success (should return 0)
    cmp rax, 0
    jne .boot_fail              ; If failed, hang

    add rsp, 40

; =============================================================
; Firmware is now gone
; =============================================================

    jmp kernel_entry


; =============================================================
; RAW ASSEMBLY STARTS HERE
; =============================================================

.boot_fail:
    jmp .boot_fail              ; Infinite loop if boot services exit failed

kernel_entry:

    ; ------------------------------------
    ; Load framebuffer address and settings
    ; (These were saved before ExitBootServices)
    ; ------------------------------------

    mov rdi, [framebuffer_addr]    ; rdi = framebuffer base
    mov edx, [vert_res]            ; VerticalResolution
    mov r9d, [pixels_per_line]     ; PixelsPerScanLine

    ; total pixels = vertical * pixels_per_scanline
    mov eax, edx
    imul eax, r9d
    mov ecx, eax                   ; ecx = total pixels

    ; ------------------------------------
    ; Fill screen green
    ; ------------------------------------

    mov eax, 0x0000FF00            ; green pixel (BGRA)

fill_loop:
    mov [rdi], eax
    add rdi, 4
    loop fill_loop

hang:
    cli                            ; Disable interrupts
    jmp hang                       ; Infinite loop


SECTION .data

framebuffer_addr dq 0
horiz_res dd 0
vert_res dd 0
pixels_per_line dd 0