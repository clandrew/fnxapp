;MMU Registers
MMU_MEM_CTRL        = $0000            ; MMU Memory Control Register
	MMU_EDIT_EN   = $80
MMU_IO_CTRL         = $0001             ; MMU I/O Control Register
	MMU_IO_PAGE_0 = $00
	MMU_IO_PAGE_1 = $01
	MMU_IO_TEXT   = $02
	MMU_IO_COLOR  = $03
MMU_MEM_BANK_0      = $0008          ; MMU Edit Register for bank 0 ($0000 - $1FFF)
MMU_MEM_BANK_1      = $0009          ; MMU Edit Register for bank 1 ($2000 - $3FFF)
MMU_MEM_BANK_2      = $000A          ; MMU Edit Register for bank 2 ($4000 - $5FFF)
MMU_MEM_BANK_3      = $000B          ; MMU Edit Register for bank 3 ($6000 - $7FFF)
MMU_MEM_BANK_4      = $000C          ; MMU Edit Register for bank 4 ($8000 - $9FFF)
MMU_MEM_BANK_5      = $000D          ; MMU Edit Register for bank 5 ($A000 - $BFFF)
MMU_MEM_BANK_6      = $000E          ; MMU Edit Register for bank 6 ($C000 - $DFFF)
MMU_MEM_BANK_7      = $000F          ; MMU Edit Register for bank 7 ($E000 - $FFFF)

;SDCard_Controller_def.asm

;SDC_VERSION_REG         = $DD00    ; Ought to read 12
;SDC_CONTROL_REG         = $DD01    ; Bit0 1 = Reset core logic, and registers. Self clearing
;SDC_TRANS_TYPE_REG      = $DD02  ; Bit[1:0]
;SDC_TRANS_DIRECT      = $00   ; 00 = Direct Access
;SDC_TRANS_INIT_SD     = $01   ; 01 = Init SD
;SDC_TRANS_READ_BLK    = $02   ; 10 = RW_READ_BLOCK (512 Bytes)
;SDC_TRANS_WRITE_BLK   = $03   ; 11 = RW_WRITE_SD_BLOCK
;SDC_TRANS_CONTROL_REG   = $DD03
;SDC_TRANS_START         = $01
;SDC_TRANS_STATUS_REG    = $DD04
;SDC_TRANS_BUSY          = $01     ;  1= Transaction Busy
;SDC_TRANS_ERROR_REG     = $DD05
;SDC_TRANS_INIT_NO_ERR   = $00   ; Init Error Report [1:0]
;SDC_TRANS_INIT_CMD0_ERR = $01
;SDC_TRANS_INIT_CMD1_ERR = $02
;SDC_TRANS_RD_NO_ERR     = $00   ; Read Error Report [3:2]
;SDC_TRANS_RD_CMD_ERR    = $04
;SDC_TRANS_RD_TOKEN_ERR  = $08
;SDC_TRANS_WR_NO_ERR     = $00   ; Write Report Error  [5:4]
;SDC_TRANS_WR_CMD_ERR    = $10   ;
;SDC_TRANS_WR_DATA_ERR   = $20
;SDC_TRANS_WR_BUSY_ERR   = $30
;SDC_DIRECT_ACCESS_REG   = $DD06 ; SPI Direct Read and Write - Set DATA before initiating direct Access Transaction
;SDC_SD_ADDR_7_0_REG     = $DD07 ; Set the ADDR before a block read or block write
;SDC_SD_ADDR_15_8_REG    = $DD08 ; Addr0 [8:0] Always should be 0, since each block is 512Bytes
;SDC_SD_ADDR_23_16_REG   = $DD09
;SDC_SD_ADDR_31_24_REG   = $DD0A
;SDC_SPI_CLK_DEL_REG     = $DD0B
;SDC_RX_FIFO_DATA_REG    = $DD10 ; Data from the Block Read
;SDC_RX_FIFO_DATA_CNT_HI = $DD12 ; How many Bytes in the FIFO HI
;SDC_RX_FIFO_DATA_CNT_LO = $DD13 ; How many Bytes in the FIFO LO
;SDC_RX_FIFO_CTRL_REG    = $DD14 ; Bit0  Force Empty - Set to 1 to clear FIFO, self clearing (the bit)
;SDC_TX_FIFO_DATA_REG    = $DD20 ; Write Data Block here
;SDC_TX_FIFO_CTRL_REG    = $DD24 ; Bit0  Force Empty - Set to 1 to clear FIFO, self clearing (the bit)


;interrupt_def.asm

