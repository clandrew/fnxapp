;;;
;;; "Wormhole" graphics demo using palette rotation.
;;;

.cpu "65816"

.include "kernel.s"
.include "vicky_ii_def.s"
.include "macros.s"
.include "page_00_inc.s"
.include "interrupt_def.s"

; Constants
F_HEX = 0                                   ; FILETYPE value for a HEX file to run through the debug port
F_PGX = 1                                   ; FILETYPE value for a PGX file to run from storage
VRAM = $B00000                              ; Base address for video RAM
HIRQ = $FFEE                                ; IRQ vector
DEFAULT_TIMER = $02                         ; Number of SOF ticks to wait between sprite updates

.if FILETYPE = F_HEX
;
; For loading through the debug port, bootstrap the code through the RESET vector
;
* = $FFFC
HRESET          .word <>START               ; Bootstrapping vector
.endif

; Data
* = $002000
GLOBALS = *
JMPHANDLER      .byte ?                 ; JMP opcode for the NEXTHANDLER
NEXTHANDLER     .word ?                 ; Pointer to the next IRQ handler in the chain
DESTPTR         .dword ?                ; Pointer used for writing data
TIMER           .word ?                 ; The timer for controlling speed of motion (decremented on SOF interrupts)
IRQJMP          .fill 4                 ; Code for the IRQ handler vector

; Data buffers used during palette rotation. It'd be possible to reorganize the code to simply use
; one of these, but this opts for a bit of a memory/performance tradeoff and chooses perf.
regr .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
regg .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
regb .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

; Easier to simply not have to do this programmatically.
indcache .word 176, 236, 296, 356, 416, 476, 536, 596, 656, 716, 776, 836, 896, 956, 1016

tmpr .byte ?
tmpg .byte ?
tmpb .byte ?

; These aren't used at the same time as reg*, so they're aliased on top.
* = regr
SOURCE          .dword ?                    ; A pointer to copy from
DEST            .dword ?                    ; A pointer to copy to
SIZE            .dword ?                    ; The number of bytes to copy

.if FILETYPE = F_PGX
;
; Header for the PGX file
;

* = START - 8
                .text "PGX"
                .byte $01
                .dword START
.endif

.if FILETYPE = F_HEX
* = $003000
.elsif FILETYPE = F_PGX
* = $010000
.endif
START           CLC
                XCE

                setdbr 0
                setdp GLOBALS
                setaxl

                JSR SETUPBANK0              ; Copy BANK0 data

                ; Switch on bitmap graphics mode
                LDA #Mstr_Ctrl_Graph_Mode_En | Mstr_Ctrl_Bitmap_En
                STA @l MASTER_CTRL_REG_L

                setas
                LDA #0
                STA @l BORDER_CTRL_REG      ; Turn off the border
                STA @l MOUSE_PTR_CTRL_REG_L ; And turn off the mouse pointer

                JSL FK_SETSIZES             ; Recalculate the screen size information

                ; Turn on bitmap #0, LUT#1
                LDA #%00000011
                STA @l BM0_CONTROL_REG

                ; Set the bitmap's starting address
                MOVEI_L BM0_START_ADDY_L, 0

                LDA #0                      ; Set the bitmap scrolling offset to (0, 0)
                STA @l BM0_X_OFFSET
                STA @l BM0_Y_OFFSET

                JSR INITLUT                 ; Initiliaze the LUT

                MOVEI_L SIZE, (640*480)     ; Set the size of the data to transfer to VRAM
                MOVEI_L SOURCE, IMG_START   ; Set the source to the image data
                MOVEI_L DEST, 0             ; Set the destination to the beginning of VRAM

                JSR COPYS2V                 ; Request the DMA to copy the image data

                ; Set up the interrupt handler

                SEI

                setal
                LDA HIRQ                    ; Get the current handler
                STA NEXTHANDLER             ; And save it to call it

                LDA #<>IRQJMP               ; Replace it with our handler
                STA HIRQ

                setas
                LDA @l INT_MASK_REG0        ; Enable SOF interrupts
                AND #~FNX0_INT00_SOF
                STA @l INT_MASK_REG0

                CLI                         ; Make sure interrupts are enabled

lock            NOP                         ; Otherwise pause

                BRA lock

