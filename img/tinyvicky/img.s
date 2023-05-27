.cpu "65816"                        ; Tell 64TASS that we are using a 65816

.include "api.asm"
.include "TinyVicky_Def.asm"
.include "interrupt_def.asm"
.include "C256_Jr_SID_def.asm"
.include "includes/f256jr_registers.asm"

; Constants
VIA_ORB_IRB = $DC00
VIA_ORB_IRA = $DC01
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
    JMP SoundInitStart
    JMP Fn11CC
    JMP Fn12A6
    JMP Fn11C2
    JMP Fn12A5_EarlyOut

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

SoundInitStart
                JSR   SomeSoundFn
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

Fn11C2
                LDX   #$15
                JSR   $1BE8
                LDX   #$00
                JMP   $1BE8

Fn11CC
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
Fn12A5_EarlyOut
                RTS

Fn12A6
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

SomeSoundFn
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
    BPL L1AB2
    STA $1B63
    JSR $1BD1
    JMP $1B2B

L1AB2
    TAY
    LDA $1A25,Y
    STA $1ABE
    LDA $1026,X
    CLC

    BCC L1AEA

    LDY #$FF
    LDA #$6E
    JSR $1C6F
    JMP $1B2B

.byte $09, $02, $d0, $0b, $29, $fd

    JMP $1AD8
.byte  $09, $04, $d0, $02, $29, $fb, $9d, $26, $10

    JMP $1B2B
    LDA #$FF

.byte $9d, $27, $10, $bd, $26, $10, $09, $01, $d0, $ee

L1AEA
.byte $a0, $0c, $b1, $fe, $d0, $0e
.byte $a9, $fe, $9d, $27, $10, $3d, $26, $10, $9d, $26, $10, $4c, $01, $1b, $9d, $50
.byte $10, $a0, $0d, $b1, $fe, $f0, $03, $9d, $51, $10, $e0, $15, $90, $10, $ec, $7d
.byte $16, $d0, $18, $c8, $b1, $fe, $f0, $13

    STA $1681
    JMP L1B2B
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

    JSR L1B80

L1B35
    LDA $107B,X
    BEQ EarlyOut_1b52

    CMP #$20
    BCS L1B80
    ASL
    TAY
    LDA $1C29,Y
    STA $1B50
    LDA $1C2A,Y
    STA $1B51
    LDA $107C,X
    JMP Fn1C78
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

SomeLookupTable
;       1   10   20   30   39   49   60  78   83   94   97   106  112  119
.byte $01, $0a, $14, $1e, $27, $31, $3c, $4e, $53, $5e, $61, $6a, $70, $77

L1B80
.byte $48, $4a, $4a, $4a, $4a, $a8, $b9, $70, $1b, $8d, $94, $1b, $68, $29, $0f, $8d
.byte $63, $1b, $18, $90, $31, $60, $bd, $23, $11, $20, $5d, $1b, $4c, $a5, $1b, $bd
.byte $23, $11, $20, $55, $1b, $9d, $23, $11, $60, $bd, $26, $10, $20, $5d, $1b, $9d
.byte $26, $10, $60, $bd, $24, $11, $20, $5d, $1b, $4c, $c2, $1b, $bd, $24, $11, $20
.byte $55, $1b, $9d, $24, $11, $60, $9d, $f8, $10, $a8, $b9, $8b, $2c, $9d, $f9, $10
.byte $60, $a0, $05, $20, $5b, $1b, $4c, $7c, $1c, $a0, $00, $b1, $fe, $29, $30, $9d
.byte $ca, $10, $60, $0a, $9d, $ce, $10, $60, $e0, $15, $b0, $28, $8d, $55, $12, $8d
.byte $30, $13, $60, $4c, $1b, $1c, $9d, $f6, $10, $a9, $ff, $9d, $52, $10, $60, $0a
; 1400
.byte $0a, $0a, $4c, $ad, $1c, $bd, $26, $10, $20, $55, $1b, $60, $0a, $0a, $0a, $0a
.byte $8d, $50, $12, $60, $8d, $7e, $12, $8d, $35, $13, $60, $0a, $0a, $0a, $0a, $e0
.byte $15, $90, $04, $8d, $80, $12, $60, $8d, $57, $12, $60, $69, $1c, $6d, $1c, $78
.byte $1c, $af, $1b, $a5, $1b, $c2, $1b, $c6, $1b, $7c, $1c, $84, $1c, $8d, $1c, $9d
.byte $1c, $f6, $1b, $ad, $1c, $b1, $1c, $b7, $1c, $c3, $1c, $ef, $1c, $fe, $1c, $07
.byte $1d, $17, $1d, $28, $1d, $dd, $1b, $31, $1d, $31, $1d, $31, $1d, $31, $1d, $31
.byte $1d, $31, $1d, $3d, $1d, $51, $1d, $60, $1d, $a0, $81, $d0, $02, $a0, $82, $48
.byte $98, $9d, $ca, $10, $68, $4c, $7c, $19

Fn1C78
                LDY   #$83
                BNE   $1C6F

                PHA
                JSR   $1BD9
                PLA
                JMP   $195F

                JSR   $1B6B
                ADC   #$10
                STA   $1050,X
                RTS

                JSR   $1B6B
                LDY   #$0A
                ADC   ($FE),Y
                STA   $1051,X
                LDA   #$00
                STA   $1028,X
                RTS

                JSR   $1B6B
                LDY   #$0B
                ADC   ($FE),Y
                STA   $1718
                LDA   #$00
                STA   $171F
                RTS

                STA   $10A6,X
                RTS

                AND   #$0F
                STA   $1025,X
                RTS

                CPX   #$15
                BCC   L1CBF
                STA   $1294
                RTS

