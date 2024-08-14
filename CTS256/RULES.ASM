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
;	$	1F	unknown pattern. Maybe 1 or more consonants followed by E or I

	; Rules for punctuation
RLPNCT	INITIAL	":"
	DEFRULE	"[-]",		<_PA1>
	DEFRULE	".['S]",	<_ZZ>
	DEFRULE	"#:.E['S]",	<_ZZ>
	DEFRULE	"#['S]",	<_ZZ>
	DEFRULE	"['S]",		<_SS>
	DEFRULE	"[']",		<>
	DEFRULE	"[,]",		<_PA4>
	DEFRULE	"[;]",		<_PA4>
	DEFRULE	"[ ]",		<_PA2>
	DEFRULE	"[.]",		<_PA5,_PA5>
	DEFRULE	"[!]",		<_PA5,_PA5>
	DEFRULE	"[?]",		<_PA5,_PA5>
	DEFRULE	"[:]",		<_PA5>
	DEFRULE	"[%]",		<_PP,_ER2,_SS,_SS,_EH,_NN1,_TT2,_PA1>
	DEFRULE	"[$]",		<_DD2,_AA,_LL,_ER1,_ZZ,_PA1>
	DEFRULE	"[#]",		<_NN2,_AX,_MM,_BB1,_ER1,_PA1>
	DEFRULE	"[]",		<_PA3>

	; Rules for 'A'
RULESA	INITIAL	"A"
	DEFRULE	"<[A]<",	<_EY>
	DEFRULE	"[ACHE]",	<_EY,_PA3,_KK2>
	DEFRULE	"[A]<",		<_AX>
	DEFRULE	"<[ARE]<",	<_AR>
	DEFRULE	"^[AS]#",	<_EY,_SS>
	DEFRULE	"<[AR]O",	<_AX,_RR2>
	DEFRULE	"<[A]^R",	<_AX>
	DEFRULE	"[AR]#",	<_XR>
	DEFRULE	"<:[ANY]",	<_EH,_NN1,_IY>
	DEFRULE	"[AGAIN]",	<_AX,_PA2,_GG1,_EH,_EH,_NN1>
	DEFRULE	"[A]WA",	<_AX>
	DEFRULE	"[AW]",		<_AO,_AO>
	DEFRULE	"<:[A]^+<",	<_EY>
	DEFRULE	"<[A]^#",	<_AX>
	DEFRULE	"[A]^+#",	<_EY>
	DEFRULE	"#:[ALLY]",	<_AX,_LL,_IY>
	DEFRULE	"<[AL]#",	<_AX,_LL>
	DEFRULE	"#:[AG]E",	<_IH,_PA2,_JH>
	DEFRULE	"[A]^%",	<_EY>
	DEFRULE	"[A]^+:#",	<_AE>
	DEFRULE	"<[ARR]",	<_AX,_RR2>
	DEFRULE	"[ARR]",	<_AE,_RR2>
	DEFRULE	"<:[AR]<",	<_AR>
	DEFRULE	"[AR]<",	<_ER1>
	DEFRULE	"[AR]",		<_AR>
	DEFRULE	"[AIR]",	<_EH,_XR>
	DEFRULE	"[AI]",		<_EY>
	DEFRULE	"[AY]",		<_EY>
	DEFRULE	"[AU]",		<_AO>
	DEFRULE	"#:[AL]<",	<_EL>
	DEFRULE	"#:[ALS]<",	<_EL,_ZZ>
	DEFRULE	"[ALK]",	<_AO,_PA3,_KK2>
	DEFRULE	"[A]L^",	<_AO>
	DEFRULE	"<:[ABLE]",	<_EY,_PA2,_BB2,_EL>
	DEFRULE	"[ABLE]",	<_AX,_PA2,_BB2,_EL>
	DEFRULE	"[ANG]+",	<_EY,_NN1,_PA2,_JH>
	DEFRULE	"[A]",		<_AE>

	; Rules for 'B'
