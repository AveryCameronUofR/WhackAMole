;;; Directives
            PRESERVE8
            THUMB       		 
;;; Equates

INITIAL_MSP	EQU		0x20001000	; Initial Main Stack Pointer Value


;The onboard LEDS are on port C bits 8 and 9
;PORT C GPIO - Base Addr: 0x40011000

GPIOA_CRL	EQU		0x40010800	; (0x00) Port Configuration Register for PA7 -> PA0
GPIOB_CRL	EQU		0x40010C00	; (0x00) Port Configuration Register For PB7 -> PB0
GPIOC_CRL	EQU		0x40011000	; (0x00) Port Configuration Register for PC7 -> PC0
RCC_APB2ENR	EQU		0x40021018	; APB2 Peripheral Clock Enable Register


; Times for delay routines
DELAYTIME	EQU	150000

; Constants for Random Number Generation
AConstant 	EQU 	1664525
CConstant	EQU 	1013904223
MConstant	EQU 	0xFFFFFFFF

; Vector Table Mapped to Address 0 at Reset
            AREA    RESET, Data, READONLY
            EXPORT  __Vectors

__Vectors	DCD		INITIAL_MSP			; stack pointer value when stack is empty
        	DCD		Reset_Handler		; reset vector
			
            AREA    MYCODE, CODE, READONLY
			EXPORT	Reset_Handler
			ENTRY

Reset_Handler		PROC

	BL GPIO_ClockInit
	;LDR R8, =0x40033
	BL GPIO_init
	BL mainLoop
	
	ENDP
	ALIGN	
winner	PROC
	MOV R1, #0
	MOV R10, #0
	LDR R6, =GPIOA_CRL
	ADD R6, R6, #0x0C
	MOV R3, #0xF
	LSL R3, #9
	STR R3, [R6]
winnerInner
	BL winnerDelay
	ADD R1, #1
	CMP R10, #0
	BEQ cycleLed1
	CMP R10, #1
	BEQ cycleLed2
	CMP R10, #2
	BEQ cycleLed3
	CMP R10, #3
	BEQ cycleLed4
	CMP R10, #4
	BEQ cycleLed4
	CMP R10, #5
	BEQ cycleLed3
	CMP R10, #6
	BEQ cycleLed2
	CMP R10, #7
	BEQ cycleLed1
	
cycleLed1
	MOV R0, #0xE
	B ledLight
cycleLed2
	MOV R0, #0xD
	B ledLight
cycleLed3
	MOV R0, #0xB
	B ledLight
cycleLed4
	MOV R0, #0x7
	B ledLight
	
ledLight
	LDR R6, =GPIOA_CRL
	ADD R6, R6, #0x0C
	LSL R0, #9
	STR R0, [R6]
	ADD R10, R10, #1
	CMP R10, #7
	BEQ reset10
	B continueWin
reset10
	MOV R10, #0
continueWin	
	CMP R1, #0xF
	BEQ mainLoop
	
	B winnerInner
	ENDP
		
	ALIGN	
winnerDelay PROC
	push {LR}
	LDR R11, =200000
	
winDelayInner
	SUB R11, R11, #1
	CMP R11, #0
	
	BNE winDelayInner
	
	pop {LR}
	BX LR
	ENDP
;Constantly loops checking which buttons are pressed and activating the corressponding LED
	ALIGN
mainLoop PROC
		BL waitForUser
		BL PrelimWait
		ENDP
	ALIGN
gameLoop PROC
		CMP R12, #0x10
		BEQ winner
		BL randomLED
 		BL delay200ms
		BL checkButton
		BL checkLED
		BL PrelimWait
		B	gameLoop	;loop
		ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Flashes LEDs all on and all off whil 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ALIGN
waitForUser PROC
	push {LR}
	MOV R0, #0
	MOV R1, #0
	MOV R2, #0
	MOV R3, #0
	MOV R4, #0
	MOV R5, #0
	MOV R6, #0
	MOV R7, #0
	MOV R8, #0
	MOV R9, #0
	MOV R10, #0
	MOV R11, #0
	MOV R12, #0
