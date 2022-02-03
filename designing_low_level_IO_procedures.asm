TITLE Designing low-level I/O procedures     (program6_powdrild.asm)

; Author: David Powdrill
; Last Modified: 6/7/2020
; OSU email address: powdrild@oregonstate.edu
; Course number/section: 271-400
; Project Number: 6                 Due Date: 6/7/2020
; Description: Program that asks the user for 10 signed integers. Then validates they fit in a 32-bit register, 
;				converts them from a string to an integer to be stored, then converts them from integer to string 
;				for each integer to be displayed. Finally it displays the sum and rounded average of the 10 integers. entered. 

INCLUDE Irvine32.inc

ARRAYSIZE = 10
POSITIVE = 43
NEGATIVE = 45
ZERO = 48
NINE = 57


;----------------------------------------------------------
mgetString	MACRO numarray
;
; Gets string character from user
;
; Preconditions: Must be passed an array
;
; Postconditions: changes registers edx, ecx, eax
;
; Receives: An array = for user input
;
; Returns: None 
;----------------------------------------------------------
	push			edi
	
	;reads string character
	mov				edx, OFFSET inputArray
	mov				ecx, SIZEOF inputArray
	call			ReadString
	pop				edi

ENDM

;----------------------------------------------------------
mdisplayString	MACRO	string
;
; Displays a string to the program window.
;
; Preconditions: Must be passed a string
;
; Postconditions: changes register edx
;
; Receives: string = string to be displayed
;
; Returns: None 
;----------------------------------------------------------
	push	edx

	;displays string
	mov		edx, string
	call	WriteString

	pop		edx

ENDM

.data
inputArray		SDWORD	ARRAYSIZE DUP(0)
stringArray		SDWORD	ARRAYSIZE DUP(?)
intList			SDWORD	ARRAYSIZE DUP(?)
negcounter		DWORD	?
intro_1			BYTE	"PROGRAMMING ASSIGNMENT 6: Designing Low-Level I/O Procedures ", 0
intro_2			BYTE	"Programmed by: David Powdrill ", 0
instruct_1		BYTE	"Please provide 10 signed decimal integers. ", 0
instruct_2		BYTE	"Each number needs to be small enough to fit inside a 32 bit register. ", 0
instruct_3		BYTE	"After you have finished inputting the raw numbers I will display a list ", 0
instruct_4		BYTE	"of the integers, their sum, and their average value. ", 0
prompt			BYTE	"Please enter a signed number: ", 0
error			BYTE	"ERROR: You did not enter a signed number or your number was too big. ", 0
numdisplay		BYTE	"You entered the following numbers: ", 0
sumdisplay		BYTE	"The sum of these numbers is: ", 0
avgdisplay		BYTE	"The round average is: ", 0
minus			BYTE	"-", 0
goodBye			BYTE	"Thanks for playing! ", 0

.code
main PROC
	;introduction
	push	OFFSET	intro_1			;28
	push	OFFSET	intro_2			;24
	push	OFFSET	instruct_1		;20
	push	OFFSET	instruct_2		;16
	push	OFFSET	instruct_3		;12
	push	OFFSET	instruct_4		;8
	call	introduction

	;readVal
	push	ZERO					;40
	push	NINE					;36
	push	POSITIVE				;32
	push	NEGATIVE				;28
	push	negcounter				;24
	push	OFFSET	error			;20	
	push	OFFSET	prompt			;16
	push	OFFSET	intList			;12
	push	OFFSET	inputArray		;8
	call	readVal

	;writeVal
	push	OFFSET	minus			;24	
	push	OFFSET	numdisplay		;20
	push	ARRAYSIZE				;16
	push	OFFSET stringArray		;12
	push	OFFSET intList				;8
	call	writeVal

	;displayMath
	push	OFFSET	minus			;24
	push	OFFSET	sumdisplay		;20
	push	OFFSET	avgdisplay		;16
	push	OFFSET	intList			;12	
	push	ARRAYSIZE				;8
	call	displayMath

	;goodBye
	push	OFFSET	goodBye			;8
	call	farewell

	exit	; exit to operating system
main ENDP

;----------------------------------------------------------
introduction	PROC
;
; Displays title and author.
;
; Preconditions: None
;
; Postconditions: None
;
; Receives: [ebp+28] = intro_1
;			[ebp+24] = intro_2
;			[ebp+20] = instruct_1
;			[ebp+16] = instruct_2
;			[ebp+12] = instruct_3
;			[ebp+8]  = instruct_4
; Returns: None 
;----------------------------------------------------------
	push	ebp
	mov		ebp, esp
	
	;displays title and author
	mdisplayString	[ebp+28]
	call	CrLf
	mdisplayString	[ebp+24]
	call	CrLf
	call	CrLf

	;displays instructions
	mdisplayString	[ebp+20]
	call	CrLf
	mdisplayString	[ebp+16]
	call	CrLf
	mdisplayString	[ebp+12]
	call	CrLf
	mdisplayString	[ebp+8]
	call	CrLf
	call	CrLf

	pop		ebp
	ret	24

