; variable/data section
MY_EXTENDED_RAM: SECTION
; Insert here your data definition.
sum ds.b 1
N ds.b 1
values ds.b 6

; code section
MyCode:     SECTION
main:
_Startup:
Entry:

           
            LDY #values
            
            ;Enter values:
            MOVB #12, 0,Y
            MOVB #2, 1,Y
            MOVB #17, 2,Y
            MOVB #6, 3,Y
            MOVB #1, 4,Y
            MOVB #0, 5,Y
            
            ;Enter value for N:
            MOVB #5,N            
            
            
            LDAA #0
            LDX #0
            
            
branch:            
            LDAB Y    
            ABA
            INY
            INX
            TFR X,B
            CMPB N
            BLO branch
            
            
            ;exit loop
            STAA sum
           
            
            ;turns light on
            MOVB #$1,DDRA
            MOVB #$0,PORTA            


                       
    
            LDX #$32

Loopb:      LDD #$FFFF
Loop:       NOP
            DBNE D,Loop
            DBNE X,Loopb     
            
           
           
           
            LDAA sum
            LDAB #50
            CBA
            BLS lower
            ;turns light off
            MOVB #$0,DDRA
            MOVB #$1,PORTA
            
lower:            
Always:     BRA Always
