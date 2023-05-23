.cpu "65816"                        ; Tell 64TASS that we are using a 65816

.include "api.asm"
.include "TinyVicky_Def.asm"
.include "interrupt_def.asm"
.include "C256_Jr_SID_def.asm"
.include "includes/f256jr_registers.asm"

; Constants
VIA_ORB_IRB = $DC00
VIA_ORB_IRA = $DC01

;const SIDSTART=$a000,SIDINIT=$a000,SIDPLAY=$a003,SIDMODE=5,SIDFILE='toccata_v3.a000'
;const SIDSTART=$a000,SIDINIT=$a048,SIDPLAY=$a021,SIDMODE=5,SIDFILE='viola_duet.a000'
;const SIDSTART=$1000,SIDINIT=$1000,SIDPLAY=$1003,SIDMODE=5,SIDFILE='Super_Mario_Bros_2SID'
;const SIDSTART=$1000,SIDINIT=$1000,SIDPLAY=$1003,SIDMODE=5,SIDFILE='mrdo'
;const SIDSTART=$4000,SIDINIT=$4000,SIDPLAY=$4003,SIDMODE=5,SIDFILE='Airwolf_2SID'
;const SIDSTART=$1000,SIDINIT=$1000,SIDPLAY=$1003,SIDMODE=5,SIDFILE='Space_Oddity_2SID'
;const SIDSTART=$0FF6,SIDINIT=$0FF6,SIDPLAY=$1003,SIDMODE=6,SIDFILE='Girl_from_Tomorrow_2SID'
SIDSTART=$1000
SIDINIT=$1000
SIDPLAY=$1003
SIDMODE=5
SIDFILE='Space_Oddity_2SID'

; Code

* = $000000 
        .byte 0

* = $000800 
    .logical $1000

; Proc: SIDINIT
    JMP $1148
    JMP $11CC
    JMP $12A6
    JMP $11C2
    JMP $12A5

.byte $80
.byte $01, $20, $53, $49, $44, $57, $49, $5a, $2d, $32, $53, $49, $44, $20, $31, $2e
.byte $38, $01, $bd, $02, $e0, $03, $41, $ff, $07, $a0, $1b, $10, $02, $41, $ff, $09
.byte $40, $37, $20, $05, $41, $ff, $09, $da, $2b, $20, $05, $41, $ff, $09, $f6, $0a
.byte $80, $06, $40, $ff, $03, $6d, $10, $20, $0a, $40, $fe, $05, $00, $01, $0f, $1f
.byte $19, $23, $00, $00, $01, $0f, $0d, $10, $17, $00, $00, $01, $0f, $1c, $13, $17
.byte $00, $00, $01, $0f, $23, $13, $17, $00, $00, $01, $0f, $1e, $1c, $2f, $00, $00
.byte $01, $0f, $27, $16, $23, $00, $0b, $00, $11, $00, $04, $00, $01, $0c, $00, $35
.byte $00, $07, $00, $04, $35, $63, $45, $00, $0c, $00, $40, $2e, $63, $41, $00, $02
.byte $00, $40, $18, $00, $29, $00, $0a, $00, $b0, $17, $30, $30, $08, $08, $00, $b0
.byte $01, $fe, $02, $ff, $00, $00, $00, $02, $fd, $04, $ff, $00, $00, $00, $04, $fb
.byte $06, $ff, $00, $00, $00, $01, $fe, $08, $ff, $00, $00, $00, $02, $fd, $0a, $ff
.byte $00, $00, $00, $04, $fb, $0c, $ff, $00, $00, $00, $10, $00, $00, $ff, $00, $f7
.byte $00, $10, $00, $00, $ff, $00, $f7, $00, $10, $00, $00, $ff, $0a, $03, $00, $10
.byte $00, $00, $ff, $0c, $06, $00, $10, $00, $00, $ff, $00, $ed, $00, $10, $00, $00
.byte $ff, $00, $ed, $00, $00, $01, $00, $00, $01, $00, $00, $00, $01, $01, $00, $01
; 900
.byte $02, $00, $00, $01, $00, $00, $01, $00, $00, $00, $01, $00, $00, $01, $00, $00
.byte $00, $01, $00, $00, $01, $00, $00, $00, $01, $00, $00, $01, $00, $00, $be, $02
.byte $e0, $03, $41, $00, $f8, $a0, $1b, $10, $02, $41, $00, $7a, $41, $37, $20, $05
.byte $41, $00, $7b, $db, $2b, $20, $05, $41, $00, $aa, $f7, $0a, $80, $06, $40, $00
.byte $7c, $6e, $10, $20, $0a, $40, $0f, $00

                JSR   $18D6
                LDA   #$00
                LDY   #$7D
L114F           STA   $1022,Y
                DEY
                BPL   $114F
                LDY   #$7D
L1157           STA   $10CA,Y
                DEY
                BPL   $1157
                LDY   #$17
L115F           STA   $D400,Y
                STA   $D500,Y
                DEY
                BPL   $115F
                STA   $1257
                STA   $1280
                STA   $126D
                STA   $1296
                STA   $125D
                STA   $1286
                STA   $124E
                STA   $1277
                LDA   #$0F
                STA   $1255
                STA   $127E
                STA   $1330
                STA   $1335
                STA   $1714
                STA   $167D
                LDX   #$23
L1196           LDA   #$00
                STA   $10A5,X
                STA   $10A4,X
L119E           LDY   $104E,X
                JSR   $192A
                BPL   $11B2
                CMP   #$FE
                BCS   $11B5
                JSR   $1A77
                INC   $104E,X
                BNE   $119E
L11B2           STA   $1076,X
L11B5           LDA   #$FF
                STA   $10A3,X
                TXA
                SEC
                SBC   #$07
                TAX
                BPL   L1196
                RTS

                LDX   #$15
                JSR   $1BE8
                LDX   #$00
                JMP   $1BE8


                LDA   $FE
                PHA
                LDA   $FF
                PHA
                LDX   #$0E
                JSR   L12F2
                LDX   #$23
                JSR   L12F2
                LDX   #$07
                JSR   L12F2
                LDX   #$1C
                JSR   L12F2
                LDX   #$00
                JSR   L12F2
                LDX   #$15
                JSR   L12F2
                LDX   #$0E
                SEC
L11F3           LDA   $1124,X
                STA   $D406,X
                LDA   $1123,X
                STA   $D405,X
                LDA   $111E,X
                STA   $D400,X
                LDA   $111F,X
                STA   $D401,X
                LDA   $1120,X
                STA   $D402,X
                LDA   $1121,X
                STA   $D403,X
                LDA   $1122,X
                STA   $D404,X
                LDA   $1139,X
                STA   $D506,X
                LDA   $1138,X
                STA   $D505,X
                LDA   $1133,X
                STA   $D500,X
                LDA   $1134,X
                STA   $D501,X
                LDA   $1135,X
                STA   $D502,X
                LDA   $1136,X
                STA   $D503,X
                LDA   $1137,X
                STA   $D504,X
                TXA
                SBC   #$07
                TAX
                BCS   L11F3
L124D           LDA   #$01
L124F           ORA   #$A0
                STA   $D417
L1254           LDA   #$0F
L1256           ORA   #$10
                STA   $D418
                CLC
