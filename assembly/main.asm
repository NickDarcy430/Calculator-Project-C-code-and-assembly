; Define variables.
.def  temp  = r16
.def position = r20
.equ SP = 0xDF



; Reset Vector.
reset:
   rjmp start

;***********************************************************
; This program reads a single number from the keypad.
;***********************************************************
; Program starts here after Reset
start:

	LDI  TEMP,  SP		; Init Stack pointer
	OUT  0x3D,  TEMP



    CALL Init           ; Initialise the system.


loop:		
	; Get a single key from the keypad and return it in R16 (temp)
	CALL ReadKey      

	; Once the key has been recieved, put it on the PORTB leds.          	
    
	RJMP	 loop			; Do all again - You don't need to reinitialize

;************************************************************************
;
Init:
// Init of constants, and column values
.equ zeros = 0x00
.equ ones = 0xFF
.equ CBITS = 0xF0
.equ CPULLUP = 0xF

.equ col1 = 0xEF
.equ col2 = 0xDF
.equ col3 = 0xBF
.equ col4 = 0x7F
.equ colidle = 0xFF
.equ equals = 0x0E
.equ addition = 0x0A
.equ subtraction = 0x0B 
.equ multiply = 0x0C

LDI XL, low(firstNumber<<1)
LDI XH, high(firstNumber<<1)

// SET Pins at C 0-3 as inputs 0, and 4 -7 as outputs 1
LDI TEMP, CBITS
OUT DDRC, TEMP


//SET bits 0-3 to 1, to activate pull up resitors
LDI TEMP, CPULLUP
OUT PORTC, TEMP

//Set PORTB to output
LDI TEMP, ones
OUT DDRB, TEMP

//Set PORTB to all off
LDI TEMP, zeros
OUT PortB, TEMP

;
; Initialise the 16-key keypad connected to Port C
; This assumes that a 16-key alpha numeric keypad is connected to
; Port C as follows (see keypad data):
; Keypad   Function 					 J2 pin
;  1      Row 1, Keys 1, 2, 3, A       1   PC0
;  2      Row 2, Keys 4, 5, 6, B       2   PC1
;  3      Row 3, Keys 7, 8, 9, C       3   PC2
;  4      Row 4, Keys *, 0, #, D       4   PC3
;  5      Column 1, Keys 1, 4, 7, *    5   PC4
;  6      Column 2, Keys 2, 5, 8, 0    6   PC5
;  7      Column 3, Keys 3, 6, 9, #    7   PC6
;  7      Column 4, Keys A, B, C, D    8   PC7

	; Set the pull-up resistor values on PORTC.
  	RET	
;************************************************************************
;
; ReadKey - Read a single digit from the keypad and store in TEMP
; Uses:  R16 (Temp)
; Returns: Temp
;
 ReadKey:
	RCALL	ReadFirst		; Read one number from keypad and return in Temp (R16)
	RET		                ; Exit back to calling routine
;
;********************************************************************
; ReadKP will determine which key is pressed and return that key in Temp
; The design of the keypad is such that each row is normally pulled high
; by the internal pullups that are enabled at init time
;
; When a key is pressed contact is made between the corresponding row and column.
; To determine which key is pressed each column is forced low in turn
; and software tests which row has been pulled low at micro input pins
;
; To avoid contact bounce the program must include a delay to allow
; the signals time to settle
;
ReadFirst:
	// COL1 SCAN
	// 
	LDI TEMP, col1
	OUT PORTC, TEMP  
	//NOP
	//NOP                                                  
	RCALL Delay
	IN R17, PINC
	CP TEMP, R17
	BRNE TableFirst              //Jumps to table, this is the section of code that controls Z registers
	// COL2 SCAN
	//
	LDI TEMP, col2
	OUT PORTC, TEMP  
	RCALL Delay
	IN R17, PINC
	CP TEMP, R17
	BRNE TableFirst
	// COL3 SCAN
	//
	LDI TEMP, col3
	OUT PORTC, TEMP  
	RCALL Delay
	IN R17, PINC
	CP TEMP, R17
	BRNE TableFirst
	// COL4 SCAN
	//
	LDI TEMP, col4
	OUT PORTC, TEMP  
	RCALL Delay
	IN R17, PINC
	CP TEMP, R17
	BRNE TableFirst
	// End of Scan section, if no jump to table, loops back to start, and scans columns again
	CALL ReadFirst

