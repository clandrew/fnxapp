var dopush=0

const FOENIXMODELS = enum(	C256FMX,
							C256U,
							F256JR,
							A2560DEV,
							GENX,
							C256UP,
							RES1,
							RES2,
							A2560X,
							A2560U,
							A2560M,
							A2560K)
const FNX_SCREEN_WIDTH = 320 ,
		FNX_SCREEN_HEIGHT = 240 ,
		FNX_BORDER_WIDTH = 0 ,
		FNX_BORDER_HEIGHT = 0 ,
		FNX_SCREEN_COLUMNS = (FNX_SCREEN_WIDTH-FNX_BORDER_WIDTH) / 8 ,
		FNX_SCREEN_LINES = (FNX_SCREEN_HEIGHT-FNX_BORDER_HEIGHT) / 8

VKY_SCREEN_MEMORY = $C000	; character memory in io page 2, color memory in io page 3
VKY_FONT_MEMORY   = $C000	; address of screen font memory in io page 1
VKY_TEXT_MEMORY   = $C000	; address of screen text memory in io page 2
VKY_COLOR_MEMORY  = $C000	; address of screen color memory in io page 3

define jeq(aaddr) 'beq ~pcnext2 : jmp aaddr'
define jne(aaddr) 'bne ~pcnext2 : jmp aaddr'
define jlt(aaddr) 'blt ~pcnext2 : jmp aaddr'
define jge(aaddr) 'bge ~pcnext2 : jmp aaddr'
define jcc(aaddr) 'bcc ~pcnext2 : jmp aaddr'
define jcs(aaddr) 'bcs ~pcnext2 : jmp aaddr'
define jmi(aaddr) 'bmi ~pcnext2 : jmp aaddr'
define jpl(aaddr) 'bpl ~pcnext2 : jmp aaddr'
define jvc(aaddr) 'bvc ~pcnext2 : jmp aaddr'
define jvs(aaddr) 'bvs ~pcnext2 : jmp aaddr'

define DoC64COLOR(aforeground,abackground) (C64COLOR.aforeground<<4) | C64COLOR.abackground
define PushAXY 'pha : phx : phy'
define PullYXA 'ply : plx : pla'
define SetMMUIO 'stz MMU_IO_CTRL'
define SetMMUGFX 'lda #MMU_IO_PAGE_1 : sta MMU_IO_CTRL'
define SetMMUTEXT 'lda #MMU_IO_TEXT : sta MMU_IO_CTRL'
define SetMMUCOLOR 'lda #MMU_IO_COLOR : sta MMU_IO_CTRL'
define PushMMUIO 'lda MMU_IO_CTRL : pha'
define PullMMUIO 'pla : sta MMU_IO_CTRL'
define UnlockMMU 'lda MMU_MEM_CTRL : ora #MMU_EDIT_EN : sta MMU_MEM_CTRL'
define LockMMU 'lda MMU_MEM_CTRL : and #~(MMU_EDIT_EN) : sta MMU_MEM_CTRL'
define SetMMUBank(abank,aaddr) 'lda #((aaddr)/$2000) : sta MMU_MEM_Bank_0+abank'
;=====================================================================================
section add('VECTORS',$fff9,$ffff,save=1)
	F256_DUMMYIRQ rti
	word F256_DUMMYIRQ	; nmi
	word F256_RESET		; reset
	word F256_DUMMYIRQ	; irq
endsection	

section add('ZPAGE',$0020,$00ef,type='bss',save=0)
	TempIRQ resb 16
	TempSrc resb 4
	TempDest resb 4
	TempZ resb 16
	CursorColor resb 1
	CursorColumn resb 1
	CursorLine	resb 1
	CursorPointer resw 1
	
	SOFCounter resd 1
endsection

section add('DATA',$0200,$1fff,size=-1,save=1,file='wkdata.000200.bin')
endsection

;section add('TEXT',___MAIN_SECTION_NEXT_FREE___,$fff8,size=-1,save=1)
;endsection

section add('F256JRLIB',$e000,$fff8,size=-1,save=1,file='wkf256.00e000.bin')
;=====================================================================================
macro F256Test
	-
		SetMMUTEXT
		inc TEXT_MEM
		SetMMUCOLOR
		inc COLOR_MEM
		SetMMUIO
		inc BACKGROUND_COLOR_B
		inc BORDER_COLOR_B
	bra -
endmacro

