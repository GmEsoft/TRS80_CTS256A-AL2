;CTS256_LINK.ASM

;------------------------------------------------------------------------------
;	L I N K   B E G I N	; OS Link begin
;------------------------------------------------------------------------------

;-----	Protected stack driver SVC call
;	Use the low memory stack to invoke the SVC.
;	The SVC switches out the banked memory while
;	it runs, and restores the banked memory on return.
	IF	LSDOS6		; LS-DOS 6 code
DRVSVC:
	IF	DRIVER		; if LS-DOS driver mode
	  LD	(SVCSP),SP	; save local stack pointer
	  LD	SP,(SAVSP)	; restore low-core memory stack ptr
	ENDIF			; end if LS-DOS driver mode

	RST	28H		; $SVC
	DI			; re-disable interrupts

	IF	DRIVER		; if LS-DOS driver mode
	  LD	SP,$-$		; restore local stack ptr
SVCSP	  EQU	$-2
	ENDIF			; end if LS-DOS driver mode

	RET			; done
	ENDIF			; end LS-DOS 6 code

;-----	Display char in A
DDISA:
	IF	LSDOS6		; LS-DOS 6 code
	  PUSH	BC
	  LD	C,A		; char to C
	  LD	A,@DSP
	  CALL	DRVSVC		; invoke @DSP
	  POP	BC
	ENDIF			; end LS-DOS 6 code

	IF	CPM		; CP/M code
;	  $BREAK
	  PUSH	HL
	  PUSH	DE
	  PUSH	BC
	  LD	E,A		; char to display
	  LD	C,02H		; display char BDOS func
	  PUSH	AF
	  CALL	BDOS
	  POP	AF
	  CP	CR		; CR ?
	  LD	E,LF
	  LD	C,02H
	  CALL	Z,BDOS		; if yes, append LF
	  POP	BC
	  POP	DE
	  POP	HL
	ENDIF			; end CP/M code
	RET

;-----	Send char in A to print device
DPRTA:
	IF	LSDOS6		; LS-DOS 6 code
	  PUSH	BC
	  LD	C,A		; char to C
	  LD	A,@PRT
	  CALL	DRVSVC		; invoke @DSP
	  POP	BC
	ENDIF			; end LS-DOS 6 code

	IF	CPM		; CP/M code
;	  $BREAK
	  PUSH	HL
	  PUSH	DE
	  PUSH	BC
	  LD	E,A		; char to display
	  LD	C,05H		; send to printer via BDOS
	  PUSH	AF
	  CALL	BDOS
	  POP	AF
	  CP	CR		; CR ?
	  LD	E,LF
	  LD	C,02H
	  CALL	Z,BDOS		; if yes, append LF
	  POP	BC
	  POP	DE
	  POP	HL
	ENDIF			; end CP/M code
	RET

;-----	Display message @HL (end with 0, ETX or CR)
DMSG:	LD	A,(HL)		; fetch char
	INC	HL		;
	OR	A		; NUL ?
	RET	Z		; ret if yes
	CP	3		; ETX ?
	RET	Z		; ret if yes
	PUSH	AF		; save char
	CALL	DDISA		; display it
	POP	AF		; rest char
	CP	0DH		; CR ?
	JR	NZ,DMSG		; loop if not
	RET			; done

;-----	Put char in speech buffer
PUT_CHAR:	; put char (A) into the speech buffer
	LD	C,A
	LD	A,(MODE)
	OR	A
	LD	A,C
	JR	Z,PUTCTS
	$BREAK
	LD	HL,ENCOBUF
ENCOPOS	EQU	$-2
	LD	A,L
	SUB	LOW ENCOBUF
	LD	D,A
	LD	E,3
	LD	A,C
	CP	'0'
	JR	C,PUTCHX
	CP	'9'+1
	JR	C,PUTCH1
	DEC	E
	AND	5FH
	CP	'Z'+1
	JR	NC,PUTCHX
	CP	'A'
	JR	C,PUTCHX

PUTCH1	LD	C,A
	LD	A,D
	CP	E
	JR	C,PUTCHOK
	CP	3
	JR	C,PUTCHX	;discard
	LD	HL,ENCOBUF
	LD	(ENCOPOS),HL

PUTCHOK	LD	(HL),C
	INC	HL
	LD	(HL),0
	LD	(ENCOPOS),HL
	LD	A,D
	CP	1
	RET	C
	LD	HL,ENCOBUF
	CALL	ENCOTOK
	RET	C
	OR	40H
	CALL	PUTSP0

PUTCHX	LD	HL,ENCOBUF
	LD	(ENCOPOS),HL
	RET


PUTCTS	CALL	SENDCTS		; Send char to CTS256 module
	LD	HL,ECHO		; ECHO mode active ?
	INC	(HL)
	DEC	(HL)
	JP	NZ,DDISA	; echo char if yes
	RET			; done


PUTSP0	LD	C,A
	LD	A,(DEBUG)
	OR	A
	LD	A,C

	PUSH	AF
	CALL	NZ,DECOTOK
	POP	AF

	OR	40H		;avoid ctrl-chrs in the output stream

	IF	EXEC
	  CALL	DPRTA		;Send to *PR
	ENDIF

	IF	DRIVER
	  LD	C,A
	  CALL	XSP0256		; Send to SP0256A-AL2
	ENDIF
	RET			; done

;-----	Flush and play the buffer
PLAY_BUFFER:	; play buffer
	LD	A,0DH		; CR to flush input
	CALL	SENDCTS		; Send char to CTS-256 module
	RET


CMDLINE_ADDR:	; address of next character to read from command line
	DW	CMDLINE
MODE:	; current mode: 0x00=english, 0xff=phoneme
	DB	00H
DEBUG:	; debug mode
	DB	00H
ECHO:	; echo mode
	DB	00H
DBGRUL:	; debug rules mode
	DB	00H
SOURCE:	; source: 0x00 = command line, 0xff = file
	DB	00H

BLOCKPOS:	; position inside file block (0..127)

	DB	80H

	DS	80H		; External stack area

	; end of stack, begin of garbage
STACK	EQU	$		; External stack origin

;------------------------------------------------------------------------------
;	L I N K   E N D		; OS Link end
;------------------------------------------------------------------------------

	END