introduction	ENDP

;----------------------------------------------------------
readVal	PROC
;
; Gets the user's string of digits and converts to numeric
; value and validates it is in correct range and signed
;
; Preconditions: None
;
; Postconditions: changes registers eax, ebx, ecx, edx, esi, edi
;
; Receives: [ebp+40] = ZERO
;			[ebp+36] = NINE
;			[ebp+32] = POSITIVE
;			[ebp+28] = NEGATIVE
;			[ebp+24] = negative counter
;			[ebp+20] = error
;			[ebp+16] = prompt
;			[ebp+12] = intList
;			[ebp+8]  = inputArray
;
; Returns: intList (edi) = array of 10 integers 
;----------------------------------------------------------
	push	ebp
	mov		ebp, esp

	;set up 
	mov		edi, [ebp+12]			;intList
	mov		ecx, 10					;counter
	push	ecx
	mov		ebx, 0

start:
	;displays prompt
	mdisplayString	[ebp+16]

	;gets value from user
	mgetString	[ebp+8]
	mov		esi, edx				;inputArray
	mov		ecx, eax				;number of digits
	mov		ebx, ecx
	dec		ebx
	mov		edx, 0
	
eachdigit:
	lodsb

	;checks to see if finished converting 
	cmp		ax, 0
	je		done

	;checks if digit is a negative or positive sign
	cmp		ax, [ebp+28]
	je		negcount
	cmp		ax, [ebp+32]
	je		posnextdigit
	push	ebx

	;checks to see if digit is a valid digit (0-9)
	cmp		ax, [ebp+40]
	jb		errormsg
	cmp		ax, [ebp+36]
	ja		errormsg

	;convert string to integer
	sub		ax, 48						;convert to from string to integer
	push	edx							;integer total so far

	;checks if this is the last digit
	cmp		ebx, 0						
	je		validatedDigit
	mov		ecx, ebx					;prepare counter for 10's multiplier

mul10:
	;multiples digit by 10
	mov		ebx, 10
	imul	ebx
	loop	mul10		
	jmp		validatedDigit

negcount:
	dec		ebx
	push	ebx							;10's multiplier counter

	;stores a 1 in negcounter
	mov		ebx, [ebp+24]
	mov		ebx, 1
	mov		[ebp+24], ebx

	;prepare for next digit
	pop		ebx							;10's multiplier counter
	xor		eax, eax
	jmp		eachdigit

posnextdigit:
	;prepare for next digit
	dec		ebx							;10's multiplier counter
	xor		eax, eax
	jmp		eachdigit

validatedDigit:
	;adds current value to total value
	pop		edx							;total value
	add		edx, eax		
	jo		ofcheck

moveon:
	;prepare for next digit
	pop		ebx							;10's multiplier counter
	dec		ebx
	cld
	xor		eax, eax
	jmp		eachdigit

ofcheck:
	;checks if current value is negative
	mov		ebx, [ebp+24]
	cmp		ebx, 1
	jne		errormsg

	;checks for overflow
	neg		edx
	jno		moveon

errormsg:
	;displays error message to user
	mdisplayString	[ebp+20]
	call	CrLf

	;prepares to ask user input again
	pop		ebx							;10's multiplier counter
	pop		ecx							;total integer counter
	push	ecx
	jmp		start

done:
	;checks if value is neagtive
	mov		ebx, [ebp+24]				
	cmp		ebx, 1
	jne		addtolist

	;negates value
	neg		edx
	xor		ebx, ebx					;clears negative counter
	mov		[ebp+24], ebx

addtolist:
	;decreases integer counter
	pop		ecx
	dec		ecx
	push	ecx

	;stores converted integer into array
	mov		[edi], edx
	add		edi, 4						;moves to next spot in array
	
	;checks if user as inputted all 10 integers
	cmp		ecx, 0
	jne		start

	;clears up registers
	pop		ecx
	pop		ebp
	ret	36

readVal		ENDP

