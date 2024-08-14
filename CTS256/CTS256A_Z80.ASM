;** TMS-7000(tm) DISASSEMBLER V1.10beta3 - (c) 2015-20 GmEsoft, All rights reserved. **
;
;	Tue Dec 27 08:39:46 2022
;
;	Disassembly of : CTS256A.BIN
;	Equates file   : CTS256A.EQU
;	Screening file : CTS256A.SCR


;==============================================================================

	ORG	0F000H		;AORG	>F000

;==============================================================================

	; Main entry point
CTS256	LD	B,3AH		;MOV	%>3A,B
	LD	L,B		;LDSP			; Init stack pointer 3B-XX
	LD	H,0
	LD	SP,HL
	LD	HL,SP0256	;MOVD	%SP0256,R45	; R45 := $2000 - Memory-mapped parallel output to SP0256A-AL2
	LD	(R45),HL
	LD	C,A		;MOVP	%>AA,P0		; P0 = IOCNT0 := 1010 1010
	LD	A,0AAH
	LD	(P0),A
	LD	A,C
				; 	Full Expansion;
				;	Clear INT1, INT2 and INT3 flags
	LD	C,A		;MOVP	%>0A,P16	; P16 = IOCNT1 := 0000 1010
	LD	A,0AH
	LD	(P16),A
	LD	A,C
				;	Clear INT4 and INT5 flags
	LD	C,A		;MOVP	P4,B		; Read P4 = APORT
	LD	A,(P4)
	LD	B,A
	LD	A,B		;AND	%>07,B		; Get Serial mode
	AND	07H
	LD	B,A
	LD	A,B		;CMP	%>00,B		; Is it Parallel mode ?
	CP	00H
	LD	A,C
				; useful ?
	; Jump if yes
	JR	Z,PARALL	;JZ	PARALL		; Start in parallel mode
	RES	7,(IX-10)	;AND	%>7F,R10	; Clear R10.7, indicating serial mode
	LD	A,(P4)		;MOVP	P4,A		; Read P4 = APORT
	AND	08H		;AND	%>08,A		; Get Selectable Serial Config flag
	CP	00H		;CMP	%>00,A		; Is it set ?
				; useful ?
	; Jump if not
	JR	Z,SER7N2	;JZ	SER7N2		; Serial fixed 7N2 config
	LD	HL,1000H	;LDA	@>1000		; Read serial config from $1000
	LD	A,(HL)
	LD	(P17),A		;MOVP	A,P17		; Init P17 = SMODE with seria config
	JR	SERSEL		;JMP	SERSEL		; Serial selectable config

SER7N2	LD	C,A		;MOVP	%>CB,P17	; P17 = SMODE := Fixed Serial 7N2 config
	LD	A,0CBH
	LD	(P17),A
	LD	A,C
SERSEL	LD	C,A		;MOVP	%>15,P17	; P17 = SCTL0 := OOO1 O1O1
	LD	A,15H
	LD	(P17),A
	LD	A,C
				; Reset error flags; enable RX & TX
	; A := value for SCTL1 (prescaler)
	LD	HL,SCT1TB	;LDA	@SCT1TB(B)	; Table of values for SCTL1
	LD	E,B
	LD	D,0
	ADD	HL,DE
	LD	A,(HL)
	PUSH	AF		;PUSH	A
	; A := value for T3DATA (timer3 reload)
	LD	HL,T3DATB	;LDA	@T3DATB(B)	; Table of timer3 reload values T3DATA
	LD	E,B
	LD	D,0
	ADD	HL,DE
	LD	A,(HL)
	POP	BC		;POP	B
	LD	C,A		;MOVP	B,P21		; set SCTL1
	LD	A,B
	LD	(P21),A
	LD	A,C
	LD	(P20),A		;MOVP	A,P20		; set T3DATA
	LD	C,A		;ORP	%>01,P16	; enable T4
	LD	A,(P16)
	OR	01H
	LD	(P16),A
	LD	A,C
	; proceed with RAM setup
	JR	INIRAM		;JMP	INIRAM		; Init RAM config

	; Table of values for SCTL1
SCT1TB	DB	0FFH,040H,043H,040H,043H,040H,040H,040H

	; Table of timer3 reload values T3DATA
T3DATB	DB	0FFH,020H,057H,007H,0C2H,00FH,081H,003H

	; Start in parallel mode
PARALL	SET	7,(IX-10)	;OR	%>80,R10	; Set R10.7, indicating parallel mode
	LD	HL,PARLINP	;MOVD	%PARLINP,R47	; R47 := $0200 parallel input mapped address
	LD	(R47),HL
	LD	C,A		;ORP	%>30,P0		; P0 = IOCNT0, set .4=enable INT3, .5=clear INT3
	LD	A,(P0)
	OR	30H
	LD	(P0),A
	LD	A,C
	; Init RAM config
INIRAM	LD	C,A		;MOVP	P4,B		; B := P4 = APORT
	LD	A,(P4)
	LD	B,A
	LD	A,C
	LD	C,A		;AND	%>10,B		; test APORT.4 = RAM buffer - 0=internal - 1=external
	LD	A,B
	AND	10H
	LD	B,A
	LD	A,B		;CMP	%>00,B		; useful ?
	CP	00H
	LD	A,C
	; jump if internal
	JR	Z,INTRAM	;JZ	INTRAM		; init internal RAM pointers

	LD	HL,CTSXRAM	;MOVD	%CTSXRAM,R3	; R2:3 := base RAM address = $3000
	LD	(R3),HL
	LD	HL,(R3)		;MOVD	R3,R41		; R40:41 := R2:3
	LD	(R41),HL
	LD	D,(IX-2)	;PUSH	R2
	PUSH	DE
	DEC	(IX-2)		;DEC	R2
	LD	C,(IX-2)	;MOV	R2,R34		; R34:35 := R2:3 - 1 ($2FFF)
	LD	(IX-34),C
	LD	(IX-35),0FFH	;MOV	%>FF,R35
	LD	C,A		;ADD	%>02,R2		; R2 += 2 ($31)
	LD	A,(R2)
	ADD	A,02H
	LD	(R2),A
	LD	A,C
	LD	(IX-23),0	;CLR	R23		; R23 := 0 (page counter)
	; Init external RAM sizing loop

IRAML0	INC	(IX-2)		;INC	R2		; ++R2
	LD	C,A		;CMP	%>F0,R2		; R2 == $F0 ($F000 reached) ?
	LD	A,(R2)
	CP	0F0H
	LD	A,C
	; Exit loop if yes
	JR	Z,IRAMX0	;JZ	IRAMX0
	INC	(IX-23)		;INC	R23		; ++R23
	LD	C,A		;CMP	%>10,R23	; R23 == $10 (16 pages) ?
	LD	A,(R23)
	CP	10H
	LD	A,C
	; exit loop if yes
	JR	Z,IRAMX0	;JZ	IRAMX0
	LD	A,5AH		;MOV	%>5A,A		; A := $5A (RAM test pattern)
	LD	HL,(R3)		;STA	*R3		; *R2:3 := A
	LD	(HL),A
	LD	A,0		;CLR	A		; A := 0 (useful?)
	LD	HL,(R3)		;LDA	*R3		; A := *R2:3
	LD	A,(HL)
	CP	5AH		;CMP	%>5A,A		; A == $5A (test pattern) ?
	; exit loop if not
	JR	NZ,IRAMX0	;JNZ	IRAMX0
	RLCA			;SWAP	A		; A := $A5 (reverse bits)
	RLCA	
	RLCA	
	RLCA	
	LD	HL,(R3)		;STA	*R3		; *R2:3 := A
	LD	(HL),A
	LD	A,0		;CLR	A		; A := 0 (useful?)
	LD	HL,(R3)		;LDA	*R3		; A := *R2:3
	LD	A,(HL)
	CP	0A5H		;CMP	%>A5,A		; A == $A5 (test pattern) ?
	; exit loop if not
	JR	NZ,IRAMX0	;JNZ	IRAMX0
	; Test next RAM page
	JR	IRAML0		;JMP	IRAML0

IRAMX0	LD	C,(IX-2)	;MOV	R2,R38		; R38:39 := R2:$00 (end RAM addr + 1)
	LD	(IX-38),C
	LD	(IX-39),0	;CLR	R39		; ATTENTION: page boundary !!
	LD	C,A		;SUB	%>01,R2		; --R2 (why not DEC R2?)
	LD	A,(R2)
	SUB	01H
	LD	(R2),A
	LD	A,C
	LD	HL,(R3)		;MOVD	R3,R7		; R6:7 := R2:3 = last RAM page addr (output buffer read ptr)
	LD	(R7),HL
	LD	HL,(R7)		;MOVD	R7,R43		; R42:43 := R6:R7 (output buffer start)
	LD	(R43),HL
	LD	C,A		;SUB	%>01,R2		; --R2 (why not DEC R2?)
	LD	A,(R2)
	SUB	01H
	LD	(R2),A
	LD	A,C
	LD	C,(IX-2)	;MOV	R2,R36		; R36:37 := R2:$FF (input buffer end)
	LD	(IX-36),C
	LD	(IX-37),0FFH	;MOV	%>FF,R37
	POP	DE		;POP	R2		; R2 := $30
	LD	(IX-2),D
	LD	(IX-50),0DFH	;MOV	%>DF,R50	; R50 := $DF
	JR	INIROM		;JMP	INIROM		; Init EPROM

	; init internal RAM pointers
INTRAM	LD	HL,0051H	;MOVD	%>0051,R41	; R40:41 := $0051 (input buffer start)
	LD	(R41),HL
	LD	HL,0065H	;MOVD	%>0065,R37	; R36:37 := $0065 (input buffer end)
	LD	(R37),HL
	LD	HL,0050H	;MOVD	%>0050,R35	; R34:35 := $0050 (input buffer start - 1)
	LD	(R35),HL
	LD	HL,0066H	;MOVD	%>0066,R43	; R42:43 := $0066 (output buffer start)
	LD	(R43),HL
	LD	HL,0080H	;MOVD	%>0080,R39	; R38:39 := $0080 (end RAM addr + 1)
	LD	(R39),HL
	LD	HL,(R41)	;MOVD	R41,R3		; R2:R3 := $0051 (input buffer read ptr)
	LD	(R3),HL
	LD	HL,(R43)	;MOVD	R43,R7		; R6:R7 := $0066 (output buffer read ptr)
	LD	(R7),HL
	LD	(IX-50),01H	;MOV	%>01,R50	; R50 := $01

	; Init EPROM
INIROM	LD	HL,0000H	;MOVD	%>0000,R19	; R18:19 := 0
	LD	(R19),HL
LF0DA	LD	B,0		;CLR	B		; B := 0 (5 signature bytes counter/index)
	LD	C,A		;ADD	%>10,R18	; ++R18 (next page, starting at $1000)
	LD	A,(R18)
	ADD	A,10H
	LD	(R18),A
	LD	A,(R18)		;CMP	%>F0,R18	; $F0 reached ? (ending at $F000)
	CP	0F0H
	LD	A,C
	; Jump if yes
	JR	Z,INITOK	;JZ	INITOK		; Done peripherals init
LF0E3	LD	HL,(R19)	;LDA	*R19		; Read signature byte
	LD	A,(HL)
	; and compare it to the 5 first letters flags $80,$48,$28,$58,$85
	LD	HL,LTFLGS	;CMPA	@LTFLGS(B)	; Letter flags
	LD	E,B
	LD	D,0
	ADD	HL,DE
	CP	(HL)
	; next page if mismatch
	JR	NZ,LF0DA	;JNZ	LF0DA
	INC	B		;INC	B		; next test byte
	LD	C,A		;CMP	%>05,B		; done 5 bytes
	LD	A,B
	CP	05H
	LD	A,C
	; Exit if yes => EPROM found
	JR	Z,STAROM	;JZ	STAROM		; Boot in EPROM
	INC	(IX-19)		;INC	R19		; next EPROM byte
	JR	LF0E3		;JMP	LF0E3		; loop

	; Boot in EPROM
STAROM	INC	(IX-19)		;INC	R19		; point to 1st byte following sig bytes
	LD	HL,(R19)	;MOVD	R19,R49		; R48:49 := R18:19 = EPROM entry point
	LD	(R49),HL
	LD	HL,(R49)	;BR	*R49		; Boot in EPROM
	JP	(HL)

	; Done peripherals init
INITOK	LD	(IX-48),00H	;MOV	%>00,R48	; R48 := 0 (EPROM not present)
	CALL	INIPTR		;CALL	@INIPTR		; Init buffer pointers and regs
	CALL	SAYOK		;CALL	@SAYOK		; Say O.K.
	JR	LF110		;JMP	LF110

;==============================================================================

	; Polling loop
POLL	BIT	0,(IX-11)	;BTJO	%>01,R11,LF110	; test R11.0 = any delimiter; jump if yes
	JR	NZ,LF110
	RES	4,(IX-11)	;AND	%>EF,R11	; reset R11.4 (found delimiter?)

	; Idle loop (wait interrupt?)
WTIDLE	BIT	4,(IX-11)	;BTJZ	%>10,R11,WTIDLE	; Idle loop (wait R11.4)
	JR	Z,WTIDLE
LF110	LD	C,A		;CMP	R3,R5		; Input buffer read ptr LSB != write ptr LSB ?
	LD	A,(R5)
	CP	(IX-3)
	LD	A,C
	JR	NZ,ENDPOL	;JNZ	ENDPOL		; Exit polling loop if yes
	LD	C,A		;CMP	R2,R4		; Idem for MSB ?
	LD	A,(R4)
	CP	(IX-2)
	LD	A,C
	JR	NZ,ENDPOL	;JNZ	ENDPOL		; Exit polling loop if yes
	JR	POLL		;JMP	POLL		; Polling loop

	; Exit polling loop
