;CTS256_WRAPPER.ASM

;------------------------------------------------------------------------------
;	C T S 2 5 6   W R A P P E R   B E G I N
;------------------------------------------------------------------------------

EXTSP	DS	2		; external stack pointer save
CTSSP	DS	2		; CTS256-mode stack pointer save

OLD	EQU	0
NEW	EQU	1

;-----	Boot CTS-256 module
BOOTCTS	;$BREAK
	PUSH	AF		; Save registers
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	IX
	PUSH	IY

	IF	0		; debugging
	LD	HL,P0		; Clear buffers
	LD	DE,P0+1		;
	LD	(HL),0		;
	LD	BC,0200H
	LDIR
	LD	(HL),0FFH
	LD	BC,1000H
	LDIR
	LD	(HL),'S'
	LD	BC,0100H
	LDIR
	LD	(HL),'Z'
	LD	BC,0040H
	LDIR
	LD	(HL),0
	ENDIF			; end debugging

	LD	IX,R0		;Indexed pointer to TMS-7000 registers
	LD	IY,P0		;Indexed pointer to TMS-7000 I/O ports
	LD	(IY+4),10H	;APORT: select ext RAM
	LD	(EXTSP),SP	;Save external SP
	DI			;Disable interrupts while on internak stack
	LD	SP,CTSSTK	;Switch to CTS256A-AL2 module stack
	JR	CTS256		;Boot the CTS256A-AL2 module

;-----	Yield from CTS-256 module
YLDCTS	;$BREAK
YLDL0	BIT	0,(IY+0)	;INT1 enabled?
	JR	Z,YLDJ1		;skip if not (no more char to send)
	CALL	INT1		;invoke INT1 to output char

	LD	A,(R27)		;Allophone

	CALL	PUTSP0		;Send to SP0256A-AL2

	JR	YLDL0		;Next char

YLDJ1	LD	(CTSSP),SP	;Switch to the user stack
	LD	SP,(EXTSP)	;
	POP	IY		;Restore registers
	POP	IX
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET			;Return to the user code

;-----	Send char in A to CTS-256 module
SENDCTS	PUSH	AF		;Save registers
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	IX
	PUSH	IY
	LD	(EXTSP),SP	;Save external stack pointer
	DI			;Disable interrupts while on internak stack
	LD	SP,(CTSSP)	;Switch to CTS256A-AL2 module stack
	LD	IX,R0		;Registers Rnn index
	LD	IY,P0		;Ports Rnn index
	OR	A		;Char to send?
	RET	Z		;return if NUL
	LD	(PARLINP),A	;Send to parallel input
	BIT	4,(IY+0)	;INT3 enabled?
	JP	NZ,INT3		;call INT3 if yes
	RET			;Return to CTS256A-AL2 module code

;------------------------------------------------------------------------------
;	C T S 2 5 6   W R A P P E R   E N D
;------------------------------------------------------------------------------

	END
