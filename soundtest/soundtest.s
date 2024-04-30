.cpu "65816"                        ; Tell 64TASS that we are using a 65816

.include "includes/TinyVicky_Def.asm"
.include "includes/interrupt_def.asm"
.include "includes/f256jr_registers.asm"
.include "includes/f256k_registers.asm"
.include "includes/macros.s"

dst_pointer = $30
src_pointer = $32
up_arrow_cur = $34
up_arrow_next = $35
down_arrow_cur = $36
down_arrow_next = $37
left_arrow_cur = $38
left_arrow_next = $39
right_arrow_cur = $3A
right_arrow_next = $3B
text_memory_pointer = $3C

volume = $46
tone = $48

; PGZ header
* =  0
                ; Place the one-byte PGZ signature before the code section
                .text "Z"           
                .long MAIN_SEGMENT_START               
                
                ; Three-byte segment size. Make sure the size DOESN'T include this metadata.
                .long MAIN_SEGMENT_END - MAIN_SEGMENT_START 

                ; Note that when your executable is loaded, *only* the data segment after the metadata is loaded into memory. 
                ; The 'Z' signature above, and the metadata isn't loaded into memory.


; Code
.logical $4000
MAIN_SEGMENT_START

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ENTRYPOINT
    CLC     ; disable interrupts
    SEI

    LDA #$B3           ; EDIT_EN=true, EDIT_LUT=3, ACT_LUT=3
    STA MMU_MEM_CTRL
    LDA #$07
    STA MMU_MEM_BANK_7 ; map the last bank    
    LDA #$3            ; EDIT_EN=false, EDIT_LUT=0, ACT_LUT=3
    
    STA MMU_MEM_CTRL    

    JMP MAIN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MAIN
    ; Initialize graphics mode
    STZ MMU_IO_CTRL
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
    
    ; Initialize text memory pointer
    LDA #<VKY_TEXT_MEMORY
    STA text_memory_pointer
    LDA #>VKY_TEXT_MEMORY
    STA text_memory_pointer+1   
    
    STZ down_arrow_cur
    STZ down_arrow_next
    STZ up_arrow_cur
    STZ up_arrow_next
    STZ volume       
    LDA #252 
    STA tone
    STZ tone+1
    
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
        
    use_mode16 
    JSR SaveToneValueToAscii
    JSR ClearScreenCharacterColorsNative
    JSR ClearScreenCharactersNative
    JSR PrintHeader
    JSR PrintVolumeStatus
    JSR PrintToneStatus
    use_mode8

    JSR SetSoundOnDevice
        
Poll
    JSR HandleDownArrow
    JSR HandleUpArrow
    JSR HandleLeftArrow
    JSR HandleRightArrow
    JMP Poll

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HandleDownArrow
    STZ MMU_IO_CTRL ; Need to be on I/O page 0

    ; Check for down key
    LDA #(1 << 0 ^ $FF)
    STA VIA1_PRA
    LDA VIA0_PRB
    CMP #(1 << 7 ^ $FF)
    BNE DownArrow_NotPressed
DownArrow_Pressed
    LDA #$FF
    BRA DownArrow_DonePoll
DownArrow_NotPressed
    LDA #$00
DownArrow_DonePoll
    STA down_arrow_next
    CMP #$00                ; If the key was pressed and now it's not anymore
    BNE DownArrow_DoneAll
    LDA down_arrow_cur
    CMP #$FF
    BNE DownArrow_DoneAll    

    use_mode16
    LDA volume
    BEQ AfterDecreaseVolume
    DEC volume
    JSR OnVolumeChanged
AfterDecreaseVolume
    use_mode8
    
DownArrow_DoneAll
    LDA down_arrow_next
    STA down_arrow_cur

    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HandleUpArrow
    STZ MMU_IO_CTRL ; Need to be on I/O page 0    
    ; Check for up key. PA0, PB7
    LDA #(1 << 0 ^ $FF)
    STA VIA1_PRA
    LDA VIA1_PRB
    CMP #(1 << 7 ^ $FF)
    BNE UpArrow_NotPressed
UpArrow_Pressed
    LDA #$FF
    BRA UpArrow_DonePoll
UpArrow_NotPressed
    LDA #$00
UpArrow_DonePoll
    STA up_arrow_next
    CMP #$00                ; If the key was pressed and now it's not anymore
    BNE UpArrow_DoneAll
    LDA up_arrow_cur
    CMP #$FF
    BNE UpArrow_DoneAll    
    
    use_mode16
    LDA volume
    CMP #15
    BPL AfterIncreaseVolume
    INC volume
    JSR OnVolumeChanged
AfterIncreaseVolume
    use_mode8
    
UpArrow_DoneAll
    LDA up_arrow_next
    STA up_arrow_cur

    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HandleLeftArrow
    STZ MMU_IO_CTRL ; Need to be on I/O page 0    
    ; Check for left key. PA0, PB7
    LDA #(1 << 0 ^ $FF)
    STA VIA1_PRA
    LDA VIA1_PRB
    CMP #(1 << 2 ^ $FF)
    BNE LeftArrow_NotPressed
LeftArrow_Pressed
    LDA #$FF
    BRA LeftArrow_DonePoll
LeftArrow_NotPressed
    LDA #$00
LeftArrow_DonePoll
    STA left_arrow_next
    CMP #$00                ; If the key was pressed and now it's not anymore
    BNE LeftArrow_DoneAll
    LDA left_arrow_cur
    CMP #$FF
    BNE LeftArrow_DoneAll    
    
    use_mode16  
    LDX tone
    DEX
    STX tone
    JSR OnToneChanged

    use_mode8
    
