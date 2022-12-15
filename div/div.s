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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Value      ; 8bit interpretation    ; 16bit interpretation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            ;                        ;
.byte $A9    ; LDA #$3A               ; LDA #$3A3A                    
.byte $3A    ;                        ;
.byte $3A    ; DEC A                  ;       
;            ;                        ;        
.byte $29    ; AND #$39               ; AND #$3A39         
.byte $39    ;                        ;   
;            ;                        ;      
.byte $3A    ; DEC A                  ;       
;            ;                        ;      
.byte $29    ; AND #$38               ; AND #$2038       
.byte $38    ;                        ;   
;            ;                        ;      
.byte $20    ; JSR $20EA              ;                                    
.byte $EA    ;                        ; NOP
;            ;                        ;      
.byte $20    ;                        ; JSR $20E0
;            ;                        ;      
.byte $E0    ; 
.byte $20    ; 

        TAX
        JSR CLRB
        JSL PUTS 
        JSR MSG2

DONE    NOP         ; Spin
        BRA DONE

* = $002038
MODE16 .null "16"
PRE   .null "This is in "
SUF   .null "-bit mode.     "

CLRB    LDA #$0000
        PHA
        PLB
        PLB
        RTS

MSG1    JSR CLRB
        LDX #<>PRE
        JSL PUTS 
        RTS

MSG2    JSR CLRB
        LDX #<>SUF
        JSL PUTS 
        RTS

* = $0020E0
        RTS

* = $0020EA
        JSL PUTC
        REP #$30
        .al
        .xl
        JSR MSG2
        JSR MSG1
        JMP DIV   ; Can change this later to a screwy return.
