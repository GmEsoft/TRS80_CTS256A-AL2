;CTS256_EXEC.ASM

;------------------------------------------------------------------------------
;	E X E C   B E G I N	; LS-DOS and CP/M executor part
;------------------------------------------------------------------------------

ENTRY:
	; CP/M entry point at 0100H; LS-DOS6 entry point at 3000H
	IF	LSDOS6
	  EX	DE,HL		; Save HL = command line args ptr
	ENDIF

	LD	HL,STACK	; set local stack
	LD	SP,HL

	IF	CPM
	  LD	A,(D0080)	; Parameters length
	  CP	00H		; == 0 ?
	ENDIF
	IF	LSDOS6
	  EX	DE,HL		; Recover HL = command line args ptr
	  LD	(CMDLINE_ADDR),HL
	  LD	A,(HL)		; Parameters first byte
	  CP	0DH		; CR ?
	ENDIF

	JP	Z,SHOWHELP	; If no parameters, show help and exit
	CALL	CHECK_INPUT_SOU	; try to open specified file. On fail input comes from

	LD	HL,2020H	; Suppress the 'O-K' message on boot
	LD	(STROK),HL	;
	LD	(STROK+2),HL	;
	CALL	BOOTCTS		; Boot the CTS256A-AL2 module

READ_LOOP:
	CALL	GET_NEXT_CHAR	; get next char (ret in A)
	CP	00H
	JR	Z,END_READ
	CP	'Z'-40H		; found Ctrl-Z, end of text
	JR	Z,END_READ
	CP	'['
	JR	Z,BEGIN_PHONEME_M; found '[', begin phoneme section
	CP	']'
	JR	Z,BEGIN_ENGLISH_M; found ']', end of phoneme section
	CP	'|'
	JR	Z,SET_PARAM	; found '|', parameter
	CP	'M'-40H		; Ctrl-M / CR
	JR	Z,FOUND_NEWLINE	; found CR or LF
	CP	'J'-40H		; Ctrl-J / LF
	JR	Z,FOUND_NEWLINE	; found CR or LF
	CALL	PUT_CHAR	; put char (A) into the speech buffer
	JR	READ_LOOP

END_READ:
	CALL	PLAY_BUFFER	; play buffer
	LD	A,(SOURCE)	; source: 0x00 = command line, 0xff = file
	CP	00H
	JR	Z,END_READ_EXIT
	LD	DE,FCB
	IF	CPM
	  LD	C,10H		; Close file
	  CALL	BDOS
	ENDIF
	IF	LSDOS6
	  $SVC	@CLOSE		; Close the file
	ENDIF
END_READ_EXIT:
	LD	A,(DEBUG)	; is debug mode?
	LD	HL,(ECHO)	; or echo mode?
	OR	(HL)		;
	LD	HL,(DBGRUL)	; or rules debugging?
	OR	(HL)		;
	LD	A,0DH		; if yes, display <CR>
	CALL	Z,DDISA		;

	IF	CPM
	  JP	0000H
	ENDIF
	IF	LSDOS6
	  LD	HL,0		; no error
	  $SVC	@EXIT		; Exit program with return code
	ENDIF

FOUND_NEWLINE:			; found CR or LF
	CALL	PLAY_BUFFER	; play buffer
	JR	READ_LOOP

BEGIN_PHONEME_M:		; found '[', begin phoneme section
	CALL	PLAY_BUFFER	; play buffer
	LD	A,0FFH
	LD	(MODE),A	; current mode: 0x00=english, 0xff=phoneme
	JR	READ_LOOP

BEGIN_ENGLISH_M:		; found ']', end of phoneme section
	CALL	PLAY_BUFFER	; play buffer
	LD	A,00H
	LD	(MODE),A	; current mode: 0x00=english, 0xff=phoneme
	JR	READ_LOOP

SET_PARAM:	; found '|', parameter
	CALL	PLAY_BUFFER	; play buffer
	CALL	GET_NEXT_CHAR	; get next char (ret in A)
	AND	5FH		; to uppercase
	LD	HL,DEBUG	; debug parameter address
	CP	'D'		; 'D' = debug ?
	JR	Z,SET_PARAM_HL	; set debug value if yes
	LD	HL,ECHO		; echo parameter address
	CP	'E'		; 'E' = echo ?
	JR	Z,SET_PARAM_HL	; set echo value if yes
	LD	HL,DBGRUL	; echo parameter address
	CP	'R'		; 'R' = rules debugging ?
	JR	Z,SET_PARAM_HL	; set echo value if yes
	JP	READ_LOOP	; next char