RULESB	INITIAL	"B"
	DEFRULE	"<[B]<",	<_PA2,_BB2,_IY>
	DEFRULE	"MAY[BE]",	<_BB2,_IY>
	DEFRULE	"<[BE]^#",	<_PA2,_BB2,_IY>
	DEFRULE	"<[BEEN]<",	<_BB2,_IH,_NN1>
	DEFRULE	"<[BOTH]<",	<_PA2,_BB2,_OW,_TH>
	DEFRULE	"<[BUS]#",	<_PA2,_BB2,_IH,_ZZ>
	DEFRULE	"[BUIL]",	<_PA2,_BB2,_IH,_IH,_LL>
	DEFRULE	"[B]B",		<>
	DEFRULE	"[B]<",		<_PA2,_BB1>
	DEFRULE	"[B]S",		<_PA2,_BB1>
	DEFRULE	"[BT]",		<_PA3,_TT2>
	DEFRULE	"<[B]^",	<_PA2,_BB1>
	DEFRULE	"[B]",		<_PA2,_BB2>

	; Rules for 'C'
RULESC	INITIAL	"C"
	DEFRULE	"<[C]<",	<_SS,_SS,_IY>
	DEFRULE	"<[CH]^",	<_PA3,_KK1>
	DEFRULE	"^E[CH]",	<_PA3,_KK1>
	DEFRULE	"[CH]",		<_PA3,_CH>
	DEFRULE	"S[CI]#",	<_SS,_SS,_AY>
	DEFRULE	"[CI]#",	<_SH>
	DEFRULE	"[CI]O",	<_SH>
	DEFRULE	"[CI]EN",	<_SH>
	DEFRULE	"[C]+",		<_SS,_SS>
	DEFRULE	"C[C]",		<>
	DEFRULE	"[CK]#",	<_PA3,_KK1>
	DEFRULE	"[CK]",		<_PA3,_KK2>
	DEFRULE	"[COM]%",	<_PA3,_KK3,_AX,_MM>
	DEFRULE	"[CC]+",	<_PA3,_KK1,_SS,_SS>
	DEFRULE	"[C]<",		<_PA3,_KK2>
	DEFRULE	"[C]S",		<_PA3,_KK2>
	DEFRULE	"[C]>",		<_PA3,_KK3>
	DEFRULE	"[C]",		<_PA3,_KK1>

	; Rules for 'D'
RULESD	INITIAL	"D"
	DEFRULE	"<[D]<",	<_PA2,_DD2,_IY>
	DEFRULE	"[D]D",		<>
	DEFRULE	"#:[DED]<",	<_PA2,_DD2,_IH,_PA2,_DD1>
	DEFRULE	".E[D]<",	<_PA2,_DD1>
	DEFRULE	"#*E[D]<",	<_PA3,_TT2>
	DEFRULE	"<[DE]^#",	<_PA2,_DD2,_IH>
	DEFRULE	"<[DO]<",	<_PA2,_DD2,_UW2>
	DEFRULE	"<[DOES]",	<_PA2,_DD2,_AX,_ZZ>
	DEFRULE	"<[DOING]",	<_PA2,_DD2,_UW2,_IH,_NG>
	DEFRULE	"<[DOW]",	<_PA2,_DD2,_AW>
	DEFRULE	"#[DU]:A",	<_PA2,_JH,_UW1>
	DEFRULE	"[DG]",		<_PA2,_JH>
	DEFRULE	"[DJ]",		<_PA2,_JH>
	DEFRULE	"[D]<",		<_PA2,_DD1>
	DEFRULE	"[D]S",		<_PA2,_DD1>
	DEFRULE	"[D]",		<_PA2,_DD2>

	; Rules for 'E'
