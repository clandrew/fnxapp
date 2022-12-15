.cpu "65816"                        ; Tell 64TASS that we are using a 65816

; Platform-specific functions
.include "platform.s"

; Code

* = $002000                         ; Set the origin for the file

START   CLC                         ; Make sure we're native mode
        XCE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; SEP #$30  ; Set 8bit axy
.byte $E2
.byte $30

; LDA #$46  ; ASCII F
.byte $A9
.byte $46

; JSL PUTC  ; Prints a character to the screen, based on 8bit acc.
.byte $22
.byte $18   ; CLC
.byte $10   ; BPL
.byte $00   ; BRK

; NOP
.byte $EA

; BRA above ; infinite loop
.byte $80
.byte $FD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;