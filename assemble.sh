nasm -f win64 boot.asm -o boot.obj
lld-link boot.obj /subsystem:efi_application /entry:efi_main /out:BOOTX64.EFI