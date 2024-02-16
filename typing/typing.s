.cpu "65816"                        ; Tell 64TASS that we are using a 65816

.include "includes/TinyVicky_Def.asm"
.include "includes/interrupt_def.asm"
.include "includes/f256jr_registers.asm"
.include "includes/f256k_registers.asm"
.include "includes/macros.s"

dst_pointer = $30
src_pointer = $32
text_memory_pointer = $38 ; 16bit
fallen_to_bottom = $3A  ; unused right now
need_score_update = $3B ; could be a flag
animation_index = $3F

letter0_ascii = $40
letter0_pos = $41

score = $48

; Code
* = $000000 
        .byte 0

* = $4000
.logical $4000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

F256_RESET
    CLC     ; disable interrupts
    SEI
    LDX #$FF
    TXS     ; initialize stack

    ; initialize mmu
    STZ MMU_MEM_CTRL
    LDA MMU_MEM_CTRL
    ORA #MMU_EDIT_EN

    ; enable mmu edit, edit mmu lut 0, activate mmu lut 0
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
    STA MMU_MEM_CTRL  ; disable mmu edit, use mmu lut 0

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

MAIN
    LDA #MMU_EDIT_EN
    STA MMU_MEM_CTRL
    STZ MMU_IO_CTRL 
    STZ MMU_MEM_CTRL    
    LDA #(Mstr_Ctrl_Text_Mode_En|Mstr_Ctrl_Text_Overlay|Mstr_Ctrl_Graph_Mode_En|Mstr_Ctrl_Bitmap_En)
    STA @w MASTER_CTRL_REG_L 
    LDA #(Mstr_Ctrl_Text_XDouble|Mstr_Ctrl_Text_YDouble)
    STA @w MASTER_CTRL_REG_H

    ; Disable the cursor
    LDA VKY_TXT_CURSOR_CTRL_REG
    AND #$FE
    STA VKY_TXT_CURSOR_CTRL_REG
    
    JSR ClearScreen        
             
    ; Clear to magenta
    LDA #$FF
    STA $D00D ; Background red channel
    LDA #$00
    STA $D00E ; Background green channel
    LDA #$FF
    STA $D00F ; Background blue channel

    ; Turn off the border
    STZ VKY_BRDR_CTRL
    
    STZ TyVKY_BM0_CTRL_REG ; Make sure bitmap 0 is turned off
    STZ TyVKY_BM1_CTRL_REG ; Make sure bitmap 1 is turned off
    STZ TyVKY_BM2_CTRL_REG ; Make sure bitmap 2 is turned off
    
    ; Initialize matrix keyboard
    LDA   #$FF
    STA   VIA_DDRB
    LDA   #$00
    STA   VIA_DDRA
    STZ   VIA_PRB
    STZ   VIA_PRA
    
    ; Initialize RNG
    LDA #1
    STA $D6A6 
    
    STZ animation_index
    LDA #123
    STA score
    STZ score+1
    STZ need_score_update
    
    CLC     ; disable interrupts
    SEI
    CLC ; Try entering native mode
    XCE
    setxl
    JSR NewLetter
    SEC      ; Go back to emulation mode
    XCE    
    CLI ; Enable interrupts again
    
    ; Initialize IRQ
    JSR Init_IRQHandler     
    
    LDA #$02 ; Set I/O page to 2
    STA MMU_IO_CTRL
    
    ; Put text at the top left of the screen
    LDA #<VKY_TEXT_MEMORY
    STA text_memory_pointer
    LDA #>VKY_TEXT_MEMORY
    STA text_memory_pointer+1    
        
Poll

Lock
    ; Check for key    
    LDA #$00 ; Need to be on I/O page 0
    STA MMU_IO_CTRL
    
    JSR CheckKeys
    BNE DoneCheckInput
    
    CLC     ; disable interrupts
    SEI
    CLC ; Try entering native mode
    XCE
    setxl
    JSR EraseLetter ; If they pressed the 'A' key, erase the 'A' letter.
    JSR PrintScore
    SEC      ; Go back to emulation mode
    XCE    
    CLI ; Enable interrupts again

    JMP DoneCheckInput
        
DoneCheckInput

    ; SOF handler will update animation_index behind the scenes.
    LDA animation_index
    BNE Lock
    ; Unblocked. Reset for next frame
    LDA #$9
    STA animation_index

    CLC     ; disable interrupts
    SEI
    CLC ; Try entering native mode
    XCE
    setxl
    JSR LetterFall
    JSR UpdateScore
    JSR PrintScore
    SEC      ; Go back to emulation mode
    XCE    
    CLI ; Enable interrupts again
   
    JMP Poll    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckKeys ; TODO: compact this
    LDA letter0_ascii
    CMP #65
    BEQ CheckA
    CMP #66
    BEQ CheckB
    CMP #67
    BEQ CheckC
    CMP #68
    BEQ CheckD
    RTS

CheckA
    LDA #(1 << 2 ^ $FF) ; 'A' is PB2, PA1
    STA VIA_PRB
    LDA VIA_PRA
    CMP #(1 << 1 ^ $FF)
    RTS

