TITLE Project 04    (project04DePrey.asm)

; Author: Joseph DePrey
; depreyj@oregonstate.edu
; CS271-400 / Project 04                  Due Date: 5/8/16
; Description: A program to calculate and display composite numbers.  User is asked 
; 	to enter a number n from 1 to the upper limit and the program will display n 
; 	composite numbers, ten per line.
; **EC: Align the output columns
; **EC: Display extra composites one page at a time and allow user to press any key to continue
; **EC: Increase efficiency by checking against only prime divisors 	
; **EC: Color!

INCLUDE Irvine32.inc

UPPER_LIMIT = 400			; maximum number of composites that can be displayed

.data

myTitle			BYTE 		"Composite Creator ", 0
myName			BYTE 		"produced by Joseph DePrey", 0
intro			BYTE		"Enter a number and I'll show you that many composite numbers.", 0
prompt1			BYTE		"Please enter a number in [1, ", 0
prompt2 	 	BYTE 		"]: ", 0
nextPrompt		BYTE		"Press any key for next page ", 0
exitPrompt		BYTE 		"Would you like to quit? Enter 1 to exit or press any key to continue: ", 0	


errorMsg		BYTE		"Invalid input. Please enter an integer within range.", 0
goodBye 		BYTE 		"Until next time ", 0
spacing 		BYTE 		"	", 0 

EC_1			BYTE		"**EC1: Output columns are aligned", 0
EC_2			BYTE		"**EC2: Display composites page by page(300 per 'page')", 0
EC_3			BYTE		"**EC3: Increased efficiency. Primes stored to array", 0
EC_4			BYTE		"**EC4: Pretty colors", 0

userInt 		SDWORD		?		; store number of composites desired by user here
currentComp		DWORD 		4 		; current composite number, beginning with 4
testVal 		DWORD 		? 		; variable used to test if number if composite
testMax			DWORD		?		; square root of test number
displayCount	DWORD 		0 		; count number of component numbers displayed
arraySize 		DWORD  		2 		; current index of array
primeArray		DWORD 		2, 3, 500 DUP(?) 	; array to hold primes, initialized with first 2 primes 
 
.code

main PROC
	
	call introduction
	call getUserData
	call showComposites
	call farewell

	exit	; exit to operating system
main ENDP

;--------------------------------------------------------
; introduction
; Displays programmers name, program title, and gives
; 	instructions to user 
; Receives: myTitle, myName, EC_1, EC_2, EC_3, intro are globals
; Returns: nothing
; Preconditions: initialize edx
; Registers Changed: edx 
;--------------------------------------------------------
introduction 	PROC
	call 	ClrScr
	mov 	eax, white + (blue * 16)
	call 	setTextColor

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
	; program introduction for user
	mov 	edx, OFFSET intro
	call 	WriteString
	call 	CrLf
	
	ret
introduction 	ENDP

;--------------------------------------------------------
; getUserData
; Prompt user for integer in [1, 400].  Verify if within 
; 	range and loop until valid input received
; Receives: prompt1, prompt2, UPPER_LIMIT, userInt are globals
; Returns: userInt assigned a value within range
; Preconditions:
; Registers Changed: eax, edx
;--------------------------------------------------------
getUserData 	PROC
	getUserNum:
		mov 	edx, OFFSET prompt1
		call 	WriteString
		mov 	eax, UPPER_LIMIT
		call 	WriteDec
		mov 	edx, OFFSET prompt2
		call 	WriteString
		call 	CrLf
	
	validate:
		; check if user input is within range
		call 	ReadInt
		mov 	userInt, eax
		cmp 	eax, UPPER_LIMIT
		ja 		errorDisplay
		cmp 	eax, 1
		jb 		errorDisplay
		jmp 	backToMain

	errorDisplay:
	; display error if desired number of composites is out of range
	mov 	edx, OFFSET errorMsg
	call 	WriteString
	call 	CrLf
	jmp		getUserNum

	backToMain:
	ret
getUserData 	ENDP

;--------------------------------------------------------
; showComposites
; Calculates and displays all composites up to and 
; including the nth composite number using isComposite.
; Receives: userInt is global variable
; Returns: nothing
; Preconditions:
; Registers Changed: eax, ebx, ecx, edx
;--------------------------------------------------------
showComposites 	PROC	
	
	; initialize ECX with userInt
	mov 	ecx, userInt
	; call isComposite sub-procedure to calculate composites
	checkLoop:
		call 	isComposite

		lineCheck:	
		; check number of composites on current line.  if 10 go to next line
		mov 	eax, displayCount
		mov 	ebx, 10
		cdq
		div 	ebx
		cmp 	edx, 0
		jne 	displayComp
		call 	CrLf
		jmp 	displayComp

		newPage: 
		; display 200 numbers per page.  wait for user input to display next page
		call 	WaitMsg
		call 	ClrScr
		mov 	eax, white + (blue * 16) 		; set color again
		call 	setTextColor

		displayComp:
		; display composite number
		mov 	eax, currentComp
		call 	WriteDec
		mov 	edx, OFFSET spacing
		call 	WriteString
		inc 	displayCount
		inc 	currentComp
		; check if page is full (200 numbers per page)
		mov 	eax, displayCount
		mov 	ebx, 300
		cdq
		div 	ebx
		cmp 	edx, 0
		je 		newPage
		loop 	checkLoop

	ret
showComposites 	ENDP

;--------------------------------------------------------
; isComposite
; A sub-procedure to check for composite numbers. 
; 	Divides only by prime numbers smaller than the number 
; 	being tested.  
; Receives: currentComp, arraySize, primeArray are globals
; Returns: nothing
; Preconditions: userInt in range, displayCount = 0
; Registers Changed: eax, ebx, ecx, edx, esi 
;--------------------------------------------------------
isComposite 	PROC USES esi ecx 

outerLoop:
	mov 	ecx, arraySize
	mov 	esi, OFFSET primeArray 	; address of the array 

	innerLoop: 
		mov 	eax, currentComp
		mov 	ebx, [esi]
		cdq
		div 	ebx
		cmp 	edx, 0
		je 		printComposite
		; increment test number
		add 	esi, TYPE DWORD 
		loop 	innerLoop
	
	addPrime: 
		; add prime to array
		mov 	eax, currentComp
		mov 	[esi], eax
		inc 	arraySize
		inc 	currentComp
		jmp  	outerLoop	
	
printComposite:
	; return to showComposites
	ret 

isComposite 	ENDP

;--------------------------------------------------------
; showMore
; Prints more composite numbers by first increasing userInt
; and then calling showComposites 
; Receives: userInt as global variable
; Returns: nothing
; Preconditions:
; Registers Changed: 
;--------------------------------------------------------
showMore 	PROC
	
	; ask if user would like to see more numbers, if user enters '1' program will exit, otherwise continue
	mov		eax, 0
	mov 	edx, OFFSET exitPrompt	
	call 	WriteString
	call 	ReadInt
	cmp 	eax, 1
	je 		quitt
	; increase userInt to display more composites
	mov 	eax, 3000
	mov 	userInt, eax
	call 	showComposites

	quitt:
	ret
showMore 	ENDP
;--------------------------------------------------------
; farewell
; Says goodbye 
; Receives: goodBye is global variable
; Returns: nothing
; Preconditions:
; Registers Changed: edx
;--------------------------------------------------------
farewell 	PROC
	call 	CrLf
	call 	showMore
	mov 	edx, OFFSET goodBye
	call 	WriteString
	call 	CrLf

	ret
farewell 	ENDP

END main
