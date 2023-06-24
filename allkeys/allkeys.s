.cpu "65816"                        ; Tell 64TASS that we are using a 65816

.include "includes/TinyVicky_Def.asm"
.include "includes/interrupt_def.asm"
.include "includes/f256jr_registers.asm"
.include "includes/f256k_registers.asm"
.include "includes/macros.s"

dst_pointer = $30
src_pointer = $32
string_table = $34
text_memory_pointer = $38

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
    ; Do we need to set DDR to FF,00?

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
    
    ; Put next text lower down
    LDA #(<VKY_TEXT_MEMORY + $80)
    STA text_memory_pointer
    LDA #((>VKY_TEXT_MEMORY) + $00)
    STA text_memory_pointer+1
    
    LDA #<STRINGTABLE_PB4
    STA string_table
    LDA #>STRINGTABLE_PB4
    STA string_table+1
        
Poll
    ; Check for key    
    LDA #$00 ; Need to be on I/O page 0
    STA MMU_IO_CTRL

    ; Check all PB4s 
    LDA #(1 << 4 ^ $FF)
    STA VIA_PRB
    LDA VIA_PRA
    JSR GetStringTableOffsetForSingleBitCleared
    
    CMP #$FF
    BEQ Poll

    TAY
    LDA (string_table),Y
    STA src_pointer
    INY
    LDA (string_table),Y
    STA src_pointer+1
    JSR PrintAnsiString

DoneCheckInput   
    JMP Poll
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetStringTableOffsetForSingleBitCleared
    ; Arg in A
    ; return value in A
GetStringTableOffsetForSingleBitCleared_Check0
    CMP #(1 << 0 ^ $FF)
    BNE GetStringTableOffsetForSingleBitCleared_Check1
    LDA #0
    RTS

GetStringTableOffsetForSingleBitCleared_Check1
    CMP #(1 << 1 ^ $FF)
    BNE GetStringTableOffsetForSingleBitCleared_Check2
    LDA #2
    RTS

GetStringTableOffsetForSingleBitCleared_Check2
    CMP #(1 << 2 ^ $FF)
    BNE GetStringTableOffsetForSingleBitCleared_Check3
    LDA #4
    RTS

GetStringTableOffsetForSingleBitCleared_Check3
    CMP #(1 << 3 ^ $FF)
    BNE GetStringTableOffsetForSingleBitCleared_Check4
    LDA #6
    RTS

GetStringTableOffsetForSingleBitCleared_Check4
    CMP #(1 << 4 ^ $FF)
    BNE GetStringTableOffsetForSingleBitCleared_Check5
    LDA #8
    RTS

GetStringTableOffsetForSingleBitCleared_Check5
    CMP #(1 << 5 ^ $FF)
    BNE GetStringTableOffsetForSingleBitCleared_Check6
    LDA #10
    RTS

GetStringTableOffsetForSingleBitCleared_Check6
    CMP #(1 << 6 ^ $FF)
    BNE GetStringTableOffsetForSingleBitCleared_Check7
    LDA #12
    RTS

GetStringTableOffsetForSingleBitCleared_Check7
    CMP #(1 << 7 ^ $FF)
    BNE GetStringTableOffsetForSingleBitCleared_None
    LDA #14
    RTS

GetStringTableOffsetForSingleBitCleared_None
    LDA #$FF
    RTS

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

TX_PROMPT
.null "Last key pressed:"

TX_SPACE                .null "Space     "
TX_A                    .null "A         "
TX_B                    .null "B         "
TX_C                    .null "C         "
TX_D                    .null "D         "
TX_E                    .null "E         "
TX_F                    .null "F         "
TX_G                    .null "G         "
TX_H                    .null "H         "
TX_I                    .null "I         "
TX_J                    .null "J         "
TX_K                    .null "K         "
TX_L                    .null "L         "
TX_M                    .null "M         "
TX_N                    .null "N         "
TX_O                    .null "O         "
TX_P                    .null "P         "
TX_Q                    .null "Q         "
TX_R                    .null "R         "
TX_S                    .null "S         "
TX_T                    .null "T         "
TX_U                    .null "U         "
TX_V                    .null "V         "
TX_W                    .null "W         "
TX_X                    .null "X         "
TX_Y                    .null "Y         "
TX_Z                    .null "Z         "
TX_PERIOD               .null ".         "
TX_RIGHTSHIFT           .null "RightShift"
TX_F1                   .null "F1        "
TX_F3                   .null "F3        "
TX_F5                   .null "F5        "
TX_F7                   .null "F7        "
TX_FOENIX               .null "Foenix    "
TX_COLON                .null ":         "
TX_ALT                  .null "Alt       "

STRINGTABLE_PB4
.word TX_F1
.word TX_Z
.word TX_C
.word TX_B
.word TX_M
.word TX_PERIOD
.word TX_RIGHTSHIFT
.word TX_SPACE

STRINGTABLE_PB5
.word TX_FOENIX
.word TX_S
.word TX_F
.word TX_H
.word TX_K
.word TX_COLON
.word TX_ALT
.word TX_F3

STRINGTABLE_ALL
.word STRINGTABLE_PB4
.word STRINGTABLE_PB4
.word STRINGTABLE_PB4
.word STRINGTABLE_PB4
.word STRINGTABLE_PB4
.word STRINGTABLE_PB5
.word STRINGTABLE_PB5
.word STRINGTABLE_PB5

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