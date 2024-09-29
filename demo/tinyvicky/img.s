.cpu "65816"                        ; Tell 64TASS that we are using a 65816

.include "includes/TinyVicky_Def.asm"
.include "includes/interrupt_def.asm"
.include "includes/f256jr_registers.asm"
.include "includes/f256k_registers.asm"

dst_pointer = $30
src_pointer = $32
key_cur  = $34 

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
         
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Initialize matrix keyboard
    LDA #$FF
    STA VIA1_DDRA
    LDA #$00
    STA VIA1_DDRB

    STZ VIA1_PRB
    STZ VIA1_PRA
    
    LDA #$7F
    STA VIA0_DDRA
    STA VIA0_PRA
    STZ VIA0_PRB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
    LDX #$3F
    JSR FnCopySmallLut
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Go back to I/O page 0
    LDA #0
    STA MMU_IO_CTRL 
    
    STZ TyVKY_BM1_CTRL_REG ; Disable bitmap 1
    STZ TyVKY_BM2_CTRL_REG ; Disable bitmap 2

    LDA #$01
    STA TyVKY_BM0_CTRL_REG ; Enable bitmap 0 (HUD), LUT 0

    LDA #$40    ; Tilemap below, HUD on top
    STA $D002

    ; Copy graphics data to bitmap 0 (HUD)
    lda #<HUD_START
    sta $D101 
    lda #>HUD_START 
    sta $D102
    lda #`HUD_START 
    sta $D103

    JSR FnDrawHPBar

;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

    ; Initial tile scroll position #$26
    LDA #(($26 << 4) & $FF)
    STA TL0_MAP_X_POS_L
    LDA #(($26 >> 4) & $FF)
    STA TL0_MAP_X_POS_H

    JSR Init_IRQHandlers

    ; Live in native mode
    NOP
    NOP
    CLC
    XCE

Lock
    JMP Lock


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FnDrawHPBar
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


Init_IRQHandlers   ; Assumption: IO state has been previously set
    ; Disable IRQ handling
    SEI

    LDA #<IRQ_Handler_Native
    STA $FFEE ; VECTOR_IRQ
    LDA #>IRQ_Handler_Native
    STA $FFEF ; (VECTOR_IRQ)+1

    ; Mask off all but start-of-frame
    LDA #$FF
    STA INT_MASK_REG1
    AND #~(JR0_INT00_SOF)
    STA INT_MASK_REG0

    ; Re-enable interrupt handling    
    CLI

    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IRQ_Handler_Native
    PHP
    PHA
    PHX
    PHY
    
    ; Save the I/O page
    LDA MMU_IO_CTRL
    PHA

    ; Switch to I/O page 0
    STZ MMU_IO_CTRL

    ; Check for start-of-frame flag
    LDA #JR0_INT00_SOF
    BIT INT_PENDING_REG0
    BEQ IRQ_Handler_Native_Done
    
    ; Clear the flag for start-of-frame
    STA INT_PENDING_REG0        

    ; Advance frame
    JSR OnSOF

IRQ_Handler_Native_Done
    ; Restore the I/O page
    PLA
    STA MMU_IO_CTRL
    
    PLY
    PLX
    PLA
    PLP
    RTI
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OnSOF
    SEI ; disable interrupts

    STZ key_cur

    ; Poll right arrow
    LDA #(1 << 6 ^ $FF)
    STA VIA1_PRA
    LDA VIA0_PRB
    CMP #(1 << 7 ^ $FF)
    BNE RightArrow_DonePoll
RightArrow_Pressed
    lda #<SPRITE_FACING_EAST 
    sta VKY_SP0_AD_L
    lda #>SPRITE_FACING_EAST
    sta VKY_SP0_AD_M
    lda #`SPRITE_FACING_EAST 
    STA VKY_SP0_AD_H    
    LDA key_cur
    ORA #$01
    STA key_cur
RightArrow_DonePoll

    ; Poll down arrow
    LDA #(1 << 0 ^ $FF)
    STA VIA1_PRA
    LDA VIA0_PRB
    CMP #(1 << 7 ^ $FF)
    BNE DownArrow_DonePoll
DownArrow_Pressed
    lda #<SPRITE_FACING_SOUTH 
    sta VKY_SP0_AD_L
    lda #>SPRITE_FACING_SOUTH
    sta VKY_SP0_AD_M
    lda #`SPRITE_FACING_SOUTH 
    STA VKY_SP0_AD_H       
    LDA key_cur
    ORA #$02
    STA key_cur
DownArrow_DonePoll

    LDA #(1 << 0 ^ $FF)
    STA VIA1_PRA
    LDA VIA1_PRB
    CMP #(1 << 2 ^ $FF)
    BNE LeftArrow_DonePoll
LeftArrow_Pressed
    lda #<SPRITE_FACING_WEST_START
    sta VKY_SP0_AD_L
    lda #>SPRITE_FACING_WEST_START
    sta VKY_SP0_AD_M
    lda #`SPRITE_FACING_WEST_START
    STA VKY_SP0_AD_H    
    LDA key_cur
    ORA #$04
    STA key_cur
LeftArrow_DonePoll
 
    LDA #(1 << 0 ^ $FF)
    STA VIA1_PRA
    LDA VIA1_PRB
    CMP #(1 << 7 ^ $FF)
    BNE UpArrow_DonePoll
