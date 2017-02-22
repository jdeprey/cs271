TITLE Simple Calculator     (simple_calculator.asm)

; Author: Joseph DePrey
; Description: A program which does the following: 
; 1. Displays programmers name and program title on the output screen
; 2. Displays instructions for the user
; 3. Prompts the user to enter two numbers
; 4. Calculates the sum, difference, product, (integer)quotient and remainder of those numbers
; 5. Displays a terminating message
; Extras: Program repeats until the user chooses to quit
; 	Program verifies second number less than first
; 	Program calculates and displays quotient as floating-point number, rounded to nearest .001 


INCLUDE Irvine32.inc


.data

myName			BYTE 		"produced by Joseph DePrey", 0
myTitle			BYTE 		"Magical Calculator ", 0
intro_1			BYTE		"Enter two numbers and you shall receive their sum, difference, product, quotient, and remainder.", 0
prompt_1		BYTE		"First number: ", 0
prompt_2		BYTE		"Second number: ", 0
goodBye 		BYTE 		"Goodbye for now..." 	; say goodbye to user
plus			BYTE 		" + ", 0
minus			BYTE 		" - ", 0
times			BYTE 		" x ", 0
dividedBy		BYTE 		" / ", 0
remainderIs		BYTE 		" remainder ", 0
equals 			BYTE 		" = ", 0
dot				BYTE 		".", 0
floatMsg		BYTE		"Quotient as floating-point number, rounded to nearest .001: ", 0
errorMsg		BYTE 		"Invalid Input. Your second number should be less than your first.", 0
errorMsgZero	BYTE 		"Invalid Input.  Cannot divide by zero.", 0
prompt_3 		BYTE 		"Would you like to quit? Enter 1 to exit or press any key to continue: ", 0
EC_1			BYTE		"**EC: Program repeats until the user chooses to quit", 0
EC_2			BYTE		"**EC: Program verifies second number less than first", 0
EC_3			BYTE		"**EC: Program calculates and displays quotient as floating-point number, rounded to nearest .001", 0

userInt_1		DWORD		?		; first integer to be entered by user
userInt_2		DWORD		?		; second integer to be entered by user
sum				DWORD		?		; sum of the two integers entered by user
difference		DWORD		?		; difference of the two integers entered by user
product			DWORD		?		; product of the two integers entered by user
quotient		DWORD		?		; quotient of the two integers entered by user
remainder		DWORD		?		; remainder 
mantissa	    DWORD		?		; mantissa of floating-point quotient
roundFactor		DWORD		1000




.code
main PROC

; introduction: display programmers name and program title
	mov 		edx, OFFSET myTitle
	call 		WriteString
	mov 		edx, OFFSET myName
	call 		WriteString
	call 		CrLf
	mov 		edx, OFFSET EC_1
	call 		WriteString
	call 		CrLf
	mov 		edx, OFFSET EC_2
	call 		WriteString
	call 		CrLf
	mov 		edx, OFFSET EC_3
	call 		WriteString
	call 		CrLf

inputLoop:
	; get the data: display instructions for user
		mov 		edx, OFFSET intro_1
		call 		WriteString
		call 		CrLf
	; get two numbers from user
		mov 		edx, OFFSET prompt_1
		call 		WriteString
		call 		ReadInt
		mov 		userInt_1, eax
	
		mov 		edx, OFFSET prompt_2
		call 		WriteString
		call 		ReadInt
		cmp 		eax, userInt_1
		jge 		errorDisplay
		mov 		userInt_2, eax
	

; calculate the required values
		; sum
		mov 		eax, userInt_1
		add 		eax, userInt_2
		mov 		sum, eax
	
		; difference
		mov 		eax, userInt_1
		sub 		eax, userInt_2
		mov 		difference, eax
	
		; product
		mov 		eax, userInt_1
		mov 		ebx, userInt_2
		mul 		ebx
		mov 		product, eax
	
		; quotient and remainder
		mov 		eax, userInt_1
		cdq	
		mov 		ebx, userInt_2
			; skip division if second number is zero
			cmp 		ebx, 0
			je 			errorDisplayZero
	
		; make sure edx is set to 0
		cdq
		mov 		edx, 0
		div 		ebx
		mov 		quotient, eax
		mov 		remainder, edx

		; quotient as floating-point
		; multiply remainder by 1000 because we want floating-point to nearest .001
		mov 		eax, roundFactor
		mov 		ebx, remainder
		mul 		ebx
		cdq
		mov 		ebx, userInt_2
		; make sure edx is set to 0
		; divide remainder*1000 by second number to get mantissa of the float
		cdq
		mov 		edx, 0
		div 		ebx
		mov 		mantissa, eax


displaySequence:	
; display the results
		; display sum
		mov 		eax, userInt_1
		call 		WriteDec
		mov 		edx, OFFSET plus
		call 		WriteString
		mov 		eax, userInt_2
		call 		WriteDec
		mov 		edx, OFFSET equals
		call 		WriteString
		mov 		eax, sum
		call 		WriteDec
		call 		CrLf
	
		; display difference
		mov 		eax, userInt_1
		call 		WriteDec
		mov 		edx, OFFSET minus
		call 		WriteString
		mov 		eax, userInt_2
		call 		WriteDec
		mov 		edx, OFFSET equals
		call 		WriteString
		mov 		eax, difference
		call 		WriteDec
		call 		CrLf
	
		; display product
		mov 		eax, userInt_1
		call 		WriteDec
		mov 		edx, OFFSET times
		call 		WriteString
		mov 		eax, userInt_2
		call 		WriteDec
		mov 		edx, OFFSET equals
		call 		WriteString
		mov 		eax, product
		call 		WriteDec
		call 		CrLf
	
		; display quotient and remainder
		mov 		eax, userInt_1
		call 		WriteDec
		mov 		edx, OFFSET dividedBy
		call 		WriteString
		mov 		eax, userInt_2
		call 		WriteDec
		mov 		edx, OFFSET equals
		call 		WriteString
		mov 		eax, quotient
		call 		WriteDec
		mov 		edx, OFFSET remainderIs
		call 		WriteString
		mov 		eax, remainder
		call 		WriteDec
		call 		CrLf
		
		; display quotient as floating-point
		mov 		edx, OFFSET floatMsg
		call 		WriteString
		mov 		eax, quotient
		call 		WriteDec
		mov 		edx, OFFSET dot
		call 		WriteString
		mov			eax, mantissa
		call 		WriteDec
		call 		CrLf

		; ask if user would like to try again, if user enters '1' program will exit, otherwise continue
		mov			eax, 0
		mov 		edx, OFFSET prompt_3
		call 		WriteString
		call 		ReadInt
		cmp 		eax, 1
		je 			goodbyeDisplay
		jmp			inputLoop

; display error if second number is larger than first, allow user to input numbers again 
errorDisplay:
		mov 		edx, OFFSET errorMsg
		call 		WriteString
		call 		CrLf
		jmp			inputLoop

errorDisplayZero:
		mov 		edx, OFFSET errorMsgZero
		call 		WriteString
		call 		CrLf
		jmp			displaySequence


goodbyeDisplay:
		; say goodbye
		mov 	 	edx, OFFSET goodBye
		call 		WriteString
		call 		CrLf

	exit	; exit to operating system
main ENDP


END main
