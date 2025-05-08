nasm -f bin boot.asm -o boot.bin
nasm -f bin kernel.asm -o kernel.bin
nasm -f bin program.asm -o program.bin
dd if=/dev/zero of=image.img bs=512 count=16
dd if=boot.bin of=image.img conv=notrunc
dd if=kernel.bin of=image.img bs=512 seek=1 conv=notrunc
dd if=program.bin of=image.img bs=512 seek=5 conv=notrunc
qemu-system-i386 -hda image.img
