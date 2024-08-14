#include <stdio.h>
#include <io.h>
#include <ctype.h>
#include <stddef.h>
#include <string.h>

#include <fcntl.h>    // O_RDWR...
#include <sys/stat.h> // S_IWRITE

/* Allophones table:
	 0	 1	 2	 3	 4	 5	 6	 7	 8	 9	 A	 B	 C	 D	 E	 F
 0	PA1	PA2	PA3	PA4	PA5	OY	AY	EH	KK3	PP	JH	NN1	IH	TT2	RR1	AX
 1	MM	TT1	DH1	IY	EY	DD1	UW1	AO	AA	YY2	AE	HH1	BB1	TH	UH	UW2
 2	AW	DD2	GG3	VV	GG1	SH	ZH	RR2	FF	KK2	KK1	ZZ	NG	LL	WW	XR
 3	WH	YY1	CH	ER1	ER2	OW	DH2	SS	NN2	HH2	OR	AR	YR	GG2	EL	BB2
*/

char* allophones[] =
{
	"PA1",	"PA2",	"PA3",	"PA4",	"PA5",	"OY",	"AY",	"EH",
	"KK3",	"PP",	"JH",	"NN1",	"IH",	"TT2",	"RR1",	"AX",
	"MM",	"TT1",	"DH1",	"IY",	"EY",	"DD1",	"UW1",	"AO",
	"AA",	"YY2",	"AE",	"HH1",	"BB1",	"TH",	"UH",	"UW2",
	"AW",	"DD2",	"GG3",	"VV",	"GG1",	"SH",	"ZH",	"RR2",
	"FF",	"KK2",	"KK1",	"ZZ",	"NG",	"LL",	"WW",	"XR",
	"WH",	"YY1",	"CH",	"ER1",	"ER2",	"OW",	"DH2",	"SS",
	"NN2",	"HH2",	"OR",	"AR",	"YR",	"GG2",	"EL",	"BB2"

};

/* Patterns:
#	09	1+ vowels
.	0A	voiced consonant: B D G J L M N R V W X
%	0B	suffix: ER E ES ED ING ELY (FUL?)
&	0C	sibilant: S C G Z X J CH SH
@	0D	T S R D L Z N J TH CH SH preceding long U
^	0E	1 consonant
+	0F	front vowel: E I Y
:	10	0+ consonants
*	11	1+ consonants
>	12	back vowel: O U
<	13	Anything other than a letter
?	14	0+ vowels
$	1F	unknown pattern. Maybe 1 or more consonants followed by E or I
*/

char symbols[] =
{
	 0,		 0,		 0,		 0,		 0,		 0,		 0,		'\'',	// 00-07
	 0,		'#',	'.',	'%',	'&',	'@',	'^',	'+',	// 08-0F
	':',	'*',	'>',	'<',	'?',	 0,		 0,		 0,		// 10-17
	 0,		 0,		 0,		 0,		 0,		 0,		 0,		'$',	// 18-1F
	 0,		'A',	'B',	'C',	'D',	'E',	'F',	'G',	// 20-27
	'H',	'I',	'J',	'K',	'L',	'M',	'N',	'O',	// 28-2F
	'P',	'Q',	'R',	'S',	'T',	'U',	'V',	'W',	// 30-37
	'X',	'Y',	'Z',	 0,		 0,		 0,		 0,		 0		// 38-3F
};

#define INDEX_SIZE 28

char initials[INDEX_SIZE] =
{
	':', 	'A',	'B',	'C',	'D',	'E',	'F',	'G',
	'H',	'I',	'J',	'K',	'L',	'M',	'N',	'O',
	'P',	'Q',	'R',	'S',	'T',	'U',	'V',	'W',
	'X',	'Y',	'Z', 	'#'
};

int offsets[INDEX_SIZE+1];

