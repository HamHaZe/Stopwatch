#include P16F84A.INC
    
__config _XT_OSC & _WDT_OFF & _PWRTE_ON
    
;File Registers used by delay subroutine
DELAY_COUNT1 EQU H'21'
DELAY_COUNT2 EQU H'22'
DELAY_COUNT3 EQU H'23'
DELAYER1 EQU H'24'
DELAYER2 EQU H'25'
DELAYER3 EQU H'26'
DELAY_PLEX EQU H'27'
    ORG h'0'
    bsf STATUS,5 ;select bank 1
	movlw B'00000000' ;set up port B as all outputs
	movwf TRISB
	movlw B'00011111'
	movwf TRISA
    bcf STATUS,5 ;select bank 0
	movlw B'01000000'
	movwf PORTB
    
resetloop:
    movlw B'00000010' ; changed from 00000010
    movwf DELAYER1
    movlw B'00000000'
    movwf DELAYER2
    movlw B'00000000'
    movwf DELAYER3
    
pauseloop:
    call plexor
    movfw PORTA
    addwf PCL
    goto pauseloop
    
    
    
    
    
    
    
    
    addwf PCL    
    goto resetloop
 
loop:
    movfw DELAYER1
    call conversion
    movwf PORTB
    call delay
    incfsz DELAYER1,F
    movfw PORTA
    addwf PCL
    goto loop
	movlw H'FA' ;initialise delay counters
	movwf DELAY_COUNT1
	movlw H'90'
	movwf DELAY_COUNT2
	movlw H'06'
	movwf DELAY_COUNT3
	stop_loop:
	decfsz DELAY_COUNT1,F ; inner most loop
	call plexor
	goto stop_loop ; decrements and loops until delay_count1=0
	decfsz DELAY_COUNT2,F ; middle loop
        goto stop_loop
        decfsz DELAY_COUNT3,F ; outer loop
        goto stop_loop
        goto pauseloop
 
delay:
    movlw H'FA' ;initialise delay counters
    movwf DELAY_COUNT1
    movlw H'90'
    movwf DELAY_COUNT2
    movlw H'06'
    movwf DELAY_COUNT3
delay_loop
    decfsz DELAY_COUNT1,F ; inner most loop
    call plexor
    goto delay_loop ; decrements and loops until delay_count1=0
    decfsz DELAY_COUNT2,F ; middle loop
    goto delay_loop
    decfsz DELAY_COUNT3,F ; outer loop
    goto delay_loop
    return
    
delay_plex:
    movlw H'15' ;initialise delay counters
    movwf DELAY_PLEX
plex_loop
    decfsz DELAY_PLEX,F ; outer loop
    goto plex_loop
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
    movwf DELAYER1
    incfsz DELAYER2,F
    retlw B'01000000'
    
    
conversion2:
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
    movwf DELAYER2
    incfsz DELAYER3,F
    retlw B'01000000'
    
conversion3:
    addwf PCL ; add w to the PC (jump)
    retlw B'01000001' ; 0 return 7 seg code.
    retlw B'01011111' ; 1
    retlw B'00100101' ; 2
    retlw B'00001101' ; 3
    retlw B'00011011' ; 4
    retlw B'10001001' ; 5
    retlw B'10000001' ; 6
    retlw B'01011101' ; 7
    retlw B'00000001' ; 8
    retlw B'00011001' ; 9
    movlw B'00000001'
    movwf DELAYER3
    retlw B'01000001'

plexor:
    bsf STATUS,5
	movlw B'00000011'   ; changed from 00000000
	movwf TRISA	    ; sets A pins as inputs and outputs
    bcf STATUS,5
    movlw B'00000100'	    ; sends power to displays
    movwf PORTA
    movfw DELAYER1
    call conversion
;    movwf PORTB
;    movlw B'00000000'	    ; Shuts off display before switching]
    movwf PORTA
    call delay_plex	    ; Sets delay between switching between displays
;	movlw H'50' ; changed from 20
;	movwf DELAY_PLEX
plexloop1:
;	decfsz DELAY_PLEX,F ; outer loop
;	goto plexloop1
    movlw B'00001000'
    movwf PORTA
    movfw DELAYER2
    call conversion2
    movwf PORTB
;    movlw B'00000000'	    ; Shuts off display before switching]
;    movwf PORTA
    call delay_plex
;	movlw H'15'
;	movwf DELAY_PLEX
plexloop2:
;	decfsz DELAY_PLEX,F ; outer loop
;	goto plexloop2
    movlw B'00000001'
    movwf PORTB
    movfw DELAYER3
    call conversion3
    movwf PORTB
    call delay_plex
;	movlw H'15' ; changed from 20
;	movwf DELAY_PLEX
plexloop3:
;	decfsz DELAY_PLEX,F ; outer loop
;	goto plexloop3
    bsf STATUS, 5
	movlw B'00011111' ; changed from 0001111
	movwf TRISA
    bcf STATUS, 5
    return
    
    end


