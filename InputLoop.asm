; Library Test #1: Integer I/O (InputLoop.asm)
; Tests the Clrscr, Crlf, DumpMem, ReadInt, SetTextColor,
; WaitMsg, WriteBin, WriteHex, and WriteString procedures.
    
INCLUDE Irvine32.inc

.data
COUNT = 4
BlueTextOnGray = blue + (lightGray * 16)
DefaultColor = lightGray + (black * 16)

arrayD 		SDWORD 	12345678h, 1A4B2000h, 343h, 7AB9h
prompt 		BYTE 	"Enter a 32-bit signed integer: ", 0

.code
main PROC 
	mov 	eax, BlueTextOnGray
	call 	SetTextColor
	; clear the screen so we can set background color 
	call 	Clrscr
	; assign offset of arrayD to ESI, marking beginning of range to display
	mov 	esi, OFFSET arrayD
	; assign EBX a value 
	mov 	ebx, TYPE arrayD		; doubleword = 4 bytes
	; set ECX to number of units that will be displayed
	mov 	ecx, LENGTHOF arrayD 	; number of units in arrayD
	call 	DumpMem 				; display memory

; Next, the user will be asked to input a sequence of four signed 
; integers. After each integer is entered, it is redisplayed in 
; signed decimal, hexadecimal, and binary.

	; output a blank line, then initialize ECX to COUNT
	call 	Crlf
	mov 	ecx, COUNT
	; display string to ask user to enter integer 
L1: 
	mov 	edx, OFFSET prompt
	call 	WriteString
	call 	ReadInt				; input integer into EAX
	call	Crlf				; newline

	call 	WriteInt			; display in signed decimal
	call 	Crlf

	call 	WriteHex			; display in hexadecimal
	call 	Crlf
	call 	WriteBin 			; display in binary
	call	Crlf
	call 	Crlf

	Loop 	L1					; repeat the Loop

; Return the console window to default colors
	call 	WaitMsg				; "Press any key..."
	mov 	eax, DefaultColor
	call 	SetTextColor
	call 	Clrscr

	exit
main ENDP
END main