INT_PENDING_REG0 = $D660 ;
INT_PENDING_REG1 = $D661 ;
;INT_PENDING_REG2 = $D662 ; NOT USED
;INT_PENDING_REG3 = $D663 ; NOT USED
INT_POL_REG0     = $D664 ;
INT_POL_REG1     = $D665 ;
;INT_POL_REG2     = $D666 ;  NOT USED
;INT_POL_REG3     = $D667 ; NOT USED
INT_EDGE_REG0    = $D668 ;
INT_EDGE_REG1    = $D669 ;
;INT_EDGE_REG2    = $D66A ; NOT USED
;INT_EDGE_REG3    = $D66B ; NOT USED
INT_MASK_REG0    = $D66C ;
INT_MASK_REG1    = $D66D ;
;INT_MASK_REG2    = $D66E ; NOT USED
;INT_MASK_REG3    = $D66F ; NOT USED
JR0_INT00_SOF        = $01  ;Start of Frame @ 60FPS
JR0_INT01_SOL        = $02  ;Start of Line (Programmable)
JR0_INT02_KBD        = $04  ;
JR0_INT03_MOUSE      = $08  ;
JR0_INT04_TMR0       = $10  ;
JR0_INT05_TMR1       = $20  ;Real-Time Clock Interrupt
JR0_INT06_DMA        = $40  ;Floppy Disk Controller
JR0_INT07_TBD        = $80  ; Mouse Interrupt (INT12 in SuperIO IOspace)
JR1_INT00_UART       = $01  ;Keyboard Interrupt
JR1_INT01_COL0       = $02  ;TYVKY Collision TBD
JR1_INT02_COL1       = $04  ;TYVKY Collision TBD
JR1_INT03_COL2       = $08  ;TYVKY Collision TBD
JR1_INT04_RTC        = $10  ;Serial Port 1
JR1_INT05_VIA        = $20  ;Midi Controller Interrupt
JR1_INT06_IEC        = $40  ;Parallel Port
JR1_INT07_SDCARD     = $80  ;SDCard Insert


;RTC_def.asm

;RTC_SEC       = $D690 ;Seconds Register
;RTC_SEC_ALARM = $D691 ;Seconds Alarm Register
;RTC_MIN       = $D692 ;Minutes Register
;RTC_MIN_ALARM = $D693 ;Minutes Alarm Register
;RTC_HRS       = $D694 ;Hours Register
;RTC_HRS_ALARM = $D695 ;Hours Alarm Register
;RTC_DAY       = $D696 ;Day Register
;RTC_DAY_ALARM = $D697 ;Day Alarm Register
;RTC_DOW       = $D698 ;Day of Week Register
;RTC_MONTH     = $D699 ;Month Register
;RTC_YEAR      = $D69A ;Year Register
;RTC_RATES     = $D69B ;Rates Register
;RTC_ENABLE    = $D69C ;Enables Register
;RTC_FLAGS     = $D69D ;Flags Register
;RTC_CTRL      = $D69E ;Control Register
;RTC_CENTURY   = $D69F ;Century Register


;VIA_def.asm

VIA_ORB_IRB     = $DC00 ;Output/Input Register Port B
VIA_ORA_IRA     = $DC01 ;Output/Input Register Port B
VIA_DDRB        = $DC02 ;Data Direction Port B
VIA_DDRA        = $DC03 ;Data Direction Port A
VIA_T1CL        = $DC04 ;T1C-L
VIA_T1CH        = $DC05 ;T1C-H
VIA_T1LL        = $DC06 ;T1L-L
VIA_T1LH        = $DC07 ;T1L-H
VIA_T2CL        = $DC08 ;T2C-L
VIA_T2CH        = $DC09 ;T2C-H
VIA_SR          = $DC0A ;SR
VIA_ACR         = $DC0B ;ACR
VIA_PCR         = $DC0C ;PCR
VIA_IFR         = $DC0D ;IFR
VIA_IER         = $DC0E ;IER
VIA_ORA_IRA_AUX = $DC0F ;ORA/IRA
JOY_UP         = $01
JOY_DWN        = $02
JOY_LFT        = $04
JOY_RGT        = $08
JOY_BUT0       = $10
JOY_BUT1       = $20
JOY_BUT2       = $40
;JOYA_UP         = $01
;JOYA_DWN        = $02
;JOYA_LFT        = $04
;JOYA_RGT        = $08
;JOYA_BUT0       = $10
;JOYA_BUT1       = $20
;JOYA_BUT2       = $40
;JOYB_UP         = $01
;JOYB_DWN        = $02
;JOYB_LFT        = $04
;JOYB_RGT        = $08
;JOYB_BUT0       = $10
;JOYB_BUT1       = $20
;JOYB_BUT2       = $40


;Simple_UART_Jr_def.asm