L1CBF           STA   $126B
                RTS

                ORA   #$80
L1CC5           STA   $2C6C
                LDA   #$00
L1CCA           STA   $10F5
                STA   $10FC
                STA   $1103
                STA   $10F4
                STA   $10FB
                STA   $1102
                STA   $110A
                STA   $1111
                STA   $1118
                STA   $1109
                STA   $1110
                STA   $1117
                RTS

                PHA
                AND   #$0F
                ORA   #$80
                STA   $2C6D
                PLA
                LSR   A
                LSR   A
                LSR   A
                LSR   A
                BPL   L1CC5

                BEQ   L1D7E
                TAY
                LDA   $2C8A,Y
                JMP   L1CCA

                ORA   #$80
L1D09           LDY   $10A2,X
                STA   $2C6C,Y
                TYA
L1D10           STA   $10F4,X
                STA   $10F5,X
                RTS

                PHA
                LSR   A
                LSR   A
                LSR   A
                LSR   A
                JSR   L1D09
                PLA
                AND   #$0F
                ORA   #$80
                STA   $2C6D,Y
                RTS

                BEQ   L1D7E
                TAY
                LDA   $2C8A,Y
                JMP   L1D10

                CPX   #$15
                BCC   L1D39
                STA   $1296
                RTS

L1D39           STA   $126D
                RTS

L1D3D           LDY   $10A3,X
                BEQ   L1D4D
                INY
                BNE   L1D48
                STA   $10A3,X
L1D48           LDA   #$02
                STA   $104D,X
L1D4D           DEC   $10A3,X
                RTS

                LDY   $10A3,X
                BNE   L1D5D
                CLC
                ADC   $104D,X
                STA   $104D,X
L1D5D           JMP   L1D3D

                PHA
                AND   #$0F
                CPX   #$15
                BCC   L1D6D
                STA   $1277
                JMP   L1D70

L1D6D           STA   $124E
L1D70           PLA
                AND   #$F0
                CPX   #$15
                BCC   L1D7B
                STA   $1279
                RTS

L1D7B           STA   $1250
L1D7E           RTS

