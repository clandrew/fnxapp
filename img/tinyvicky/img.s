.cpu "65816"                        ; Tell 64TASS that we are using a 65816

.include "api.asm"
.include "TinyVicky_Def.asm"
.include "interrupt_def.asm"
.include "C256_Jr_SID_def.asm"
.include "includes/f256jr_registers.asm"

; Constants
VIA_ORB_IRB = $DC00
VIA_ORB_IRA = $DC01

dst_pointer = $30
src_pointer = $32
column = $34
bm_bank = $35
line = $40

; Code
* = $000000 
        .byte 0

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
    BNE ChrOut_Done

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

ChrOut_Done
    STY $49
    PLA
    STA $01
    PLY
    PLA
    RTS

ClearScreen
    PHA
    PHX
    LDA $01
    PHA
    STZ $E073
    STZ $4B
.byte $a9, $c0, $8d, $74, $e0, $85
.byte $4c, $a9, $02, $85, $01, $a2, $20, $20, $71, $e0, $9c, $73, $e0, $a9, $c0, $8d
.byte $74, $e0, $a9, $03, $85, $01, $a6, $48, $20, $71, $e0, $68, $85, $01, $fa
    PLA
    RTS

.byte $8a, $8d, $34, $12, $ee, $73, $e0, $d0, $03, $ee, $74, $e0, $ad, $73, $e0
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
    JSR ClearScreen
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
    JSR ClearScreen

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
    LDA #(Mstr_Ctrl_Text_Mode_En|Mstr_Ctrl_Text_Overlay|Mstr_Ctrl_Graph_Mode_En|Mstr_Ctrl_Bitmap_En)
    STA @w MASTER_CTRL_REG_L 
    LDA #(Mstr_Ctrl_Text_XDouble|Mstr_Ctrl_Text_YDouble)
    STA @w MASTER_CTRL_REG_H
    
    JSR Init_GameFont

    LDA #$E0 ; #(C64COLOR.LTBLUE<<4) | C64COLOR.BLACK
    STA $48 ; CursorColor

    JSR ClearScreen

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
         
    ; Clear to magenta
    LDA #$00
    STA $D00D ; Background red channel
    LDA #$00
    STA $D00E ; Background green channel
    LDA #$00
    STA $D00F ; Background blue channel
    
    STZ TyVKY_BM1_CTRL_REG ; Make sure bitmap 1 is turned off
    STZ TyVKY_BM2_CTRL_REG ; Make sure bitmap 2 is turned off

    ; Enable bitmap layer0
    LDA #$1 ; set Enable. Setting no more bits leaves LUT selection to 0
    STA TyVKY_BM0_CTRL_REG    

    lda #$40 ; Layer 0 = BM 0, Layer 1 = TM 0
    sta VKY_LAYER_CTRL_0
    lda #$01 ; Layer 2 = BM 1
    sta VKY_LAYER_CTRL_1

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ; Switch to page 1 because the lut lives there
    LDA #1
    STA MMU_IO_CTRL

    ; Store a dest pointer in $30-$31
    LDA #<VKY_GR_CLUT_0
    STA dst_pointer
    LDA #>VKY_GR_CLUT_0
    STA dst_pointer+1

    ; Store a source pointer
    LDA #<LUT_START
    STA src_pointer
    LDA #>LUT_START
    STA src_pointer+1

    LDX #$00

    ; It won't load from src_pointer, probably the MMU is not set to the right thing.

LutLoop
    LDY #$0
        
    LDA (src_pointer),Y
    STA (dst_pointer),Y
    INY    
    LDA (src_pointer),Y
    STA (dst_pointer),Y
    INY
    LDA (src_pointer),Y
    STA (dst_pointer),Y
    INY

    INX
    BEQ LutDone     ; When X overflows, exit

    CLC
    LDA dst_pointer
    ADC #$04
    STA dst_pointer
    LDA dst_pointer+1
    ADC #$00 ; Add carry
    STA dst_pointer+1
    
    ;CLC
    ;LDA src_pointer
    ;ADC #$04
    ;STA src_pointer
    ;LDA src_pointer+1
    ;ADC #$00 ; Add carry
    ;STA src_pointer+1
    BRA LutLoop
    
LutDone

    ; Go back to I/O page 0
    LDA #0
    STA MMU_IO_CTRL

    
    STZ TyVKY_BM1_CTRL_REG ; Make sure bitmap 1 is turned off
    STZ TyVKY_BM2_CTRL_REG ; Make sure bitmap 2 is turned off

    ; Enable bitmap layer0
    LDA #$1 ; set Enable. Setting no more bits leaves LUT selection to 0
    STA TyVKY_BM0_CTRL_REG    

    ; Now copy graphics data
    lda #<IMG_START ; Set the low byte of the bitmap’s address
    sta $D101
    lda #>IMG_START ; Set the middle byte of the bitmap’s address
    sta $D102
    lda #`IMG_START ; Set the upper two bits of the address
    and #$03
    sta $D103

    ;;;;;;;;;;;;;;;

    ; Set the line number to 0
    stz line

    ; Calculate the bank number for the bitmap
    lda #(IMG_START >> 13)
    sta bm_bank
    bank_loop: stz dst_pointer ; Set the pointer to start of the current bank
    lda #$20
    sta dst_pointer+1
    ; Set the column to 0
    stz column
    stz column+1
    ; Alter the LUT entries for $2000 -> $bfff

    lda #$80 ; Turn on editing of MMU LUT #0, and use #0
    sta MMU_MEM_CTRL
    lda bm_bank
    sta MMU_MEM_BANK_1 ; Set the bank we will map to $2000 - $3fff
    stz MMU_MEM_CTRL ; Turn off editing of MMU LUT #0

    ; Fill the line with the color..
loop2
    lda line ; The line number is the color of the line

    sta (dst_pointer)
    inc_column: inc column ; Increment the column number
    bne chk_col
    inc column+1
    chk_col: lda column ; Check to see if we have finished the row
    cmp #<320
    bne inc_point
    lda column+1
    cmp #>320
    bne inc_point

    LDA line ; If so, increment the line number
    inc a
    STA line
    cmp #240 ; If line = 240, we’re done
    beq Lock

    stz column ; Set the column to 0
    stz column+1
    inc_point: inc dst_pointer ; Increment pointer
    bne loop2 ; If < $4000, keep looping
    inc dst_pointer+1
    lda dst_pointer+1
    cmp #$40
    bne loop2
    inc bm_bank ; Move to the next bank
    bra bank_loop ; And start filling it

Lock
    JMP Lock

; String for stylized title
TX_GAMETITLE
.text "Test text"
.byte 0 ; null term
.endlogical

; Emitted with 
;     D:\repos\fnxapp\BitmapEmbedder\x64\Release\BitmapEmbedder.exe D:\repos\fnxapp\img\tinyvicky\rsrc\vcf.bmp D:\repos\fnxapp\img\tinyvicky\rsrc\colors.s D:\repos\fnxapp\img\tinyvicky\rsrc\pixmap.s

* = $F800
.logical $F000
.include "rsrc/colors.s"
.endlogical

* = $10000-$800
.logical $10000
.include "rsrc/pixmap.s"
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