macro ConvertParamToA('aparam')
	if upcase('aparam')='A'
	elseif upcase('aparam')='X'
		txa
	elseif upcase('aparam')='Y'
		tya
	elseif upcase('aparam')='YA'
	else
		if leftstr('aaddr',1)='#'
			lda #(loword(val(copy('aaddr',2)))) : sta adest
		else
			lda aparam
		endif
	endif
endmacro

macro ConvertParamToX('aparam')
	if upcase('aparam')='A'
		tax
	elseif upcase('aparam')='X'
	elseif upcase('aparam')='Y'
		pha
		tya
		tax
		pla
	elseif upcase('aparam')='YA'
	else
		if leftstr('aaddr',1)='#'
			ldx #(loword(val(copy('aaddr',2)))) : sta adest
		else
			ldx aparam
		endif
	endif
endmacro

macro AssignWord('aaddr',adest)
	if leftstr('aaddr',1)='#'
		lda #<(loword(val(copy('aaddr',2)))) : sta adest
		lda #>(loword(val(copy('aaddr',2)))) : sta (adest)+1
	else
		lda aaddr : sta adest
		lda aaddr+1 : sta adest+1
	endif
endmacro

macro AssignLong('aaddr',adest)
	if leftstr('aaddr',1)='#'
		lda #<(loword(val(copy('aaddr',2)))) : sta adest
		lda #>(loword(val(copy('aaddr',2)))) : sta (adest)+1
		lda #<(hiword(val(copy('aaddr',2)))) : sta (adest)+2
	else
		lda aaddr : sta adest
		lda aaddr+1 : sta adest+1
		lda aaddr+2 : sta adest+2
	endif
endmacro

macro AssignDWord('aaddr',adest)
	if leftstr('aaddr',1)='#'
		lda #<(loword(val(copy('aaddr',2)))) : sta adest
		lda #>(loword(val(copy('aaddr',2)))) : sta (adest)+1
		lda #<(hiword(val(copy('aaddr',2)))) : sta (adest)+2
		lda #>(hiword(val(copy('aaddr',2)))) : sta (adest)+3
	else
		lda aaddr : sta adest
		lda aaddr+1 : sta adest+1
		lda aaddr+2 : sta adest+2
		lda aaddr+3 : sta adest+3
	endif
endmacro

macro SetMMUBlock(acontrol)
	if (~argcount=0) or (acontrol=0)
		stz MMU_IO_CTRL
	else
		ConvertParamToA(acontrol)
		sta MMU_IO_CTRL
	endif
endmacro

macro SetCursorColor(acolor)
	ConvertParamToA(acolor)
	sta CursorColor
endmacro

; hard coded for 80 columns
macro SetCursorPointer('acolumn','aline')
	ConvertParamToA(acolumn)
	sta CursorColumn
	ConvertParamToA(aline)
	sta CursorLine
	
	if (leftstr('acolumn',1)='#') and (leftstr('aline',1)='#')
		lda #<(VKY_TEXT_MEMORY+val(copy('aline',2))*40)
		sta CursorPointer
		lda #>(VKY_TEXT_MEMORY+val(copy('aline',2))*40)
		sta CursorPointer+1
	else
		; not done yet
	endif
endmacro

macro Increase_SOF_Counter
{
	inc SOFCounter
	bne +
		inc SOFCounter+1
		bne +
			inc SOFCounter+2
			bne +
				inc SOFCounter+3
	+
}
endmacro

proc ChrOut
	pha
	phy
	tay
	PushMMUIO
	SetMMUTEXT
	tya
	ldy CursorColumn
	sta (CursorPointer),y
	inc MMU_IO_CTRL
	lda CursorColor
	sta (CursorPointer),y
	iny
	cpy #FNX_SCREEN_COLUMNS
	bne +
		clc
		lda CursorPointer
		adc #FNX_SCREEN_COLUMNS
		sta CursorPointer
		bcc ~pcnext2
			inc CursorPointer+1
		lda CursorLine
		inc
		cmp #FNX_SCREEN_LINES
		bne ++
			lda #>VKY_TEXT_MEMORY
			sta CursorPointer+1
			lda #<VKY_TEXT_MEMORY	; always equals 0
			sta CursorPointer
		++
		sta CursorLine
		ldy #0
	+
	sty CursorColumn
	PullMMUIO
	ply
	pla
	rts
endproc

