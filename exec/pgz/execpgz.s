.include "platform.s"

* =  $02000;
                ; Main segment metadata
                .text "Z"                                   ; Place the one-byte PGZ signature before the code section
                .long MAIN_SEGMENT_START                    ; Three-byte address indicating where you want that segment to get loaded into memory
                .long MAIN_SEGMENT_END - MAIN_SEGMENT_START ; Three-byte segment size. Make sure this DOESN'T include the header.

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

GREETING        .null "Hello, it's a PGZ!", 13

MAIN_SEGMENT_END

                ; Entrypoint segment metadata
                .long START   ; Entrypoint
                .long 0       ; Dummy value to indicate this segment is for declaring the entrypoint.