;	Code-To-Speech Rules extracted from CTS256A-AL2
;	===============================================


;	Patterns:
;	---------
;	#	09	one or more vowels
;	.	0A	voiced consonant: B D G J L M N R V W X
;	%	0B	suffix: ER E ES ED ING ELY (FUL?)
;	&	0C	sibilant: S C G Z X J CH SH
;	@	0D	T S R D L Z N J TH CH SH preceding long U
;	^	0E	one consonant
;	+	0F	front vowel: E I Y
;	:	10	zero or more consonants
;	*	11	one or more consonants
;	>	12	back vowel: O U
;	<	13	anything other than a letter
;	?	14	two or more vowels
;	$	1F	not a pattern, not treated as such by the ROM
;			Should probably be a D: [I]D% = [AY]

;-----	Set the initial for the group of rules
INITIAL	MACRO	CHR
$INITL	DEFL	'CHR'
	ENDM	;MACRO

;-----	Define a rule:	DEFRULE "pfx[ptrn]sfx"	<@AL1,...>
DEFRULE	MACRO	STR,ALLO
	LOCAL	$BKTMSK,$BKTFLG,$BKT1ST,$INBKT,$REPL,$NEXT
$BKTMSK	DEFL	0		;Brackets mask
$BKTFLG	DEFL	0		;Bracket found flag
$BKT1ST	DEFL	0		;1st char after [
$INBKT	DEFL	0		;Inside brackets
$REPL	DEFL	0		;Replace char
$NEXT	DEFL	-1		;Pending char in bracket

	; encode pattern
	IRPC	CH,"STR"
$BKTFLG	 DEFL	0
	 IFEQ	"CH",']'
	  ;Closing bracket
$BKTFLG	  DEFL	1
$BKTMSK	  DEFL	$BKTMSK|80H
	  IF	$NEXT >= 0
	   DB	$NEXT|$BKTMSK
	  ELSE
	   DB	3FH|$BKTMSK
	  ENDIF
$BKTMSK	  DEFL	0
$INBKT	  DEFL	0
	 ELSE
	  ;Pending char inside bracket
	  IF	$NEXT >= 0
	   DB	$NEXT|$BKTMSK
$BKTMSK	   DEFL	0
	  ENDIF
	 ENDIF

$NEXT	 DEFL	-1

	 IFEQ	"CH",'['
	  ;Opening bracket
$BKTFLG	  DEFL	1
$BKTMSK	  DEFL	40H
$INBKT	  DEFL	1
$BKT1ST	  DEFL	1
	 ENDIF

	 IFEQ	$BKTFLG,0
	  ; No bracket sign
	  IFEQ	$INBKT,0
	   ; not inside bracket => encode patterns
$REPL	   DEFL	("CH"-20H)&3FH
	   IFEQ	"CH",'#'
$REPL	    DEFL 09H
	   ENDIF
	   IFEQ	"CH",'.'
$REPL	    DEFL 0AH
	   ENDIF
	   IFEQ	"CH",'%'
$REPL	    DEFL 0BH
	   ENDIF
	   IFEQ	"CH",'&'
$REPL	    DEFL 0CH
	   ENDIF
	   IFEQ	"CH",'@'
$REPL	    DEFL 0DH
	   ENDIF
	   IFEQ	"CH",'^'
$REPL	    DEFL 0EH
	   ENDIF
	   IFEQ	"CH",'+'
$REPL	    DEFL 0FH
	   ENDIF
	   IFEQ	"CH",':'
$REPL	    DEFL 10H
	   ENDIF
	   IFEQ	"CH",'*'
$REPL	    DEFL 11H
	   ENDIF
	   IFEQ	"CH",'>'
$REPL	    DEFL 12H
	   ENDIF
	   IFEQ	"CH",'<'
$REPL	    DEFL 13H
	   ENDIF
	   IFEQ	"CH",'?'
$REPL	    DEFL 14H
	   ENDIF
	   IFEQ	"CH",'$'
$REPL	    DEFL 1FH
	   ENDIF
	   DB	$REPL
	  ELSE	;IFEQ	$INBKT,0
	   ; inside bracket => set pending char
	   IFNE	"CH",$INITL
	    ; char not initial
$NEXT	    DEFL ("CH"-20H)&3FH
	   ELSE	;IFNE	"CH",$INITL
	    IFLT "CH",'A'
	     ; char not letter
$NEXT	     DEFL ("CH"-20H)&3FH
	    ELSE ;IFLT "CH",'A'
	     IFEQ $BKT1ST,0
	      ; not 1st char
$NEXT	      DEFL ("CH"-20H)&3FH
	     ENDIF ;IFEQ $BKT1ST,0
	    ENDIF ;ELSE ;IFLT "CH",'A'
	   ENDIF ;ELSE	;IFNE	"CH",$INITL
$BKT1ST	   DEFL	0
	  ENDIF	;ELSE	;IFEQ	$BKTMSK,0
	 ENDIF	;IFEQ	$BKTFLG,0

	ENDM	;IRPC

	; count allophones
$LEN	DEFL	0

	IRP	AL,<ALLO>
$LEN	 DEFL	$LEN+1
	ENDM	;IRP

	; encode allophones
	IFEQ	$LEN,0
	 DB	0FFH
	ELSE
$POS	 DEFL	0
	 IRP	AL,<ALLO>
$BKTMSK	  DEFL	0
$POS	  DEFL	$POS+1
	  IFEQ	$POS,1
$BKTMSK	   DEFL	40H
	  ENDIF
	  IFEQ	$POS,$LEN
$BKTMSK	   DEFL	$BKTMSK+80H
	  ENDIF
	  DB	AL|$BKTMSK
	 ENDM	;IRP
	ENDIF

	ENDM	;MACRO

;-----	SP0256A-AL2 Allophones
@PA1	EQU	0
@PA2	EQU	1
@PA3	EQU	2
@PA4	EQU	3
@PA5	EQU	4
@OY	EQU	5
@AY	EQU	6
@EH	EQU	7
@KK3	EQU	8
@PP	EQU	9
@JH	EQU	10
@NN1	EQU	11
@IH	EQU	12
@TT2	EQU	13
@RR1	EQU	14
@AX	EQU	15
@MM	EQU	16
@TT1	EQU	17
@DH1	EQU	18
@IY	EQU	19
@EY	EQU	20
@DD1	EQU	21
@UW1	EQU	22
@AO	EQU	23
@AA	EQU	24
@YY2	EQU	25
@AE	EQU	26
@HH1	EQU	27
@BB1	EQU	28
@TH	EQU	29
@UH	EQU	30
@UW2	EQU	31
@AW	EQU	32
@DD2	EQU	33
@GG3	EQU	34
@VV	EQU	35
@GG1	EQU	36
@SH	EQU	37
@ZH	EQU	38
@RR2	EQU	39
@FF	EQU	40
@KK2	EQU	41
@KK1	EQU	42
@ZZ	EQU	43
@NG	EQU	44
@LL	EQU	45
@WW	EQU	46
@XR	EQU	47
@WH	EQU	48
@YY1	EQU	49
@CH	EQU	50
@ER1	EQU	51
@ER2	EQU	52
@OW	EQU	53
@DH2	EQU	54
@SS	EQU	55
@NN2	EQU	56
@HH2	EQU	57
@OR	EQU	58
@AR	EQU	59
@YR	EQU	60
@GG2	EQU	61
@EL	EQU	62
@BB2	EQU	63

	; Rules for punctuation
RLPNCT	INITIAL	":"
	DEFRULE	"[-]",		<@PA1>
	DEFRULE	".['S]",	<@ZZ>
	DEFRULE	"#:.E['S]",	<@ZZ>
	DEFRULE	"#['S]",	<@ZZ>
	DEFRULE	"['S]",		<@SS>
	DEFRULE	"[']",		<>
	DEFRULE	"[,]",		<@PA4>
	DEFRULE	"[;]",		<@PA4>
	DEFRULE	"[ ]",		<@PA2>
	DEFRULE	"[.]",		<@PA5,@PA5>
	DEFRULE	"[!]",		<@PA5,@PA5>
	DEFRULE	"[?]",		<@PA5,@PA5>
	DEFRULE	"[:]",		<@PA5>
	DEFRULE	"[%]",		<@PP,@ER2,@SS,@SS,@EH,@NN1,@TT2,@PA1>
	DEFRULE	"[$]",		<@DD2,@AA,@LL,@ER1,@ZZ,@PA1>
	DEFRULE	"[#]",		<@NN2,@AX,@MM,@BB1,@ER1,@PA1>
	DEFRULE	"[]",		<@PA3>

	; Rules for 'A'
RULESA	INITIAL	"A"
	DEFRULE	"<[A]<",	<@EY>
	DEFRULE	"[ACHE]",	<@EY,@PA3,@KK2>
	DEFRULE	"[A]<",		<@AX>
	DEFRULE	"<[ARE]<",	<@AR>
	DEFRULE	"^[AS]#",	<@EY,@SS>
	DEFRULE	"<[AR]O",	<@AX,@RR2>
	DEFRULE	"<[A]^R",	<@AX>
	DEFRULE	"[AR]#",	<@XR>
	DEFRULE	"<:[ANY]",	<@EH,@NN1,@IY>
	DEFRULE	"[AGAIN]",	<@AX,@PA2,@GG1,@EH,@EH,@NN1>
	DEFRULE	"[A]WA",	<@AX>
	DEFRULE	"[AW]",		<@AO,@AO>
	DEFRULE	"<:[A]^+<",	<@EY>
	DEFRULE	"<[A]^#",	<@AX>
	DEFRULE	"[A]^+#",	<@EY>
	DEFRULE	"#:[ALLY]",	<@AX,@LL,@IY>
	DEFRULE	"<[AL]#",	<@AX,@LL>
	DEFRULE	"#:[AG]E",	<@IH,@PA2,@JH>
	DEFRULE	"[A]^%",	<@EY>
	DEFRULE	"[A]^+:#",	<@AE>
	DEFRULE	"<[ARR]",	<@AX,@RR2>
	DEFRULE	"[ARR]",	<@AE,@RR2>
	DEFRULE	"<:[AR]<",	<@AR>
	DEFRULE	"[AR]<",	<@ER1>
	DEFRULE	"[AR]",		<@AR>
	DEFRULE	"[AIR]",	<@EH,@XR>
	DEFRULE	"[AI]",		<@EY>
	DEFRULE	"[AY]",		<@EY>
	DEFRULE	"[AU]",		<@AO>
	DEFRULE	"#:[AL]<",	<@EL>
	DEFRULE	"#:[ALS]<",	<@EL,@ZZ>
	DEFRULE	"[ALK]",	<@AO,@PA3,@KK2>
	DEFRULE	"[A]L^",	<@AO>
	DEFRULE	"<:[ABLE]",	<@EY,@PA2,@BB2,@EL>
	DEFRULE	"[ABLE]",	<@AX,@PA2,@BB2,@EL>
	DEFRULE	"[ANG]+",	<@EY,@NN1,@PA2,@JH>
	DEFRULE	"[A]",		<@AE>

	; Rules for 'B'
RULESB	INITIAL	"B"
	DEFRULE	"<[B]<",	<@PA2,@BB2,@IY>
	DEFRULE	"MAY[BE]",	<@BB2,@IY>
	DEFRULE	"<[BE]^#",	<@PA2,@BB2,@IY>
	DEFRULE	"<[BEEN]<",	<@BB2,@IH,@NN1>
	DEFRULE	"<[BOTH]<",	<@PA2,@BB2,@OW,@TH>
	DEFRULE	"<[BUS]#",	<@PA2,@BB2,@IH,@ZZ>
	DEFRULE	"[BUIL]",	<@PA2,@BB2,@IH,@IH,@LL>
	DEFRULE	"[B]B",		<>
	DEFRULE	"[B]<",		<@PA2,@BB1>
	DEFRULE	"[B]S",		<@PA2,@BB1>
	DEFRULE	"[BT]",		<@PA3,@TT2>
	DEFRULE	"<[B]^",	<@PA2,@BB1>
	DEFRULE	"[B]",		<@PA2,@BB2>

	; Rules for 'C'
RULESC	INITIAL	"C"
	DEFRULE	"<[C]<",	<@SS,@SS,@IY>
	DEFRULE	"<[CH]^",	<@PA3,@KK1>
	DEFRULE	"^E[CH]",	<@PA3,@KK1>
	DEFRULE	"[CH]",		<@PA3,@CH>
	DEFRULE	"S[CI]#",	<@SS,@SS,@AY>
	DEFRULE	"[CI]#",	<@SH>
	DEFRULE	"[CI]O",	<@SH>
	DEFRULE	"[CI]EN",	<@SH>
	DEFRULE	"[C]+",		<@SS,@SS>
	DEFRULE	"C[C]",		<>
	DEFRULE	"[CK]#",	<@PA3,@KK1>
	DEFRULE	"[CK]",		<@PA3,@KK2>
	DEFRULE	"[COM]%",	<@PA3,@KK3,@AX,@MM>
	DEFRULE	"[CC]+",	<@PA3,@KK1,@SS,@SS>
	DEFRULE	"[C]<",		<@PA3,@KK2>
	DEFRULE	"[C]S",		<@PA3,@KK2>
	DEFRULE	"[C]>",		<@PA3,@KK3>
	DEFRULE	"[C]",		<@PA3,@KK1>

	; Rules for 'D'
RULESD	INITIAL	"D"
	DEFRULE	"<[D]<",	<@PA2,@DD2,@IY>
	DEFRULE	"[D]D",		<>
	DEFRULE	"#:[DED]<",	<@PA2,@DD2,@IH,@PA2,@DD1>
	DEFRULE	".E[D]<",	<@PA2,@DD1>
	DEFRULE	"#*E[D]<",	<@PA3,@TT2>
	DEFRULE	"<[DE]^#",	<@PA2,@DD2,@IH>
	DEFRULE	"<[DO]<",	<@PA2,@DD2,@UW2>
	DEFRULE	"<[DOES]",	<@PA2,@DD2,@AX,@ZZ>
	DEFRULE	"<[DOING]",	<@PA2,@DD2,@UW2,@IH,@NG>
	DEFRULE	"<[DOW]",	<@PA2,@DD2,@AW>
	DEFRULE	"#[DU]:A",	<@PA2,@JH,@UW1>
	DEFRULE	"[DG]",		<@PA2,@JH>
	DEFRULE	"[DJ]",		<@PA2,@JH>
	DEFRULE	"[D]<",		<@PA2,@DD1>
	DEFRULE	"[D]S",		<@PA2,@DD1>
	DEFRULE	"[D]",		<@PA2,@DD2>

	; Rules for 'E'
RULESE	INITIAL	"E"
	DEFRULE	"<[E]<",	<@IY>
	DEFRULE	"#:[E]<",	<>
	DEFRULE	"'*[E]<",	<>
	DEFRULE	"*[E]<",	<@IY>
	DEFRULE	"#[ED]<",	<@PA2,@DD1>
	DEFRULE	"#:[E]D<",	<>
	DEFRULE	"[EV]ER",	<@EH,@VV>
	DEFRULE	"#*[EL]",	<@EL>
	DEFRULE	"[ERI]#",	<@YR,@IY>
	DEFRULE	"#:[ER]#",	<@ER1>
	DEFRULE	"[E]^%",	<@IY>
	DEFRULE	"[ERI]",	<@EH,@EH,@RR1,@IH>
	DEFRULE	"[ER]#",	<@EH,@XR>
	DEFRULE	"[ER]",		<@ER1>
	DEFRULE	"<[EVEN]<",	<@IY,@VV,@IH,@NN1>
	DEFRULE	"<[EVEN]",	<@IY,@VV,@EH,@EH,@NN1>
	DEFRULE	"#:[EW]",	<@YY1,@UW2>
	DEFRULE	"@[EW]",	<@UW2>
	DEFRULE	"[EW]",		<@YY1,@UW2>
	DEFRULE	"[E]O",		<@IY>
	DEFRULE	"#:&[ES]<",	<@IH,@ZZ>
	DEFRULE	"#:[E]S<",	<>
	DEFRULE	"#:[ELY]<",	<@LL,@IY>
	DEFRULE	"#:[EMENT]",	<@MM,@IH,@NN1,@PA3,@TT2>
	DEFRULE	"[EFUL]",	<@FF,@UH,@LL>
	DEFRULE	"[EER]",	<@YR>
	DEFRULE	"[EE]",		<@IY>
	DEFRULE	"[EARN]",	<@ER2,@NN1>
	DEFRULE	"<[EAR]^",	<@ER2>
	DEFRULE	"*[EAR]",	<@YR>
	DEFRULE	"[EAD]",	<@EH,@EH,@PA2,@DD1>
	DEFRULE	"#:[EA]<",	<@IY,@AX>
	DEFRULE	"[EA]SU",	<@EH>
	DEFRULE	"[EA]",		<@IY>
	DEFRULE	"[EIGH]",	<@EY>
	DEFRULE	"[EI]",		<@IY>
	DEFRULE	"<[EYE]",	<@AY>
	DEFRULE	"[EY]",		<@IY>
	DEFRULE	"[EU]",		<@UW1>
	DEFRULE	"[E]",		<@EH>

	; Rules for 'F'
RULESF	INITIAL	"F"
	DEFRULE	"<[F]<",	<@EH,@EH,@FF>
	DEFRULE	"[FU]L",	<@FF,@UH>
	DEFRULE	"[F]F",		<>
	DEFRULE	"[FOUR]",	<@FF,@OR>
	DEFRULE	"[F]",		<@FF>

	; Rules for 'G'
RULESG	INITIAL	"G"
	DEFRULE	"<[G]<",	<@PA2,@JH,@IY>
	DEFRULE	"[GIV]",	<@PA2,@GG1,@IH,@VV>
	DEFRULE	"<[G]I^",	<@PA2,@GG1>
	DEFRULE	"[GE]T",	<@PA2,@GG1,@EH>
	DEFRULE	"SU[GGES]",	<@PA2,@GG2,@PA2,@JH,@EH,@EH,@SS>
	DEFRULE	"[GG]",		<@PA2,@GG1>
	DEFRULE	"[GREAT]",	<@PA2,@GG3,@RR2,@EY,@TT2>
	DEFRULE	"[G]<",		<@PA2,@GG3>
	DEFRULE	"<B#[G]",	<@PA2,@GG2>
	DEFRULE	"[G]+",		<@PA2,@JH>
	DEFRULE	"#[GH]",	<@FF>
	DEFRULE	"[GH]",		<@PA2,@GG2>
	DEFRULE	"[G]",		<@PA2,@GG2>

	; Rules for 'H'
RULESH	INITIAL	"H"
	DEFRULE	"<[H]<",	<@EY,@PA3,@CH>
	DEFRULE	"<[HAV]",	<@HH1,@AE,@VV>
	DEFRULE	"<[HERE]",	<@HH1,@YR>
	DEFRULE	"<[HOUR]",	<@AW,@ER1>
	DEFRULE	"[HOW]",	<@HH1,@AW>
	DEFRULE	"[HYP]",	<@HH1,@IH,@PA3,@PP>
	DEFRULE	"[H]>",		<@HH2>
	DEFRULE	"[H]#",		<@HH1>
	DEFRULE	"[H]",		<>

	; Rules for 'I'
RULESI	INITIAL	"I"
	DEFRULE	"<[IN]",	<@IH,@NN1>
	DEFRULE	"N[I]NE",	<@AY>
	DEFRULE	"[I]<",		<@AY>
	DEFRULE	"[IN]D",	<@AY,@NN1>
	DEFRULE	"<:[I]%",	<@AY>
	DEFRULE	"<:[IED]<",	<@AY,@PA2,@DD1>
	DEFRULE	"#*[IED]<",	<@IY,@PA2,@DD1>
	DEFRULE	"FR[IE]ND",	<@EH>
	DEFRULE	"[IEN]",	<@IY,@IH,@NN1>
	DEFRULE	"[IE]T",	<@AY,@IH>
	DEFRULE	"[IER]",	<@IY,@ER1>
	DEFRULE	"[I]%",		<@IY>
	DEFRULE	"[IE]",		<@IY>
	DEFRULE	"[IN]%",	<@IY,@NN1>
	DEFRULE	"[IR]#",	<@AY,@ER1>
	DEFRULE	"[I]^%",	<@AY>
	DEFRULE	"[I]^+:#",	<@IH>
	DEFRULE	"[IZ]%",	<@AY,@ZZ>
	DEFRULE	"[IS]%",	<@AY,@ZZ>
	DEFRULE	"[I]$%",	<@AY>
	DEFRULE	"+^[I]^+",	<@IH>
	DEFRULE	"[I]T%",	<@AY>
	DEFRULE	"#*[I]^+",	<@IH>
	DEFRULE	"[IR]",		<@ER2>
	DEFRULE	"*[I]ON",	<@YY1>
	DEFRULE	"[IGH]",	<@AY>
	DEFRULE	"[ILD]",	<@AY,@EL,@PA2,@DD1>
	DEFRULE	"[IGN]",	<@AY,@NN1>
	DEFRULE	"[IGN]^",	<@AY,@NN1>
	DEFRULE	"[IGN]%",	<@AY,@NN1>
	DEFRULE	"[IQUE]",	<@IY,@PA3,@KK2>
	DEFRULE	"[I]A",		<@AY>
	DEFRULE	"M[I]C",	<@AY>
	DEFRULE	"[I]",		<@IH>

	; Rules for 'J'
RULESJ	INITIAL	"J"
	DEFRULE	"<[J]<",	<@PA2,@JH,@EY>
	DEFRULE	"[J]",		<@PA2,@JH>

	; Rules for 'K'
RULESK	INITIAL	"K"
	DEFRULE	"<[K]<",	<@PA3,@KK1,@EY>
	DEFRULE	"<[K]N",	<>
	DEFRULE	"[K]<",		<@PA3,@KK2>
	DEFRULE	"[K]",		<@PA3,@KK1>

	; Rules for 'L'
RULESL	INITIAL	"L"
	DEFRULE	"<[L]<",	<@EH,@EH,@LL>
	DEFRULE	"[LO]C#",	<@LL,@OW>
	DEFRULE	"[L]L",		<>
	DEFRULE	"[L]%",		<@EL>
	DEFRULE	"[LEAD]",	<@LL,@IY,@PA2,@DD1>
	DEFRULE	"[LAUGH]",	<@LL,@AE,@FF>
	DEFRULE	"[L]",		<@LL>

	; Rules for 'M'
RULESM	INITIAL	"M"
	DEFRULE	"[MB]",		<@MM>
	DEFRULE	"<[M]<",	<@EH,@EH,@MM>
	DEFRULE	"[MOV]",	<@MM,@UW2,@VV>
	DEFRULE	"[M]M",		<>
	DEFRULE	"[M]",		<@MM>

	; Rules for 'N'
RULESN	INITIAL	"N"
	DEFRULE	"<[N]<",	<@EH,@EH,@NN1>
	DEFRULE	"E[NG]+",	<@NN1,@PA2,@JH>
	DEFRULE	"[NG]R",	<@NG,@PA2,@GG1>
	DEFRULE	"[NG]#",	<@NG,@PA2,@GG1>
	DEFRULE	"[NGL]%",	<@NG,@PA2,@GG1,@EL>
	DEFRULE	"[NG]",		<@NG>
	DEFRULE	"[NK]<",	<@NG,@PA3,@KK2>
	DEFRULE	"[NK]S",	<@NG,@PA3,@KK2>
	DEFRULE	"[NK]",		<@NG,@PA3,@KK1>
	DEFRULE	"<[NOW]<",	<@NN2,@AW>
	DEFRULE	"[N]N",		<>
	DEFRULE	"#:[NU]",	<@NN1,@YY1,@UW1>
	DEFRULE	"<[N]",		<@NN2>
	DEFRULE	"[N'T]",	<@NN1,@PA3,@TT2>
	DEFRULE	"[N]",		<@NN1>

	; Rules for 'O'
RULESO	INITIAL	"O"
	DEFRULE	"<[O]<",	<@OW>
	DEFRULE	"[OF]<",	<@AX,@VV>
	DEFRULE	"[OROUGH]",	<@AX,@AX,@RR2,@OW>
	DEFRULE	"#:[OR]<",	<@ER1>
	DEFRULE	"#:[ORS]<",	<@ER1,@ZZ>
	DEFRULE	"[OR]",		<@OR>
	DEFRULE	"<[ONE]",	<@WW,@AX,@NN1>
	DEFRULE	"+[ONE]",	<@WW,@AX,@NN1>
	DEFRULE	"*[OW]N",	<@AW>
	DEFRULE	"[OW]",		<@OW>
	DEFRULE	"<[OVER]",	<@OW,@VV,@ER1>
	DEFRULE	"[OV]",		<@AX,@VV>
	DEFRULE	"[O]^%",	<@OW>
	DEFRULE	"[O]^EN",	<@OW>
	DEFRULE	"[O]^I#",	<@OW>
	DEFRULE	"[OL]D",	<@OW,@LL>
	DEFRULE	"[OUGHT]",	<@AO,@AO,@PA3,@TT2>
	DEFRULE	"[OUGH]",	<@AX,@AX,@FF>
	DEFRULE	"&[OUR]",	<@OR>
	DEFRULE	":[OUR]",	<@AW,@ER1>
	DEFRULE	"<[OU]",	<@AW>
	DEFRULE	":[OU]S#",	<@AW>
	DEFRULE	"[OUS]",	<@AX,@SS>
	DEFRULE	"[OULD]",	<@UH,@PA2,@DD1>
	DEFRULE	"^[OU]^L",	<@AX>
	DEFRULE	"[OUP]",	<@UW2,@PA3,@PP>
	DEFRULE	"[OU]",		<@AW>
	DEFRULE	"[OY]",		<@OY>
	DEFRULE	"[OING]",	<@OW,@IH,@NG>
	DEFRULE	"[OI]",		<@OY>
	DEFRULE	"[OOR]",	<@OR>
	DEFRULE	"[OOK]<",	<@UH,@PA3,@KK2>
	DEFRULE	"[OOK]S",	<@UH,@PA3,@KK2>
	DEFRULE	"[OOK]",	<@UH,@PA3,@KK1>
	DEFRULE	"[OOD]<",	<@UH,@PA2,@DD1>
	DEFRULE	"[OO]D",	<@UH>
	DEFRULE	"[OO]",		<@UW2>
	DEFRULE	"[O]E",		<@OW>
	DEFRULE	"[O]<",		<@OW>
	DEFRULE	"[OAR]",	<@OR>
	DEFRULE	"[OA]",		<@OW>
	DEFRULE	"<[ONLY]",	<@OW,@NN1,@LL,@IY>
	DEFRULE	"<[ONCE]",	<@WW,@AX,@NN1,@SS>
	DEFRULE	"[ON'T]",	<@OW,@NN1,@PA3,@TT2>
	DEFRULE	"C[O]N",	<@AX>
	DEFRULE	"[O]NG",	<@AO>
	DEFRULE	"<*[O]N",	<@AX>
	DEFRULE	"I[ON]",	<@AX,@NN1>
	DEFRULE	"#:[ON]<",	<@AX,@NN1>
	DEFRULE	"[O]ST<",	<@OW>
	DEFRULE	"[OF]^",	<@AO,@FF>
	DEFRULE	"[OTHER]",	<@AX,@DH2,@ER1>
	DEFRULE	"[OSS]<",	<@AO,@AO,@SS,@SS>
	DEFRULE	"#*[OM]",	<@AX,@MM>
	DEFRULE	"[O]",		<@AA>

	; Rules for 'P'
RULESP	INITIAL	"P"
	DEFRULE	"[PSYCH]",	<@SS,@SS,@AY,@PA2,@KK1>
	DEFRULE	"<[P]<",	<@PA3,@PP,@IY>
	DEFRULE	"[PH]",		<@FF>
	DEFRULE	"[PEOP]",	<@PA3,@PP,@IY,@PA3,@PP>
	DEFRULE	"[POW]",	<@PA3,@PP,@AW>
	DEFRULE	"[PUT]<",	<@PA3,@PP,@UH,@PA3,@TT2>
	DEFRULE	"[P]P",		<>
	DEFRULE	"[P]",		<@PA3,@PP>

	; Rules for 'Q'
RULESQ	INITIAL	"Q"
	DEFRULE	"<[Q]<",	<@PA3,@KK1,@YY1,@UW2>
	DEFRULE	"[QUAR]",	<@PA3,@KK3,@WH,@AA>
	DEFRULE	"[QUE]<",	<@PA3,@KK1,@YY1,@UW2>
	DEFRULE	"[QU]",		<@PA3,@KK3,@WH>
	DEFRULE	"[Q]",		<@PA3,@KK3>

	; Rules for 'R'
RULESR	INITIAL	"R"
	DEFRULE	"<[R]<",	<@AR>
	DEFRULE	"<[RE]^#",	<@RR1,@IY>
	DEFRULE	"[RH]",		<@RR1>
	DEFRULE	"[R]R",		<>
	DEFRULE	"*[R]",		<@RR2>
	DEFRULE	"[R]",		<@RR1>

	; Rules for 'S'
RULESS	INITIAL	"S"
	DEFRULE	"<[S]<",	<@EH,@EH,@SS,@SS>
	DEFRULE	"[SH]",		<@SH>
	DEFRULE	"#[SION]",	<@ZH,@AX,@NN1>
	DEFRULE	"[SOME]",	<@SS,@AX,@MM>
	DEFRULE	"#[SUR]#",	<@ZH,@ER1>
	DEFRULE	"[SUR]#",	<@SH,@ER1>
	DEFRULE	"#[SU]#",	<@ZH,@UW1>
	DEFRULE	"#[SSU]#",	<@SH,@UW1>
	DEFRULE	"#[SED]<",	<@ZZ,@PA2,@DD1>
	DEFRULE	"#[S]#",	<@ZZ>
	DEFRULE	"[SAID]",	<@SS,@SS,@EH,@EH,@PA2,@DD1>
	DEFRULE	"^[SION]",	<@SH,@AX,@NN1>
	DEFRULE	"[S]S",		<>
	DEFRULE	".[S]<",	<@ZZ>
	DEFRULE	"#:.E[S]<",	<@ZZ>
	DEFRULE	"#*?[S]<",	<@ZZ>
	DEFRULE	"#*#[S]<",	<@SS>
	DEFRULE	"U[S]<",	<@SS>
	DEFRULE	"<:#[S]<",	<@ZZ>
	DEFRULE	"<[SCH]",	<@SS,@SS,@PA3,@KK2>
	DEFRULE	"[S]C+",	<>
	DEFRULE	"#[SM]",	<@ZZ,@MM>
	DEFRULE	"#[S]N'",	<@ZZ>
	DEFRULE	"[S]<",		<@SS>
	DEFRULE	"[S]",		<@SS,@SS>

	; Rules for 'T'
RULEST	INITIAL	"T"
	DEFRULE	"[T]'S",	<@PA3,@TT1>
	DEFRULE	"[TCH]",	<@PA3,@CH>
	DEFRULE	"<[T]<",	<@PA3,@TT2,@IY>
	DEFRULE	"<[THE]<#",	<@DH1,@IY>
	DEFRULE	"<[THE]<",	<@DH1,@AX>
	DEFRULE	"[TO]<",	<@PA3,@TT2,@UW2>
	DEFRULE	"[TODAY]",	<@PA3,@TT2,@UW2,@DD2,@EY>
	DEFRULE	"[THA]^<",	<@DH1,@AE>
	DEFRULE	"<[THIS]<",	<@DH1,@IH,@SS,@SS>
	DEFRULE	"<[THEY]",	<@DH1,@EY>
	DEFRULE	"<[THERE]",	<@DH1,@XR>
	DEFRULE	"<[THER]",	<@TH,@ER1>
	DEFRULE	"[THER]",	<@DH2,@ER1>
	DEFRULE	"[THEIR]",	<@DH1,@XR>
	DEFRULE	"<[THEM]:",	<@DH1,@EH,@MM>
	DEFRULE	"[THESE]<",	<@DH1,@IY,@ZZ>
	DEFRULE	"<[THEN]",	<@DH1,@EH,@NN1>
	DEFRULE	"[THROUGH]<",	<@TH,@RR2,@UW2>
	DEFRULE	"[THOSE]",	<@DH1,@OW,@SS>
	DEFRULE	"[THOUGH]<",	<@DH1,@OW>
	DEFRULE	"<[THUS]",	<@DH1,@AX,@SS,@SS>
	DEFRULE	"[THE]<",	<@DH1>
	DEFRULE	"[TH]",		<@TH>
	DEFRULE	"#:[TED]<",	<@PA3,@TT2,@IH,@PA2,@DD1>
	DEFRULE	"S[TI]#N",	<@PA3,@CH>
	DEFRULE	"[TI]O",	<@SH>
	DEFRULE	"[TI]A",	<@SH>
	DEFRULE	"[TIEN]",	<@SH,@AX,@NN1>
	DEFRULE	"[TUR]#",	<@PA3,@CH,@ER1>
	DEFRULE	"[TU]A",	<@PA3,@CH,@UW1>
	DEFRULE	"<[TWO]",	<@PA3,@TT2,@UW2>
	DEFRULE	"[T]T",		<>
	DEFRULE	"[T]S",		<@PA3,@TT1>
	DEFRULE	"[T]",		<@PA3,@TT2>

	; Rules for 'U'
RULESU	INITIAL	"U"
	DEFRULE	"<[U]<",	<@YY1,@UW2>
	DEFRULE	"[UN]I",	<@YY2,@UW1,@NN1>
	DEFRULE	"<[UN]",	<@AX,@NN1>
	DEFRULE	"<[UPON]",	<@AX,@PA3,@PP,@AA,@NN1>
	DEFRULE	"@[UR]#",	<@UW1,@ER1>
	DEFRULE	"[UR]#",	<@YY1,@UW1,@ER1>
	DEFRULE	"[UR]*",	<@ER1>
	DEFRULE	"[U]^<",	<@AX>
	DEFRULE	"[U]^^",	<@AX>
	DEFRULE	"[UY]",		<@AY>
	DEFRULE	"<G[U]#",	<>
	DEFRULE	"G[U]%",	<>
	DEFRULE	"G[U]#",	<@WW>
	DEFRULE	"@[U]",		<@UW2>
	DEFRULE	"[U]",		<@YY1,@UW1>

	; Rules for 'V'
RULESV	INITIAL	"V"
	DEFRULE	"<[V]<",	<@VV,@IY>
	DEFRULE	"[VIEW]",	<@VV,@YY1,@UW2>
	DEFRULE	"[V]",		<@VV>

	; Rules for 'W'
RULESW	INITIAL	"W"
	DEFRULE	"<[W]<",	<@PA2,@DD2,@AX,@PA2,@BB2,@EL,@YY1,@UW1>
	DEFRULE	"<[WERE]",	<@WW,@ER2>
	DEFRULE	"<[WAS]<",	<@WW,@AX,@ZZ>
	DEFRULE	"[WA]S",	<@WW,@AA>
	DEFRULE	"[WA]T",	<@WW,@AO,@AO>
	DEFRULE	"[WAN]",	<@WW,@AA,@NN1>
	DEFRULE	"[WHERE]",	<@WH,@XR>
	DEFRULE	"[WHAT]",	<@WH,@AA,@PA3,@TT2>
	DEFRULE	"[WHOL]",	<@HH2,@OW,@LL>
	DEFRULE	"[WHO]",	<@HH2,@UW2>
	DEFRULE	"[WO]M",	<@WW,@AX>
	DEFRULE	"[WH]",		<@WH>
	DEFRULE	"[WAR]",	<@WW,@OR>
	DEFRULE	"[WOR]^",	<@WW,@ER1>
	DEFRULE	"[WR]",		<@RR1>
	DEFRULE	"[W]",		<@WW>

	; Rules for 'X'
RULESX	INITIAL	"X"
	DEFRULE	"<[X]<",	<@EH,@PA3,@KK2,@SS>
	DEFRULE	"<[X]",		<@ZZ>
	DEFRULE	"[X]",		<@PA3,@KK2,@SS>

	; Rules for 'Y'
RULESY	INITIAL	"Y"
	DEFRULE	"[YOUR]",	<@YY2,@OR>
	DEFRULE	"<[Y]<",	<@WW,@AY>
	DEFRULE	"[YOUNG]",	<@YY2,@AX,@NG>
	DEFRULE	"<[YOU]",	<@YY2,@UW2>
	DEFRULE	"[YEAR]:",	<@YY2,@YR>
	DEFRULE	"<[YES]",	<@YY2,@EH,@SS,@SS>
	DEFRULE	"<[Y]",		<@YY2>
	DEFRULE	"#*[Y]<",	<@IY>
	DEFRULE	"#*[Y]I",	<@IY>
	DEFRULE	"<:[Y]<",	<@AY>
	DEFRULE	"<:[Y]#",	<@AY>
	DEFRULE	"<:[Y]^+:#",	<@IH>
	DEFRULE	"<:[Y]^#",	<@AY>
	DEFRULE	"[Y]",		<@IH>

	; Rules for 'Z'
RULESZ	INITIAL	"Z"
	DEFRULE	"<[Z]<",	<@ZZ,@IY>
	DEFRULE	"[Z]Z",		<>
	DEFRULE	"[Z]",		<@ZZ>

	; Rules for digits
RULNUM	INITIAL	"#"
	DEFRULE	"[0]",		<@ZZ,@YR,@OW>
	DEFRULE	"[1]",		<@WW,@AX,@AX,@NN1>
	DEFRULE	"[2]",		<@PA3,@TT2,@UW2>
	DEFRULE	"[3]",		<@TH,@RR1,@IY>
	DEFRULE	"[4]",		<@FF,@OR>
	DEFRULE	"[5]",		<@FF,@AY,@VV>
	DEFRULE	"[6]",		<@SS,@SS,@IH,@PA3,@KK2,@SS>
	DEFRULE	"[7]",		<@SS,@SS,@EH,@VV,@IH,@NN1>
	DEFRULE	"[8]",		<@EY,@PA3,@TT2>
	DEFRULE	"[9]",		<@NN2,@AY,@NN1>


;	Total count of rules: 432

	; Index of rules tables
TABRUL	DW	RLPNCT
	DW	RULESA,RULESB,RULESC,RULESD
	DW	RULESE,RULESF,RULESG,RULESH
	DW	RULESI,RULESJ,RULESK,RULESL
	DW	RULESM,RULESN,RULESO,RULESP
	DW	RULESQ,RULESR,RULESS,RULEST
	DW	RULESU,RULESV,RULESW,RULESX
	DW	RULESY,RULESZ,RULNUM,0FFFFH

	END