TableFirst:
	LDI ZH, high(lookupTable << 1)
	LDI ZL, low(lookupTable << 1)
	CLR R15

	ADD ZL, R17
	ADC ZH, R15
	LPM TEMP, Z

	CALL StoreFirst

	RET

ReadSecond:
	// COL1 SCAN
	// 
	LDI TEMP, col1
	OUT PORTC, TEMP  
	//NOP
	//NOP                                                  
	RCALL Delay
	IN R17, PINC
	CP TEMP, R17
	BRNE TableSecond              //Jumps to table, this is the section of code that controls Z registers
	// COL2 SCAN
	//
	LDI TEMP, col2
	OUT PORTC, TEMP  
	RCALL Delay
	IN R17, PINC
	CP TEMP, R17
	BRNE TableSecond   
	// COL3 SCAN
	//
	LDI TEMP, col3
	OUT PORTC, TEMP  
	RCALL Delay
	IN R17, PINC
	CP TEMP, R17
	BRNE TableSecond   
	// COL4 SCAN
	//
	LDI TEMP, col4
	OUT PORTC, TEMP  
	RCALL Delay
	IN R17, PINC
	CP TEMP, R17
	BRNE TableSecond   
	// End of Scan section, if no jump to table, loops back to start, and scans columns again
	CALL ReadSecond

TableSecond:
	LDI ZH, high(lookupTable << 1)
	LDI ZL, low(lookupTable << 1)
	CLR R15

	ADD ZL, R17
	ADC ZH, R15
	LPM TEMP, Z

	CALL StoreSecond

	RET

ReadThird:
	// COL1 SCAN
	// 
	LDI TEMP, col1
	OUT PORTC, TEMP  
	//NOP
	//NOP                                                  
	RCALL Delay
	IN R17, PINC
	CP TEMP, R17
	BRNE TableThird             //Jumps to table, this is the section of code that controls Z registers
	// COL2 SCAN
	//
	LDI TEMP, col2
	OUT PORTC, TEMP  
	RCALL Delay
	IN R17, PINC
	CP TEMP, R17
	BRNE TableThird    
	// COL3 SCAN
	//
	LDI TEMP, col3
	OUT PORTC, TEMP  
	RCALL Delay
	IN R17, PINC
	CP TEMP, R17
	BRNE TableThird    
	// COL4 SCAN
	//
	LDI TEMP, col4
	OUT PORTC, TEMP  
	RCALL Delay
	IN R17, PINC
	CP TEMP, R17
	BRNE TableThird    
	// End of Scan section, if no jump to table, loops back to start, and scans columns again
	CALL ReadThird

TableThird:
	LDI ZH, high(lookupTable << 1)
	LDI ZL, low(lookupTable << 1)
	CLR R15

	ADD ZL, R17
	ADC ZH, R15
	LPM TEMP, Z

	CALL StoreThird

	RET

