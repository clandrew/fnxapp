.include "platform.s"

ORG     = $02000
* =  $02000 - 3*2 - 1 ; start, minus 2 blocks, minus signature byte.

; Place the one-byte PGZ signature before the code section
                .text "Z"     

; Three-byte address indicating where you want that segment to get loaded into memory
                .long ORG

; Three-byte segment size. Make sure this DOESN'T include the header.
                .long MAIN_SEGMENT_END - MAIN_SEGMENT_START

MAIN_SEGMENT_START

START           PHB
                PHP

                SEP #$20                ; A is 8-bit
                .as
                REP #$10                ;X, and Y are 16-bit
                .xl

                LDX #<>GREETING         ; Point to GREETING ; loads 1D
                LDA #`GREETING          ; loads 00, the data bank
                PHA
                PLB
                JSL PUTS                ; And print it
                                
                LDA #$0                 ; Set a return value of 0

                PLP
                PLB
                RTL                     ; Go back to the caller

GREETING        .null "Hello, world!", 13 

MAIN_SEGMENT_END

FINAL_SEGMENT_START
                .long START   ; Entrypoint
                .long 0       ; Dummy value to indicate this is the final segment
FINAL_SEGMENT_END