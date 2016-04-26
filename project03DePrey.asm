TITLE Project 03    (project03DePrey.asm)

; Author: Joseph DePrey
; depreyj@oregonstate.edu
; CS271-400 / Project 03                  Due Date: 5/1/16
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
; **EC: Number the lines during user input
; **EC: Calculate and display the average as a floating-point number,
; 		rounded to the nearest .001
; **EC: Seomthing astoundingly creative


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
errorMsg		BYTE		"Invalid input. Please enter an integer within range.", 0
errorMsgSpecial BYTE 		"Sorry, but you failed to enter a single valid number.", 0
dot				BYTE 		".", 0
goodBye 		BYTE 		"Until next time ", 0

EC_1			BYTE		"**EC1: Numbered lines during user input", 0
EC_2			BYTE		"**EC2: Average displayed as floating-point, rounded to nearest .001", 0
EC_3			BYTE		"**EC3: Something special", 0

userName		BYTE 		26 DUP(?)		; user's name and input buffer

userInt 		SDWORD		?		; store user integers here
validCount		DWORD 		0 		; number of valid user inputs
lineCount 		DWORD 		1 		; line numbers for user input
sum 			SDWORD		0 		; sum of valid numbers inputted by user
average			SDWORD		? 		; average of valid numbers
floatInt		SDWORD		?		; integer-part of average
floatMantissa	DWORD		?		; mantissa of floating-point average
remainder		DWORD		?		; remainder 
roundFactor		DWORD		1000

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

	; validate. if out of range(negative) jump to errorDisplay
	cmp 	eax, LOWERLIMIT
	jnge	errorDisplay
	; if non-negative jump to display
	cmp		eax, 0
	jnl 	display
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


	exit	; exit to operating system
main ENDP


END main
