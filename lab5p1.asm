
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

            XREF __SEG_END_SSTACK ; symbol defined by the linker for the end of the stack


; Constant Data Section
DATA: SECTION
ValN        dc.b "Enter a value for N "
EndOfN      dc.b 0
ValForArray dc.b "Enter array values one line at a time:"
EndofArray  dc.b $0A ;newline
EndOfLine   dc.b 0

; Variable Data Section
MY_EXTENDED_RAM: SECTION
n         ds.b  1
ArrayOfN  ds.b  5
tmp       ds.b  1
temp      ds.b  1
negVal    ds.b  1
sum       ds.b  1
sumStr    ds.b  5


; Code Section
MyCode:     SECTION
main:
_Startup:
Entry:
; Set up the SP for subroutine calls
          LDS   #__SEG_END_SSTACK
          
; Initialize SCI control registers
          JSR   SCI_init
          
; Prompt to enter N
          LDX   #ValN   
          JSR   writeStr  

; Receive one character
          CLR   SCISR1    
          LEAS  -1,SP    
          BSR   readValue 
          MOVB  0,SP, n   
          LEAS  1,SP      

; Prompt to enter array values
          LDX   #ValForArray 
          JSR   writeStr     
          
; Receive values one character at a time
          LDX   #0        
          LDAB  n         
          ABX             
          LDY   #ArrayOfN    
 getVal:  LEAS  -1,SP     
          BSR   readValue 
          MOVB  0,SP, 0,Y 
          LEAS  1,SP      
          INY             
          DBNE  X, getVal 
          
; Add value logic
          LDAB  n         
          PSHB            
          LDX   #ArrayOfN    
          PSHX            
          JSR   adding  
          STAA  sum        
          LEAS  3,SP      
          
; Print the sum value to the screen
          LDAA  sum       
          PSHA            
          LDX   #sumStr   
          PSHX            
          JSR   char2Str
          
          LDX   #sumStr
          JSR   writeStr  

finish:   BRA   finish 

; Subroutine to read in a value
readValue:CLR   tmp      
          CLR   negVal    
          CLRB            
loop1:    BRSET SCISR1, #$20, action1   
          BRA   loop1     
       
action1:  BSR   printChar  
          LDAA  #$0D       
          CMPA  SCIDRL 
          BEQ   end    
          LDAA  #$2D       
          CMPA  SCIDRL
          BEQ   negative    
          LDAA  SCIDRL     
          SUBA  #'0'       
          STAA  tmp       
          LDAA  #10        
          MUL              
          ADDB  tmp       
          BRA   loop1      
          
negative: MOVB  #1,negVal  
          BRA   loop1
          
endReadVAl:  
	        BRCLR negVal, #$01, end     
          NEGB                           
end:      STAB  2,SP     
          RTS 

; Print out the received character
printChar:PSHB           
          LDAB  SCIDRL    
loop2:    BRSET SCISR1, #$80, action2 
          BRA   loop2     
action2:  STAB  SCIDRL    
          PULB            
          RTS             

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
          
; adds up all the values in the array and then stores the sum to the sum           
adding:   LDX   #0
          LDY   #0
          LDAB  4,SP  
          ABX         
          LDY   2,SP  
          LDAA  #0    
 sumUp:   ADDA  0,Y   
          INY
          DBNE  X, sumUp
          RTS
          
          
;printing the sum to the terminal screen
char2Str: PSHD
          PSHX
          PSHY

          LDY   8,SP       ;Loading Y sumStr
          LDX   #5         ;Loading X with 5
clearStr: CLR   0,Y        ;Clears the first value in sumStr
          INY              ;Increases Y by 1
          DBNE  X,clearStr ;Decrease X by 1,compare it to 
          LDY   8,SP       ;Loading Y with sumStr again
          LDAA  #0         ;Loading A wiht 0
          LDAB  10,SP      ;loading B with the first value of sumStr
          
          CMPB  #0         ;Comparing B with 0
          BGE   store      ;Branches if greater than or eaqual to, branches to store
          MOVB  #'-',0,Y   ;Moves the negavite sign 
          INY              ;Increases Y by 1
          NEGB             ;Negates the value in B
          
store:    CMPB  #10        ;Compares B with 10
          BLT   firstLoop ;If the value of B is less than 10 it branches to lessThan10
          
          LDX   #10        ;Loades X with 10
          IDIVS            ;Divides D with X, signed
          CPX   #10        ;Compares X with 10
          BLT   secondLoop;If the value of X is less than 100 it branches to lessThan100
          
          ADDB  #'0'       ;Adds B with the character value of 0
          STAB  temp       ;Stores that value to temp
          TFR   X,D        ;Transfrers register X to register D
          LDX   #10        ;Loads X with 10
          IDIVS            ;Divides D with X
          
          MOVB  temp,2,Y   ;Moves the value in temp to 2,Y
          
secondLoop:  
          ADDB  #'0'       ;Adds the character value to B
          STAB  1,Y        ;Stores B to the second address in Y
          TFR   X,D        ;Transfers register X with D
          
firstLoop:   
          ADDB  #'0'       ;Adds B with the character value of 0
          STAB  0,Y        ;Stores B to the first address in Y
          
          
          PULY             ;Pulls Y off the stack
          PULX             ;Pulls X off the stack
          PULD             ;Pulls D off the stack 
          RTS              ;Returns to sub routine