;----------------------------------------------------------
writeVal	PROC
;
; Converts all integers to a string and displays them using
; the displayString MACRO
;
; Preconditions: All 10 values have been collected from user. 
;					stringArray and intList are both SDWORD arrays. 
;
; Postconditions: changes registers eax, ebx, ecx, edx, esi, edi 
;
; Receives: [ebp+24] = negative sign
;			[ebp+20] = numdisplays
;			[ebp+16] = ARRAYSIZE
;			[ebp+12] - stringArray
;			[ebp+8]	 = intList
;
; Returns: string (edi) = placeholder array of converted integers to strings
;----------------------------------------------------------
	push	ebp
	mov		ebp, esp

	;displays numdisplay text
	call	CrLf
	mdisplayString	[ebp+20]
	call	CrLf

	;set up 
	mov		esi, [ebp+8]				;intList
	mov		edi, [ebp+12]				;stringArray
	mov		ecx, [ebp+16]				;ARRAYSIZE (10)

new:
	push	ecx
	push	0

	;check if first value in list is negative
	mov		eax, [esi]
	test	eax, eax
	jns		divide

	;if negative
	neg		eax							;negates value
	mov		ecx, 100

divide:
	;divides by 10
	xor		edx, edx
	mov		ebx, 10
	div		ebx							;divide eax by 10
	
	;convert to string
	add		edx, 48
	push	edx							;saves remainder converted to string
	cmp		eax, 0						;checks to see if we are done converting
	jne		divide


storestring:
	;store string
	pop		[edi]						;remainder from division converted to string
	mov		eax, [edi]
	inc		edi							;moves over 1 for next digit
	cmp		eax, 0						;checks to see if we have made it to the end of remainder digits
	jne		storestring

	;checks to see if we negative sign is needed to be displayed
	mov		edi,	[ebp+12]			; string array
	cmp		ecx, 100
	jl		displayit

	;displays negative sign
	mdisplayString	[ebp+24]

displayit:
	;displays value converted to string
	mdisplayString	edi

	;checks if comma is needed to be displayed
	mov		ecx, 0
	pop		ecx
	cmp		ecx, 1
	je		spaceit						;jumps if we are on last value (doesn't need comma)
	mov		al, ','
	call	WriteChar					;displays ','
spaceit:
	;displays space character
	mov		al, ' '						
	call	WriteChar					;displays ' '
	
	;moves to next in list 
	add		esi, 4

	;checks if finished converting all integers to strings
	dec		ecx
	cmp		ecx, 0
	jne		new
	call	CrLf
	pop		ebp
	ret		20

writeVal	ENDP

;----------------------------------------------------------
displayMath	PROC
;
; Calculates and displays the sum and average of the 10 integers inputted. 
;
; Preconditions: list array must be DWORD. Must be 10 integers in the array
;
; Postconditions: changes registers eax, ebx, ecx, edx, esi, edi 
;
; Receives: [ebp+24] = negative sign
;			[ebp+20] = sumdisplay		
;			[ebp+16] = avgdisplay		
;			[ebp+12] = intList			
;			[ebp+8]  = ARRAYSIZE				
;
; Returns: None 
;----------------------------------------------------------
	push	ebp
	mov		ebp, esp

	;set up
	mov		esi, [ebp+12]				;intList
	mov		ecx, 10						;counter
	mov		ebx, 0

addloop:
	mov		eax, [esi]					;moves value in intList to eax

addthem:	
	;adds eax (current value) to total and loops to next value
	add		ebx, eax
	add		esi, 4
	loop	addloop
	jmp		addtext

addtext:
	;displays sumdisplay text
	mdisplayString	[ebp+20]

	;checks if negative sign is needed
	mov		eax, ebx
	test	eax, eax
	js		negsign

	;displays sum
	call	WriteDec
	jmp		avg

negsign:
	push	eax							;sum

	;displays negtive sign and value
	mdisplayString [ebp+24]				;negative sign	
	pop		eax
	neg		eax					
	call	WriteDec					;displays value
	mov		ecx, 1						;stores 1 for negative average

avg:	
	push	eax
	call	CrLf

	;displays avgdisplay text
	mdisplayString	[ebp+16]

	;calculates average
	pop		eax
	mov		ebx, [ebp+8]				;10
	cdq
	idiv	ebx							;divides sum by 10

negcheck:
	;checks to see if negative sign is needed for average
	cmp		ecx, 1
	jne		display	
	cmp		eax, 0
	je		display

	;displays negative sign
	push	eax
	mdisplayString [ebp+24]				;minus sign
	pop		eax

display:
	call	WriteDec					;displays average
		

	pop		ebp
	ret	20


displayMath		ENDP

;---------------------------------------------------------
farewell		PROC
;
; Displays a farewell message to the user. 
;
; Preconditions: All other procedures have been executed
;
; Postconditions: changes register edx
;
; Receives: [ebp+8] = goodBye text
;
; Returns: None
;---------------------------------------------------------
	push	ebp
	mov		ebp, esp

	;prints farwell message to user
	call	CrLf
	call	CrLf
	mdisplayString	[ebp+8]

	pop		ebp
	ret		4

farewell		ENDP
END main
