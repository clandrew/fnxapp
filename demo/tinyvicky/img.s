.cpu "65816"                        ; Tell 64TASS that we are using a 65816

.include "includes/TinyVicky_Def.asm"
.include "includes/interrupt_def.asm"
.include "includes/f256jr_registers.asm"

dst_pointer = $30
src_pointer = $32

; Code
* = $000000 
        .byte 0

; Entrypoint
* = $1000
.logical $1000
F256_RESET
    CLC     ; disable interrupts
    SEI
    LDX #$FF
    TXS     ; initialize stack

    ; initialize mmu
    STZ MMU_MEM_CTRL

    LDA MMU_MEM_CTRL ; Enable editing
    ORA #MMU_EDIT_EN
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

    CLI
    JMP MAIN


MAIN
    LDA #(Mstr_Ctrl_Graph_Mode_En|Mstr_Ctrl_Bitmap_En|Mstr_Ctrl_Sprite_En|Mstr_Ctrl_TileMap_En)
    STA @w MASTER_CTRL_REG_L 
    LDA #(Mstr_Ctrl_Text_XDouble|Mstr_Ctrl_Text_YDouble)
    STA @w MASTER_CTRL_REG_H
         
    ; Clear to black
    LDA #$00
    STA $D00D ; Background red channel
    LDA #$00
    STA $D00E ; Background green channel
    LDA #$00
    STA $D00F ; Background blue channel    
    
    STZ VKY_BRDR_CTRL ; Turn off the border

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LUT copying

    ; Switch to page 1 because the lut lives there
    LDA #1
    STA MMU_IO_CTRL

    ; Source = baked-in data, Dest = register
    LDA #<LUT_IMG_START
    STA src_pointer
    LDA #>LUT_IMG_START
    STA src_pointer+1
    LDA #<VKY_GR_CLUT_0
    STA dst_pointer
    LDA #>VKY_GR_CLUT_0
    STA dst_pointer+1
    LDX #$3A
    JSR FnCopySmallLut

    LDA #<LUT_HUD_START
    STA src_pointer
    LDA #>LUT_HUD_START
    STA src_pointer+1
    LDA #<VKY_GR_CLUT_1
    STA dst_pointer
    LDA #>VKY_GR_CLUT_1
    STA dst_pointer+1
    LDX #11
    JSR FnCopySmallLut
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Go back to I/O page 0
    LDA #0
    STA MMU_IO_CTRL 
    
    STZ TyVKY_BM2_CTRL_REG ; Disable bitmap 2

    LDA #$03
    STA TyVKY_BM0_CTRL_REG ; Enable bitmap 0 (HUD), LUT 1

    LDA #$00
    STA TyVKY_BM1_CTRL_REG ; Enable bitmap 1 (BG), LUT 0

    LDA #$40    ; Tilemap below, HUD on top
    STA $D002

    ; Copy graphics data to bitmap 0 (HUD)
    lda #<HUD_START
    sta $D101 
    lda #>HUD_START 
    sta $D102
    lda #`HUD_START 
    sta $D103

    JSR FnDraw1HP

    ; Initialize sprite
    lda #<SPRITE_DATA_START 
    sta VKY_SP0_AD_L
    lda #>SPRITE_DATA_START
    sta VKY_SP0_AD_M
    lda #`SPRITE_DATA_START 
    STA VKY_SP0_AD_H

    lda #200
    sta VKY_SP0_POS_X_L ; X position
    lda #0
    STA VKY_SP0_POS_X_H ;

    lda #200
    sta VKY_SP0_POS_Y_L ; Y position
    lda #0
    STA VKY_SP0_POS_Y_H

    lda #$1 ; Size=32x32, Layer=0, LUT=0, Enabled
    sta VKY_SP0_CTRL

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #<TLSET_START
    sta TILE_MAP_ADDY0_L
    lda #>TLSET_START
    sta TILE_MAP_ADDY0_M
    lda #`TLSET_START
    sta TILE_MAP_ADDY0_H

    lda #$01 ; 16x16 tiles, enable
    sta TyVKY_TL_CTRL0

    lda #48
    sta TL0_MAP_X_SIZE_L
    STZ TL0_MAP_X_SIZE_H

    lda #27
    sta TL0_MAP_Y_SIZE_L
    STZ TL0_MAP_Y_SIZE_H

    lda #<tile_map ; Point to the tile map
    sta TL0_START_ADDY_L
    lda #>tile_map
    sta TL0_START_ADDY_M
    lda #`tile_map
    sta TL0_START_ADDY_H

    stz TL0_MAP_X_POS_L
    stz TL0_MAP_X_POS_H
    stz TL0_MAP_Y_POS_L
    stz TL0_MAP_Y_POS_H