L125C           LDA   #$00
                BEQ   L126A

                ; Inaccessible
                LDX   $1714
                ADC   $1078,X
                TAY
                LDA   $19A4,Y
                ; Done inaccsessible

L126A           ADC   #$0C
                ADC   #$00
                STA   $D416
L1271           LDA   #$00
                STA   $D415
L1276           LDA   #$00
L1278           ORA   #$00
                STA   $D517
L127D           LDA   #$0F
L127F           ORA   #$00
                STA   $D518
                CLC
L1285           LDA   #$00
                BEQ   L1293
            
                ; Inaccessible
                LDX   $167D
                ADC   $1078,X
                TAY
                LDA   $19A4,Y
                ; Done inaccessible

L1293           ADC   #$00
                ADC   #$00
                STA   $D516
L129A           LDA   #$00
                STA   $D515
                PLA
                STA   $FF
                PLA
                STA   $FE
                RTS

                LDA   $FE
                PHA
                LDA   $FF
                PHA
                LDX   #$0E
                JSR   L12CD
                LDX   #$23
                JSR   L12CD
                LDX   #$07
                JSR   L12CD
                LDX   #$1C
                JSR   L12CD
                LDX   #$00
                JSR   L12CD
                LDX   #$15
                JSR   L12CD
                JMP   $11F0

L12CD           LDA   $1052,X
                BMI   $12A5
                LDY   $107A,X
                LDA   $2C9A,Y
                STA   $FE
                LDA   $2CAD,Y
                STA   $FF
                LDY   #$07
                LDA   ($FE),Y
                BMI   L12EF
                AND   #$40
                BNE   L12EC
                JMP   $1818

L12EC           JMP   $17A7

L12EF           JMP   $1675

L12F2           LDY   $10F5,X
                LDA   $104D,X
                INY
                SEC
                SBC   $2C6B,Y
                BEQ   L1306
                BVC   L130D
                LDY   $10F4,X
                LDA   #$00
L1306           STA   $104D,X
                TYA
                STA   $10F5,X
L130D           LDA   $104D,X
                INC   $104D,X
                CMP   #$00
                BEQ   L131A
                JMP   L1415

L131A           LDY   $1076,X
                LDA   $2CBF,Y
                STA   $FE
                LDA   $2D27,Y
                STA   $FF
                LDA   #$00
                STA   $1079,X
                STA   $107B,X
                LDA   #$0F
                STA   L1254+1
                LDA   #$0F
                STA   L127D+1
                LDA   $10A4,X
                BEQ   L1346
                JSR   $1D07
                LDA   #$00
                STA   $10A4,X
L1346           LDY   $104F,X
                LDA   $104C,X
                BNE   L135D
                LDA   ($FE),Y
                CMP   #$70
                BCC   L1362
                CMP   #$78
                BCS   L1362
                SBC   #$6D
                STA   $104C,X
L135D           DEC   $104C,X
                LDA   #$00
L1362           CMP   #$00
                BMI   L136B
                STA   $1077,X
                BPL   L138F

L136B           AND   #$7F
                STA   $1077,X
                INY
                LDA   ($FE),Y
                BMI   L137A
                STA   $1079,X
                BPL   L138F

L137A           AND   #$7F
                STA   $1079,X
                INY
                LDA   ($FE),Y
                STA   $107B,X
                AND   #$E0
                BNE   L138F
                INY
                LDA   ($FE),Y
                STA   $107C,X
L138F           TYA
                STA   $104F,X
                LDY   $10F5,X
                LDA   $2C6C,Y
                AND   #$7F
                CMP   #$02
                BPL   L13A2
                JMP   L1426

L13A2           LDA   #$02
L13A4           LDY   $1077,X
                BEQ   L13AD
                CPY   #$60
                BCC   L13B0
L13AD           JMP   L15C1

L13B0           LDY   $107B,X
                CPY   #$03
                BEQ   L13AD
                LDY   $10CA,X
                INY
                BEQ   L13AD
                LDY   $1079,X
                BEQ   L13C8
                CPY   #$3F
                BEQ   L13AD
                BMI   L13CB
L13C8           LDY   $107A,X
L13CB           PHA
                LDA   $2C9A,Y
                STA   $FE
                LDA   $2CAD,Y
                STA   $FF
                PLA
                LDY   #$00
                AND   ($FE),Y
                BEQ   L1405
                LDA   #$FE
                STA   $1027,X
                AND   $1026,X
                STA   $1026,X
                LDY   #$02
                LDA   ($FE),Y
                STA   $1124,X
                DEY
                LDA   ($FE),Y
                STA   $1123,X
                DEY
                LDA   ($FE),Y
                AND   #$04
                BEQ   L1405
                LDA   #$18
                STA   $1026,X
                STA   $1122,X
                RTS

L1405           LDY   $107A,X
                LDA   $2C9A,Y
                STA   $FE
                LDA   $2CAD,Y
                STA   $FF
                JMP   L15D1

L1415           CMP   #$02
                BPL   L148C
                LDY   $1076,X
                LDA   $2CBF,Y
                STA   $FE
                LDA   $2D27,Y
                STA   $FF
L1426           LDY   $104F,X
                LDA   $10A5,X
                STA   $10D0,X
                LDA   $104C,X
                BNE   L1477
                INY
                LDA   ($FE),Y
                CMP   #$FF
                BNE   L1477
                LDY   $104E,X
                INY
L143F           JSR   L192A
                BPL   L146E
                CMP   #$FE
                BNE   L144E
                DEC   $104D,X
                JMP   L15C1

L144E           CMP   #$FF
                BEQ   L145F
                JSR   $1A77
                INY
                JSR   L192A
                CMP   #$FF
                BEQ   L1475
                BNE   L143F

L145F           INY
                JSR   L192A
                BPL   L146A
                JSR   L1904
                LDA   #$00
L146A           TAY
                JMP   L143F

L146E           STA   $1076,X
                TYA
                STA   $104E,X
L1475           LDY   #$00
L1477           TYA
                STA   $104F,X
                LDY   $10F5,X
                LDA   $2C6C,Y
                AND   #$7F
                CMP   #$03
                BMI   L1491
                LDA   #$01
                JMP   L13A4

L148C           BEQ   L1491
                JMP   L15C1

L1491           LDY   #$FF
                LDA   $1079,X
                BEQ   L14A1
                CMP   #$1F
                BPL   L14A1
                STA   $107A,X
                LDY   #$3F
L14A1           STY   L14FE+1
                LDY   $107A,X
                BNE   L14AC
                JMP   L14F4

L14AC           LDA   $2C9A,Y
                STA   $FE
                LDA   $2CAD,Y
                STA   $FF
                LDA   $1077,X
                BNE   L14C1
                JSR   $1B2B
                JMP   L15D1

L14C1           CMP   #$60
                BMI   L14CB
                JSR   $1AA5
                JMP   L15D1

L14CB           CLC
                LDY   #$09
                ADC   ($FE),Y
                CLC
                ADC   $10D0,X
                STA   $1078,X
                LDA   #$03
                CMP   $107B,X
                BEQ   L14F4
                ADC   $10CA,X
                BCS   L14EF
                LDA   #$3F
                CMP   $1079,X
                BNE   L14FA
                LDA   #$7F
                STA   $10CC,X
L14EF           LDA   #$83
                STA   $10CA,X
