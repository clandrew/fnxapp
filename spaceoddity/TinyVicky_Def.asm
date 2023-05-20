; TinyVicky_Def.asm

MASTER_CTRL_REG_L =         $D000  [53248/$D000]
Mstr_Ctrl_Text_Mode_En =    $01  [1/$01]                    ; Enable the Text Mode
Mstr_Ctrl_Text_Overlay =    $02  [2/$02]                    ; Enable the Overlay of the text mode on top of Graphic Mode (the Background Color is ignored)
Mstr_Ctrl_Graph_Mode_En =   $04  [4/$04]                    ; Enable the Graphic Mode
Mstr_Ctrl_Bitmap_En =       $08  [8/$08]                    ; Enable the Bitmap Module In Vicky
Mstr_Ctrl_TileMap_En =      $10  [16/$10]                   ; Enable the Tile Module in Vicky
Mstr_Ctrl_Sprite_En =       $20  [32/$20/" "]               ; Enable the Sprite Module in Vicky
Mstr_Ctrl_GAMMA_En =        $40  [64/$40/"@"]               ; this Enable the GAMMA correction - The Analog and DVI have different color value, the GAMMA is great to correct the difference
Mstr_Ctrl_Disable_Vid =     $80  [128/$80/"?"]              ; This will disable the Scanning of the Video hence giving 100% bandwith to the CPU
MASTER_CTRL_REG_H =         $D001  [53249/$D001]
Mstr_Ctrl_Video_Mode =      $01  [1/$01]                    ; 0 - 640x480@60Hz : 1 - 640x400@70hz (text mode) // 0 - 320x240@60hz : 1 - 320x200@70Hz (Graphic Mode & Text mode when Doubling = 1)
Mstr_Ctrl_Text_XDouble =    $02  [2/$02]                    ; X Pixel Doubling
Mstr_Ctrl_Text_YDouble =    $04  [4/$04]                    ; Y Pixel Doubling
LAYER_CTRL_REG_0 =          $D002  [53250/$D002]
LAYER_CTRL_REG_1 =          $D003  [53251/$D003]
BORDER_CTRL_REG =           $D004  [53252/$D004]            ; Bit[0] - Enable (1 by default)  Bit[4..6]: X Scroll Offset ( Will scroll Left) (Acceptable Value: 0..7)
Border_Ctrl_Enable =        $01  [1/$01]
BORDER_COLOR_B  =           $D005  [53253/$D005]
BORDER_COLOR_G  =           $D006  [53254/$D006]
BORDER_COLOR_R  =           $D007  [53255/$D007]
BORDER_X_SIZE   =           $D008  [53256/$D008]            ; X-  Values: 0 - 32 (Default: 32)
BORDER_Y_SIZE   =           $D009  [53257/$D009]            ; Y- Values 0 -32 (Default: 32)