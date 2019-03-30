
;**************************************************************
;* This program serves as a sample code to test the           *
;* "Terminal" component when using a "Full Chip simulation".  *
;* When you execute this program, a "Hello! Please enter ..." *
;* message shows up in the terminal window.                   *
;*                                                            *
;* To open a Terminal window, use the menu "Component",       *
;* sub-menu "Open" within the debug window environment, and   *
;* click on the Terminal icon.                                *
;* Press the right mouse button and select the "Configure     *
;* Connection" option.  Then select the "Virtual SCI" as the  *
;* default configuration.  As to the virtual SCI input/output *
;* ports, replace Sci0 with Sci. For example,                 *
;* Sci0.SerialOutput becomes Sci.SerialOutput                 *
;**************************************************************
; Include derivative-specific definitions
            INCLUDE 'derivative.inc'

; export symbols
            XDEF Entry, _Startup, main
            ; we use export 'Entry' as symbol. This allows us to
            ; reference 'Entry' either in the linker .prm file
            ; or from C/C++ later on

            XREF __SEG_END_SSTACK ; symbol defined by the linker for the end of the stack


; Constant Data Section
DATA: SECTION
Hello_msg    dc.b "Enter a value for N between 2-5"
Newline      dc.b $0a
EndofHello   dc.b 0
nValues      dc.b "Enter what values you would like to be stored in N."
Newline2     dc.b $0a
Endofvalues  dc.b 0
Receive_ms1g dc.b "Received: "
EndofRecv    dc.b 0
             
; Variable Data Section
MY_EXTENDED_RAM: SECTION
val         ds.b  1
n           ds.b  1
nArray      ds.b  5
negVal      ds.b  1
tempVal     ds.b  1
sum         ds.b  1
temp        ds.b  1
negate      ds.b  1
; Code Section
MyCode:     SECTION
main:
_Startup:
Entry:
; Set up the SP for subroutine calls
          LDS   #__SEG_END_SSTACK
          
; Initialize SCI control registers
          JSR   SCI_init
          
; Print out the "Hello ..."
          LDX   #Hello_msg      
          JSR   writeStr
 
; Receive one character
          CLR   SCISR1
          LEAS  -1,SP
          BSR   readValue
          MOVB  0,SP,n
          LEAS  1,SP
               
         
; Print out the "Received: "
          LDX   #nValues
          JSR   writeStr

; Print out the received character

          LDX   #0
          LDAB  n
          ABX
          LDY   #nArray
 getVal:  LEAS  -1,SP
          BSR   readValue
          MOVB  0,SP, 0,Y
          LEAS  1,SP
          INY
          DBNE  X,getVal
          
;adding up values  
          LDAB   n
          PSHB
          LDX    #nArray
          PSHX   
          JSR    addingVals
          STAA   sum
          LEAS   3,SP
          
; A subroutine to print out a string
; Register X stores the starting address of the string
writeStr: LDAB  0,x
          CMPB  #$0
          BEQ   complete
loop3:    BRSET SCISR1, #$80, action3
          BRA   loop3        
action3:  STAB  SCIDRL
          INX  
          BRA   writeStr
complete: RTS

; A subroutine to initialize the SCI port
; No need for any argument
SCI_init: LDAA  #$4c
          STAA  SCICR1
          LDAA  #$0c
          STAA  SCICR2
          LDAA  #52
          STAA  SCIBDL
          RTS
        
;readValue subroutine
readValue:CLR   tempVal
          CLR   negVal
          CLRB  
loop4:    BRSET SCISR1, #$20, action4
          BRA   loop4
          
action4:  BSR	printChar
	        LDAA  #$0D
          CMPA  SCIDRL
	  BEQ   endLoop
	  LDAA  #$2D
          CMPA  SCIDRL
          BEQ   handelingNeg
	  CMPB  #$0d
	  LDAA  SCIDRL     
          SUBA  #'0'       
          STAA  temp       
          LDAA  #10        
          MUL             
          ADDB  temp       
          BRA   loop4      
          

endLoop:  BRCLR negate, #$01, finished  
          NEGB
                      
finished:	STAB  2,SP      
          RTS 

handelingNeg:
          MOVB #1,negVal
          BRA loop4                   
 
addingVals:LDX   #0
           LDY   #0
           LDAB  4,SP
           ABX
           LDY   2,SP
           LDAA  #0
adding:    ADDA  0,Y
           INY
           DBNE  X,adding
           RTS 
                    
;printing out the character that was recieved          
printChar:PSHB          
          LDAB  SCIDRL    
no:       BRSET SCISR1, #$80, yes 
          BRA   no     
yes:      STAB  SCIDRL    
          PULB            
          RTS 
          
          
          
             