ReadFourth:
	// COL1 SCAN
	// 
	LDI TEMP, col1
	OUT PORTC, TEMP  
	//NOP
	//NOP                                                  
	RCALL Delay
	IN R17, PINC
	CP TEMP, R17
	BRNE TableFourth              //Jumps to table, this is the section of code that controls Z registers
	// COL2 SCAN
	//
	LDI TEMP, col2
	OUT PORTC, TEMP  
	RCALL Delay
	IN R17, PINC
	CP TEMP, R17
	BRNE TableFourth
	// COL3 SCAN
	//
	LDI TEMP, col3
	OUT PORTC, TEMP  
	RCALL Delay
	IN R17, PINC
	CP TEMP, R17
	BRNE TableFourth
	// COL4 SCAN
	//
	LDI TEMP, col4
	OUT PORTC, TEMP  
	RCALL Delay
	IN R17, PINC
	CP TEMP, R17
	BRNE TableFourth
	// End of Scan section, if no jump to table, loops back to start, and scans columns again
	CALL ReadFourth

// Input of PINC value to Z registers for array indexing
TableFourth:
	LDI ZH, high(lookupTable << 1)
	LDI ZL, low(lookupTable << 1)
	CLR R15

	ADD ZL, R17
	ADC ZH, R15
	LPM TEMP, Z

	CALL StoreFourth

	RET

;************************************************************************
;
; Takes whatever is in the Temp register and outputs it to the LEDs
StoreFirst:
		CPI Temp, equals
		BREQ Calculate
		CPI Temp, addition
		BREQ Operation1
		CPI Temp, subtraction
		BREQ Operation1
		CPI Temp, multiply
		BREQ Operation1

		LDI XL, low(firstNumber<<1)
		LDI XH, high(firstNumber<<1)
		LD R21, X+
		LD R22, X+
		LD R23, X+
		LD R24, X
		MOV R21, R22
		MOV R22, R23
		MOV R23, R24
		LDI XL, low(firstNumber<<1)
		LDI XH, high(firstNumber<<1)
		ST X+, R21
		ST X+, R22
		ST X+, R23
		ST X+, Temp
		RET

Operation1:
		LDI XL, low(firstOperation<<1)
		LDI XH, high(firstOperation<<1)
		ST X, Temp
		LDI XL, low(secondNumber<<1)
		LDI XH, high(secondNumber<<1)
	
		CALL ReadSecond

StoreSecond:
		CPI Temp, equals
		BREQ Calculate
		CPI Temp, addition
		BREQ Operation2
		CPI Temp, subtraction
		BREQ Operation2
		CPI Temp, multiply
		BREQ Operation2

		LDI XL, low(secondNumber<<1)
		LDI XH, high(secondNumber<<1)
		LD R21, X+
		LD R22, X+
		LD R23, X+
		LD R24, X
		MOV R21, R22
		MOV R22, R23
		MOV R23, R24
		LDI XL, low(secondNumber<<1)
		LDI XH, high(secondNumber<<1)
		ST X+, R21
		ST X+, R22
		ST X+, R23
		ST X+, Temp

		CALL ReadSecond

Operation2:
		LDI XL, low(secondOperation<<1)
		LDI XH, high(secondOperation<<1)
		ST X, Temp
		LDI XL, low(thirdNumber<<1)
		LDI XH, high(thirdNumber<<1)

		CALL ReadThird

calculate:
		CALL combineFirst
		CALL combineSecond
		CALL combineThird
		CALL combineFourth

		LDI XL, low(firstOperation<<1)
		LDI XH, high(firstOperation<<1)
		LD R25, X

		CPI R25, addition
		BREQ ADD12
		CPI R25, subtraction
		BREQ SUB12
		CPI R25, multiply
		BREQ MUL12Jump

calculate2:
		LDI XL, low(secondOperation<<1)
		LDI XH, high(secondOperation<<1)
		LD R25, X

		CPI R25, addition
		BREQ ADD3Jump
		CPI R25, subtraction
		BREQ SUB3JUMP
		CPI R25, multiply
		BREQ MUL3Jump

		CALL Result

calculate3:
		LDI XL, low(thirdOperation<<1)
		LDI XH, high(thirdOperation<<1)
		LD R25, X

		CPI R25, addition
		BREQ ADD4Jump
		CPI R25, subtraction
		BREQ SUB4Jump
		CPI R25, multiply
		BREQ MUL4Jump

		CALL Result

