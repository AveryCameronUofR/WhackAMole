;;Avery Cameron
;;December 3, 2018
;;ENSE 352
;;Whack a Mole Term Project
;;; Directives
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Notes: General registers used
;;R0  for storing and loading
;;R1  for buttons
;;R2 for Leds
;;R3 for functions
;;R12 for score
;;R11 for count
;;R9 for comparisons
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            PRESERVE8
            THUMB       		 
;;; Equates
INITIAL_MSP	EQU		0x20001000	; Initial Main Stack Pointer Value

;The onboard LEDS are on port C bits 8 and 9
;PORT C GPIO - Base Addr: 0x40011000
GPIOA_CRL	EQU		0x40010800	; (0x00) Port Configuration Register for PA7 -> PA0
GPIOB_CRL	EQU		0x40010C00	; (0x00) Port Configuration Register For PB7 -> PB0
GPIOC_CRL	EQU		0x40011000	; (0x00) Port Configuration Register for PC7 -> PC0
GPIOA_CRH	EQU		0x40010804	; (0x00) Port Configuration Register for PA15 -> PA8
GPIOA_IDR	EQU		0x40010808	; (0x00) Port Input Register for PA
GPIOB_IDR	EQU		0x40010C08	; (0x00) Port Input Register for PB
GPIOC_IDR	EQU		0x40011008	; (0x00) Port Input Register for PC
GPIOA_ODR	EQU		0x4001080C	; (0x00) Port Output Register for PA	
RCC_APB2ENR	EQU		0x40021018	; APB2 Peripheral Clock Enable Register

; Times for delay routines
DELAYTIME	EQU	450000
WINDELAY	EQU 200000
PRELIMDELAY EQU 800000
CHECKDELAY  EQU 2500000
PROFDELAY	EQU 999999999
; Cycles taken to win
CYCLES 		EQU 4
	
; Constants for Random Number Generation
AConstant 	EQU 	1664525
CConstant	EQU 	1013904223
; Vector Table Mapped to Address 0 at Reset
            AREA    RESET, Data, READONLY
            EXPORT  __Vectors

__Vectors	DCD		INITIAL_MSP			; stack pointer value when stack is empty
        	DCD		Reset_Handler		; reset vector
			
            AREA    MYCODE, CODE, READONLY
			EXPORT	Reset_Handler
			ENTRY
;;Use Case 1: System Boot by Reset Button
Reset_Handler		PROC
	BL GPIO_ClockInit
	BL GPIO_init
	BL mainLoop
	ENDP
;;Use Case 2: Waiting for player, waitForUser loops until user input detected
mainLoop PROC
		BL waitForUser
		BL PrelimWait
		ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Use Case 3: Normal Game Play
;; random Led loaded, user has to react before timer expires (if true loop, if false Use Case 5: Failure)
;; loads cycles into R1
;; Branches to winner when score in R12 equals CYCLES
;; Picks a random led, checks user input, verifies input and loops
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gameLoop PROC
		LDR R1, =CYCLES
		CMP R12, R1
		BEQ winner
		BL randomLED
 		BL delay200ms
		BL checkLED
		BL PrelimWait
		B	gameLoop	;loop
		ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Use Case 4: End Success - user has won the game and winning signal is displayed
;; Displays winning LED Pattern
;; 	-a cycle of one led on and back 2 times
;; Require:
;; 		None
;; Note: following registers are changed 
;; R4, used for getting cycles of winning pattern
;; R3 used for led to display 
;; R0 used for LED GPIOA_IDR
;; R10 used for cycling back and forth
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
winner	PROC
	MOV R4, #0
	MOV R9, #0
	LDR R0, =GPIOA_ODR
	MOV R3, #0xF
	LSL R3, #9
	STR R3, [R0]
	LDR R11, =DELAYTIME
	SUB R8, R8, R11
	MOV R5, #10
	MUL R10, R10, R5
	UDIV R10, R10, R8
winnerInner
	BL winnerDelay
;;allows for cycle back and forth
	ADD R4, #1
	CMP R9, #0
	BEQ cycleLed1
	CMP R9, #1
	BEQ cycleLed2
	CMP R9, #2
	BEQ cycleLed3
	CMP R9, #3
	BEQ cycleLed4
	CMP R9, #4
	BEQ cycleLed4
	CMP R9, #5
	BEQ cycleLed3
	CMP R9, #6
	BEQ cycleLed2
	CMP R9, #7
	BEQ cycleLed1
;;sets an LED value
cycleLed1
	MOV R3, #0xE
	B ledLight
cycleLed2
	MOV R3, #0xD
	B ledLight
cycleLed3
	MOV R3, #0xB
	B ledLight
cycleLed4
	MOV R3, #0x7
	B ledLight
profComplete
	B mainLoop
;;turns on the proper LED	
ledLight
	LDR R0, =GPIOA_ODR
	LSL R3, #9
	STR R3, [R0]
	ADD R9, R9, #1
	CMP R9, #7
	BEQ reset10
	B continueWin
;;this resets 10 so it runs twice
reset10
	MOV R9, #0
