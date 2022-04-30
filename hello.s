.include "platform.s"

; PGX header
* = START - 8
                .text "PGX"
                .byte $01
                .dword START

; Main code
* = $02000

START           PHB
                PHP

                REP #$30                ; A, X, and Y are 16-bit
                .al
                .xl

                SEP #$20                ; A is 8-bit
                .as
                REP #$10                ;X, and Y are 16-bit
                .xl

                LDX #<>GREETING         ; Point to GREETING
                LDA #`GREETING
                PHA
                PLB
                JSL PUTS                ; And print it

                REP #$20                ; A is 16-bit
                .al

                LDA #$1234              ; Set a return value of $1234

                PLP
                PLB
                RTL                     ; Go back to the caller

GREETING        .null "Hello, world!", 13
