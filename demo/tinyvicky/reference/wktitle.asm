cpu 'f256jr'
const usesystemfont=0

include 'includes\f256jr_registers.asm'
include 'f256jrlib.asm'
;include 'sid.asm'

; main game framework stored with libary section 
section 'F256JRLIB'
SIDSpeed resb 1
proc SOFIRQ	;	proc Increase_SOFCounter
;	Increase_SOF_Counter()
;	SID_Play_Frame()
	lda #SIDMODE
	cmp #6
	beq +
		dec SIDSpeed
		bne +
			sta SIDSpeed
			rts
	+
	jsr SIDPLAY
	rts
endproc

proc IRQ_Handler
	php
	PushAXY
	cld
	lda MMU_MEM_CTRL
	pha
	PushMMUIO

	SetMMUIO	; use i/o registers
	lda INT_PENDING_REG0
	sta TempIRQ
	bit #JR0_INT00_SOF
	beq +
		sta INT_PENDING_REG0	; clear irq
		jsr SOFIRQ ;Increase_SOFCounter
		lda TempIRQ
	+
	bit #JR0_INT02_KBD
	beq +
		sta INT_PENDING_REG0	; clear irq
		jsr KeyboardIRQ
		lda TempIRQ
	+

	PullMMUIO
	pla
	sta MMU_MEM_CTRL
	PullYXA
	plp
	rti
endproc

proc Init_IRQHandler
	PushMMUIO
	SetMMUIO

	sei
	AssignWord(#IRQ_Handler,VECTOR_IRQ)
	lda #~(JR0_INT00_SOF|JR0_INT02_KBD)
	sta INT_MASK_REG0
	
	AssignDWord(#0,SOFCounter)
	cli

	PullMMUIO
	rts
endproc

proc Init_Audio
	PushMMUIO
	SetMMUIO

	; init left and right sids
;	stz SID_Control
	ldx #0
	-
		stz SID_LEFT,x
		stz SID_RIGHT,x
		inx
		cpx #32
		bne -
		
	PullMMUIO
	rts
endproc

proc Init_GameFont
	PushMMUIO
	SetMMUIO
	
	SetMMUGFX
	CopyMemSmall(FONT_FANTASY,FONT_MEM,sizeof(FONT_FANTASY))
	
	PullMMUIO
	rts
	FONT_FANTASY incbin 'assets\gamefont2.bin'
endproc

proc Main
	lda #MMU_EDIT_EN
	sta MMU_MEM_CTRL
	SetMMUIO
	stz MMU_MEM_CTRL

	lda #(Mstr_Ctrl_Text_Mode_En|Mstr_Ctrl_Text_Overlay|Mstr_Ctrl_Graph_Mode_En|Mstr_Ctrl_Bitmap_En|Mstr_Ctrl_TileMap_En|Mstr_Ctrl_Sprite_En)
	sta MASTER_CTRL_REG_L
	lda #(Mstr_Ctrl_Text_XDouble|Mstr_Ctrl_Text_YDouble)
	sta MASTER_CTRL_REG_H
	jsr Init_GameFont
	jsr Init_Audio
	jsr Init_IRQHandler
	
	SetCursorColor(#DoC64COLOR(LTBLUE,BLACK))
	jsr ClearScreen
	
	; map in title screen code as $06000
;	UnlockMMU
;	lda #(TitleScreenCode/$2000)
;	sta MMU_MEM_BANK_3
;	LockMMU
;	jsr ShowTitle
	PrintString(TX_GAMETITLE,#0,#0,#DoC64COLOR(YELLOW,BLACK)))
;	inc SID_Control
;	SID_Initialize(0,0)

; BackSID
;// choose setting
;poke 54299,2 (overdrive)
;poke 54299,3 (filters)
;poke 54299,4 (smoothing)
;
;// choose value
;// overdrive: 0 (medium) 1 (high) 2 (low)
;// filters:   0 (blend)  1 (8580) 2 (6581)
;// smoothing: 0 (neat)   1 (soft) 2 (rough)
;poke 54300,0/1/2 (setting)
;
;// apply setting
;poke 54301,181:poke 54302,29
	
	SetMMUIO
	lda #1
	sta SIDSpeed
	lda #0
	jsr SIDINIT
;	SID_Initialize(0,0)
;	SID_SetVolume(-1)
;	SID_Play()
	SetMMUIO
	-
		jmp -

	TX_GAMETITLE bytez SIDFILE
endproc
endsection

section add('MAIN',$0800,$bfff,size=-1,save=1)

pad SIDSTART-$7e
;const SIDSTART=$a000,SIDINIT=$a000,SIDPLAY=$a003,SIDMODE=5,SIDFILE='toccata_v3.a000'
;const SIDSTART=$a000,SIDINIT=$a048,SIDPLAY=$a021,SIDMODE=5,SIDFILE='viola_duet.a000'
;const SIDSTART=$1000,SIDINIT=$1000,SIDPLAY=$1003,SIDMODE=5,SIDFILE='Super_Mario_Bros_2SID'
;const SIDSTART=$1000,SIDINIT=$1000,SIDPLAY=$1003,SIDMODE=5,SIDFILE='mrdo'
;const SIDSTART=$4000,SIDINIT=$4000,SIDPLAY=$4003,SIDMODE=5,SIDFILE='Airwolf_2SID'
;const SIDSTART=$1000,SIDINIT=$1000,SIDPLAY=$1003,SIDMODE=5,SIDFILE='Space_Oddity_2SID'
;const SIDSTART=$0FF6,SIDINIT=$0FF6,SIDPLAY=$1003,SIDMODE=6,SIDFILE='Girl_from_Tomorrow_2SID'
const SIDSTART=$0FF6,SIDINIT=$0FF6,SIDPLAY=$1003,SIDMODE=6,SIDFILE='Lakeside_2SID'
incbin 'music\'+SIDFILE+'.sid'

endsection

;savepgz
savebin 'wktitle.0800.bin',$0800 to $0ffff

