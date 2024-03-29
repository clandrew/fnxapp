.cpu "65816"                        ; Tell 64TASS that we are using a 65816

; Platform-specific functions
.include "platform.s"

; Code

* = $002000                         ; Set the origin for the file

START   CLC                         ; Make sure we're native mode
        XCE

        ; This would normally be done with a macro "setas"
        SEP #$20                    ; Set M to 1 for 8-bit accumulator
        .as                         ; Tell 64TASS that the accumulator is 8-bit

        ; This would normally be done with a macro "setxl"
        REP #$10                    ; Set X to 0 for 16-bit index registers
        .xl                         ; Tell 64TASS that the index registers are 16-bit

        ; Set the data bank register to this bank. This might normally be done by a macro "setdbr"
        LDA #`GREET                 ; Set the data bank register to be the current bank of the program
        PHA
        PLB
        .databank `GREET            ; Tell 64TASS which data bank we're using

        LDX #<>GREET                ; Point to the message in an ASCIIZ string
        JSL PUTS                    ; And ask the kernel to print it
                                    ; Note: PUTS scrambles X.

_done   NOP                         ; Infinite loop when we're finished 
        BRA _done

GREET   .null "Hello, this is a test.", 13   ; The text to display. Will include a terminal NUL 