Lock
    JMP Lock

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FnDraw1HP
    ; CPU map part of the bitmap layer

    LDA MMU_MEM_CTRL ; Enable editing
    ORA #MMU_EDIT_EN
    STA MMU_MEM_CTRL

    LDA #$10; Location of portion of HUD bitmap
    STA MMU_MEM_BANK_2 ; map to bank 2 (0x4000..0x5FFF)

    LDA MMU_MEM_CTRL    ; Disable editing
    AND #~(MMU_EDIT_EN)
    STA MMU_MEM_CTRL

    ; Start address: 0x45A0    
    LDA #$A0
    STA dst_pointer
    LDA #$45
    STA dst_pointer+1

    LDA #5    ; Current HP value [0-128]

    TAX
FillLoop
    LDA dst_pointer
    PHA  
    LDA dst_pointer+1
    PHA  

    LDY #$5
ForEachPixelWithinColumn
    LDA #$01
    STA (dst_pointer)

    DEY
    BMI DoneFillingColumn

    CLC
    LDA dst_pointer
    ADC #$40
    STA dst_pointer
    LDA dst_pointer+1
    ADC #$01 ; Adds carry
    STA dst_pointer+1

    BRA ForEachPixelWithinColumn

DoneFillingColumn

    PLA
    STA dst_pointer+1
    PLA
    STA dst_pointer

    CLC
    LDA dst_pointer
    ADC #$01
    STA dst_pointer
    LDA dst_pointer+1
    ADC #$00 ; Adds carry
    STA dst_pointer+1

    DEX
    BNE FillLoop    
    
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FnCopySmallLut
    LDY #$0
LutLoop
    ; If we can switch into 16bit mode it would be nice to simplify this code,
    ; and straightforwardly save memory by not storing unused alpha in the colors.    
    CPY #$35
    BNE AfterCondBrk
    NOP
    NOP
    NOP

AfterCondBrk
    ; 0
    LDA (src_pointer)
    STA (dst_pointer)

    CLC
    LDA src_pointer
    ADC #$01
    STA src_pointer
    LDA src_pointer+1
    ADC #$00
    STA src_pointer+1

    CLC
    LDA dst_pointer
    ADC #$01
    STA dst_pointer
    LDA dst_pointer+1
    ADC #$00
    STA dst_pointer+1

    ; 1
    LDA (src_pointer)
    STA (dst_pointer)

    CLC
    LDA src_pointer
    ADC #$01
    STA src_pointer
    LDA src_pointer+1
    ADC #$00
    STA src_pointer+1

    CLC
    LDA dst_pointer
    ADC #$01
    STA dst_pointer
    LDA dst_pointer+1
    ADC #$00
    STA dst_pointer+1

    ; 2
    LDA (src_pointer)
    STA (dst_pointer)

    CLC
    LDA src_pointer
    ADC #$02
    STA src_pointer
    LDA src_pointer+1
    ADC #$00
    STA src_pointer+1

    CLC
    LDA dst_pointer
    ADC #$02
    STA dst_pointer
    LDA dst_pointer+1
    ADC #$00
    STA dst_pointer+1

    DEX
    INY
    BNE LutLoop 
    
LutDone
    RTS

.endlogical

; Emitted with 
;     D:\repos\fnxapp\BitmapEmbedder\x64\Release\BitmapEmbedder.exe D:\repos\fnxapp\demo\tinyvicky\rsrc\hud.bmp D:\repos\fnxapp\demo\tinyvicky\rsrc\colors_hud.s D:\repos\fnxapp\demo\tinyvicky\rsrc\pixmap_hud.s HUD
;     D:\repos\fnxapp\BitmapEmbedder\x64\Release\BitmapEmbedder.exe D:\repos\fnxapp\demo\tinyvicky\rsrc\sprite.bmp D:\repos\fnxapp\demo\tinyvicky\rsrc\colors_sprite.s D:\repos\fnxapp\demo\tinyvicky\rsrc\pixmap_sprite.s SPRT
;     D:\repos\fnxapp\BitmapEmbedder\x64\Release\BitmapEmbedder.exe D:\repos\fnxapp\demo\tinyvicky\rsrc\Tileset.bmp D:\repos\fnxapp\demo\tinyvicky\rsrc\colors_main.s D:\repos\fnxapp\demo\tinyvicky\rsrc\pixmap_tileset.s TLSET


.include "rsrc/colors_main.s"
.include "rsrc/colors_hud.s"
.include "rsrc/tilemap.s"

* = $10000
.logical $10000
.include "rsrc/pixmap_hud.s"
.include "rsrc/sprite_data.s"
.include "rsrc/pixmap_tileset.s"
.endlogical

; Write the system vectors
* = $FFF8
.logical $FFF8
.byte $00
F256_DUMMYIRQ       ; Abort vector
    RTI

.word F256_DUMMYIRQ ; nmi
.word F256_RESET    ; reset
.word F256_DUMMYIRQ ; irq
.endlogical