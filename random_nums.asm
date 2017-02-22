TITLE Random Numbers    (random_nums.asm)

; Author: Joseph DePrey
; Description: Generates and displays a user-defined number of random integers in a
; 	predefined range. Random integers will be stored in an array and then displayed 10 per line.
; 	Integers will then be sorted in descending order.  Median value(rounded to nearest integer)
; 	will be calculated and, finally, the sorted list will be displayed.
; **EC: Display numbers ordered by column instead of row.
; **EC: Use a recursive sorting algorithm
; **EC: Other cool stuff

INCLUDE Irvine32.inc

MIN = 10				; minimum number of random integers to be displayed
MAX = 200				; maximum number of random integers to be displayed
LO = 100				; lowest value of random integers to be generated
HI = 999				; highest value of random integers to be generated

temp_local 		EQU DWORD PTR [ebp-4]

; macro for push sequence used in procedures
mPush 			MACRO
				push 	ebp
				mov 	ebp, esp
				pushad
				ENDM
; macro for pop sequence used in procedures. take numbers of bytes to ret as parameter
mPop			MACRO 	bytes
				popad
				pop 	ebp
				ret 	bytes
				ENDM

.data

introduction	BYTE 		"=-=-=-=-=-=-=-=-=-=-=Random Number Generator=-=-=-=-=-=-=-=-=-=-=", 0Dh, 0Ah
				BYTE 		"=-=-=-=-=-=-=-=-=-=-=-=-by Joseph DePrey=-=-=-=-=-=-=-=-=-=-=-=-=", 0Dh, 0Ah
				BYTE		"**EC1: Display numbers ordered by column instead of row", 0Dh, 0Ah
				BYTE 		"**EC2: Sorted with recursive sorting algorithm(Quicksort)", 0Dh, 0Ah, 0Dh, 0Ah
				BYTE		"This program generates random numbers in the range of [100 .. 999],", 0Dh, 0Ah
	 			BYTE 		"displays the original list, sorts the list, and calculates the", 0Dh, 0Ah
	 			BYTE 		"median value. Finally, it displays the list sorted in descending order.", 0Dh, 0Ah, 0
prompt			BYTE		"How many numbers should be generated? [10 .. 200]: ", 0
errorMsg		BYTE		"Invalid input. Please enter an integer within range.", 0Dh, 0Ah, 0
unsortedMsg 	BYTE 		"The unsorted random numbers:", 0Dh, 0Ah, 0
medianMsg 		BYTE 		"The median is ", 0
sortedMsg 		BYTE 		"The sorted random numbers:", 0Dh, 0Ah, 0
goodbyeMsg 		BYTE 		"Until next time ", 0Dh, 0Ah, 0
spaces  		BYTE 		"	", 0

request 		DWORD		?			; number of random numbers desired by user
array			DWORD 		MAX DUP(?)  ; array to hold random numbers

.code

main PROC
; Program Intro
	push 	OFFSET introduction
	call 	intro
; Get User Data (number of randoms)
	push 	OFFSET errorMsg 			; pass by reference
	push 	OFFSET prompt 				; pass by reference
	push 	OFFSET request 				; pass by reference
	call 	getData
; Generate Random Numbers and Fill Array
	call 	Randomize  					; seed random number generator
	push 	OFFSET array 				; pass by reference
	push 	request						; pass by value
	call 	fillArr
; Display Array(as generated, unsorted)
	push 	OFFSET spaces 				; pass by value
	push 	OFFSET array 				; pass by reference
	push 	request						; pass by value
	push 	OFFSET unsortedMsg			; pass by reference
	call 	displayList
; Sort Array
	push 	OFFSET array 				; pass by reference
	push 	request						; pass by value
	call 	sortList
; Display Median
	push 	OFFSET array 				; pass by reference
	push 	request 					; pass by value
	push 	OFFSET medianMsg 			; pass by reference
	call 	displayMedian				; display median after array is sorted
; Display Array(now sorted)
	push 	OFFSET spaces 				; pass by value
	push 	OFFSET array 				; pass by reference
	push 	request  					; pass by value
	push 	OFFSET sortedMsg 			; pass by reference
	call 	displayList
; Say Goodbye
	push 	OFFSET goodbyeMsg			; pass by reference
	call 	farewell

	exit	; exit to operating system
main ENDP