; data here
.byte $02
.byte $02, $02, $04, $04, $06, $04, $04, $06, $08, $0a, $0b, $0e, $0e, $10, $0b, $0e
.byte $0e, $10, $02, $02, $13, $15, $48, $03, $55, $56, $0b, $0e, $0e, $10, $58, $5c
.byte $02, $02, $13, $15, $48, $03, $55, $63, $62, $01, $01, $01, $ff, $00, $2f, $03
.byte $03, $03, $05, $05, $07, $05, $05, $07, $2c, $0a, $0c, $0f, $0f, $11, $0c, $0f
.byte $0f, $11, $03, $03, $22, $24, $43, $4a, $4c, $4e, $0c, $0f, $0f, $11, $59, $5d
.byte $03, $03, $22, $24, $43, $4a, $4c, $68, $62, $01, $01, $01, $ff, $00, $2f, $12
.byte $1d, $26, $19, $19, $1c, $19, $19, $1c, $27, $09, $35, $36, $37, $38, $35, $36
.byte $37, $3f, $3b, $3d, $3e, $15, $44, $12, $51, $52, $35, $36, $37, $38, $66, $67
; 1600
.byte $3b, $3d, $3e, $15, $44, $12, $51, $52, $62, $01, $01, $01, $ff, $00, $2f, $01
.byte $29, $2a, $2f, $2f, $30, $2f, $31, $32, $2b, $0a, $2e, $33, $34, $39, $2e, $33
.byte $34, $3c, $40, $41, $42, $15, $45, $0d, $50, $53, $2e, $33, $34, $39, $60, $61
.byte $40, $41, $42, $15, $45, $0d, $50, $53, $62, $01, $01, $01, $ff, $00, $2f, $0d
.byte $0d, $64, $18, $18, $1b, $18, $18, $1b, $2d, $57, $18, $1f, $1f, $21, $18, $1f
.byte $1f, $21, $64, $64, $14, $15, $46, $16, $4f, $54, $18, $1f, $1f, $21, $5a, $5e
.byte $64, $64, $14, $15, $46, $16, $4f, $54, $62, $01, $01, $01, $ff, $00, $2f, $16
.byte $16, $65, $17, $17, $1a, $17, $17, $1a, $3a, $57, $17, $1e, $1e, $20, $17, $1e
.byte $1e, $20, $65, $65, $23, $25, $47, $49, $4b, $4d, $17, $1e, $1e, $20, $5f, $5b
.byte $65, $65, $23, $25, $47, $49, $4b, $4d, $62, $01, $01, $01, $ff, $00, $2f, $00
.byte $77, $77, $77, $72, $ff, $20, $92, $01, $00, $77, $73, $11, $00, $77, $73, $ff
.byte $20, $ba, $83, $72, $00, $00, $7e, $00, $77, $70, $38, $00, $00, $7e, $00, $77
.byte $70, $ff, $20, $8d, $01, $00, $77, $73, $11, $00, $77, $73, $ff, $20, $bd, $83
.byte $79, $00, $00, $7e, $00, $77, $70, $b5, $80, $72, $00, $00, $7e, $00, $77, $70
.byte $ff, $20, $96, $01, $00, $77, $73, $13, $00, $77, $73, $ff, $20, $ba, $83, $76
.byte $00, $00, $7e, $00, $77, $70, $bf, $80, $79, $00, $00, $7e, $00, $77, $70, $ff
; 1700
.byte $20, $80, $80, $02, $01, $00, $77, $77, $77, $71, $ff, $20, $ae, $05, $00, $73
.byte $2e, $00, $71, $2e, $2e, $2e, $2e, $ff, $10, $00, $77, $74, $ff, $10, $8d, $04
.byte $00, $70, $a5, $05, $00, $00, $88, $01, $8d, $04, $00, $0d, $00, $a5, $05, $00
.byte $70, $91, $04, $00, $70, $a5, $05, $00, $00, $8d, $01, $91, $04, $00, $11, $00
.byte $a5, $05, $00, $91, $04, $00, $ff, $20, $bd, $87, $79, $00, $74, $bd, $79, $00
.byte $74, $35, $00, $74, $35, $00, $70, $b5, $75, $00, $70, $ff, $20, $00, $00, $ae
.byte $08, $00, $72, $3a, $00, $76, $2c, $00, $72, $38, $00, $74, $ff, $20, $92, $04
.byte $00, $70, $a5, $05, $00, $00, $8d, $01, $92, $04, $00, $12, $00, $a5, $05, $00
.byte $8d, $01, $00, $92, $04, $00, $70, $95, $05, $00, $00, $92, $01, $8d, $04, $00
.byte $0d, $00, $91, $05, $00, $8d, $04, $00, $ff, $20, $b6, $07, $00, $74, $36, $00
.byte $74, $b6, $72, $00, $74, $bd, $75, $00, $70, $bd, $79, $00, $70, $ff, $20, $92
.byte $04, $00, $70, $a5, $05, $00, $00, $8d, $01, $92, $04, $00, $12, $00, $a5, $05
.byte $00, $8d, $01, $00, $ff, $10, $b6, $07, $00, $74, $36, $00, $74, $ff, $10, $00
.byte $71, $b1, $09, $00, $77, $73, $30, $00, $77, $00, $ff, $20, $97, $01, $00, $74
.byte $16, $00, $74, $14, $00, $74, $12, $00, $74, $ff, $20, $bb, $83, $75, $00, $7e
.byte $00, $72, $ba, $76, $00, $7e, $00, $72, $b8, $75, $00, $7e, $00, $72, $c2, $79
; 1800
.byte $00, $70, $7e, $00, $70, $ff, $20, $00, $75, $ff, $08, $aa, $08, $00, $72, $35
.byte $00, $76, $29, $00, $72, $33, $00, $76, $ff, $20, $b1, $0a, $00, $00, $b1, $08
.byte $b1, $0a, $00, $00, $b1, $08, $00, $b1, $08, $b1, $0a, $00, $00, $b1, $08, $b1
.byte $0a, $b1, $08, $b0, $0a, $00, $00, $b0, $08, $b0, $0a, $00, $00, $b0, $08, $00
.byte $b0, $08, $b0, $0a, $00, $00, $b0, $08, $b0, $0a, $b0, $08, $ff, $20, $a9, $08
.byte $00, $70, $a9, $08, $00, $00, $a9, $0a, $00, $00, $a9, $08, $00, $70, $a9, $08
.byte $00, $a9, $08, $00, $70, $a9, $08, $00, $00, $a9, $0a, $00, $00, $a9, $08, $00
.byte $70, $29, $00, $ff, $20, $ac, $09, $00, $70, $2c, $00, $00, $2c, $00, $00, $2c
.byte $00, $70, $2c, $00, $2c, $00, $70, $2c, $00, $00, $2c, $00, $00, $2c, $00, $70
.byte $2c, $00, $ff, $20, $b1, $0a, $00, $00, $b1, $08, $b1, $0a, $00, $00, $b1, $08
.byte $00, $b1, $08, $b1, $0a, $00, $00, $b1, $08, $b1, $0a, $b1, $08, $b3, $0a, $00
.byte $00, $b3, $08, $b3, $0a, $00, $00, $b3, $08, $00, $b3, $08, $b3, $0a, $00, $00
.byte $b3, $08, $b3, $0a, $b3, $08, $ff, $20, $a9, $08, $00, $70, $a9, $08, $00, $00
.byte $a9, $0a, $00, $00, $a9, $08, $00, $70, $a9, $08, $00, $ab, $08, $00, $70, $ab
.byte $08, $00, $00, $ab, $0a, $00, $00, $ab, $08, $00, $70, $ab, $08, $00, $ff, $20
.byte $ae, $09, $00, $70, $2e, $00, $00, $2e, $00, $00, $2e, $00, $70, $2e, $00, $2e
; 1900
.byte $00, $70, $2e, $00, $00, $2e, $00, $00, $2e, $00, $70, $2e, $00, $ff, $20, $00
.byte $71, $b1, $09, $00, $77, $73, $30, $00, $71, $c6, $11, $00, $73, $ff, $20, $b1
.byte $0a, $00, $70, $31, $00, $00, $31, $00, $00, $31, $00, $70, $31, $00, $31, $00
.byte $70, $31, $00, $00, $31, $00, $00, $31, $00, $70, $31, $00, $ff, $20, $aa, $08
.byte $00, $70, $2a, $00, $00, $2a, $00, $2a, $2a, $00, $00, $2a, $2a, $2a, $2a, $00
.byte $00, $2a, $2a, $00, $2a, $29, $00, $29, $29, $00, $00, $29, $29, $29, $ff, $20
.byte $b1, $0a, $00, $70, $31, $00, $00, $31, $00, $00, $31, $00, $70, $31, $00, $ff
.byte $10, $aa, $08, $00, $00, $2a, $2a, $00, $00, $2a, $00, $2a, $2a, $00, $00, $2a
.byte $2a, $2a, $ff, $10, $aa, $08, $00, $70, $33, $00, $70, $29, $00, $70, $31, $00
.byte $70, $27, $00, $70, $30, $00, $70, $2a, $00, $70, $31, $00, $70, $ff, $20, $00
.byte $00, $af, $08, $00, $70, $36, $00, $70, $2e, $00, $70, $35, $00, $70, $2c, $00
.byte $70, $33, $00, $70, $2e, $00, $70, $36, $00, $ff, $20, $ba, $08, $00, $70, $42
.byte $00, $70, $ff, $08, $00, $00, $bd, $08, $00, $72, $ff, $08, $00, $73, $7e, $00
.byte $77, $77, $74, $ff, $20, $ae, $09, $00, $77, $77, $77, $71, $ff, $20, $00, $77
.byte $77, $77, $72, $ff, $20, $b6, $0b, $c1, $80, $03, $06, $00, $77, $75, $7e, $63
.byte $00, $77, $c4, $80, $03, $28, $ff, $20, $00, $70, $63, $00, $77, $00, $bf, $80
; 1a00
.byte $03, $30, $00, $70, $63, $00, $77, $70, $ff, $20, $99, $8b, $01, $02, $00, $77
.byte $77, $77, $71, $ff, $20, $00, $77, $74, $be, $91, $01, $04, $00, $77, $73, $ff
.byte $20, $ab, $08, $00, $77, $77, $72, $b3, $92, $01, $70, $00, $74, $ff, $20, $b8
.byte $02, $38, $63, $7e, $3d, $63, $3f, $c2, $80, $03, $80, $63, $7e, $41, $bf, $80
.byte $03, $60, $63, $7e, $3d, $bc, $80, $03, $40, $63, $00, $00, $7e, $00, $00, $3c
.byte $63, $41, $63, $3f, $63, $3d, $63, $3c, $bd, $80, $03, $40, $ff, $20, $00, $71
.byte $a5, $82, $06, $da, $63, $a5, $bf, $0a, $00, $a5, $bf, $0a, $00, $63, $00, $a5
.byte $bf, $0a, $00, $a7, $bf, $0a, $00, $63, $00, $a5, $bf, $0a, $00, $a4, $bf, $0a
.byte $00, $00, $63, $7e, $00, $77, $71, $ff, $20, $00, $71, $a5, $82, $06, $da, $63
.byte $a7, $bf, $0a, $00, $63, $a5, $bf, $0a, $00, $63, $a7, $bf, $0a, $00, $63, $a5
.byte $bf, $0a, $00, $63, $a7, $bf, $0a, $00, $63, $a5, $bf, $0a, $00, $63, $a7, $bf
.byte $0a, $00, $63, $a5, $bf, $0a, $00, $63, $a7, $bf, $0a, $00, $a5, $bf, $0a, $00
.byte $a7, $80, $03, $40, $00, $65, $7e, $00, $71, $ff, $20, $00, $70, $a5, $82, $06
.byte $da, $a5, $bf, $0a, $00, $63, $a5, $bf, $0a, $00, $63, $a5, $bf, $0a, $00, $63
.byte $a5, $bf, $0a, $00, $63, $a7, $bf, $0a, $00, $63, $a5, $bf, $0a, $00, $63, $a4
.byte $bf, $0a, $00, $63, $00, $7e, $00, $77, $70, $ff, $20, $00, $71, $a5, $82, $06
; 1b00
.byte $da, $63, $a7, $bf, $0a, $00, $63, $a5, $bf, $0a, $00, $a7, $bf, $0a, $00, $63
.byte $00, $a5, $bf, $0a, $00, $63, $a7, $bf, $0a, $00, $63, $a5, $bf, $0a, $00, $63
.byte $a7, $bf, $0a, $00, $63, $a5, $bf, $0a, $00, $63, $a7, $bf, $0a, $00, $63, $a5
.byte $bf, $0a, $00, $a7, $80, $03, $40, $00, $00, $65, $7e, $00, $00, $ff, $20, $63
.byte $bf, $3f, $bd, $3f, $ba, $3f, $63, $00, $00, $7e, $00, $71, $ba, $02, $63, $3c
.byte $63, $3d, $3d, $63, $7e, $3d, $63, $3f, $3d, $63, $7e, $3d, $63, $3d, $63, $3f
.byte $bd, $80, $01, $40, $ff, $20, $bf, $80, $03, $40, $63, $bd, $02, $63, $7e, $00
.byte $74, $3a, $63, $3c, $63, $3d, $63, $7e, $3d, $3d, $63, $3f, $63, $3d, $3d, $63
.byte $7e, $3d, $63, $3f, $bd, $80, $01, $40, $ff, $20, $c1, $0c, $41, $63, $7e, $41
.byte $63, $41, $c4, $3f, $63, $7e, $44, $c1, $3f, $63, $7e, $41, $41, $63, $00, $00
.byte $7e, $00, $00, $41, $63, $45, $63, $41, $63, $41, $63, $41, $c2, $80, $03, $40
.byte $ff, $20, $63, $42, $42, $42, $63, $00, $00, $7e, $00, $71, $c2, $0c, $63, $42
.byte $63, $42, $42, $63, $7e, $42, $63, $42, $41, $63, $7e, $41, $63, $41, $63, $41
.byte $c2, $80, $01, $40, $ff, $20, $c4, $80, $03, $40, $63, $c2, $0c, $63, $7e, $00
.byte $74, $42, $63, $42, $63, $42, $63, $7e, $42, $42, $63, $42, $63, $41, $41, $63
.byte $7e, $41, $63, $41, $c2, $80, $01, $40, $ff, $20, $c4, $80, $03, $40, $63, $c2
; 1c00
.byte $0c, $63, $00, $7e, $00, $77, $ff, $10, $bf, $80, $03, $40, $63, $bd, $02, $63
.byte $00, $7e, $00, $77, $ff, $10, $b3, $0a, $00, $74, $b1, $12, $00, $77, $77, $72
.byte $ff, $20, $c1, $80, $03, $58, $00, $00, $63, $00, $73, $7e, $00, $bf, $02, $63
.byte $bd, $3f, $63, $3c, $3c, $3c, $3d, $3c, $63, $38, $63, $00, $00, $7e, $00, $72
.byte $ff, $20, $bf, $80, $03, $40, $63, $bd, $02, $63, $00, $7e, $00, $75, $ba, $0c
.byte $63, $ff, $10, $c1, $02, $00, $63, $00, $71, $7e, $00, $00, $41, $bf, $3f, $63
.byte $00, $3d, $bc, $3f, $63, $00, $71, $7e, $00, $77, $ff, $20, $bf, $02, $3f, $63
.byte $7e, $3f, $63, $41, $63, $3d, $63, $00, $7e, $3d, $63, $3d, $63, $3c, $3c, $63
.byte $7e, $3d, $63, $3c, $63, $3a, $00, $00, $63, $00, $00, $7e, $00, $ff, $20, $c4
.byte $80, $03, $40, $63, $c2, $0c, $63, $00, $7e, $00, $75, $bd, $02, $63, $ff, $10
.byte $bd, $80, $03, $58, $00, $00, $63, $00, $73, $7e, $00, $bc, $0c, $63, $ba, $3f
.byte $63, $38, $38, $38, $3a, $38, $63, $35, $63, $00, $00, $7e, $00, $72, $ff, $20
.byte $bd, $0c, $00, $63, $00, $71, $7e, $00, $00, $3d, $bc, $3f, $63, $00, $3a, $b8
.byte $3f, $63, $00, $71, $7e, $00, $77, $ff, $20, $bb, $0c, $3b, $63, $7e, $3b, $63
.byte $3d, $63, $3a, $63, $00, $7e, $3a, $63, $3a, $63, $38, $38, $63, $7e, $3a, $63
.byte $38, $63, $36, $00, $00, $63, $00, $00, $7e, $00, $ff, $20, $a5, $88, $06, $bc
; 1d00
.byte $00, $9d, $80, $06, $bc, $9e, $8a, $06, $bc, $00, $00, $a0, $88, $06, $bc, $00
.byte $a0, $0d, $20, $a2, $88, $06, $bc, $00, $a2, $80, $06, $bc, $00, $70, $a5, $80
.byte $06, $bc, $00, $9d, $80, $06, $bc, $9e, $8a, $06, $bc, $00, $00, $a0, $88, $06
.byte $bc, $00, $a0, $0d, $20, $a2, $88, $06, $bc, $00, $a2, $80, $06, $bc, $00, $70
.byte $ff, $20, $a9, $09, $00, $00, $2a, $00, $00, $27, $00, $80, $64, $00, $a9, $09
.byte $00, $29, $00, $70, $29, $00, $00, $2a, $00, $00, $27, $00, $80, $64, $00, $29
.byte $00, $29, $00, $70, $ff, $20, $ac, $8a, $06, $bc, $00, $00, $ae, $88, $06, $bc
.byte $00, $00, $ac, $8a, $06, $bc, $00, $ac, $0e, $2c, $ae, $8a, $06, $bc, $00, $ae
.byte $80, $06, $bc, $00, $70, $ac, $80, $06, $bc, $00, $00, $ae, $88, $06, $bc, $00
.byte $00, $ac, $8a, $06, $bc, $00, $ac, $0e, $2c, $ae, $8a, $06, $bc, $00, $ae, $80
.byte $06, $bc, $00, $70, $ff, $20, $b1, $89, $06, $bc, $00, $00, $b1, $80, $06, $bc
.byte $00, $00, $b0, $80, $06, $bc, $00, $80, $64, $00, $b2, $80, $06, $bc, $00, $b2
.byte $80, $06, $bc, $00, $70, $b1, $80, $06, $bc, $00, $00, $b1, $80, $06, $bc, $00
.byte $00, $b0, $80, $06, $bc, $00, $80, $64, $00, $b2, $80, $06, $bc, $00, $b2, $80
.byte $06, $bc, $00, $70, $ff, $20, $00, $77, $bd, $0f, $00, $3d, $00, $77, $71, $3d
.byte $00, $3d, $00, $bf, $06, $bd, $3f, $ff, $20, $7e, $00, $76, $bd, $0f, $00, $3d
; 1e00
.byte $00, $77, $71, $3d, $00, $3d, $00, $70, $ff, $20, $bf, $3f, $c1, $80, $03, $20
.byte $00, $00, $64, $00, $74, $c6, $3f, $00, $80, $80, $02, $10, $80, $80, $02, $20
.byte $44, $00, $00, $64, $00, $75, $bf, $3f, $00, $63, $00, $ff, $20, $92, $01, $00
.byte $77, $73, $11, $00, $77, $73, $ff, $20, $c1, $80, $03, $20, $00, $70, $64, $00
.byte $76, $bf, $3f, $bd, $3f, $bf, $3f, $c1, $80, $03, $30, $00, $00, $64, $00, $74
.byte $bf, $3f, $00, $bd, $3f, $00, $ff, $20, $96, $01, $00, $77, $71, $18, $00, $19
.byte $00, $77, $73, $ff, $20, $b8, $3f, $ba, $80, $03, $20, $00, $72, $64, $00, $75
.byte $fe, $80, $6d, $00, $77, $73, $ff, $20, $8f, $01, $00, $77, $73, $fe, $80, $6d
.byte $00, $77, $00, $9b, $80, $02, $30, $00, $70, $ff, $20, $a2, $08, $00, $72, $35
.byte $00, $76, $25, $00, $72, $33, $00, $76, $ff, $20, $00, $00, $a9, $08, $00, $72
.byte $3a, $00, $76, $2c, $00, $72, $38, $00, $74, $ff, $20, $00, $71, $ae, $08, $00
.byte $77, $73, $31, $00, $77, $00, $ff, $20, $00, $00, $ae, $08, $00, $77, $72, $38
.byte $00, $00, $2e, $00, $00, $27, $00, $00, $1f, $00, $72, $ff, $20, $00, $71, $b3
.byte $08, $00, $70, $3a, $00, $76, $37, $00, $00, $2c, $00, $00, $22, $00, $00, $1b
.byte $00, $71, $ff, $20, $a7, $08, $00, $72, $35, $00, $76, $3a, $00, $00, $33, $00
.byte $00, $2b, $00, $00, $20, $00, $73, $ff, $20, $ba, $03, $00, $00, $7e, $00, $77
; 1f00
.byte $70, $bd, $78, $00, $00, $7e, $00, $77, $70, $ff, $20, $bf, $83, $78, $00, $00
.byte $7e, $00, $71, $80, $80, $6d, $00, $73, $80, $80, $6f, $00, $76, $fd, $80, $05
.byte $de, $00, $73, $ff, $20, $00, $77, $71, $80, $80, $02, $b0, $00, $00, $ff, $10
.byte $94, $04, $00, $70, $a5, $05, $00, $00, $93, $01, $91, $04, $00, $11, $00, $a5
.byte $05, $00, $95, $01, $00, $96, $04, $00, $70, $95, $05, $00, $00, $91, $01, $96
.byte $04, $00, $16, $00, $91, $05, $00, $94, $01, $00, $ff, $20, $b8, $07, $00, $74
.byte $b5, $7d, $00, $70, $35, $00, $70, $ba, $76, $00, $74, $ba, $72, $00, $70, $ba
.byte $76, $00, $70, $ff, $20, $ac, $08, $00, $70, $2c, $00, $00, $2d, $00, $2d, $2d
.byte $00, $00, $2d, $2d, $2d, $2e, $00, $00, $2e, $2e, $00, $2e, $2e, $00, $2e, $2e
.byte $00, $00, $2e, $2c, $2c, $ff, $20, $b3, $0a, $00, $70, $33, $00, $00, $33, $00
.byte $00, $33, $00, $70, $33, $00, $31, $00, $70, $31, $00, $00, $31, $00, $00, $31
.byte $00, $70, $31, $00, $33, $00, $70, $33, $00, $00, $33, $00, $00, $33, $00, $70
.byte $33, $00, $ff, $30, $93, $04, $00, $70, $a5, $05, $00, $00, $91, $01, $8f, $04
.byte $00, $0f, $00, $a5, $05, $00, $91, $01, $00, $8d, $04, $00, $70, $95, $05, $00
.byte $00, $8d, $01, $99, $04, $00, $19, $00, $91, $05, $00, $8f, $01, $11, $94, $04
.byte $00, $70, $a5, $05, $00, $00, $8f, $01, $94, $04, $00, $14, $00, $a5, $05, $00