L14F4           JSR   $1B2B
                JMP   L18CF

L14FA           LDY   #$00
                LDA   ($FE),Y
L14FE           AND   #$FF
                STA   L1508+1
                AND   #$30
                STA   $10CA,X
L1508           LDA   #$1A
                AND   #$08
                BEQ   L151E
                LDY   $1078,X
                LDA   $19AF,Y
                STA   $111F,X
                LDY   #$0F
                LDA   ($FE),Y
                STA   $1026,X
L151E           LDA   #$10
                STA   $1050,X
                LDA   #$FF
                STA   $1027,X
                STA   $1052,X
                LDY   #$07
                LDA   ($FE),Y
                STA   $10F6,X
                JSR   L1954
                LDY   #$08
                LDA   ($FE),Y
                STA   $10F8,X
                TAY
                LDA   $2C8B,Y
                STA   $10F9,X
                BIT   L1508+1
                BVS   L154F
                LDY   #$0A
                LDA   ($FE),Y
                STA   $1051,X
L154F           BIT   L1508+1
                BMI   L15AE
                LDY   #$0B
                LDA   ($FE),Y
                TAY
                CPX   #$15
                BCC   L1587
                LDA   ($FE),Y
                BEQ   L156B
                CMP   #$FF
                BEQ   L1573
                STX   L167C+1
                STY   L1680+1
L156B           LDA   $10A0,X
                ORA   L1276+1
                BNE   L1581
L1573           CPX   L167C+1
                BNE   L157B
                STY   L1680+1
L157B           LDA   $10A1,X
                AND   L1276+1
L1581           STA   L1276+1
                JMP   L15AE

L1587           LDA   ($FE),Y
                BEQ   L1595
                CMP   #$FF
                BEQ   L159D
                STX   L1713+1
                STY   L1717+1
L1595           LDA   $10A0,X
                ORA   L124D+1
                BNE   L15AB
L159D           CPX   L1713+1
                BNE   L15A5
                STY   L1717+1
L15A5           LDA   $10A1,X
                AND   L124D+1
L15AB           STA   L124D+1
L15AE           LDY   #$04
                LDA   ($FE),Y
                STA   $1124,X
                DEY
                LDA   ($FE),Y
                STA   $1123,X
                JSR   $1B2B
                JMP   L18CF

L15C1           LDY   $107A,X
                BNE   L15C7
                RTS

L15C7           LDA   $2C9A,Y
                STA   $FE
                LDA   $2CAD,Y
                STA   $FF
L15D1           LDY   $10CA,X
                BEQ   L1625
                BPL   L161A
                CPY   #$82
                BEQ   L1648
                BPL   L15E1
                JMP   L1663

L15E1           CPY   #$FF
                BEQ   L160B
                LDY   $1078,X
                LDA   $1A17,Y
                SBC   $1022,X
                STA   L15F8+1
                LDA   $19AF,Y
                SBC   $1023,X
                TAY
L15F8           LDA   #$C7
                BCS   L165A
                ADC   $10CB,X
                TYA
                ADC   $10CC,X
                BCC   L1648
L1605           JSR   $1BD9
                JSR   L195B
L160B           LDY   $1078,X
                LDA   $1A17,Y
                STA   $1022,X
                LDA   $19AF,Y
                JMP   L1672

L161A           LDY   $10CD,X
                BMI   L1634
                DEC   $10CD,X
                JMP   L1675

L1625           LDA   $10CB,X
                CLC
                ADC   $10CD,X
                STA   $10CB,X
                BCC   L1634
                INC   $10CC,X
L1634           LDA   $10CF,X
                BNE   L163C
                LDA   $10CE,X
L163C           SEC
                SBC   #$01
                STA   $10CF,X
                ASL   A
                CMP   $10CE,X
                BCC   L1663
L1648           LDA   $1022,X
                SBC   $10CB,X
                STA   $1022,X
                LDA   $1023,X
                SBC   $10CC,X
                JMP   L1672

L165A           SBC   $10CB,X
                TYA
                SBC   $10CC,X
                BCC   L1605
L1663           LDA   $1022,X
                ADC   $10CB,X
                STA   $1022,X
                LDA   $1023,X
                ADC   $10CC,X
L1672           STA   $1023,X
L1675           CPX   #$15
                BCS   L167C
                JMP   L1713

L167C           CPX   #$0F
                BNE   L16C3
L1680           LDY   #$00
                LDA   ($FE),Y
                BMI   L16C6
                INY
L1687           CMP   #$00
                BEQ   L16F4
                INC   L1687+1
                CLC
                LDA   ($FE),Y
                BPL   L16AA
                ORA   #$F8
                ADC   L129A+1
                PHP
                AND   #$07
                STA   L129A+1
                LDA   ($FE),Y
                EOR   #$FF
                LSR   A
                LSR   A
                LSR   A
                EOR   #$FF
                JMP   L16BC

L16AA           AND   #$07
                ADC   L129A+1
                CMP   #$08
                PHP
                AND   #$07
                STA   L129A+1
                LDA   ($FE),Y
                LSR   A
                LSR   A
                LSR   A
L16BC           PLP
                ADC   L1293+1
                STA   L1293+1
L16C3           JMP   L1710

L16C6           CMP   #$FE
                BEQ   L16CE
                BCC   L16DB
                BCS   L1710

L16CE           INY
                LDA   ($FE),Y
                CMP   L1680+1
                BEQ   L1710
                TAY
                LDA   ($FE),Y
                BPL   L1708
L16DB           PHA
                AND   #$70
                STA   L127F+1
                PLA
                ASL   A
                ASL   A
                ASL   A
                ASL   A
                STA   L1278+1
                INY
                LDA   ($FE),Y
                STA   L1293+1
                LDA   #$00
                STA   L129A+1
L16F4           INY
                LDA   ($FE),Y
                BPL   L1704
                CMP   #$90
                BCS   L1704
                AND   #$0F
                STA   L1276+1
                LDA   #$00
L1704           STA   L1285+1
                INY
L1708           STY   L1680+1
                LDA   #$00
                STA   L1687+1
L1710           JMP   L17A7

L1713           CPX   #$00
                BNE   L175A
L1717           LDY   #$36
                LDA   ($FE),Y
                BMI   L175D
                INY
L171E           CMP   #$07
                BEQ   L178B
                INC   L171E+1
                CLC
                LDA   ($FE),Y
                BPL   L1741
                ORA   #$F8
                ADC   L1271+1
                PHP
                AND   #$07
                STA   L1271+1
                LDA   ($FE),Y
                EOR   #$FF
                LSR   A
                LSR   A
                LSR   A
                EOR   #$FF
                JMP   L1753

L1741           AND   #$07
                ADC   L1271+1
                CMP   #$08
                PHP
                AND   #$07
                STA   L1271+1
                LDA   ($FE),Y
                LSR   A
                LSR   A
                LSR   A
L1753           PLP
                ADC   L126A+1
                STA   L126A+1
L175A           JMP   L17A7

L175D           CMP   #$FE
                BEQ   L1765
                BCC   L1772
                BCS   L17A7

L1765           INY
                LDA   ($FE),Y
                CMP   L1717+1
                BEQ   L17A7
                TAY
                LDA   ($FE),Y
                BPL   L179F
