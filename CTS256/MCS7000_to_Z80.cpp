#include <iostream>
#include <sstream>
#include <vector>
#include <string>

const bool origcode = true;	// Output original source in comment

using namespace std;

namespace ops
{
	// Z-80 mnemonics
	const string
		ORG = "\tORG\t",
		NOP = "\tNOP\t",
		HALT= "\tHALT\t",
		LD 	= "\tLD\t",
		EX	= "\tEX\t",
		PUSH= "\tPUSH\t",
		POP	= "\tPOP\t",
		AND	= "\tAND\t",
		OR	= "\tOR\t",
		XOR	= "\tXOR\t",
		CPL	= "\tCPL\t",
		NEG	= "\tNEG\t",
		RLCA= "\tRLCA\t",
		RLC	= "\tRLC\t",
		RLA	= "\tRLA\t",
		RL	= "\tRL\t",
		RRCA= "\tRRCA\t",
		RRC	= "\tRRC\t",
		RRA	= "\tRRA\t",
		RR	= "\tRR\t",
		SET	= "\tSET\t",
		RES	= "\tRES\t",
		BIT	= "\tBIT\t",
		ADD	= "\tADD\t",
		ADC	= "\tADC\t",
		SUB	= "\tSUB\t",
		SBC	= "\tSBC\t",
		CP	= "\tCP\t",
		INC	= "\tINC\t",
		DEC	= "\tDEC\t",
		JP	= "\tJP\t",
		JR	= "\tJR\t",
		CALL= "\tCALL\t",
		RET	= "\tRET\t",
		DJNZ= "\tDJNZ\t",
		IN	= "\tIN\t",
		OUT = "\tOUT\t",
		EI	= "\tEI\t",
		DI	= "\tDI\t",
		RETI= "\tRETI\t",
		MUL	= "\tMUL\t",	// (unsupported by Z-80)
		DB	= "\tDB\t",
		DW	= "\tDW\t",
		EQU	= "\tEQU\t",
		END = "\tEND\t";
	const string // patterns to eliminate
		LD_A_A 	= LD + "A,A",	// LD	A,A	- to eliminate.
		LD_A_C 	= LD + "A,C",	// LD	A,C - to eliminate with preceding LD C,A
		LD_C_A	= LD + "C,A";	// LD	C,A   if no label between them.
}

using namespace ops;

int rmax = 0;	// Highest used register
int pmax = 0;	// Highest used port

// Split string to tokens using provided separator
vector<string> split( string str, char sep )
{
	vector<string> tokens;
	tokens.reserve( 5 );
	const char *p0 = str.data();
	const char *p = p0;
	bool cmt = false;

	while ( *p )
	{
		cmt = cmt || *p == ';';
		while ( *p && ( cmt || *p != sep ) )
		{
			++p;
		}
		tokens.push_back( string( p0, p ) );
		while ( *p && !cmt && *p == sep )
		{
			++p;
		}
		p0 = p;
	}
	return tokens;
}

// Tabulate string to given position
void tab( string &str, int tab )
{
	int len = 0;
	for ( int pos = 0; pos < str.size(); ++pos )
	{
		if ( str[pos] == '\t' )
			len += 8 - ( len % 8 );
		else
			++len;
	}
	while ( len < tab )
	{
		str += "\t";
		len += 8 - ( len % 8 );
	}

}

// Convert literal hex constant >nnnn to Z-80 syntax [0]nnnnH
string convlit( const string &arg, bool prefix = 0 )
{
	size_t size = arg.size();
	if ( size > 1 && arg[0] == '>' )
	{
		if ( prefix || isalpha( arg[1] ) )
			return "0" + arg.substr( 1 ) + "H";
		else
			return arg.substr( 1 ) + "H";
	}
	return arg;
}

