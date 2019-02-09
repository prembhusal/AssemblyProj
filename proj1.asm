;**************************************************************
;* This stationery serves as the framework for a              *
;* user application. For a more comprehensive program that    *
;* demonstrates the more advanced functionality of this       *
;* processor, please see the demonstration applications       *
;* located in the examples subdirectory of the                *
;* Freescale CodeWarrior for the HC12 Program directory       *
;**************************************************************
; Include derivative-specific definitions
            INCLUDE 'derivative.inc'

; export symbols
            XDEF Entry, _Startup, main
            ; we use export 'Entry' as symbol. This allows us to
            ; reference 'Entry' either in the linker .prm file
            ; or from C/C++ later on

            XREF __SEG_END_SSTACK      ; symbol defined by the linker for the end of the stack




; variable/data section
DATA:     SECTION
; Insert here your data definition.
hundred     ds.b 1
sign        ds.b 1
tens        ds.b 1
one         ds.b 1
out         ds.b 1

DATA2:    SEction

; code section
Code:     SECTION
main:
_Startup:
Entry:      MOVB  #$FF, DDRP  ; RGB LED: pins 3, 4, 6
            MOVB  #$F7, PTP   ; turn on red LED on pin 3
            ;Convert ascii to binary
            LDAA #'+'
            STAA sign

            LDAA #'1' ;load register a with ascii 1, = 31 in hex
            LDAB #'0'
            SBA
            LDAB $'100'
            MUL
            STAB hundred

            LDAA #'2'
            LDAB #'0'
            SBA
            LDAB $'10'
            MUL
            STAB tens

            LDAA '7'
            LDAB hundred
            ABA
            LDAB tens
            ABA
            STAA out ;out = 1*100+2*10+7 = 127

            ;turn on the red light if - sign is incountered otherwise green

            LDAA sign
            CMPA #'+'
            BEQ equal
            BRA negate


negate:     NEG out
            MOVB  #$FF, DDRP  ; RGB LED: pins 3, 4, 6
            MOVB  #BF, PTP    ; green light on



equal:      STAA out
            MOVB  #$FF, DDRP  ; RGB LED: pins 3, 4, 6
            MOVB  #F7, PTP    ; red light on
            






