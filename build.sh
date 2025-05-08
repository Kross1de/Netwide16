nasm -f bin src/boot.asm -o bin/boot.bin
nasm -f bin src/kernel.asm -o bin/kernel.bin
nasm -f bin src/snake.asm -o bin/snake.bin
nasm -f bin src/program.asm -o bin/program.bin
dd if=/dev/zero of=bin/image.img bs=512 count=16
dd if=bin/boot.bin of=bin/image.img conv=notrunc
dd if=bin/kernel.bin of=bin/image.img bs=512 seek=1 conv=notrunc
dd if=bin/program.bin of=bin/image.img bs=512 seek=5 conv=notrunc
dd if=bin/snake.bin of=bin/image.img bs=512 seek=6 conv=notrunc
qemu-system-i386 -hda bin/image.img
