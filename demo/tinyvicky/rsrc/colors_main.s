LUT_IMG_START				
.byte $00, $00, $00
.byte $00, $88, $70		; Green in top left. Color $01
.byte $10, $80, $60		; Next green, Color $02
.byte $00, $70, $58		; Next green, Color $03
.byte $00, $60, $50		; Next green, color $04
.byte $e8, $e0, $e0
.byte $f8, $f8, $f8
.byte $d0, $d0, $d0
.byte $20, $a0, $90
.byte $e0, $a0, $58
.byte $f8, $b8, $70		; 0xA
.byte $d0, $90, $40
.byte $f8, $d8, $98
.byte $e8, $e8, $e8
.byte $c0, $c0, $c0
.byte $b8, $b8, $b8

.byte $b0, $a8, $a8		; 0x10
.byte $98, $98, $98
.byte $80, $80, $78
.byte $68, $68, $68
.byte $00, $90, $70
.byte $00, $50, $40
.byte $50, $50, $50
.byte $40, $40, $40
.byte $18, $18, $18
.byte $28, $28, $28

.byte $00, $10, $20		; $1A
.byte $00, $00, $08		; $1B
.byte $00, $28, $38		; $1C
.byte $58, $58, $58		; $1D
.byte $00, $30, $40		; $1E
.byte $00, $40, $30		; $1F
				
; Tileset, contd, redundant with below. 
.byte $08, $10, $20		; $20
.byte $00, $38, $48		; $21
.byte $18, $48, $58		; $22
.byte $00, $30, $20		; $23
.byte $00, $70, $88		; $24 
.byte $00, $68, $80		; $25 

; For sprite
.byte $00, $28, $40		; $26
.byte $00, $38, $58		; $27
.byte $00, $38, $70		; $28
.byte $08, $10, $08		; $29
.byte $38, $70, $a8		; $2A
.byte $08, $50, $00		; $2B
.byte $70, $a0, $e0		; $2C
.byte $58, $90, $d0		; $2D
.byte $60, $58, $48		; $2E
.byte $c8, $b8, $a8		; $2F
.byte $90, $80, $78		; $30
.byte $18, $60, $08		; $31
.byte $68, $20, $00		; $32
.byte $90, $40, $00		; $33

; For sprite. Redundant with other 4. Ultimately want to use these, not the first group
.byte $00, $28, $40		; $34	- unused
.byte $00, $38, $58		; $35
.byte $00, $38, $70    ; $36
.byte $08, $10, $08    ; $37

; Blank, unused
.byte $00, $00, $00    ; $38
.byte $00, $00, $00    ; $39
.byte $00, $00, $00    ; $3A
.byte $00, $00, $00    ; $3B

; Tileset, cont'd
.byte $00, $60, $78    ; $3C
.byte $00, $50, $68    ; $3D
.byte $00, $38, $50    ; $3E
.byte $18, $50, $68    ; $3F

; HUD
.byte $00, $58, $58		; $40
.byte $00, $c0, $c8		; $41
.byte $00, $f8, $f8		; $42
.byte $00, $80, $80		; $43
.byte $f8, $f8, $a8		; $44
.byte $f8, $b8, $40		; $45
.byte $c0, $00, $00		; $46

LUT_IMG_END = *
