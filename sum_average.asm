TITLE sum_average    (sum_average.asm)

; Author: Joseph DePrey
; Description: A program to perform the following:
; 1. Display the program title and programmer’s name.
; 2. Get the user’s name, and greet the user.
; 3. Display instructions for the user.
; 4. Repeatedly prompt the user to enter a number. Validate 
; the user input to be in [-100, -1] (inclusive).
; Count and accumulate the valid user numbers until a non-negative 
; number is entered. (The non-negative number is discarded.)
; 5. Calculate the (rounded integer) average of the negative numbers. 
; 6. Display:
; 	i. the number of negative numbers entered (Note: if no negative 
;	numbers were entered, display a special message and skip to iv.)
;	ii. the sum of negative numbers entered
;	iii. the average, rounded to the nearest integer (e.g. -20.5 
;	rounds to -20)
; 	iv. a parting message (with the user’s name)
; Extras: Number the lines during user input
;         Calculate and display the average as a floating-point number,
; 		rounded to the nearest .001
<<<<<<< HEAD:project03DePrey.asm
; **EC: Display max, min	
=======

>>>>>>> origin/master:sum_average.asm

INCLUDE Irvine32.inc

LOWERLIMIT = -100			; the lower limit of the numbers that can be entered by user

.data

myTitle			BYTE 		"A C C U M U L A T O R ", 0
myName			BYTE 		" produced by Joseph DePrey", 0
promptName		BYTE		"Please enter your first name: ", 0
greeting		BYTE		"Greetings ", 0
intro			BYTE		"This program will produce the sum and average of the numbers you enter.", 0
instruct_a		BYTE		"Please enter numbers in [", 0
instruct_b  	BYTE 		", -1]", 0
instruct_c  	BYTE 		"Enter a non-negative number when you are finished.", 0
promptNum  		BYTE 		"  Enter number: ", 0
totalMsg_a 	 	BYTE 		"You entered ", 0
totalMsg_b	 	BYTE		" valid numbers.", 0
sumMsg 		   	BYTE 		"Sum (of valid numbers): ", 0
avgMsg 	 		BYTE 		"Rounded Average: ", 0
floatMsg		BYTE		"Average (as floating-point): ", 0
maxMsg			BYTE		"Maximum: ", 0
minMsg			BYTE		"Minimum: ", 0

errorMsg		BYTE		"Invalid input. Please enter an integer within range.", 0
errorMsgSpecial BYTE 		"Sorry, but you failed to enter a single valid number.", 0
dot				BYTE 		".", 0
goodBye 		BYTE 		"Until next time ", 0

EC_1			BYTE		"**EC1: Numbered lines during user input", 0
EC_2			BYTE		"**EC2: Average displayed as floating-point, rounded to nearest .001", 0
EC_3			BYTE		"**EC3: Display maximum and minimum of numbers", 0

userName		BYTE 		26 DUP(?)		; user's name and input buffer

userInt 		SDWORD		?		; store user integers here
validCount		DWORD 		0 		; number of valid user inputs
lineCount 		DWORD 		1 		; line numbers for user input
sum 			SDWORD		0 		; sum of valid numbers inputted by user
average			SDWORD		? 		; average of valid numbers
floatInt		SDWORD		?		; integer-part of average
floatRemainder  DWORD 		?		; remainder of floating-point representation
floatMantissa	DWORD		0		; mantissa of floating-point average
remainder		DWORD		?		; remainder 
roundFactor		DWORD		1000
currentMax		SDWORD		-100 	; current maximim number inputted
currentMin 		SDWORD 		0 		; current minimum number inputted

.code
main PROC

introduction:
; introduction: display programmers name and program title
	mov 	edx, OFFSET myTitle
	call 	WriteString
	mov 	edx, OFFSET myName
	call 	WriteString
	call 	CrLf
	mov 	edx, OFFSET EC_1
	call 	WriteString
	call 	CrLf
	mov 	edx, OFFSET EC_2
	call 	WriteString
	call 	CrLf
	mov 	edx, OFFSET EC_3
	call 	WriteString
	call 	CrLf
	; get users name and greet them
	mov 	edx, OFFSET promptName
	call 	WriteString
	; maximum number of non-null chars to read
	mov 	edx, OFFSET userName
	mov		ecx, 26
	call 	ReadString
	call 	CrLf
	mov 	edx, OFFSET greeting
	call 	WriteString
	mov 	edx, OFFSET userName
	call 	WriteString
	call 	CrLf
	; program introduction for user
	mov 	edx, OFFSET intro
	call 	WriteString
	call 	CrLf

userInstructions:
	mov 	edx, OFFSET instruct_a
	call 	WriteString
	mov 	eax, LOWERLIMIT
	call 	WriteInt
	mov 	edx, OFFSET instruct_b
	call 	WriteString
	call 	CrLf
	mov 	edx, OFFSET instruct_c
	call 	WriteString
	call 	CrLf