proc ClearScreen
	pha
	phx
	PushMMUIO
	
	stz WriteAddress	;lda #<TEXT_MEM
	stz CursorPointer	;sta CursorPointer
	lda #>TEXT_MEM
	sta WriteAddress+1
	sta CursorPointer+1
	SetMMUTEXT
	ldx #' '
	jsr WriteLoop
	stz WriteAddress	;lda #<TEXT_MEM
	lda #>TEXT_MEM
	sta WriteAddress+1
	SetMMUCOLOR
	ldx CursorColor
	jsr WriteLoop

	PullMMUIO
	plx
	pla
	rts

	WriteLoop:
		txa
	WriteAddress=*+1
		sta $1234
		inc WriteAddress
		bne +
			inc WriteAddress+1
		+
		lda WriteAddress
		cmp #<(TEXT_MEM+80*60)
		bne WriteLoop
			lda WriteAddress+1
			cmp #>(TEXT_MEM+80*60)
			bne WriteLoop
		rts
endproc

; parameters:
;	<TempSrc>	=	word address of string to print
;	<CursorPointer>	=	word address of screen character/color memory
proc PrintAnsiString
;	PushAXY

	ldy #0
	bra Print20
	Print10:
		cmp #27
		blt CheckControlCodes
		jsr ChrOut
	NextByte:
		iny
		bne Print20
			inc TempSrc+1
	Print20:
		lda (TempSrc),y
		bne Print10
;	PullYXA
	rts

	CheckControlCodes:
		cmp #2	; ctrl-b/set cursor background color
		bne +
			lda CursorColor
			and #$f0
			sta CursorColor
			jsr GetNextByte
			ora CursorColor
			sta CursorColor
			bra NextByte
		+
		cmp #3	; ctrl-c/set cursor color
		bne +
			jsr GetNextByte
			sta CursorColor
			bra NextByte
		+
		cmp #6	; ctrl-f/set cursor foreground color
		bne +
			lda CursorColor
			and #$0f
			sta CursorColor
			jsr GetNextByte
			asl : asl : asl : asl
			ora CursorColor
			sta CursorColor
			bra NextByte
		+
		cmp #12	; ctrl-l/clear screen
		bne +
			jsr ClearScreen
			bra NextByte
		+
		rts
		temp byte 0
	GetNextByte:
		iny
		bne +
			inc TempSrc+1
		+
		lda (TempSrc),y
		rts
endproc

macro PrintString('astring','acolumn','aline','acolor')
	if dopush
		PushAXY
	endif
	if (length('acolumn')>0) and (length('aline')>0)
		SetCursorPointer(acolumn,aline)
	endif
	if length('acolor')>0
		SetCursorColor(acolor)
	endif
	if (leftstr('astring',1)="'") or (leftstr('astring',1)='"') or (leftstr('astring',1)='(') or (leftstr('astring',1)='[')
		section TEXT_BANK
			var @newtext = *
			bytez astring
		endsection
		lda #<(@newtext) : sta TempSrc
		lda #>(@newtext) : sta TempSrc+1
	else
		lda #<astring : sta TempSrc
		lda #>astring : sta TempSrc+1
	endif
	jsr PrintAnsiString
	if dopush
		PullYXA
	endif
endmacro

; parameters
;	A	=	byte to print
; returns
;	Y	=	upper nibble ascii
;	A	=	lower nibble ascii
proc HexByteToASCII
	phx
	tax
	and #$f0
	lsr : lsr : lsr : lsr
	tay
	lda HEXTABLE,y
	tay
	txa
	and #$0f
	tax
	lda HEXTABLE,x
	plx
	rts
	HEXTABLE byte '0123456789ABCDEF'
endproc

macro PrintHexByte('avalue','acolumn','aline','acolor')
	if dopush
		PushAXY
	endif
	if (length('acolumn')>0) and (length('aline')>0)
		SetCursorPointer(acolumn,aline)
	endif
	if length('acolor')>0
		SetCursorColor(acolor)
	endif
	if dopush
		PullYXA
	endif
	if dopush
		PushAXY
	endif
	ConvertParamToA(avalue)
	jsr HexByteToASCII
	sty TempZ : sta TempZ+1
	stz TempZ+2
	PrintString(TempZ)
	if dopush
		PullYXA
	endif
endmacro

