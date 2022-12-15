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

        JSR MSG1

        SEP #$30  ; Set 8bit axy

DIV

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Value           |        8bit interpretation               |            16bit interpretation
;;;;;;;;;;;;;;;;;;|;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;|;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
.byte $A9         ;        LDA #$3A      A:3A ':'                        LDA #$3A3A                    
.byte $3A         ;           
.byte $3A         ;        DEC A         A:39 '9'        

.byte $29         ;        AND #$39                                      AND #$3A39          ; A:3A38
.byte $39

.byte $3A         ;        DEC A         A:38 '8'                                               

.byte $29         ;        AND #$38                                      AND #$2038          : A:2038
.byte $38

.byte $20         ;        JSR $20EA                                     
.byte $EA         ;                                                      NOP

.byte $20         ;                                                      JSR $20E0
.byte $E0         ; 
.byte $20         ; 

        TAX
        LDA #$0000
        PHA
        PLB
        PLB
        JSL PUTS 
        JSR MSG2

DONE    NOP
        BRA DONE

* = $002038
MODE16 .null "16"
PRE   .null "This is in "
SUF   .null "-bit mode.     "

* = $0020E0
        NOP
        RTS

* = $0020EA
        NOP
        NOP
        NOP
        JSL PUTC
        REP #$30
        .al
        .xl
        JSR MSG2
        JSR MSG1
        JMP DIV   ; Can change this later to a screwy return.

MSG1    LDA #`PRE
        PHA
        PLB
        PLB
        LDX #<>PRE
        JSL PUTS 
        NOP
        NOP
        RTS

MSG2    LDA #`SUF
        PHA
        PLB
        PLB
        LDX #<>SUF
        JSL PUTS 
        RTS


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