.cpu "65816"                        ; Tell 64TASS that we are using a 65816

.include "includes/TinyVicky_Def.asm"
.include "includes/interrupt_def.asm"
.include "includes/f256jr_registers.asm"

dst_pointer = $30
src_pointer = $32
column = $34
bm_bank = $35
line = $40
CursorColor = $48

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
    LDA #MMU_EDIT_EN
    STA MMU_MEM_CTRL
    STZ MMU_IO_CTRL
    STZ MMU_MEM_CTRL
    LDA #(Mstr_Ctrl_Graph_Mode_En|Mstr_Ctrl_Bitmap_En)
    STA @w MASTER_CTRL_REG_L 
    LDA #(Mstr_Ctrl_Text_XDouble|Mstr_Ctrl_Text_YDouble)
    STA @w MASTER_CTRL_REG_H

    LDA #$E0 ; #(C64COLOR.LTBLUE<<4) | C64COLOR.BLACK
    STA CursorColor

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
         
    ; Clear to black
    LDA #$00
    STA $D00D ; Background red channel
    LDA #$00
    STA $D00E ; Background green channel
    LDA #$00
    STA $D00F ; Background blue channel
    
    ; Turn off the border
    STZ VKY_BRDR_CTRL

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
    LDX #47
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

    LDA #$01
    STA TyVKY_BM1_CTRL_REG ; Enable bitmap 1 (BG), LUT 0

    LDA #$10    ; Set bitmap 0 to layer 0, and bitmap 1 to layer 1
    STA $D002

    ; Copy graphics data to bitmap 1 (BG)
    lda #<IMG_START
    sta $D109
    lda #>IMG_START
    sta $D10A
    lda #`IMG_START 
    sta $D10B

    ; Copy graphics data to bitmap 0 (HUD)
    lda #<HUD_START
    sta $D101 
    lda #>HUD_START 
    sta $D102
    lda #`HUD_START 
    sta $D103

    ; CPU map part of the bitmap layer

    LDA MMU_MEM_CTRL ; Enable editing
    ORA #MMU_EDIT_EN
    STA MMU_MEM_CTRL

    LDA #$08 ; Physical address 01:0000
    STA MMU_MEM_BANK_2 ; map $00e000 to bank 2 (0x4000..0x5FFF)

    LDA MMU_MEM_CTRL    ; Disable editing
    AND #~(MMU_EDIT_EN)
    STA MMU_MEM_CTRL

    LDA #$01
    STA $4000
    STA $4001
    STA $4002

Lock
    JMP Lock

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FnCopySmallLut
    LDY #$0
LutLoop
    
    LDA (src_pointer),Y
    STA (dst_pointer),Y
    INY
    LDA (src_pointer),Y
    STA (dst_pointer),Y
    INY
    LDA (src_pointer),Y
    STA (dst_pointer),Y
    INY
    INY

    DEX
    BNE LutLoop     ; When X overflows, exit
    
LutDone
    RTS

.endlogical

; Emitted with 
;     D:\repos\fnxapp\BitmapEmbedder\x64\Release\BitmapEmbedder.exe D:\repos\fnxapp\demo\tinyvicky\rsrc\LagoonRef.bmp D:\repos\fnxapp\demo\tinyvicky\rsrc\colors_bg.s D:\repos\fnxapp\demo\tinyvicky\rsrc\pixmap_bg.s
;     D:\repos\fnxapp\BitmapEmbedder\x64\Release\BitmapEmbedder.exe D:\repos\fnxapp\demo\tinyvicky\rsrc\hud.bmp D:\repos\fnxapp\demo\tinyvicky\rsrc\colors_hud.s D:\repos\fnxapp\demo\tinyvicky\rsrc\pixmap_hud.s

.include "rsrc/colors_bg.s"
.include "rsrc/colors_hud.s"

* = $10000
.logical $10000
.include "rsrc/pixmap_bg.s"
.include "rsrc/pixmap_hud.s"
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