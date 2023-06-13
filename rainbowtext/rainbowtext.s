.cpu "65816"                        ; Tell 64TASS that we are using a 65816

.include "includes/TinyVicky_Def.asm"
.include "includes/interrupt_def.asm"
.include "includes/f256jr_registers.asm"
.include "includes/macros.s"

dst_pointer = $30
TempSrc = $30
src_pointer = $32
column = $34
bm_bank = $35
TextLength = $36
AnimationCounter = $37
line = $40
CursorColor = $48
CursorColumn = $49
CursorLine = $4A
CursorPointer = $4B

; Code
* = $000000 
        .byte 0

.if TARGETFMT = "hex"
* = $00E000
.endif
.if TARGETFMT = "bin"
* = $00E000-$800
.endif
.logical $E000

; Data buffers used during palette rotation. It'd be possible to reorganize the code to simply use
; one channel of these, but there's a memory/performance tradeoff and this chooses perf.
CACHE_BEGIN
regr .fill 16
regg .fill 16
regb .fill 16
CACHE_END

; These aren't used at the same time as reg*, so they're aliased on top.
* = CACHE_BEGIN
SOURCE          .dword ?                    ; A pointer to copy the bitmap from
DEST            .dword ?                    ; A pointer to copy the bitmap to
SIZE            .dword ?                    ; The number of bytes to copy
tmpr .byte ?            ; A backed-up-and-restored color, separated by channels
tmpg .byte ?            ; used during the 4th loop.
tmpb .byte ?
iter_i .byte ?          ; Couple counters used for the 4th loop.
iter_j .byte ?
* = CACHE_END

ClearScreen
    LDA MMU_IO_CTRL ; Back up I/O page
    PHA
    
    LDA #$02 ; Set I/O page to 2
    STA MMU_IO_CTRL
    
    STZ dst_pointer ; dst_pointer=$C000
    LDA #$C0
    STA dst_pointer+1

ClearExperiment_ForEach
    LDA #32 ; Character 0
    STA (dst_pointer) ; Character to print gets stored in (CursorPointer),Y
        
    CLC
    LDA dst_pointer
    ADC #$01
    STA dst_pointer
    LDA dst_pointer+1
    ADC #$00 ; Add carry
    STA dst_pointer+1

    CMP #$C5
    BNE ClearExperiment_ForEach
    
    PLA
    STA MMU_IO_CTRL ; Restore I/O page
    RTS


; Procedure: PrintAnsiString
; parameters:
;	<TempSrc>	=	word address of string to print
;	<CursorPointer>	=	word address of screen character/color memory
PrintAnsiString
    LDX #$00
    LDY #$00
    
    LDA MMU_IO_CTRL ; Back up I/O page
    PHA
    
    LDA #$02 ; Set I/O page to 2
    STA MMU_IO_CTRL    

PrintAnsiString_EachCharToTextMemory
    LDA (TempSrc),y                              ; Load the character to print
    BEQ PrintAnsiString_DoneStoringToTextMemory  ; Exit if null term        
    STA (CursorPointer),Y                        ; Store character to text memory
    INY
    BRA PrintAnsiString_EachCharToTextMemory

    STY TextLength

PrintAnsiString_DoneStoringToTextMemory

    LDA #$03 ; Set I/O page to 3
    STA MMU_IO_CTRL
    
    LDA #$F0


PrintAnsiString_EachCharToColorMemory
    ADC #$10
    DEY
    STA (CursorPointer),Y ; Color to print gets stored in (CursorPointer),Y

    BNE PrintAnsiString_EachCharToColorMemory

    PLA
    STA MMU_IO_CTRL ; Restore I/O page

    RTS

UpdateTextColors
    LDA MMU_IO_CTRL ; Back up I/O page
    PHA

    LDY #$00

    LDA #$03 ; Set I/O page to 3
    STA MMU_IO_CTRL
    
    LDA #<VKY_TEXT_MEMORY
    STA dst_pointer

    LDA #>VKY_TEXT_MEMORY
    STA dst_pointer+1

UpdateTextColors_ForEachCharacter
    LDA (dst_pointer),Y 
    ADC #$10
    STA (dst_pointer),Y 
    INY
    CPY TextLength
    BNE UpdateTextColors_ForEachCharacter
    
    PLA
    STA MMU_IO_CTRL ; Restore I/O page

    RTS

.endlogical

.if TARGETFMT = "hex"
* = $00E5D5
.endif
.if TARGETFMT = "bin"
* = $00E5D5-$800
.endif
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

    CLI ; Enable interrupts
    JMP MAIN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IRQ_Handler
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
    BEQ IRQ_Handler_Done
    
    ; Clear the flag for start-of-frame
    STA INT_PENDING_REG0

    ; Dec animation counter
    LDA AnimationCounter
    BNE AfterUpdateTextColors

    LDA #8
    STA AnimationCounter
    JSR UpdateTextColors

AfterUpdateTextColors
    DEC AnimationCounter

IRQ_Handler_Done
    ; Restore the I/O page
    PLA
    STA MMU_IO_CTRL
    
    PLY
    PLX
    PLA
    PLP
    RTI