RULESE	INITIAL	"E"
	DEFRULE	"<[E]<",	<_IY>
	DEFRULE	"#:[E]<",	<>
	DEFRULE	"'*[E]<",	<>
	DEFRULE	"*[E]<",	<_IY>
	DEFRULE	"#[ED]<",	<_PA2,_DD1>
	DEFRULE	"#:[E]D<",	<>
	DEFRULE	"[EV]ER",	<_EH,_VV>
	DEFRULE	"#*[EL]",	<_EL>
	DEFRULE	"[ERI]#",	<_YR,_IY>
	DEFRULE	"#:[ER]#",	<_ER1>
	DEFRULE	"[E]^%",	<_IY>
	DEFRULE	"[ERI]",	<_EH,_EH,_RR1,_IH>
	DEFRULE	"[ER]#",	<_EH,_XR>
	DEFRULE	"[ER]",		<_ER1>
	DEFRULE	"<[EVEN]<",	<_IY,_VV,_IH,_NN1>
	DEFRULE	"<[EVEN]",	<_IY,_VV,_EH,_EH,_NN1>
	DEFRULE	"#:[EW]",	<_YY1,_UW2>
	DEFRULE	"@[EW]",	<_UW2>
	DEFRULE	"[EW]",		<_YY1,_UW2>
	DEFRULE	"[E]O",		<_IY>
	DEFRULE	"#:&[ES]<",	<_IH,_ZZ>
	DEFRULE	"#:[E]S<",	<>
	DEFRULE	"#:[ELY]<",	<_LL,_IY>
	DEFRULE	"#:[EMENT]",	<_MM,_IH,_NN1,_PA3,_TT2>
	DEFRULE	"[EFUL]",	<_FF,_UH,_LL>
	DEFRULE	"[EER]",	<_YR>
	DEFRULE	"[EE]",		<_IY>
	DEFRULE	"[EARN]",	<_ER2,_NN1>
	DEFRULE	"<[EAR]^",	<_ER2>
	DEFRULE	"*[EAR]",	<_YR>
	DEFRULE	"[EAD]",	<_EH,_EH,_PA2,_DD1>
	DEFRULE	"#:[EA]<",	<_IY,_AX>
	DEFRULE	"[EA]SU",	<_EH>
	DEFRULE	"[EA]",		<_IY>
	DEFRULE	"[EIGH]",	<_EY>
	DEFRULE	"[EI]",		<_IY>
	DEFRULE	"<[EYE]",	<_AY>
	DEFRULE	"[EY]",		<_IY>
	DEFRULE	"[EU]",		<_UW1>
	DEFRULE	"[E]",		<_EH>

	; Rules for 'F'
RULESF	INITIAL	"F"
	DEFRULE	"<[F]<",	<_EH,_EH,_FF>
	DEFRULE	"[FU]L",	<_FF,_UH>
	DEFRULE	"[F]F",		<>
	DEFRULE	"[FOUR]",	<_FF,_OR>
	DEFRULE	"[F]",		<_FF>

	; Rules for 'G'
RULESG	INITIAL	"G"
	DEFRULE	"<[G]<",	<_PA2,_JH,_IY>
	DEFRULE	"[GIV]",	<_PA2,_GG1,_IH,_VV>
	DEFRULE	"<[G]I^",	<_PA2,_GG1>
	DEFRULE	"[GE]T",	<_PA2,_GG1,_EH>
	DEFRULE	"SU[GGES]",	<_PA2,_GG2,_PA2,_JH,_EH,_EH,_SS>
	DEFRULE	"[GG]",		<_PA2,_GG1>
	DEFRULE	"[GREAT]",	<_PA2,_GG3,_RR2,_EY,_TT2>
	DEFRULE	"[G]<",		<_PA2,_GG3>
	DEFRULE	"<B#[G]",	<_PA2,_GG2>
	DEFRULE	"[G]+",		<_PA2,_JH>
	DEFRULE	"#[GH]",	<_FF>
	DEFRULE	"[GH]",		<_PA2,_GG2>
	DEFRULE	"[G]",		<_PA2,_GG2>

	; Rules for 'H'