macro PrintHexWord('avalue','acolumn','aline','acolor')
	if dopush
		PushAXY
	endif
	if (length('acolumn')>0) and (length('aline')>0)
		SetCursorPointer(acolumn,aline)
	endif
	if length('acolor')>0
		SetCursorColor(acolor)
	endif
	if leftstr('avalue',1)='#'
		lda #>(val(copy('avalue',2)))
		jsr HexByteToASCII
		sty TempZ : sta TempZ+1
		lda #<(val(copy('avalue',2)))
		jsr HexByteToASCII
		sty TempZ+2 : sta TempZ+3
		stz TempZ+4
	else
		lda avalue+1
		jsr HexByteToASCII
		sty TempZ : sta TempZ+1
		lda avalue
		jsr HexByteToASCII
		sty TempZ+2 : sta TempZ+3
		stz TempZ+4
	endif
	PrintString(TempZ)
	if dopush
		PullYXA
	endif
endmacro

macro PrintHexDWord('avalue','acolumn','aline','acolor')
	if dopush
		PushAXY
	endif
	if (length('acolumn')>0) and (length('aline')>0)
		SetCursorPointer(acolumn,aline)
	endif
	if length('acolor')>0
		SetCursorColor(acolor)
	endif
	if leftstr('avalue',1)='#'
		lda #<(val(copy('avalue',2)) shr 24)
		jsr HexByteToASCII
		sty TempZ : sta TempZ+1
		lda #<(val(copy('avalue',2)) shr 16)
		jsr HexByteToASCII
		sty TempZ+2 : sta TempZ+3
		lda #<(val(copy('avalue',2)) shr 8)
		jsr HexByteToASCII
		sty TempZ+4 : sta TempZ+5
		lda #<(val(copy('avalue',2)))
		jsr HexByteToASCII
		sty TempZ+6 : sta TempZ+7
		stz TempZ+8
	else
		lda avalue+3
		jsr HexByteToASCII
		sty TempZ : sta TempZ+1
		lda avalue+2
		jsr HexByteToASCII
		sty TempZ+2 : sta TempZ+3
		lda avalue+1
		jsr HexByteToASCII
		sty TempZ+4 : sta TempZ+5
		lda avalue
		jsr HexByteToASCII
		sty TempZ+6 : sta TempZ+7
		stz TempZ+8
	endif
	PrintString(TempZ)
	if dopush
		PullYXA
	endif
endmacro

; KeyboardState
; shift
; ctrl
; win
; numlk
; capslk			
;   bit
;	5  4  3  2  1  0
;	|  |  |  |  |  |
;	|  |  |  |  |  shift l/r = c0 c1
;	|  |  |  |  ----alt l/r  = c2 c3
;	|  |  |  ------ctrl l/r  = c4 c5
;	|  |  ----------win l/r  = c6 c7
;	|  ---------------numlk  = cf
;   -----------------capslk  = ce
; 
const KEYDOWN=$00, KEYUP=$80
ScancodeBufferWPos word 0
ScancodeBufferRPos word 0
LastScancode word 0
ScancodeBuffer resb 128,0
KeyboardState resb 1,0
KeyboardKeyStates resb $90,KEYUP
const KEYBOARDSTATES = enum(	ALLOFF =%000000,
								SHIFT  =%000001,
								ALT    =%000010,
								CTRL   =%000100,
								WIN    =%001000,
								NUMLK  =%010000,
								CAPSLK =%100000)
proc Init_Keyboard
	; clear keyboard & mouse fifo buffer
	lda #(KBD_FIFO_CLEAR|MSE_FIFO_CLEAR)
	sta KBD_MSE_CTRL_REG
	stz KBD_MSE_CTRL_REG

	stz ScancodeBufferRPos
	stz ScancodeBufferWPos
	ldx #0
	-
		sta ScancodeBuffer
		inx
		cpx #lobyte(sizeof(ScancodeBuffer))
		bne -

	lda #KEYUP	; key released
	ldx #0
	-
		sta KeyboardKeyStates,x
		inx
		cpx #sizeof(KeyboardKeyStates)
		bne -
	
	lda #KEYBOARDSTATES.ALLOFF
	sta KeyboardState
	
	; enable keyboard interrupt
	lda INT_MASK_REG0
	ora #~(JR0_INT02_KBD)
	sta INT_MASK_REG0
	rts
endproc

