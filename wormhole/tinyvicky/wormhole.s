.cpu "65816"                        ; Tell 64TASS that we are using a 65816

.include "includes/TinyVicky_Def.asm"
.include "includes/interrupt_def.asm"
.include "includes/f256jr_registers.asm"
.include "includes/macros.s"

dst_pointer = $30
src_pointer = $32
column = $34
bm_bank = $35
line = $40
CursorColor = $48

; Code
* = $000000 
        .byte 0

* = $00E000
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
    LDA MMU_IO_CTRL ; Back up MMU page state
    PHA

    STZ $E073
    STZ $4B
    LDA #$C0
    STA $E074
    STA $4C
    LDA #$02 ; Switch to page 2
    STA MMU_IO_CTRL
    LDX #$20

    JSR Fn_E071
    STZ $E073
    LDA #$C0
    STA $E074
    LDA #$03 ; Switch to page 3
    STA MMU_IO_CTRL
    LDX $48

    JSR Fn_E071

    PLA
    STA MMU_IO_CTRL ; Restore MMU page state
    PLX
    PLA
    RTS

Fn_E071
    TXA
    STA $1234
    INC $E073
    BNE LE07A
    INC $E074

LE07A
    LDA $E073
    CMP #$C0

    BNE Fn_E071

    LDA $E074
    CMP #$D2

    BNE Fn_E071
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
    RTS ; Exit if null term

CheckControlCodes
    CMP #$02            ; ctrl-f/set cursor foreground color
    BNE CheckControlCodes_Cond0
    LDA CursorColor
    AND #$F0
    STA CursorColor
    JSR GetNextByte
    ORA CursorColor
    STA CursorColor
    BRA NextByte

CheckControlCodes_Cond0
    CMP #$03
    BNE CheckControlCodes_Cond1 
    JSR $E0E1 ; GetNextByte
    STA CursorColor
    BRA NextByte
    
CheckControlCodes_Cond1
    CMP #$06    ; ctrl-f/set cursor foreground color
    BNE CheckControlCodes_Cond2
    LDA CursorColor
    AND #$0F
    STA CursorColor
    JSR GetNextByte
    ASL
    ASL
    ASL
    ASL
    ORA CursorColor
    STA CursorColor
    BRA NextByte

CheckControlCodes_Cond2
    CMP #$0C

    BNE CheckControlCodes_Cond3 
    JSR ClearScreen
    BRA NextByte
CheckControlCodes_Cond3
    RTS

GetNextByte
    INY
    BNE CheckControlCodes_Cond4
    INC $31 ; $e6, $31

CheckControlCodes_Cond4
    LDA ($30), y ; (TempSrc),y
    RTS    
.endlogical

; Entrypoint
* = $00E5D5 
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

    CLI
    JMP MAIN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

INNERIMPL       .proc
    LDA VKY_GR_CLUT_0, X        ; Load pe[pre]
    STA VKY_GR_CLUT_0, Y        ; Store it in pe[cur]
    INX
    INY
    LDA VKY_GR_CLUT_0, X
    STA VKY_GR_CLUT_0, Y
    INX
    INY
    LDA VKY_GR_CLUT_0, X
    STA VKY_GR_CLUT_0, Y
    INX
    INY
    LDA VKY_GR_CLUT_0, X
    STA VKY_GR_CLUT_0, Y

    ; Now decrement pre and cur
    DEX
    DEX
    DEX
    DEX
    DEX
    DEX
    DEX

    DEY
    DEY
    DEY
    DEY
    DEY
    DEY
    DEY
    RTS
    .pend

OnStartOfFrame

    ; This handler completes palette rotation in four parts. The four parts can run
    ; separately from each other so it'd be possible to cleanly separate each one
    ; out along functional lines. But since each function would be called once
    ; I inline them.
    
    ; For each channel, 
    ;     Back up pe[30..45], the previous palette entries.

    
    CLC ; Try entering native mode
    XCE
    
    .al
    .xl
    REP #$30
    
    LDX #0
    LDY #30*4
LOOP1
    LDA VKY_GR_CLUT_0,Y 
    STA @w regb,X 
    INY
    LDA VKY_GR_CLUT_0,Y
    STA @w regg,X
    INY
    LDA VKY_GR_CLUT_0,Y
    STA @w regr,X
    INY
    INY         ; Alpha ignored
                
    INX
    CPX #15
    BNE LOOP1  

    ; For each channel,
    ;     Overwrite pe[30..230] with pe[45..255].
    ;    
    LDX #30*4
    LDY #45*4
