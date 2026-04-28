nasm -f bin boot.asm -o boot.bin
gcc -ffreestanding -m64 -c kernel.c -o kernel.o
ld -o kernel.bin -T linker.ld kernel.o --oformat binary
cat boot.bin kernel.bin > os-image.bin
qemu-system-x86_64 -drive format=raw,file=os-image.bin