;UART_TRHB 	= $D630        ; Transmit/Receive Hold Buffer
;UART_DLL 	= $D630        ; Divisor Latch Low Byte
;UART_DLH 	= $D631        ; Divisor Latch High Byte
;UART_IER 	= $D631        ; Interupt Enable Register
;UART_FCR 	= $D632        ; FIFO Control Register
;UART_IIR 	= $D632        ; Interupt Indentification Register
;UART_LCR 	= $D633        ; Line Control Register
;UART_MCR 	= $D634        ; Modem Control REgister
;UART_LSR 	= $D635        ; Line Status Register
;UART_MSR 	= $D636        ; Modem Status Register
;UART_SR 	= $D637        ; Scratch Register
;UINT_LOW_POWER = $20        ; Enable Low Power Mode (16750)
;UINT_SLEEP_MODE = $10       ; Enable Sleep Mode (16750)
;UINT_MODEM_STATUS = $08     ; Enable Modem Status Interrupt
;UINT_LINE_STATUS = $04      ; Enable Receiver Line Status Interupt
;UINT_THR_EMPTY = $02        ; Enable Transmit Holding Register Empty interrupt
;UINT_DATA_AVAIL = $01       ; Enable Recieve Data Available interupt
;IIR_FIFO_ENABLED = $80      ; FIFO is enabled
;IIR_FIFO_NONFUNC = $40      ; FIFO is not functioning
;IIR_FIFO_64BYTE = $20       ; 64 byte FIFO enabled (16750)
;IIR_MODEM_STATUS = $00      ; Modem Status Interrupt
;IIR_THR_EMPTY = $02         ; Transmit Holding Register Empty Interrupt
;IIR_DATA_AVAIL = $04        ; Data Available Interrupt
;IIR_LINE_STATUS = $06       ; Line Status Interrupt
;IIR_TIMEOUT = $0C           ; Time-out Interrupt (16550 and later)
;IIR_INTERRUPT_PENDING = $01 ; Interrupt Pending Flag
;LCR_DLB = $80               ; Divisor Latch Access Bit
;LCR_SBE = $60               ; Set Break Enable
;LCR_PARITY_NONE = $00       ; Parity: None
;LCR_PARITY_ODD = $08        ; Parity: Odd
;LCR_PARITY_EVEN = $18       ; Parity: Even
;LCR_PARITY_MARK = $28       ; Parity: Mark
;LCR_PARITY_SPACE = $38      ; Parity: Space
;LCR_STOPBIT_1 = $00         ; One Stop Bit
;LCR_STOPBIT_2 = $04         ; 1.5 or 2 Stop Bits
;LCR_DATABITS_5 = $00        ; Data Bits: 5
;LCR_DATABITS_6 = $01        ; Data Bits: 6
;LCR_DATABITS_7 = $02        ; Data Bits: 7
;LCR_DATABITS_8 = $03        ; Data Bits: 8
;LSR_ERR_RECIEVE = $80       ; Error in Received FIFO
;LSR_XMIT_DONE = $40         ; All data has been transmitted
;LSR_XMIT_EMPTY = $20        ; Empty transmit holding register
;LSR_BREAK_INT = $10         ; Break interrupt
;LSR_ERR_FRAME = $08         ; Framing error
;LSR_ERR_PARITY = $04        ; Parity error
;LSR_ERR_OVERRUN = $02       ; Overrun error
;LSR_DATA_AVAIL = $01        ; Data is ready in the receive buffer


;TinyVicky_Def.asm