L1772           PHA
                AND   #$70
                STA   L1256+1
                PLA
                ASL   A
                ASL   A
                ASL   A
                ASL   A
                STA   L124F+1
                INY
                LDA   ($FE),Y
                STA   L126A+1
                LDA   #$00
                STA   L1271+1
L178B           INY
                LDA   ($FE),Y
                BPL   L179B
                CMP   #$90
                BCS   L179B
                AND   #$0F
                STA   L124D+1
                LDA   #$00
L179B           STA   L125C+1
                INY
L179F           STY   L1717+1
                LDA   #$00
                STA   L171E+1
L17A7           LDY   $1051,X
                LDA   ($FE),Y
                BMI   L17CC
                INY
                CMP   $1028,X
                BEQ   L17EC
                INC   $1028,X
                LDA   ($FE),Y
                BPL   L17BE
                DEC   $1025,X
L17BE           CLC
                ADC   $1024,X
                STA   $1024,X
                BCC   L17FC
                INC   $1025,X
                BCS   L17FC

L17CC           CMP   #$FE
                BEQ   L17D4
                BCC   L17E1
                BCS   L17FC

L17D4           INY
                LDA   ($FE),Y
                CMP   $1051,X
                BEQ   L17FC
                TAY
                LDA   ($FE),Y
                BPL   L17F3
L17E1           AND   #$7F
                STA   $1025,X
                INY
                LDA   ($FE),Y
                STA   $1024,X
L17EC           INY
                LDA   ($FE),Y
                STA   $10F7,X
                INY
L17F3           TYA
                STA   $1051,X
                LDA   #$00
                STA   $1028,X
L17FC           CLC
                LDA   $10F7,X
                BEQ   L180C
                ADC   $1078,X
                TAY
                LDA   $19A4,Y
                SBC   L19A3,Y
L180C           ADC   $1025,X
                STA   $1121,X
                LDA   $1024,X
                STA   $1120,X
                DEC   $1052,X
                BPL   L1830
                LDA   $10F6,X
                AND   #$3F
                STA   $1052,X
L1825           LDY   $1050,X
                LDA   ($FE),Y
                CMP   #$FE
                BEQ   L183C
                BCC   L1833
L1830           JMP   L18BE

L1833           CMP   #$10
                BCS   L1847
                STA   $1052,X
                BCC   L184D

L183C           INY
                LDA   ($FE),Y
                BMI   L18BE
                STA   $1050,X
                TAY
                LDA   ($FE),Y
L1847           AND   $1027,X
                STA   $1026,X
L184D           INY
                LDA   ($FE),Y
                INY
                CMP   #$7F
                BEQ   L1874
                STA   L1866+1
                LDA   ($FE),Y
                CMP   #$FF
                BEQ   L1861
                STA   $10A6,X
L1861           INY
                TYA
                STA   $1050,X
L1866           LDA   #$00
                BPL   L18AB

                .byte  $C9
                .byte  $80
                .byte  $F0
                .byte  $50
                .byte  $C9
                .byte  $E0
                .byte  $90
                .byte  $3D
                .byte  $B0
                .byte  $37

L1874           LDA   ($FE),Y
                STA   $10A6,X
                LDY   $10F9,X
                LDA   $2C38,Y
                CMP   #$7E
                BNE   L1897
                LDY   $10F8,X
                LDA   $2C8B,Y
                STA   $10F9,X
                LDA   $1050,X
                ADC   #$02
                STA   $1050,X
                JMP   L1825

L1897           CMP   #$7F
                BNE   L18A8
                LDY   $10F8,X
                LDA   $2C8B,Y
                STA   $10F9,X
                TAY
                LDA   $2C38,Y
L18A8           INC   $10F9,X
L18AB           CLC
                ADC   $1078,X
                AND   #$7F
                TAY
                LDA   $1A17,Y
                STA   $1022,X
                LDA   $19AF,Y
                STA   $1023,X
L18BE           LDA   $1022,X
                ADC   $10A6,X
                STA   $111E,X
                LDA   $1023,X
                ADC   #$00
                STA   $111F,X
L18CF           LDA   $1026,X
                STA   $1122,X
                RTS

                .byte  $A2
                .byte  $00
                .byte  $20
                .byte  $04
                .byte  $19
                .byte  $A2
                .byte  $07
                .byte  $20
                .byte  $0E
                .byte  $19
                .byte  $A2
                .byte  $0E
                .byte  $20
                .byte  $0E
                .byte  $19
                .byte  $A2
                .byte  $15
                .byte  $20
                .byte  $0E
                .byte  $19
                .byte  $A2
                .byte  $1C
                .byte  $20
                .byte  $0E
                .byte  $19
                .byte  $A2
                .byte  $23
                .byte  $20
                .byte  $0E
                .byte  $19
                
                .byte $C8
                .byte $C8
                .byte $C8
                .byte $B9

                .byte  $7A
                .byte  $2C
                .byte  $8D
                .byte  $6C
                .byte  $2C
                .byte  $B9
                .byte  $7B
                .byte  $2C
                .byte  $8D
                .byte  $6D
                .byte  $2C
                .byte  $60

L1904           STX   L1927+1
                ASL   A
                ASL   A
                ASL   A
                ASL   A
                STA   L1917+1
                LDA   $10A2,X
                ASL   A
                SBC   #$02
                TAX
                LSR   A
                CLC
L1917           ADC   #$00
                TAY
                LDA   $2C7A,Y
                STA   L193C,X
                INY
                LDA   $2C7A,Y
                STA   L193C+1,X
L1927           LDX   #$00 ; The 2nd byte of this gets replaced. This pattern is used other places too.
                RTS

L192A           CPX   #$15
                BCC   L1936
                CPX   #$1C
                BEQ   L194C
                BPL   L1950
                BMI   L1948

L1936           CPX   #$07
                BEQ   L1940
                BPL   L1944
L193C           LDA   $1D7F,Y
                RTS

L1940           LDA   $1DAF,Y
                RTS

L1944           LDA   $1DDF,Y
                RTS

L1948           LDA   $1E0F,Y
                RTS

L194C           LDA   $1E3F,Y
                RTS

L1950           LDA   $1E6F,Y
                RTS

L1954           LDY   #$06
                LDA   ($FE),Y
                STA   $10CD,X
L195B           LDY   #$05
                LDA   ($FE),Y
                PHA
                AND   #$0F
                ASL   A
                STA   $10CE,X
                LSR   A
                LDY   $10CA,X
                CPY   #$20
                BPL   L196F
                LSR   A
L196F           CPY   #$30
                BNE   L1975
                LDA   #$00
L1975           STA   $10CF,X
                PLA
                AND   #$F0
                LSR   A
                BEQ   L198E
                LSR   A
                ADC   $1078,X
                TAY
                CPY   #$CB
                BCS   L1995
                CPY   #$6B
                BCS   L1997
                LDA   $19A4,Y
L198E           STA   $10CB,X
                LDA   #$00
                BEQ   L19A0

L1995           LDY   #$CB
L1997           LDA   $19AC,Y
                STA   $10CB,X
                LDA   L1944,Y
L19A0           STA   $10CC,X
L19A3           RTS

.endlogical

; Data below
* = $0011a4
.logical $19A4
.binary 'assets/data.bin'
.endlogical