Init_IRQHandler
    ; Back up I/O state
    LDA MMU_IO_CTRL
    PHA        

    ; Disable IRQ handling
    SEI

    ; Load our interrupt handler. Should probably back up the old one oh well
    LDA #<IRQ_Handler
    STA $FFFE ; VECTOR_IRQ
    LDA #>IRQ_Handler
    STA $FFFF ; (VECTOR_IRQ)+1

    ; Mask off all but start-of-frame
    LDA #$FF
    STA INT_MASK_REG1
    AND #~(JR0_INT00_SOF)
    STA INT_MASK_REG0

    ; Re-enable interrupt handling    
    CLI
    PLA ; Restore I/O state
    STA MMU_IO_CTRL ;<<<="PullMMUIO"
    RTS

.endlogical

.if TARGETFMT = "hex"
* = $00E800
.endif
.if TARGETFMT = "bin"
* = $00E800-$800
.endif
.logical $E800
.include "rsrc/colors.s"
.include "rsrc/textcolors.s"
.endlogical

.if TARGETFMT = "hex"
* = $00EF07
.endif
.if TARGETFMT = "bin"
* = $00EF07-$800
.endif
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

    LDA #$E0 ; #(C64COLOR.LTBLUE<<4) | C64COLOR.BLACK
    STA CursorColor
    
    JSR ClearScreen

    LDA #$00
    STA CursorColumn
    
    LDA #$00
    STA $4A ; CursorLine
    
    LDA #<VKY_TEXT_MEMORY
    STA CursorPointer

    LDA #>VKY_TEXT_MEMORY
    STA CursorPointer+1
    
    LDA #$70
    STA CursorColor

    LDA #<TX_GAMETITLE
    STA TempSrc

    LDA #>TX_GAMETITLE
    STA TempSrc+1

    JSR PrintAnsiString
         
    ; Clear to black
    LDA #$00
    STA $D00D ; Background red channel
    LDA #$00
    STA $D00E ; Background green channel
    LDA #$00
    STA $D00F ; Background blue channel
    
    STZ TyVKY_BM1_CTRL_REG ; Make sure bitmap 1 is turned off
    STZ TyVKY_BM2_CTRL_REG ; Make sure bitmap 2 is turned off    
    LDA #$01 
    STA TyVKY_BM0_CTRL_REG ; Make sure bitmap 0 is turned on. Setting no more bits leaves LUT selection to 0
    
    JSR CopyTextLutToDevice

    JSR CopyGraphicsLutToDevice

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
bank_loop: 
    stz dst_pointer ; Set the pointer to start of the current bank
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
loop2_fillLine
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
    beq Done_Init

    stz column ; Set the column to 0
    stz column+1
    inc_point: inc dst_pointer ; Increment pointer
    bne loop2_fillLine ; If < $4000, keep looping
    inc dst_pointer+1
    lda dst_pointer+1
    cmp #$40
    bne loop2_fillLine
    inc bm_bank ; Move to the next bank
    bra bank_loop ; And start filling it

Done_Init

    JSR Init_IRQHandler

    LDA #$01
    STA AnimationCounter

Lock    
    WAI

    JMP Lock
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CopyTextLutToDevice
    ; Switch to page 0 because the lut lives there
    LDA #0
    STA MMU_IO_CTRL
    
    LDA $EC00 ; test thingy

    ; Store a dest pointer in $30-$31
    LDA #<VKY_TXT_FGLUT
    STA dst_pointer
    LDA #>VKY_TXT_FGLUT
    STA dst_pointer+1
    
    ; Store a source pointer
    LDA #<TEXT_LUT_START
    STA src_pointer
    LDA #>TEXT_LUT_START
    STA src_pointer+1
    
    LDY #65

TextLutLoop
    DEY
    LDA (src_pointer),Y
    STA (dst_pointer),Y
    CPY #$00
    BNE TextLutLoop

    RTS
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CopyGraphicsLutToDevice
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

    INX
    BEQ LutDone     ; When X overflows, exit

    CLC
    LDA dst_pointer
    ADC #$04
    STA dst_pointer
    LDA dst_pointer+1
    ADC #$00 ; Add carry
    STA dst_pointer+1
    
    CLC
    LDA src_pointer
    ADC #$04
    STA src_pointer
    LDA src_pointer+1
    ADC #$00 ; Add carry
    STA src_pointer+1
    BRA LutLoop
    
LutDone
    ; Go back to I/O page 0
    STZ MMU_IO_CTRL 

    RTS

TX_GAMETITLE
.text "rainbowtext demo by haydenkale"
.byte 0 ; null term
.endlogical

; Emitted with 
;     D:\repos\fnxapp\BitmapEmbedder\x64\Release\BitmapEmbedder.exe D:\repos\fnxapp\rainbowtext\tinyvicky\rsrc\rainbowtext.bmp D:\repos\fnxapp\rainbowtext\tinyvicky\rsrc\colors.s D:\repos\fnxapp\rainbowtext\tinyvicky\rsrc\pixmap.s --halfsize

.if TARGETFMT = "hex"
* = $010000
.endif
.if TARGETFMT = "bin"
* = $010000-$800
.endif
.logical $10000
.include "rsrc/pixmap.s"
.endlogical

; Write the system vectors
.if TARGETFMT = "hex"
* = $00FFF8
.endif
.if TARGETFMT = "bin"
* = $00FFF8-$800
.endif
.logical $FFF8
.byte $00
F256_DUMMYIRQ       ; Abort vector
    RTI

.word F256_DUMMYIRQ ; nmi
.word F256_RESET    ; reset
.word F256_DUMMYIRQ ; irq
.endlogical