MASTER_CTRL_REG_L	    = $D000
Mstr_Ctrl_Text_Mode_En  = $01       ; Enable the Text Mode
Mstr_Ctrl_Text_Overlay  = $02       ; Enable the Overlay of the text mode on top of Graphic Mode (the Background Color is ignored)
Mstr_Ctrl_Graph_Mode_En = $04       ; Enable the Graphic Mode
Mstr_Ctrl_Bitmap_En     = $08       ; Enable the Bitmap Module In Vicky
Mstr_Ctrl_TileMap_En    = $10       ; Enable the Tile Module in Vicky
Mstr_Ctrl_Sprite_En     = $20       ; Enable the Sprite Module in Vicky
Mstr_Ctrl_GAMMA_En      = $40       ; this Enable the GAMMA correction - The Analog and DVI have different color value, the GAMMA is great to correct the difference
Mstr_Ctrl_Disable_Vid   = $80       ; This will disable the Scanning of the Video hence giving 100% bandwith to the CPU
MASTER_CTRL_REG_H	    = $D001
Mstr_Ctrl_Video_Mode    = $01       ; 0 - 640x480@60Hz : 1 - 640x400@70hz (text mode) // 0 - 320x240@60hz : 1 - 320x200@70Hz (Graphic Mode & Text mode when Doubling = 1)
Mstr_Ctrl_Text_XDouble   = $02       ; X Pixel Doubling
Mstr_Ctrl_Text_YDouble   = $04       ; Y Pixel Doubling
LAYER_CTRL_REG_0        = $D002
LAYER_CTRL_REG_1        = $D003
BORDER_CTRL_REG         = $D004 ; Bit[0] - Enable (1 by default)  Bit[4..6]: X Scroll Offset ( Will scroll Left) (Acceptable Value: 0..7)
Border_Ctrl_Enable      = $01
BORDER_COLOR_B          = $D005
BORDER_COLOR_G          = $D006
BORDER_COLOR_R          = $D007
BORDER_X_SIZE           = $D008; X-  Values: 0 - 32 (Default: 32)
BORDER_Y_SIZE           = $D009; Y- Values 0 -32 (Default: 32)
;VKY_RESERVED_02         = $D00A
;VKY_RESERVED_03         = $D00B
;VKY_RESERVED_04         = $D00C
BACKGROUND_COLOR_B      = $D00D ; When in Graphic Mode, if a pixel is "0" then the Background pixel is chosen
BACKGROUND_COLOR_G      = $D00E
BACKGROUND_COLOR_R      = $D00F ;
VKY_TXT_CURSOR_CTRL_REG = $D010   ;[0]  Enable Text Mode
Vky_Cursor_Enable       = $01
Vky_Cursor_Flash_Rate0  = $02
Vky_Cursor_Flash_Rate1  = $04
VKY_TXT_START_ADD_PTR   = $D011   ; This is an offset to change the Starting address of the Text Mode Buffer (in x)
VKY_TXT_CURSOR_CHAR_REG = $D012
VKY_TXT_CURSOR_COLR_REG = $D013
VKY_TXT_CURSOR_X_REG_L  = $D014
VKY_TXT_CURSOR_X_REG_H  = $D015
VKY_TXT_CURSOR_Y_REG_L  = $D016
VKY_TXT_CURSOR_Y_REG_H  = $D017
VKY_LINE_IRQ_CTRL_REG   = $D018 ;[0] - Enable Line 0 - WRITE ONLY
VKY_LINE_CMP_VALUE_LO  = $D019 ;Write Only [7:0]
VKY_LINE_CMP_VALUE_HI  = $D01A ;Write Only [3:0]
VKY_PIXEL_X_POS_LO     = $D018 ; This is Where on the video line is the Pixel
VKY_PIXEL_X_POS_HI     = $D019 ; Or what pixel is being displayed when the register is read
VKY_LINE_Y_POS_LO      = $D01A ; This is the Line Value of the Raster
VKY_LINE_Y_POS_HI      = $D01B ;
TyVKY_BM0_CTRL_REG       = $D100
BM0_Ctrl                = $01       ; Enable the BM0
BM0_LUT0                = $02       ; LUT0
BM0_LUT1                = $04       ; LUT1
TyVKY_BM0_START_ADDY_L   = $D101
TyVKY_BM0_START_ADDY_M   = $D102
TyVKY_BM0_START_ADDY_H   = $D103
TyVKY_BM1_CTRL_REG       = $D108
BM1_Ctrl                = $01       ; Enable the BM0
BM1_LUT0                = $02       ; LUT0
BM1_LUT1                = $04       ; LUT1
TyVKY_BM1_START_ADDY_L   = $D109
TyVKY_BM1_START_ADDY_M   = $D10A
TyVKY_BM1_START_ADDY_H   = $D10B
TyVKY_BM2_CTRL_REG       = $D110
BM2_Ctrl                = $01       ; Enable the BM0
BM2_LUT0                = $02       ; LUT0
BM2_LUT1                = $04       ; LUT1
BM2_LUT2                = $08       ; LUT2
TyVKY_BM2_START_ADDY_L   = $D111
TyVKY_BM2_START_ADDY_M   = $D112
TyVKY_BM2_START_ADDY_H   = $D113
TyVKY_TL_CTRL0          = $D200
TILE_Enable             = $01
TILE_LUT0               = $02
TILE_LUT1               = $04
TILE_LUT2               = $08
TILE_SIZE               = $10   ; 0 -> 16x16, 0 -> 8x8
TL0_CONTROL_REG         = $D200       ; Bit[0] - Enable, Bit[3:1] - LUT Select,
TL0_START_ADDY_L        = $D201       ; Not USed right now - Starting Address to where is the MAP
TL0_START_ADDY_M        = $D202
TL0_START_ADDY_H        = $D203
TL0_MAP_X_SIZE_L        = $D204       ; The Size X of the Map
TL0_MAP_X_SIZE_H        = $D205
TL0_MAP_Y_SIZE_L        = $D206       ; The Size Y of the Map
TL0_MAP_Y_SIZE_H        = $D207
TL0_MAP_X_POS_L         = $D208       ; The Position X of the Map
TL0_MAP_X_POS_H         = $D209
TL0_MAP_Y_POS_L         = $D20A       ; The Position Y of the Map
TL0_MAP_Y_POS_H         = $D20B
TL1_CONTROL_REG         = $D20C       ; Bit[0] - Enable, Bit[3:1] - LUT Select,
TL1_START_ADDY_L        = $D20D       ; Not USed right now - Starting Address to where is the MAP
TL1_START_ADDY_M        = $D20E
TL1_START_ADDY_H        = $D20F
TL1_MAP_X_SIZE_L        = $D210       ; The Size X of the Map
TL1_MAP_X_SIZE_H        = $D211
TL1_MAP_Y_SIZE_L        = $D212       ; The Size Y of the Map
TL1_MAP_Y_SIZE_H        = $D213
TL1_MAP_X_POS_L         = $D214       ; The Position X of the Map
TL1_MAP_X_POS_H         = $D215
TL1_MAP_Y_POS_L         = $D216       ; The Position Y of the Map
TL1_MAP_Y_POS_H         = $D217
TL2_CONTROL_REG         = $D218       ; Bit[0] - Enable, Bit[3:1] - LUT Select,
TL2_START_ADDY_L        = $D219       ; Not USed right now - Starting Address to where is the MAP
TL2_START_ADDY_M        = $D21A
TL2_START_ADDY_H        = $D21B
TL2_MAP_X_SIZE_L        = $D21C       ; The Size X of the Map
TL2_MAP_X_SIZE_H        = $D21D
TL2_MAP_Y_SIZE_L        = $D21E       ; The Size Y of the Map
TL2_MAP_Y_SIZE_H        = $D21F
TL2_MAP_X_POS_L         = $D220       ; The Position X of the Map
TL2_MAP_X_POS_H         = $D221
TL2_MAP_Y_POS_L         = $D222       ; The Position Y of the Map
TL2_MAP_Y_POS_H         = $D223
TILE_MAP_ADDY0_L      = $D280
TILE_MAP_ADDY0_M      = $D281
TILE_MAP_ADDY0_H      = $D282
TILE_MAP_ADDY0_CFG    = $D283
TILE_MAP_ADDY1      = $D284
TILE_MAP_ADDY2      = $D288
TILE_MAP_ADDY3      = $D28C
TILE_MAP_ADDY4      = $D290
TILE_MAP_ADDY5      = $D294
TILE_MAP_ADDY6      = $D298
TILE_MAP_ADDY7      = $D29C
XYMATH_CTRL_REG     = $D300 ; Reserved
XYMATH_ADDY_L       = $D301 ; W
XYMATH_ADDY_M       = $D302 ; W
XYMATH_ADDY_H       = $D303 ; W
XYMATH_ADDY_POSX_L  = $D304 ; R/W
XYMATH_ADDY_POSX_H  = $D305 ; R/W
XYMATH_ADDY_POSY_L  = $D306 ; R/W
XYMATH_ADDY_POSY_H  = $D307 ; R/W
XYMATH_BLOCK_OFF_L  = $D308 ; R Only - Low Block Offset
XYMATH_BLOCK_OFF_H  = $D309 ; R Only - Hi Block Offset
XYMATH_MMU_BLOCK    = $D30A ; R Only - Which MMU Block
XYMATH_ABS_ADDY_L   = $D30B ; Low Absolute Results
XYMATH_ABS_ADDY_M   = $D30C ; Mid Absolute Results
XYMATH_ABS_ADDY_H   = $D30D ; Hi Absolute Results
SPRITE_Ctrl_Enable = $01
SPRITE_LUT0        = $02
SPRITE_LUT1        = $04
SPRITE_DEPTH0      = $08    ; 00 = Total Front - 01 = In between L0 and L1, 10 = In between L1 and L2, 11 = Total Back
SPRITE_DEPTH1      = $10
SPRITE_SIZE0       = $20    ; 00 = 32x32 - 01 = 24x24 - 10 = 16x16 - 11 = 8x8
SPRITE_SIZE1       = $40
SP0_Ctrl           = $D900
SP0_Addy_L         = $D901
SP0_Addy_M         = $D902
SP0_Addy_H         = $D903
SP0_X_L            = $D904
SP0_X_H            = $D905
SP0_Y_L            = $D906  ; In the Jr, only the L is used (200 & 240)
SP0_Y_H            = $D907  ; Always Keep @ Zero '0' because in Vicky the value is still considered a 16bits value
;SP1_Ctrl           = $D908
;SP1_Addy_L         = $D909
;SP1_Addy_M         = $D90A
;SP1_Addy_H         = $D90B
;SP1_X_L            = $D90C
;SP1_X_H            = $D90D
;SP1_Y_L            = $D90E  ; In the Jr, only the L is used (200 & 240)
;SP1_Y_H            = $D90F  ; Always Keep @ Zero '0' because in Vicky the value is still considered a 16bits value
;SP2_Ctrl           = $D910
;SP2_Addy_L         = $D911
;SP2_Addy_M         = $D912
;SP2_Addy_H         = $D913
;SP2_X_L            = $D914
;SP2_X_H            = $D915
;SP2_Y_L            = $D916  ; In the Jr, only the L is used (200 & 240)
;SP2_Y_H            = $D917  ; Always Keep @ Zero '0' because in Vicky the value is still considered a 16bits value
;SP3_Ctrl           = $D918
;SP3_Addy_L         = $D919
;SP3_Addy_M         = $D91A
;SP3_Addy_H         = $D91B
;SP3_X_L            = $D91C
;SP3_X_H            = $D91D
;SP3_Y_L            = $D91E  ; In the Jr, only the L is used (200 & 240)
;SP3_Y_H            = $D91F  ; Always Keep @ Zero '0' because in Vicky the value is still considered a 16bits value
;SP4_Ctrl           = $D920
;SP4_Addy_L         = $D921
;SP4_Addy_M         = $D922
;SP4_Addy_H         = $D923
;SP4_X_L            = $D924
;SP4_X_H            = $D925
;SP4_Y_L            = $D926  ; In the Jr, only the L is used (200 & 240)
;SP4_Y_H            = $D927  ; Always Keep @ Zero '0' because in Vicky the value is still considered a 16bits value
TyVKY_LUT0              = $D000 ; IO Page 1 -$D000 - $D3FF
TyVKY_LUT1              = $D400 ; IO Page 1 -$D400 - $D7FF
TyVKY_LUT2              = $D800 ; IO Page 1 -$D800 - $DBFF
TyVKY_LUT3              = $DC00 ; IO Page 1 -$DC00 - $DFFF



