.cpu "65816"                        ; Tell 64TASS that we are using a 65816

; Platform-specific functions
.include "platform.s"

; Code

* = $002000
START   CLC                         ; Make sure we're native mode
        XCE

        REP #$30
        .al
        .xl

        LDA #`PRE
        PHA
        PLB
        LDX #<>PRE
        JSL PUTS 

        SEP #$30  ; Set 8bit axy

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Value           |        8bit interpretation               |            16bit interpretation
;;;;;;;;;;;;;;;;;;|;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;|;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
.byte $A9         ;        LDA #$3A      A:3A ':'                        LDA #$3A3A                    
.byte $3A         ;           
.byte $3A         ;        DEC A         A:39 '9'        

.byte $29         ;        AND #$39                                      AND #$0939          ; A:0838
.byte $39
.byte $09         ;        ORA #$38      A:38 '8'
.byte $38         ;                                                      SEC               

.byte $E9         ;        SBC #$00                                      SBC #$1800          : A:F038
.byte $00         ;
.byte $18         ;        CLC

.byte $09         ;        ORA $#30                                      ORA #$2030          ; A:2037
.byte $30

.byte $20         ;        JSR $20EA                                     NOP
.byte $EA
.byte $20


DONE    NOP
        BRA DONE

* = $002037
MODE16 .null "16", 2
PRE   .null "This is in ", 11
SUF   .null "-bit mode.\n", 12

* = $0020EA
        NOP
        NOP
        NOP
        DEC A
        JSL PUTC
        REP #$30
        .al
        .xl
        LDA #`SUF
        PHA
        PLB
        LDX #<>SUF
        JSL PUTS 
        JMP $2012   ; Can change this later to a screwy return.


; Common opcodes which are also valid ASCII
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Note that ASCII goes from 0x30 to 0x7E.
;
; Mnemonic       Value
; --------       -----
; BMI near       30 __
; SEC            38
; DEC            3A
; PHA            48
; LSR A          4A
; RTS            60
; PLA            68
; ADC imm        69 __ (__)
; ROR            6A
; BVS near       70 __

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;.2014	a2 1e 20	ldx #$201e	        LDX #<>MSG8                ; The X register needs to be 16 bits for this to work.