;
; Start copying data from system RAM to VRAM
;
; Inputs (pushed to stack, listed top down)
;   SOURCE = address of source data (should be system RAM)
;   DEST = address of destination (should be in video RAM)
;   SIZE = number of bytes to transfer
;
; Outputs:
;   None
COPYS2V         .proc
                PHD
                PHP

                setdbr 0
                setdp GLOBALS
                setas

                ; Set SDMA to go from system to video RAM, 1D copy
                LDA #SDMA_CTRL0_SysRAM_Src | SDMA_CTRL0_Enable
                STA @l SDMA_CTRL_REG0

                ; Set VDMA to go from system to video RAM, 1D copy
                LDA #VDMA_CTRL_SysRAM_Src | VDMA_CTRL_Enable
                STA @l VDMA_CONTROL_REG

                MOVE_L SDMA_SRC_ADDY_L, SOURCE      ; Set the source address
                MOVE_L VDMA_DST_ADDY_L, DEST        ; Set the destination address
                MOVE_L SDMA_SIZE_L, SIZE            ; Set the size of the block
                MOVE_L VDMA_SIZE_L, SIZE          

                setas
                LDA @l VDMA_CONTROL_REG             ; Start the VDMA
                ORA #VDMA_CTRL_Start_TRF
                STA @l VDMA_CONTROL_REG

                LDA @l SDMA_CTRL_REG0               ; Start the SDMA
                ORA #SDMA_CTRL0_Start_TRF
                STA @l SDMA_CTRL_REG0

                NOP                                 ; VDMA involving system RAM will stop the processor
                NOP                                 ; These NOPs give Vicky time to initiate the transfer and pause the processor
                NOP                                 ; Note: even interrupt handling will be stopped during the DMA
                NOP

wait_vdma       LDA @l VDMA_STATUS_REG              ; Get the VDMA status
                BIT #VDMA_STAT_Size_Err | VDMA_STAT_Dst_Add_Err | VDMA_STAT_Src_Add_Err
                BNE vdma_err                        ; Go to monitor if there is a VDMA error
                BIT #VDMA_STAT_VDMA_IPS             ; Is it still in process?
                BNE wait_vdma                       ; Yes: keep waiting

                LDA #0                              ; Make sure DMA registers are cleared
                STA @l SDMA_CTRL_REG0
                STA @l VDMA_CONTROL_REG

                PLP
                PLD
                RTS

vdma_err        BRK
                .pend

;
; Initialize the color look up tables
;
INITLUT         .proc
                PHB
                PHP

                setdbr 0
                setdp GLOBALS

                setas
                LDA #0                      ; Make sure default color is 0,0,0
                STA @l GRPH_LUT0_PTR
                STA @l GRPH_LUT0_PTR+1
                STA @l GRPH_LUT0_PTR+2
                STA @l GRPH_LUT0_PTR+3

                setaxl
                LDA #LUT_END - LUT_START    ; Copy the palette to Vicky LUT0
                LDX #<>LUT_START
                LDY #<>GRPH_LUT1_PTR
                MVN `START,`GRPH_LUT1_PTR

                PLP
                PLB
                RTS
                .pend

;
; Copy the Bank 0 data down to bank 0
;
SETUPBANK0      .proc
                PHB
                PHP

                setaxl
                LDX #<>BEGIN_BANK0
                LDY #<>GLOBALS
                LDA #(END_BANK0 - BEGIN_BANK0)
                MVN #`BEGIN_BANK0, #`GLOBALS

                PLP
                PLB
                RTS
                .pend

INNERIMPL       .proc
                LDA LUT_START, X        ; Load pe[pre]
                STA LUT_START, Y        ; Store it in pe[cur]
                INX
                INY
                LDA LUT_START, X
                STA LUT_START, Y
                INX
                INY
                LDA LUT_START, X
                STA LUT_START, Y
                INX
                INY
                LDA LUT_START, X
                STA LUT_START, Y
                INX
                INY

                ; Now decrement pre and cur
                DEX
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
                DEY
                RTS
                .pend

