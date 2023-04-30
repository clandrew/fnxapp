# Cheat sheet for 64tass Assembler

This contains some example syntax for working with named variables in case you need to refer to it.

In all the below examples, ```MYVAR``` is a variable located at ```$12:3456```:
```
* = $123456
MYVAR .byte 0
```

| Assembler syntax         | Result object code |  Result language | Comment                        |
| ------------------------ | ------------------ | ---------------- | ------------------------------ | 
| ```LDX #`MYVAR```        | a2 12 00           | ldx #$0012       |  Loads the bank, as a literal  | 
| ```LDX `MYVAR```         | ae 12 00           | ldx $0012        |  Loads the bank, as an address | 
| ```LDX #<>MYVAR```       | a2 56 34           | ldx #$3456       |  Loads the short address, as a literal       | 
| ```LDX <>MYVAR```        | ae 56 34           | ldx $3456        |  Loads whatever's at the short address       | 