proc KeyboardIRQ
	-
	lda KBD_MS_RD_STATUS
	and #KBD_FIFO_Empty
	bne +
		lda ScancodeBufferWPos
		tax
		inc
		and #$7f
		cmp ScancodeBufferRPos
		beq .BufferFull
			sta ScancodeBufferWPos
			lda KBD_RD_SCAN_REG		; get keyboard scan code
			sta ScancodeBuffer,x
			bra -
		
	.BufferFull:
		lda KBD_RD_SCAN_REG		; get keyboard scan code and forget it
	+
		rts
endproc

; returns:
;	A	=	scan code from buffer
;	<carry>	:	clear=scan code in A, set=buffer empty A equals 0
proc GetScancode
	lda ScancodeBufferRPos
	cmp ScancodeBufferWPos
	beq BufferEmpty
		phx
		tax
		inc
		and #$7f
		sta ScancodeBufferRPos
		lda ScancodeBuffer,x
		plx
		clc
		rts
	BufferEmpty:
		lda #0
		sec
		rts
endproc

proc GetChar
	jsr GetScancode
	bcc +
		; buffer empty
		rts
	+
	cmp #$90	; scan code can only be 00-8f
	blt +
		sta LastScancode
		cmp #$f0	; is last scan code a break prefix, get next scan code
		beq GetChar
			lda #0	; return null for invalid scan code range
			sec		; set carry for empty buffer
			rts
	+
	phx
	ldx LastScancode	; get last scan code
	sta LastScancode	; save new scan code
	cpx #$f0
	bne KeyPressed
	jmp KeyReleased
		
	KeyPressed:
		tax
		lda #KEYDOWN	; set state as key for DOWN
		sta KeyboardKeyStates,x
		lda KeyboardState
		bit #(KEYBOARDSTATES.SHIFT|KEYBOARDSTATES.CAPSLK)
		beq +
			lda SCSET21,x
			bra ++
		+
			lda SCSET2,x
		++
		tax
		and #$c0
		cmp #$c0
		beq .SpecialKeyDown
	txa
	plx
	rts
		
	.SpecialKeyDown:
		cpx #$c0
		beq .Shift
		cpx #$c1
		bne ++
		.Shift:
			lda KeyboardState
			ora #KEYBOARDSTATES.SHIFT
			sta KeyboardState
			bra +
		++
		cpx #$c2
		beq .Alt
		cpx #$c3
		bne ++
		.Alt:
			lda KeyboardState
			ora #KEYBOARDSTATES.ALT
			sta KeyboardState
			bra +
		++
		cpx #$c4
		beq .Ctrl
		cpx #$c5
		bne ++
		.Ctrl:
			lda KeyboardState
			ora #KEYBOARDSTATES.CTRL
			sta KeyboardState
			bra +
		++
		cpx #$c6
		beq .Win
		cpx #$c7
		bne ++
		.Win:
			lda KeyboardState
			ora #KEYBOARDSTATES.WIN
			sta KeyboardState
			bra +
		++
		cpx #$cf
		bne ++
		.NumLk:
			lda KeyboardState
			eor #KEYBOARDSTATES.NUMLK
			sta KeyboardState
			bra +
		++
		cpx #$ce
		bne ++
		.CapsLk:
			lda KeyboardState
			eor #KEYBOARDSTATES.CAPSLK
			sta KeyboardState
				bra +
		++
	+
	lda #0
	sec
	plx
	rts
			
	KeyReleased:
		tax
		lda #KEYUP	; set state for key as UP
		sta KeyboardKeyStates,x
		lda SCSET2,x
		tax
		and #$c0
		cmp #$c0
		beq .SpecialKeyDown
	lda #0
	sec
	plx
	rts
		
	.SpecialKeyDown:
		cpx #$c0
		beq .Shift
		cpx #$c1
		bne ++
		.Shift:
			lda KeyboardState
			and #~(KEYBOARDSTATES.SHIFT)
			sta KeyboardState
			bra +
		++
		cpx #$c2
		beq .Alt
		cpx #$c3
		bne ++
		.Alt:
			lda KeyboardState
			and #~(KEYBOARDSTATES.ALT)
			sta KeyboardState
			bra +
		++
		cpx #$c4
		beq .Ctrl
		cpx #$c5
		bne ++
		.Ctrl:
			lda KeyboardState
			and #~(KEYBOARDSTATES.CTRL)
			sta KeyboardState
			bra +
		++
		cpx #$c6
		beq .Win
		cpx #$c7
		bne ++
		.Win:
			lda KeyboardState
			and #~(KEYBOARDSTATES.WIN)
			sta KeyboardState
			bra +
		++
	+
	lda #0
	sec
	plx
	rts