; 2000
.byte $94, $01, $00, $ff, $30, $bf, $87, $79, $00, $74, $33, $00, $74, $bd, $75, $00
.byte $74, $bd, $77, $00, $70, $bd, $75, $00, $70, $38, $00, $74, $bd, $79, $00, $70
.byte $b8, $75, $00, $70, $ff, $30, $ab, $08, $00, $70, $2b, $00, $00, $2b, $00, $2b
.byte $2b, $00, $00, $2b, $2b, $2b, $2c, $00, $00, $2c, $2c, $00, $2c, $2c, $00, $2c
.byte $2c, $00, $00, $2c, $2c, $2c, $2c, $00, $70, $2c, $00, $00, $2c, $00, $2c, $2c
.byte $00, $00, $2c, $2c, $2c, $ff, $30, $b3, $0a, $00, $70, $33, $00, $00, $33, $00
.byte $00, $33, $00, $70, $33, $00, $31, $00, $70, $31, $00, $00, $31, $00, $00, $31
.byte $00, $70, $31, $00, $ff, $20, $ba, $8c, $01, $40, $bc, $80, $03, $40, $3c, $63
.byte $3c, $63, $7e, $3c, $3c, $63, $3c, $3c, $63, $bc, $80, $01, $30, $bd, $80, $03
.byte $30, $63, $3c, $63, $3a, $63, $3a, $63, $7e, $35, $3a, $63, $3c, $63, $3d, $80
.byte $80, $02, $40, $3a, $3a, $ff, $20, $b7, $0c, $63, $37, $63, $37, $63, $38, $b7
.byte $3f, $63, $00, $7e, $00, $70, $37, $00, $38, $63, $38, $63, $38, $63, $7e, $38
.byte $63, $00, $7e, $00, $70, $38, $00, $38, $63, $38, $63, $38, $63, $7e, $38, $63
.byte $00, $7e, $00, $70, $3c, $ba, $3f, $ff, $30, $fe, $80, $6f, $00, $77, $77, $77
.byte $71, $ff, $20, $bf, $83, $78, $00, $71, $fe, $80, $6e, $00, $77, $77, $75, $ff
.byte $20, $aa, $08, $00, $70, $31, $00, $70, $3a, $00, $76, $2c, $00, $70, $33, $00
; 2100
.byte $76, $ff, $20, $00, $00, $ae, $08, $00, $70, $35, $00, $76, $29, $00, $70, $30
.byte $00, $70, $38, $00, $74, $ff, $20, $bd, $82, $01, $40, $bf, $80, $03, $40, $3f
.byte $63, $3f, $63, $7e, $3f, $3f, $63, $3f, $3f, $63, $bf, $80, $01, $40, $c1, $80
.byte $03, $40, $63, $3f, $63, $3d, $63, $3d, $63, $7e, $3a, $3d, $63, $3f, $63, $41
.byte $80, $80, $02, $40, $3d, $3d, $ff, $20, $bf, $02, $63, $3f, $63, $3f, $63, $41
.byte $bf, $3f, $63, $00, $7e, $00, $70, $3f, $bd, $80, $03, $60, $3f, $63, $3f, $63
.byte $3f, $63, $41, $bf, $3f, $63, $00, $7e, $00, $70, $3f, $bd, $80, $03, $60, $3f
.byte $63, $3f, $63, $3f, $63, $41, $bf, $3f, $63, $00, $7e, $00, $70, $3f, $bd, $3f
.byte $ff, $30, $8f, $01, $00, $77, $73, $fe, $80, $6d, $00, $77, $73, $ff, $20, $1a
.byte $0f, $00, $00, $f8, $19, $40, $00, $01, $00, $14, $21, $00, $00, $00, $09, $41
.byte $00, $00, $ff, $83, $00, $00, $12, $20, $00, $12, $e0, $00, $fe, $17, $00, $ff
.byte $9a, $1a, $00, $0a, $f0, $00, $ff, $1a, $0f, $00, $00, $aa, $06, $00, $00, $01
.byte $00, $14, $21, $00, $00, $00, $09, $41, $00, $00, $ff, $84, $00, $00, $30, $20
.byte $00, $30, $e0, $00, $fe, $17, $00, $ff, $ff, $1a, $0f, $00, $cc, $4c, $06, $00
.byte $02, $01, $00, $14, $21, $00, $00, $00, $09, $41, $7f, $00, $ff, $84, $00, $00
.byte $30, $20, $00, $30, $e0, $00, $fe, $17, $00, $ff, $ff, $1a, $0f, $00, $00, $f8
; 2200
.byte $00, $00, $00, $01, $00, $1a, $2d, $00, $00, $00, $09, $81, $da, $00, $41, $90
.byte $00, $41, $00, $00, $ff, $88, $00, $00, $88, $00, $00, $83, $00, $00, $12, $20
.byte $00, $12, $e0, $00, $fe, $23, $00, $ff, $97, $70, $00, $9f, $03, $00, $9a, $1a
.byte $00, $0a, $f0, $00, $ff, $1a, $0f, $00, $00, $f9, $00, $00, $00, $01, $00, $23
.byte $27, $00, $00, $00, $09, $81, $d9, $00, $41, $a9, $00, $81, $c6, $00, $80, $c4
.byte $00, $80, $c6, $00, $fe, $19, $00, $ff, $88, $00, $00, $ff, $ff, $1a, $0f, $00
.byte $00, $fa, $07, $00, $00, $01, $00, $14, $15, $00, $00, $00, $09, $11, $00, $00
.byte $ff, $ff, $ff, $1a, $0f, $00, $00, $7a, $00, $00, $01, $01, $00, $14, $24, $00
.byte $00, $00, $09, $41, $7f, $00, $ff, $81, $80, $00, $60, $10, $00, $20, $f0, $00
.byte $20, $10, $00, $fe, $1a, $00, $ff, $ff, $1a, $0f, $00, $00, $8c, $00, $00, $00
.byte $01, $00, $17, $2a, $00, $00, $00, $09, $41, $00, $00, $40, $00, $00, $ff, $81
.byte $00, $00, $82, $00, $00, $8c, $00, $00, $0b, $b0, $00, $0b, $50, $00, $fe, $20
.byte $00, $ff, $ff, $1c, $0f, $00, $00, $7c, $00, $00, $00, $01, $00, $1a, $30, $00
.byte $00, $00, $09, $01, $00, $00, $41, $00, $00, $40, $00, $00, $ff, $88, $00, $00
.byte $81, $00, $00, $82, $00, $00, $8a, $00, $00, $0b, $b0, $00, $0b, $50, $00, $fe
.byte $26, $00, $ff, $ff, $1c, $0f, $00, $00, $7c, $00, $00, $00, $01, $00, $1d, $36
; 2300
.byte $00, $00, $00, $09, $01, $00, $00, $01, $00, $00, $41, $00, $00, $40, $00, $00
.byte $ff, $88, $00, $00, $88, $00, $00, $81, $00, $00, $82, $00, $00, $89, $00, $00
.byte $0b, $b0, $00, $0b, $50, $00, $fe, $2c, $00, $ff, $ff, $1a, $0f, $00, $ff, $ff
.byte $08, $00, $00, $01, $00, $14, $21, $00, $00, $00, $09, $41, $00, $00, $ff, $8a
.byte $00, $00, $20, $16, $00, $20, $ea, $00, $fe, $17, $00, $ff, $ff, $1a, $0f, $00
.byte $00, $7b, $05, $00, $00, $01, $00, $14, $21, $00, $00, $00, $09, $41, $00, $00
.byte $ff, $84, $00, $00, $30, $20, $00, $30, $e0, $00, $fe, $17, $00, $ff, $ff, $1a
.byte $0f, $00, $10, $c3, $00, $00, $00, $01, $00, $17, $1b, $00, $00, $00, $09, $41
.byte $b0, $00, $10, $aa, $00, $ff, $84, $00, $00, $ff, $ff, $1c, $0f, $00, $10, $92
.byte $00, $00, $00, $01, $00, $1a, $1e, $00, $00, $00, $09, $01, $00, $00, $41, $a2
.byte $00, $10, $aa, $00, $ff, $84, $00, $00, $ff, $ff, $1a, $0f, $00, $00, $e5, $00
.byte $00, $00, $01, $00, $26, $27, $00, $00, $00, $09, $81, $da, $00, $81, $98, $00
.byte $81, $b4, $00, $81, $ac, $00, $80, $b0, $00, $80, $af, $00, $fe, $1c, $00, $ff
.byte $ff, $ff, $1a, $0f, $00, $4d, $89, $07, $00, $00, $01, $00, $14, $21, $00, $00
.byte $00, $09, $41, $00, $00, $ff, $84, $00, $00, $30, $0a, $00, $30, $f6, $00, $fe
.byte $17, $00, $ff, $ff, $1a, $0f, $00, $ed, $dd, $18, $10, $00, $01, $00, $14, $21
; 2400
.byte $00, $00, $00, $09, $41, $00, $00, $ff, $81, $e0, $00, $0f, $e8, $00, $0f, $18
.byte $00, $fe, $17, $00, $ff, $ff, $1a, $0f, $00, $eb, $fb, $66, $20, $00, $01, $00
.byte $14, $21, $00, $00, $00, $09, $27, $00, $00, $ff, $88, $00, $00, $10, $40, $00
.byte $10, $c0, $00, $fe, $17, $00, $ff, $ff, $00, $04, $07, $7f, $00, $03, $07, $7f
.byte $00, $05, $07, $7f, $00, $02, $07, $7f, $fb, $00, $04, $7f, $fb, $00, $03, $7f
.byte $fb, $00, $05, $7f, $fb, $00, $02, $7f, $f8, $fb, $00, $7f, $f7, $fb, $00, $7f
.byte $f9, $fb, $00, $7f, $f6, $fb, $00, $7f, $04, $07, $0a, $7f, $0c, $8a, $ff, $21
.byte $53, $59, $4e, $43, $20, $20, $20, $20, $00, $04, $7f, $1d, $af, $1d, $df, $1d
.byte $0f, $1e, $3f, $1e, $6f, $1e, $07, $7f, $0c, $8a, $04, $0e, $00, $04, $08, $0c
.byte $10, $14, $18, $1c, $20, $24, $28, $2c, $30, $34, $8f, $8f, $b7, $d9, $fb, $35
.byte $5d, $73, $98, $c3, $f4, $2b, $4d, $6f, $8b, $aa, $d2, $f4, $16, $29, $29, $29
.byte $29, $29, $2a, $2a, $2a, $2a, $2a, $2a, $2b, $2b, $2b, $2b, $2b, $2b, $2b, $2c
.byte $9f, $a6, $b1, $c3, $ce, $e2, $ed, $01, $0c, $19, $1e, $48, $5d, $6e, $9a, $af
.byte $c6, $cf, $dc, $eb, $07, $0b, $1a, $4e, $75, $94, $c8, $f0, $0f, $1f, $3e, $60
.byte $71, $84, $9f, $bb, $c4, $cc, $d5, $de, $e5, $f8, $0a, $15, $21, $2f, $5e, $89
.byte $cb, $fb, $3f, $66, $8a, $b2, $d6, $fa, $08, $16, $22, $42, $53, $6c, $8f, $a0
; 2500
.byte $c0, $d9, $fc, $42, $66, $a6, $e6, $f9, $0a, $2d, $38, $58, $65, $78, $8b, $9a
.byte $ab, $b8, $cd, $e4, $f9, $0b, $25, $30, $5c, $75, $97, $c4, $05, $26, $57, $76
.byte $a7, $d9, $e3, $f1, $03, $17, $48, $82, $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1f
.byte $1f, $1f, $1f, $1f, $1f, $1f, $1f, $1f, $1f, $1f, $1f, $1f, $20, $20, $20, $20
.byte $20, $20, $20, $20, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21
.byte $21, $21, $22, $22, $22, $22, $22, $22, $22, $22, $23, $23, $23, $23, $23, $23
.byte $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $25, $25, $25, $25, $25
.byte $26, $26, $26, $26, $26, $26, $26, $26, $26, $26, $26, $26, $26, $27, $27, $27
.byte $27, $27, $27, $27, $28, $28, $28, $28, $28, $28, $28, $28, $29, $29, $29, $29
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
; Data end
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
    BNE LE038

    CLC
    LDA $4B
    ADC #$28
    STA $4B
    BCC LE025
    INC $4C