RULESH	INITIAL	"H"
	DEFRULE	"<[H]<",	<_EY,_PA3,_CH>
	DEFRULE	"<[HAV]",	<_HH1,_AE,_VV>
	DEFRULE	"<[HERE]",	<_HH1,_YR>
	DEFRULE	"<[HOUR]",	<_AW,_ER1>
	DEFRULE	"[HOW]",	<_HH1,_AW>
	DEFRULE	"[HYP]",	<_HH1,_IH,_PA3,_PP>
	DEFRULE	"[H]>",		<_HH2>
	DEFRULE	"[H]#",		<_HH1>
	DEFRULE	"[H]",		<>

	; Rules for 'I'
RULESI	INITIAL	"I"
	DEFRULE	"<[IN]",	<_IH,_NN1>
	DEFRULE	"N[I]NE",	<_AY>
	DEFRULE	"[I]<",		<_AY>
	DEFRULE	"[IN]D",	<_AY,_NN1>
	DEFRULE	"<:[I]%",	<_AY>
	DEFRULE	"<:[IED]<",	<_AY,_PA2,_DD1>
	DEFRULE	"#*[IED]<",	<_IY,_PA2,_DD1>
	DEFRULE	"FR[IE]ND",	<_EH>
	DEFRULE	"[IEN]",	<_IY,_IH,_NN1>
	DEFRULE	"[IE]T",	<_AY,_IH>
	DEFRULE	"[IER]",	<_IY,_ER1>
	DEFRULE	"[I]%",		<_IY>
	DEFRULE	"[IE]",		<_IY>
	DEFRULE	"[IN]%",	<_IY,_NN1>
	DEFRULE	"[IR]#",	<_AY,_ER1>
	DEFRULE	"[I]^%",	<_AY>
	DEFRULE	"[I]^+:#",	<_IH>
	DEFRULE	"[IZ]%",	<_AY,_ZZ>
	DEFRULE	"[IS]%",	<_AY,_ZZ>
	DEFRULE	"[I]$%",	<_AY>
	DEFRULE	"+^[I]^+",	<_IH>
	DEFRULE	"[I]T%",	<_AY>
	DEFRULE	"#*[I]^+",	<_IH>
	DEFRULE	"[IR]",		<_ER2>
	DEFRULE	"*[I]ON",	<_YY1>
	DEFRULE	"[IGH]",	<_AY>
	DEFRULE	"[ILD]",	<_AY,_EL,_PA2,_DD1>
	DEFRULE	"[IGN]",	<_AY,_NN1>
	DEFRULE	"[IGN]^",	<_AY,_NN1>
	DEFRULE	"[IGN]%",	<_AY,_NN1>
	DEFRULE	"[IQUE]",	<_IY,_PA3,_KK2>
	DEFRULE	"[I]A",		<_AY>
	DEFRULE	"M[I]C",	<_AY>
	DEFRULE	"[I]",		<_IH>

	; Rules for 'J'
RULESJ	INITIAL	"J"
	DEFRULE	"<[J]<",	<_PA2,_JH,_EY>
	DEFRULE	"[J]",		<_PA2,_JH>

	; Rules for 'K'
RULESK	INITIAL	"K"
	DEFRULE	"<[K]<",	<_PA3,_KK1,_EY>
	DEFRULE	"<[K]N",	<>
	DEFRULE	"[K]<",		<_PA3,_KK2>
	DEFRULE	"[K]",		<_PA3,_KK1>

	; Rules for 'L'
RULESL	INITIAL	"L"
	DEFRULE	"<[L]<",	<_EH,_EH,_LL>
	DEFRULE	"[LO]C#",	<_LL,_OW>
	DEFRULE	"[L]L",		<>
	DEFRULE	"[L]%",		<_EL>
	DEFRULE	"[LEAD]",	<_LL,_IY,_PA2,_DD1>
	DEFRULE	"[LAUGH]",	<_LL,_AE,_FF>
	DEFRULE	"[L]",		<_LL>

	; Rules for 'M'
RULESM	INITIAL	"M"
	DEFRULE	"[MB]",		<_MM>
	DEFRULE	"<[M]<",	<_EH,_EH,_MM>
	DEFRULE	"[MOV]",	<_MM,_UW2,_VV>
	DEFRULE	"[M]M",		<>
	DEFRULE	"[M]",		<_MM>

	; Rules for 'N'