; function keys f1-f24 = ascii $8a-$a1
;
;				 0    1    2    3    4    5    6    7    8    9    A    B    C    D    E    F
SCSET2	byte	$00, $92, $00, $8e, $8c, $8a, $8b, $95, $00, $93, $91, $8f, $8d, $09, '`', $00,
				$00, $c2, $c0, $00, $c4, 'q', '1', $00, $00, $00, 'z', 's', 'a', 'w', '2', $c6,
				$00, 'c', 'x', 'd', 'e', '4', '3', $c7, $00, ' ', 'v', 'f', 't', 'r', '5', $00,
				$00, 'n', 'b', 'h', 'g', 'y', '6', $00, $00, $00, 'm', 'j', 'u', '7', '8', $00,
				$00, ',', 'k', 'i', 'o', '0', '9', $00, $00, '.', '/', 'l', ';', 'p', '-', $00,
				$00, $00, $2c, $00, '[', '=', $00, $00, $ce, $c1, $0d, ']', $00, '\', $00, $00,
				$00, $00, $00, $00, $00, $00, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00,
				$00, $00, $00, $00, $00, $00, $1b, $cf, $94, $00, $00, $00, $00, $00, $00, $00,
				$00, $00, $00, $90, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

; shift
;				 0    1    2    3    4    5    6    7    8    9    A    B    C    D    E    F
SCSET21	byte	$00, $9e, $00, $9a, $98, $96, $97, $a1, $00, $9f, $9d, $9b, $99, $09, '~', $00,
				$00, $c2, $c0, $00, $c4, 'Q', '!', $00, $00, $00, 'Z', 'S', 'A', 'W', '@', $c6,
				$00, 'C', 'X', 'D', 'E', '$', '#', $c7, $00, ' ', 'V', 'F', 'T', 'R', '%', $00,
				$00, 'N', 'B', 'H', 'G', 'Y', '^', $00, $00, $00, 'M', 'J', 'U', '&', '*', $00,
				$00, '<', 'K', 'I', 'O', ')', '(', $00, $00, '.', '?', 'L', ':', 'P', '_', $00,
				$00, $00, $2c, $00, '{', '+', $00, $00, $ce, $c1, $0d, '}', $00, '|', $00, $00,
				$00, $00, $00, $00, $00, $00, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00,
				$00, $00, $00, $00, $00, $00, $1b, $cf, $a0, $00, $00, $00, $00, $00, $00, $00,
				$00, $00, $00, $9c, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
endproc

; assume SetMMUIO
proc WaitForDMAReset
	-
		lda DMA_STATUS_REG
		and #DMA_STATUS_TRF_IP
		cmp #DMA_STATUS_TRF_IP
		beq -
	stz DMA_CTRL_REG
	rts
endproc

; assume SetMMUIO
macro DMA1DCopy(asource,adest,asize)
	lda #(DMA_CTRL_Enable) : sta DMA_CTRL_REG
	lda #<(asource) : sta DMA_SOURCE_ADDY_L
	lda #>(asource) : sta DMA_SOURCE_ADDY_M
	lda #^(asource) : sta DMA_SOURCE_ADDY_H
	lda #<(adest) : sta DMA_DEST_ADDY_L
	lda #>(adest) : sta DMA_DEST_ADDY_M
	lda #^(adest) : sta DMA_DEST_ADDY_H
	lda #<(asize) : sta DMA_SIZE_1D_L
	lda #>(asize) : sta DMA_SIZE_1D_M
	lda #^(asize) : sta DMA_SIZE_1D_H
	lda #(DMA_CTRL_Enable|DMA_CTRL_Start_Trf) : sta DMA_CTRL_REG
endmacro

; assume SetMMUIO
macro DMA1DFill(adest,asize,afillbyte)
	lda #(DMA_CTRL_Enable) : sta DMA_CTRL_REG
	lda #<(adest) : sta DMA_DEST_ADDY_L
	lda #>(adest) : sta DMA_DEST_ADDY_M
	lda #^(adest) : sta DMA_DEST_ADDY_H
	lda #afillbyte
	sta DMA_DATA_2_WRITE
	lda #<(asize) : sta DMA_SIZE_1D_L
	lda #>(asize) : sta DMA_SIZE_1D_M
	lda #^(asize) : sta DMA_SIZE_1D_H
	lda #(DMA_CTRL_Enable|DMA_CTRL_Start_Trf) : sta DMA_CTRL_REG
