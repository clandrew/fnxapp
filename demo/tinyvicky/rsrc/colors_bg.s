LUT_IMG_START
.byte $00, $00, $00, $00
.byte $00, $88, $70, $00	; Green in top left. Color $01
.byte $10, $80, $60, $00	; Next green, Color $02
.byte $00, $70, $58, $00	; Next green, Color $03
.byte $00, $60, $50, $00	; Next green, color $04
.byte $e8, $e0, $e0, $00
.byte $f8, $f8, $f8, $00
.byte $d0, $d0, $d0, $00
.byte $20, $a0, $90, $00
.byte $e0, $a0, $58, $00
.byte $f8, $b8, $70, $00	; 0xA
.byte $d0, $90, $40, $00
.byte $f8, $d8, $98, $00
.byte $e8, $e8, $e8, $00
.byte $c0, $c0, $c0, $00
.byte $b8, $b8, $b8, $00
.byte $b0, $a8, $a8, $00	; 0x10
.byte $98, $98, $98, $00
.byte $80, $80, $78, $00
.byte $68, $68, $68, $00
.byte $00, $90, $70, $00
.byte $00, $50, $40, $00
.byte $50, $50, $50, $00
.byte $40, $40, $40, $00
.byte $18, $18, $18, $00
.byte $28, $28, $28, $00

.byte $00, $10, $20, $00	; 0x20
.byte $00, $00, $08, $00
.byte $00, $28, $38, $00
.byte $58, $58, $58, $00
.byte $00, $30, $40, $00
.byte $00, $40, $30, $00

; For sprite
.byte $00, $28, $40, $00	; $26
.byte $00, $38, $58, $00	; $27
.byte $00, $38, $70, $00	; $28
.byte $08, $10, $08, $00	; $29
.byte $38, $70, $a8, $00	; $2A
.byte $08, $50, $00, $00	; $2B
.byte $70, $a0, $e0, $00	; $2C
.byte $58, $90, $d0, $00	; $2D
.byte $60, $58, $48, $00	; $2E
.byte $c8, $b8, $a8, $00	; $2F
.byte $90, $80, $78, $00	; $30
.byte $18, $60, $08, $00	; $31
.byte $68, $20, $00, $00	; $32
.byte $90, $40, $00, $00	; $33

; Other- colors which appeared in tileset but not in the reference image
.byte $08, $10, $20, $00    ; $36
.byte $00, $38, $48, $00    ; $37
.byte $18, $48, $58, $00    ; $38
.byte $00, $30, $20, $00    ; $39

.byte $00, $70, $88, $00    ; $3A
.byte $00, $68, $80, $00    ; $3B
.byte $00, $60, $78, $00    ; $3C
.byte $00, $50, $68, $00    ; $3D
.byte $00, $38, $50, $00    ; $3E
.byte $18, $50, $68, $00    ; $3F

LUT_IMG_END = *