DMA_CTRL_REG        = $DF00
DMA_CTRL_Enable     = $01
DMA_CTRL_1D_2D      = $02
DMA_CTRL_Fill       = $04
DMA_CTRL_Int_En     = $08
;DMA_CTRL_NotUsed0   = $10
;DMA_CTRL_NotUsed1   = $20
;DMA_CTRL_NotUsed2   = $40
DMA_CTRL_Start_Trf  = $80
DMA_DATA_2_WRITE    = $DF01 ; Write Only
DMA_STATUS_REG      = $DF01 ; Read Only
DMA_STATUS_TRF_IP   = $80   ; Transfer in Progress
;DMA_RESERVED_0      = $DF02
;DMA_RESERVED_1      = $DF03
DMA_SOURCE_ADDY_L   = $DF04
DMA_SOURCE_ADDY_M   = $DF05
DMA_SOURCE_ADDY_H   = $DF06
;DMA_RESERVED_2      = $DF07
DMA_DEST_ADDY_L     = $DF08
DMA_DEST_ADDY_M     = $DF09
DMA_DEST_ADDY_H     = $DF0A
;DMA_RESERVED_3      = $DF0B
DMA_SIZE_1D_L       = $DF0C
DMA_SIZE_1D_M       = $DF0D
DMA_SIZE_1D_H       = $DF0E
;DMA_RESERVED_4      = $DF0F
DMA_SIZE_X_L        = $DF0C
DMA_SIZE_X_H        = $DF0D
DMA_SIZE_Y_L        = $DF0E
DMA_SIZE_Y_H        = $DF0F
DMA_SRC_STRIDE_X_L  = $DF10
DMA_SRC_STRIDE_X_H  = $DF11
DMA_DST_STRIDE_Y_L  = $DF12
DMA_DST_STRIDE_Y_H  = $DF13
;DMA_RESERVED_5      = $DF14
;DMA_RESERVED_6      = $DF15
;DMA_RESERVED_7      = $DF16
;DMA_RESERVED_8      = $DF17