ENDPOL	LD	C,A		;CMP	%>00,R56	; Chars in buffer MSB
	LD	A,(R56)
	CP	00H
	LD	A,C
	JR	NZ,LF126	;JNZ	LF126		; exit ENDPOL loop if != 0
	LD	C,A		;CMP	%>00,R57	; Chars in buffer LSB
	LD	A,(R57)
	CP	00H
	LD	A,C
	JR	Z,ENDPOL	;JZ	ENDPOL		; loop if == 0

	; Exit ENDPOL loop
LF126	BIT	3,(IX-11)	;BTJZ	%>08,R11,LF133	; R11.3 == 1 (output buffer full or too high)? Jump if not
	JR	Z,LF133
	LD	C,A		;CMP	%>01,R50	; Internal RAM ?
	LD	A,(R50)
	CP	01H
	LD	A,C
	; jump if yes
	JR	Z,CLBUF1	;JZ	CLBUF1		; Clear buffers if yes

	; wait reset of bit 3 of R11
W11B3	BIT	3,(IX-11)	;BTJO	%>08,R11,W11B3	; wait reset of bit 3 of R11 (output buffer low enough)
	JR	NZ,W11B3
LF133	CALL	ENCODE		;CALL	@ENCODE		; Encode text to allophones
	LD	C,A		;CMP	R7,R9		; Output buffer empty ?
	LD	A,(R9)
	CP	(IX-7)
	LD	A,C
	JR	Z,LF110		;JZ	LF110		; jump to input buffer polling loop if yes
	LD	C,A		;ORP	%>01,P0		; enable INT1* (SP0256) to send output
	LD	A,(P0)
	OR	01H
	LD	(P0),A
	LD	A,C
	JR	LF110		;JMP	LF110		; jump to input buffer polling loop

	; Clear buffers
CLBUF1	JP	CLBUF		;BR	@CLBUF		; clear buffers - reinit

;==============================================================================

	; Init buffer pointers and regs
INIPTR	LD	C,A		;AND	%>00,R11	; R11 := 0 (why not CLR R11?)
	LD	A,(R11)
	AND	00H
	LD	(R11),A
	LD	A,C
	LD	(IX-55),0	;CLR	R55		; R55 := 0 (chars to free?)
	LD	(IX-56),0	;CLR	R56		; R56 := 0
	LD	(IX-57),0	;CLR	R57		; R57 := 0
	LD	C,A		;ORP	%>01,P6		; set P6.0 (DSR/BUSY)
	LD	A,(P6)
	OR	01H
	LD	(P6),A
	LD	A,C
	LD	HL,(R41)	;MOVD	R41,R3		; R2:3 := R40:41 (input buffer start)
	LD	(R3),HL
	LD	HL,(R43)	;MOVD	R43,R7		; R6:7 := R42:43 (output buffer start)
	LD	(R7),HL
	LD	A,20H		;MOV	%>20,A		; A := $20
	LD	HL,(R3)		;STA	*R3		; *R2:3 := $20 (input buffer read ptr)
	LD	(HL),A
	CALL	INCR3		;CALL	@INCR3		; inc R2:3 and roll to R40:41 if == R42:43
	LD	HL,(R3)		;MOVD	R3,R5		; R4:5 := R2:3 (input buffer write ptr)
	LD	(R5),HL
	LD	D,(IX-3)	;PUSH	R3		; save pointers
	PUSH	DE
	LD	D,(IX-7)	;PUSH	R7
	PUSH	DE
	LD	D,(IX-6)	;PUSH	R6
	PUSH	DE
	DEC	(IX-3)		;DEC	R3		; R6:7 := ( R6:7 - R2:3 + 1 ) = input buffer size
	LD	C,A		;SUB	R3,R7
	LD	A,(R7)
	SUB	(IX-3)
	LD	(R7),A
	LD	A,(R6)		;SBB	R2,R6
	SBC	A,(IX-2)
	LD	(R6),A
	LD	A,C
	LD	HL,(R7)		;MOVD	R7,R52		; R51:52 := input buffer size - 1
	LD	(R52),HL
	LD	HL,(R52)	;DECD	R52
	DEC	HL
	LD	(R52),HL
	CP	0		;TSTA			; = CLR C
	RR	(IX-6)		;RRC	R6		; R6:7 /= 2
	RR	(IX-7)		;RRC	R7
	LD	HL,(R7)		;MOVD	R7,R31		; R30:31 := buffer size / 2 (and clears C)
	LD	(R31),HL
	RR	(IX-6)		;RRC	R6		; R6:7 /= 2
	RR	(IX-7)		;RRC	R7
	CP	0		;TSTA			; = CLR C
	RR	(IX-6)		;RRC	R6		; R6:7 /= 2
	RR	(IX-7)		;RRC	R7
	LD	HL,(R7)		;MOVD	R7,R33		; R32:33 := buffer size / 8
	LD	(R33),HL
	POP	DE		;POP	R6		; restore pointers
	LD	(IX-6),D
	POP	DE		;POP	R7
	LD	(IX-7),D
	POP	DE		;POP	R3
	LD	(IX-3),D
	LD	HL,(R7)		;MOVD	R7,R9		; R8:9 := R6:7 = output buffer write ptr
	LD	(R9),HL
	LD	HL,(R3)		;MOVD	R3,R25		; R24:25 last delimiter ptr := R2:3 input buffer read ptr
	LD	(R25),HL
	LD	HL,(R39)	;MOVD	R39,R54		; R53:54 := R38:39 = end RAM address + 1
	LD	(R54),HL
	LD	C,A		;SUB	R43,R54		; R53:54 := ( R53:54 - R42:43 ) = output buffer size
	LD	A,(R54)
	SUB	(IX-43)
	LD	(R54),A
	LD	A,(R53)		;SBB	R42,R53
	SBC	A,(IX-42)
	LD	(R53),A
	LD	A,(P4)		;MOVP	P4,B		; B := APORT
	LD	B,A
	LD	A,B		;AND	%>80,B		; APORT.7 set ? (Delimiter=any)
	AND	80H
	LD	B,A
	LD	A,B		;CMP	%>00,B		; useful ?
	CP	00H
	LD	A,C
	; Jump if not
	JR	Z,LF1A6		;JZ	LF1A6
	SET	0,(IX-11)	;OR	%>01,R11	; R11.0 := 1 if any delimiter
LF1A6	DI			;EINT			; enable interrupts
	RET			;RETS

;==============================================================================

	; "O-K\n"
STROK	DB	'O-K'
	DB	00DH

	; Say O.K.
SAYOK	LD	C,A		;AND	%>F9,R10	; Clear R10.1 and R10.2: Write to input buffer
	LD	A,(R10)
	AND	0F9H
	LD	(R10),A
	LD	A,C
	LD	B,0		;CLR	B
LF1B0	LD	HL,STROK	;LDA	@STROK(B)	; Get char
	LD	E,B
	LD	D,0
	ADD	HL,DE
	LD	A,(HL)
	CALL	STINPB		;CALL	@STINPB		; Store char in input buffer
	INC	B		;INC	B		; next char
	LD	C,A		;CMP	%>04,B		; loop until 4 chars processed
	LD	A,B
	CP	04H
	LD	A,C
	JR	NZ,LF1B0	;JNZ	LF1B0
	RET			;RETS			; return

;==============================================================================

	; INT4 handler (serial interrupt)
INT4	HALT			;BTJOP	%>02,P17,INT3	; Jump if P17.1 (RXRDY) == 1
	RET			;RETI			; else return from interrupt

	; INT3 handler (parallel interrupt)
INT3	PUSH	AF		;PUSH	A		; save A from interrupt
	BIT	7,(IX-10)	;BTJO	%>80,R10,LF1D1	; R10.7 (parallel mode) == 1 ? Jump if yes
	JR	NZ,LF1D1
	LD	C,A		;ANDP	%>FE,P16	; Reset P16.0 (disable serial INT4)
	LD	A,(P16)
	AND	0FEH
	LD	(P16),A
	LD	A,C
	; wait RXBUF ready with new character
WRXRDY	HALT			;BTJZP	%>02,P17,WRXRDY	; wait RXBUF ready with new character
	LD	A,(P22)		;MOVP	P22,A		; get A := RXBUF incoming character
	JR	LF1D6		;JMP	LF1D6		; handle incoming char in A

	; Parallel mode
LF1D1	LD	C,A		;ANDP	%>EF,P0		; Disable P0.0 = INT3*
	LD	A,(P0)
	AND	0EFH
	LD	(P0),A
	LD	A,C
	LD	HL,(R47)	;LDA	*R47		; Read char from parallel input ($0200)
	LD	A,(HL)

	; Handle incoming char
LF1D6	CALL	STINPB		;CALL	@STINPB		; Store char in input buffer
	POP	AF		;POP	A		; restore A from interrupt
	BIT	5,(IX-11)	;BTJO	%>20,R11,LF1E1	; R11.5 == 1 ? (input buffer full) skip next instr if yes
	JR	NZ,LF1E1
	CALL	ENINT		;CALL	@ENINT		; re-enable parallel or serial interrupt
LF1E1	RET			;RETI			; return from interrupt

;==============================================================================

	; Store char in input buffer
STINPB	PUSH	BC		;PUSH	B		; Save registers
	LD	D,(IX-10)	;PUSH	R10
	PUSH	DE
	LD	D,(IX-12)	;PUSH	R12
	PUSH	DE
	LD	D,(IX-13)	;PUSH	R13
	PUSH	DE
	LD	C,A		;AND	%>F9,R10	; reset R10.1 and R10.2: write to input buffer
	LD	A,(R10)
	AND	0F9H
	LD	(R10),A
	LD	A,C
	CP	1BH		;CMP	%>1B,A		; <ESC> ? => clear buffers
	JR	NZ,NOTESC	;JNZ	NOTESC		; Skip if not

	; clear buffers - reinit
CLBUF	LD	C,A		;ANDP	%>FE,P0		; Disable INT1* (SP0256)
	LD	A,(P0)
	AND	0FEH
	LD	(P0),A
	LD	A,C
	CALL	INIPTR		;CALL	@INIPTR		; Init buffer pointers and regs
	LD	B,3AH		;MOV	%>3A,B		; Init SP
	LD	L,B		;LDSP			;
	LD	H,0
	LD	SP,HL
	LD	HL,(R45)	;MOVD	R45,R27		; R26:27 := R44:45  (SP0256 device)
	LD	(R27),HL
	LD	HL,(R27)	;STA	*R27		; *R26:27 := A  (SP0256 device)
	LD	(HL),A
	CALL	ENINT		;CALL	@ENINT		; Enable input interrupt (parallel or serial)
	JP	POLL		;BR	@POLL		; Polling loop

	; Not <ESC>
NOTESC	CP	12H		;CMP	%>12,A		; <Ctrl-R> ? => backspace until last delimiter
	JR	NZ,NOTCTR	;JNZ	NOTCTR		; Skip if not

	; Handle <Ctrl-R>
	BIT	0,(IX-11)	;BTJO	%>01,R11,LF21E	; R11.0 == 1 (any delimiter) ? Exit if yes
	JR	NZ,LF21E
	LD	C,A		;SUB	R25,R3		; R2:3 (input buf read ptr) -= R24:25 (last delimiter)
	LD	A,(R3)
	SUB	(IX-25)
	LD	(R3),A
	LD	A,(R2)		;SBB	R24,R2		;	(may not work correctly if rolled...)
	SBC	A,(IX-24)
	LD	(R2),A
	LD	A,(R52)		;SUB	R3,R52		; R51:52 (input buffer free size) -= R2:3
	SUB	(IX-3)
	LD	(R52),A
	LD	A,(R51)		;SBB	R2,R51
	SBC	A,(IX-2)
	LD	(R51),A
	LD	A,C
	LD	HL,(R25)	;MOVD	R25,R3		; R2:3 := R24:25 (last delimiter position)
	LD	(R3),HL
	LD	(IX-57),01H	;MOV	%>01,R57	; input buffer counter LSB(why?) := 1
LF21E	JP	XSTINP		;BR	@XSTINP		; exit handler

	; Not <Ctrl-R>
NOTCTR	CP	08H		;CMP	%>08,A		; <BkSp> ?
	JR	NZ,NOTBKS	;JNZ	NOTBKS		; Skip if not

	; Handle <BkSp>
	LD	C,A		;CMP	R2,R4		; Input buffer pointers equal ?
	LD	A,(R4)
	CP	(IX-2)
	LD	A,C
	JR	NZ,LF22F	;JNZ	LF22F
	LD	C,A		;CMP	R3,R5
	LD	A,(R5)
	CP	(IX-3)
	LD	A,C
	JR	Z,XSTINP	;JZ	XSTINP		; If yes, exit handler
LF22F	LD	D,(IX-3)	;PUSH	R3		; Save R2:3
	PUSH	DE
	LD	D,(IX-2)	;PUSH	R2
	PUSH	DE
	LD	HL,(R5)		;MOVD	R5,R3		; R2:3 := R4:5 input buffer write ptr
	LD	(R3),HL
	CALL	DECR3		;CALL	@DECR3		; dec R2:3 and roll if needed
	LD	HL,(R3)		;MOVD	R3,R5		; R4:5 := R2:3
	LD	(R5),HL
	POP	DE		;POP	R2		; restore R2:3
	LD	(IX-2),D
	POP	DE		;POP	R3
	LD	(IX-3),D
	INC	(IX-52)		;INC	R52		; Inc R51:52 input buffer free size
	JR	NZ,XSTINP	;JNC	XSTINP
	INC	(IX-51)		;INC	R51
	JR	XSTINP		;JMP	XSTINP		; exit handler

	; Not <BkSp>: Handle other chars