LeftArrow_DoneAll
    LDA left_arrow_next
    STA left_arrow_cur

    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HandleRightArrow
    STZ MMU_IO_CTRL ; Need to be on I/O page 0 
    LDA #(1 << 6 ^ $FF)
    STA VIA1_PRA
    LDA VIA0_PRB
    CMP #(1 << 7 ^ $FF)
    BNE RightArrow_NotPressed
RightArrow_Pressed
    LDA #$FF
    BRA RightArrow_DonePoll
RightArrow_NotPressed
    LDA #$00
RightArrow_DonePoll
    STA right_arrow_next
    CMP #$00                ; If the key was pressed and now it's not anymore
    BNE RightArrow_DoneAll
    LDA right_arrow_cur
    CMP #$FF
    BNE RightArrow_DoneAll    
    
    use_mode16  
    LDX tone
    INX
    STX tone
    JSR OnToneChanged

    use_mode8
    
RightArrow_DoneAll
    LDA right_arrow_next
    STA right_arrow_cur

    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OnVolumeChanged
    JSR SaveVolumeValueToAscii
    JSR PrintVolumeStatus
    JSR SetSoundOnDevice
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OnToneChanged
    JSR SaveToneValueToAscii
    JSR PrintToneStatus
    JSR SetSoundOnDevice
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SetSoundOnDevice
    LDA #$00 ; Set I/O page to 0
    STA MMU_IO_CTRL

    ; Play sound here ; %10010000 = Channel 1 attenuation = 0, which is the loudest
    LDA volume
    ORA #$90
    sta $D600 ; Send it to down PSG

    ; Grab the lower 4 bits
    LDA tone
    AND #$0F
    ORA #$80
    sta $D600 ; Send it to down PSG

    ; Grab the upper 6 bits
    setal
    LDA tone
    LSR
    LSR
    LSR
    LSR
    setas
    sta $D600 ; Send it to down PSG

    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SaveToneValueToAscii
    LDA #$0 ; Set I/O page to 0- needed for fixed function math
    STA MMU_IO_CTRL        

    LDY tone
    LDX #4

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
    STA TX_TONE
    PLA
    STA TX_TONE+1    
    PLA
    STA TX_TONE+2
    PLA
    STA TX_TONE+3

outline_DoneToneUpdate
    RTS    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SaveVolumeValueToAscii ; It would almost be more compact to have a table.
    LDA volume
    CMP #10
    BMI VolumeUnderTen

VolumeAtLeastTen
    LDA #'1'
    STA TX_VOLUME
    LDA volume
    SEC
    SBC #10
    BRA OnesDigit

VolumeUnderTen
    LDA #'0'
    STA TX_VOLUME
    LDA volume

OnesDigit
    CLC
    ADC #'0' 
    STA TX_VOLUME+1
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PrintHeader
    LDX #TX_HEADER   ; Print string
    STX src_pointer
    LDY #$C000
    STY dst_pointer    
    JSR PrintAscii_ForEach
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintVolumeStatus    
    LDA #$2 ; Set I/O page to 2
    STA MMU_IO_CTRL
    
    LDX #0
    LDY #40*5
PrintVolumeStatus_Loop
    LDA TX_VOLUMESTATUS, X
    STA (text_memory_pointer),Y
    INY
    INX
    CPX #18
    BNE PrintVolumeStatus_Loop

    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintToneStatus    
    LDA #$2 ; Set I/O page to 2
    STA MMU_IO_CTRL
    
    LDX #0
    LDY #40*6
PrintToneStatus_Loop
    LDA TX_TONESTATUS, X
    STA (text_memory_pointer),Y
    INY
    INX
    CPX #18
    BNE PrintToneStatus_Loop

    RTS
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ClearScreenCharactersNative ; The console size here is 40 wide x 30 high.
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
ClearScreenCharacterColorsNative ; The console size here is 40 wide x 30 high.
    stz MMU_IO_CTRL ; Set I/O page to 0

    ; Set foreground #4 to black
    STZ $D810 
    STZ $D811
    STZ $D812

    STZ $D854 ; Set background #5 to black
    STZ $D855
    STZ $D856

    LDA #$03 ; Set I/O page to 3
    STA MMU_IO_CTRL

    LDY #$C000
    STY dst_pointer    
ClearScreenCharacterColorsNative_ForEach
    LDA #$45 ; Color 1
    STA (dst_pointer)
    INY
    STY dst_pointer  
    CPY #$C4B0
    BNE ClearScreenCharacterColorsNative_ForEach

    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PrintAsciiNative
    ; Precondition: src_pointer, dst_pointer are initialized
    ;               src_pointer is set to X
    ;               dst_pointer is set to Y
    ;               X and Y are in 16 bit mode
    
    LDA #$02 ; Set I/O page to 2
    STA MMU_IO_CTRL

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TX_HEADER       .text "***************SOUND TEST***************"
TX_HEADER2      .text " Press up+down arrows to adjust volume. "
TX_HEADER3      .text " Press left+right to adjust tone.       "
.byte 0 ; null term

TX_VOLUMESTATUS .text "Current volume: "
TX_VOLUME  .text "00"

TX_TONESTATUS .text "Current tone: "
TX_TONE  .text "0000"

TX_RESPONSE
.text "Sound playing"
.byte 0 ; null term

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MAIN_SEGMENT_END
.endlogical

; Entrypoint segment metadata
                .long ENTRYPOINT
                .long 0       ; Dummy value to indicate this segment is for declaring the entrypoint.