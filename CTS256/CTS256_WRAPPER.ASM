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
	JP	CTS256		;Boot the CTS256A-AL2 module

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
	CP	'a'		;lower case ?
	JR	C,SENDCT1	;
	CP	'z'+1		;
	JR	NC,SENDCT1	;
	AND	5FH		;if yes switch to upper case
SENDCT1	LD	(PARLINP),A	;Send to parallel input
	BIT	4,(IY+0)	;INT3 enabled?
	JP	NZ,INT3		;call INT3 if yes
	RET			;Return to CTS256A-AL2 module code

;-----	Debug CTS256 rules
DBUGCTS	LD	A,(DBGRUL)
	OR	A
	RET	Z
	LD	HL,(R21)
	LD	A,'{'
	CALL	DDISA

	;chars preceding 1st [ = prefix
DBUGCL1	LD	A,(HL)
	INC	HL
	BIT	6,A
	JR	NZ,DBUGCJ1	;'['
	CALL	DBGCPAT
	LD	A,C
	CALL	DDISA
	JR	DBUGCL1

	;chars inside 1st [ ]
DBUGCL2	LD	A,(HL)
	INC	HL
DBUGCJ1	LD	B,A
	BIT	6,A
	JR	Z,DBUGCJ9
	LD	A,'['
	CALL	DDISA

	LD	A,'_'		;Initial letter
DBGCINI	EQU	$-1

	CP	'A'
	JR	C,DBUGCJ9
	CP	'Z'+1
	JR	NC,DBUGCJ9

	CALL	DDISA

DBUGCJ9	LD	A,B
	AND	3FH
	ADD	A,20H
	LD	C,A
	CP	5FH
	JR	Z,DBUGCJ2
	LD	A,C
	CALL	DDISA
DBUGCJ2	LD	A,B
	BIT	7,A
	JR	Z,DBUGCL2
	LD	A,']'
	CALL	DDISA

	;chars preceding 2nd [ = suffix
DBUGCL3	LD	A,(HL)
	INC	HL
	BIT	6,A
	JR	NZ,DBUGCJ3	;'['
	CALL	DBGCPAT
	LD	A,C
	CALL	DDISA
	JR	DBUGCL3

	;allophones
DBUGCL4	LD	A,(HL)
	INC	HL
DBUGCJ3	LD	B,A
	BIT	6,A
	LD	A,'='
	CALL	NZ,DDISA
	LD	A,B
	CP	0FFH		;No allophone
	JR	Z,DBUGCJ4
	BIT	6,A
	LD	A,' '
	CALL	Z,DDISA
	LD	A,B
	AND	3FH
	PUSH	HL
	PUSH	BC
	CALL	DECOTOK
	POP	BC
	POP	HL
DBUGCJ4	LD	A,B
	BIT	7,A
	JR	Z,DBUGCL4
	LD	A,'}'
	CALL	DDISA
	LD	A,' '
	JP	DDISA

DBGCPAT	CP	1FH
	LD	C,'$'
	RET	Z		;'$'
	CP	15H
	JR	NC,DBGCPA2	;letters
	SUB	09H
	LD	C,'!'
	RET	C		;invalid
	PUSH	IX
	LD	IX,DBGCPTB
	LD	(DBGCPIX),A
	LD	C,(IX+0)
DBGCPIX	EQU	$-1
	POP	IX
	RET
DBGCPA2	ADD	A,20H		;letters
	LD	C,A
	RET

DBGCPTB	DB	"#.%&@^+:*><?"


;------------------------------------------------------------------------------
;	C T S 2 5 6   W R A P P E R   E N D
;------------------------------------------------------------------------------

	END
