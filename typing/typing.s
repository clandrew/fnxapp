.cpu "65816"                        ; Tell 64TASS that we are using a 65816

.include "includes/TinyVicky_Def.asm"
.include "includes/interrupt_def.asm"
.include "includes/f256jr_registers.asm"
.include "includes/f256k_registers.asm"
.include "includes/macros.s"

dst_pointer = $30
src_pointer = $32
text_memory_pointer = $38 ; 16bit
need_score_update = $3B ; could be a flag
animation_index = $3F

letter0_ascii = $40
letter0_pos = $41

lives = $47
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
    
    CLC     ; disable interrupts
    SEI
    CLC ; Try entering native mode
    XCE
    setxl
    JSR TitleScreenNative
    SEC      ; Go back to emulation mode
    XCE    
    CLI ; Enable interrupts again
          
    STZ MMU_IO_CTRL
TitleScreenLock
    ; Space is PB4, PA7
    LDA #(1 << 4 ^ $FF)
    STA VIA_PRB
    LDA VIA_PRA
    CMP #(1 << 7 ^ $FF)
    BNE TitleScreenLock
    
    ; Initialize RNG
    LDA #1
    STA $D6A6
    
    STZ animation_index
    LDA #0
    STA score
    STZ score+1
    STZ need_score_update
    LDA #5
    STA lives
    
    CLC     ; disable interrupts
    SEI
    CLC ; Try entering native mode
    XCE
    setxl
    JSR ClearScreenNative
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
    ; Check for keypress
    STZ MMU_IO_CTRL  ; Need to be on I/O page 0
    
    JSR CheckKeys
    BNE DoneCheckInput
    
    CLC     ; disable interrupts
    SEI
    CLC ; Try entering native mode
    XCE
    setxl
    JSR EraseLetter ; If they pressed the 'A' key, erase the 'A' letter.
    JSR PrintHUD
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
    JSR UpdateLives
    JSR PrintHUD
    SEC      ; Go back to emulation mode
    XCE    
    CLI ; Enable interrupts again
   
    JMP Poll    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckKeys
    LDA letter0_ascii
    CLC
    SBC #65
    INA
    TAY
    LDA PBMasks,Y
    STA VIA_PRB
    LDA VIA_PRA
    CMP PAMasks,Y
    RTS

; There isn't much rhyme or reason behind these, so this throws a bunch of data at the problem.
PAMasks
    .byte (1 << 1 ^ $FF) ; A
    .byte (1 << 3 ^ $FF) ; B
    .byte (1 << 2 ^ $FF) ; C
    .byte (1 << 2 ^ $FF) ; D
    .byte (1 << 1 ^ $FF) ; E
    .byte (1 << 2 ^ $FF) ; F
    .byte (1 << 3 ^ $FF) ; G
    .byte (1 << 3 ^ $FF) ; H
    .byte (1 << 4 ^ $FF) ; I
    .byte (1 << 4 ^ $FF) ; J
    .byte (1 << 4 ^ $FF) ; K
    .byte (1 << 5 ^ $FF) ; L
    .byte (1 << 4 ^ $FF) ; M
    .byte (1 << 4 ^ $FF) ; N
    .byte (1 << 4 ^ $FF) ; O
    .byte (1 << 5 ^ $FF) ; P
    .byte (1 << 7 ^ $FF) ; Q
    .byte (1 << 2 ^ $FF) ; R
    .byte (1 << 1 ^ $FF) ; S
    .byte (1 << 2 ^ $FF) ; T
    .byte (1 << 3 ^ $FF) ; U
    .byte (1 << 3 ^ $FF) ; V
    .byte (1 << 1 ^ $FF) ; W
    .byte (1 << 2 ^ $FF) ; X
    .byte (1 << 3 ^ $FF) ; Y
    .byte (1 << 1 ^ $FF) ; Z

PBMasks
    .byte (1 << 2 ^ $FF) ; A
    .byte (1 << 4 ^ $FF) ; B
    .byte (1 << 4 ^ $FF) ; C
    .byte (1 << 2 ^ $FF) ; D
    .byte (1 << 6 ^ $FF) ; E
    .byte (1 << 5 ^ $FF) ; F
    .byte (1 << 2 ^ $FF) ; G
    .byte (1 << 5 ^ $FF) ; H
    .byte (1 << 1 ^ $FF) ; I
    .byte (1 << 2 ^ $FF) ; J
    .byte (1 << 5 ^ $FF) ; K
    .byte (1 << 2 ^ $FF) ; L
    .byte (1 << 4 ^ $FF) ; M
    .byte (1 << 7 ^ $FF) ; N
    .byte (1 << 6 ^ $FF) ; O
    .byte (1 << 1 ^ $FF) ; P
    .byte (1 << 6 ^ $FF) ; Q
    .byte (1 << 1 ^ $FF) ; R
    .byte (1 << 5 ^ $FF) ; S
    .byte (1 << 6 ^ $FF) ; T
    .byte (1 << 6 ^ $FF) ; U
    .byte (1 << 7 ^ $FF) ; V
    .byte (1 << 1 ^ $FF) ; W
    .byte (1 << 7 ^ $FF) ; X
    .byte (1 << 1 ^ $FF) ; Y
    .byte (1 << 4 ^ $FF) ; Z
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NewLetter
    LDA #$0 ; Set I/O page to 0
    STA MMU_IO_CTRL

    LDY #40
    JSR RandModY16Bit

    ; Move down a row so we don't overlap the HUD
    CLC
    TYA
    ADC #$28

    STA letter0_pos
    STZ letter0_pos+1

    LDY #26
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
    
    ; Print the fallen character
    LDY letter0_pos                  ; Y reg contains position of character    
    LDA letter0_ascii                ; Load the character to print
    STA (text_memory_pointer),Y
    BRA DoneLetterFall
    ;;;;;;;;;;;

