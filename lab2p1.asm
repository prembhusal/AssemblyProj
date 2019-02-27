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

MY_EXTENDED_RAM: SECTION

; Insert here your data definition.

Counter     ds.w 1

FiboRes     ds.w 1





; code section

MyCode:     SECTION

main:

_Startup:

Entry:

            LDS  #__SEG_END_SSTACK     ; initialize the stack pointer

            CLI                     ; enable interrupts



Always:     LDX #100



            MOVB #$FF,DDRP   

            MOVB #$F7,PTP    ;light on

            

loopb:      LDD #$FFFF

loop:       NOP

            DBNE D, loop

            DBNE X, loopb

            

            

            MOVB #$FF,PTP       ;light off after 4.22 sec

            

            LDX #$32

            

loopc:      LDD #$FFFF 

loopa:      NOP

            DBNE D,loopa

            DBNE X,loopc

            

            BRA Always

            