;C256_Jr_SID_def.asm

SID_L_V1_FREQ_LO    = $D400 ;SID - L - Voice 1 (Write Only) - FREQ LOW
SID_L_V1_FREQ_HI    = $D401 ;SID - L - Voice 1 (Write Only) - FREQ HI
SID_L_V1_PW_LO      = $D402 ;SID - L - Voice 1 (Write Only) - PW LOW
SID_L_V1_PW_HI      = $D403 ;SID - L - Voice 1 (Write Only) - PW HI
SID_L_V1_CTRL       = $D404 ;SID - L - Voice 1 (Write Only) - CTRL REG
SID_L_V1_ATCK_DECY  = $D405 ;SID - L - Voice 1 (Write Only) - ATTACK / DECAY
SID_L_V1_SSTN_RLSE  = $D406 ;SID - L - Voice 1 (Write Only) - SUSTAIN / RELEASE
SID_L_V2_FREQ_LO    = $D407 ;SID - L - Voice 2 (Write Only) - FREQ LOW
SID_L_V2_FREQ_HI    = $D408 ;SID - L - Voice 2 (Write Only) - FREQ HI
SID_L_V2_PW_LO      = $D409 ;SID - L - Voice 2 (Write Only) - PW LOW
SID_L_V2_PW_HI      = $D40A ;SID - L - Voice 2 (Write Only) - PW HI
SID_L_V2_CTRL       = $D40B ;SID - L - Voice 2 (Write Only) - CTRL REG
SID_L_V2_ATCK_DECY  = $D40C ;SID - L - Voice 2 (Write Only) - ATTACK / DECAY
SID_L_V2_SSTN_RLSE  = $D40D ;SID - L - Voice 2 (Write Only) - SUSTAIN / RELEASE
SID_L_V3_FREQ_LO    = $D40E ;SID - L - Voice 3 (Write Only) - FREQ LOW
SID_L_V3_FREQ_HI    = $D40F ;SID - L - Voice 3 (Write Only) - FREQ HI
SID_L_V3_PW_LO      = $D410 ;SID - L - Voice 3 (Write Only) - PW LOW
SID_L_V3_PW_HI      = $D411 ;SID - L - Voice 3 (Write Only) - PW HI
SID_L_V3_CTRL       = $D412 ;SID - L - Voice 3 (Write Only) - CTRL REG
SID_L_V3_ATCK_DECY  = $D413 ;SID - L - Voice 3 (Write Only) - ATTACK / DECAY
SID_L_V3_SSTN_RLSE  = $D414 ;SID - L - Voice 3 (Write Only) - SUSTAIN / RELEASE
SID_L_FC_LO         = $D415 ;SID - L - Filter (Write Only) - FC LOW
SID_L_FC_HI         = $D416 ;SID - L - Filter (Write Only) - FC HI
SID_L_RES_FILT      = $D417 ;SID - L - Filter (Write Only) - RES / FILT
SID_L_MODE_VOL      = $D418 ;SID - L - Filter (Write Only) - MODE / VOL
SID_L_POT_X         = $D419 ;SID - L - Misc (Read Only) - POT X (C256 - NOT USED)
SID_L_POT_Y         = $D41A ;SID - L - Misc (Read Only) - POT Y (C256 - NOT USED)
SID_L_OSC3_RND      = $D41B ;SID - L - Misc (Read Only) - OSC3 / RANDOM
SID_L_ENV3          = $D41C ;SID - L - Misc (Read Only)  - ENV3
;SID_L_NOT_USED0     = $D41D ;SID - L - NOT USED
;SID_L_NOT_USED1     = $D41E ;SID - L - NOT USED
;SID_L_NOT_USED2     = $D41F ;SID - L - NOT USED
SID_R_V1_FREQ_LO    = $D500 ;SID - R - Voice 1 (Write Only) - FREQ LOW
SID_R_V1_FREQ_HI    = $D501 ;SID - R - Voice 1 (Write Only) - FREQ HI
SID_R_V1_PW_LO      = $D502 ;SID - R - Voice 1 (Write Only) - PW LOW
SID_R_V1_PW_HI      = $D503 ;SID - R - Voice 1 (Write Only) - PW HI
SID_R_V1_CTRL       = $D504 ;SID - R - Voice 1 (Write Only) - CTRL REG
SID_R_V1_ATCK_DECY  = $D505 ;SID - R - Voice 1 (Write Only) - ATTACK / DECAY
SID_R_V1_SSTN_RLSE  = $D506 ;SID - R - Voice 1 (Write Only) - SUSTAIN / RELEASE
SID_R_V2_FREQ_LO    = $D507 ;SID - R - Voice 2 (Write Only) - FREQ LOW
SID_R_V2_FREQ_HI    = $D508 ;SID - R - Voice 2 (Write Only) - FREQ HI
SID_R_V2_PW_LO      = $D509 ;SID - R - Voice 2 (Write Only) - PW LOW
SID_R_V2_PW_HI      = $D50A ;SID - R - Voice 2 (Write Only) - PW HI
SID_R_V2_CTRL       = $D50B ;SID - R - Voice 2 (Write Only) - CTRL REG
SID_R_V2_ATCK_DECY  = $D50C ;SID - R - Voice 2 (Write Only) - ATTACK / DECAY
SID_R_V2_SSTN_RLSE  = $D50D ;SID - R - Voice 2 (Write Only) - SUSTAIN / RELEASE
SID_R_V3_FREQ_LO    = $D50E ;SID - R - Voice 3 (Write Only) - FREQ LOW
SID_R_V3_FREQ_HI    = $D50F ;SID - R - Voice 3 (Write Only) - FREQ HI
SID_R_V3_PW_LO      = $D510 ;SID - R - Voice 3 (Write Only) - PW LOW
SID_R_V3_PW_HI      = $D511 ;SID - R - Voice 3 (Write Only) - PW HI
SID_R_V3_CTRL       = $D512 ;SID - R - Voice 3 (Write Only) - CTRL REG
SID_R_V3_ATCK_DECY  = $D513 ;SID - R - Voice 3 (Write Only) - ATTACK / DECAY
SID_R_V3_SSTN_RLSE  = $D514 ;SID - R - Voice 3 (Write Only) - SUSTAIN / RELEASE
SID_R_FC_LO         = $D515 ;SID - R - Filter (Write Only) - FC LOW
SID_R_FC_HI         = $D516 ;SID - R - Filter (Write Only) - FC HI
SID_R_RES_FILT      = $D517 ;SID - R - Filter (Write Only) - RES / FILT
SID_R_MODE_VOL      = $D518 ;SID - R - Filter (Write Only) - MODE / VOL
SID_R_POT_X         = $D519 ;SID - R - Misc (Read Only) - POT X (C256 - NOT USED)
SID_R_POT_Y         = $D51A ;SID - R - Misc (Read Only) - POT Y (C256 - NOT USED)
SID_R_OSC3_RND      = $D51B ;SID - R - Misc (Read Only) - OSC3 / RANDOM
SID_R_ENV3          = $D51C ;SID - R - Misc (Read Only)  - ENV3
;SID_R_NOT_USED0     = $D51D ;SID - R - NOT USED
;SID_R_NOT_USED1     = $D51E ;SID - R - NOT USED
;SID_R_NOT_USED2     = $D51F ;SID - R - NOT USED

