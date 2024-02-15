.cpu "65816"                        ; Tell 64TASS that we are using a 65816

.include "includes/TinyVicky_Def.asm"
.include "includes/interrupt_def.asm"
.include "includes/f256jr_registers.asm"
.include "includes/f256k_registers.asm"
.include "includes/macros.s"
.include "includes/api.asm"

dst_pointer = $30
src_pointer = $32
animation_index = $34
target_frame = $35
text_memory_pointer = $38

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

event       .dstruct    kernel.event.event_t

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ENTRYPOINT
    JSR ClearScreen
    
    LDA #$00 ; Set I/O page to 0
    STA MMU_IO_CTRL 

    LDA #(Mstr_Ctrl_Text_Mode_En|Mstr_Ctrl_Text_Overlay|Mstr_Ctrl_Graph_Mode_En|Mstr_Ctrl_Bitmap_En)
    STA @w MASTER_CTRL_REG_L 
    LDA #(Mstr_Ctrl_Text_XDouble|Mstr_Ctrl_Text_YDouble)
    STA @w MASTER_CTRL_REG_H

    ; Disable the cursor
    LDA VKY_TXT_CURSOR_CTRL_REG
    AND #$FE
    STA VKY_TXT_CURSOR_CTRL_REG      

    ; Turn off the border
    STZ VKY_BRDR_CTRL
    
    STZ TyVKY_BM0_CTRL_REG ; Make sure bitmap 0 is turned off
    STZ TyVKY_BM1_CTRL_REG ; Make sure bitmap 1 is turned off
    STZ TyVKY_BM2_CTRL_REG ; Make sure bitmap 2 is turned off

    
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
    
    LDA #$00 ; Set I/O page to 0
    STA MMU_IO_CTRL 

    STZ animation_index     

EachFrame
    ; First, query the current timer
    CLC
    lda     #kernel.args.timer.FRAMES | kernel.args.timer.QUERY
    sta     kernel.args.timer.units
    jsr     kernel.Clock.SetTimer   ; Returns frame number in A
    ADC #60
    STA target_frame


    ; Schedule timer here
    lda     #kernel.args.timer.FRAMES   ; Measure in frames
    sta     kernel.args.timer.units

    lda     target_frame
    sta     kernel.args.timer.absolute
    
    lda     #1                          ; Cookie 1
    sta     kernel.args.timer.cookie

    jsr     kernel.Clock.SetTimer       ; Set the timer
   
Poll
    lda     #<event
    sta     kernel.args.events.dest+0
    lda     #>event
    sta     kernel.args.events.dest+1
    jsr     kernel.NextEvent    ; Populates event
    lda     event.type
    cmp     #kernel.event.timer.EXPIRED
    BEQ TimerTick
    BRA Poll
    
TimerTick
    ; Clear to color
    LDA animation_index
    STA $D00D ; Background red channel
    STA $D00E ; Background green channel
    STA $D00F ; Background blue channel  

    INC animation_index

    BRA EachFrame
        
Lock
    JMP Lock

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ClearScreen
    ; Text screen is 80 x 60.
    ; Loop from C000 to C0FC
    
    LDA #$02 ; Set I/O page to 2
    STA MMU_IO_CTRL
    
    STZ dst_pointer ; dst_pointer = C000
    LDA #$C0
    STA dst_pointer+1

ClearScreen_ForEach
    LDA #32 ; Space 
    STA (dst_pointer)
    
    ; dst_pointer++
    CLC 
    LDA dst_pointer
    ADC #$01
    STA dst_pointer
    LDA dst_pointer+1
    ADC #$00 ; Add carry
    STA dst_pointer+1

    ; loop until dst_pointer is C0FC
    CMP #$D2
    BNE ClearScreen_ForEach
    LDA dst_pointer
    CMP #$70
    BNE ClearScreen_ForEach

    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Pre-condition: 
;     text_memory_pointer is set as desired dest address
;     src_pointer is set as source address
PrintAnsiString
    LDX #$00
    LDY #$00
    
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

    RTS    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TX_PROMPT
.text "Please press the 'space' key."
.byte 0 ; null term

TX_RESPONSE
.text "Space key pressed!"
.byte 0 ; null term

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MAIN_SEGMENT_END
.endlogical

; Entrypoint segment metadata
                .long ENTRYPOINT
                .long 0       ; Dummy value to indicate this segment is for declaring the entrypoint.