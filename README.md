# Hack Tools for Swift

A suite of tools for the Hack computer platform written in Swift. For more
info, visit [www.nand2tetris.org](https://www.nand2tetris.org/).

1. [`hsm`](#hsm) (NAND to Tetris Project 6)

-----

## `hsm`

An assembler for the Hack machine language written in Swift.

### Running

```
swift run hsm file.asm
```

This will produce a new file named `file.hack` alongside `file.asm`, encoded in
the Hack text format.

### Binary output

To produce a binary file, i.e., a sequence of big-endian 16-bit unsigned
integers, pass the `--binary` flag. It will be saved with the file extension
`.bhack`. I'm not aware of any emulator that can run these, I just thought it
would be fun to add. (Narrator: It was!)