CheckB
    LDA #(1 << 4 ^ $FF) ; 'B' is PB4, PA3
    STA VIA_PRB
    LDA VIA_PRA
    CMP #(1 << 3 ^ $FF)
    RTS

CheckC
    LDA #(1 << 4 ^ $FF) ; 'C' is PB4, PA2
    STA VIA_PRB
    LDA VIA_PRA
    CMP #(1 << 2 ^ $FF)
    RTS

CheckD
    LDA #(1 << 2 ^ $FF) ; 'C' is PB2, PA2
    STA VIA_PRB
    LDA VIA_PRA
    CMP #(1 << 2 ^ $FF)
    RTS
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NewLetter
    LDY #40
    JSR RandModY16Bit
    TYA
    STA letter0_pos
    STZ letter0_pos+1

    LDY #4 ;#26
    JSR RandModY16Bit
    TYA
    CLC
    ADC #65
    STA letter0_ascii
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EraseLetter
    LDA #$02 ; Set I/O page to 2
    STA MMU_IO_CTRL
    
    ; Print a space to cover up the falling character
    LDY letter0_pos ; 16bit type                   
    LDA #32                        
    STA (text_memory_pointer),Y
        
    STZ MMU_IO_CTRL 
    JSR NewLetter

    LDA #1
    STA need_score_update

    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LetterFall
    LDA #$02 ; Set I/O page to 2
    STA MMU_IO_CTRL
    
    ;;;;;;;;;;;;;;;;
    ; Print a space to cover up the falling character
    LDY letter0_pos                   
    LDA #32                        
    STA (text_memory_pointer),Y

    ; Increment the character pos, to move 1 row lower
    setal
    TYA
    CLC
    ADC #$28
    STA letter0_pos

    ; Check if it's fallen to the bottom
    setas
    CPY #$4AF
    BPL FallenToBottom
    STZ fallen_to_bottom
    
    ; Print the fallen character
    LDY letter0_pos                  ; Y reg contains position of character    
    LDA letter0_ascii                ; Load the character to print
    STA (text_memory_pointer),Y
    BRA DoneLetterFall
    ;;;;;;;;;;;

FallenToBottom
    LDA #1
    STA fallen_to_bottom

DoneLetterFall
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UpdateScore
    LDA need_score_update
    BEQ outline_DoneScoreUpdate
    LDY score
    INY
    STY score
    STZ need_score_update
outline_DoneScoreUpdate
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintScore    
    LDA #$2 ; Set I/O page to 2
    STA MMU_IO_CTRL    
    LDY #28

    LDA #'S'
    STA (text_memory_pointer),Y
    INY
    LDA #'C'
    STA (text_memory_pointer),Y
    INY
    LDA #'O'
    STA (text_memory_pointer),Y
    INY
    LDA #'R'
    STA (text_memory_pointer),Y
    INY
    LDA #'E'
    STA (text_memory_pointer),Y
    INY
    LDA #':'
    STA (text_memory_pointer),Y    
    
    LDA #$0 ; Set I/O page to 0- needed for fixed function math
    STA MMU_IO_CTRL        

    LDY score
    LDX #5

EachDigitToAscii
    STY $DE06   ; Fixed function numerator
    LDY #10
    STY $DE04   ; Fixed function denomenator    
    LDA $DE16   ; Load the remainder
    CLC
    ADC #'0'    ; Turn into ASCII and save to stack
    PHA
    LDY $DE14   ; Load the quotient
    DEX
    BNE EachDigitToAscii
        
    LDA #$2 ; Set I/O page to 2
    STA MMU_IO_CTRL    

    LDY #$22
    LDX #5
CopyEachDigit
    PLA
    STA (text_memory_pointer),Y
    INY
    DEX
    BNE CopyEachDigit

    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RandModY16Bit
    ; Precondition: Y contains the value to mod by.
    ; Postcondition: Y contains the result. X is scrambled

    LDX $D6A4 ; Load 16bit random value

    STX $DE06   ; Fixed function numerator
    STY $DE04   ; Fixed function denomenator    
    LDY $DE16   ; Load the remainder

    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
    STA MMU_IO_CTRL 
    RTS

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

    ; Advance frame
    LDA animation_index
    BEQ IRQ_Handler_Done
    DEC A
    STA animation_index

IRQ_Handler_Done
    ; Restore the I/O page
    PLA
    STA MMU_IO_CTRL
    
    PLY
    PLX
    PLA
    PLP
    RTI

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ClearScreen
    LDA MMU_IO_CTRL ; Back up I/O page
    PHA
    
    LDA #$02 ; Set I/O page to 2
    STA MMU_IO_CTRL
    
    STZ dst_pointer
    LDA #$C0
    STA dst_pointer+1

ClearScreen_ForEach
    LDA #32 ; Character 0
    STA (dst_pointer)
        
    CLC
    LDA dst_pointer
    ADC #$01
    STA dst_pointer
    LDA dst_pointer+1
    ADC #$00 ; Add carry
    STA dst_pointer+1

    CMP #$C5
    BNE ClearScreen_ForEach
    
    PLA
    STA MMU_IO_CTRL ; Restore I/O page
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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