NOTBKS	CP	27H		;CMP	%>27,A		; ''' ?
	JR	Z,STOCHR	;JZ	STOCHR		; Jump if yes
	CP	7BH		;CMP	%>7B,A		; higher than 'z' ?
	JP	P,DELIMT	;JP	DELIMT		; Jump if yes
	CP	30H		;CMP	%>30,A		; '0'..'9' ?
	JP	M,DELIMT	;JN	DELIMT
	CP	3AH		;CMP	%>3A,A
	JP	M,STOCHR	;JN	STOCHR
	CP	41H		;CMP	%>41,A		; >= 'A' ?
	JP	P,STOCHR	;JPZ	STOCHR

	; Delimiter (not letter/digit/')
DELIMT	BIT	0,(IX-11)	;BTJO	%>01,R11,LF267	; R11.0 set (any delimiter) ? Jump if yes
	JR	NZ,LF267
	CP	0DH		;CMP	%>0D,A		; <CR> ?
	JR	NZ,LF26A	;JNZ	LF26A		; skip if not
	SET	4,(IX-11)	;OR	%>10,R11	; R11.4 := 1 (found CR => exit idle loop)
LF267	LD	HL,(R3)		;MOVD	R3,R25		; R24:25 := R2:3 (last delimiter position)
	LD	(R25),HL
LF26A	OR	80H		;OR	%>80,A		; A.7 := 1 (set high bit)
	INC	(IX-57)		;INC	R57		; Increment R56:57 (# of bytes in input buffer)
	JR	NZ,STOCHR	;JNC	STOCHR		; put char in buffer
	INC	(IX-56)		;INC	R56

	; put char in buffer
STOCHR	CALL	RWBUFR		;CALL	@RWBUFR		; write char in buffer
	BIT	5,(IX-11)	;BTJZ	%>20,R11,XSTINP	; R11.5 set (inp buffer full)? if not exit handler
	JR	Z,XSTINP
	LD	A,8DH		;MOV	%>8D,A		; A := <CR> + $80
	INC	(IX-57)		;INC	R57		; Increment R56:57 (# of bytes in input buffer)
	JR	NZ,LF281	;JNC	LF281
	INC	(IX-56)		;INC	R56
LF281	CALL	RWBUFR		;CALL	@RWBUFR		; write char in buffer
	; exit handler
XSTINP	POP	DE		;POP	R13		; Restore registers
	LD	(IX-13),D
	POP	DE		;POP	R12
	LD	(IX-12),D
	POP	DE		;POP	R10
	LD	(IX-10),D
	POP	BC		;POP	B
	RET			;RETS			; end of input char handling

;==============================================================================

	; R10:7 ? (enable INT3) : (enable INT4)
ENINT	BIT	7,(IX-10)	;BTJZ	%>80,R10,ENINT4	; enable INT4
	JR	Z,ENINT4
	LD	C,A		;ORP	%>10,P0
	LD	A,(P0)
	OR	10H
	LD	(P0),A
	LD	A,C
	RET			;RETS

	; enable INT4
ENINT4	LD	C,A		;ORP	%>01,P16
	LD	A,(P16)
	OR	01H
	LD	(P16),A
	LD	A,C
	RET			;RETS

;==============================================================================

	; select input or output buffer and read/store byte in it
RWBUFR	BIT	1,(IX-10)	;BTJO	%>02,R10,RDBUF	; R10.1 set ? Jump if yes (read from either buffer)
	JR	NZ,RDBUF

	; write to input or output buffer
	BIT	2,(IX-10)	;BTJO	%>04,R10,WROBUF	; R10.2 set ? Jump if yes (output buffer)
	JR	NZ,WROBUF
	LD	HL,(R5)		;MOVD	R5,R13		; R12:13 := R4:5 input buffer write ptr
	LD	(R13),HL
	LD	HL,(R52)	;DECD	R52		; Decrement # of free input buffer bytes
	DEC	HL
	LD	(R52),HL
	JR	WRBUF		;JMP	WRBUF		; Store A in buffer

WROBUF	LD	HL,(R9)		;MOVD	R9,R13		; R12:13 := R8:9 output buffer write ptr
	LD	(R13),HL
	LD	HL,(R54)	;DECD	R54		; Decr output buffer free size
	DEC	HL
	LD	(R54),HL

	; Store byte A in buffer
WRBUF	LD	HL,(R13)	;STA	*R13		; *R12:13 := A (store byte in buffer)
	LD	(HL),A
	LD	HL,000DH	;LDA	@>000D		; A := R13 (why using LDA?)
	LD	A,(HL)
	LD	C,A		;ADD	%>01,R13	; Increment R12:13
	LD	A,(R13)
	ADD	A,01H
	LD	(R13),A
	LD	A,(R12)		;ADC	%>00,R12
	ADC	A,00H
	LD	(R12),A
	LD	A,C
	CALL	ROLR13		;CALL	@ROLR13		; Roll R12:13 if needed
	BIT	2,(IX-10)	;BTJO	%>04,R10,WOBUFX	; R10.2 set ? Jump if yes (output buffer)
	JR	NZ,WOBUFX
	LD	HL,(R13)	;MOVD	R13,R5		; R4:5 := R12:13 (inp buffer write ptr)
	LD	(R5),HL
WRBUFX	CALL	CHKBUF		;CALL	@CHKBUF		; Check if inp or out buffer full or above HWM
	RET			;RETS			; return

WOBUFX	LD	HL,(R13)	;MOVD	R13,R9		; R8:9 := R12:13 (out buffer write ptr)
	LD	(R9),HL
	JR	WRBUFX		;JMP	WRBUFX		; Check buffer and return

	; read from input or output buffer
RDBUF	BIT	2,(IX-10)	;BTJO	%>04,R10,RDOBUF	; R10.2 set ? jump if yes (output buffer)
	JR	NZ,RDOBUF

	; read from input buffer
	LD	HL,(R3)		;MOVD	R3,R13		; R12:13 := R2:3 input buffer read ptr
	LD	(R13),HL
	BIT	1,(IX-11)	;BTJO	%>02,R11,RDBUF1	; R11.1 set ? Jump if yes
	JR	NZ,RDBUF1
	INC	(IX-55)		;INC	R55		; inc R55 if not... (Free bytes? TODO: clarify)
	JR	RDBUF1		;JMP	RDBUF1		; Read byte

	; read from output buffer
RDOBUF	LD	HL,(R7)		;MOVD	R7,R13		; R12:13 := R6:7 out buffer read ptr
	LD	(R13),HL
	INC	(IX-54)		;INC	R54		; Inc R53:54 = Out free bytes? (TODO: clarify)
	JR	NZ,RDBUF1	;JNC	RDBUF1
	INC	(IX-53)		;INC	R53

	; Read byte from buffer
RDBUF1	LD	HL,(R13)	;LDA	*R13		; Read byte
	LD	A,(HL)
	BIT	2,(IX-10)	;BTJO	%>04,R10,LF2F3	; R10.2 set ? jump if yes (out buffer)
	JR	NZ,LF2F3

	BIT	7,A		;BTJZ	%>80,A,LF2F0	; Is high bit set ? Jump if not
	JR	Z,LF2F0
	SET	0,(IX-10)	;OR	%>01,R10	; R10.0 := A.7 = char high bit
	JR	LF2F3		;JMP	LF2F3

LF2F0	RES	0,(IX-10)	;AND	%>FE,R10

	; Incr buffer read pointer
LF2F3	PUSH	AF		;PUSH	A
	LD	HL,000DH	;LDA	@>000D		; A := R13 (why?)
	LD	A,(HL)
	LD	C,A		;ADD	%>01,R13	; increment R12:13
	LD	A,(R13)
	ADD	A,01H
	LD	(R13),A
	LD	A,(R12)		;ADC	%>00,R12
	ADC	A,00H
	LD	(R12),A
	LD	A,C
	CALL	ROLR13		;CALL	@ROLR13		; Roll if needed
	BIT	2,(IX-10)	;BTJO	%>04,R10,ROBUFX	; jump if output buffer
	JR	NZ,ROBUFX

	; update input buffer read ptr
	LD	HL,(R13)	;MOVD	R13,R3		; R2:3 := R12:13
	LD	(R3),HL
	POP	AF		;POP	A		; restore character
	RET			;RETS			; return

	; update output buffer read ptr
ROBUFX	LD	HL,(R13)	;MOVD	R13,R7		; R6:7 := R12:13
	LD	(R7),HL
	CALL	CKOBUF		;CALL	@CKOBUF		; Check if output buffer full or above HWM
	POP	AF		;POP	A		; restore allophone
	RET			;RETS

;==============================================================================

	; Roll R12:R13 according to active buffer (R10.2)
	; - if R10.2 set (output buffer active):
	;	to R42:43 (out buffer start) if reached R38:39 (out buffer end)
	; - if R10.2 not set (input buffer active):
	;	to R40:41 (in buffer start)  if reached R42:43 (in buffer end)
ROLR13	BIT	2,(IX-10)	;BTJO	%>04,R10,ROLOUT	; Roll output buffer
	JR	NZ,ROLOUT
	; Roll input buffer
ROLINP	LD	C,A		;CMP	R43,R13
	LD	A,(R13)
	CP	(IX-43)
	LD	A,C
	JR	NZ,LF322	;JNZ	LF322
	LD	C,A		;CMP	R42,R12
	LD	A,(R12)
	CP	(IX-42)
	LD	A,C
	JR	NZ,LF322	;JNZ	LF322
	LD	HL,(R41)	;MOVD	R41,R13
	LD	(R13),HL
LF322	RET			;RETS

	; Roll output buffer
ROLOUT	LD	C,A		;CMP	R39,R13
	LD	A,(R13)
	CP	(IX-39)
	LD	A,C
	JR	NZ,LF330	;JNZ	LF330
	LD	C,A		;CMP	R38,R12
	LD	A,(R12)
	CP	(IX-38)
	LD	A,C
	JR	NZ,LF330	;JNZ	LF330
	LD	HL,(R43)	;MOVD	R43,R13
	LD	(R13),HL
LF330	RET			;RETS

;==============================================================================

	; Check if inp or out buffer full or above HWM
CHKBUF	BIT	2,(IX-10)	;BTJZ	%>04,R10,CKIBUF	; Send XON/XOFF if needed
	JR	Z,CKIBUF

	; Check if output buffer full or above high water mark
CKOBUF	LD	C,A		;CMP	%>01,R53	; Only 1 free byte in output buffer ?
	LD	A,(R53)
	CP	01H
	LD	A,C
	JR	Z,LF343		;JZ	LF343		; jump if yes
	LD	C,A		;CMP	R50,R54		; R54>R50 ? (output counter >= HWM ?)
	LD	A,(R54)
	CP	(IX-50)
	LD	A,C
	JP	P,LF343		;JP	LF343		; jump if yes
	SET	3,(IX-11)	;OR	%>08,R11	; set R11.3 (output buffer full)
	RET			;RETS

LF343	RES	3,(IX-11)	;AND	%>F7,R11	; reset R11.3 (output buffer not full)
	RET			;RETS

	; Check if input buffer full or above high water mark
CKIBUF	LD	C,A		;CMP	%>00,R51	; Free bytes in input buffer ?
	LD	A,(R51)
	CP	00H
	LD	A,C
	JP	P,LF356		;JP	LF356		; jump if yes
	LD	C,A		;CMP	%>01,R52
	LD	A,(R52)
	CP	01H
	LD	A,C
	JP	P,LF356		;JP	LF356
	SET	5,(IX-11)	;OR	%>20,R11	; set R11.5 (input buffer full)
	JR	TXOFF		;JMP	TXOFF		; Send XOFF, clear DTR/BUSY*

	; Input buffer not full
LF356	LD	C,A		;CMP	R30,R51		; R50:51 inp buf free bytes < 1/2 size ?
	LD	A,(R51)
	CP	(IX-30)
	LD	A,C
	JP	M,LF362		;JN	LF362		; Jump if yes
	JP	P,TXON		;JP	TXON		; Else send XON, set DTR/BUSY*
	LD	C,A		;CMP	R31,R52
	LD	A,(R52)
	CP	(IX-31)
	LD	A,C
	JP	P,TXON		;JPZ	TXON
LF362	LD	C,A		;CMP	R32,R51		; R50:51 inp buf free bytes < 1/8 size ?
	LD	A,(R51)
	CP	(IX-32)
	LD	A,C
	JP	P,LF384		;JP	LF384		; Jump if not
	JP	M,LF36E		;JN	LF36E		; Else Send XOFF, clear DTR/BUSY*
	LD	C,A		;CMP	R33,R52
	LD	A,(R52)
	CP	(IX-33)
	LD	A,C
	JP	P,LF384		;JP	LF384

LF36E	SET	2,(IX-11)	;OR	%>04,R11	; set R11.2: input buffer above HWM

	; Send XOFF, clear DTR/BUSY*
TXOFF	LD	C,A		;ANDP	%>FE,P6		; clear P6.0 (DSR/BUSY=true)
	LD	A,(P6)
	AND	0FEH
	LD	(P6),A
	LD	A,C
	LD	C,A		;MOVP	%>13,P23	; TXBUF := XOFF
	LD	A,13H
	LD	(P23),A
	LD	A,C
	RET			;RETS

	; Send XON, set DTR/BUSY*
TXON	LD	C,A		;AND	%>DB,R11
	LD	A,(R11)
	AND	0DBH
	LD	(R11),A
	LD	A,C
	CALL	ENINT		;CALL	@ENINT		; R10:7 = parallel mode ? (enable INT3) : (enable INT4)
	LD	C,A		;ORP	%>01,P6		; set P6.0 (DSR/BUSY=false)
	LD	A,(P6)
	OR	01H
	LD	(P6),A
	LD	A,11H		;MOVP	%>11,P23	; TXBUF := XON
	LD	(P23),A
	LD	A,C
LF384	RET			;RETS			; Return

;==============================================================================

	; INT1 handler (SP0256)
INT1	LD	C,A		;ANDP	%>FE,P0		; Disable P0.0 = INT1*
	LD	A,(P0)
	AND	0FEH
	LD	(P0),A
	LD	A,C
	PUSH	AF		;PUSH	A		; save regs
	PUSH	BC		;PUSH	B
	LD	D,(IX-10)	;PUSH	R10
	PUSH	DE
	LD	D,(IX-12)	;PUSH	R12
	PUSH	DE
	LD	D,(IX-13)	;PUSH	R13
	PUSH	DE
	LD	C,A		;OR	%>06,R10	; select "read from output buffer"
	LD	A,(R10)
	OR	06H
	LD	(R10),A
	LD	A,C
	CALL	RWBUFR		;CALL	@RWBUFR		; do the read
	LD	HL,(R45)	;MOVD	R45,R27		; R26:27:= R44:45 SP0256 base address
	LD	(R27),HL
	LD	C,A		;ADD	R0,R27		; Add allophone code to the address
	LD	A,(R27)
	ADD	A,C
	LD	(R27),A
	LD	A,C
	LD	HL,(R27)	;STA	*R27		; Write any byte to that address (value doesn't care)
	LD	(HL),A
	POP	DE		;POP	R13		; restore regs
	LD	(IX-13),D
	POP	DE		;POP	R12
	LD	(IX-12),D
	POP	DE		;POP	R10
	LD	(IX-10),D
	POP	BC		;POP	B
	POP	AF		;POP	A
	LD	C,A		;CMP	R7,R9		; Buffer empty ?
	LD	A,(R9)
	CP	(IX-7)
	LD	A,C
	JR	Z,LF3AE		;JZ	LF3AE		; skip if yes
	LD	C,A		;ORP	%>01,P0		; else enable P0.0 = INT1*
	LD	A,(P0)
	OR	01H
	LD	(P0),A
	LD	A,C
LF3AE	RET			;RETI			; return from interrupt

;==============================================================================

	; select rules set
SELRUL	CP	30H		;CMP	%>30,A
	JP	P,LF3B5		;JPZ	LF3B5
	JR	LF3DF		;JMP	LF3DF		; < '0' => rules for punctuation

LF3B5	CP	3AH		;CMP	%>3A,A
	JP	P,LF3C1		;JPZ	LF3C1
	LD	HL,RULNUM	;MOVD	%RULNUM,R21	; Rules for digits
	LD	(R21),HL
	RES	5,(IX-10)	;AND	%>DF,R10	; Non-letters rules
	RET			;RETS

LF3C1	CP	41H		;CMP	%>41,A
	JP	P,LF3C7		;JPZ	LF3C7
	JR	LF3DF		;JMP	LF3DF

LF3C7	CP	5BH		;CMP	%>5B,A
	JP	P,LF3CF		;JPZ	LF3CF
	SET	5,(IX-10)	;OR	%>20,R10	; Letters rules
	RET			;RETS

LF3CF	CP	61H		;CMP	%>61,A
	JP	P,LF3D5		;JPZ	LF3D5
	JR	LF3DF		;JMP	LF3DF

LF3D5	CP	7BH		;CMP	%>7B,A
	JP	P,LF3DF		;JPZ	LF3DF
	SUB	20H		;SUB	%>20,A
	SET	5,(IX-10)	;OR	%>20,R10	; Letters rules
	RET			;RETS

LF3DF	RES	5,(IX-10)	;AND	%>DF,R10	; Non-letters rules
	LD	HL,RLPNCT	;MOVD	%RLPNCT,R21	; Rules for punctuation
	LD	(R21),HL
	RET			;RETS

;==============================================================================

	; Encode text to allophones
ENCODE	LD	C,A		;CMP	%>00,R48	; EPROM active ?
	LD	A,(R48)
	CP	00H
	LD	A,C
	; Skip if not
	JR	Z,LF3EE		;JZ	LF3EE
	LD	HL,(R49)	;BR	*R49		; Jump in EPROM
	JP	(HL)

LF3EE	LD	HL,(R3)		;MOVD	R3,R17		; R16:17 := R2:3 (backward input buffer read ptr)
	LD	(R17),HL
	CALL	DECR17		;CALL	@DECR17		; dec R16:17 and roll if needed
LF3F4	CALL	FETCH		;CALL	@FETCH		; Fetch char and mask high bit
	BIT	0,(IX-10)	;BTJZ	%>01,R10,LF400	; R11.7 := R10.0 (character high bit)
	JR	Z,LF400
	SET	7,(IX-11)	;OR	%>80,R11
	JR	LF403		;JMP	LF403

LF400	RES	7,(IX-11)	;AND	%>7F,R11
LF403	CALL	SELRUL		;CALL	@SELRUL		; select rules set
	BIT	5,(IX-10)	;BTJZ	%>20,R10,LF41B	; R10.5 set (rules for letters) ? jump if no
	JR	Z,LF41B

	LD	B,0		;CLR	B		; useful?
	SUB	41H		;SUB	%>41,A		; A -= 'A'
	MUL	02H		;MPY	%>02,A		; AB := A * 2
	LD	C,A		;ADD	%>02,B		; B += 2
	LD	A,B
	ADD	A,02H
	LD	B,A
	LD	A,C
	LD	HL,TABRUL	;LDA	@TABRUL(B)	; Index of rules tables
	LD	E,B
	LD	D,0
	ADD	HL,DE
	LD	A,(HL)
	LD	(R20),A		;MOV	A,R20		; R20 := MSB of letter rules table
	LD	HL,TABRU1	;LDA	@TABRU1(B)	; Index of rules tables LSB
	LD	E,B
	LD	D,0
	ADD	HL,DE
	LD	A,(HL)
	LD	(R21),A		;MOV	A,R21		; R21 := LSB of letter rules table

LF41B	LD	B,01H		;MOV	%>01,B		; B := 1 (number of '[') to seek
	CALL	RSEEKB		;CALL	@RSEEKB		; right seek 1st '['

	; Compare chars between [ ]
LF420	CALL	CMPBKT		;CALL	@CMPBKT		; compare in-brackets
	BIT	4,(IX-10)	;BTJO	%>10,R10,LF467	; R10.4 set (match failed) ? Jump if yes
	JR	NZ,LF467

	; Check patterns after ]
	LD	HL,(R17)	;MOVD	R17,R29		; R28:29 := R16:17 (save backward input buffer read ptr)
	LD	(R29),HL
	LD	C,A		;AND	%>BF,R10	; clear R10.6 (read input using R2:3)
	LD	A,(R10)
	AND	0BFH
	LD	(R10),A
	LD	A,C
	CALL	CHKPAT		;CALL	@CHKPAT		; Check rule pattern
	BIT	4,(IX-10)	;BTJO	%>10,R10,LF467	; R10.4 set (match failed) ? Jump if yes
	JR	NZ,LF467

	; Check patterns before [
	CALL	LSEEKB		;CALL	@LSEEKB		; left seek '['
	SET	6,(IX-10)	;OR	%>40,R10	; set R10.6 (read input using R16:17)
	CALL	CHKPAT		;CALL	@CHKPAT		; Check rule pattern
	BIT	4,(IX-10)	;BTJO	%>10,R10,LF47A	; R10.4 set (match failed) ? Jump if yes
	JR	NZ,LF47A

	; Matching Rule found
	LD	C,A		;ADD	R55,R52		; R51:52 += R55 (free preceding chars?)
	LD	A,(R52)
	ADD	A,(IX-55)
	LD	(R52),A
	LD	A,(R51)		;ADC	%>00,R51
	ADC	A,00H
	LD	(R51),A
	LD	A,C
	LD	(IX-55),0	;CLR	R55		; no more chars to free

	; Seek allophones to output
	RES	1,(IX-11)	;AND	%>FD,R11	; clear R11.1 (allow to count chars to free in R55)
	LD	B,02H		;MOV	%>02,B		; B := 2 (number of '[') to seek
	CALL	RSEEKB		;CALL	@RSEEKB		; right seek 2nd '[' => 1st allophone

	; Write allophones
	CALL	WRALLO		;CALL	@WRALLO		; Write allophones

	; Next input character
	LD	HL,(R15)	;MOVD	R15,R3		; R2:3 := R14:15 - restore input buffer read ptr
	LD	(R3),HL
	LD	HL,(R3)		;MOVD	R3,R17		; R16:17 := R2:3 - copy to backward input buffer read ptr
	LD	(R17),HL
	CALL	DECR17		;CALL	@DECR17		; dec R16:17 and roll to R36:37 if == R34:35
	BIT	7,(IX-11)	;BTJZ	%>80,R11,LF3F4	; High bit of char was set (final?) ? Jump if not
	JR	Z,LF3F4

	; Finalize and return
	LD	HL,(R57)	;DECD	R57		; dec R56:57 (number of bytes in input buffer?)
	DEC	HL
	LD	(R57),HL
	CALL	CKIBUF		;CALL	@CKIBUF		; Check if input buffer full or above high water mark
	RET			;RETS			; return

	; Match failed after opening [ => seek next rule
LF467	INC	(IX-21)		;INC	R21		; inc R20:21 rule pointer
	JR	NZ,LF46D	;JNC	LF46D
	INC	(IX-20)		;INC	R20
LF46D	LD	B,02H		;MOV	%>02,B		; B := 2 (number of '[') to seek

	; Seek next rule opening [
LF46F	CALL	RSEEKB		;CALL	@RSEEKB		; right seek 2nd or 3rd '[' => next pattern '['
	LD	(IX-55),01H	;MOV	%>01,R55	; R55 := 1 (one char to free?)
	RES	1,(IX-11)	;AND	%>FD,R11	; clear R11.1 (allow to count chars to free in R55)
	JR	LF420		;JMP	LF420		; check next rule

	; Match failed before opening [ => seek next rule
LF47A	LD	B,03H		;MOV	%>03,B		; B := 3 (number of '[') to seek
	JR	LF46F		;JMP	LF46F		; right seek 3rd '[' and check next rule

;==============================================================================

	; left seek '['
LSEEKB	LD	HL,(R21)	;LDA	*R21		; A := *R20:21
	LD	A,(HL)
	BIT	6,A		;BTJZ	%>40,A,LF484	; A.6 set ('[' found) ? jump if not
	JR	Z,LF484
	RET			;RETS			; else return

LF484	LD	HL,(R21)	;DECD	R21		; dec R20:21
	DEC	HL
	LD	(R21),HL
	JR	LSEEKB		;JMP	LSEEKB		; and loop

;==============================================================================

	; right seek Bth '['
RSEEKB	LD	(IX-23),0	;CLR	R23		; R23 := 0

LF48A	LD	HL,(R21)	;LDA	*R21		; A := *R20:21
	LD	A,(HL)
	BIT	6,A		;BTJZ	%>40,A,LF496	; A.6 set ('[' found) ? jump if not
	JR	Z,LF496
	INC	(IX-23)		;INC	R23		; inc R23
	LD	C,A		;CMP	R23,B		; jump if R23 != B
	LD	A,B
	CP	(IX-23)
	LD	A,C
	JR	NZ,LF496	;JNZ	LF496
	RET			;RETS			; else return: found

LF496	INC	(IX-21)		;INC	R21		; inc R20:21
	JR	NZ,LF49C	;JNC	LF49C
	INC	(IX-20)		;INC	R20
LF49C	JR	LF48A		;JMP	LF48A		; and loop

;==============================================================================

	; Write allophones
WRALLO	LD	(IX-23),0	;CLR	R23		; R23 := 0
	LD	HL,(R21)	;LDA	*R21		; A := *R20:21
	LD	A,(HL)
	CP	0FFH		;CMP	%>FF,A		; A == $FF ?
	JR	Z,LF4C1		;JZ	LF4C1		; jump if yes
	BIT	7,A		;BTJZ	%>80,A,LF4AB	; A.7 set (']' found) ? jump if not
	JR	Z,LF4AB
	INC	(IX-23)		;INC	R23		; else inc R23
LF4AB	AND	3FH		;AND	%>3F,A		; mask A.6 and A.7
	RES	1,(IX-10)	;AND	%>FD,R10	; clear R10.1 (write in buffer)
	SET	2,(IX-10)	;OR	%>04,R10	; set R10.2 (output buffer)
	CALL	RWBUFR		;CALL	@RWBUFR		; write allophone in buffer
	INC	(IX-21)		;INC	R21		; inc R20:21
	JR	NZ,LF4BC	;JNC	LF4BC
	INC	(IX-20)		;INC	R20
LF4BC	LD	C,A		;CMP	%>01,R23	; ']' found ?
	LD	A,(R23)
	CP	01H
	LD	A,C
	JR	NZ,WRALLO	;JNZ	WRALLO		; loop if not
LF4C1	RET			;RETS			; else return

;==============================================================================

	; compare in-brackets
CMPBKT	LD	HL,(R3)		;MOVD	R3,R19		; R18:19 := R2:3 (input read ptr)
	LD	(R19),HL
	RES	3,(IX-10)	;AND	%>F7,R10	; clear R10.3
	BIT	5,(IX-10)	;BTJZ	%>20,R10,LF4D4	; R10.5 letter rules? jump if not
	JR	Z,LF4D4
	LD	HL,(R21)	;LDA	*R21		; A := *R20:21
	LD	A,(HL)
	CP	0FFH		;CMP	%>FF,A		; A == $FF ? (single letter/end of rules)
	JR	NZ,LF4DD	;JNZ	LF4DD		; jump if not to letter rules
	JR	LF502		;JMP	LF502		; else exit (success)

	; not letter rules
LF4D4	CP	0FFH		;CMP	%>FF,A		; A == $FF ?
	JR	Z,LF502		;JZ	LF502		; exit if yes (success)
	CALL	DECR3		;CALL	@DECR3		; dec R2:3 and roll if needed
	DEC	(IX-55)		;DEC	R55		; dec R55 (chars to free?)

	; letter rules
LF4DD	CALL	FETCH		;CALL	@FETCH		; Fetch char and mask high bit
	CP	61H		;CMP	%>61,A		; lower case ?
	JP	M,LF4E6		;JN	LF4E6		; skip if not
	SUB	20H		;SUB	%>20,A		; else adjust to upper case
LF4E6	SUB	20H		;SUB	%>20,A		; adjust to range 00-3F
	LD	B,A		;MOV	A,B		; B := A
	LD	HL,(R21)	;LDA	*R21		; A := *R20:21
	LD	A,(HL)
	BIT	7,A		;BTJZ	%>80,A,LF4F1	; A.7 set (']' found) ? Skip if not
	JR	Z,LF4F1
	SET	3,(IX-10)	;OR	%>08,R10	; else set R10.3
LF4F1	AND	3FH		;AND	%>3F,A		; mask A.6 and A.7
	LD	C,A		;CMP	R0,B		; A == B ?
	LD	A,B
	CP	C
	LD	A,C
	JR	Z,LF4FE		;JZ	LF4FE		; jump if yes
	SET	4,(IX-10)	;OR	%>10,R10	; set R10.4: pattern match failed
	LD	HL,(R19)	;MOVD	R19,R3		; R2:3 := R18:19
	LD	(R3),HL
	RET			;RETS			; return (failed)

LF4FE	BIT	3,(IX-10)	;BTJZ	%>08,R10,LF50C	; R10.3 set (']' found) ? Jump if not
	JR	Z,LF50C

	; pattern match successful
LF502	LD	HL,(R3)		;MOVD	R3,R15		; R14:15 := R2:3 - save input buffer read ptr
	LD	(R15),HL
	RES	4,(IX-10)	;AND	%>EF,R10	; clear R10.4: pattern match successful
	SET	1,(IX-11)	;OR	%>02,R11	; set R11.1 - forbid to count chars to free in R55 ?
	RET			;RETS			; return

LF50C	INC	(IX-21)		;INC	R21		; inc R20:21
	JR	NZ,LF4DD	;JNC	LF4DD
	INC	(IX-20)		;INC	R20
	JR	LF4DD		;JMP	LF4DD		; and loop: check next char

;==============================================================================

	; Get letter flags
GFLAGS	LD	B,(IX-22)	;MOV	R22,B
	LD	C,A		;CMP	%>3A,B
	LD	A,B
	CP	3AH
	LD	A,C
	JP	P,GFLAGX	;JP	GFLAGX
	LD	C,A		;CMP	%>21,B
	LD	A,B
	CP	21H
	LD	A,C
	JP	M,GFLAGX	;JN	GFLAGX
	LD	C,A		;SUB	%>21,B
	LD	A,B
	SUB	21H
	LD	B,A
	LD	A,C
	LD	HL,LTFLGS	;LDA	@LTFLGS(B)	; Letter flags
	LD	E,B
	LD	D,0
	ADD	HL,DE
	LD	A,(HL)
	RET			;RETS

GFLAGX	LD	A,0		;CLR	A
	RET			;RETS

	; Letter flags
	; ------------
	; 7(80): Vowel
	; 6(40): Voiced consonant
	; 5(20): Sibilant
	; 4(10): Preceding long U
	; 3(08): Consonant
	; 2(04): Front vowel
	; 1(02): Back vowel
	; 0(01): Suffix ('E')
LTFLGS	DB	080H		; A 1000 0000 - EPROM sig check begin
	DB	048H		; B 0100 1000
	DB	028H		; C 0010 1000
	DB	058H		; D 0101 1000
	DB	085H		; E 1000 0101 - EPROM sig check end
	DB	008H		; F 0000 1000
	DB	068H		; G 0110 1000
	DB	008H		; H 0000 1000
	DB	084H		; I 1000 0100
	DB	078H		; J 0111 1000
	DB	008H		; K 0000 1000
	DB	058H		; L 0101 1000
	DB	048H		; M 0100 1000
	DB	058H		; N 0101 1000
	DB	082H		; O 1000 0010
	DB	008H		; P 0000 1000
	DB	008H		; Q 0000 1000
	DB	058H		; R 0101 1000
	DB	038H		; S 0011 1000
	DB	018H		; T 0001 1000
	DB	082H		; U 1000 0010
	DB	048H		; V 0100 1000
	DB	048H		; W 0100 1000
	DB	028H		; X 0010 1000
	DB	084H		; Y 1000 0100
	DB	078H		; Z 0111 1000

;==============================================================================

	; Pattern jump table
PATBRT	JP	PATVOW		;BR	@PATVOW		; #	09	1+ vowels

	JP	PATVOC		;BR	@PATVOC		; .	0A	voiced consonant: B D G J L M N R V W X

	JP	PATSUF		;BR	@PATSUF		; %	0B	suffix: -ER(S) -E -ES -ED -ELY -ING -OR -MENT

	JP	PATSIB		;BR	@PATSIB		; &	0C	sibilant: S C G Z X J CH SH

	JP	PATPLU		;BR	@PATPLU		; @	0D	T S R D L Z N J TH CH SH preceding long U

	JP	PAT1CO		;BR	@PAT1CO		; ^	0E	1 consonant only

	JP	PATFVO		;BR	@PATFVO		; +	0F	front vowel: E I Y

	JP	PAT0MC		;BR	@PAT0MC		; :	10	0+ consonants

	JP	PAT1MC		;BR	@PAT1MC		; *	11	1+ consonants

	JP	PATBVO		;BR	@PATBVO		; >	12	back vowel: O U

	JP	PATNLT		;BR	@PATNLT		; <	13	Anything other than a letter

	JP	PAT2MV		;BR	@PAT2MV		; ?	14	2+ vowels

;==============================================================================

	; Check rule pattern
CHKPAT	BIT	6,(IX-10)	;BTJO	%>40,R10,LF572	; R10.6 set (scan direction left) ? jump if yes
	JR	NZ,LF572
	LD	B,40H		;MOV	%>40,B		; '[' mask
	INC	(IX-21)		;INC	R21		; inc R20:21 rule ptr
	JR	NZ,LF570	;JNC	LF570
	INC	(IX-20)		;INC	R20
LF570	JR	LF576		;JMP	LF576		; proceed

LF572	LD	B,80H		;MOV	%>80,B		; ']' mask
	LD	HL,(R21)	;DECD	R21		; dec R20:21 rule ptr
	DEC	HL
	LD	(R21),HL

	; check if boundary has been reached
LF576	LD	HL,(R21)	;LDA	*R21		; get rule char
	LD	A,(HL)
	LD	C,A		;BTJZ	B,A,LF58C	; is '[' or ']' ? jump if not
	CPL	
	AND	B
	LD	A,C
	JR	NZ,LF58C
	BIT	6,(IX-10)	;BTJO	%>40,R10,LF582	; R10.6 set (scan direction left) ? jump if yes
	JR	NZ,LF582
	LD	HL,(R21)	;DECD	R21		; dec R20:21 rule ptr
	DEC	HL
	LD	(R21),HL
	JR	LF588		;JMP	LF588

LF582	INC	(IX-21)		;INC	R21		; inc R20:21 rule ptr
	JR	NZ,LF588	;JNC	LF588
	INC	(IX-20)		;INC	R20
LF588	RES	4,(IX-10)	;AND	%>EF,R10	; clear R10.4 rule pattern match failed
	RET			;RETS			; return

	; check rule char
LF58C	CALL	GNEXT		;CALL	@GNEXT		; get next input char and move code to range 00-3F
	LD	HL,(R21)	;LDA	*R21		; A := *R20:21 - load rule char
	LD	A,(HL)
	CP	15H		;CMP	%>15,A		; A < $15 ? (pattern symbol)
	JP	M,LF5A4		;JN	LF5A4		; jump if yes
LF595	LD	C,A		;CMP	R0,R22		; otherwise compare input char with rule char
	LD	A,(R22)
	CP	C
	LD	A,C
	JR	Z,CHKPAT	;JZ	CHKPAT		; continue with next char if both chars match

	; pattern match failed
PATFLD	SET	4,(IX-10)	;OR	%>10,R10	; set R10.4 - match failed
	LD	HL,(R19)	;MOVD	R19,R3		; R2:3 := R18:19 - restore input ptr
	LD	(R3),HL
	LD	HL,(R29)	;MOVD	R29,R17		; R16:17 := R28:29 - restore backward input ptr
	LD	(R17),HL
	RET			;RETS			; return (failed)

	; check rule pattern symbol
LF5A4	CP	07H		;CMP	%>07,A		; is a "'" ?
	JR	Z,LF595		;JZ	LF595		; jump if yes
	; compute pattern symbol handler address
	LD	B,A		;MOV	A,B		; B := A
	LD	C,A		;SUB	%>09,B		; B -= 9
	LD	A,B
	SUB	09H
	LD	B,A
	LD	A,B		;MPY	%>03,B		; B *= 3
	MUL	A,03H
	LD	B,A
	LD	A,C
	LD	HL,PATBRT	;BR	@PATBRT(B)	; Branch to PATBRT + B
	LD	E,B
	LD	D,0
	ADD	HL,DE
	JP	(HL)

	; <	13	Anything other than a letter
PATNLT	CALL	GFLAGS		;CALL	@GFLAGS		; Get letter flags
	CP	00H		;CMP	%>00,A		; Is a letter ?
	JR	Z,PATOK1	;JZ	PATOK1		; Accept if yes
	JR	PATFLD		;JMP	PATFLD		; else pattern match failed

	; *	11	1+ consonants
PAT1MC	CALL	GFLAGS		;CALL	@GFLAGS		; Get letter flags
	BIT	3,A		;BTJO	%>08,A,LF5C1	; Is a consonant ? Jump if yes
	JR	NZ,LF5C1
	JR	PATFLD		;JMP	PATFLD		; else pattern match failed

LF5C1	CALL	GNEXT		;CALL	@GNEXT		; get next char and move code to range 00-3F
	CALL	GFLAGS		;CALL	@GFLAGS		; Get letter flags
	BIT	3,A		;BTJO	%>08,A,LF5C1	; Is a consonant ? Loop until not
	JR	NZ,LF5C1
	JR	LF5FB		;JMP	LF5FB		; Unget and Accept rule

	; ?	14	2+ vowels
PAT2MV	CALL	GFLAGS		;CALL	@GFLAGS		; Get letter flags
	BIT	7,A		;BTJO	%>80,A,LF5D4	; Vowel flag ? Jump if yes
	JR	NZ,LF5D4
	JR	PATFLD		;JMP	PATFLD		; pattern match failed

LF5D4	CALL	GNEXT		;CALL	@GNEXT		; get next char and move code to range 00-3F
	CALL	GFLAGS		;CALL	@GFLAGS		; Get letter flags
	BIT	7,A		;BTJO	%>80,A,LF5DF	; Vowel flag ? Jump if yes
	JR	NZ,LF5DF
	JR	PATFLD		;JMP	PATFLD		; pattern match failed

LF5DF	CALL	GNEXT		;CALL	@GNEXT		; get next char and move code to range 00-3F
	CALL	GFLAGS		;CALL	@GFLAGS		; Get letter flags
	BIT	7,A		;BTJO	%>80,A,LF5DF	; Vowel flag ? Loop until not
	JR	NZ,LF5DF
	JR	LF5FB		;JMP	LF5FB		; Unget and accept rule

	; :	10	0+ consonants
PAT0MC	CALL	GFLAGS		;CALL	@GFLAGS		; Get letter flags
	BIT	3,A		;BTJO	%>08,A,LF5F2	; Consonant ? Jump if yes
	JR	NZ,LF5F2
	JR	LF5FB		;JMP	LF5FB		; else unget and accept rule

LF5F2	CALL	GNEXT		;CALL	@GNEXT		; get next char and move code to range 00-3F
	CALL	GFLAGS		;CALL	@GFLAGS		; Get letter flags
	BIT	3,A		;BTJO	%>08,A,LF5F2	; Is a consonant ? Loop until not
	JR	NZ,LF5F2

	; Unget and accept rule
LF5FB	CALL	UNGET		;CALL	@UNGET		; Unget last input character

	; pattern match ok
PATOK1	JP	CHKPAT		;BR	@CHKPAT		; Check next rule pattern

	; %	0B	suffix: -ER(S) -E -ES -ED -ELY -ING -OR -MENT
PATSUF	CALL	GFLAGS		;CALL	@GFLAGS		; Get letter flags
	BIT	0,A		;BTJO	%>01,A,LF657	; Suffix flag ('E') ? Jump if yes
	JR	NZ,LF657
	LD	C,A		;CMP	%>29,R22	; 'I' ?
	LD	A,(R22)
	CP	29H
	LD	A,C
	JR	Z,LF63C		;JZ	LF63C		; Jump if yes
	LD	C,A		;CMP	%>2D,R22	; 'M' ?
	LD	A,(R22)
	CP	2DH
	LD	A,C
	JR	Z,LF618		;JZ	LF618		; Jump if yes
	LD	C,A		;CMP	%>2F,R22	; 'O' ?
	LD	A,(R22)
	CP	2FH
	LD	A,C
	JR	Z,LF633		;JZ	LF633		; jump if yes
	JR	PATFL1		;JMP	PATFL1		; pattern match failed

	; found 'M'
LF618	CALL	FETCH		;CALL	@FETCH		; Fetch char and mask high bit
	CP	45H		;CMP	%>45,A		; 'E' ?
	JR	Z,LF621		;JZ	LF621		; jump if yes
	JR	PATFL1		;JMP	PATFL1		; pattern match failed

	; found 'ME'
LF621	CALL	FETCH		;CALL	@FETCH		; Fetch char and mask high bit
	CP	4EH		;CMP	%>4E,A		; 'N' ?
	JR	Z,LF62A		;JZ	LF62A		; jump if yes
	JR	PATFL1		;JMP	PATFL1		; pattern match failed

	; found 'MEN'
LF62A	CALL	FETCH		;CALL	@FETCH		; Fetch char and mask high bit
	CP	54H		;CMP	%>54,A		; 'T'
	JR	Z,LF64E		;JZ	LF64E		; jump if yes, suffix -MENT found
	JR	PATFL1		;JMP	PATFL1		; pattern match failed

	; Found 'O'
LF633	CALL	FETCH		;CALL	@FETCH		; Fetch char and mask high bit
	CP	52H		;CMP	%>52,A		; 'R' ?
	JR	Z,LF64E		;JZ	LF64E		; jump if yes, suffix -OR found
	JR	PATFL1		;JMP	PATFL1		; pattern match failed

	; Found 'I'
LF63C	CALL	FETCH		;CALL	@FETCH		; Fetch char and mask high bit
	CP	4EH		;CMP	%>4E,A		; 'N' ?
	JR	Z,LF645		;JZ	LF645		; jump if yes
	JR	PATFL1		;JMP	PATFL1		; pattern match failed

	; found 'IN'
LF645	CALL	FETCH		;CALL	@FETCH		; Fetch char and mask high bit
	CP	47H		;CMP	%>47,A		; 'G' ?
	JR	Z,LF64E		;JZ	LF64E		; jump if yes, suffix -ING found
	JR	PATFL1		;JMP	PATFL1		; pattern match failed

	; Suffix found
LF64E	CALL	CHKLTR		;CALL	@CHKLTR		; Check if next input char is a letter
	BIT	5,(IX-10)	;BTJO	%>20,R10,PATFL1	; pattern match failed
	JR	NZ,PATFL1
	JR	PATOK2		;JMP	PATOK2		; Accept rule

	; found 'E'
LF657	CALL	FETCH		;CALL	@FETCH		; Fetch char and mask high bit
	CP	52H		;CMP	%>52,A		; 'R' ?
	JR	NZ,LF66A	;JNZ	LF66A		; jump if not
	CALL	FETCH		;CALL	@FETCH		; Fetch char and mask high bit
	CP	53H		;CMP	%>53,A		; 'S' ? (optional plural)
	JR	Z,LF64E		;JZ	LF64E		; jump if yes, suffix -ERS found
	CALL	DECR3		;CALL	@DECR3		; dec R2:3 and roll if needed
	JR	LF64E		;JMP	LF64E		; suffix -ER found

LF66A	CP	53H		;CMP	%>53,A		; 'S'
	JR	Z,LF64E		;JZ	LF64E		; jump if yes, suffix -ES found
	CP	44H		;CMP	%>44,A		; 'D'
	JR	Z,LF64E		;JZ	LF64E		; jump if yes, suffix -ED found
	CP	4CH		;CMP	%>4C,A		; 'L'
	JR	Z,LF682		;JZ	LF682		; jump if yes
	CALL	DECR3		;CALL	@DECR3		; dec R2:3 and roll if needed
				; suffix -E found
	CALL	CHKLTR		;CALL	@CHKLTR		; Check if next input char is a letter
	BIT	5,(IX-10)	;BTJZ	%>20,R10,PATOK2	; Jump if R10.5 unset (not a letter => OK)
	JR	Z,PATOK2
	JR	PATFL1		;JMP	PATFL1		; pattern match failed

	; found 'EL'
LF682	CALL	FETCH		;CALL	@FETCH		; Fetch char and mask high bit
	CP	59H		;CMP	%>59,A		; 'Y' ?
	JR	Z,LF64E		;JZ	LF64E		; jump if yes, suffix -ELY found

	; pattern match failed
PATFL1	JP	PATFLD		;BR	@PATFLD		; pattern match failed

	; Test if next input char is a letter, R10.5=1 if yes
CHKLTR	CALL	FETCH		;CALL	@FETCH		; Fetch char and mask high bit
	LD	D,(IX-21)	;PUSH	R21		; save R20:21
	PUSH	DE
	LD	D,(IX-20)	;PUSH	R20
	PUSH	DE
	CALL	SELRUL		;CALL	@SELRUL		; select rules set, test if letter rule
	POP	DE		;POP	R20		; restore R20:21
	LD	(IX-20),D
	POP	DE		;POP	R21
	LD	(IX-21),D
	CALL	DECR3		;CALL	@DECR3		; dec R2:3 and roll if needed
	RET			;RETS			; return R10.5=1 if letter

	; #	09	1+ vowels
PATVOW	CALL	GFLAGS		;CALL	@GFLAGS		; Get letter flags
	BIT	7,A		;BTJO	%>80,A,LF6A6	; Vowel flag ? Jump if yes
	JR	NZ,LF6A6
	JR	PATFL1		;JMP	PATFL1		; pattern match failed

LF6A6	CALL	GNEXT		;CALL	@GNEXT		; get next char and move code to range 00-3F
	CALL	GFLAGS		;CALL	@GFLAGS		; Get letter flags
	BIT	7,A		;BTJO	%>80,A,LF6A6	; Vowel flag ? Loop until not
	JR	NZ,LF6A6
	CALL	UNGET		;CALL	@UNGET		; Unget input character
	JR	PATOK2		;JMP	PATOK2		; Accept rule

	; .	0A	voiced consonant: B D G J L M N R V W X
PATVOC	CALL	GFLAGS		;CALL	@GFLAGS		; Get letter flags
	BIT	6,A		;BTJO	%>40,A,PATOK2	; Voiced consonant flag ? Accept if yes
	JR	NZ,PATOK2
	JR	PATFL1		;JMP	PATFL1		; pattern match failed

PATOK2	JP	CHKPAT		;BR	@CHKPAT		; Check rule pattern

	; ^	0E	1 consonant only
PAT1CO	CALL	GFLAGS		;CALL	@GFLAGS		; Get letter flags
	BIT	3,A		;BTJO	%>08,A,PATOK2	; Consonant flag ? Accept if yes
	JR	NZ,PATOK2
	JR	PATFL1		;JMP	PATFL1		; pattern match failed

	; +	0F	front vowel: E I Y
PATFVO	CALL	GFLAGS		;CALL	@GFLAGS		; Get letter flags
	BIT	2,A		;BTJO	%>04,A,PATOK2	; Front vowel flag ? Accept if yes
	JR	NZ,PATOK2
	JR	PATFL1		;JMP	PATFL1		; pattern match failed

	; >	12	back vowel: O U
PATBVO	CALL	GFLAGS		;CALL	@GFLAGS		; Get letter flags
	BIT	1,A		;BTJO	%>02,A,PATOK2	; Back vowel flag ? Accept if yes
	JR	NZ,PATOK2
	JR	PATFL1		;JMP	PATFL1		; pattern match failed

	; &	0C	sibilant: S C G Z X J CH SH
PATSIB	CALL	GFLAGS		;CALL	@GFLAGS		; Get letter flags
	BIT	5,A		;BTJO	%>20,A,PATOK2	; Sibilant flag ? Accept if yes
	JR	NZ,PATOK2
	CALL	GNEXT		;CALL	@GNEXT		; get next char and move code to range 00-3F
	JR	LF6F0		;JMP	LF6F0

	; @	0D	T S R D L Z N J TH CH SH preceding long U
PATPLU	CALL	GFLAGS		;CALL	@GFLAGS		; Get letter flags
	BIT	4,A		;BTJO	%>10,A,PATOK2	; Letter influencing long U flag ? Accept if yes
	JR	NZ,PATOK2
				; (Could have checked for 'H' here...)
	CALL	GNEXT		;CALL	@GNEXT		; get next char and move code to range 00-3F
	LD	C,A		;CMP	%>34,R22	; 'T' ?
	LD	A,(R22)
	CP	34H
	LD	A,C
	JR	Z,LF6FC		;JZ	LF6FC		; jump if yes
LF6F0	LD	C,A		;CMP	%>23,R22	; 'C' ?
	LD	A,(R22)
	CP	23H
	LD	A,C
	JR	Z,LF6FC		;JZ	LF6FC		; jump if yes
	LD	C,A		;CMP	%>33,R22	; 'S' ?
	LD	A,(R22)
	CP	33H
	LD	A,C
	JR	Z,LF6FC		;JZ	LF6FC		; jump if yes
	JR	PATFL1		;JMP	PATFL1		; pattern match failed

	; check for TH, SH or SH
LF6FC	LD	HL,(R17)	;MOVD	R17,R3		; R2:3 := R16:17
	LD	(R3),HL
	CALL	INCR3		;CALL	@INCR3		; inc R2:3 and roll if needed
	CALL	INCR3		;CALL	@INCR3		; inc R2:3 and roll if needed
	CALL	FETCH		;CALL	@FETCH		; Fetch char and mask high bit
	CP	48H		;CMP	%>48,A		; 'H'
	JR	Z,PATOK2	;JZ	PATOK2		; Accept if yes
	JP	PATFLD		;BR	@PATFLD		; pattern match failed

;==============================================================================

	; Fetch char and mask high bit
FETCH	SET	1,(IX-10)	;OR	%>02,R10	; R10.1 = 1 - sel buffer read mode
	RES	2,(IX-10)	;AND	%>FB,R10	; R10.2 = 0 - sel input buffer
	CALL	RWBUFR		;CALL	@RWBUFR		; read in input buffer
	AND	7FH		;AND	%>7F,A		; mask high bit of char
	RET			;RETS			; return

;==============================================================================

	; inc R16:17 and roll if needed
INCR17	INC	(IX-17)		;INC	R17		; inc R16:17
	JR	NZ,LF721	;JNC	LF721
	INC	(IX-16)		;INC	R16
LF721	LD	HL,(R17)	;MOVD	R17,R13		; R12:13 := R16:17
	LD	(R13),HL
	CALL	ROLINP		;CALL	@ROLINP		; Roll input buffer R12:13
	LD	HL,(R13)	;MOVD	R13,R17		; R16:17 := R12:13
	LD	(R17),HL
	RET			;RETS

;==============================================================================

	; inc R2:3 and roll if needed
INCR3	INC	(IX-3)		;INC	R3		; inc R2:3
	JR	NZ,LF731	;JNC	LF731
	INC	(IX-2)		;INC	R2
LF731	LD	HL,(R3)		;MOVD	R3,R13		; R12:13 := R2:3
	LD	(R13),HL
	CALL	ROLINP		;CALL	@ROLINP		; Roll input buffer R12:13
	LD	HL,(R13)	;MOVD	R13,R3		; R2:3 := R12:13
	LD	(R3),HL
	RET			;RETS

;==============================================================================

	; dec R2:3 and roll if needed
DECR3	LD	HL,(R3)		;DECD	R3		; dec R2:3
	DEC	HL
	LD	(R3),HL
	LD	C,A		;CMP	R35,R3		; before input buffer start ?
	LD	A,(R3)
	CP	(IX-35)
	LD	A,C
	JR	NZ,LF74A	;JNZ	LF74A
	LD	C,A		;CMP	R34,R2
	LD	A,(R2)
	CP	(IX-34)
	LD	A,C
	JR	NZ,LF74A	;JNZ	LF74A		; jump if not
	LD	HL,(R37)	;MOVD	R37,R3		; roll to input buffer end
	LD	(R3),HL
LF74A	RET			;RETS			; return

;==============================================================================

	; dec R16:17 and roll if needed
DECR17	LD	HL,(R17)	;DECD	R17		; dec R16:17
	DEC	HL
	LD	(R17),HL
	LD	C,A		;CMP	R35,R17		; before input buffer start ?
	LD	A,(R17)
	CP	(IX-35)
	LD	A,C
	JR	NZ,LF75A	;JNZ	LF75A
	LD	C,A		;CMP	R34,R16
	LD	A,(R16)
	CP	(IX-34)
	LD	A,C
	JR	NZ,LF75A	;JNZ	LF75A		; jump if not
	LD	HL,(R37)	;MOVD	R37,R17		; roll to input buffer end
	LD	(R17),HL
LF75A	RET			;RETS			; return

;==============================================================================

	; get next char and move code to range 00-3F
GNEXT	BIT	6,(IX-10)	;BTJZ	%>40,R10,LF766	; R10.6 set ? jump if not
	JR	Z,LF766
	LD	D,(IX-3)	;PUSH	R3		; else save R2:3
	PUSH	DE
	LD	D,(IX-2)	;PUSH	R2
	PUSH	DE
	LD	HL,(R17)	;MOVD	R17,R3		; and move R16:17 to R2:3
	LD	(R3),HL
LF766	CALL	FETCH		;CALL	@FETCH		; Fetch char and mask high bit
	BIT	6,(IX-10)	;BTJZ	%>40,R10,LF774	; R10.6 set ? jump if not
	JR	Z,LF774
	CALL	DECR17		;CALL	@DECR17		; else dec R16:17 and roll if needed
	POP	DE		;POP	R2		; and restore R2:3
	LD	(IX-2),D
	POP	DE		;POP	R3
	LD	(IX-3),D
LF774	CP	61H		;CMP	%>61,A		; lower case ?
	JP	M,LF77A		;JN	LF77A		; jump if not
	SUB	20H		;SUB	%>20,A		; change to upper case
LF77A	SUB	20H		;SUB	%>20,A		; shift to range 00-3F
	LD	(R22),A		;MOV	A,R22		; store in R22
	RET			;RETS			; return

;==============================================================================

	; Unget last input character
UNGET	BIT	6,(IX-10)	;BTJO	%>40,R10,LF787	; R10.6 set ? jump if yes
	JR	NZ,LF787
	CALL	DECR3		;CALL	@DECR3		; dec R2:3 (input buffer read ptr) and roll if needed
	RET			;RETS

LF787	CALL	INCR17		;CALL	@INCR17		; inc R16:17 (backward input buffer read ptr) and roll if needed
	RET			;RETS


;==============================================================================

	DB	0FFH		; boundary

	; Rules for punctuation
RLPNCT	DB	0CDH,0C0H,00AH,047H,0B3H,0EBH,009H,010H
	DB	00AH,025H,047H,0B3H,0EBH,009H,047H,0B3H
	DB	0EBH,047H,0B3H,0F7H,0C7H,0FFH,0CCH,0C3H
	DB	0DBH,0C3H,0C0H,0C1H,0CEH,044H,084H,0C1H
	DB	044H,084H,0DFH,044H,084H,0DAH,0C4H,0C5H
	DB	049H,034H,037H,037H,007H,00BH,00DH,080H
	DB	0C4H,061H,018H,02DH,033H,02BH,080H,0C3H
	DB	078H,00FH,010H,01CH,033H,080H,0FFH,0C2H
	; Rules for 'A'
RULESA	DB	013H,0FFH,013H,0D4H,063H,028H,0A5H,054H
	DB	002H,0A9H,0FFH,013H,0CFH,013H,072H,0A5H
	DB	013H,0FBH,00EH,0F3H,009H,054H,0B7H,013H
	DB	0F2H,02FH,04FH,0A7H,013H,0FFH,00EH,032H
	DB	0CFH,0F2H,009H,0EFH,013H,010H,06EH,0B9H
	DB	047H,00BH,093H,067H,021H,029H,0AEH,04FH
	DB	001H,024H,007H,007H,08BH,0FFH,037H,021H
	DB	0CFH,0F7H,057H,097H,013H,010H,0FFH,00EH
	DB	00FH,013H,0D4H,013H,0FFH,00EH,009H,0CFH
	DB	0FFH,00EH,00FH,009H,0D4H,009H,010H,06CH
	DB	02CH,0B9H,04FH,02DH,093H,013H,0ECH,009H
	DB	04FH,0ADH,009H,010H,0E7H,025H,04CH,001H
	DB	08AH,0FFH,00EH,00BH,0D4H,0FFH,00EH,00FH
	DB	010H,009H,0DAH,013H,072H,0B2H,04FH,0A7H
	DB	072H,0B2H,05AH,0A7H,013H,010H,0F2H,013H
	DB	0FBH,0F2H,013H,0F3H,0F2H,0FBH,069H,0B2H
	DB	047H,0AFH,0E9H,0D4H,0F9H,0D4H,0F5H,0D7H
	DB	009H,010H,0ECH,013H,0FEH,009H,010H,06CH
	DB	0B3H,013H,07EH,0ABH,06CH,0ABH,057H,002H
	DB	0A9H,0FFH,02CH,00EH,0D7H,013H,010H,062H
	DB	02CH,0A5H,054H,001H,03FH,0BEH,062H,02CH
	DB	0A5H,04FH,001H,03FH,0BEH,06EH,0A7H,00FH
	DB	054H,00BH,001H,08AH,0FFH,0DAH
	; Rules for 'B'
RULESB	DB	013H,0FFH,013H,041H,03FH,093H,02DH,021H
	DB	039H,0E5H,07FH,093H,013H,0E5H,00EH,009H
	DB	041H,03FH,093H,013H,065H,025H,0AEH,013H
	DB	07FH,00CH,08BH,013H,06FH,034H,0A8H,013H
	DB	041H,03FH,035H,09DH,013H,075H,0B3H,009H
	DB	041H,03FH,00CH,0ABH,075H,029H,0ACH,041H
	DB	03FH,00CH,00CH,0ADH,0FFH,022H,0FFH,0FFH
	DB	013H,041H,09CH,0FFH,033H,041H,09CH,0F4H
	DB	042H,08DH,013H,0FFH,00EH,041H,09CH,0FFH
	DB	041H,0BFH
	; Rules for 'C'
RULESC	DB	013H,0FFH,013H,077H,037H,093H,013H,0E8H
	DB	00EH,042H,0AAH,00EH,025H,0E8H,042H,0AAH
	DB	0E8H,042H,0B2H,033H,0E9H,009H,077H,037H
	DB	086H,0E9H,009H,0E5H,0E9H,02FH,0E5H,0E9H
	DB	025H,02EH,0E5H,0FFH,00FH,077H,0B7H,023H
	DB	0FFH,0FFH,0EBH,009H,042H,0AAH,0EBH,042H
	DB	0A9H,06FH,0ADH,00BH,042H,008H,00FH,090H
	DB	0E3H,00FH,042H,02AH,037H,0B7H,0FFH,013H
	DB	042H,0A9H,0FFH,033H,042H,0A9H,0FFH,012H
	DB	042H,088H,0FFH,042H,0AAH
	; Rules for 'D'
RULESD	DB	013H,0FFH,013H,041H,021H,093H,0FFH,024H
	DB	0FFH,009H,010H,065H,0A4H,013H,041H,021H
	DB	00CH,001H,095H,00AH,025H,0FFH,013H,041H
	DB	095H,009H,011H,025H,0FFH,013H,042H,08DH
	DB	013H,0E5H,00EH,009H,041H,021H,08CH,013H
	DB	0EFH,013H,041H,021H,09FH,013H,06FH,025H
	DB	0B3H,041H,021H,00FH,0ABH,013H,06FH,029H
	DB	02EH,0A7H,041H,021H,01FH,00CH,0ACH,013H
	DB	06FH,0B7H,041H,021H,0A0H,009H,0F5H,010H
	DB	021H,041H,00AH,096H,0E7H,041H,08AH,0EAH
	DB	041H,08AH,0FFH,013H,041H,095H,0FFH,033H
	DB	041H,095H,0FFH,041H,0A1H
	; Rules for 'E'
RULESE	DB	013H,0FFH,013H,0D3H,009H,010H,0FFH,013H
	DB	0FFH,007H,011H,0FFH,013H,0FFH,011H,0FFH
	DB	013H,0D3H,009H,0E4H,013H,041H,095H,009H
	DB	010H,0FFH,024H,013H,0FFH,0F6H,025H,032H
	DB	047H,0A3H,009H,011H,0ECH,0FEH,072H,0A9H
	DB	009H,07CH,093H,009H,010H,0F2H,009H,0F3H
	DB	0FFH,00EH,00BH,0D3H,072H,0A9H,047H,007H
	DB	00EH,08CH,0F2H,009H,047H,0AFH,0F2H,0F3H
	DB	013H,076H,025H,0AEH,013H,053H,023H,00CH
	DB	08BH,013H,076H,025H,0AEH,053H,023H,007H
	DB	007H,08BH,009H,010H,0F7H,071H,09FH,00DH
	DB	0F7H,0DFH,0F7H,071H,09FH,0FFH,02FH,0D3H
	DB	009H,010H,00CH,0F3H,013H,04CH,0ABH,009H
	DB	010H,0FFH,033H,013H,0FFH,009H,010H,06CH
	DB	0B9H,013H,06DH,093H,009H,010H,06DH,025H
	DB	02EH,0B4H,050H,00CH,00BH,002H,08DH,066H
	DB	035H,0ACH,068H,01EH,0ADH,065H,0B2H,0FCH
	DB	0E5H,0D3H,061H,032H,0AEH,074H,08BH,013H
	DB	061H,0B2H,00EH,0F4H,011H,061H,0B2H,0FCH
	DB	061H,0A4H,047H,007H,001H,095H,009H,010H
	DB	0E1H,013H,053H,08FH,0E1H,033H,035H,0C7H
	DB	0E1H,0D3H,069H,027H,0A8H,0D4H,0E9H,0D3H
	DB	013H,079H,0A5H,0C6H,0F9H,0D3H,0F5H,0D6H
	DB	0FFH,0C7H
	; Rules for 'F'
RULESF	DB	013H,0FFH,013H,047H,007H,0A8H,0F5H,02CH
	DB	068H,09EH,0FFH,026H,0FFH,06FH,035H,0B2H
	DB	068H,0BAH,0FFH,0E8H
	; Rules for 'G'
RULESG	DB	013H,0FFH,013H,041H,00AH,093H,069H,0B6H
	DB	041H,024H,00CH,0A3H,013H,0FFH,029H,00EH
	DB	041H,0A4H,0E5H,034H,041H,024H,087H,033H
	DB	035H,067H,025H,0B3H,041H,03DH,001H,00AH
	DB	007H,007H,0B7H,0E7H,041H,0A4H,072H,025H
	DB	021H,0B4H,041H,022H,027H,014H,08DH,0FFH
	DB	013H,041H,0A2H,013H,022H,009H,0FFH,041H
	DB	0BDH,0FFH,00FH,041H,08AH,009H,0E8H,0E8H
	DB	0E8H,041H,0BDH,0FFH,041H,0BDH
	; Rules for 'H'
RULESH	DB	013H,0FFH,013H,054H,002H,0B2H,013H,061H
	DB	0B6H,05BH,01AH,0A3H,013H,065H,032H,0A5H
	DB	05BH,0BCH,013H,06FH,035H,0B2H,060H,0B3H
	DB	06FH,0B7H,05BH,0A0H,079H,0B0H,05BH,00CH
	DB	002H,089H,0FFH,012H,0F9H,0FFH,009H,0DBH
	DB	0FFH,0FFH
	; Rules for 'I'
RULESI	DB	013H,0EEH,04CH,08BH,02EH,0FFH,02EH,025H
	DB	0C6H,0FFH,013H,0C6H,0EEH,024H,046H,08BH
	DB	013H,010H,0FFH,00BH,0C6H,013H,010H,065H
	DB	0A4H,013H,046H,001H,095H,009H,011H,065H
	DB	0A4H,013H,053H,001H,095H,026H,032H,0E5H
	DB	02EH,024H,0C7H,065H,0AEH,053H,00CH,08BH
	DB	0E5H,034H,046H,08CH,065H,0B2H,053H,0B3H
	DB	0FFH,00BH,0D3H,0E5H,0D3H,0EEH,00BH,053H
	DB	08BH,0F2H,009H,046H,0B3H,0FFH,00EH,00BH
	DB	0C6H,0FFH,00EH,00FH,010H,009H,0CCH,0FAH
	DB	00BH,046H,0ABH,0F3H,00BH,046H,0ABH,0FFH
	DB	01FH,00BH,0C6H,00FH,00EH,0FFH,00EH,00FH
	DB	0CCH,0FFH,034H,00BH,0C6H,009H,011H,0FFH
	DB	00EH,00FH,0CCH,0F2H,0F4H,011H,0FFH,02FH
	DB	02EH,0F1H,067H,0A8H,0C6H,06CH,0A4H,046H
	DB	03EH,001H,095H,067H,0AEH,046H,08BH,067H
	DB	0AEH,00EH,046H,08BH,067H,0AEH,00BH,046H
	DB	08BH,071H,035H,0A5H,053H,002H,0A9H,0FFH
	DB	021H,0C6H,02DH,0FFH,023H,0C6H,0FFH,0CCH
	; Rules for 'J'
RULESJ	DB	013H,0FFH,013H,041H,00AH,094H,0FFH,041H
	DB	08AH
	; Rules for 'K'
RULESK	DB	013H,0FFH,013H,042H,02AH,094H,013H,0FFH
	DB	02EH,0FFH,0FFH,013H,042H,0A9H,0FFH,042H
	DB	0AAH
	; Rules for 'L'
RULESL	DB	013H,0FFH,013H,047H,007H,0ADH,0EFH,023H
	DB	009H,06DH,0B5H,0FFH,02CH,0FFH,0FFH,00BH
	DB	0FEH,065H,021H,0A4H,06DH,013H,001H,095H
	DB	061H,035H,027H,0A8H,06DH,01AH,0A8H,0FFH
	DB	0EDH
	; Rules for 'M'
RULESM	DB	0E2H,0D0H,013H,0FFH,013H,047H,007H,090H
	DB	06FH,0B6H,050H,01FH,0A3H,0FFH,02DH,0FFH
	DB	0FFH,0D0H
	; Rules for 'N'
RULESN	DB	013H,0FFH,013H,047H,007H,08BH,025H,0E7H
	DB	00FH,04BH,001H,08AH,0E7H,032H,06CH,001H
	DB	0A4H,0E7H,009H,06CH,001H,0A4H,067H,0ACH
	DB	00BH,06CH,001H,024H,0BEH,0E7H,0ECH,0EBH
	DB	013H,06CH,002H,0A9H,0EBH,033H,06CH,002H
	DB	0A9H,0EBH,06CH,002H,0AAH,013H,06FH,0B7H
	DB	013H,078H,0A0H,0FFH,02EH,0FFH,009H,010H
	DB	0F5H,04BH,031H,096H,013H,0FFH,0F8H,047H
	DB	0B4H,04BH,002H,08DH,0FFH,0CBH
	; Rules for 'O'
RULESO	DB	013H,0FFH,013H,0F5H,0E6H,013H,04FH,0A3H
	DB	072H,02FH,035H,027H,0A8H,04FH,00FH,027H
	DB	0B5H,009H,010H,0F2H,013H,0F3H,009H,010H
	DB	072H,0B3H,013H,073H,0ABH,0F2H,0FAH,013H
	DB	06EH,0A5H,06EH,00FH,08BH,00FH,06EH,0A5H
	DB	06EH,00FH,08BH,011H,0F7H,02EH,0E0H,0F7H
	DB	0F5H,013H,076H,025H,0B2H,075H,023H,0B3H
	DB	0F6H,04FH,0A3H,0FFH,00EH,00BH,0F5H,0FFH
	DB	00EH,025H,02EH,0F5H,0FFH,00EH,029H,009H
	DB	0F5H,0ECH,024H,075H,0ADH,075H,027H,028H
	DB	0B4H,057H,017H,002H,08DH,075H,027H,0A8H
	DB	04FH,00FH,0A8H,00CH,075H,0B2H,0FAH,010H
	DB	075H,0B2H,060H,0B3H,013H,0F5H,0E0H,010H
	DB	0F5H,033H,009H,0E0H,075H,0B3H,04FH,0B7H
	DB	075H,02CH,0A4H,05EH,001H,095H,00EH,0F5H
	DB	00EH,02CH,0CFH,075H,0B0H,05FH,002H,089H
	DB	0F5H,0E0H,0F9H,0C5H,069H,02EH,0A7H,075H
	DB	00CH,0ACH,0E9H,0C5H,06FH,0B2H,0FAH,06FH
	DB	0ABH,013H,05EH,002H,0A9H,06FH,0ABH,033H
	DB	05EH,002H,0A9H,06FH,0ABH,05EH,002H,0AAH
	DB	06FH,0A4H,013H,05EH,001H,095H,0EFH,024H
	DB	0DEH,0EFH,0DFH,0FFH,025H,0F5H,0FFH,013H
	DB	0F5H,061H,0B2H,0FAH,0E1H,0F5H,013H,06EH
	DB	02CH,0B9H,075H,00BH,02DH,093H,013H,06EH
	DB	023H,0A5H,06EH,00FH,00BH,0B7H,06EH,007H
	DB	0B4H,075H,00BH,002H,08DH,023H,0FFH,02EH
	DB	0CFH,0FFH,02EH,027H,0D7H,013H,011H,0FFH
	DB	02EH,0CFH,029H,0EEH,04FH,08BH,009H,010H
	DB	0EEH,013H,04FH,08BH,0FFH,033H,034H,013H
	DB	0F5H,0E6H,00EH,057H,0A8H,074H,028H,025H
	DB	0B2H,04FH,036H,0B3H,073H,0B3H,013H,057H
	DB	017H,037H,0B7H,009H,011H,0EDH,04FH,090H
	DB	0FFH,0D8H
	; Rules for 'P'
RULESP	DB	073H,039H,023H,0A8H,077H,037H,006H,001H
	DB	0AAH,013H,0FFH,013H,042H,009H,093H,0E8H
	DB	0E8H,065H,02FH,0B0H,042H,009H,013H,002H
	DB	089H,06FH,0B7H,042H,009H,0A0H,075H,0B4H
	DB	013H,042H,009H,01EH,002H,08DH,0FFH,030H
	DB	0FFH,0FFH,042H,089H
	; Rules for 'Q'
RULESQ	DB	013H,0FFH,013H,042H,02AH,031H,09FH,075H
	DB	021H,0B2H,042H,008H,030H,098H,075H,0A5H
	DB	013H,042H,02AH,031H,09FH,0F5H,042H,008H
	DB	0B0H,0FFH,042H,088H
	; Rules for 'R'
RULESR	DB	013H,0FFH,013H,0FBH,013H,0E5H,00EH,009H
	DB	04EH,093H,0E8H,0CEH,0FFH,032H,0FFH,011H
	DB	0FFH,0E7H,0FFH,0CEH
	; Rules for 'S'
RULESS	DB	013H,0FFH,013H,047H,007H,037H,0B7H,0E8H
	DB	0E5H,009H,069H,02FH,0AEH,066H,00FH,08BH
	DB	06FH,02DH,0A5H,077H,00FH,090H,009H,075H
	DB	0B2H,009H,066H,0B3H,075H,0B2H,009H,065H
	DB	0B3H,009H,0F5H,009H,066H,096H,009H,073H
	DB	0B5H,009H,065H,096H,009H,065H,0A4H,013H
	DB	06BH,001H,095H,009H,0FFH,009H,0EBH,061H
	DB	029H,0A4H,077H,037H,007H,007H,001H,095H
	DB	00EH,069H,02FH,0AEH,065H,00FH,08BH,0FFH
	DB	033H,0FFH,00AH,0FFH,013H,0EBH,009H,010H
	DB	00AH,025H,0FFH,013H,0EBH,009H,011H,014H
	DB	0FFH,013H,0EBH,009H,011H,009H,0FFH,013H
	DB	0F7H,035H,0FFH,013H,0F7H,013H,010H,009H
	DB	0FFH,013H,0EBH,013H,063H,0A8H,077H,037H
	DB	002H,0A9H,0FFH,023H,00FH,0FFH,009H,0EDH
	DB	06BH,090H,009H,0FFH,02EH,007H,0EBH,0FFH
	DB	013H,0F7H,0FFH,077H,0B7H
	; Rules for 'T'
RULEST	DB	0FFH,007H,033H,042H,091H,063H,0A8H,042H
	DB	0B2H,013H,0FFH,013H,042H,00DH,093H,013H
	DB	068H,0A5H,013H,009H,052H,093H,013H,068H
	DB	0A5H,013H,052H,08FH,0EFH,013H,042H,00DH
	DB	09FH,06FH,024H,021H,0B9H,042H,00DH,01FH
	DB	021H,094H,068H,0A1H,00EH,013H,052H,09AH
	DB	013H,068H,029H,0B3H,013H,052H,00CH,037H
	DB	0B7H,013H,068H,025H,0B9H,052H,094H,013H
	DB	068H,025H,032H,0A5H,052H,0AFH,013H,068H
	DB	025H,0B2H,05DH,0B3H,068H,025H,0B2H,076H
	DB	0B3H,068H,025H,029H,0B2H,052H,0AFH,013H
	DB	068H,025H,0ADH,010H,052H,007H,090H,068H
	DB	025H,033H,0A5H,013H,052H,013H,0ABH,013H
	DB	068H,025H,0AEH,052H,007H,08BH,068H,032H
	DB	02FH,035H,027H,0A8H,013H,05DH,027H,09FH
	DB	068H,02FH,033H,0A5H,052H,035H,0B7H,068H
	DB	02FH,035H,027H,0A8H,013H,052H,0B5H,013H
	DB	068H,035H,0B3H,052H,00FH,037H,0B7H,068H
	DB	0A5H,013H,0D2H,0E8H,0DDH,009H,010H,065H
	DB	0A4H,013H,042H,00DH,00CH,001H,095H,033H
	DB	0E9H,009H,02EH,042H,0B2H,0E9H,02FH,0E5H
	DB	0E9H,021H,0E5H,069H,025H,0AEH,065H,00FH
	DB	08BH,075H,0B2H,009H,042H,032H,0B3H,0F5H
	DB	021H,042H,032H,096H,013H,077H,0AFH,042H
	DB	00DH,09FH,0FFH,034H,0FFH,0FFH,033H,042H
	DB	091H,0FFH,042H,08DH
	; Rules for 'U'
RULESU	DB	013H,0FFH,013H,071H,09FH,0EEH,029H,059H
	DB	016H,08BH,013H,0EEH,04FH,08BH,013H,070H
	DB	02FH,0AEH,04FH,002H,009H,018H,08BH,00DH
	DB	0F2H,009H,056H,0B3H,0F2H,009H,071H,016H
	DB	0B3H,0F2H,011H,0F3H,0FFH,00EH,013H,0CFH
	DB	0FFH,00EH,00EH,0CFH,0F9H,0C6H,013H,027H
	DB	0FFH,009H,0FFH,027H,0FFH,00BH,0FFH,027H
	DB	0FFH,009H,0EEH,00DH,0FFH,0DFH,0FFH,071H
	DB	096H
	; Rules for 'V'
RULESV	DB	013H,0FFH,013H,063H,093H,069H,025H,0B7H
	DB	063H,031H,09FH,0FFH,0E3H
	; Rules for 'W'
RULESW	DB	013H,0FFH,013H,041H,021H,00FH,001H,03FH
	DB	03EH,031H,096H,013H,065H,032H,0A5H,06EH
	DB	0B4H,013H,061H,0B3H,013H,06EH,00FH,0ABH
	DB	0E1H,033H,06EH,098H,0E1H,034H,06EH,017H
	DB	097H,061H,0AEH,06EH,018H,08BH,068H,025H
	DB	032H,0A5H,070H,0AFH,068H,021H,0B4H,070H
	DB	018H,002H,08DH,068H,02FH,0ACH,079H,035H
	DB	0ADH,068H,0AFH,079H,09FH,0EFH,02DH,06EH
	DB	08FH,0E8H,0F0H,061H,0B2H,06EH,0BAH,06FH
	DB	0B2H,00EH,06EH,0B3H,0F2H,0CEH,0FFH,0EEH
	; Rules for 'X'
RULESX	DB	013H,0FFH,013H,047H,002H,029H,0B7H,013H
	DB	0FFH,0EBH,0FFH,042H,029H,0B7H
	; Rules for 'Y'
RULESY	DB	06FH,035H,0B2H,059H,0BAH,013H,0FFH,013H
	DB	06EH,086H,06FH,035H,02EH,0A7H,059H,00FH
	DB	0ACH,013H,06FH,0B5H,059H,09FH,065H,021H
	DB	0B2H,010H,059H,0BCH,013H,065H,0B3H,059H
	DB	007H,037H,0B7H,013H,0FFH,0D9H,009H,011H
	DB	0FFH,013H,0D3H,009H,011H,0FFH,029H,0D3H
	DB	013H,010H,0FFH,013H,0C6H,013H,010H,0FFH
	DB	009H,0C6H,013H,010H,0FFH,00EH,00FH,010H
	DB	009H,0CCH,013H,010H,0FFH,00EH,009H,0C6H
	DB	0FFH,0CCH
	; Rules for 'Z'
RULESZ	DB	013H,0FFH,013H,06BH,093H,0FFH,03AH,0FFH
	DB	0FFH,0EBH
	; Rules for digits
RULNUM	DB	0D0H,06BH,03CH,0B5H,0D1H,06EH,00FH,00FH
	DB	08BH,0D2H,042H,00DH,09FH,0D3H,05DH,00EH
	DB	093H,0D4H,068H,0BAH,0D5H,068H,006H,0A3H
	DB	0D6H,077H,037H,00CH,002H,029H,0B7H,0D7H
	DB	077H,037H,007H,023H,00CH,08BH,0D8H,054H
	DB	002H,08DH,0D9H,078H,006H,08BH

;==============================================================================

	; Index of rules tables
TABRUL	DW	RLPNCT
TABRU1	EQU	$-1
	DW	RULESA,RULESB,RULESC,RULESD
	DW	RULESE,RULESF,RULESG,RULESH
	DW	RULESI,RULESJ,RULESK,RULESL
	DW	RULESM,RULESN,RULESO,RULESP
	DW	RULESQ,RULESR,RULESS,RULEST
	DW	RULESU,RULESV,RULESW,RULESX
	DW	RULESY,RULESZ,RULNUM,0FFFFH

;==============================================================================
	; Interrupt vectors
	DW	INT4,INT3,0FFFFH,INT1
	DW	CTS256

;==============================================================================
PARLINP	EQU	0200H
SP0256	EQU	2000H
CTSXRAM	EQU	3000H
;==============================================================================

				;END	CTS256
	DS	LOW(100H-LOW $)
P0	DB	0
P1	DB	0
P2	DB	0
P3	DB	0
P4	DB	0
P5	DB	0
P6	DB	0
P7	DB	0
P8	DB	0
P9	DB	0
P10	DB	0
P11	DB	0
P12	DB	0
P13	DB	0
P14	DB	0
P15	DB	0
P16	DB	0
P17	DB	0
P18	DB	0
P19	DB	0
P20	DB	0
P21	DB	0
P22	DB	0
P23	DB	0

	DS	LOW(100H-LOW $)
	DS	0FFH-57
R57	DS	1
R56	DS	1
R55	DS	1
R54	DS	1
R53	DS	1
R52	DS	1
R51	DS	1
R50	DS	1
R49	DS	1
R48	DS	1
R47	DS	1
R46	DS	1
R45	DS	1
R44	DS	1
R43	DS	1
R42	DS	1
R41	DS	1
R40	DS	1
R39	DS	1
R38	DS	1
R37	DS	1
R36	DS	1
R35	DS	1
R34	DS	1
R33	DS	1
R32	DS	1
R31	DS	1
R30	DS	1
R29	DS	1
R28	DS	1
R27	DS	1
R26	DS	1
R25	DS	1
R24	DS	1
R23	DS	1
R22	DS	1
R21	DS	1
R20	DS	1
R19	DS	1
R18	DS	1
R17	DS	1
R16	DS	1
R15	DS	1
R14	DS	1
R13	DS	1
R12	DS	1
R11	DS	1
R10	DS	1
R9	DS	1
R8	DS	1
R7	DS	1
R6	DS	1
R5	DS	1
R4	DS	1
R3	DS	1
R2	DS	1
R1	DS	1
R0	DS	1

$ENTRY:	LD	IX,R0
	JP	CTS256
	END	$ENTRY

;==============================================================================

