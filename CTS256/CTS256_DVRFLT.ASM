;CTS256_DVRFLT.ASM

;==================================================================================================
;	L S - D O S   D R I V E R   L O A D E R
;==================================================================================================
;
;	Parts:
;	- Installer: installs the jumper and the driver.
;	- Jumper: to load in LOW memory, use to activate banked memory
;	  where resides the driver.
;	- Driver/Filter module: to load in banked memory.
;
;	Driver/Filter module will be loaded at 8000H in bank 1 if available.
;	Jumper will be loaded in LOW memory.
;

DCB@GET	EQU	01H		; DCB can handle @GET
DCB@PUT	EQU	02H		; DCB can handle @PUT
DCB@CTL	EQU	04H		; DCB can handle @CTL
DCB@NIL	EQU	08H		; DCB is a NIL device
DCB@RUT	EQU	10H		; DCB is routed (R/O)
DCB@LNK	EQU	20H		; DCB is linked (R/0)
DCB@FLT	EQU	40H		; DCB is a filter
DCB@FCB	EQU	80H		; DCB is actually a FCB




;------------------------------------------------------------------------------
;	M O D U L E   I N S T A L L E R
;------------------------------------------------------------------------------

ENTRY:				; Installer entry point
	$BREAK
	PUSH	DE
	POP	IX		; Get dcb
	LD	(JMPDCB),DE	; Stuff DCB pointer
	LD	HL,MSG_HELP
	$SVC	@DSPLY		; Display title

;*=*=*
; Check if entry from SET command
;*=*=*
	$SVC	@FLAGS$		; Get flags pointer
	BIT	3,(IY+'C'-'A')	; System request?
	JP	Z,VIASET

;*=*=*
; Obtain low memory driver pointer.	Bizarre API here!
;*=*=*
	LD	E,'K'		; Locate pointer to *KI DCB
	LD	D,'I'		; 	via @GTDCB SVC
	$SVC	@GTDCB		; !!EI!!
	JP	NZ,CURDL	; No error unless KI clobbered!
	DEC	HL		; Decrement to driver pointer
	LD	D,(HL)		; P/u hi-order of pointer,
	DEC	HL		;	decrement to and p/u
	LD	E,(HL)		;	lo-order of pointer
	LD	(DEST),DE	; save dest address
	LD	(LOWPTR),HL	; save pointer address

;*=*=*
; Check if driver will fit into [(LCPTR), X'12FF']
;*=*=*
	LD	HL,JMPEND-JMPBGN; Jumper length
	ADD	HL,DE		;
	LD	BC,1300H	; max address + 1
	XOR	A		;
	SBC	HL,BC		; space available in low mem?
	JP	NC,NOLOW	; jump if yes

;*=*=*
; Relocate addresses
;*=*=*
RELOC	LD	HL,(DEST)	; calculate relocation offset
	LD	DE,-JMPBGN	;
	ADD	HL,DE		;
	LD	B,H		; offset to BC
	LD	C,L		;
	LD	HL,RELTAB	; fixup table
RELO0	LD	E,(HL)		; get next address to relocate
	INC	HL		;
	LD	D,(HL)		;
	INC	HL		;
	LD	A,D		; test for null
	OR	E		;
	JR	Z,MOVDRV	; exit if no more address
	EX	DE,HL		; Swap DE and HL
	LD	A,(HL)		; adjust vector (add BC)
	ADD	A,C		;
	LD	(HL),A		;
	INC	HL		;
	LD	A,(HL)		;
	ADC	A,B		;
	LD	(HL),A		;
	EX	DE,HL		; Restore DE
	JR	RELO0		; loop

;*=*=*
; Move Driver/Filter module to bank
;*=*=*
MOVDRV:	LD	BC,0207H	; B=reserve bank, C=max bank #
	$BREAK
FBANK:	LD	L,C		; Save bank #
	$SVC	@BANK		; RAM bank switching: reserve bank
	LD	C,L		; restore bank
	JR	Z,FBNKOK	; Jump if successful
	DEC	C		; Previous bank
	JR	NZ,FBANK	; until all banks tested
	JP	NOBANK		; No bank available error
