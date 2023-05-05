;;;
;;; "Wormhole" graphics demo using palette rotation.
;;;

.cpu "65816"

PUTS = $00101C                      ; Print a string to the currently selected channel
PUTC = $001018                      ;

.include "kernel.s"
.include "vicky_ii_def.s"
.include "macros.s"
.include "page_00_inc.s"
.include "interrupt_def.s"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* =  THUNK_SEGMENT_START - 7
                .text "Z"           
                .long THUNK_SEGMENT_START               
                .long THUNK_SEGMENT_END - THUNK_SEGMENT_START 
* =  $02000

THUNK_SEGMENT_START
IRQJMP          .byte $5C               ; JML-with-24bit for IRQ handler vector
IRQADDR         .long ?
THUNK_SEGMENT_END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                .long MAIN_SEGMENT_START               
                .long MAIN_SEGMENT_END - MAIN_SEGMENT_START 
.logical $10000
MAIN_SEGMENT_START
GLOBALS_ADDR = *

; 16bit pointer to the next handler. We can assume the next handler is in bank 0.
NEXTHANDLER     .word ?                 ; Pointer to the next IRQ handler in the chain

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

START           PHB
                PHP
                
                setdbr `GLOBALS_ADDR
                
                setal
                LDA #<>HANDLEIRQ
                STA IRQADDR
                setas
                LDA #`HANDLEIRQ
                STA IRQADDR+2
                                
                LDA #$0                 ; Set a return value of 0

                PLP
                PLB
                RTL                     ; Go back to the caller
                
; Interrupt handler
HANDLEIRQ       
                PHD
                PHB
                PHA
                PHX
                PHY
                PHP

                setdbr `GLOBALS_ADDR
                PLP
                PLY
                PLX
                PLA
                PLB
yield           PLD                         ; Restore DP and status
                
                ; Data bank has been set already
                JMP (<>NEXTHANDLER)           ; Then transfer control to the next handler

MAIN_SEGMENT_END
.endlogical

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Entrypoint segment metadata
                .long START   ; Entrypoint
                .long 0       ; Dummy value to indicate this segment is for declaring the entrypoint.