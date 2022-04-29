; Kernel jump points

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PUTS - Print a string to the currently selected channel.
; Preconditions: 
;		X/Y are in 16 bit mode.
;		X contains address of string.
;		DBR contains the data bank of the string.
;
; Postconditions:
;		X is scrambled.

PUTS = $00101C                     