RULESN	INITIAL	"N"
	DEFRULE	"<[N]<",	<_EH,_EH,_NN1>
	DEFRULE	"E[NG]+",	<_NN1,_PA2,_JH>
	DEFRULE	"[NG]R",	<_NG,_PA2,_GG1>
	DEFRULE	"[NG]#",	<_NG,_PA2,_GG1>
	DEFRULE	"[NGL]%",	<_NG,_PA2,_GG1,_EL>
	DEFRULE	"[NG]",		<_NG>
	DEFRULE	"[NK]<",	<_NG,_PA3,_KK2>
	DEFRULE	"[NK]S",	<_NG,_PA3,_KK2>
	DEFRULE	"[NK]",		<_NG,_PA3,_KK1>
	DEFRULE	"<[NOW]<",	<_NN2,_AW>
	DEFRULE	"[N]N",		<>
	DEFRULE	"#:[NU]",	<_NN1,_YY1,_UW1>
	DEFRULE	"<[N]",		<_NN2>
	DEFRULE	"[N'T]",	<_NN1,_PA3,_TT2>
	DEFRULE	"[N]",		<_NN1>

	; Rules for 'O'
RULESO	INITIAL	"O"
	DEFRULE	"<[O]<",	<_OW>
	DEFRULE	"[OF]<",	<_AX,_VV>
	DEFRULE	"[OROUGH]",	<_AX,_AX,_RR2,_OW>
	DEFRULE	"#:[OR]<",	<_ER1>
	DEFRULE	"#:[ORS]<",	<_ER1,_ZZ>
	DEFRULE	"[OR]",		<_OR>
	DEFRULE	"<[ONE]",	<_WW,_AX,_NN1>
	DEFRULE	"+[ONE]",	<_WW,_AX,_NN1>
	DEFRULE	"*[OW]N",	<_AW>
	DEFRULE	"[OW]",		<_OW>
	DEFRULE	"<[OVER]",	<_OW,_VV,_ER1>
	DEFRULE	"[OV]",		<_AX,_VV>
	DEFRULE	"[O]^%",	<_OW>
	DEFRULE	"[O]^EN",	<_OW>
	DEFRULE	"[O]^I#",	<_OW>
	DEFRULE	"[OL]D",	<_OW,_LL>
	DEFRULE	"[OUGHT]",	<_AO,_AO,_PA3,_TT2>
	DEFRULE	"[OUGH]",	<_AX,_AX,_FF>
	DEFRULE	"&[OUR]",	<_OR>
	DEFRULE	":[OUR]",	<_AW,_ER1>
	DEFRULE	"<[OU]",	<_AW>
	DEFRULE	":[OU]S#",	<_AW>
	DEFRULE	"[OUS]",	<_AX,_SS>
	DEFRULE	"[OULD]",	<_UH,_PA2,_DD1>
	DEFRULE	"^[OU]^L",	<_AX>
	DEFRULE	"[OUP]",	<_UW2,_PA3,_PP>
	DEFRULE	"[OU]",		<_AW>
	DEFRULE	"[OY]",		<_OY>
	DEFRULE	"[OING]",	<_OW,_IH,_NG>
	DEFRULE	"[OI]",		<_OY>
	DEFRULE	"[OOR]",	<_OR>
	DEFRULE	"[OOK]<",	<_UH,_PA3,_KK2>
	DEFRULE	"[OOK]S",	<_UH,_PA3,_KK2>
	DEFRULE	"[OOK]",	<_UH,_PA3,_KK1>
	DEFRULE	"[OOD]<",	<_UH,_PA2,_DD1>
	DEFRULE	"[OO]D",	<_UH>
	DEFRULE	"[OO]",		<_UW2>
	DEFRULE	"[O]E",		<_OW>
	DEFRULE	"[O]<",		<_OW>
	DEFRULE	"[OAR]",	<_OR>
	DEFRULE	"[OA]",		<_OW>
	DEFRULE	"<[ONLY]",	<_OW,_NN1,_LL,_IY>
	DEFRULE	"<[ONCE]",	<_WW,_AX,_NN1,_SS>
	DEFRULE	"[ON'T]",	<_OW,_NN1,_PA3,_TT2>
	DEFRULE	"C[O]N",	<_AX>
	DEFRULE	"[O]NG",	<_AO>
	DEFRULE	"<*[O]N",	<_AX>
	DEFRULE	"I[ON]",	<_AX,_NN1>
	DEFRULE	"#:[ON]<",	<_AX,_NN1>
	DEFRULE	"[O]ST<",	<_OW>
	DEFRULE	"[OF]^",	<_AO,_FF>
	DEFRULE	"[OTHER]",	<_AX,_DH2,_ER1>
	DEFRULE	"[OSS]<",	<_AO,_AO,_SS,_SS>
	DEFRULE	"#*[OM]",	<_AX,_MM>
	DEFRULE	"[O]",		<_AA>

	; Rules for 'P'