UNKNOWN_CODE2
.logical $1A77
                CMP   #$A0
                BCS   L1A81
                SBC   #$8F
                STA   $10A5,X
                RTS

L1A81           CMP   #$B0
                BCS   L1A93
                AND   #$0F
                CPX   #$15
                BCC   L1A8F
                STA   $1335
                RTS

L1A8F           STA   $1330
                RTS

L1A93           CMP   #$F0
                BCS   L1A9C
                SBC   #$AF
                STA   $10A4,X
L1A9C           RTS

.byte $00
.byte $0a, $0e
.byte $13, $17, $1f, $2b, $00

    CMP #$78
.byte $10, $09 ; BPL
    STA $1B63
    JSR $1BD1
    JMP $1B2B

    TAY
    LDA $1A25,Y
    STA $1ABE
    LDA $1026,X
    CLC

.byte $90, $2b ; BCC

    LDY #$FF
    LDA #$6E
    JSR $1C6F
    JMP $1B2B

.byte $09, $02, $d0, $0b, $29, $fd

    JMP $1AD8
.byte  $09, $04, $d0, $02, $29, $fb, $9d, $26, $10

    JMP $1B2B
    LDA #$FF
.byte $9d, $27, $10, $bd, $26, $10, $09, $01, $d0, $ee, $a0, $0c, $b1, $fe, $d0, $0e
.byte $a9, $fe, $9d, $27, $10, $3d, $26, $10, $9d, $26, $10, $4c, $01, $1b, $9d, $50
.byte $10, $a0, $0d, $b1, $fe, $f0, $03, $9d, $51, $10, $e0, $15, $90, $10, $ec, $7d
.byte $16, $d0, $18, $c8, $b1, $fe, $f0, $13

    STA $1681
    JMP $1B2B
    CPX $1714
    BNE L1B2B
    INY
    LDA ($FE),Y
    BEQ L1B2B
    STA $1718

L1B2B
    LDA $1079,X
    CMP #$40
    BMI L1B35

    JSR $1B80

L1B35
    LDA $107B,X
    BEQ EarlyOut_1b52

    CMP #$20
    .byte $b0, $42; BCS
    ASL
    TAY
    LDA $1C29,Y
    STA $1B50
    LDA $1C2A,Y
    STA $1B51
    LDA $107C,X
    JMP $1C78
EarlyOut_1b52 
    RTS

    LDA ($FE),Y
    AND #$F0
    ORA $1B63
    RTS

    LDA ($FE),Y
    AND #$0F
    STA $1B69
    LDA #$63
    ASL
    ASL
    ASL
    ASL
    ORA #$06
    RTS

    STA $1B70
    ASL
    ADC #$00
    RTS

.binary 'assets/data2.bin'
.endlogical

* = $00D800
.logical $E000
ChrOut
    PHA
    PHY
    TAY
    LDA $01
    PHA
    LDA #$02
    STA $01
    TYA
    LDY $49
    STA ($4B),Y
    INC $01
    LDA $48
    STA ($4B),Y
    INY
    CPY #$28
    BNE TEST1

    CLC
    LDA $4B
    ADC #$28
    STA $4B
    BCC TEST2
    INC $4C

TEST2
    LDA $4A
    INA
    CMP #$1E
    BNE TEST3

    LDA #$C0
    STA $4C

    LDA #$00
    STA $4B

TEST3
    STA $4A
    LDY #$00

TEST1
.byte $84, $49, $68, $85, $01, $7a, $68, $60
.byte $48, $da, $a5, $01, $48, $9c, $73, $e0, $64, $4b, $a9, $c0, $8d, $74, $e0, $85
.byte $4c, $a9, $02, $85, $01, $a2, $20, $20, $71, $e0, $9c, $73, $e0, $a9, $c0, $8d
.byte $74, $e0, $a9, $03, $85, $01, $a6, $48, $20, $71, $e0, $68, $85, $01, $fa, $68
.byte $60, $8a, $8d, $34, $12, $ee, $73, $e0, $d0, $03, $ee, $74, $e0, $ad, $73, $e0
.byte $c9, $c0, $d0, $ed, $ad, $74, $e0, $c9, $d2, $d0, $e6
    RTS

; Procedure: PrintAnsiString
; parameters:
;	<TempSrc>	=	word address of string to print
;	<CursorPointer>	=	word address of screen character/color memory
PrintAnsiString
    LDY #$00
    BRA Print20

Print10
    CMP #$1B
    BCC CheckControlCodes
    JSR ChrOut

NextByte
    INY
    BNE Print20
    INC $31 ; TempSrc+1
    
Print20
    LDA ($30),y ; (TempSrc),y
    BNE Print10
    RTS

CheckControlCodes
    CMP #$02            ; ctrl-f/set cursor foreground color
    BNE CheckControlCodes_Cond0
    LDA $48 ; CursorColor
    AND #$F0
    STA $48 ; CursorColor
    JSR GetNextByte
    ORA $48 ; CursorColor
    STA $48 ; CursorColor
    BRA NextByte

CheckControlCodes_Cond0
    CMP #$03
    BNE CheckControlCodes_Cond1 
    JSR $E0E1 ; GetNextByte
    STA $48 ; CursorColor
    BRA NextByte
    
CheckControlCodes_Cond1
    CMP #$06    ; ctrl-f/set cursor foreground color
    BNE CheckControlCodes_Cond2
    LDA $48 ; CursorColor
    AND #$0F
    STA $48 ; CursorColor
    JSR GetNextByte
    ASL
    ASL
    ASL
    ASL
    ORA $48 ; CursorColor
    STA $48 ; CursorColor
    BRA NextByte

CheckControlCodes_Cond2
    CMP #$0C

    BNE CheckControlCodes_Cond3 
    JSR $E040
    BRA NextByte
CheckControlCodes_Cond3
    RTS

temp
.byte $00

GetNextByte
    INY
    BNE CheckControlCodes_Cond4
    INC $31 ; $e6, $31

CheckControlCodes_Cond4
    LDA ($30), y ; (TempSrc),y
    RTS    
.endlogical

* = $00DA00
.logical $E200
Init_Keyboard
    STZ $01
    LDA #$30
    STA $D640
    STZ $D640
    STZ $E0EB
    STZ $E0E9
    LDX #$00

Keyboard_SetScancodeBuffer
    STA $E0EF
    INX
    CPX #$80
    BNE Keyboard_SetScancodeBuffer

    LDA #$80
    LDX #$00
    
    Keyboard_Loop
    STA $E170,X 
    INX
    CPX #$90
    BNE Keyboard_Loop

    LDA #$00
    STA $E16F
    RTS

KeyboardIRQ 
    LDA KBD_MS_RD_STATUS
    AND #KBD_FIFO_Empty
    BNE KeyboardIRQ_Done
    LDA $E0E9 ; ScancodeBufferWPos
    TAX
    INA
    AND #$7F
    CMP $E0EB ; ScancodeBufferRPos

    BEQ KeyboardIRQ_Load

    STA $E0E9 ; ScancodeBufferWPos
    LDA KBD_RD_SCAN_REG
    STA $E0EF,x ; ScancodeBuffer,x

    BRA KeyboardIRQ

    KeyboardIRQ_Load
    LDA KBD_RD_SCAN_REG

    KeyboardIRQ_Done
    RTS