int main( int argc, char* argv[] )
{
	FILE *infile=0, *outfile=0;
	int c, c0, ch, s;
	int p, p0, px;
	int i;
	int sig[] = {0x80,0x48,0x68,0x58,0x85};
	int bracket = 0;
	int allo = 0;
	int first;
	int count = 0;
	int	len = 0;

	infile = fopen("CTS256A.BIN", "rb");

	if ( errno )
	{
		puts( strerror( errno ) );
		return 1;
	}

	outfile = fopen( "RULES.ASM", "w" );

	if ( errno )
	{
		puts( strerror( errno ) );
		return 1;
	}

	p0 = p = 0;
	while( p < sizeof( sig ) / sizeof( int ) && !feof( infile ) )
	{
		c = fgetc( infile );
		++p0;
		if ( c == sig[p] )
			++p;
		else
			p = 0;
	}

	printf( "Signature found at %04X\n", p0 - p );

	p0 = 0xFFBC;
	offsets[INDEX_SIZE] = p0;

	fseek( infile, p0 & 0x0FFF, SEEK_SET );

	for ( i=0; i<INDEX_SIZE; ++i ) {
		c = fgetc( infile );
		c = ( c << 8 ) | fgetc( infile );
		offsets[i] = c;
	}

	fputs(
		";\tCode-To-Speech Rules extracted from CTS256A-AL2\n"
		";\t===============================================\n"
		"\n"
		"\n"
		";\tPatterns:\n"
		";\t---------\n"
		";\t#	09	one or more vowels\n"
		";\t.	0A	voiced consonant: B D G J L M N R V W X\n"
		";\t%	0B	suffix: ER E ES ED ING ELY (FUL?)\n"
		";\t&	0C	sibilant: S C G Z X J CH SH\n"
		";\t@	0D	T S R D L Z N J TH CH SH preceding long U\n"
		";\t^	0E	one consonant\n"
		";\t+	0F	front vowel: E I Y\n"
		";\t:	10	zero or more consonants\n"
		";\t*	11	one or more consonants\n"
		";\t>	12	back vowel: O U\n"
		";\t<	13	anything other than a letter\n"
		";\t?	14	two or more vowels\n"
		";\t$	1F	unknown pattern. Maybe 1 or more consonants followed by E or I\n"
		, outfile );

	for ( i=0; i<INDEX_SIZE; ++i ) {

		p0 = offsets[i];
		px = offsets[i+1];
		c0 = initials[i];

		fseek( infile, p0 & 0x0FFF, SEEK_SET );

		first = 1;

		if ( c0 == ':' )
			fprintf( outfile, "\n\t; Rules for punctuation\nRLPNCT" );
		else if ( c0 == '#' )
			fprintf( outfile, "\n\t; Rules for digits\nRULNUM" );
		else
			fprintf( outfile, "\n\t; Rules for '%c'\nRULES%c", c0, c0 );

		fprintf( outfile, "\tINITIAL\t\"%c\"\n", c0 );

		printf( "%04X-%04X : %c\n", p0, px, c0 );


		while ( p0 < px && !feof( infile ) )
		{
			if ( first ) {
				first = 0;
				fputs( "\tDEFRULE\t\"", outfile );
				len = 17;
			}

			c = fgetc( infile );

			// Opening bracket ?
			if ( c & 0x40 ) {
				if ( allo ) {
					fputs( "\",\t", outfile );
					len += 2; // exclude tab
					if ( len < 24 )
						fputc( '\t', outfile );
				}
				fputc( allo ? '<' :'[', outfile );
				++len;
				if ( !allo && c0 >= 'A' )
				{
					fputc( c0, outfile );
					++len;
				}
				bracket = 1;
			}

			ch = c & 0x3F;

			if ( !bracket )
			{
				// pattern outside brackets: use symbols table
				if ( s = symbols[ch] )
					fputc( s, outfile );
				else
					fprintf( outfile, "{%02X}", ch );
				++len;
			}
			else if ( allo )
			{
				// allophones inside brackets
				if ( c != 0xFF )
				{
					fputc( '_', outfile );
					fputs( allophones[ch], outfile );
					if ( !( c & 0x80 ) )
						fputc( ',', outfile );
				}
			}
			else
			{
				// pattern inside brackets
				if ( c != 0xFF )
				{
					fputc( ( ch ) + 0x20, outfile  );
					++len;
				}
			}

			// Closing bracket ?
			if ( c & 0x80 ) {
				fputc( allo ? '>' : ']', outfile );
				if ( allo ) {
					fputc( '\n', outfile );
					first = 1;
					++count;
				}
				allo = !allo;
				bracket = 0;
				++len;
			}

			++p0;
		}
	}

	fprintf( outfile, "\n\n;\tTotal count of rules: %d\n", count );

	printf( "Stopped at %04X\n", p0 );

	fclose( infile );
	fclose( outfile );
}

