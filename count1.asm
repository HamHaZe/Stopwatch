#include P16F84A.INC
    
__config _XT_OSC & _WDT_OFF & _PWRTE_ON
    
;   Ross Hamer & Ramy Elabbadi
	
;File Registers used by delay subroutine
DELAY_COUNT1	EQU H'21'
DELAY_COUNT2	EQU H'22'
DELAY_COUNT3	EQU H'23'
DELAY_COUNT4	EQU H'30'
COUNTER		EQU H'24'
COUNTER1	EQU H'25'
COUNTER2	EQU H'26'
COUNTER3	EQU H'27'
DELAY_PLEX	EQU H'28'
DIGIT1		EQU H'29'
DIGIT2		EQU H'2A'
DIGIT3		EQU H'2B'
Pause		EQU H'2C'
Start		EQU H'2D'
UnPause		EQU H'2E'
Reset1		EQU H'2F'
ORG h'0'
clrf PORTA
clrf PORTB
bsf STATUS,5		;   Select bank 1
movlw B'00000000'	;   Set up port B as all outputs
movwf TRISB
movlw B'00000001'
movwf TRISA
bcf STATUS,5		;   select bank 0
movlw 0x00		;   Moves 0 to the working register
call conversion		;   Calls PORTB outputs for zeroes
movwf DIGIT1		;   
movwf DIGIT2		;   Sets PORTB outputs for all digits
movwf DIGIT3		;
movlw 0xFF
movwf COUNTER1		;
movwf COUNTER2		;   Sets counters to max value so they overflow loop
movwf COUNTER3		;
goto Start_loop
		
preStart		;   Reset function
	movlw 0x00
	call conversion	;   Sets all DIGITs to 0
	movwf DIGIT1
	movwf DIGIT2
	movwf DIGIT3
	movlw 0xFF	;   Sets all COUNTERs to 0
	movwf COUNTER1
	movwf COUNTER2
	movwf COUNTER3
	goto Start_loop
	
Start_loop		    ;   Initial start loop 
	call plex_loop	    ;   Multiplexes display
	call CheckStart	    ;   Checks to see if start button is pressed
	goto Start_loop	    ;   Loops back to start_loop

CheckStart		    ;	Checks whether start button pressed
	movfw PORTA
	andlw 0x01	    ;	Masks out final value of PORTA buttons
	movwf Start	    ;	Assigns button value to variable Start
	decfsz Start	    ;	Decreases Start variable,
	Return		    ;	    skips if button not pressed
	goto interrupt
	
CheckPause		    ;	Checks whether pause button pressed
	movfw PORTA	    ;	    called when stopwatch is running
	andlw 0x01	    
	movwf Pause	    ;	Follows same procedure as CheckStart
	decfsz Pause
	Return
	goto interrupt_Pause
	
Unpause			    ;	Checks whether pause button pressed
	movfw PORTA	    ;	    called when stopwatch is paused
	andlw 0x01
	movwf UnPause	    ;	Follows same procedure as CheckStart
	decfsz UnPause
	Return
	goto interrupt_UnPause

CheckReset		    ;	Checks whether reset button pressed
	movfw PORTA	    ;	    called when stopwatch is paused
	sublw 0x09
	movwf Reset1
	decfsz Reset1	    ;	Follows same procedure as CheckStart
	goto interrupt_Reset
	Return
	
PauseIdle		    ;	Pause loop 
	call plex_loop	    ;	Multiplexes display
	call Unpause	    ;	Checks whether pause button pressed
	call CheckReset	    ;	Checks whether reset
	goto PauseIdle

	
interrupt			;   Adds delay to button press so it doesn't
	call delay_interrupt	;	quickly reset
	goto display1
	
interrupt_Pause			;   Interrupt delay for pause button
	call delay_interrupt
	goto PauseIdle

interrupt_UnPause		;   Interrupt delay for unpause
	call delay_interrupt
	goto display1
	
interrupt_Reset			;   Interrupt delay for reset
	call delay_interrupt
	goto preStart
	

display1			;   Gets required digit for display 1
	incf COUNTER1,F		;   Increase number counter
	movfw COUNTER1
	call conversion		;   Calls conversion table for digit
	movwf DIGIT1
	call plex_loop		;   Multiplexes display
	call timer		;   Calls timer
	goto display1		;   Loops until it reaches 10

display2			;   Gets required digit for display 2
	movlw 0xFF
	movwf COUNTER1		;   Increase number counter
	incf COUNTER2,F
	movfw COUNTER2
	call conversion2	;   Calls conversion table for digit
	movwf DIGIT2
	goto display1
	
display3			;   Gets required digit for display 3
	movlw 0xFF
	movwf COUNTER2
	incf COUNTER3,F		;   Increase number counter
	movfw COUNTER3
	call conversion3	;   Calls conversion table for digit
	movwf DIGIT3
	goto display1
	
conversion:		    ;	Conversion table for display 1
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
	goto display2

conversion2:		    ;	Conversion table for display 2
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
	goto display3

conversion3:		    ;	Conversion table for display 3
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
	movlw 0xFF
	movwf COUNTER3
	goto display1
	

plex_loop:		    ;	Cycles through turning on and off each display
	movlw B'00000010'   ;	Turns on display 1
	movwf PORTA	   
	movfw DIGIT1	    ;	Prints DIGIT1
	movwf PORTB	    
	call plex_delay	    ;	Gets delay between display plexing
	
	movlw B'00000100'   ;	Turns on display 2
	movwf PORTA	   
	movfw DIGIT2	    ;	Prints DIGIT2
	movwf PORTB	    
	call plex_delay	    
	
	movlw B'00001000'   ;	Turns on display 3
	movwf PORTA
	movfw DIGIT3	    ;	Turns on DIGIT3
	movwf PORTB	    
	call plex_delay	    ;	Gets delay between display plexing
	return
	
plex_delay:		    ;	Delay loop between turning off and on displays
	movlw H'FF'	    
	movwf DELAY_PLEX
	loop
	decfsz DELAY_PLEX,F
	goto loop
	return

timer			    ;	Delay loop to increment time accurately
	call plex_loop	    ;	Multiplexes display output
	call CheckPause	    ;	Polls for pause button
	movlw H'FF'
	movwf DELAY_COUNT1
	movlw H'05'
	movwf DELAY_COUNT4
delay_loop		    ;	Decrements DELAY_COUNT to 0 and moves on
	decfsz DELAY_COUNT1,F	
	goto delay_loop
	decfsz DELAY_COUNT4,F
	goto delay_loop
	return

delay_interrupt		    ;	Delay for interrupt to fix buttons
	movlw H'FF'
	movwf DELAY_COUNT2
	movlw H'EF'
	movwf DELAY_COUNT3
delay_loop_interrupt	
	decfsz DELAY_COUNT2,F	
	goto delay_loop_interrupt
	decfsz DELAY_COUNT3,F	
	goto delay_loop_interrupt
	Return

	
	
end