PSG_INT_L_PORT = $D600          ; Control register for the SN76489
PSG_INT_R_PORT = $D610          ; Control register for the SN76489


VECTORS_BEGIN   = $FFFA ;0 Byte  Interrupt vectors
VECTOR_NMI      = $FFFA ;2 Bytes Emulation mode interrupt handler
VECTOR_RESET    = $FFFC ;2 Bytes Emulation mode interrupt handler
VECTOR_IRQ      = $FFFE ;2 Bytes Emulation mode interrupt handler
;ISR_BEGIN       = $FF00 ; Byte  Beginning of CPU vectors in Direct page
;HRESET          = $FF00 ;16 Bytes Handle RESET asserted. Reboot computer and re-initialize the kernel.
;HCOP            = $FF10 ;16 Bytes Handle the COP instruction. Program use; not used by OS
;HBRK            = $FF20 ;16 Bytes Handle the BRK instruction. Returns to BASIC Ready prompt.
;HABORT          = $FF30 ;16 Bytes Handle ABORT asserted. Return to Ready prompt with an error message.
;HNMI            = $FF40 ;32 Bytes Handle NMI
;HIRQ            = $FF60 ;32 Bytes Handle IRQ



KEYBOARD_SC_TMP     = $20
KBD_MSE_CTRL_REG    = $D640
KBD_Write_Strobe    = $02
MS_Write_Strobe     = $08
KBD_FIFO_CLEAR      = $10 ; Dump entire FIFO, set to 1 and then back to 0
MSE_FIFO_CLEAR      = $20 ; Dump entire FIFO, set to 1 and then back to 0
KBD_MS_WR_DATA_REG  = $D641      ; Data to Send to Keyboard or Mouse
KBD_RD_SCAN_REG     = $D642         ; DATA Out from KBD FIFO
MS_RD_SCAN_REG      = $D643          ; DATA Out from MSE FIFO
KBD_MS_RD_STATUS    = $D644       ; Keyboard RD/WR Status
KBD_FIFO_Empty           = $01           ; Set when Keyboard FIFO is empty
MSE_FIFO_Empty           = $02           ; Set when Mouse FIFO is empty
MS_Stat_Tx_Error_No_Ack  = $10
MS_Stat_Tx_Ack           = $20            ; When 1, it ack the Tx
KBD_Stat_Tx_Error_No_Ack = $40
KBD_Stat_Tx_Ack          = $80            ; When 1, it ack the Tx
KBD_MSE_NOT_USED    = $D645;       ; Reads as 0
KBD_FIFO_BYTE_CNT   = $D646       ; Number of Bytes in the Keyboard FIFO
MSE_FIFO_BYTE_CNT   = $D647       ; Number of Bytes in the Mouse FIFO



