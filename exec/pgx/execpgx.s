.include "platform.s"

; Place a PGX header before the code section
* = START - 8
                .text "PGX"
                .byte $01
                .dword START

; Code section
* = $020000

START           PHB
                PHP

                SEP #$20                ; A is 8-bit
                .as
                REP #$10                ;X, and Y are 16-bit
                .xl

                LDX #<>GREETING         ; Point to GREETING
                LDA #`GREETING
                PHA
                PLB
                JSL PUTS                ; And print it
                                
                LDA #$0                 ; Set a return value of 0

                PLP
                PLB
                RTL                     ; Go back to the caller

GREETING        .null "Hello, this is a PGX!", 13 