continueWin	
;;once win loop is complete, start program over again
	CMP R4, #0xF
	BEQ displayProf
	B winnerInner
	ENDP
displayProf PROC
	LDR R0, =GPIOA_ODR
	MOV R2, #0xF
	LSL R2, R2, #9
	STR R2, [R0]
	LDR R11, =PROFDELAY
	CMP R10, #9
	BEQ prof90
	CMP R10, #8
	BEQ prof80
	CMP R10, #7
	BEQ prof70
	CMP R10, #6
	BEQ prof60
	CMP R10, #5
	BEQ prof50
	CMP R10, #4
	BEQ prof40
	CMP R10, #3
	BEQ prof30
	CMP R10, #2
	BEQ prof20
	CMP R10, #1
	BEQ prof10
	CMP R10, #80
	BEQ prof00
prof90
	MOV R3, #6
	B profInner
prof80
	MOV R3, #7
	B profInner
prof70
	MOV R3, #8
	B profInner
prof60
	MOV R3, #9
	B profInner
prof50
	MOV R3, #10
	B profInner
prof40
	MOV R3, #11
	B profInner
prof30
	MOV R3, #12
	B profInner
prof20
	MOV R3, #13
	B profInner
prof10
	MOV R3, #14
	B profInner
prof00
	MOV R3, #15
	B profInner
profInner
	BL delay200ms
	CMP R1, #0xF
	BNE profComplete
	CMP R9, #0
	BEQ profLED
	CMP R9, #1
	BEQ blankLED
profLED 
	LDR R0, =GPIOA_ODR
	LSL R3, R3, #9
	STR R3, [R0]
	MOV R9, #1
	B profInner
blankLED
	MOV R2, #0xF
	LDR R0, =GPIOA_ODR
	LSL R2, R2, #9
	STR R2, [R0]
	MOV R9, #0
	B profInner
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; winnerDelay
;;  	takes WINDELAY constant and subtracts 1 to create a delay timer
;; PROMISE:
;;		R11 will be 0
;; 		Program will exit back to proper location afterward
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
winnerDelay PROC
	push {LR}
	LDR R11, =WINDELAY
winDelayInner
	SUB R11, R11, #1
	CMP R11, #0
	BNE winDelayInner
	pop {LR}
	BX LR
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Use Case 2
;; waitForUser
;;		Resets all registers to 0 initially for game start
;; 		takes user input from buttons, exits when any are pressed
;;		alternates a solid on and solid off signal
;; Promise
;;		R11 will hold the value remaining in timer when loop is exited on user input
;;		R1 will hold user input, if any button is presed, result will not be 0xF
;;		R3 holds LED value to display
;; Require
;;		R11 constant DELAYTIME must be greater than or equal to 0 (larger shows longer)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
	CMP R9, #0
	BEQ led1
	CMP R9, #1
	BEQ led2
led1
	LDR R0, =GPIOA_ODR
	MOV R3, #0xF
	LSL R3, #9
	STR R3, [R0]
	MOV R9, #1
	B check
led2
	LDR R0, =GPIOA_ODR
	MOV R3, #0x0
	LSL R3, #9
	STR R3, [R0]
	MOV R9, #0
	B check
check
	CMP R1, #0xF
	BEQ waitInner
	pop {LR}
	BX LR
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; delay200ms
;;		delays for user's set time, takes button input each loop
;;		exits loop when user input detected
;; PROMISE
;;		R11 holds counter value, whatever the value is on exit
;; REQUIRE
;;		R11 holds DELAYTIME
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
delay200ms PROC
	push {LR}
;; code block to calculate delay time = time - (time/(2*cycles) * currentCycle)
	MOV R0, #2
	LDR R4, =CYCLES
	LDR R11, =DELAYTIME
	MUL R0, R0, R4
	UDIV R0, R11, R0
	MUL R0, R0, R12
	SUB R11, R11, R0
	ADD R8, R8, R11
;;
	MOV R1, #0
	MOV R0, #0
	MOV R4, #1
;;reduces R11, constantly polls buttons
delayInner
	SUB R11, R11, #1
	;;button4, loads button, shifts it so button is in bit 0, ands with 1 to clear rest of register
	LDR R0, =GPIOA_IDR
	LDR R3, [R0]
	LSR R3, R3, #5
	AND R3, R3, #1
;;moves bit from button 4 into R1, similar to all other buttons
	MOV R1, R3
	LSL R1, #1
	;;button3
	LDR R0, =GPIOC_IDR
	LDR R3, [R0]
	LSR R3, R3, #12
	AND R3, #1
	ADD R1, R1, R3
	LSL R1, #2
	;;button 1 &2
	LDR R0, =GPIOB_IDR
	LDR R3, [R0]
	LSR R3, R3, #8
	AND R3, #3
	;;R3 stores all button inputs into bits 0-3 
	ADD R1, R1, R3	
	CMP R1, #0xF
	BNE continue
	CMP R11, #0
	BNE delayInner
continue
	pop {LR}
	BX LR
	ENDP 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PrelimWait