GetScancode
    LDA $E0EB ; ScancodeBufferRPos
    CMP $E0E9 ; ScancodeBufferWPos
.byte $f0, $0e
    PHX
    TAX
    INA
    AND #$7F
    STA $E0EB
    LDA $E0EF,x ; ScancodeBuffer,x 
    PLX
    CLC
    RTS
BufferEmpty
    LDA #$00
    SEC
    RTS

GetChar
    JSR GetScancode
    BCC GetChar_BufferNotEmpty
    RTS
GetChar_BufferNotEmpty
    CMP #$90 ; scan code can only be 00-8f
    BCC InvalidScanCode ; BCC 0B
    STA $E0ED ; LastScancode
    CMP #$F0  ; is last scan code a break prefix, get next scan code

.byte $f0, $ef

    LDA #$00
    SEC
    RTS

InvalidScanCode
    PHX
    LDX $E0ED ; LastScancode ; get last scan code
    STA $E0ED ; LastScancode ; save new scan code
    CPX #$F0
    .byte $D0, $03 ; BNE KeyPressed ; 03
    
    JMP KeyReleased

KeyPressed
    TAX
    LDA #$00
    STA $E170,x ; KeyboardKeyStates,x 
    LDA $E16F ; KeyboardState
    BIT #$21 ; #(KEYBOARDSTATES.SHIFT|KEYBOARDSTATES.CAPSLK)

.byte $f0, $05 ; BEQ

    LDA SCSET21,x

.byte $80, $03 ; BRA

    LDA SCSET2,x
    TAX
    AND #$C0
    CMP #$C0

.byte $f0, $03 ; BEQ

    TXA
    PLX
    RTS

SpecialKeyDown

    CPX #$C0

.byte $f0, $04 ; BEQ

    CPX #$C1

.byte $d0, $0a, $ad, $6f, $e1, $09, $01, $8d, $6f, $e1, $80, $52, $e0, $c2, $f0, $04
.byte $e0, $c3, $d0, $0a, $ad, $6f, $e1, $09, $02, $8d, $6f, $e1, $80, $40, $e0, $c4
.byte $f0, $04, $e0, $c5, $d0, $0a, $ad, $6f, $e1, $09, $04, $8d, $6f, $e1, $80, $2e
.byte $e0, $c6, $f0, $04, $e0, $c7, $d0, $0a, $ad, $6f, $e1, $09, $08, $8d, $6f, $e1

.byte $80, $1c ; BRA
    CPX #$CF

.byte $d0, $0a ; BNE

    LDA $E16F ; KeyboardState
    EOR #$10 ; #KEYBOARDSTATES.NUMLK
    STA $E16F ; KeyboardState
.byte $80, $0e ; BRA
.endlogical

; db00
* = $00DB00
.logical $E300
    CPX #$CE
.byte $d0, $0a ; BNE
    LDA $E16F ; KeyboardState
    EOR #$20 ; #KEYBOARDSTATES.CAPSLK
    STA $E16F ; KeyboardState
.byte $80, $00 ; BRA
    LDA #$00
    SEC
    PLX
    RTS

KeyReleased
.byte $aa, $a9, $80, $9d, $70, $e1, $bd, $75, $e3, $aa, $29, $c0, $c9
.byte $c0, $f0, $05, $a9, $00, $38, $fa, $60, $e0, $c0, $f0, $04, $e0, $c1, $d0, $0a
.byte $ad, $6f, $e1, $29, $fe, $8d, $6f, $e1, $80, $36, $e0, $c2, $f0, $04, $e0, $c3
.byte $d0, $0a, $ad, $6f, $e1, $29, $fd, $8d, $6f, $e1, $80, $24, $e0, $c4, $f0, $04
.byte $e0, $c5, $d0, $0a, $ad, $6f, $e1, $29, $fb, $8d, $6f, $e1, $80, $12, $e0, $c6
.byte $f0, $04, $e0, $c7, $d0, $0a, $ad, $6f, $e1, $29, $f7, $8d, $6f, $e1

    BRA Keyboard_Done

Keyboard_Done
    LDA #$00
    SEC
    PLX
    RTS

SCSET2
; function keys f1-f24 = ascii $8a-$a1
;
;	   0    1    2    3    4    5    6    7    8    9    A    B    C    D    E    F
.byte $00, $92, $00, $8e, $8c, $8a, $8b, $95, $00, $93, $91, $8f, $8d, $09, $60, $00
.byte $00, $c2, $c0, $00, $c4, $71, $31, $00, $00, $00, $7a, $73, $61, $77, $32, $c6
.byte $00, $63, $78, $64, $65, $34, $33, $c7, $00, $00, $76, $66, $74, $72, $35, $00
.byte $00, $6e, $62, $68, $67, $79, $36, $00, $00, $00, $6d, $6a, $75, $37, $38, $00
.byte $00, $2c, $6b, $69, $6f, $30, $39, $00, $00, $2e, $2f, $6c, $3b, $70, $2d, $00
.byte $00, $00, $2c, $00, $5b, $3d, $00, $00, $ce, $c1, $0d, $5d, $00, $5c, $00, $00
.byte $00, $00, $00, $00, $00, $00, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $1b, $cf, $94, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $90, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

SCSET21
; shift
;	    0    1    2    3    4    5    6    7    8    9    A    B    C    D    E    F
.byte $00, $9e, $00, $9a, $98, $96, $97, $a1, $00, $9f, $9d, $9b, $99, $09, $7e, $00
.byte $00, $c2, $c0, $00, $c4, $51, $21, $00, $00, $00, $5a, $53, $41, $57, $40, $c6
.byte $00, $43, $58, $44, $45, $24, $23, $c7, $00, $00, $56, $46, $54, $52, $25, $00
.byte $00, $4e, $42, $48, $47, $59, $5e, $00, $00, $00, $4d, $4a, $55, $26, $2a, $00
.byte $00, $3c, $4b, $49, $4f, $29, $28, $00, $00, $2e, $3f, $4c, $3a, $50, $5f, $00
.byte $00, $00, $2c, $00, $7b, $2b, $00, $00, $ce, $c1, $0d, $7d, $00, $7c, $00, $00 
.byte $00, $00, $00, $00, $00, $00, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $1b, $cf, $a0, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $9c, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

Init_Graphics
    LDA $01
    PHA
    STZ $01
    LDX #$00
    LDA #$00

GraphicsLoop1
    STA $D800,x
    STA $D840,x
    INX
    CPX #$40
    BNE GraphicsLoop1

    LDX #$00

GraphicsLoop2
    LDA COLODORE_PALETTE,X
    STA $D800,x ; TEXT_LUT_FG
    STA $D840,x ; TEXT_LUT_BG
    INX
    CPX #$40 ; #sizeof(COLODORE_PALETTE)
    BNE GraphicsLoop2

    ; initialize border
    ; set i/o at $d000, use page 0=i/o registers ;<<<="SetMMUIO				; set i/o at $d000, use page 0=i/o registers"
    ;lda #Border_Ctrl_Enable	; enable border
    STZ MMU_IO_CTRL
    STZ BORDER_CTRL_REG
    STZ BORDER_COLOR_B ; set border color to blue, #0000ff
    STZ BORDER_COLOR_G
    STZ BORDER_COLOR_R

    ; set border to 8 pixels high and 8 pixels wide
    STZ BORDER_Y_SIZE
    STZ BORDER_X_SIZE

    STZ BACKGROUND_COLOR_B ; set background color to black, #000000
    STZ BACKGROUND_COLOR_G
    STZ BACKGROUND_COLOR_R
                      ; initialize Tiny Vicky registers
    LDX #$00