LOOP2
    LDA VKY_GR_CLUT_0,Y
    STA VKY_GR_CLUT_0,X
    INX
    INY
    LDA VKY_GR_CLUT_0,Y
    STA VKY_GR_CLUT_0,X
    INX
    INY
    LDA VKY_GR_CLUT_0,Y
    STA VKY_GR_CLUT_0,X
    INX
    INY
    INX        ; Alpha ignored     
    INY             
    CPX #$3C0 ; 240 * 4
    BNE LOOP2

    ; For each channel,
    ;     Take the old pe[30..45] that we backed up and store it at the end.
    ;     In other words, 
    ;     pe[k+240] = reg[k];
    ;
    LDX #0
    LDY #240*4
LOOP3
    LDA regb,X
    STA VKY_GR_CLUT_0,Y
    INY
    LDA regg,X
    STA VKY_GR_CLUT_0,Y
    INY
    LDA regr,X
    STA VKY_GR_CLUT_0,Y
    INY
    INY ; Alpha ignored

    INX
    CPX #15
    BNE LOOP3

    ; Now the last part. The reg buffers are not needed any more.
    ; Keep shifting pallette entries, replacing the color at N with the color at N-1,
    ; using modulus math at the boundaries.
    ; Note that this rolls a loop that the original sample doesn't.
    ;
    ; Pseudo-code:
    ; for(i=0;i<15;i++)
    ; {
    ;     int k = i + 2;
    ;
    ;     int cur = 15 * k + 14;
    ;     int pre = cur - 1;
    ;
    ;     tmp = pe[cur];
    ;     for(j=0; j<14; j++)
    ;     {
    ;         pe[cur] = pe[pre];
    ;         cur--;
    ;         pre--;
    ;     }
    ;     pe[pre] = tmp;
    ; }
    LDX #$0
    LDY #$0
    STX @w iter_i ; i=0

LOOP4
    setal
    LDA @w indcache, X         ; cur=indcache[i] 
    TAY
    DEC A
    DEC A
    DEC A
    DEC A
    TAX                     ; pre stored in X
    setas
    ; pre and cur indices are stored in X and Y now.

    ; tmp = pe[cur];
    LDA VKY_GR_CLUT_0, Y
    STA @w tmpr
    INY
    LDA VKY_GR_CLUT_0, Y
    STA @w tmpg
    INY
    LDA VKY_GR_CLUT_0, Y
    STA @w tmpb
    ; Alpha ignored
    DEY
    DEY

    ; Initialize the inner loop
    LDA #14
    STA @w iter_j; j=14
INNER
    ; Unfortunately, need a function here because otherwise the branch from 
    ; the end of the loop back to LOOP4 is too long
    JSR INNERIMPL

    DEC @w iter_j   ; j--
    BNE INNER

    INX
    INX
    INX
    INX

    ; pe[pre] = tmp;
    LDA @w tmpr
    STA VKY_GR_CLUT_0, X
    INX
    LDA @w tmpg
    STA VKY_GR_CLUT_0, X
    INX
    LDA @w tmpb
    STA VKY_GR_CLUT_0, X

    ; Variable iter_i is used as an offset into an array whose element size is
    ; 2, so it gets incremented by 2.
    INC @w iter_i ; Check if i>15, for outer loop
    INC @w iter_i
    LDX @w iter_i
    CPX @w #30
    BNE LOOP4

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    .as
    .xs
    REP #$20 ; Need to do this
    SEC      ; Go back to emulation mode
    XCE
    
UpdateLutDone
    RTS

; Easier to simply not have to do this programmatically.
indcache .word 176, 236, 296, 356, 416, 476, 536, 596, 656, 716, 776, 836, 896, 956, 1016

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
        
    ; Switch to I/O page 1
    LDA #1
    STA MMU_IO_CTRL

    JSR OnStartOfFrame    

    ; Restore to I/O page 1
    STZ MMU_IO_CTRL

    ; Clear the flag for start-of-frame
    STA INT_PENDING_REG0

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

* = $00E800
.logical $E800
.include "rsrc/colors.s"
.endlogical

* = $00EF07
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

    JSR CopyLutToDevice

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

Lock
    JMP Lock

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CopyLutToDevice
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
    LDA #0
    STA MMU_IO_CTRL 
    RTS

; String for stylized title
TX_GAMETITLE
.text "Test text"
.byte 0 ; null term
.endlogical

; Emitted with 
;     D:\repos\fnxapp\BitmapEmbedder\x64\Release\BitmapEmbedder.exe D:\repos\fnxapp\wormhole\tinyvicky\rsrc\wormhole.bmp D:\repos\fnxapp\wormhole\tinyvicky\rsrc\colors.s D:\repos\fnxapp\wormhole\tinyvicky\rsrc\pixmap.s --halfsize

* = $10000
.logical $10000
.include "rsrc/pixmap.s"
.endlogical

; Write the system vectors
* = $00FFF8
.logical $FFF8
.byte $00
F256_DUMMYIRQ       ; Abort vector
    RTI

.word F256_DUMMYIRQ ; nmi
.word F256_RESET    ; reset
.word F256_DUMMYIRQ ; irq
.endlogical