endmacro

; 8-bit
macro CopyMemTiny(asource,adest,asize)
	{
		ldy #0
		-
			lda asource,y
			sta adest,y
			iny
			cpy #asize
			bne -
	}
endmacro

; 16-bit
macro CopyMemSmall(asource,adest,asize)
	{
;		AssignWord(asource,.asrcaddr)
		lda #<(asource) : sta .srcaddr
		lda #>(asource) : sta .srcaddr+1
;		AssignWord(adest,.destaddr)
		lda #<(adest) : sta .destaddr
		lda #>(adest) : sta .destaddr+1
		ldy #0
		-
			.srcaddr=*+1
			lda $1234
			.destaddr=*+1
			sta $4321
			inc .srcaddr
			bne +
				inc .srcaddr+1
			+
			inc .destaddr
			bne +
				inc .destaddr+1
			+
		lda .srcaddr
		cmp #<(asource+asize)
		bne -
		lda .srcaddr+1
		cmp #>(asource+asize)
		bne -
	}
endmacro

const C64COLOR = enum(	BLACK,WHITE,RED,CYAN,
						PURPLE,GREEN,BLUE,YELLOW,
						ORANGE,BROWN,LTRED,DKGREY,
						MDGREY,LTGREEN,LTBLUE,LTGREY)
if usesystemfont
	SYSTEM_FONT incbin 'includes\cp437ish_f256jr_8x8-charset.bin'