// Swap MSB and LSB of literal constant
string swap( const string &arg )
{
	size_t size = arg.size();
	if ( size && isdigit( arg[0] ) && arg[size-1] == 'H' )
	{
		if ( isalpha( arg[size-3] ) )
			return "0" + arg.substr( size-3, 2 ) + arg.substr( size-5, 2 ) + "H";
		else
			return arg.substr( size-3, 2 ) + arg.substr( size-5, 2 ) + "H";
	}
	else if ( size && isdigit( arg[0] ) )
	{
		stringstream sstr;
		int x = atoi( arg.data() );
		x = ( ( x >> 8 ) | ( x << 8 ) ) & 0xFFFF;
		sstr << x;
		return sstr.str();
	}
	return "SWAP " + arg;
}

// Convert bitmask to bit:
// - to convert "OR >nn,X" and "AND >nn,X" to "SET b,X" and "RES b,X"
// - to convert "BTJO >nn,X,aaaa" and "BTJZ >nn,X,aaaa" to "BIT b,X"; "JR [N]Z,aaaa"
string convbit( const string &arg, int bit )
{
	static const char* bitstr[8]  = {"0",   "1",   "2",   "3",   "4",   "5",   "6",   "7"};
	static const char* maskset[8] = {"01H", "02H", "04H", "08H", "10H", "20H", "40H","80H"};
	static const char* maskres[8] = {"0FEH","0FDH","0FBH","0F7H","0EFH","0DFH","BFH","7FH"};
	for ( int i=0; i<8; ++i )
	{
		if ( arg == (bit?maskset:maskres)[i] )
			return bitstr[i];
	}
	return "";
}

// Convert 8-bit operand
// if msb < 0 then use direct (Rn) access else indirect (IX-n)
string conv( const vector< string > &args, size_t i, int msb = -1 )
{
	if ( i>=args.size() )
	{
		stringstream sstr;
		sstr << "?ARG" << i << "?";
		return sstr.str();
	}
	const string arg = args[i];
	size_t size = arg.size();

	if ( !size )
		return arg;

	if ( arg[0] == '%' ) // literals: %nnn => nnn; %>nn => [0]nnH
	{
		return convlit( arg.substr( 1 ) );
	}

	if ( arg[0] == '@' ) // literals:  @nnn => nnn; @>nn => [0]nnH
	{
		return convlit( arg.substr( 1 ) );
	}

	if ( ( isdigit( arg[0] ) || arg[0] == '>' ) ) // literals: nnn => nnn; >nn => [0]nnH
	{
		return convlit( arg );
	}

	if ( size > 1 && arg[0] == 'R' && isdigit( arg[1] ) ) // R0 => C (== A); Rn => (IX-n) or (Rn)
	{
		int r = atoi( arg.substr(1).data() );
		if ( rmax < r )
			rmax = r;

		if ( !r )
		{
			return "C";
		}
		else if ( msb < 0 ) // direct
		{
			return "(R" + arg.substr(1) + ")";
		}
		else // indirect via IX
		{
			return "(IX-" + arg.substr(1) + ")";
		}
	}

	if ( size > 2 && arg[0] == '*' && arg[1] == 'R' && isdigit( arg[2] ) ) // indirect: *Rn => (Rn) or (IX-n[-1])
	{
		int r = atoi( arg.substr(1).data() );
		if ( rmax < r )
			rmax = r;

		if ( msb < 0 ) // direct
		{
			return "(R" + arg.substr(2) + ")";
		}
		else // indirect via IX
		{
			stringstream sstr;
			sstr << atoi( arg.substr(2).data() ) + msb;
			return "(IX-" + sstr.str() + ")";
		}
	}

	if ( size > 1 && arg[0] == 'P' && isdigit( arg[1] ) ) // port: Pn => (Pn)
	{
		int p = atoi( arg.substr(1).data() );
		if ( pmax < p )
			pmax = p;

		return "(P" + arg.substr(1) + ")";
	}

	return arg;
}

// Convert 16-bit operand
string convd( const vector< string > &args, size_t i )
{
	if ( i>=args.size() )
	{
		stringstream sstr;
		sstr << "?ARG" << i << "?";
		return sstr.str();
	}

	const string arg = args[i];
	size_t size = arg.size();

	if ( !size )
		return arg;

	if ( arg[0] == '%' ) // literals: %nnnnn => nnnnn; %>nnnn => [0]nnnnH
	{
		string str = convlit( arg.substr( 1 ) );
		return str;
	}

	if ( size > 1 && arg[0] == 'R' && isdigit( arg[1] ) ) // Rn => (Rnn)
	{
		int r = atoi( arg.substr(1).data() );
		if ( rmax < r )
			rmax = r;

		return "(R" + arg.substr(1) + ")";
	}

	return arg;
}

