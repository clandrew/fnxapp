.cpu "65816"                        ; Tell 64TASS that we are using a 65816

.include "includes/TinyVicky_Def.asm"
.include "includes/interrupt_def.asm"
.include "includes/f256jr_registers.asm"
.include "includes/f256k_registers.asm"
.include "includes/macros.s"

dst_pointer = $30
src_pointer = $32
tone = $34
sound_enabled = $36
text_memory_pointer = $38
keys_cur = $3A
keys_next = $3B

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
    
    LDA #$02 ; Set I/O page to 2
    STA MMU_IO_CTRL
    
    ; Put text at the top left of the screen
    LDA #<VKY_TEXT_MEMORY
    STA text_memory_pointer
    LDA #>VKY_TEXT_MEMORY
    STA text_memory_pointer+1

    LDA #<TX_PROMPT
    STA src_pointer

    LDA #>TX_PROMPT
    STA src_pointer+1
    
    JSR PrintAnsiString

    LDA #$8E
    STA tone
    LDA #$1F
    STA tone+1
    STZ sound_enabled
    STZ keys_cur
    STZ keys_next
        
Poll
    
    ; Place the four-digit number and print it
    LDA #(<VKY_TEXT_MEMORY + $20)
    STA text_memory_pointer
    LDA #((>VKY_TEXT_MEMORY) + $00)
    STA text_memory_pointer+1
    JSR PrintFourDigitHexNumber

    ; Check for key    
    LDA #$00 ; Need to be on I/O page 0
    STA MMU_IO_CTRL
    
    ; Space is PB4, PA7
    LDA #(1 << 4 ^ $FF)
    STA VIA_PRB
    LDA VIA_PRA
    CMP #(1 << 7 ^ $FF)

    LDA keys_cur
    ORA #$1
    STA keys_cur
    BEQ OnSpacePress

    JMP Poll
    
OnSpacePress
    LDA sound_enabled
    BEQ EnableSound
    BRA DisableSound
EnableSound
    lda #$90 ; %10010000 = Channel 1 attenuation = 0
    sta $D600 ; Send it to left PSG
    sta $D610 ; Send it to right PSG
    lda #$8E ; %10001100 = Set the low 4 bits of the frequency code
    sta $D600 ; Send it to left PSG
    sta $D610 ; Send it to right PSG
    lda #$1F ; %00001111 = Set the high 6 bits of the frequency
    sta $D600 ; Send it to left PSG
    sta $D610 ; Send it to right PSG
    LDA #$01
    STA sound_enabled
    JMP Poll
DisableSound
    lda #$9F ; %10011111 = Channel 1 attenuation = 15 (silence)
    sta $D600 ; Send it to left PSG
    sta $D610 ; Send it to right PSG    
    STZ sound_enabled
    JMP Poll    

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

; Pre-condition: 
;     text_memory_pointer is set as desired dest address
;     src_pointer is set as source address
PrintAnsiString
    LDX #$00
    LDY #$00
    
    LDA MMU_IO_CTRL ; Back up I/O page
    PHA
    
    LDA #$02 ; Set I/O page to 2
    STA MMU_IO_CTRL

PrintAnsiString_EachCharToTextMemory
    LDA (src_pointer),y                          ; Load the character to print
    BEQ PrintAnsiString_DoneStoringToTextMemory  ; Exit if null term        
    STA (text_memory_pointer),Y                  ; Store character to text memory
    INY
    BRA PrintAnsiString_EachCharToTextMemory

PrintAnsiString_DoneStoringToTextMemory

    LDA #$03 ; Set I/O page to 3
    STA MMU_IO_CTRL

    LDA #$F0 ; Text color

PrintAnsiString_EachCharToColorMemory
    DEY
    STA (text_memory_pointer),Y
    BNE PrintAnsiString_EachCharToColorMemory

    PLA
    STA MMU_IO_CTRL ; Restore I/O page

    RTS   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PrintHexDigitImpl
; Precondition: Hex value is in X.
;               text_memory_pointer,Y is the desired output location.
; Postcondition:
;               Y is updated.
;               A is scrambled.
;   
    TXA
    AND #$F0
    LSR
    LSR
    LSR
    LSR
    CLC
    PHY
    TAY
    LDA TX_HEX,Y
    PLY
    STA (text_memory_pointer),Y
    INY
    
    TXA
    AND #$0F
    PHY
    TAY
    LDA TX_HEX,Y
    PLY
    STA (text_memory_pointer),Y
    INY
    RTS
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PrintFourDigitHexNumber

    LDA MMU_IO_CTRL ; Back up I/O page
    PHA

    LDA #$02 ; Set I/O page to 2
    STA MMU_IO_CTRL

    LDX tone+1
    JSR PrintHexDigitImpl
    LDX tone
    JSR PrintHexDigitImpl    

    LDA #$03 ; Set I/O page to 3
    STA MMU_IO_CTRL
    
    LDA #$F0 ; Text color
    DEY
    STA (text_memory_pointer),Y
    DEY
    STA (text_memory_pointer),Y
    DEY
    STA (text_memory_pointer),Y
    DEY
    STA (text_memory_pointer),Y

    PLA
    STA MMU_IO_CTRL ; Restore I/O page
    RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TX_PROMPT
.text "Press 'space' to play a tone."
.byte 0 ; null term

TX_RESPONSE
.text "Playing: 0x1F8E"
.byte 0 ; null term

TX_HEX
.text "0123456789ABCDEF" ; Because I'm too lazy

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