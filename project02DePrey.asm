TITLE Project 02    (project02DePrey.asm)

; Author: Joseph DePrey
; depreyj@oregonstate.edu
; CS271-400 / Project 02                  Due Date: 4/17/16
; Description: A program to calculate Fibonacci numbers 
; 	Displays programmers name and program title on the output screen
; 	Gets users name and greets user
; 	Prompt the user to enter the number of Fibonacci terms to be displayed. 
;		Advise the user to enter an integer in the range [1 .. 46].
; 	Get and validate user input
; 	Calculate and display all of the Fibonacci numbers up to and including 
; 		the nth term. The results are displayed 5 terms per line with at 
;		least 5 spaces between terms.
;	Display a parting message that includes the user’s name, and terminate the program.
; **EC: Number aligned in columns, 5 terms per line
; **EC: Someting incredible, different colored text for each term


INCLUDE Irvine32.inc

UPPERLIMIT = 47			; the maximum number of Fibonnaci terms to be displayed

.data

myTitle		BYTE 		"Fibonacci Calculator ", 0
myName		BYTE 		"produced by Joseph DePrey", 0
prompt_1	BYTE		"Please enter your first name: ", 0
greeting	BYTE		"Greetings ", 0
intro_1		BYTE		"This program will display the terms of a Fibonacci sequence.", 0
prompt_2	BYTE		"How many Fibonacci terms would you like to see?  Enter an integer in the range of 1 to ", 0
goodBye 	BYTE 		"Until next time ", 0
errorMsg	BYTE		"Invalid input. Please enter an integer within range.", 0
exitPrompt 	BYTE 		"Would you like to quit? Enter 1 to exit or press any key to continue: ", 0
EC_1		BYTE		"**EC1: Numbers displayed in aligned columns", 0
EC_2		BYTE		"**EC2: Some incredibly colorful text", 0
userName	BYTE 		26 DUP(?)		; user's name and input buffer

userInt 	DWORD		0		; number of Fibonnaci terms desired by user
fibsN_2 	DWORD 		0		; the Fibonnaci term n-2
fibsN_1		DWORD 		1       ; the Fibonnaci term n-1
columns		DWORD 		5		; number of columns in which terms are aligned
colors 		DWORD		16		; number of colors to cycle through
termCount	DWORD 		0 		; counter for Fibonnaci terms already displayed

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
	; get users name and greet them
	mov 	edx, OFFSET prompt_1
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

userInstructions:
	mov 	edx, OFFSET intro_1
	call 	WriteString
	call 	CrLf

getUserData:
; get the data, make sure values are within range
	mov 	edx, OFFSET prompt_2
	call 	WriteString
	mov		eax, UPPERLIMIT
	call 	WriteDec
	call 	CrLf
	call 	ReadInt	
	; validate
	cmp 	eax, UPPERLIMIT
	jg		errorDisplay
	cmp		eax, 0
	jle 	errorDisplay
	mov 	userInt, eax

	; set counter for user-defined number of terms
	mov 	ecx, userInt

displayFibs:	
; cycle through different colored text on black background 	
	mov		eax, ecx
	cdq
	mov 	edx, 0
	mov		ebx, colors
	cdq
	div     ebx
	mov 	eax, edx
	add		eax, 1
	call 	setTextColor

; calculate and display the desired amount of Fibonacci terms
	mov 	eax, fibsN_1
	call 	WriteDec
	; calculate next term, use ebx as temp
	add		eax, fibsN_2
	mov  	ebx, eax
	mov 	eax, fibsN_1
	mov 	fibsN_2, eax
	mov 	fibsN_1, ebx
	; print two tabs for formatting
	mov 	al, TAB
	call 	WriteChar
	call 	WriteChar
	; increment term counter
	mov 	eax, termCount
	add 	eax, 1
	mov 	termCount, eax
	; use term counter % 5 to determine when to insert new line
	mov 	edx, 0
	cdq
	mov		ebx, columns
	cdq
	div     ebx
	cmp 	edx, 0
	je 		formatLoop
	continue:
	loop  	displayFibs	

	jmp		goodbyeDisplay

	formatLoop:
	call 	CrLf
	jmp continue

	

; display error if desired number of terms is out of range
errorDisplay:
		mov 	edx, OFFSET errorMsg
		call 	WriteString
		call 	CrLf
		jmp		getUserData

goodbyeDisplay:
		; say goodbye
		call 	CrLf
		mov 	edx, OFFSET goodBye
		call 	WriteString
		mov 	edx, OFFSET userName
		call 	  WriteString
		call 	CrLf

	exit	; exit to operating system
main ENDP


END main
