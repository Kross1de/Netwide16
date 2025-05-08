# Netwide16

A 16-bit operating system written in NASM, built from scratch and inspired by the bare-bones kernel guide at [osdev.netlify.app](https://osdev.netlify.app/x16/mini-kernel/lesson1.html).

## Features

- **Graphics Support**: Renders graphics in 12h VGA mode.
- **Snake Game**: A fun, playable game included (credits to [PRoX2011/x16-PRos](https://github.com/PRoX2011/x16-PRos/blob/main/src/snake.asm)).
- **Interactive Shell**: A simple yet functional command-line interface.

## Roadmap

- [ ] Implement FAT16 filesystem support.
- [ ] Add more games for enhanced user experience.
- [ ] Develop graphical applications.

## Getting Started

1. Clone the repository: `git clone https://github.com/Kross1de/Netwide16.git`
2. Assemble the code using NASM, run: `chmod +x build.sh; ./build.sh`

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests to improve features or fix bugs.

## License

This project is licensed under the BSD-2-Clause License - see the [LICENSE](LICENSE) file for details.