getUserData:
; get the data, make sure values are within range
	mov 	eax, lineCount
	call 	WriteDec
	mov 	edx, OFFSET promptNum
	call 	WriteString

	call 	ReadInt
	mov 	userInt, eax
	call 	CrLf


	limitCheck:
	; validate. if out of range(negative) jump to errorDisplay
	cmp 	eax, LOWERLIMIT
	jnge	errorDisplay
	; if non-negative jump to display
	cmp		eax, 0
	jns 	calculate

	maxCheck:
	; compare to current maximum
	cmp 	eax, currentMax
	jg 		updateMax

	minCheck:
	; compare to current mimimum
	cmp 	eax, currentMin
	jl 		updateMin	


	updateCount:
	; if within range add to sum, increment valid number counter
	mov 	userInt, eax
	mov 	eax, sum
	add 	eax, userInt
	mov 	sum, eax
	mov 	eax, validCount
	inc 	eax
	mov 	validCount, eax

	; increment line counter
	mov 	eax, lineCount
	inc 	eax
	mov 	lineCount, eax

	; continue asking for numbers
	jmp 	getUserData

calculate:
	; calculate average or rounded average
	mov 	eax, sum
	mov 	edx, 0
	cdq							; extend EAX into EDX
	mov 	ebx, validCount		; divisor
	idiv 	ebx 				; quotient in EAX, remainder in EDX
	mov 	average, eax 		; move quotient to average variable
	mov 	floatInt, eax 		; move quotient to floating-point integer part 
	cmp 	edx, 0      		; if remainder is zero do not round or calculate floating-point
	jz 		display
	mov 	remainder, edx

	; if the remainder is greater than half of divisor then round-down(decrement)
	; use a positive remainder for comparison
	neg 	remainder
	mov 	eax, remainder
	mov 	ebx, 2
	mul 	ebx
	cmp 	eax, validCount
	jna		calculateFloat		; if remainder not greater than half of divisor, don't round
	
	; round down
	mov 	eax, average
	dec 	eax
	mov 	average, eax

calculateFloat:
	; calculate floating-point representation of average without rounding
	mov 	eax, remainder
	mov 	ebx, roundFactor
	mul 	ebx
	cdq
	mov 	ebx, validCount
	div 	ebx
	mov 	floatMantissa, eax
	; test if float's last digit needs to be rounded up 
	mov 	floatRemainder, edx
	mov 	eax, edx
	mov 	ebx, 2
	mul 	ebx
	cmp 	eax, validCount
	jna 	display
	; round up last digit 
	mov 	eax, floatMantissa
	inc 	eax
	mov 	floatMantissa, eax 
	jmp 	display

updateMax:
	; store new maximum
	mov 	currentMax, eax
	jmp 	minCheck


updateMin:
	; store new minimum
	mov 	currentMin, eax
	jmp 	updateCount

display:	
	; make sure at least one valid number has been entered, else jump to error
	mov 	eax, validCount
	cmp 	eax, 0
	jz 		errorSpecial

	; display number of valid numbers entered
	mov 	edx, OFFSET totalMsg_a
	call 	WriteString
	call 	WriteDec
	mov 	edx, OFFSET totalMsg_b
	call 	WriteString
	call 	CrLf
	
	; display sum of valid numbers entered
	mov 	edx, OFFSET sumMsg
	call 	WriteString
	mov 	eax, sum
	call 	WriteInt
	call 	CrLf

	; display average of valid user numbers
	mov 	edx, OFFSET avgMsg
	call 	WriteString
	mov 	eax, average
	call 	WriteInt
	call 	CrLf
	
	; display floating-point average 
	mov 	edx, OFFSET floatMsg
	call 	WriteString
	mov 	eax, floatInt
	call 	WriteInt
	mov 	edx, OFFSET dot
	call 	WriteString
	mov 	eax, floatMantissa
	call 	WriteDec
	call 	CrLf


maxMinDisplay:
	; display max and min
	mov 	edx, OFFSET maxMsg
	call 	WriteString
	mov 	eax, currentMax
	call 	WriteInt
	call 	CrLf
	mov 	edx, OFFSET minMsg
	call 	WriteString
	mov 	eax, currentMin
	call 	WriteInt
	jmp 	goodbyeDisplay

updateAverage:
	; update average 
	mov 	average, eax
	jmp 	display
	

errorDisplay:
	; display error if desired number of terms is out of range
	mov 	edx, OFFSET errorMsg
	call 	WriteString
	call 	CrLf
	jmp		getUserData

errorSpecial:
	; display special error if user did not enter any valid numbers
	mov 	edx, OFFSET errorMsgSpecial
	call 	WriteString

goodbyeDisplay:
	; say goodbye
	call 	CrLf
	mov 	edx, OFFSET goodBye
	call 	WriteString
	mov 	edx, OFFSET userName
	call 	 WriteString
	call 	CrLf

	exit	; exit to operating system
main ENDP


END main