GraphicsLoop3
    STZ $D100,x ; TyVKY_BM0_CTRL_REG,x
    STZ $D200,x ; TL0_CONTROL_REG,x
    STZ $D900,x ; SP0_Ctrl,x
    STZ $DA00,x ; SP0_Ctrl+$0100,x
    INX
    BNE GraphicsLoop3

    ; initialize cursor
    STZ VKY_TXT_CURSOR_CTRL_REG ; disable cursor
    STZ VKY_TXT_CURSOR_CHAR_REG ; set cursor character as font tile 0

    STZ VKY_TXT_CURSOR_X_REG_L ; set cursor to colum 0
    STZ VKY_TXT_CURSOR_X_REG_H
    STZ VKY_TXT_CURSOR_Y_REG_L ; set cursor to row 0
    STZ VKY_TXT_CURSOR_Y_REG_H

    LDA #$E0 ; #(C64COLOR.LTBLUE<<4) | C64COLOR.BLACK  [224/$E0/"�"] ;<<<="lda #DoC64COLOR(LTBLUE,BLACK)"
    STA $48 ; CursorColor
    JSR $E040 ; ClearScreen

    LDA #$00 ; #<(loword(val(copy('#VKY_TEXT_MEMORY',2))))
    STA $4B ; CursorPointer
    LDA #$C0 ; #>(loword(val(copy('#VKY_TEXT_MEMORY',2))))
    STA ($4B) ; (CursorPointer)

    PLA
    STA $01
    RTS

COLODORE_PALETTE
.byte $00, $00, $00, $00, $ff, $ff, $ff, $00, $38, $33, $81, $00, $c8, $ce, $75, $00
.byte $97, $3c, $8e, $00, $4d, $ac, $56, $00, $9b, $2c, $2e, $00, $71, $f1, $ed, $00
.byte $29, $50, $8e, $00, $00, $38, $55, $00, $71, $6c, $c4, $00, $4a, $4a, $4a, $00
.byte $7b, $7b, $7b, $00, $9f, $ff, $a9, $00, $eb, $6d, $70, $00, $b2, $b2, $b2, $00

Init_CODEC
    LDA #$00
    STA CODEC_LOW
    LDA #$1A
    STA CODEC_HI    
    LDA #$01
    STA CODEC_CTRL
    JSR WriteCodecWait ; 1A00
    
    LDA #$03
    STA CODEC_LOW    
    LDA #$2A
    STA CODEC_HI    
    LDA #$01
    STA CODEC_CTRL    
    JSR WriteCodecWait ; 2A03
    
    LDA #$01
    STA CODEC_LOW    
    LDA #$23
    STA CODEC_HI    
    LDA #$01
    STA CODEC_CTRL    
    JSR WriteCodecWait ; 2301
    
    LDA #$07
    STA CODEC_LOW    
    LDA #$2C
    STA CODEC_HI    
    LDA #$01
    STA CODEC_CTRL    
    JSR WriteCodecWait ; 2C07
    
    LDA #$02
    STA CODEC_LOW    
    LDA #$14
    STA CODEC_HI    
    LDA #$01
    STA CODEC_CTRL    
    JSR WriteCodecWait ; 1402
    
    LDA #$02
    STA CODEC_LOW    
    LDA #$16
    STA CODEC_HI    
    LDA #$01
    STA CODEC_CTRL    
    JSR WriteCodecWait ; 1602
    
    LDA #$45
    STA CODEC_LOW    
    LDA #$18
    STA CODEC_HI    
    LDA #$01
    STA CODEC_CTRL    
    JSR WriteCodecWait  ; 1845

    RTS

    WriteCodecWait
    LDA CODEC_CTRL
    AND #$01
    CMP #$01
    BEQ WriteCodecWait
    RTS
.endlogical

; Entrypoint
* = $00DDD5 
.logical $E5D5
F256_RESET
    CLC     ; disable interrupts
    SEI
    LDX #$FF
    TXS     ; initialize stack

    ; initialize mmu
    STZ MMU_MEM_CTRL
    LDA MMU_MEM_CTRL
    ORA #MMU_EDIT_EN

    ; enable mmu edit, edit mmu lut 0, activate mmu lut 0 ;<<<="UnlockMMU	; enable mmu edit, edit mmu lut 0, activate mmu lut 0"
    STA MMU_MEM_CTRL
    STZ MMU_IO_CTRL

    LDA #$00
    STA MMU_MEM_BANK_0 ; map $000000 to bank 0
    INA
    STA MMU_MEM_BANK_1 ; map $002000 to bank 1
    INA
    STA MMU_MEM_BANK_2 ; map $004000 to bank 2
    INA
    STA MMU_MEM_BANK_3 ; map $006000 to bank 3
    INA
    STA MMU_MEM_BANK_4 ; map $008000 to bank 4
    INA
    STA MMU_MEM_BANK_5 ; map $00a000 to bank 5
    INA
    STA MMU_MEM_BANK_6 ; map $00c000 to bank 6
    INA
    STA MMU_MEM_BANK_7 ; map $00e000 to bank 7
    LDA MMU_MEM_CTRL
    AND #~(MMU_EDIT_EN)
    STA MMU_MEM_CTRL  ; disable mmu edit, use mmu lut 0 ;<<<="LockMMU	; disable mmu edit, use mmu lut 0"

                        ; initialize via registers
                        ; reset via registers a/b
    STZ $01
    STZ VIA_ORB_IRB     ; set via i/o port a to read
    STZ VIA_ORB_IRA     ; set via i/o port b to read

    ; enable random number generator
    LDA #RNG_ENABLE
    STA RNG_CTRL

                        ; initialize interrupts
    LDA #$FF            ; mask off all interrupts
    STA INT_EDGE_REG0
    STA INT_EDGE_REG1
    STA INT_MASK_REG0
    STA INT_MASK_REG1

    LDA INT_PENDING_REG0 ; clear all existing interrupts
    STA INT_PENDING_REG0
    LDA INT_PENDING_REG1
    STA INT_PENDING_REG1

    JSR Init_CODEC      ; Init_Sound
    JSR Init_Graphics   ; Init_Graphics
    JSR Init_Keyboard   ; Init_Keyboard
    CLI
    JMP MAIN

.byte $00

    ; SOFIRQ ;	proc Increase_SOFCounter
                    ;	Increase_SOF_Counter()
                    ;	SID_Play_Frame()
    LDA #$05 ; SIDMODE
    CMP #$06
    BEQ DoneUpdateSpeed

    DEC $E637 ; SIDSpeed
    BNE DoneUpdateSpeed

    STA $E637 ; SIDSpeed
    RTS

DoneUpdateSpeed
    JSR $1003 ; SIDPLAY
    RTS

; IRQ_Handler
    PHP
    PHA
    PHX
    PHY                ;<<<="PushAXY"
    CLD
    LDA MMU_MEM_CTRL
    PHA
    LDA MMU_IO_CTRL
    PHA
                       ;<<<="PushMMUIO"
    STZ MMU_IO_CTRL    ; use i/o registers ;<<<="SetMMUIO	; use i/o registers"
    LDA INT_PENDING_REG0
    STA $20 ; TempIRQ
    BIT #JR0_INT00_SOF

