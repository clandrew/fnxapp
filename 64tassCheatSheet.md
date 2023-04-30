# Cheat sheet for 64tass Assembler

This contains some example syntax in case you need to refer to it.

In all the below examples, ```MYVAR``` is a variable located at ```$12:3456```:
```
* = $123456
MYVAR .byte 0
```

| Assembler syntax         |  Result     | Comment                   |
| ------------------------ | ----------- | ------------------------- | 
| ```LDX #`BEGIN_BANK0```  | ldx #$0012  |  Loads the bank           | 
| ```LDX #<>MYVAR```       | ldx #$3456  |  Loads the short address  | 
