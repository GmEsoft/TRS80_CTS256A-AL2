;CTS256_SP0256.ASM

;------------------------------------------------------------------------------
;	S P O 2 5 6   H E L P E R   B E G I N
;------------------------------------------------------------------------------

DEFTOK	MACRO	STR
	LOCAL	POS

	; Generate output
POS	DEFL	0
	IRPC	C,'STR'
	 IFEQ	POS,0
	  DB	'C'+80H		; First character bit 7 is 1
	 ELSE
	  DB	'C'
	 ENDIF
POS	 DEFL	POS+1
	ENDM	;IRPC

	ENDM	;MACRO


;-----	Table of allophone mnemonics
ALLO	DEFTOK	"PA1"
	DEFTOK	"PA2"
	DEFTOK	"PA3"
	DEFTOK	"PA4"
	DEFTOK	"PA5"
	DEFTOK	"OY"
	DEFTOK	"AY"
	DEFTOK	"EH"
	DEFTOK	"KK3"
	DEFTOK	"PP"
	DEFTOK	"JH"
	DEFTOK	"NN1"
	DEFTOK	"IH"
	DEFTOK	"TT2"
	DEFTOK	"RR1"
	DEFTOK	"AX"
	DEFTOK	"MM"
	DEFTOK	"TT1"
	DEFTOK	"DH1"
	DEFTOK	"IY"
	DEFTOK	"EY"
	DEFTOK	"DD1"
	DEFTOK	"UW1"
	DEFTOK	"AO"
	DEFTOK	"AA"
	DEFTOK	"YY2"
	DEFTOK	"AE"
	DEFTOK	"HH1"
	DEFTOK	"BB1"
	DEFTOK	"TH"
	DEFTOK	"UH"
	DEFTOK	"UW2"
	DEFTOK	"AW"
	DEFTOK	"DD2"
	DEFTOK	"GG3"
	DEFTOK	"VV"
	DEFTOK	"GG1"
	DEFTOK	"SH"
	DEFTOK	"ZH"
	DEFTOK	"RR2"
	DEFTOK	"FF"
	DEFTOK	"KK2"
	DEFTOK	"KK1"
	DEFTOK	"ZZ"
	DEFTOK	"NG"
	DEFTOK	"LL"
	DEFTOK	"WW"
	DEFTOK	"XR"
	DEFTOK	"WH"
	DEFTOK	"YY1"
	DEFTOK	"CH"
	DEFTOK	"ER1"
	DEFTOK	"ER2"
	DEFTOK	"OW"
	DEFTOK	"DH2"
	DEFTOK	"SS"
	DEFTOK	"NN2"
	DEFTOK	"HH2"
	DEFTOK	"OR"
	DEFTOK	"AR"
	DEFTOK	"YR"
	DEFTOK	"GG2"
	DEFTOK	"EL"
	DEFTOK	"BB2"
	DB	0FFH

;-----	Encode allophone mnemonic to SP0256A-AL2 code
ENCOTOK	LD	B,0		;init allophone code
	EX	DE,HL		;mnemo pointer to DE
	LD	HL,ALLO		;allophone mnemonics table to HL
ENCOTL0	LD	A,(HL)		;Seek mnemonic 1st char (high bit set)
	INC	HL		;
	ADD	A,1		;End of table (0xFF)?
	RET	C		;return with Cy if yes

	DEC	A		;restore char
	SUB	80H		;high bit set?
	JR	C,ENCOTL0	;loop if not

	PUSH	DE		; else, save mnemo pointer

ENCOTL1	LD	C,A		;save char from table
	LD	A,(DE)		;get char from mnemonic candidate
	INC	DE		;
	CP	C		;match?
	JR	NZ,ENCOTJ3	;no => next token
	LD	A,(HL)		;get next char from table
	INC	HL		;
	CP	80H		;end token?
	JR	C,ENCOTL1	;no => next char
	LD	A,B		;return allophone code
	EX	DE,HL		;point to char following found mnemo
	POP	DE		;don't care
	RET			;done

ENCOTJ3	INC	B		;try next mnemo from table
	POP	DE		;restore mnemo pointers
	JR	ENCOTL0		;next mnemo


;-----	Decode allophone mnemonic from SP0256A-AL2 code
DECOTOK	LD	HL,ALLO		;Allophone mnemonics table
	AND	3FH		;Keep 6 lower bits
	LD	B,A		;allophone code to B
	LD	A,'['		;Display [
	CALL	DDISA		;
	INC	B		;Increment once
DECOTL0	DEC	B		;Loop to find corresponding mnemonic
	JR	Z,DECOTL2	;exit loop when matching mnemo found
DECOTL1	INC	HL		;loop until start of mnemo found (high bit set)
	BIT	7,(HL)		;
	JR	Z,DECOTL1	;
	JR	DECOTL0		;found: test if matching mnemo found
DECOTL2	LD	A,(HL)		;get mnemo char from table
	INC	HL		;
	AND	7FH		;mask out high bit
	CALL	DDISA		;display char
	BIT	7,(HL)		;end of mnemo (high bit of next char set) ?
	JR	Z,DECOTL2	;display next char if not
	LD	A,']'		;display ]
	JP	DDISA		;and return

;-----	Allophone mnemonic buffer
ENCOBUF	DC	10H,0

;------------------------------------------------------------------------------
;	S P O 2 5 6   H E L P E R   E N D
;------------------------------------------------------------------------------

	END