RULESP	INITIAL	"P"
	DEFRULE	"[PSYCH]",	<_SS,_SS,_AY,_PA2,_KK1>
	DEFRULE	"<[P]<",	<_PA3,_PP,_IY>
	DEFRULE	"[PH]",		<_FF>
	DEFRULE	"[PEOP]",	<_PA3,_PP,_IY,_PA3,_PP>
	DEFRULE	"[POW]",	<_PA3,_PP,_AW>
	DEFRULE	"[PUT]<",	<_PA3,_PP,_UH,_PA3,_TT2>
	DEFRULE	"[P]P",		<>
	DEFRULE	"[P]",		<_PA3,_PP>

	; Rules for 'Q'
RULESQ	INITIAL	"Q"
	DEFRULE	"<[Q]<",	<_PA3,_KK1,_YY1,_UW2>
	DEFRULE	"[QUAR]",	<_PA3,_KK3,_WH,_AA>
	DEFRULE	"[QUE]<",	<_PA3,_KK1,_YY1,_UW2>
	DEFRULE	"[QU]",		<_PA3,_KK3,_WH>
	DEFRULE	"[Q]",		<_PA3,_KK3>

	; Rules for 'R'
RULESR	INITIAL	"R"
	DEFRULE	"<[R]<",	<_AR>
	DEFRULE	"<[RE]^#",	<_RR1,_IY>
	DEFRULE	"[RH]",		<_RR1>
	DEFRULE	"[R]R",		<>
	DEFRULE	"*[R]",		<_RR2>
	DEFRULE	"[R]",		<_RR1>

	; Rules for 'S'
RULESS	INITIAL	"S"
	DEFRULE	"<[S]<",	<_EH,_EH,_SS,_SS>
	DEFRULE	"[SH]",		<_SH>
	DEFRULE	"#[SION]",	<_ZH,_AX,_NN1>
	DEFRULE	"[SOME]",	<_SS,_AX,_MM>
	DEFRULE	"#[SUR]#",	<_ZH,_ER1>
	DEFRULE	"[SUR]#",	<_SH,_ER1>
	DEFRULE	"#[SU]#",	<_ZH,_UW1>
	DEFRULE	"#[SSU]#",	<_SH,_UW1>
	DEFRULE	"#[SED]<",	<_ZZ,_PA2,_DD1>
	DEFRULE	"#[S]#",	<_ZZ>
	DEFRULE	"[SAID]",	<_SS,_SS,_EH,_EH,_PA2,_DD1>
	DEFRULE	"^[SION]",	<_SH,_AX,_NN1>
	DEFRULE	"[S]S",		<>
	DEFRULE	".[S]<",	<_ZZ>
	DEFRULE	"#:.E[S]<",	<_ZZ>
	DEFRULE	"#*?[S]<",	<_ZZ>
	DEFRULE	"#*#[S]<",	<_SS>
	DEFRULE	"U[S]<",	<_SS>
	DEFRULE	"<:#[S]<",	<_ZZ>
	DEFRULE	"<[SCH]",	<_SS,_SS,_PA3,_KK2>
	DEFRULE	"[S]C+",	<>
	DEFRULE	"#[SM]",	<_ZZ,_MM>
	DEFRULE	"#[S]N'",	<_ZZ>
	DEFRULE	"[S]<",		<_SS>
	DEFRULE	"[S]",		<_SS,_SS>

	; Rules for 'T'
