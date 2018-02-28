#include P16F84A.INC
    
__config _XT_OSC & _WDT_OFF & _PWRTE_ON
    
;File Registers used by delay subroutine
DELAY_COUNT1 EQU H'21'
DELAY_COUNT2 EQU H'22'
DELAY_COUNT3 EQU H'23'
DELAYER EQU H'24'
    ORG h'0'
    bsf STATUS,5 ;select bank 1
	movlw B'00000000' ;set up port B as all outputs
	movwf TRISB
	movlw B'00000011'
	movwf TRISA
    bcf STATUS,5 ;select bank 0
	movlw B'01000000'
	movwf PORTB
	
start_loop:
;   Turn on LED to show it's in the start loop
	movlw B'00001100'
	movwf PORTA
;   Test if either button is pressed
	movlw B'00001110'   ;	Should be 00000010
	subwf PORTA
	btfsc STATUS,Z	    ;	If PORTA = W
	goto reset_loop	    ;	goes to resetloop if reset button pressed
	
	btfss STATUS,C	    ;	If PORTA < W
	goto stopwatch	    ;	goes to main stopwatch code
	
	goto start_loop	    ;	Else loops back to start loop
	
reset_loop:
;   Resets code
	movlw B'00000000'
	movwf DELAYER
	goto start_loop
	
pause_loop:
;   Turn on LED to show it's in pause loop
	movlw PORTB
	addlw B'00000001'
	movwf PORTB
;   Holds the stopwatch in a loop while paused
;   Test if either button is pressed
	movlw B'00000010'
	subwf PORTA
	btfsc STATUS,Z	    ;	If PORTA = W
	goto reset_loop	    ;	goes to resetloop if reset button pressed
	
	btfss STATUS,C	    ;	If PORTA < W
	goto stopwatch	    ;	goes to main stopwatch code
	
	goto pause_loop	    ;	Else loops back to start loop
	
stopwatch:
;   Actual stopwatch code
	movfw DELAYER
	call conversion
	movwf PORTB
	call delay
	incfsz DELAYER,F
	goto stopwatch
	
delay:
;   Initialise delay counters
	movlw H'FA'
	movwf DELAY_COUNT1
	movlw H'90'
	movwf DELAY_COUNT2
	movlw H'06'
	movwf DELAY_COUNT3
delay_loop
;   Check whether start/stop button is pressed
	movlw B'00000001'
	subwf PORTA
	btfsc STATUS,Z		;   If PORTA = W
	goto pause_loop		;   goes to resetloop if reset button pressed
	
	decfsz DELAY_COUNT1,F	;   inner most loop
	goto delay_loop		;   decrements and loops until delay_count1=0
	decfsz DELAY_COUNT2,F	;   middle loop
	goto delay_loop
	decfsz DELAY_COUNT3,F	;   outer loop
	goto delay_loop
return
    
    
conversion:
	addwf PCL ; add w to the PC (jump)
	retlw B'01000000' ; 0 return 7 seg code.
	retlw B'01011110' ; 1
	retlw B'00100100' ; 2
	retlw B'00001100' ; 3
	retlw B'00011010' ; 4
	retlw B'10001000' ; 5
	retlw B'10000000' ; 6
	retlw B'01011100' ; 7
	retlw B'00000000' ; 8
	retlw B'00011000' ; 9
	movlw B'00000000'
	movwf DELAYER
	goto stopwatch
	
end