MUL12Jump:
		CALL MUL12
MUL4Jump:
		CALL MUL4
SUB4Jump:
		CALL SUB4
ADD3Jump:
		CALL ADD3
ADD4JUMP:
		CALL ADD4
SUB3JUMP:
		CALL SUB3
MUL3Jump:
		CALL MUL3

ADD12:
		LDI XL, low(numberOne<<1)
		LDI XH, high(numberOne<<1)
		LD R18, X+
		LD R19, X
		LDI XL, low(numberTwo<<1)
		LDI XH, high(numberTwo<<1)
		LD R20, X+
		LD R21, X

		ADD R19, R21
		ADC R18, R20

		CALL calculate2

SUB12:
		LDI XL, low(numberOne<<1)
		LD R18, X+
		LD R19, X
		LDI XL, low(numberTwo<<1)
		LD R20, X+
		LD R21, X

		SUB R19, R21
		SUB R18, R20

		CALL calculate2

CalculateJump:
		CALL calculate
		RET

MUL12:
		CLR R29
		CLR R28
		LDI R29, 0x80

		LDI XL, low(numberOne<<1)
		LDI XH, high(numberOne<<1)
		LD R18, X+
		LD R19, X
		LDI XL, low(numberTwo<<1)
		LDI XH, high(numberTwo<<1)
		LD R20, X+
		LD R21, X

		CLR R22
		CLR R23

		MUL R18, R21
		MOV R30, R1
		MOV R31, R0
		MUL R30, R29
		LSL R1
		LSL R0
		ADD R22, R1
		ADD R23, R0
		MUL R31, R29
		LSL R1
		LSL R0
		ADC R1,R28
		ADD R22, R1
		ADD R23, R0

		MUL R19, R20
		MOV R30, R1
		MOV R31, R0
		MUL R30, R29
		LSL R1
		LSL R0
		ADD R22, R1
		ADD R23, R0
		MUL R31, R29
		LSL R1
		LSL R0
		ADD R22, R1
		ADD R23, R0

		MUL R19, R21
		ADD R23, R0
		ADC R22, R1
		
		MOV R18, R22
		MOV R19, R23

		CALL calculate2

ADD3:
		LDI XL, low(numberThree<<1)
		LDI XH, high(numberThree<<1)
		LD R20, X+
		LD R21, X

		ADD R19, R21
		ADC R18, R20

		CALL calculate3

SUB3:
		LDI XL, low(numberThree<<1)
		LDI XH, high(numberThree<<1)
		LD R20, X+
		LD R21, X

		SUB R19, R21
		SUB R18, R20

		CALL calculate3

MUL3:
		CLR R29
		CLR R28
		LDI R29, 0x80

		LDI XL, low(numberThree<<1)
		LDI XH, high(numberThree<<1)
		LD R20, X+
		LD R21, X

		CLR R22
		CLR R23

		MUL R18, R21
		MOV R30, R1
		MOV R31, R0
		MUL R30, R29
		LSL R1
		LSL R0
		ADD R22, R1
		ADD R23, R0
		MUL R31, R29
		LSL R1
		LSL R0
		ADC R1,R28
		ADD R22, R1
		ADD R23, R0

		MUL R19, R20
		MOV R30, R1
		MOV R31, R0
		MUL R30, R29
		LSL R1
		LSL R0
		ADD R22, R1
		ADD R23, R0
		MUL R31, R29
		LSL R1
		LSL R0
		ADD R22, R1
		ADD R23, R0

		MUL R19, R21
		ADD R23, R0
		ADC R22, R1
		
		MOV R18, R22
		MOV R19, R23

		CALL calculate3

ADD4:
		LDI XL, low(numberFour<<1)
		LDI XH, high(numberFour<<1)
		LD R20, X+
		LD R21, X

		ADD R19, R21
		ADC R18, R20

		CALL Result

