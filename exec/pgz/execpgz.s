.include "platform.s"

* =  MAIN_SEGMENT_START - 7 ; Metadata is 7 bytes
                ; Main segment metadata

                ; Place the one-byte PGZ signature before the code section
                .text "Z"           

                ; Three-byte address indicating where you want the segment to be loaded into memory at. Up to you. Whatever you do, just make sure it's
                ; consistent with your compile offset ("* =") directive. If you prefer your segment start to align nicely with a bank or page boundary
                ; you may want to adjust the compilation offset accordingly. This program doesn't do that- the entrypoint starts at 2007.
                .long MAIN_SEGMENT_START               
                
                ; Three-byte segment size. Make sure the size DOESN'T include this metadata.
                .long MAIN_SEGMENT_END - MAIN_SEGMENT_START 

                ; Note that when your executable is loaded, *only* the data segment after the metadata is loaded into memory. 
                ; The 'Z' signature above, and the metadata isn't loaded into memory.

* =  $02000

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