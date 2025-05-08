nasm -f bin boot.asm -o boot.bin
dd if=/dev/zero of=image.img bs=512 count=16
dd if=boot.bin of=image.img conv=notrunc
qemu-system-i386 -hda image.img