.byte $f0, $08 ; BEQ
    STA INT_PENDING_REG0 ; clear irq

    JSR $E638 ; SOFIRQ ;Increase_SOFCounter

    LDA $20 ; TempIRQ

    BIT #JR0_INT02_KBD

.byte $f0, $08 ; BEQ __

    STA INT_PENDING_REG0

    JSR KeyboardIRQ

    LDA $20 ; TempIRQ
    PLA
    STA MMU_IO_CTRL ;<<<="PullMMUIO"
    PLA
    STA MMU_MEM_CTRL
    PLY
    PLX
    PLA
    PLP
    RTI

Init_IRQHandler
    LDA MMU_IO_CTRL
    PHA                 ;<<<="PushMMUIO"
    STZ MMU_IO_CTRL     ;<<<="SetMMUIO"
    SEI
    LDA #$4B ; #<(loword(val(copy('#IRQ_Handler',2))))
    STA $FFFE ; VECTOR_IRQ
    LDA #$E6 ; #>(loword(val(copy('#IRQ_Handler',2))))
    STA $FFFF ; (VECTOR_IRQ)+1
    LDA #$FA ; #~(JR0_INT00_SOF|JR0_INT02_KBD)

    STA $D66C ; INT_MASK_REG0

    LDA #$00 ; #<(loword(val(copy('#0',2))))
    STA $4D  ; SOFCounter
    
    LDA #$00 ; #>(loword(val(copy('#0',2))))
    STA ($4D) ; (SOFCounter)+1
    
    LDA #$00 ; #<(hiword(val(copy('#0',2))))
    STA ($4D) ; (SOFCounter)+2 

    LDA #$00 ; #>(hiword(val(copy('#0',2))))
    STA ($4D) ; (SOFCounter)+3 

    CLI
    PLA
    STA MMU_IO_CTRL ;<<<="PullMMUIO"
    RTS

Init_Audio
    LDA MMU_IO_CTRL
    PHA                 ;<<<="PushMMUIO"
    STZ MMU_IO_CTRL     ; ;<<<="SetMMUIO"
    LDX #$00

    ClearAudioElement
    STZ $D400,x         ; SID_LEFT,x
    STZ $D500,x         ; SID_RIGHT,x
    INX
    CPX #$20
    BNE ClearAudioElement

    PLA
    STA MMU_IO_CTRL ;<<<="PullMMUIO"
    RTS

.endlogical

* = $00DEC0
.logical $e6c0
Init_GameFont
    LDA MMU_IO_CTRL
    PHA                ;<<<="PushMMUIO"
    STZ MMU_IO_CTRL    ;<<<="SetMMUIO"

    LDA #MMU_IO_PAGE_1
    STA MMU_IO_CTRL

CopyMemSmall
                    ;		AssignWord(FONT_FANTASY,.asrcaddr)
    LDA #<(FONT_FANTASY)
    STA local_srcaddr

    LDA #>(FONT_FANTASY)
    STA local_srcaddr+1
    
    LDA #$00 ; #<(FONT_MEM) 
    STA local_destaddr
    
    LDA #$C0 ; #>(FONT_MEM)
    STA local_destaddr+1

    LDY #$00

LoadNextFontData
    
    local_srcaddr = *+1
    LDA $1234

    local_destaddr = *+1
    STA $4321

    INC local_srcaddr
    BNE done_updating_srcaddr
    INC local_srcaddr+1

done_updating_srcaddr
    INC local_destaddr
    BNE done_updating_destaddr
    INC local_destaddr+1

done_updating_destaddr
    LDA local_srcaddr
    CMP #$07 ; #<(FONT_FANTASY+sizeof(FONT_FANTASY))  [217/$D9/"U"]
    BNE LoadNextFontData

    LDA local_srcaddr+1
    CMP #$EF ; #>(FONT_FANTASY+sizeof(FONT_FANTASY))  [247/$F7/"�"]
    BNE LoadNextFontData

    PLA
    STA MMU_IO_CTRL ;<<<="PullMMUIO"
    RTS
.endlogical

* = $00DF07
.logical $E707
FONT_FANTASY
.binary 'assets/gamefont2.bin'
.endlogical

* = $00E707
.logical $EF07
; Main
MAIN
    LDA #MMU_EDIT_EN
    STA MMU_MEM_CTRL
    STZ MMU_IO_CTRL ;<<<="SetMMUIO"
    STZ MMU_MEM_CTRL
    LDA #(Mstr_Ctrl_Text_Mode_En|Mstr_Ctrl_Text_Overlay|Mstr_Ctrl_Graph_Mode_En|Mstr_Ctrl_Bitmap_En|Mstr_Ctrl_TileMap_En|Mstr_Ctrl_Sprite_En)
    STA @w MASTER_CTRL_REG_L 
    LDA #(Mstr_Ctrl_Text_XDouble|Mstr_Ctrl_Text_YDouble)
    STA @w MASTER_CTRL_REG_H
    
    JSR Init_GameFont
    JSR Init_Audio
    JSR Init_IRQHandler

    LDA #$E0 ; #(C64COLOR.LTBLUE<<4) | C64COLOR.BLACK
    STA $48 ; CursorColor

    JSR $E040 ; JSR CearScreen

    ; map in title screen code as $06000
    ;	lda MMU_MEM_CTRL : ora #MMU_EDIT_EN : sta MMU_MEM_CTRL ;<<<=";	UnlockMMU"
    ;	lda #(TitleScreenCode/$2000)
    ;	sta MMU_MEM_BANK_3
    ;	lda MMU_MEM_CTRL : and #~(MMU_EDIT_EN) : sta MMU_MEM_CTRL ;<<<=";	LockMMU"
    ;	jsr ShowTitle

    LDA #$00
    STA $49 ; CursorColumn
    
    LDA #$00
    STA $4A ; CursorLine
    
    LDA #$00 ; #<(VKY_TEXT_MEMORY+val(copy('#0',2))*40)
    STA $4B ; CursorPointer

    LDA #$C0
    STA $4C
    
    LDA #$70
    STA $48

    LDA #<TX_GAMETITLE
    STA $30  ; STA TempSrc

    LDA #>TX_GAMETITLE
    STA $31  ; STA TempSrc+1
    
    JSR PrintAnsiString

    STZ MMU_IO_CTRL         ;<<<="SetMMUIO"
    LDA #$01
    STA $E637 ; SIDSpeed

    LDA #$00
    JSR SIDINIT

                            ;	SID_Initialize(0,0)
                            ;	SID_SetVolume(-1)
                            ;	SID_Play()
                            ;<<<="SetMMUIO"
    STZ MMU_IO_CTRL

Lock
    JMP Lock

; String for stylized title
TX_GAMETITLE
.text "Space Oddity"
.endlogical

; Write the system vectors
* = $00F7F8
.logical $FFF8
.byte $00
F256_DUMMYIRQ       ; Abort vector
    RTI

.word F256_DUMMYIRQ ; nmi
.word F256_RESET    ; reset
.word F256_DUMMYIRQ ; irq
.endlogical