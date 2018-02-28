#include P16F84A.INC
    
__config _XT_OSC & _WDT_OFF & _PWRTE_ON
    
;File Registers used by delay subroutine
DELAY_COUNT1 EQU H'21'
DELAY_COUNT2 EQU H'22'
DELAY_COUNT3 EQU H'23'
COUNTER EQU H'24'
COUNTER1 EQU H'25'
COUNTER2 EQU H'26'
COUNTER3 EQU H'27'
DELAY_PLEX EQU H'28'
DIGIT1 EQU H'29'
DIGIT2 EQU H'2A'
DIGIT3 EQU H'2B'
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
;   Test if either button is pressed
	movlw B'00001110'   ;	Should be 00000010
	subwf PORTA
	btfsc STATUS,Z	    ;	If PORTA = W
	goto reset_loop	    ;	goes to resetloop if reset button pressed
	
	btfss STATUS,C	    ;	If PORTA < W
	goto main	    ;	goes to main stopwatch code
	
	goto start_loop	    ;	Else loops back to start loop
	
reset_loop:
;   Resets all counters
	movlw B'0000000'
	movwf COUNTER1
	movlw B'00000000'
	movwf COUNTER2
	movlw B'00000000'
	movwf COUNTER3
	goto start_loop
	
pause_loop:
;   Holds the stopwatch in a loop while paused
;   Test if either button is pressed
	movlw B'00000010'
	subwf PORTA
	btfsc STATUS,Z	    ;	If PORTA = W
	goto reset_loop	    ;	goes to resetloop if reset button pressed
	
	btfss STATUS,C	    ;	If PORTA < W
	goto main	    ;	goes to main stopwatch code
	
	goto pause_loop	    ;	Else loops back to start loop
	
converter:
;   Converts COUNTER into DIGIT
	movfw COUNTER
	call conversion
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
	movwf COUNTER
	goto main

plex_loop:
;   Flashes between displays
	movlw B'00000100'
	movwf PORTA	    ;	Turning on display 1
	movfw DIGIT1
	movwf PORTB	    ;	Outputs display 1
	call plex_delay	    ;	Delay to keep display on
	
	movlw B'00001000'   
	movwf PORTA	    ;	Turning on display 2
	movfw DIGIT2
	movwf PORTB	    ;	Outputs to display 2
	call plex_delay	    ;	Delay
	
	movlw B'00000000'
	movwf PORTA	    ;	Turning off display 2
	movfw DIGIT3
	movwf PORTB	    ;	Turning on display 3 and displaying digit
	call plex_delay
return
	
plex_delay:
;   Allows time for displays to switch
;   Initialises plex_delay counter
	movlw H'F0'
	movwf DELAY_PLEX
    loop
	decfsz DELAY_PLEX,F
	goto loop
return

plex_timer:
;   Loops plex_loop and keeps time
;   Initialise delay counters
	movlw H'FA'
	movwf DELAY_COUNT1
	movlw H'60'
	movwf DELAY_COUNT2
delay_loop
;   Check whether start/stop button is pressed
	movlw B'00000001'
	subwf PORTA
	btfsc STATUS,Z		;   If PORTA = W
	goto pause_loop		;   goes to resetloop if reset button pressed

;   Multiplex the display
	call plex_loop
	
	decfsz DELAY_COUNT1,F	;   inner most loop
	goto delay_loop		;   decrements and loops until delay_count1=0
	decfsz DELAY_COUNT2,F	;   middle loop
	goto delay_loop
return
	
	
main:
;   Initialises TRISA
	bsf STATUS,5
	    movlw B'00000011'   ; changed from 00000000
	    movwf TRISA	    ; sets A pins as inputs and outputs
	bcf STATUS,5
    
;   Calculates PORTB outputs for each display
    ;	Display 1
	movfw COUNTER1
	movwf COUNTER
	incfsz COUNTER1,F
	call converter
	movwf DIGIT1

    ; Display 2
	movfw COUNTER2
	movwf COUNTER
	incfsz COUNTER2,F
	call converter
	movwf DIGIT2
	
    ; Display 3
	movfw COUNTER3
	movwf COUNTER
	incfsz COUNTER3,F
	call converter
	addlw B'00000001'   ;	Adds output pin for display
	movwf DIGIT3
	
	call plex_timer
	goto main
end