FBNKOK:	LD	A,C		; Put bank # in message
	ADD	A,'0'		;
	LD	(MSGBNKNUM),A	;
	LD	B,3		; Reserve the bank
	LD	L,C		; save bank #
	$SVC	@BANK		; RAM bank switching: reserve bank
	LD	C,L		; restore bank

	EXX			; Save BC, reserved bank #
	LD	HL,MODBGN	; Move banked module to bank
	PUSH	HL		; Push Source address
	LD	DE,BUFFER	; 1st: from bank 0 to resident memory
	PUSH	DE		; Push dest address
	LD	BC,MODEND-MODBGN; Banked module length
	PUSH	BC		; Push length
	LDIR			; Move it
	EXX			; Restore reserved bank

	LD	B,0		; select bank
	LD	(BANKNUM),BC	; save bank # in jumper
	$SVC	@BANK		; RAM bank switching

	EXX			; save BC=restore Bank 0
	POP	BC		; Pop length
	POP	HL		; Pop dest address as new source
	POP	DE		; Pop source address as new dest
	LDIR			; Move from resident memory to bank C
	EXX			; restore BC to reselect bank 0

	CALL	BOOTCTS		; Boot the CTS256A-AL2 module

	$SVC	@BANK		; reselect bank 0

;*=*=*
; Install Jumper
;*=*=*
INSTAL	LD	HL,JMPBGN	; driver begin
	LD	DE,(DEST)	; top of low memory
	LD	BC,JMPEND-JMPBGN; block length
	; Stuff TYPE byte
	IF	FILTER
	  LD	(IX+0),DCB@PUT+DCB@CTL+DCB@FLT
	ELSE
	  LD	(IX+0),DCB@PUT
	ENDIF
	LD	(IX+1),E
	LD	(IX+2),D	; Install addr into dcb
	LDIR			; move
	LD	HL,(LOWPTR)	; set new top of low memory
	LD	(HL),E		;
	INC	HL		;
	LD	(HL),D		;

;*=*=*
; Display banner
;*=*=*
	LD	HL,MSGJMPLD	; 'Module loaded in '
	$SVC	@DSPLY
	LD	HL,(LOWHIGH)	; 'LOW' / 'HIGH'
	$SVC	@DSPLY
	LD	HL,MSGMEMORY	; ' memory'
	$SVC	@DSPLY

	PUSH	IX		; Recover DCB in DE
	POP	DE		;
	LD	HL,READY_	; "Ready." message
	$SVC	@MSG		; send to voice driver

;-----	Exit OK:
ENDOK	LD	HL,0		; no error
EXIT	$SVC	@EXIT		; exit to DOS


;*=*=*
; Error messages logging
;*=*=*
CURDL:	LD	HL,CURDL_	; Other error
	DB	0DDH		;
VIASET:	LD	HL,VIASET_	; 'Must install via SET!'
	DB	0DDH		;
NOBANK:	LD	HL,NOBANK_	; 'Banked memory is not available!'
	DB	0DDH		;
NOLOW:	LD	HL,NOLOW_	; 'Low memory is not available!'
	$SVC	@LOGOT		; Display and log a message (*DO and *JL)
	LD	HL,-1		; Return code
	JR	EXIT		; exit to DOS
;

VIASET_:DB	'Must install via SET!',CR
CURDL_: DB	'LS-DOS is curdled!',CR
NOBANK_:DB	'Banked memory is not available!',CR
NOLOW_:	DB	'Low memory is not available!',CR
READY_:	DB	'...',CR

MSGJMPLD:
	DB	'Driver loaded in ',03H

MSGLOW:
	DB	'LOW',03H

MSGHIGH:
	DB	'HIGH',03H

MSGMEMORY:
	DB	' memory and in Bank #'
MSGBNKNUM:
	DB	'0',0AH,0DH


;------------------------------------------------------------------------------
;	J U M P E R   B E G I N
;------------------------------------------------------------------------------

JMPBGN:	JR	JBEGIN		; Branch around linkage
FX00:	DW	JMPEND-1	; To contain last byte used
	DB	JMPDCB-JMPNAM	; Calculate length of 'NAME'
JMPNAM:	DB	'CTS256'	; Name of this Jumper
JMPDCB:	DW	$-$		; To contain DCB pointer for Jumper
	DW	0		; Reserved by the DOS