; Interrupt handler
HANDLEIRQ       
                PHD
                PHB
                PHA
                PHX
                PHY
                PHP

                setdbr 0
                setdp GLOBALS
                
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Update palette here.
    
    ; For each channel,
    ; Back up pe[30..45].
    ;
    ;for(k=0;k<15;k++)
    ;{
    ;    regr[k]=pe[k+30].peRed;
    ;}
                setas
                setxl

                LDX #0
                LDY #30*4
LOOP1
                LDA LUT_START,Y 
                STA @w regb,X   ; Force 16bit address
                INY
                LDA LUT_START,Y
                STA @w regg,X
                INY
                LDA LUT_START,Y
                STA @w regr,X
                INY
                INY         ; Alpha ignored
                
                INX
                CPX #15
                BNE LOOP1              

    ; For each channel,
    ; Overwrite pe[30..230] with pe[45..255]
    ;
    ;for(k=45;k<255;k++)
    ;{                                                            
    ;    pe[k-15].peRed=pe[k].peRed;
    ;}
    
                LDX #30*4   ; 0x78
                LDY #45*4   ; 0xB4
LOOP2
                LDA LUT_START,Y
                STA LUT_START,X
                INX
                INY
                LDA LUT_START,Y
                STA LUT_START,X
                INX
                INY
                LDA LUT_START,Y
                STA LUT_START,X
                INX
                INY
                INX        ; Alpha ignored     
                INY             
                CPX #$3C0 ; 240 * 4
                BNE LOOP2


    ; For each channel,
    ; Take the old pe[30..45] that we backed up and store it at the end.
    ;
    ;for(k=0;k<15;k++)
    ;{
    ;    pe[k+240].peRed=reg[k];
    ;}

                LDX #0
                LDY #240*4
LOOP3
                LDA regb,X
                STA LUT_START,Y
                INY
                LDA regg,X
                STA LUT_START,Y
                INY
                LDA regr,X
                STA LUT_START,Y
                INY
                INY ; Alpha ignored

                INX
                CPX #15
                BNE LOOP3

  ; Now the last part. We don't need the backups any more.
    ;for(i=0;i<15;i++)
    ;{
    ;    int k = i + 2;
    ;
    ;    int cur = 15 * k + 14;
    ;    int pre = cur - 1;
    ;
    ;    tmp = pe[cur];
    ;    for(j=0; j<14; j++)
    ;    {
    ;        pe[cur] = pe[pre];
    ;        cur--;
    ;        pre--;
    ;    }
    ;    pe[pre] = tmp;
    ;}

                LDX #$0
                LDY #$0
                STX @w regr ; i=0

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
                LDA LUT_START, Y
                STA @w tmpr
                INY
                LDA LUT_START, Y
                STA @w tmpg
                INY
                LDA LUT_START, Y
                STA @w tmpb
                ; Alpha ignored
                DEY
                DEY

                ; Now initialize the inner loop.
                LDA #14
                STA @w regb; j=14
INNER
                JSR INNERIMPL

                DEC @w regb   ; j--
                BNE INNER

                INX
                INX
                INX
                INX

                ; pe[pre] = tmp;
                LDA @w tmpr
                STA LUT_START, X
                INX
                LDA @w tmpg
                STA LUT_START, X
                INX
                LDA @w tmpb
                STA LUT_START, X

                INC @w regr ; Check if i>15, for outer loop
                INC @w regr
                LDX @w regr
                CPX #30
                BNE LOOP4

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                setaxl
                LDA #LUT_END - LUT_START    ; Copy the palette to Vicky LUT0
                LDX #<>LUT_START
                LDY #<>GRPH_LUT1_PTR
                MVN `START,`GRPH_LUT1_PTR
                
                PLP
                PLY
                PLX
                PLA
                PLB
yield           PLD                         ; Restore DP and status
                
                JML JMPHANDLER              ; Then transfer control to the next handler

;
; Bank 0 data (to be copied on startup)

;

BEGIN_BANK0 = *
D_JMPHANDLER    JMP 0                   ; JMP and Pointer to the next IRQ handler in the chain
D_DESTPTR       .dword 0                ; Pointer used for writing data
D_TIMER         .word DEFAULT_TIMER     ; The timer for controlling speed of motion (decremented on SOF interrupts)
                JML HANDLEIRQ           ; Code to start the interrupt handler
END_BANK0 = *

.include "rsrc/colors.s"
.include "rsrc/pixmap.s"
