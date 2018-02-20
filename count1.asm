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
    movlw B'00011111'
    movwf TRISA
bcf STATUS,5 ;select bank 0
    movlw B'01000000'
    movwf PORTB

main
 call startloop
 call loop
 call pauseloop
 
startloop
 movfw PORTA
 addwf PCL
 goto startloop
 return
 
pauseloop
 movfw PORTA
 addwf PCL
 goto pauseloop
 goto loop
 
loop
movfw DELAYER
call conversion
movwf PORTB
incfsz DELAYER,F
call delay
movfw PORTA
addwf PCL
goto loop
    movlw H'FA' ;initialise delay counters
    movwf DELAY_COUNT1
    movlw H'90'
    movwf DELAY_COUNT2
    movlw H'06'
    movwf DELAY_COUNT3
stop_loop
    decfsz DELAY_COUNT1,F ; inner most loop
    goto stop_loop ; decrements and loops until delay_count1=0
    decfsz DELAY_COUNT2,F ; middle loop
    goto stop_loop
    decfsz DELAY_COUNT3,F ; outer loop
goto stop_loop
return
 
delay
    movlw H'FA' ;initialise delay counters
    movwf DELAY_COUNT1
    movlw H'90'
    movwf DELAY_COUNT2
    movlw H'06'
    movwf DELAY_COUNT3
delay_loop
    decfsz DELAY_COUNT1,F ; inner most loop
    goto delay_loop ; decrements and loops until delay_count1=0
    decfsz DELAY_COUNT2,F ; middle loop
    goto delay_loop
    decfsz DELAY_COUNT3,F ; outer loop
    goto delay_loop
movfw PORTA
addwf PCL
return
    movlw H'FA' ;initialise delay counters
    movwf DELAY_COUNT1
    movlw H'90'
    movwf DELAY_COUNT2
    movlw H'06'
    movwf DELAY_COUNT3
stop_loop
    decfsz DELAY_COUNT1,F ; inner most loop
    goto stop_loop ; decrements and loops until delay_count1=0
    decfsz DELAY_COUNT2,F ; middle loop
    goto stop_loop
    decfsz DELAY_COUNT3,F ; outer loop
goto stop_loop
goto pauseloop

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
    goto loop
end