;--------------------------------------------------------
intro 	PROC
; Displays programmers name, program title, and gives
; 	instructions to user
; Receives: introduction:[ebp+8]
; Returns: nothing
; Preconditions: initialize edx
; Registers Changed: edx
;--------------------------------------------------------
	mPush
	mov 	edx, [ebp+8]
	call 	WriteString
	mPop 	4
intro 	ENDP

;--------------------------------------------------------
getData 	PROC
; Prompt user for integer in [10, 200].  Verify if within
; 	range and loop until valid input received
; Receives: request:[ebp+8], prompt:[ebp+12], errorMsg:[ebp+16]
; Returns: request assigned a value within range
; Preconditions: none
; Registers Changed: none
;--------------------------------------------------------
	mPush
	mov 	edi, [ebp+8]		; request
GetNum:
	mov 	edx, [ebp+12] 		; prompt
	call 	WriteString
	call 	ReadDec
Validate:
	cmp 	eax, MAX
	jg 		errorDisplay
	cmp 	eax, MIN
	jl 		errorDisplay
	jmp 	backToMain
errorDisplay:
	mov 	edx, [ebp+16] 		; errorMsg
	call 	WriteString
	jmp 	GetNum
backToMain:
	mov 	[edi], eax  		; move validated number into request

	mPop 	12 					; 4+4+4
getData 	ENDP

;--------------------------------------------------------
fillArr 	PROC
; Generates n random numbers where n=request. Stores the
; random numbers in array.
; Receives: request:[ebp+8], array:[ebp+12]
; Returns: array filled with n "random" numbers
; Preconditions: request is a value within range, call Randomize
; Registers Changed: none
;--------------------------------------------------------
	mPush

	mov 	ecx, [ebp+8] 		; request, use as counter
	mov 	edi, [ebp+12] 		; array
generator:
	mov 	eax, HI   			; generate range for the random numbers
	sub 	eax, LO
	inc  	eax
	call 	RandomRange
	add 	eax, LO
	mov 	[edi], eax 			; put random number in array
	add 	edi, 4 				; next location in array
	loop 	generator

	mPop 	8 					; 4+4
fillArr 	ENDP

;--------------------------------------------------------
displayList 	PROC
; Displays 10 random numbers per row, ordered by column
; Receives: unsortedMsg:[ebp+8], request:(value)[ebp+12],
; 	array:[ebp+16], spaces:[ebp+20]
; Returns: nothing
; Preconditions: request within range
; Registers Changed: none
;--------------------------------------------------------
	mPush

	mov 	edx, [ebp+8] 		; unsortedMsg
	call 	WriteString
	mov 	ecx, [ebp+12] 		; request as counter in ECX
	mov 	esi, [ebp+16] 		; array