;*=*=*
; Jumper execution start
;*=*=*
; On entry:
;	Z,NC if @PUT
;	C,NZ if @GET
;	NC,NZ if @CTL
;	B = I/O direction code (1=@GET, 2=@PUT, 4=@CTL)
;	C = char code passed to @PUT or @CTL
; On exit:
;	A = char to return for @GET on success, with Z (CP A:RET)
;	A = 0 if no char available for @GET, with NZ (OR 1:LD A,0:RET)
;	A = errnum if an error occurred, with NZ (LD A,n:OR A:RET)
JBEGIN:
;	$BREAK
	DI			; Disable interrupts while banking !
	$EIBRK	ON
	LD	(JSAVSP),SP	; Save SP
FX01	EQU	$-2
	LD	SP,JMPEND	; Switch to local stack
FX02	EQU	$-2
	CALL	JBEG1		; Exec the jumper
FX03	EQU	$-2
	LD	SP,$-$		; restore SP
JSAVSP	EQU	$-2
	$EIBRK	OFF
	EI			; re-enable interrupts
	RET			; done

JBEG1:	PUSH	AF		; save function flags
	PUSH	BC		; save output char
	LD	BC,0001H	; Select bank 1
BANKNUM	EQU	$-2		; Fixed up by installer
	$SVC	@BANK		; RAM bank switching
	JR	NZ,JERROR	; Jump on error
	LD	L,C		; save old bank
	POP	BC		; Restore char
	POP	AF		; restore flags

	PUSH	BC		; save output char
	PUSH	HL		; save old bank
	CALL	BEGIN		; Execute banked module
	POP	BC		; restore old bank
	PUSH	AF		; save exit condition
	LD	B,0		; restore old bank
	$SVC	@BANK		; RAM bank switching
	POP	AF		; restore exit condition
	POP	BC		; output char
	RET			; return to DOS

JERROR:	POP	BC		; restore output char
	INC	SP		; drop saved function flags
	INC	SP		;
	RET			; return to DOS with NZ

;	DS	400H		; dummy space (to test low memory availability)

	DC	60H,76H		; Local stack
JMPEND:				; Jumper ends here

;------------------------------------------------------------------------------
;	J U M P E R   E N D
;------------------------------------------------------------------------------

;*=*=*
; Relocation table
;*=*=*
RELTAB:	DW	FX00,FX01,FX02,FX03
	DW	RX01
	DW	0		; End of table

BUCKET	DW	0		; Dummy storage
LOWHIGH	DW	MSGLOW		; can be changed to MSGHIGH
DEST	DS	2		; dest relocation address
LOWPTR	DS	2		; pointer to top of low memory

BUFFER	EQU	$

	ORG	8000H		; Portion to move to banked memory at 8000H

;------------------------------------------------------------------------------
;	D R I V E R   B E G I N
;------------------------------------------------------------------------------

MODBGN:	JR	BEGIN		; Branch around linkage
	DW	MODEND-1	; To contain last byte used
	DB	MODDCB-MODNAM	; Calculate length of 'NAME'
MODNAM:	DB	'CTS256A-AL2'	; Name of this module
MODDCB:	DW	$-$		; To contain DCB pointer for module
	DW	0		; Reserved by the DOS

;*=*=*
; Module execution start
;*=*=*
; On entry:
;	Z,NC if @PUT
;	C,NZ if @GET
;	NC,NZ if @CTL
;	B = I/O direction code (1=@GET, 2=@PUT, 4=@CTL)
;	C = char code passed to @PUT or @CTL
; On exit:
;	A = char to return for @GET on success, with Z (CP A:RET)
;	A = 0 if no char available for @GET, with NZ (OR 1:LD A,0:RET)
;	A = errnum if an error occurred, with NZ (LD A,n:OR A:RET)
BEGIN:	;$BREAK		;
	LD	(SAVSP),SP	; Save SP
	LD	SP,STACK	; switch to local stack
	CALL	BEGIN1		; do the I/O
	LD	SP,$-$		; saved SP
SAVSP	EQU	$-2		;
	RET			; return

BEGIN1:	JR	Z,DOPUT		; Go if @PUT request
				; else Was @CTL request

; Ctl character => @CHNIO or @PRT
XSP0256:			; Send to SP0256A-AL2
DOCTL:	;$BREAK
	PUSH	IX
	PUSH	BC
	LD	IX,(JMPDCB)