SUB4:
		LDI XL, low(numberFour<<1)
		LDI XH, high(numberFour<<1)
		LD R20, X+
		LD R21, X

		SUB R19, R21
		SUB R18, R20

		CALL Result

MUL4:
		CLR R29
		CLR R28
		LDI R29, 0x80

		LDI XL, low(numberFour<<1)
		LDI XH, high(numberFour<<1)
		LD R20, X+
		LD R21, X

		CLR R22
		CLR R23

		MUL R18, R21
		MOV R30, R1
		MOV R31, R0
		MUL R30, R29
		LSL R1
		LSL R0
		ADD R22, R1
		ADD R23, R0
		MUL R31, R29
		LSL R1
		LSL R0
		ADC R1,R28
		ADD R22, R1
		ADD R23, R0

		MUL R19, R20
		MOV R30, R1
		MOV R31, R0
		MUL R30, R29
		LSL R1
		LSL R0
		ADD R22, R1
		ADD R23, R0
		MUL R31, R29
		LSL R1
		LSL R0
		ADD R22, R1
		ADD R23, R0

		MUL R19, R21
		ADD R23, R0
		ADC R22, R1
		
		MOV R18, R22
		MOV R19, R23

		CALL Result

CalculateJump2:
		CALL calculate
		RET

StoreThird:
		CPI Temp, equals
		BREQ CalculateJump2
		CPI Temp, addition
		BREQ Operation3
		CPI Temp, subtraction
		BREQ Operation3
		CPI Temp, multiply
		BREQ Operation3

		LDI XL, low(thirdNumber<<1)
		LDI XH, high(thirdNumber<<1)
		LD R21, X+
		LD R22, X+
		LD R23, X+
		LD R24, X
		MOV R21, R22
		MOV R22, R23
		MOV R23, R24
		LDI XL, low(thirdNumber<<1)
		LDI XH, high(thirdNumber<<1)
		ST X+, R21
		ST X+, R22
		ST X+, R23
		ST X+, Temp

		CALL ReadThird

Operation3:
		LDI XL, low(thirdOperation<<1)
		LDI XH, high(thirdOperation<<1)
		ST X, Temp
		LDI XL, low(fourthNumber<<1)
		LDI XH, high(fourthNumber<<1)

		CALL ReadFourth

StoreFourth:
		CPI Temp, equals
		BREQ CalculateJump2
		LDI XL, low(fourthNumber<<1)
		LDI XH, high(fourthNumber<<1)
		LD R21, X+
		LD R22, X+
		LD R23, X+
		LD R24, X
		MOV R21, R22
		MOV R22, R23
		MOV R23, R24
		LDI XL, low(fourthNumber<<1)
		LDI XH, high(fourthNumber<<1)
		ST X+, R21
		ST X+, R22
		ST X+, R23
		ST X+, Temp

		CALL ReadFourth


combineFirst:
		LDI R22, 0x01
		;Multiply first digit by 1000
		LDI R18, 0x64
		LDI R19, 0x0A

		LDI XL, low(firstNumber<<1)
		LDI XH, high(firstNumber<<1)
		LD Temp, X+

		MUL Temp, R18
		MOV temp, R1
		MOV R17, R0

		MUL temp, R19
		CLR R20
		CLR R21
		MOV R20, R1
		MOV R21, R0

		MUL R17, R19
		ADD R21, R0
		ADC R20, R1

		;Multiply second digit by 100
		LDI XL, low(firstNumber<<1)
		LDI XH, high(firstNumber<<1)
		ADD XL, R22
		LD Temp, X
		
		MUL Temp, R18
		MOV Temp, R1
		MOV R17, R0
		
		ADD R21, R0
		ADC R20, R1

		;Multiply third digit by 10
		LDI XL, low(firstNumber<<1)
		LDI XH, high(firstNumber<<1)
		LDI R22, 0x02
		ADD XL, R22
		LD Temp, X
		
		MUL Temp, R19
		MOV Temp, R1
		MOV R17, R0
		
		ADD R21, R0
		ADC R20, R1

		;Last digit
		LDI XL, low(firstNumber<<1)
		LDI XH, high(firstNumber<<1)
		LDI R22, 0x03
		ADD XL, R22
		LD Temp, X
		ADD R21, Temp

		LDI XL, low(numberOne<<1)
		LDI XH, high(numberOne<<1)
		ST X+, R20
		ST X, R21

		RET

