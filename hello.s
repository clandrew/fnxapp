.include "platform.s"

; PGX header
* = START - 8
                .text "PGX"
                .byte $01
                .dword START

; Main code
* = $02000

; Function: Main
; Postconditions:
;       - Return long.
;       - Processor bits are unchanged.
;       - Data bank is unchanged.
;
START           PHB
                PHP

                SEP #$20                ; A is 8-bit
                .as
                REP #$10                ;X, and Y are 16-bit
                .xl

                LDX #<>GREETING         ; X=address of GREETING
                LDA #`GREETING          ; A=data bank of GREETING
                PHA
                PLB                     ; Both X and data bank are set
                JSL PUTS                ; And print it

                LDA #$00                ; Set a return value of 0

                PLP                     ; Restore data bank and processor flags
                PLB
                RTL                     ; Go back to the caller

GREETING        .null "Hello, world!", 13
