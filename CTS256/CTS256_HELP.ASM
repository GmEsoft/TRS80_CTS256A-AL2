;CTS256_HELP.ASM

DEFLINE	MACRO	STR
	DB	'STR'
	IF	CPM
	  DB	0DH,0AH
	ENDIF
	IF	LSDOS6
	  DB	0AH
	ENDIF
	ENDM

;-----	Title and Help text
MSG_HELP:	; Help text
	IF	DRIVER
	  IF	FILTER
	    DB	"** Software CTS256A-AL2 Code-To-Speech Filter"
	  ELSE
	    DB	"** Software CTS256A-AL2 Code-To-Speech Driver"
	  ENDIF
	ENDIF

	IF	EXEC
	  DB	"** Software CTS256A-AL2 Code-To-Speech Processor"
	ENDIF

	DEFLINE " - v0.2.0-alpha **"
	DEFLINE	""
	DEFLINE	"Converted from GI/Microchip CTS256A-AL2 device By GmEsoft"

	IF	EXEC		; Executable mode
	  DEFLINE "Specify English text, Allophones (inside brackets) or filename to speech."
	  DEFLINE "Examples:"
	  DEFLINE "  CTS256 Hello world!! I''m a [KK3AAMMPA3PPYY1UW1PA3TT2ER1]"
	  IF	CPM
	    DEFLINE "  CTS256 speech.txt"
	  ENDIF
	  IF	LSDOS6
	    DEFLINE "  CTS256 speech/txt"
	  ENDIF
	  DEFLINE ""
	ENDIF			; EXEC - Executable mode

	IF	CPM
	  DB	'$'
	ENDIF
	IF	LSDOS6
	  DB	3
	ENDIF

	END

