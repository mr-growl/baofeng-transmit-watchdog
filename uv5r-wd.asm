;**********************************************************************
;   This file is a basic code template for assembly code generation   *
;   on the PICmicro PIC16F688. This file contains the basic code      *
;   building blocks to build upon.                                    *  
;                                                                     *
;   If interrupts are not used all code presented between the ORG     *
;   0x004 directive and the label main can be removed. In addition    *
;   the variable assignments for 'w_temp' and 'status_temp' can       *
;   be removed.                                                       *                         
;                                                                     *
;   Refer to the MPASM User's Guide for additional information on     *
;   features of the assembler (Document DS33014).                     *
;                                                                     *
;   Refer to the respective PICmicro data sheet for additional        *
;   information on the instruction set.                               *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Filename:	    xxx.asm                                           *
;    Date:                                                            *
;    File Version:                                                    *
;                                                                     *
;    Author:                                                          *
;    Company:                                                         *
;                                                                     * 
;                                                                     *
;**********************************************************************
;                                                                     *
;    Files required:                                                  *
;                                                                     *
;                                                                     *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Notes:                                                           *
;                                                                     *
;                                                                     *
;                                                                     *
;                                                                     *
;**********************************************************************


	list		p=16f688		; list directive to define processor
	#include	<P16F688.inc>		; processor specific variable definitions
	
	__CONFIG    _CP_OFF & _CPD_OFF & _BOD_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT & _MCLRE_OFF & _FCMEN_OFF & _IESO_OFF


; '__CONFIG' directive is used to embed configuration data within .asm file.
; The labels following the directive are located in the respective .inc file.
; See respective data sheet for additional information on configuration word.


;***** VARIABLE DEFINITIONS
w_temp		EQU	0x71			; variable used for context saving
status_temp	EQU	0x72			; variable used for context saving
pclath_temp	EQU	0x73			; variable used for context saving

count0		EQU 0x74
count1		EQU 0x75
count2		EQU 0x76





;**********************************************************************
	ORG		0x000			; processor reset vector
  	goto		main			; go to beginning of program


	ORG		0x004			; interrupt vector location
	movwf		w_temp			; save off current W register contents
	movf		STATUS,w		; move status register into W register
	movwf		status_temp		; save off contents of STATUS register
	movf		PCLATH,w		; move pclath register into W register
	movwf		pclath_temp		; save off contents of PCLATH register


; isr code can go here or be located as a call subroutine elsewhere

	movf		pclath_temp,w		; retrieve copy of PCLATH register
	movwf		PCLATH			; restore pre-isr PCLATH register contents	
	movf		status_temp,w		; retrieve copy of STATUS register
	movwf		STATUS			; restore pre-isr STATUS register contents
	swapf		w_temp,f
	swapf		w_temp,w		; restore pre-isr W register contents
	retfie					; return from interrupt


main

; remaining code goes here




	MOVLW	0x20
	MOVWF	STATUS
	MOVLW	b'00000000'		; OPTION 10000000  enable pullups, set internal clock
	MOVWF 	OPTION_REG
	MOVLW	b'00000000'		;PIE1   00000000  disable more interrupts
	MOVWF	PIE1
							;PCON   default power options
	
	MOVLW	b'01100001'		;OSCCON 01100001
	MOVWF	OSCCON
	MOVLW	b'00000001'		;TRISA  00000001
	MOVWF 	TRISA
	MOVLW	b'00000000'		;TRISC	00000000
	MOVWF	TRISC
	MOVLW	b'00000000'		;ANSEL  00000000
	MOVWF	ANSEL
	MOVLW	b'00000000'		;WPUA	00000000
	MOVWF	WPUA
	MOVLW	b'00001000'		;IOCA	00000000
	MOVWF	IOCA
	banksel 0x00
	MOVLW 	b'00000000'		;INTCON 00000000  disable all interupts
	MOVWF	INTCON
	MOVLW	b'00000000'		;PORTA 00000000
	MOVWF	PORTA
	MOVLW	b'00000000'		;PORTC 00000000
	MOVWF	PORTC

dogit
	
init
	BCF		PORTA,1		;STOP TRANSMITTING
initloop
	BTFSS	PORTA,3			;DOES THE COMPUTER WANT TO TRANSMIT?
	goto initloop
	

waiting
	BCF		PORTA,1		;STOP TRANSMITTING
waitloop
	BTFSC	PORTA,3			;DOES THE COMPUTER WANT TO TRANSMIT?
	goto 	waitloop			;NO, it doesn't want to transmit... loop
	BSF		PORTA,1
	;MOVLW	0x02		;YES, it does want to transmit, so transmit
	;MOVWF	PORTA
	
	CLRW
	MOVWF 	count0
	MOVWF 	count1
	MOVWF 	count2
dogloop
	BTFSC	PORTA,3			;Still trying to transmit?
	goto	waiting			;NO...Transmit disabled, reset things
	INCFSZ	count0,1		;YES... start counting
	goto 	dogloop			;counter didn't overflow so loop back
	INCFSZ	count1,1		
	goto 	dogloop
	INCFSZ	count2,1
	goto 	dogloop
							;enter frozen state
	BCF		PORTA,1			;stop transmitting
frozenloop
	BTFSS	PORTA,3			;still trying to transmit?
	goto 	frozenloop		;YES: loop
	goto	waiting			;NO: wait for next transmis attempt


	ORG	0x2100				; data EEPROM location
	DE	1,2,3,4				; define first four EEPROM locations as 1, 2, 3, and 4
	END                       ; directive 'end of program'