waitInner
	
	BL delay200ms
	CMP R10, #0
	BEQ led1
	CMP R10, #1
	BEQ led2
	
led1
	LDR R6, =GPIOA_CRL
	ADD R6, R6, #0x0C
	LDR R0, [R6]
	MOV R3, #0xF
	LSL R3, #9
	STR R3, [R6]
	MOV R10, #1
	B check

led2
	LDR R6, =GPIOA_CRL
	ADD R6, R6, #0x0C
	LDR R0, [R6]
	MOV R3, #0x0
	LSL R3, #9
	STR R3, [R6]
	MOV R10, #0
	B check

check
	CMP R7, #1
	BNE waitInner
	pop {LR}
	BX LR
	ENDP

delay200ms PROC
	push {LR}
	LDR R11, =DELAYTIME
	MOV R1, #7500
	MUL R0, R12, R7
	SUB R11, R11, R0
	MOV R1, #0
	MOV R0, #0
delayInner
	SUB R11, R11, #1
	MOV R8, #1
	;;button1
	LDR R0, =GPIOB_CRL
	ADD R0, R0, #8
	LDR R1, [R0]
	LSR R1, R1, #8
	AND R1, R8, R1
	
	;;button2
	LDR R0, =GPIOB_CRL
	ADD R0, R0, #8
	LDR R2, [R0]
	LSR R2, R2, #9
	AND R2, R8, R2
	
	;;button3
	LDR R0, =GPIOC_CRL
	ADD R0, R0, #8
	LDR R3, [R0]
	LSR R3, R3, #12
	AND R3, R8, R3
	
	;;button4
	LDR R0, =GPIOA_CRL
	ADD R0, R0, #8
	LDR R4, [R0]
	LSR R4, R4, #5
	AND R4, R8, R4
	
	MOV R5, R4
	LSL R5, #1
	ADD R5, R3
	LSL R5, #1
	ADD R5, R2
	LSL R5, #1
	ADD R5, R1
	CMP R5, #0xF
	BNE buttonClicked
	
	CMP R11, #0
	BNE delayInner
	pop {LR}
	BX LR
	ENDP
		
	ALIGN
buttonClicked PROC
	MOV R7, #0xF
	EOR R7, R1, #1
	EOR R8, R2, #1
	EOR R9, R3, #1
	EOR R10, R4, #1
	
	EOR R7, R7, R8 
	EOR R8, R9, R10
	EOR R7, R8
	pop {LR}
	BX LR
	ENDP
	
	ALIGN	
PrelimWait PROC
	push {LR}
	LDR R1, =800000
	
	LDR R6, =GPIOA_CRL
	ADD R6, R6, #0x0C
	LDR R0, [R6]
	MOV R3, #0xF
	LSL R3, #9
	STR R3, [R6]
	
prelimInner
	SUB R1, R1, #1
	CMP R1, #0
	
	BNE prelimInner
	
	pop {LR}
	BX LR
	ENDP
		
	ALIGN	
randomLED PROC
	LDR R8, =AConstant
	LDR R9, =CConstant
	LDR R10, =MConstant
	MUL R0, R8, R11
	ADD R0, R0, R9
	AND R0, R0, R10
	LSR R0, R0, #30
	AND R0, R0, #3
	CMP R0, #0
	BEQ LED1
	CMP R0, #1
	BEQ LED2
	CMP R0, #2
	BEQ LED3
	CMP R0, #3
	BEQ LED4
	
LED1
	MOV R0, #1
	LSL R0, R0, #9
	EOR R0, R10
	B continueLED

LED2
	MOV R0, #1
	LSL R0, R0, #10
	EOR R0, R10
	B continueLED
	
