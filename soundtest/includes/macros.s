
;
; Stack parameters and locals utilities
; 

setaxs      .macro
            SEP #$30
            .as
            .xs
            .endm

setas       .macro
            SEP #$20
            .as
            .endm

setxs       .macro
            SEP #$10
            .xs
            .endm

setaxl      .macro
            REP #$30
            .al
            .xl
            .endm

setal       .macro
            REP #$20
            .al
            .endm

setxl       .macro
            REP #$10
            .xl
            .endm

setdp       .macro
            PHP
            setal
            PHA
            LDA #\1
            TCD
            PLA
            PLP
            .dpage \1
            .endm

setdbr      .macro
            PHP
            setas
            PHA
            LDA #\1
            PHA
            PLB
            PLA
            PLP
            .databank \1
            .endm

MOVEI_L     .macro dest, value
            setas
            LDA #<\value
            STA \dest
            LDA #>\value
            STA \dest+1
            LDA #`\value
            STA \dest+2
            .endm

MOVE_L      .macro dest, value
            setas
            LDA \value
            STA \dest
            LDA \value+1
            STA \dest+1
            LDA \value+2
            STA \dest+2
            .endm


use_mode8 .macro
            SEC
            XCE
            .endm

use_mode16 .macro
            CLC  
            XCE
            REP #$10 ; setxl
            .xl
            .endm
            
enable_int_mode8 .macro
            SEC
            XCE
            CLI
            .endm

disable_int_mode16 .macro
            CLC
            SEI
            CLC
            XCE
            REP #$10 ; setxl
            .xl
            .endm