void main()
{
	char buf[256];
	const string stab = "\t";

	string lastop;
	vector< string > queue;


	while( cin.getline( buf, sizeof buf ) )
	{
		string 	line = buf;

#if 0
		cerr << line << endl;
#endif

		vector< string > tokens = split( line, '\t' );
#if 0
		cout << ";\t";
		for ( int i=0; i<tokens.size(); ++i )
		{
			cout << "[" << tokens[i] << "]\t";
		}
		cout << endl;
#endif

		// get tokens
		string label, op, comment;
		vector< string > args;
		for ( int i=0; i<tokens.size(); ++i )
		{
			const string &token = tokens[i];
			if ( token[0] == ';' )
				comment = token;
			else
			{
				switch ( i )
				{
				case 0:
					label = token;
					break;
				case 1:
					op = token;
					break;
				case 2:
					args = split( token, ',' );
					break;
				default:
					cout << "*** extra token " << i << ": " << token << endl;
					break;
				}
			}
		}

		string out;

		if ( !label.empty() )
		{
			out += label;
//TODO: parameter to add colon
//			if ( op != "EQU" )
//				out += ":";
		}

		vector< string > instr;

		bool first = true;

		string arg0 = conv( args, 0 ); // 1st arg as 8-bit value
		string arg1 = conv( args, 1 ); // 2nd arg as 8-bit value
		string arg0ixl = conv( args, 0, 0 ); // 1st arg as 16-bit value LSB
		string arg0ixh = conv( args, 0, 1 ); // 1st arg as 16-bit value MSB
		string arg1ixl = conv( args, 1, 0 ); // 2nd arg as 16-bit value LSB
		string arg1ixh = conv( args, 1, 1 ); // 2nd arg as 16-bit value MSB

		if ( op == "AORG" )	// AORG aaaa
		{
			instr.push_back( ORG + arg0 );
		}
		else if ( op == "MOV" ) // MOV ss,dd
		{
			if ( arg0.find( "(" ) == 0 && arg1.find( "(" ) == 0 )
			{
				instr.push_back( LD + "C," + arg0ixl );
				instr.push_back( LD + arg1ixl + ",C" );
			}
			else if ( arg0 == "A" || arg1 == "A" )
				instr.push_back( LD + arg1 + "," + arg0 );
			else
				instr.push_back( LD + arg1ixl + "," + arg0ixl );
		}
		else if ( op == "MOVD" ) // MOVD ssss,dddd
		{
			instr.push_back( LD + "HL," + convd( args, 0 ) );
			instr.push_back( LD + convd( args, 1 ) + ",HL" );
		}
		else if ( op == "MOVP" ) // MOVP ss,dd
		{
			if ( arg0.find( "(" ) == 0 )
			{
				if ( arg1 == "A" )
					instr.push_back( LD + "A," + arg0 );
				else
				{
					instr.push_back( LD_C_A );
					instr.push_back( LD + "A," + arg0 );
					instr.push_back( LD	+ arg1 + ",A" );
					instr.push_back( LD_A_C );
				}
			}
			else
			{
				if ( arg0 == "A" )
					instr.push_back( LD + arg1 + ",A" );
				else
				{
					instr.push_back( LD_C_A );
					instr.push_back( LD + "A," + arg0 );
					instr.push_back( LD + arg1 + ",A" );
					instr.push_back( LD_A_C );
				}
			}
		}
		else if ( op == "LDA" ) // LDA @aaaa[(B)],dd
		{
			int pos = arg0.find( "(B)" );
			if ( pos != string::npos )
			{
				instr.push_back( LD + "HL," + arg0.substr( 0, pos ) );
				instr.push_back( LD + "E,B" );
				instr.push_back( LD + "D,0" );
				instr.push_back( ADD + "HL,DE" );
			}
			else
			{
				instr.push_back( LD + "HL," + arg0 );
			}
			instr.push_back( LD + "A,(HL)" );
		}
		else if ( op == "STA" ) // STA dd,@aaaa[(B)]
		{
			int pos = arg0.find( "(B)" );
			if ( pos != string::npos )
			{
				instr.push_back( LD + "HL," + arg0.substr( 0, pos ) );
				instr.push_back( LD + "E,B" );
				instr.push_back( LD + "D,0" );
				instr.push_back( ADD + "HL,DE" );
			}
			else
			{
				instr.push_back( LD + "HL," + arg0 );
			}
			instr.push_back( LD + "(HL),A" );
		}
		else if ( op == "CMPA" ) // CMPA @aaaa[(B)]
		{
			int pos = arg0.find( "(B)" );
			if ( pos != string::npos )
			{
				instr.push_back( LD + "HL," + arg0.substr( 0, pos ) );
				instr.push_back( LD + "E,B" );
				instr.push_back( LD + "D,0" );
				instr.push_back( ADD + "HL,DE" );
			}
			else
			{
				instr.push_back( LD + "HL," + arg0 );
			}
			instr.push_back( CP + "(HL)" );
		}
		else if ( op == "LDSP" ) // LDSP
		{
			instr.push_back( LD + "L,B" );
			instr.push_back( LD + "H,0" );
			instr.push_back( LD + "SP,HL" );
		}
		else if ( op == "DEC" ) // DEC xx
		{
			instr.push_back( DEC + arg0ixl );
		}
		else if ( op == "INC" ) // INC xx
		{
			instr.push_back( INC + arg0ixl );
		}
		else if ( op == "DECD" ) // DECD Rnn
		{
			string argd0 = convd( args, 0 );
			instr.push_back( LD + "HL," + argd0 );
			instr.push_back( DEC + "HL" );
			instr.push_back( LD + argd0 + ",HL" );
		}
		else if ( op == "AND" ) // AND yy,xx
		{
			if ( arg1 == "A" )
				instr.push_back( AND + arg0ixl );
			else
			{
				string bitstr = convbit( arg0, 0 );
				if ( !bitstr.empty() )
				{
					instr.push_back( RES + bitstr + "," + arg1ixl );
				}
				else
				{
					instr.push_back( LD_C_A );
					instr.push_back( LD	+ "A," + arg1 );
					instr.push_back( AND + arg0ixl );
					instr.push_back( LD	+ arg1 + ",A" );
					instr.push_back( LD_A_C );
				}
			}
		}
		else if ( op == "ANDP" ) // ANDP yy,Pnn
		{
			instr.push_back( LD_C_A );
			instr.push_back( LD + "A," + arg1 );
			instr.push_back( AND + arg0ixl );
			instr.push_back( LD + arg1 + ",A" );
			instr.push_back( LD_A_C );
		}
		else if ( op == "OR" ) // OR yy,xx
		{
			if ( arg1 == "A" )
				instr.push_back( OR + arg0ixl );
			else
			{
				string bitstr = convbit( arg0, 1 );
				if ( !bitstr.empty() )
				{
					instr.push_back( SET + bitstr + "," + arg1ixl );
				}
				else
				{
					instr.push_back( LD_C_A );
					instr.push_back( LD	+ "A," + arg1 );
					instr.push_back( OR + arg0ixl );
					instr.push_back( LD	+ arg1 + ",A" );
					instr.push_back( LD_A_C );
				}
			}
		}
		else if ( op == "ORP" ) // ORP yy,Pnn
		{
			instr.push_back( LD_C_A );
			instr.push_back( LD + "A," + arg1 );
			instr.push_back( OR + arg0ixl );
			instr.push_back( LD + arg1 + ",A" );
			instr.push_back( LD_A_C );
		}
		else if ( op == "XOR" ) // XOR yy,xx
		{
			if ( arg1 == "A" )
				instr.push_back( XOR + arg0ixl );
			else
			{
				instr.push_back( LD_C_A );
				instr.push_back( LD	+ "A," + arg1 );
				instr.push_back( XOR + arg0ixl );
				instr.push_back( LD	+ arg1 + ",A" );
				instr.push_back( LD_A_C );
			}
		}
		else if ( op == "TSTA" ) // TSTA
		{
			instr.push_back( CP + "0" );
		}
		else if ( op == "CMP" ) // CMP yy,xx
		{
			if ( arg1 == "A" )
				instr.push_back( CP + arg0ixl );
			else
			{
				instr.push_back( LD + "C,A" );
				instr.push_back( LD	+ "A," + arg1 );
				instr.push_back( CP + arg0ixl );
				instr.push_back( LD + "A,C" );
			}
		}
		else if ( op == "ADD" ) // ADD yy,xx
		{

			if ( arg1 == "A" )
				instr.push_back( ADD + "A," + arg0ixl );
			else
			{
				instr.push_back( LD_C_A );
				instr.push_back( LD	+ "A," + arg1 );
				instr.push_back( ADD + "A," + arg0ixl );
				instr.push_back( LD	+ arg1 + ",A" );
				instr.push_back( LD_A_C );
			}
		}
		else if ( op == "ADC" ) // ADC yy,xx
		{

			if ( arg1 == "A" )
				instr.push_back( ADC + "A," + arg0ixl );
			else
			{
				instr.push_back( LD_C_A );
				instr.push_back( LD	+ "A," + arg1 );
				instr.push_back( ADC + "A," + arg0ixl );
				instr.push_back( LD	+ arg1 + ",A" );
				instr.push_back( LD_A_C );
			}
		}
		else if ( op == "SUB" ) // SUB yy,xx
		{
			if ( arg1 == "A" )
				instr.push_back( SUB + arg0ixl );
			else
			{
				instr.push_back( LD_C_A );
				instr.push_back( LD	+ "A," + arg1 );
				instr.push_back( SUB + arg0ixl );
				instr.push_back( LD	+ arg1 + ",A" );
				instr.push_back( LD_A_C );
			}
		}
		else if ( op == "SBB" ) // SBB yy,xx
		{
			if ( arg1 == "A" )
				instr.push_back( SBC + arg0ixl );
			else
			{
				instr.push_back( LD_C_A );
				instr.push_back( LD	+ "A," + arg1 );
				instr.push_back( SBC + "A," + arg0ixl );
				instr.push_back( LD	+ arg1 + ",A" );
				instr.push_back( LD_A_C );
			}
		}
		else if ( op == "MPY" ) // MPY yy,xx
		{
			if ( arg1 == "A" )
				instr.push_back( MUL + arg0ixl );
			else
			{
				instr.push_back( LD_C_A );
				instr.push_back( LD	+ "A," + arg1 );
				instr.push_back( MUL + "A," + arg0ixl );
				instr.push_back( LD	+ arg1 + ",A" );
				instr.push_back( LD_A_C );
			}
		}
		else if ( op == "CLR" ) // CLR xx
		{
			instr.push_back( LD	+ arg0ixl + ",0" );
		}
		else if ( op == "SWAP" ) // SWAP xx
		{

			if ( arg0 == "A" )
			{
				instr.push_back( RLCA );
				instr.push_back( RLCA );
				instr.push_back( RLCA );
				instr.push_back( RLCA );
			}
			else
			{
				instr.push_back( RLC + arg0ixl );
				instr.push_back( RLC + arg0ixl );
				instr.push_back( RLC + arg0ixl );
				instr.push_back( RLC + arg0ixl );
			}
		}
		else if ( op == "RRC" ) // RRC xx
		{

			if ( arg0 == "A" )
			{
				instr.push_back( RR );
			}
			else
			{
				instr.push_back( RR + arg0ixl );
			}
		}
		else if ( op == "JMP" ) // JMP aaaa
		{
			instr.push_back( JR + arg0 );
		}
		else if ( op == "JZ" ) // JZ aaaa (jump if zero)
		{
			instr.push_back( JR + "Z," + arg0 );
		}
		else if ( op == "JNZ" ) // JZ aaaa (jump if !zero)
		{
			instr.push_back( JR + "NZ," + arg0 );
		}
		else if ( op == "JC" ) // JZ aaaa (jump if carry)
		{
			instr.push_back( JR + "C," + arg0 );
		}
		else if ( op == "JNC" ) // JZ aaaa (jump if !carry)
		{
			if ( lastop == "INC" )
			{
				// special case for sequences
				//	INC	Rx1
				//	JNC	$+3
				//	INC	Rx0
				// because the Z-80 doesn't set Cy on INC and DEC
				instr.push_back( JR + "NZ," + arg0 );
			}
			else
			{
				instr.push_back( JR + "NC," + arg0 );
			}
		}
		else if ( op == "JP" ) // JZ aaaa (jump if positive)
		{
			instr.push_back( JP + "P," + arg0 );
		}
		else if ( op == "JPZ" ) // JZ aaaa (jump if positive or zero)
		{
			instr.push_back( JP + "P," + arg0 );
		}
		else if ( op == "JN" ) // JZ aaaa (jump if negative)
		{
			instr.push_back( JP + "M," + arg0 );
		}
		else if ( op == "BR" ) // BR @aaaa[(B)] (long jump)
		{
			int pos = arg0.find( "(B)" );
			if ( pos != string::npos )
			{
				instr.push_back( LD + "HL," + arg0.substr( 0, pos ) );
				instr.push_back( LD + "E,B" );
				instr.push_back( LD + "D,0" );
				instr.push_back( ADD + "HL,DE" );
				instr.push_back( JP + "(HL)" );
			}
			else if ( arg0.find("(R") != string::npos )
			{
				instr.push_back( LD + "HL," + arg0 );
				instr.push_back( JP + "(HL)" );
			}
			else
			{
				instr.push_back( JP + arg0 );
			}
		}
		else if ( op == "BTJO" ) // BTJO %yy,xx,aaaa (jump if any bit of xx masked by %yy is one)
		{
			string bitstr = convbit( arg0, 1 );
			if ( !bitstr.empty() )
			{
				instr.push_back( BIT + bitstr + "," + arg1ixl );
				instr.push_back( JR	+ "NZ," + conv( args, 2 ) );
			}
			else
			{
				instr.push_back( LD_C_A );
				instr.push_back( LD	+ "A," + arg1 );
				instr.push_back( AND + arg0ixl );
				instr.push_back( LD_A_C );
				instr.push_back( JR	+ "NZ," + conv( args, 2 ) );
			}
		}
		else if ( op == "BTJOP" ) // BTJOP %yy,Pnn,aaaa (jump if any bit of Pnn masked by %yy is one)
		{
			instr.push_back( HALT );
		}
		else if ( op == "BTJZ" ) // BTJZ %yy,xx,aaaa (jump if any bit of xx masked by %yy is zero)
		{
			string bitstr = convbit( arg0, 1 );
			if ( !bitstr.empty() )
			{
				instr.push_back( BIT + bitstr + "," + arg1ixl );
				instr.push_back( JR	+ "Z," + conv( args, 2 ) );
			}
			else
			{
				instr.push_back( LD_C_A );
				instr.push_back( LD	+ "A," + arg1 );
				instr.push_back( CPL );
				instr.push_back( AND + arg0ixl );
				instr.push_back( LD_A_C );
				instr.push_back( JR	+ "NZ," + conv( args, 2 ) );
			}
		}
		else if ( op == "BTJZP" ) // BTJZP %yy,Pnn,aaaa (jump if any bit of Pnn masked by %yy is zero)
		{
			instr.push_back( HALT );
		}
		else if ( op == "CALL" ) // CALL aaaa
		{
			instr.push_back( CALL + arg0 );
		}
		else if ( op == "RETS" ) // RETS (from subroutine)
		{
			instr.push_back( RET );
		}
		else if ( op == "RETI" ) // RETI (from interrupt)
		{
			instr.push_back( RET );	// => normal RET
		}
		else if ( op == "PUSH" ) // PUSH xx
		{
			if ( arg0 == "A" )
				instr.push_back( PUSH + "AF" );
			else if ( arg0 == "B" )
				instr.push_back( PUSH + "BC" );
			else
			{
				instr.push_back( LD + "D," + arg0ixl );
				instr.push_back( PUSH + "DE" );
			}
		}
		else if ( op == "POP" ) // POP xx
		{
			if ( arg0 == "A" )
				instr.push_back( POP + "AF" );
			else if ( arg0 == "B" )
				instr.push_back( POP + "BC" );
			else
			{
				instr.push_back( POP + "DE" );
				instr.push_back( LD + arg0ixl + ",D" );
			}
		}
		else if ( op == "EINT" ) // EINT
		{
			instr.push_back( DI );		// No EI
		}
		else if ( op == "DINT" )
		{
			instr.push_back( DI ); // DINT
		}
		else if ( op == "BYTE" || op == "TEXT" ) // BYTE x,... (8-bit data) or TEXT "..."
		{
			string str = DB + convlit( args[0], true );
			for ( int i=1; i<args.size(); ++i )
				str += "," + convlit( args[i], true );
			if ( !comment.empty() )
			{
				tab( str, 32 );
				str += comment;
			}
			instr.push_back( str );
			first = false; // No original line in comment
		}
		else if ( op == "DATA" ) // DATA xxxx,... (16-bit data)
		{
			string str = DW + convlit( args[0], true );
			for ( int i=1; i<args.size(); ++i )
				str += "," + convlit( args[i], true );
			if ( !comment.empty() )
			{
				tab( str, 32 );
				str += comment;
			}
			instr.push_back( str );
			first = false; // No original line in comment
		}
		else if ( op == "EQU" ) // llll EQU xxxx
		{
			string str = EQU + arg0;
			instr.push_back( str );
			first = false; // No original line in comment
		}
		else if ( op == "END" ) // END [aaaa]
		{
			stringstream sstr;

			// generate ports table
			instr.push_back( "" );
			instr.push_back( "\tDS\tLOW(100H-LOW $)" );

			for ( int i=0; i<=pmax; ++i )
			{
				sstr.str("");
				sstr << "P" << i << "\tDB\t0";
				instr.push_back( sstr.str() );
			}

			// generate registers table
			sstr.str("");
			instr.push_back( "" );
			instr.push_back( "\tDS\tLOW(100H-LOW $)" );
			sstr << "\tDS\t0FFH-" << rmax;
			instr.push_back( sstr.str() );

			for ( int i=rmax; i>=0; --i )
			{
				sstr.str("");
				sstr << "R" << i << "\tDS\t1";
				instr.push_back( sstr.str() );
			}

			instr.push_back( "" );
			instr.push_back( "$ENTRY:"+ LD + "IX,R0" );
			instr.push_back( JP + arg0 );
			instr.push_back( END + "$ENTRY" );
		}
		else if ( !op.empty() ) // Unrecognized op-code
		{
			instr.push_back( stab + "*** ?" + stab + op );
		}

		lastop = op;

		for ( int i=0; i<instr.size(); ++i )
		{
			const std::string &instr_i = instr[i];

 			// Remove LD A,A
			if ( instr_i == LD_A_A )
			{
				continue;
			}

			// Remove LD A,C ; LD C,A sequence
			if ( !queue.empty() && instr_i == LD_C_A && queue.back().find( LD_A_C ) == 0 )
			{
				queue.pop_back();
				continue;
			}

			// Append original code and comment to first generated line for the statement
			if ( first )
			{
				first = false;
				out += instr_i;
				tab( out, 32 );

				if ( origcode )
				{
					for ( int pos = 0; pos < line.size(); ++pos )
					{
						if ( line[pos] == '\t' )
						{
							out += ";" + line.substr( pos + 1 );
							break;
						}
					}
				}
				else
				{
					out += comment;
				}
			}
			else
			{
				out += instr_i;
			}

			queue.push_back( out );
			out.clear();
		}

		if ( first )
		{
			queue.push_back( line );
		}

		if ( !label.empty() )
		{
			for ( int i=0; i<queue.size(); ++i )
			{
				cout << queue[i] << endl;
			}
			queue.clear();
		}
	}

	for ( int i=0; i<queue.size(); ++i )
	{
		cout << queue[i] << endl;
	}
}