; calculate index of element to be displayed in next column
; index depends on number of rows(#rows = request/10)
columns:
	mov 	edx, 0 				; clear dividend
	mov 	eax, ecx 			; request = dividend
	mov 	ebx, 10 			; 10 = divisor
	div 	ebx  				; eax = #rows = request/10
	mov 	ebx, TYPE DWORD
	mul 	ebx 		 		; get index
	mov 	temp_local, eax  	; save in local

	mov 	ebx, 0 				; initialize ebx as count

print:
	mov 	eax, [esi] 			; access first value of array
	call  	WriteDec			; print it
	inc  	ebx
	add 	esi, temp_local		; element for next column
	cmp 	ebx, 10 			; ensure only 10 numbers per line
	jne 	noLine

; iterate through array to fill first column of each row
; need to move esi back to front of array
rows:
	call 	CrLf 				; new line
	mov 	eax, temp_local 	;
	mul 	ebx
	sub 	esi, eax
	add 	esi, TYPE DWORD

	mov 	ebx, 0 				; reset counter
	jmp 	loopPrint

noLine:
	mov 	edx, [ebp+20] 		; add spaces between numbers
	call 	WriteString

loopPrint:
	loop 	print
	call 	CrLf

	mPop 	16 					; 4+4+4+4
displayList 	ENDP

;--------------------------------------------------------
sortList 	PROC
; Sort array in descending order using Quicksort
; Receives: request:[ebp+8], array:[ebp+12]
; Returns: sorted array
; Preconditions: non-empty array
; Registers Changed: none
;--------------------------------------------------------
	mPush

	mov 	ecx, [ebp+8] 		; request, use as counter
	mov 	esi, [ebp+12] 		; array
	shl 	ecx, 2 				; multiply by 4 for index of last element

	mov 	eax, 0 				; low index
	mov 	ebx, ecx  			; high index
	call 	QuickSort

	mPop	 8  				; 4+4
sortList 	ENDP

;--------------------------------------------------------
QuickSort 	PROC
; Uses a recursive QuickSort algorithm by Miguel Casillas
; Receives: none
; Returns: sorted array
; Preconditions: request in ecx, array in esi, low index
; 	in eax, high index in ebx
; Registers Changed:
;--------------------------------------------------------
	cmp 	eax, ebx 			; if (low >= high)
	jge  	backToSortList 		; finished sorting

	push 	eax 				; save low, use eax as i
	push 	ebx					; save high, use ebx as j
	add 	ebx, 4 				; j = high + 1

	mov 	edi, [esi+eax] 		; use low index as pivot

frontLoop:
	add 	eax, 4 				; i++

	cmp 	eax, ebx 			; if (i >= j)
	jge 	backLoop 			; exit loop

	cmp 	[esi+eax], edi 		; if (array[i] < pivot)
	jl 	 	backLoop			; exit loop

	jmp 	frontLoop 			; while(i < j && array[i] < pivot)

backLoop:
	sub 	ebx, 4 				; j--

	cmp 	[esi+ebx], edi 		; if (array[j] >= pivot)
	jge 	firstSwap			; exit loop
	jmp 	backLoop 			; while(array[j] > pivot)

firstSwap:
	cmp 	eax, ebx 			; if (i >= j)
	jge 	secondSwap 			; no swap here


	push 	[esi+eax] 			; swap array[i], array[j]
	push 	[esi+ebx]
	pop 	[esi+eax]
	pop 	[esi+ebx]
	jmp  	frontLoop 			; keep sorting

secondSwap:
	pop 	edi 				; restore high
	pop 	ecx 				; restore low

	cmp 	ecx, ebx 			; if (low == j)
	je 		noSwap				; no swap here

	push 	[esi+ecx] 			; swap array[low], array[j]
	push 	[esi+ebx]
	pop 	[esi+ecx]
	pop 	[esi+ebx]

noSwap:
	mov 	eax, ecx 			; low index
	push 	edi 				; high index
	push  	ebx 				; j

	sub 	ebx, 4 				; j-1
	call 	QuickSort

	pop 	eax 				; j
	add 	eax, 4  			; j + 1
	pop 	ebx 				; high index
	call  	QuickSort

backToSortList:
	ret 						; back up to sortList
QuickSort 	ENDP

;--------------------------------------------------------
displayMedian 	PROC
; Calcuates and displays median of sorted array
; Receives: medianMsg:[ebp+8], request:[ebp+12],
; 	array:[ebp+16]
; Returns: nothing
; Preconditions: array has been sorted
; Registers Changed:
;--------------------------------------------------------
	mPush
	mov 	esi, [ebp+16] 		; array
	mov 	eax, [ebp+12] 		; request
	mov  	edx, [ebp+8]		; medianMsg
	call 	WriteString 		; print medianMsg

	test  	eax, 1 				; check if number of array elements is even
	jz 		evenPrint  			; jump to evenReq if even
	jmp 	oddPrint 			; else jump to oddReq

evenPrint:
	shr 	eax, 1
	shl 	eax, 2 				; multiply request by 4 to get first index
	add 	esi, eax
	mov 	eax, [esi]
	add  	eax, [esi-4] 		; average numbers to get median value
	shr 	eax, 1
	call 	WriteDec
	jmp 	backToMain

oddPrint:
	shr 	eax, 1
	shl 	eax, 2 				; multiply request by 4 to get index of median in array
	add 	esi, eax
	mov 	eax, [esi] 			; get value at median index
	call 	WriteDec

backToMain:
	call 	CrLf

	mPop 	12 					; 4+4+4
displayMedian 	ENDP

;--------------------------------------------------------
farewell 	PROC
; Says goodbye
; Receives: goodbyeMsg:[ebp+8]
; Returns: nothing
; Preconditions: none
; Registers Changed: none
;--------------------------------------------------------
	mPush
	mov 	edx, [ebp+8]
	call 	WriteString
	mPop 	4
farewell 	ENDP

END main
