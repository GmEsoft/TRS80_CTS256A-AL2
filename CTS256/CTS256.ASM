;
; 	** CP/M CTS256.COM - LS-DOS 6 CTS256/CMD, CTS256/DVR & CTS256/FLT - v0.0.0-alpha **
;
;
;	Assemble using ZMAC from http://48k.ca/zmac.html
;	- For CP/M (Montezuma Micro CP/M 2.x):
;		ZMAC --zmac CTS256.ASM -P0=2 --od . --oo CIM,LST,BDS
;		and rename CTS256.CIM to CTS256.COM
;	- For LS-DOS 6.3 executable:
;		ZMAC --zmac CTS256.ASM -P0=3 --od . --oo CMD,LST,BDS
;	- For LS-DOS 6.3 driver:
;		ZMAC --zmac CTS256.ASM -P0=4 --od . --oo CIM,LST,BDS
;		and rename CTS256.CMD to CTS256.DVR
;		To load:
;			SET *CT CTS256/DVR
;		Caution: Don't route/link *PR to CTS256! Use the Filter for that purpose.
;	- For LS-DOS 6.3 filter:
;		ZMAC --zmac CTS256.ASM -P0=5 --od . --oo CIM,LST,BDS
;		and rename CTS256.CMD to CTS256.FLT
;		To load:
;			SET *CT CTS256/FLT
;			FILTER *PR *CT

;==================================================================================================
;	C O N F I G
;==================================================================================================

; Search labels
;	$BREAK
;	YLDCTS
;	ENCODE
;	ENDPOL

@@DEBUG	EQU	0
@@EIBRK	EQU	0

	JPERROR 0		; Error if JP can be a JR

VERSION	MACRO			; Version number
	DB	"v0.3.0-alpha"
	ENDM

	IF	@@0
CONFIG	  EQU	@@0
	ELSE
CONFIG	  EQU	4
	ENDIF


	IF	CONFIG = 2	; TRS-80 Model 4 CP/M + Orchestra 90
CPM	  EQU	1		; CP/M version
LSDOS6	  EQU	0		; LS-DOS version
EXEC	  EQU	1		; Executable Mode
DRIVER	  EQU	0		; LS-DOS Driver/Filter Mode
FILTER	  EQU	0		; LS-DOS Filter Mode
	ENDIF

	IF	CONFIG = 3	; TRS-80 Model 4 LS-DOS 6 + Orchestra 90
CPM	  EQU	0		; CP/M version
LSDOS6	  EQU	1		; LS-DOS version
EXEC	  EQU	1		; Executable Mode
DRIVER	  EQU	0		; LS-DOS Driver/Filter Mode
FILTER	  EQU	0		; LS-DOS Filter Mode
	ENDIF

	IF	CONFIG = 4	; TRS-80 Model 4 /DVR for LS-DOS 6 + Orchestra 90
CPM	  EQU	0		; CP/M version
LSDOS6	  EQU	1		; LS-DOS version
EXEC	  EQU	0		; Executable
DRIVER	  EQU	1		; LS-DOS Driver/Filter Mode
FILTER	  EQU	0		; LS-DOS Filter Mode
	ENDIF

	IF	CONFIG = 5	; TRS-80 Model 4 /FLT for LS-DOS 6 + Orchestra 90
CPM	  EQU	0		; CP/M version
LSDOS6	  EQU	1		; LS-DOS version
EXEC	  EQU	0		; Executable
DRIVER	  EQU	1		; LS-DOS Driver/Filter Mode
FILTER	  EQU	1		; LS-DOS Filter Mode
	ENDIF

	IFNDEF	EXEC
	 ASSERT	0		; Invalid config selected
	 END
	ENDIF


;==================================================================================================
;	M A C R O S
;==================================================================================================

ON	EQU	1
OFF	EQU	0

	INCLUDE	"CTS256_DBG.ASM"



;==================================================================================================
;	S Y M B O L S
;==================================================================================================

;-----	LS-DOS 6 SVC equates
	IF	LSDOS6

	  INCLUDE "LSDOSSVC.EQU"

;-----	  Invoke SVC
$SVC	  MACRO	#NUM
	   LD	A,#NUM
	   RST	28H
	  ENDM

CMDLINE	  EQU	0000H		; dummy

	ENDIF

;-----	CP/M BDOS EQUATES equates
	IF	CPM
BDOS	  EQU	0005H
D007C	  EQU	007CH
D0080	  EQU	0080H
CMDLINE	  EQU	0082H
	ENDIF

LF	EQU	10
CR	EQU	13

	IF	CPM
	  ORG	0100H		; CP/M Entry Point
	ENDIF

	IF	LSDOS6
	  ORG	3000H		; LS-DOS 6 Entry Point
	ENDIF

	IF	DRIVER		; Driver/Filter
	INCLUDE "CTS256_DVRFLT.ASM"
	ENDIF			; DRIVER - Driver Mode

	IF	EXEC		; Executable mode
	INCLUDE	"CTS256_EXEC.ASM"
	ENDIF			; end EXEC - Executable mode

	INCLUDE	"CTS256_HELP.ASM"

	INCLUDE	"CTS256_LINK.ASM"

	INCLUDE	"CTS256_SP0256.ASM"

	INCLUDE	"CTS256_WRAPPER.ASM"

	INCLUDE	"CTS256_MODULE.ASM"

;==================================================================================================
;	B U F F E R S
;==================================================================================================

	DS	LOW(100H-LOW $)	; Align on page boundary (mandatory!)
CTSXRAM	DS	1000H		; 16 pages CTS256A-AL2 external RAM

SP0256	DS	100H		; SP0256A-AL2 allophones are written via the address bus

CTSSTK0	DS	40H		; CTS256A-mode stack
CTSSTK	EQU	$		; stack origin

PARLINP	DS	1		; Parallel input

MODEND	EQU	$

	END	ENTRY

;==============================================================================