combineSecond:
		LDI R22, 0x01
		;Multiply first digit by 1000
		LDI R18, 0x64
		LDI R19, 0x0A

		LDI XL, low(secondNumber<<1)
		LDI XH, high(secondNumber<<1)
		LD Temp, X+

		MUL Temp, R18
		MOV temp, R1
		MOV R17, R0

		MUL temp, R19
		CLR R20
		CLR R21
		MOV R20, R1
		MOV R21, R0

		MUL R17, R19
		ADD R21, R0
		ADC R20, R1

		;Multiply second digit by 100
		LDI XL, low(secondNumber<<1)
		LDI XH, high(secondNumber<<1)
		ADD XL, R22
		LD Temp, X
		
		MUL Temp, R18
		MOV Temp, R1
		MOV R17, R0
		
		ADD R21, R0
		ADC R20, R1

		;Multiply third digit by 10
		LDI XL, low(secondNumber<<1)
		LDI XH, high(secondNumber<<1)
		LDI R22, 0x02
		ADD XL, R22
		LD Temp, X
		
		MUL Temp, R19
		MOV Temp, R1
		MOV R17, R0
		
		ADD R21, R0
		ADC R20, R1

		;Last digit
		LDI XL, low(secondNumber<<1)
		LDI XH, high(secondNumber<<1)
		LDI R22, 0x03
		ADD XL, R22
		LD Temp, X
		ADD R21, Temp

		LDI XL, low(numberTwo<<1)
		LDI XH, high(numberTwo<<1)
		ST X+, R20
		ST X, R21

		RET

combineThird:
		LDI R22, 0x01
		;Multiply first digit by 1000
		LDI R18, 0x64
		LDI R19, 0x0A

		LDI XL, low(thirdNumber<<1)
		LDI XH, high(thirdNumber<<1)
		LD Temp, X+

		MUL Temp, R18
		MOV temp, R1
		MOV R17, R0

		MUL temp, R19
		CLR R20
		CLR R21
		MOV R20, R1
		MOV R21, R0

		MUL R17, R19
		ADD R21, R0
		ADC R20, R1

		;Multiply second digit by 100
		LDI XL, low(thirdNumber<<1)
		LDI XH, high(thirdNumber<<1)
		ADD XL, R22
		LD Temp, X
		
		MUL Temp, R18
		MOV Temp, R1
		MOV R17, R0
		
		ADD R21, R0
		ADC R20, R1

		;Multiply third digit by 10
		LDI XL, low(thirdNumber<<1)
		LDI XH, high(thirdNumber<<1)
		LDI R22, 0x02
		ADD XL, R22
		LD Temp, X
		
		MUL Temp, R19
		MOV Temp, R1
		MOV R17, R0
		
		ADD R21, R0
		ADC R20, R1

		;Last digit
		LDI XL, low(thirdNumber<<1)
		LDI XH, high(thirdNumber<<1)
		LDI R22, 0x03
		ADD XL, R22
		LD Temp, X
		ADD R21, Temp

		LDI XL, low(numberThree<<1)
		LDI XH, high(numberThree<<1)
		ST X+, R20
		ST X, R21

		RET