;; 		delays by PRELIMDELAY set at top of file
;; WARN:
;;		R3, will be 0 at end of the loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PrelimWait PROC
	push {LR}
	LDR R3, =PRELIMDELAY
	LDR R0, =GPIOA_ODR
	MOV R4, #0xF
	LSL R4, #9
	STR R4, [R0]
prelimInner
	SUB R3, R3, #1
	CMP R3, #0
	BNE prelimInner	
	pop {LR}
	BX LR
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Part of Use Case 3
;; randomLED
;; 		Selects a randomLED based on random number 
;; 		using equation (a*x + c) % M 
;;		top 2 bits of random number are used to select LED, 00 for 1 etc
;; NOTE:
;;		M is 2^32 which is equivalent of & (2^32 -1) which leaves a*x + c
;;		x is the remaining time from counter of DELAYTIME 
;; REQUIRE:
;;		None
;; PROMISE:
;;		RO will contain random number
;;		R0, R1, will be set to AConstant and CConstant
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
randomLED PROC
	LDR R0, =AConstant
	LDR R1, =CConstant
	MUL R0, R0, R11
	ADD R0, R0, R1
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
	MOV R1, #7
	B continueLED
LED2
	MOV R1, #0xB
	B continueLED	
LED3
	MOV R1, #0xD
	B continueLED	
LED4
	MOV R1, #0xE
	B continueLED	
continueLED
	LDR R0, =GPIOA_ODR
	LSL R1, R1, #9
	STR R1, [R0]	
	BX LR
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Part of Use Case 3
;;	checkLED
;;		based on LED that is on, button pattern is checked for match
;;		game enters fail stat if buttons and LEDs dont match
;;	REQUIRE:
;;		R1 contains button inputs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
checkLED PROC
	push {LR}	
	LDR R0, =GPIOA_ODR
	LDR R0, [R0]
	LSR R0, R0, #9
	AND R0, R0, #0xF
	
	CMP R0, #0xE
	BEQ checkBtn1
	
	CMP R0, #0xD
	BEQ checkBtn2
	
	CMP R0, #0xB
	BEQ checkBtn3
	
	CMP R0, #0x7
	BEQ checkBtn4
	B gameEnd
checkBtn1
	CMP R1, #0xE
	BEQ validLed
	B gameEnd	
checkBtn2
	CMP R1, #0xD
	BEQ validLed
	B gameEnd	
checkBtn3
	CMP R1, #0xB
	BEQ validLed
	B gameEnd	
checkBtn4
	CMP R1, #0x7
	BEQ validLed
	B gameEnd
;;increment score
validLed
	ADD R12, R12, #1	
	ADD R10, R10, R11
	pop {LR}
	BX LR
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Part of Use Case 5
;;	gameEND
;;		display score on Lose
;;		start mainloop again
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
gameEnd PROC
	BL displayLose
	B mainLoop
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	checkWait
;;		loop to delay CHECK, reduces risk of timing error 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
checkWait PROC
	push {LR}
	LDR R0, =CHECKDELAY
checkWaitInner
	SUB R0, R0, #1
	CMP R0, #0
	BNE checkWaitInner
	pop {LR}
	BX LR
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Part of Use Case 5
;; displayLose
;;		alternates between user Score and outer leds on
;;		allows for score of zero to be displayable
;;		cycles 3 times, display 6 times total
;; R9 used for Compare, R0 for loading register, R3 for LEDs, R4 for counter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
displayLose PROC
	push {LR}
	MOV R9, #0
	MOV R4, #0
	MOV R0, #0
	LDR R0, =GPIOA_ODR
	STR R4, [R0]
loseInner
	CMP R9, #0
	BEQ lightOuter
	CMP R9, #1
	BEQ lightScore
lightOuter
	MOV R3, #0x6
	MOV R9, #1
	B displayLED
lightScore
	MOV R3, R12
	;ADD R0, R12, #1
	EOR R3, R3, #0xF
	MOV R9, #0
	B displayLED
displayLED
	ADD R4, R4, #1
	LSL R3, R3, #9
	LDR R0, =GPIOA_ODR
	STR R3, [R0]
	BL checkWait 
	CMP R4, #5
	BNE loseInner
	pop {LR}
	BX LR
	ENDP		
;This routine will enable the clock for the Ports that you need	
;gets the address of the clock and turns it on for the ports 
;address 0x40021018 turning on 00011100 ports A, B and C
GPIO_ClockInit PROC
	LDR R0, =RCC_APB2ENR
	LDR R4, [R0]
	ORR R4, #0x1C
	STR R4, [R0]
	
	BX LR
	ENDP		
;This routine enables the GPIO for the LEDs
;GPIO CRH Mode set for Leds on port A 9 - 12
GPIO_init  PROC
	;LEDS
	;stored in port A, HRL 9 - 12
	;00 for general purpose output push-pull
	;11 for output mode max speed 50 mhz
	LDR R0, =GPIOA_CRH
	LDR R3, [R0]
	LDR R4, =0xFFF0000F
	AND R3, R4
	LDR R4, =0x33330
	ADD R3, R3, R4
	STR R4, [R0]
	BX LR
	ENDP

;;delays program using clock times/process clock counts
	ALIGN
	END