FallenToBottom
    LDA lives
    DEC A
    BEQ GameOverScreen
    STA lives
    JSR NewLetter

DoneLetterFall
    RTS
    
TX_GAMEOVER .null "G A M E   O V E R"

GameOverScreen
    JSR ClearScreenNative
    ; Print string
    LDX #TX_GAMEOVER
    STX src_pointer
    LDY #$C1C4
    STY dst_pointer    
    JSR PrintAscii_ForEach

GameOverLock
    ; Poll for input xxx
    JMP GameOverLock


;GameOverLock
    ; Poll for space
    ; Space is PB4, PA7
;    LDA #(1 << 4 ^ $FF)
;    STA VIA_PRB
;    LDA VIA_PRA
;    CMP #(1 << 7 ^ $FF)
;    BNE GameOverLock
    ; Unlock here

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PrintAscii
    ; Precondition: src_pointer, dst_pointer are initialized
    ;               src_pointer is set to X
    ;               dst_pointer is set to Y
    ;               X and Y are in 16 bit mode
PrintAscii_ForEach
    LDA (src_pointer)
    BEQ PrintAscii_Done
    STA (dst_pointer)
    INY
    STY dst_pointer
    INX
    STX src_pointer
    BRA PrintAscii_ForEach
PrintAscii_Done
    RTS
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UpdateLives
    LDA #' '
    STA TX_LIVES+0
    STA TX_LIVES+1
    STA TX_LIVES+2
    STA TX_LIVES+3   
    STA TX_LIVES+4    
    STA TX_LIVES+5

    ; Update the display.
    LDY #TX_LIVES
    STY dst_pointer
    setxs
    LDA lives
    BEQ UpdateLives_Done
    TAY

    
UpdateLives_ForEach
    DEY
    LDA #'*'
    STA (dst_pointer), Y
    CPY #0
    BEQ UpdateLives_Done
    BRA UpdateLives_ForEach

UpdateLives_Done
    setxl
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UpdateScore
    LDA need_score_update
    BEQ outline_DoneScoreUpdate
    LDY score
    INY ; Increment score
    STY score
    STZ need_score_update

    ; Update the display too.    
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
          
    PLA
    STA TX_SCORE
    PLA
    STA TX_SCORE+1    
    PLA
    STA TX_SCORE+2
    PLA
    STA TX_SCORE+3
    PLA
    STA TX_SCORE+4

outline_DoneScoreUpdate
    RTS    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TX_HUD .text "LIVES:"
TX_LIVES .text "      SCORE:"
TX_SCORE .text "00000"

PrintHUD    
    LDA #$2 ; Set I/O page to 2
    STA MMU_IO_CTRL
    
    LDX #0
    LDY #16
PrintHUD_Loop
    LDA TX_HUD, X
    STA (text_memory_pointer),Y
    INY
    INX
    CPX #23
    BNE PrintHUD_Loop

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ClearScreenNative ; The console size here is 40 wide x 30 high.
    LDA #$02 ; Set I/O page to 2
    STA MMU_IO_CTRL

    LDY #$C000
    STY dst_pointer    
ClearScreenNative_ForEach
    LDA #32 ; Character 0
    STA (dst_pointer)
    INY
    STY dst_pointer  
    CPY #$C4B0
    BNE ClearScreenNative_ForEach

    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TitleScreenNative
    LDA #$02 ; Set I/O page to 2
    STA MMU_IO_CTRL    
    LDY #$C000
    STY dst_pointer
    LDX #TX_TITLESCREEN
    STX src_pointer
    JSR PrintAscii
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TX_TITLESCREEN
.text "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
.text "XF                                    YX"
.text "X 88888888888                          X"
.text "X     888                              X"
.text "X     888     888                      X"
.text "X     888 888  888 88888b.   .d88b.    X"
.text 'X     888 888  888 888 "88b d8P  Y8b   X'
.text "X     888 888  888 888  888 88888888   X"
.text "X     888 Y88b 888 888 d88P Y8b.       X"
.text 'X     888  "Y88888 88888P"   "Y8888    X'
.text "X              888 888                 X"
.text "X    .d8888b.  888 888                 X"
.text "X   d88P  Y88b 888 888    o            X"
.text "X   Y88b.      888       ,8b           X"
.text 'X    "Y888b.   888888   ,888b   888d88 X'
.text 'X       "Y88b. 888   "Y8888888F"888P"  X'
.text 'X         "888 888     "F8"YF"  888    X'
.text "X   Y88b  d88P Y88b.   d8F T8b  888    X"
.text 'X    "Y8888P"   "Y888 d"     "b 888    X'
.text "X                                      X"
.text "X                                      X"
.text "X                                      X"
.text "X                                      X"
.text "X         Press SPACE to start!        X"
.text "X                                      X"
.text "X                                      X"
.text "X                                      X"
.text "X                                      X"
.text "Xb                                    dX"
.text "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"


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