LED3
	MOV R0, #1
	LSL R0, R0, #11
	EOR R0, R10
	B continueLED
	
LED4
	MOV R0, #1
	LSL R0, R0, #12
	EOR R0, R10
	B continueLED
	
continueLED
	LDR R6, =GPIOA_CRL
	ADD R6, R6, #0x0C
	STR R0, [R6]
	
	BX LR
	ENDP

checkLED PROC
	push {LR}
	
	LDR R6, =GPIOA_CRL
	ADD R6, R6, #0x0C
	LDR R6, [R6]
	LSR R6, R6, #9
	AND R6, R6, #0xF
	
	CMP R6, #0xE
	BEQ checkBtn1
	
	CMP R6, #0xD
	BEQ checkBtn2
	
	CMP R6, #0xB
	BEQ checkBtn3
	
	CMP R6, #0x7
	BEQ checkBtn4
	B gameEnd
checkBtn1
	CMP R5, #0xE
	BEQ validLed
	B gameEnd
	
checkBtn2
	CMP R5, #0xD
	BEQ validLed
	B gameEnd
	
checkBtn3
	CMP R5, #0xB
	BEQ validLed
	B gameEnd
	
checkBtn4
	CMP R5, #0x7
	BEQ validLed
	B gameEnd

validLed
	ADD R12, R12, #1
	
	pop {LR}
	BX LR
	ENDP
	
	ALIGN
checkButton PROC
	CMP R5, #0xF
	BEQ gameEnd
	BX LR
	ENDP
	
	ALIGN
gameEnd PROC
	BL displayLose
	B mainLoop
	ENDP
		
checkWait PROC
	push {LR}
	LDR R0, =2500000
	
checkWaitInner
	SUB R0, R0, #1
	CMP R0, #0
	BNE checkWaitInner
	
	pop {LR}
	BX LR
	ENDP
displayLose PROC
	push {LR}
	MOV R10, #0
	MOV R1, #0
	MOV R0, #0
	LDR R6, =GPIOA_CRL
	ADD R6, R6, #0x0C
	STR R0, [R6]
loseInner
	CMP R10, #0
	BEQ lightOuter
	CMP R10, #1
	BEQ lightScore

lightOuter
	MOV R0, #0x6
	MOV R10, #1
	B displayLED
lightScore
	ADD R0, R12, #1
	EOR R0, R0, #0xF
	MOV R10, #0
	B displayLED
	
displayLED
	ADD R1, R1, #1
	LSL R0, R0, #9
	LDR R6, =GPIOA_CRL
	ADD R6, R6, #0x0C
	STR R0, [R6]
	BL checkWait 
	CMP R1, #5
	BNE loseInner
	pop {LR}
	BX LR
	ENDP
;This routine will enable the clock for the Ports that you need	
;gets the address of the clock and turns it on for the ports 
;address 0x40021018 turning on 00011100 ports A, B and C
	ALIGN
GPIO_ClockInit PROC

	LDR R6, =RCC_APB2ENR
	LDR R0, [R6]
	ORR R0, #0x1C
	STR R0, [R6]
	
	BX LR
	ENDP
		
	ALIGN
		
;This routine enables the GPIO for the LED;s
;GPIO CRH Mod set for Leds on port A 9 - 12, and button on port A5, B8, B9, C12
;loads initial value, sets led/btn stores it back in the memory location
GPIO_init  PROC
	

	;LEDS
	;stored in port A, HRL 9 - 12
	;00 for general purpose output push-pull
	;11 for output mode max speed 50 mhz
	;0011 is loaded in (0x3) for each LED 
	LDR R6, =GPIOA_CRL
	ADD R5, R6, #0x04
	LDR R0, [R5]
	LDR R1, =0xFFF0000F
	AND R0, R1
	LDR R2, =0x33330
	ADD R0, R0, R2
	STR R0, [R5]
	BX LR
	ENDP

;;delays program using clock times/process clock counts


	ALIGN


	END