RULEST	INITIAL	"T"
	DEFRULE	"[T]'S",	<_PA3,_TT1>
	DEFRULE	"[TCH]",	<_PA3,_CH>
	DEFRULE	"<[T]<",	<_PA3,_TT2,_IY>
	DEFRULE	"<[THE]<#",	<_DH1,_IY>
	DEFRULE	"<[THE]<",	<_DH1,_AX>
	DEFRULE	"[TO]<",	<_PA3,_TT2,_UW2>
	DEFRULE	"[TODAY]",	<_PA3,_TT2,_UW2,_DD2,_EY>
	DEFRULE	"[THA]^<",	<_DH1,_AE>
	DEFRULE	"<[THIS]<",	<_DH1,_IH,_SS,_SS>
	DEFRULE	"<[THEY]",	<_DH1,_EY>
	DEFRULE	"<[THERE]",	<_DH1,_XR>
	DEFRULE	"<[THER]",	<_TH,_ER1>
	DEFRULE	"[THER]",	<_DH2,_ER1>
	DEFRULE	"[THEIR]",	<_DH1,_XR>
	DEFRULE	"<[THEM]:",	<_DH1,_EH,_MM>
	DEFRULE	"[THESE]<",	<_DH1,_IY,_ZZ>
	DEFRULE	"<[THEN]",	<_DH1,_EH,_NN1>
	DEFRULE	"[THROUGH]<",	<_TH,_RR2,_UW2>
	DEFRULE	"[THOSE]",	<_DH1,_OW,_SS>
	DEFRULE	"[THOUGH]<",	<_DH1,_OW>
	DEFRULE	"<[THUS]",	<_DH1,_AX,_SS,_SS>
	DEFRULE	"[THE]<",	<_DH1>
	DEFRULE	"[TH]",		<_TH>
	DEFRULE	"#:[TED]<",	<_PA3,_TT2,_IH,_PA2,_DD1>
	DEFRULE	"S[TI]#N",	<_PA3,_CH>
	DEFRULE	"[TI]O",	<_SH>
	DEFRULE	"[TI]A",	<_SH>
	DEFRULE	"[TIEN]",	<_SH,_AX,_NN1>
	DEFRULE	"[TUR]#",	<_PA3,_CH,_ER1>
	DEFRULE	"[TU]A",	<_PA3,_CH,_UW1>
	DEFRULE	"<[TWO]",	<_PA3,_TT2,_UW2>
	DEFRULE	"[T]T",		<>
	DEFRULE	"[T]S",		<_PA3,_TT1>
	DEFRULE	"[T]",		<_PA3,_TT2>

	; Rules for 'U'
RULESU	INITIAL	"U"
	DEFRULE	"<[U]<",	<_YY1,_UW2>
	DEFRULE	"[UN]I",	<_YY2,_UW1,_NN1>
	DEFRULE	"<[UN]",	<_AX,_NN1>
	DEFRULE	"<[UPON]",	<_AX,_PA3,_PP,_AA,_NN1>
	DEFRULE	"@[UR]#",	<_UW1,_ER1>
	DEFRULE	"[UR]#",	<_YY1,_UW1,_ER1>
	DEFRULE	"[UR]*",	<_ER1>
	DEFRULE	"[U]^<",	<_AX>
	DEFRULE	"[U]^^",	<_AX>
	DEFRULE	"[UY]",		<_AY>
	DEFRULE	"<G[U]#",	<>
	DEFRULE	"G[U]%",	<>
	DEFRULE	"G[U]#",	<_WW>
	DEFRULE	"@[U]",		<_UW2>
	DEFRULE	"[U]",		<_YY1,_UW1>

	; Rules for 'V'