;	SYSTEM_FONT incbin 'includes\f256jr_native-charset_1.0b2.bin'
endif
proc Init_Graphics
	; clear foreground & background luts with #000000
	ldx #0
	lda #0
	-
		sta TEXT_LUT_FG,x
		sta TEXT_LUT_BG,x
		inx
		cpx #16*4
		bne -

	; set C64 colodore palette
	ldx #0
	-
		lda COLODORE_PALETTE,x
		sta TEXT_LUT_FG,x	; set font foreground lut
		sta TEXT_LUT_BG,x	; set font background lut
		inx
		cpx #sizeof(COLODORE_PALETTE)
		bne -

	; initialize system font
	if usesystemfont
		SetMMUGFX
		CopyMemSmall(SYSTEM_FONT,VKY_FONT_MEMORY,sizeof(SYSTEM_FONT))
	endif

	; initialize border
	SetMMUIO				; set i/o at $d000, use page 0=i/o registers
	;lda #Border_Ctrl_Enable	; enable border
	stz BORDER_CTRL_REG	;sta BORDER_CTRL_REG
	stz BORDER_COLOR_B	;lda #$ff : sta BORDER_COLOR_B		; set border color to blue, #0000ff
	stz BORDER_COLOR_G	;lda #$00 : sta BORDER_COLOR_G
	stz BORDER_COLOR_R	;lda #$00 : sta BORDER_COLOR_R
	;lda #FNX_BORDER_HEIGHT	; set border to 8 pixels high and 8 pixels wide
	stz BORDER_Y_SIZE	;sta BORDER_Y_SIZE
	;lda #FNX_BORDER_WIDTH
	stz BORDER_X_SIZE	;sta BORDER_X_SIZE
	
	; initialize backgrounnd
	stz BACKGROUND_COLOR_B	; set background color to black, #000000
	stz BACKGROUND_COLOR_G
	stz BACKGROUND_COLOR_R

	; initialize Tiny Vicky registers
	ldx #0
	-
		stz TyVKY_BM0_CTRL_REG,x	; bitmaps
		stz TL0_CONTROL_REG,x	; tilemaps/tilesets
		stz SP0_Ctrl,x	; sprites
		stz SP0_Ctrl+$0100,x
		inx
		bne -
		
	; initialize cursor
	stz VKY_TXT_CURSOR_CTRL_REG	; disable cursor
	stz VKY_TXT_CURSOR_CHAR_REG	; set cursor character as font tile 0
	
	stz VKY_TXT_CURSOR_X_REG_L	; set cursor to colum 0
	stz VKY_TXT_CURSOR_X_REG_H
	stz VKY_TXT_CURSOR_Y_REG_L	; set cursor to row 0
	stz VKY_TXT_CURSOR_Y_REG_H
	
	lda #DoC64COLOR(LTBLUE,BLACK)
	sta CursorColor
	jsr ClearScreen
	AssignWord(#VKY_TEXT_MEMORY,CursorPointer)
	rts
option showallbytes=1
COLODORE_PALETTE hex	00 00 00 00 FF FF FF 00 38 33 81 00 C8 CE 75 00 ,
						97 3C 8E 00 4D AC 56 00 9B 2C 2E 00 71 F1 ED 00 ,
						29 50 8E 00 00 38 55 00 71 6C C4 00 4A 4A 4A 00 ,
						7B 7B 7B 00 9F FF A9 00 EB 6D 70 00 B2 B2 B2 00
option showallbytes=0
endproc

proc Init_CODEC
	lda #%0.0.000.0.0.0.0
	ldy #%0001101.0
	jsr WriteCodecWait
	lda #%0000.0011
	ldy #%0010101.0
	jsr WriteCodecWait
	lda #%0.0.00.0001
	ldy #%0010001.1
	jsr WriteCodecWait
	lda #%00000.111
	ldy #%0010110.0
	jsr WriteCodecWait
	lda #%00.00.0.0.10
	ldy #%0001010.0
	jsr WriteCodecWait
	lda #%0.0.00.0.0.10
	ldy #%0001011.0
	jsr WriteCodecWait
	lda #%0.100.0.101
	ldy #%0001100.0
	jsr WriteCodecWait
	rts

	WriteCodecWait:
		sta CODEC_LOW
		sty CODEC_HI
		lda #1
		sta CODEC_CTRL
		-
			bit CODEC_CTRL
			bne -
		rts
endproc

proc Init_Sound
	jsr Init_CODEC

	; intialize left and right PSG SN76489
	lda #%1.00.1.1111	;mute channel 0
	sta PSG_INT_L_PORT
	sta PSG_INT_R_PORT
	lda #%1.01.1.1111	;mute channel 1
	sta PSG_INT_L_PORT
	sta PSG_INT_R_PORT
	lda #%1.10.1.1111	;mute channel 2
	sta PSG_INT_L_PORT
	sta PSG_INT_R_PORT
	lda #%1.11.1.1111	;mute channel 3
	sta PSG_INT_L_PORT
	sta PSG_INT_R_PORT
	
	; initialize left and right SIDs
	ldx #0
	-
		stz SID_L_V1_FREQ_LO,x
		stz SID_R_V1_FREQ_LO,x
		inx
		cpx #$20
		bne -
	rts
endproc

proc F256_RESET
	; disable interrupts
	sei
	; clear decimal mode
	cld
	; initialize stack
	ldx #$ff
	txs

	; initialize mmu
	stz MMU_MEM_CTRL
	UnlockMMU	; enable mmu edit, edit mmu lut 0, activate mmu lut 0
	SetMMUIO	; enable i/o at $d000, use page 0=i/o registers
	lda #0 : sta MMU_MEM_BANK_0	; map $000000 to bank 0
	inc : sta MMU_MEM_BANK_1	; map $002000 to bank 1
	inc : sta MMU_MEM_BANK_2	; map $004000 to bank 2
	inc : sta MMU_MEM_BANK_3	; map $006000 to bank 3
	inc : sta MMU_MEM_BANK_4	; map $008000 to bank 4
	inc : sta MMU_MEM_BANK_5	; map $00a000 to bank 5
	inc : sta MMU_MEM_BANK_6	; map $00c000 to bank 6
	inc : sta MMU_MEM_BANK_7	; map $00e000 to bank 7
	LockMMU	; disable mmu edit, use mmu lut 0

	; initialize via registers
	; reset via registers a/b
	stz VIA_ORB_IRB	; set via i/o port a to read
	stz VIA_ORA_IRA	; set via i/o port b to read

	; enable random number generator	
	lda #RNG_ENABLE
	sta RNG_CTRL

	; initialize interrupts
	lda #$ff	; mask off all interrupts
	sta INT_EDGE_REG0
	sta INT_EDGE_REG1
	sta INT_EDGE_REG2
	sta INT_MASK_REG0
	sta INT_MASK_REG1
	sta INT_MASK_REG2

	lda INT_PENDING_REG0	; clear all existing interrupts
	sta INT_PENDING_REG0
	lda INT_PENDING_REG1
	sta INT_PENDING_REG1
	lda INT_PENDING_REG2
	sta INT_PENDING_REG2
	
	jsr Init_Sound
	jsr Init_Graphics
	jsr Init_Keyboard
	cli
	jmp Main
endproc
endsection