UpArrow_Pressed
    lda #<SPRITE_FACING_NORTH_START
    sta VKY_SP0_AD_L
    lda #>SPRITE_FACING_NORTH_START
    sta VKY_SP0_AD_M
    lda #`SPRITE_FACING_NORTH_START
    STA VKY_SP0_AD_H       
    LDA key_cur
    ORA #$08
    STA key_cur
UpArrow_DonePoll

    LDA key_cur
    AND #$01
    BEQ SOFSkip1
    JSR ScrollRight
    BRA DoneSOF
SOFSkip1

    LDA key_cur
    AND #$02
    BEQ SOFSkip2
    JSR ScrollDown
    BRA DoneSOF
SOFSkip2

    LDA key_cur
    AND #$04
    BEQ SOFSkip3
    JSR ScrollLeft
    BRA DoneSOF
SOFSkip3

    LDA key_cur
    AND #$08
    BEQ SOFSkip4
    JSR ScrollUp
    BRA DoneSOF
SOFSkip4

DoneSOF
    CLI ; Enable interrupts again
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ScrollRight
    .al
    .xl
    REP #$30    ; 16bit A,X,Y
    CLC
    LDA $D208
    ADC @w #$0010
    CMP @w #$0440
    ;BEQ ScrollRight_Done
    STA $D208

ScrollRight_Done
    .as
    .xs
    SEP #$30 ; Go back to 8bit A,X,Y
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ScrollDown
    .al
    .xl
    REP #$30    ; 16bit A,X,Y
    CLC
    LDA $D20A
    ADC @w #$0010
    AND @w #$0FFF
    ;CMP @w #$0440
    ;BEQ ScrollDown_Done
    STA $D20A

ScrollDown_Done
    .as
    .xs
    SEP #$30 ; Go back to 8bit A,X,Y
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ScrollLeft
    .al
    .xl
    REP #$30    ; 16bit A,X,Y

    SEC
    LDA $D208
    SBC @w #$0010
    CMP @w #$025F
    ;BEQ ScrollLeft_Done
    STA $D208

ScrollLeft_Done
    .as
    .xs
    SEP #$30 ; Go back to 8bit A,X,Y
    RTS
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ScrollUp
    .al
    .xl
    REP #$30    ; 16bit A,X,Y

    SEC
    LDA $D20A
    SBC @w #$0010
    AND @w #$0FFF
    ;CMP @w #$025F
    ;BEQ ScrollUp_Done
    STA $D20A

ScrollUp_Done
    .as
    .xs
    SEP #$30 ; Go back to 8bit A,X,Y
    RTS
    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


FnCopySmallLut
    NOP
LutLoop
    LDY #$0

    LDA (src_pointer), y
    STA (dst_pointer), y
    INY

    LDA (src_pointer), y
    STA (dst_pointer), y
    INY

    LDA (src_pointer), y
    STA (dst_pointer), y

    CLC
    LDA src_pointer
    ADC #$03
    STA src_pointer
    LDA src_pointer+1
    ADC #$00
    STA src_pointer+1

    CLC
    LDA dst_pointer
    ADC #$04
    STA dst_pointer
    LDA dst_pointer+1
    ADC #$00
    STA dst_pointer+1

    DEX
    BNE LutLoop 
    
LutDone
    RTS

.endlogical

; Emitted with 
;     D:\repos\fnxapp\BitmapEmbedder\FixedPalette\x64\Release\BitmapEmbedder.exe D:\repos\fnxapp\demo\tinyvicky\rsrc\hud.bmp D:\repos\fnxapp\demo\tinyvicky\rsrc\pixmap_hud.s HUD

;     D:\repos\fnxapp\BitmapEmbedder\FixedPalette\x64\Release\BitmapEmbedder.exe D:\repos\fnxapp\demo\tinyvicky\rsrc\sprite0.bmp D:\repos\fnxapp\demo\tinyvicky\rsrc\pixmap_sprite.s SPRITE_FACING_SOUTH
;     D:\repos\fnxapp\BitmapEmbedder\FixedPalette\x64\Release\BitmapEmbedder.exe D:\repos\fnxapp\demo\tinyvicky\rsrc\sprite1.bmp D:\repos\fnxapp\demo\tinyvicky\rsrc\pixmap_sprite.s SPRITE_FACING_EAST
;     D:\repos\fnxapp\BitmapEmbedder\FixedPalette\x64\Release\BitmapEmbedder.exe D:\repos\fnxapp\demo\tinyvicky\rsrc\sprite2.bmp D:\repos\fnxapp\demo\tinyvicky\rsrc\pixmap_sprite.s SPRITE_FACING_WEST
;     D:\repos\fnxapp\BitmapEmbedder\FixedPalette\x64\Release\BitmapEmbedder.exe D:\repos\fnxapp\demo\tinyvicky\rsrc\sprite3.bmp D:\repos\fnxapp\demo\tinyvicky\rsrc\pixmap_sprite.s SPRITE_FACING_NORTH

;     D:\repos\fnxapp\BitmapEmbedder\FixedPalette\x64\Release\BitmapEmbedder.exe D:\repos\fnxapp\demo\tinyvicky\rsrc\Tileset.bmp D:\repos\fnxapp\demo\tinyvicky\rsrc\pixmap_tileset.s TLSET


.include "rsrc/colors_main.s"
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