LE025
    LDA $4A
    INA
    CMP #$1E
    BNE LE034

    LDA #$C0
    STA $4C

    LDA #$00
    STA $4B

LE034
    STA $4A
    LDY #$00

LE038
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
.endlogical

; db00
* = $00DB00
.logical $E300
    CPX #$CE
    BNE LE30E ; .byte $d0, $0a ; BNE
    LDA $E16F ; KeyboardState
    EOR #$20 ; #KEYBOARDSTATES.CAPSLK
    STA $E16F ; KeyboardState
    BRA LE30E ; This seems pointless but ok
LE30E
    LDA #$00
    SEC
    PLX
    RTS

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

    LDA #$E0 ; #(C64COLOR.LTBLUE<<4) | C64COLOR.BLACK  [224/$E0/"…"] ;<<<="lda #DoC64COLOR(LTBLUE,BLACK)"
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

    JSR Init_Graphics   ; Init_Graphics
    CLI
    JMP MAIN

Init_Audio
    ; Dead code?
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
    CMP #$EF ; #>(FONT_FANTASY+sizeof(FONT_FANTASY))  [247/$F7/"ö"]
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

    LDA #$E0 ; #(C64COLOR.LTBLUE<<4) | C64COLOR.BLACK
    STA $48 ; CursorColor

    JSR $E040 ; JSR ClearScreen

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