RX01	EQU	$-2
	IF	FILTER
	  BIT	6,(IX+0)	; Filter activated?
	  LD	A,@CHNIO	; If yes, send to @CHNIO
	  JR	Z,DOCTL1	;
	ENDIF
	LD	A,@PRT		;   else send to @PRT
DOCTL1	CALL	DRVSVC		; Protected @SVC call
	;$BREAK
	POP	BC
	POP	IX
	RET

; Send a character to CTS256A-AL2
DOPUT:	LD	A,(PARMODE)	; Param mode ('|' or param letter)
	OR	A		;
	JR	NZ,DOPARAM	; Jump if Parameter being parsed
	LD	A,C		; get output char
	CP	20H		; Displayable ?
	JR	C,DOPLAY	; Play buffer if not
	CP	'['		; '[' to start phoneme mode ?
	JR	NZ,DOPUT1	; Skip if not
	CALL	PLAY_BUFFER	; play buffer
	LD	A,0FFH		; set current mode to phoneme
	LD	(MODE),A	; current mode: 0x00=english, 0xff=phoneme
	JR	DOPUTX		; exit driver
DOPUT1:	CP	']'		; ']' to exit phoneme mode ?
	JR	NZ,DOPUT2	; skip if not
	CALL	PLAY_BUFFER	; play buffer
	XOR	A		; set current mode to English
	LD	(MODE),A	; current mode: 0x00=english, 0xff=phoneme
	JR	DOPUTX		; exit driver
DOPUT2:	CP	'|'		; '|' to set parameter ?
	JR	NZ,DOPUT3	; skip if not
	LD	(PARMODE),A	; put '|' as param mode
	JR	DOPLAY		; play buffer and exit driver
DOPUT3:	CALL	PUT_CHAR	; playable character => put to buffer
	JR	DOPUTX		; exit driver
DOPLAY:	CALL	PLAY_BUFFER	; play buffer
	JR	DOPUTX		; exit driver
DORESET:XOR	A		; reset parameter mode
	LD	(PARMODE),HL	;
DOPUTX:	CP	A		; set Z (no error)
	RET			; done


; Parse parameter
DOPARAM:
	CP	'|'		; check last char: '|' ?
	JR	NZ,DOPAR1	; jump if not
	LD	A,C		; get param letter
	AND	5FH		; convert to upper case
	CP	'A'		; if not letter, reset and exit
	JR	C,DORESET	;
	CP	'Z'+1		;
	JR	NC,DORESET	;
	LD	(PARMODE),A	; store param letter
	XOR	A		;
	LD	(PARVAL),A	; reset param value
	JR	DOPUTX		; exit driver
DOPAR1:	LD	A,C		; param name known: parse value
	SUB	'0'		; check and get digit value
	JR	C,DOPAR2	; jump if not digit => process param
	CP	10		;
	JR	NC,DOPAR2	;
	LD	C,A		; PARVAL := 10 * PARVAL + digit value
	LD	A,(PARVAL)	;
	LD	B,A		;
	ADD	A,A		;
	ADD	A,A		;
	ADD	A,B		;
	ADD	A,A		;
	ADD	A,C		;
	LD	(PARVAL),A	; store updated PARVAL
	JR	DOPUTX		; exit driver
DOPAR2:	LD	A,(PARVAL)	; process param: get value
	LD	C,A		;
	LD	A,(PARMODE)	; get param letter
	CP	'D'		; 'D' = debug mode ?
	JR	NZ,DOPAR6	; skip if not
	LD	A,C		; store new debug flag
	LD	(DEBUG),A	;
DOPAR6:	CP	'E'		; 'E' = echo mode ?
	JR	NZ,DOPAR7	; skip if not
	LD	A,C		; store new echo flag
	LD	(ECHO),A	;
DOPAR7:	CP	'R'		; 'E' = echo mode ?
	JR	NZ,DORESET	; reset param and exit if not
	LD	A,C		; store new debug rules flag
	LD	(DBGRUL),A	;
	JR	DORESET		; reset param and exit

PARMODE	DB	0		; parameter mode ('|' or param letter)
PARVAL	DB	0		; parameter value

;------------------------------------------------------------------------------
;	D R I V E R   E N D	; End of the LS-DOS part of the driver
;------------------------------------------------------------------------------


	END