TEXT_LUT_FG      = $D800
TEXT_LUT_BG		 = $D840
FONT_MEM         = $C000 	; IO Page 1
TEXT_MEM         = $C000 	; IO Page 2
COLOR_MEM        = $C000 	; IO Page 3
DIPSWITCH        = $D670
CODEC_LOW        = $D620
CODEC_HI         = $D621
CODEC_CTRL       = $D622

RNG_DAT_LO     = $D6A4 ; Low Part of 16Bit RNG Generator
RNG_DAT_HI     = $D6A5 ; Hi Part of 16Bit RNG Generator
RNG_SEED_LO    = $D6A4 ; Low Part of 16Bit RNG Generator
RNG_SEED_HI    = $D6A5 ; Hi Part of 16Bit RNG Generator
RNG_CTRL       = $D6A6
	RNG_SEED_LD = $02
	RNG_ENABLE  = $01
RNG_STAT       = $D6A6
RNG_LFSR_DONE = $80 ; ???indicates that Output = SEED Database

FOENIX_MACHINE_ID = $D6A7



; tilemap base = $d200
TVKY_TILEMAP        = $D200
struct TILEMAP_TYPE(actrl,aaddr,axsize,aysize,axpos,aypos)
	CONTROL byte actrl
	ADDRESS long aaddr
	XSIZE word axsize
	YSIZE word aysize
	XPOS word axpos
	YPOS word aypos
endstruct

; bitmap base = $d100
TVKY_BITMAP         = $D100
struct BITMAP_TYPE(actrl,aaddr)
	CONTROL byte actrl
	ADDRESS long aaddr
endstruct

; tileset base = $d280
TVKY_TILESET        = $D280
struct TILESET_TYPE(aaddr,aconfig)
	ADDRESS long aaddr
	CONFIG byte aconfig
endstruct

; sprite base = $d900
TVKY_SPRITE         = $D900
struct SPRITE_TYPE(actrl,aaddr,axpos,aypos)
	CONTROL byte actrl
	ADDRESS long aaddr
	XPOS word axpos
	YPOS word aypos
endstruct

; left sid base = $d400
SID_LEFT            = $D400
; right sid base = $d500
SID_RIGHT           = $D500