SET_PARAM_HL:
	PUSH	HL		; save pointer
	CALL	DECODE_INTEGER	; get value in A
	POP	HL		; restore pointer
	LD	(HL),A		; store parameter value
	JP	READ_LOOP	; next char

DECODE_INTEGER:
	LD	B,00H
L_DECODE_INTEGE:
	CALL	GET_NEXT_CHAR	; get next char (ret in A)
	SUB	30H
	JR	C,X_DECODE_INTEGE
	CP	10
	JR	NC,X_DECODE_INTEGE
	LD	C,B
	SLA	C
	SLA	B
	SLA	B
	SLA	B
	ADD	A,B
	ADD	A,C
	LD	B,A
	JR	L_DECODE_INTEGE

X_DECODE_INTEGE:
	LD	A,B
	RET


;-----	Get next char in A
GET_NEXT_CHAR:	; get next char (ret in A)
	LD	A,(SOURCE)	; source: 0x00 = command line, 0xff = file
	CP	0FFH
	JR	Z,GET_NEXT_CHAR_F; get next char from file (ret in A)
	LD	HL,(CMDLINE_ADDR); address of next character to read from command line
	LD	A,(HL)
	INC	HL
	LD	(CMDLINE_ADDR),HL; address of next character to read from command line

	IF	LSDOS6
	  CP	0DH		; LS-DOS command line terminates with CR
	  RET	NZ
	  XOR	A		; Change it to 0
	ENDIF

	RET

GET_NEXT_CHAR_F:	; get next char from file (ret in A)
	IF	CPM
	  LD	A,(BLOCKPOS)	; position inside file block (0..127)
	  CP	80H
	  CALL	Z,LOAD_FILE_BLOCK; load a new block (128 bytes) into 0x0080
	  LD	A,(BLOCKPOS)	; position inside file block (0..127)
	  ADD	A,80H
	  LD	L,A
	  LD	H,00H
	  LD	A,(HL)
	  LD	HL,BLOCKPOS	; position inside file block (0..127)
	  INC	(HL)
	ENDIF

	IF	LSDOS6
	  LD	DE,FCB		; File control block
	  $SVC	@GET		; read one byte from file
	  RET	Z		; if success
	  XOR	A		; End of file => return 0
	  RET
	ENDIF

	RET

	IF	CPM
LOAD_FILE_BLOCK:		; load a new block (128 bytes) into 0x0080
	  LD	DE,FCB
	  LD	C,14H
	  CALL	BDOS
	  CP	00H
	  JR	Z,X_LOAD_FILE_BLO
	  LD	A,1AH		; End of file (Ctrl-Z)
	  LD	(D0080),A
X_LOAD_FILE_BLO:
	  LD	A,00H
	  LD	(BLOCKPOS),A	; position inside file block (0..127)
	  RET
	ENDIF			; CP/M

SHOWHELP:	; show help and exit
	IF CPM
	  LD	DE,MSG_HELP	; Help text
	  LD	C,09H
	  CALL	BDOS
	  JP	0000H
	ENDIF

	IF	LSDOS6
	  LD	HL,MSG_HELP
	  $SVC	@DSPLY		; Line output to *DO (video display)
	  LD	HL,0		; No error exit
	  $SVC	@EXIT		; Exit program with return code
	ENDIF

CHECK_INPUT_SOU:	; try to open specified file. On fail input comes from command line
	IF	LSDOS6
	  LD	DE,FCB		; File control block
	  PUSH	DE
	  $SVC	@FSPEC		; Fetch and parse a file specification
	  POP	DE
	  LD	HL,FCB_BUF	; Sector buffer
	  LD	B,1		; use @GET to read the file
	  $SVC	@OPEN		; Open an existing file
	  JR	Z,OPEN_OK
	  CP	2AH		; LRL mismatch error code
	  RET	NZ
OPEN_OK:
	ENDIF

	IF	CPM
	  LD	DE,FCB
	  LD	C,0FH
	  CALL	BDOS
	  CP	0FFH
	  RET	Z
	  LD	A,00H
	  LD	(D007C),A	; used ?
	ENDIF

	LD	A,0FFH
	LD	(SOURCE),A	; source: 0x00 = command line, 0xff = file
	RET

	IF	CPM
FCB	  EQU	005CH
FCB_END	  EQU	007CH
	ENDIF

	IF	LSDOS6
FCB	  DS	0020H		; DOS file control block
FCB_BUF	  DS	0100H		; DOS sector buffer
	ENDIF


;------------------------------------------------------------------------------
;	E X E C   E N D		; End of LS-DOS and CP/M executor part
;------------------------------------------------------------------------------


	END