RULESV	INITIAL	"V"
	DEFRULE	"<[V]<",	<_VV,_IY>
	DEFRULE	"[VIEW]",	<_VV,_YY1,_UW2>
	DEFRULE	"[V]",		<_VV>

	; Rules for 'W'
RULESW	INITIAL	"W"
	DEFRULE	"<[W]<",	<_PA2,_DD2,_AX,_PA2,_BB2,_EL,_YY1,_UW1>
	DEFRULE	"<[WERE]",	<_WW,_ER2>
	DEFRULE	"<[WAS]<",	<_WW,_AX,_ZZ>
	DEFRULE	"[WA]S",	<_WW,_AA>
	DEFRULE	"[WA]T",	<_WW,_AO,_AO>
	DEFRULE	"[WAN]",	<_WW,_AA,_NN1>
	DEFRULE	"[WHERE]",	<_WH,_XR>
	DEFRULE	"[WHAT]",	<_WH,_AA,_PA3,_TT2>
	DEFRULE	"[WHOL]",	<_HH2,_OW,_LL>
	DEFRULE	"[WHO]",	<_HH2,_UW2>
	DEFRULE	"[WO]M",	<_WW,_AX>
	DEFRULE	"[WH]",		<_WH>
	DEFRULE	"[WAR]",	<_WW,_OR>
	DEFRULE	"[WOR]^",	<_WW,_ER1>
	DEFRULE	"[WR]",		<_RR1>
	DEFRULE	"[W]",		<_WW>

	; Rules for 'X'
RULESX	INITIAL	"X"
	DEFRULE	"<[X]<",	<_EH,_PA3,_KK2,_SS>
	DEFRULE	"<[X]",		<_ZZ>
	DEFRULE	"[X]",		<_PA3,_KK2,_SS>

	; Rules for 'Y'
RULESY	INITIAL	"Y"
	DEFRULE	"[YOUR]",	<_YY2,_OR>
	DEFRULE	"<[Y]<",	<_WW,_AY>
	DEFRULE	"[YOUNG]",	<_YY2,_AX,_NG>
	DEFRULE	"<[YOU]",	<_YY2,_UW2>
	DEFRULE	"[YEAR]:",	<_YY2,_YR>
	DEFRULE	"<[YES]",	<_YY2,_EH,_SS,_SS>
	DEFRULE	"<[Y]",		<_YY2>
	DEFRULE	"#*[Y]<",	<_IY>
	DEFRULE	"#*[Y]I",	<_IY>
	DEFRULE	"<:[Y]<",	<_AY>
	DEFRULE	"<:[Y]#",	<_AY>
	DEFRULE	"<:[Y]^+:#",	<_IH>
	DEFRULE	"<:[Y]^#",	<_AY>
	DEFRULE	"[Y]",		<_IH>

	; Rules for 'Z'
RULESZ	INITIAL	"Z"
	DEFRULE	"<[Z]<",	<_ZZ,_IY>
	DEFRULE	"[Z]Z",		<>
	DEFRULE	"[Z]",		<_ZZ>

	; Rules for digits
RULNUM	INITIAL	"#"
	DEFRULE	"[0]",		<_ZZ,_YR,_OW>
	DEFRULE	"[1]",		<_WW,_AX,_AX,_NN1>
	DEFRULE	"[2]",		<_PA3,_TT2,_UW2>
	DEFRULE	"[3]",		<_TH,_RR1,_IY>
	DEFRULE	"[4]",		<_FF,_OR>
	DEFRULE	"[5]",		<_FF,_AY,_VV>
	DEFRULE	"[6]",		<_SS,_SS,_IH,_PA3,_KK2,_SS>
	DEFRULE	"[7]",		<_SS,_SS,_EH,_VV,_IH,_NN1>
	DEFRULE	"[8]",		<_EY,_PA3,_TT2>
	DEFRULE	"[9]",		<_NN2,_AY,_NN1>


;	Total count of rules: 432
