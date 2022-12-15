; Kernel jump points
PUTS = $00101C                      ; Print a string to the currently selected channel
PUTC = $001018                      ;

; Hardware RESET vector
* = $00FFFC
RESET   .word <>START               ; Over-ride the RESET vector with the start of our code