combineFourth:
		LDI R22, 0x01
		;Multiply first digit by 1000
		LDI R18, 0x64
		LDI R19, 0x0A

		LDI XL, low(fourthNumber<<1)
		LDI XH, high(fourthNumber<<1)
		LD Temp, X+

		MUL Temp, R18
		MOV temp, R1
		MOV R17, R0

		MUL temp, R19
		CLR R20
		CLR R21
		MOV R20, R1
		MOV R21, R0

		MUL R17, R19
		ADD R21, R0
		ADC R20, R1

		;Multiply second digit by 100
		LDI XL, low(fourthNumber<<1)
		LDI XH, high(fourthNumber<<1)
		ADD XL, R22
		LD Temp, X
		
		MUL Temp, R18
		MOV Temp, R1
		MOV R17, R0
		
		ADD R21, R0
		ADC R20, R1

		;Multiply third digit by 10
		LDI XL, low(fourthNumber<<1)
		LDI XH, high(fourthNumber<<1)
		LDI R22, 0x02
		ADD XL, R22
		LD Temp, X
		
		MUL Temp, R19
		MOV Temp, R1
		MOV R17, R0
		
		ADD R21, R0
		ADC R20, R1

		;Last digit
		LDI XL, low(fourthNumber<<1)
		LDI XH, high(fourthNumber<<1)
		LDI R22, 0x03
		ADD XL, R22
		LD Temp, X
		ADD R21, Temp

		LDI XL, low(numberFour<<1)
		LDI XH, high(numberFour<<1)
		ST X+, R20
		ST X, R21

		RET

Result:
		OUT PORTB, R18
		CALL Delay
		OUT PORTB, R19
		




		

;*************************************
;
; Delay routine
;
; this has an inner loop and an outer loop. The delay is approximately
; equal to 256*256*number of inner loop instruction cycles.
; You can vary this by changing the initial values in the accumulator.
; If you need a much longer delay change one of the loop counters
; to a 16-bit register such as X or Y.
;
;*************************************
Delay:
	PUSH R16			; Save R16 and 17 as we're going to use them
	PUSH R17			; as loop counters
	PUSH R0			; we'll also use R0 as a zero value
	CLR R0
	CLR R16			; Init inner counter
	CLR R17			; and outer counter
L1: 
	DEC R16         ; Counts down from 0 to FF to 0
	CPSE R16, R0    ; equal to zero?
	BRNE L1			; If not, do it again
	CLR R16			; reinit inner counter
L2: 
	DEC R17
    CPSE R17, R0    ; Is it zero yet?
    BRNE L1			; back to inner counter

	POP R0          ; Done, clean up and return
	POP R17
	POP R16				
    RET


	// Table with all data for outputting to PORTB LEDs
lookupTable:
	.DB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	.DB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	.DB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	.DB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	.DB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	.DB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	.DB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	.DB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0D, 0xFF, 0xFF, 0xFF, 0x0C, 0xFF, 0x0B, 0x0A, 0xFF
	.DB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	.DB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	.DB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	.DB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 0xFF, 0xFF, 0xFF, 0x09, 0xFF, 0x06, 0x03, 0xFF
	.DB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	.DB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x08, 0xFF, 0x05, 0x02, 0xFF
	.DB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0E, 0xFF, 0xFF, 0xFF, 0x07, 0xFF, 0x04, 0x01, 0xFF
	.DB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF

firstNumber:
	.DB 0x00, 0x00, 0x00, 0x00
secondNumber:
	.DB 0x00, 0x00, 0x00, 0x00
thirdNumber:
	.DB 0x00, 0x00, 0x00, 0x00
fourthNumber:
	.DB 0x00, 0x00, 0x00, 0x00
firstOperation:
	.DB 0x00
secondOperation:
	.DB 0x00
thirdOperation:
	.DB 0x00

NumberOne:
	.DB 0x00, 0x00
NumberTwo:
	.DB 0x00, 0x00
NumberThree:
	.DB 0x00, 0x00
NumberFour:
	.DB 0x00, 0x00

