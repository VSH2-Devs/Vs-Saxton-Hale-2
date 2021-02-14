/**
 * Remade FF2 formula parser by Nergal.
 */

enum {
	TokenInvalid,
	TokenNum,
	TokenLParen, TokenRParen,
	TokenLBrack, TokenRBrack,
	TokenPlus, TokenSub,
	TokenMul, TokenDiv,
	TokenPow,
	TokenVar
};

enum {
	LEXEME_SIZE=64,
	dot_flag = 1,
};

enum struct Token {
	char lexeme[LEXEME_SIZE];
	int size;
	int tag;
	float val;
}

enum struct LexState {
	Token tok;
	int i;
}
/**
 * formula grammar (hint PEMDAS):
 * expr      = <add_expr> ;
 * add_expr  = <mult_expr> [ ('+' | '-') <add_expr> ] ;
 * mult_expr = <pow_expr> [ ('*' | '/') <mult_expr> ] ;
 * pow_expr  = <factor> [ '^' <pow_expr> ] ;
 * factor    = <number> | <var> | '(' <expr> ')' | '[' <expr> ']' ;
 */

float ParseFormula(const char[] formula, const int players)
{
	LexState ls;
	GetToken(ls, formula);
	return ParseAddExpr(ls, formula, players + 0.0);
}

float ParseAddExpr(LexState ls, const char[] formula, const float n)
{
	float val = ParseMulExpr(ls, formula, n);
	if( ls.tok.tag==TokenPlus ) {
		GetToken(ls, formula);
		float a = ParseAddExpr(ls, formula, n);
		return val + a;
	} else if( ls.tok.tag==TokenSub ) {
		GetToken(ls, formula);
		float a = ParseAddExpr(ls, formula, n);
		return val - a;
	}
	return val;
}

float ParseMulExpr(LexState ls, const char[] formula, const float n)
{
	float val = ParsePowExpr(ls, formula, n);
	if( ls.tok.tag==TokenMul ) {
		GetToken(ls, formula);
		float m = ParseMulExpr(ls, formula, n);
		return val * m;
	} else if( ls.tok.tag==TokenDiv ) {
		GetToken(ls, formula);
		float m = ParseMulExpr(ls, formula, n);
		return val / m;
	}
	return val;
}

float ParsePowExpr(LexState ls, const char[] formula, const float n)
{
	float val = ParseFactor(ls, formula, n);
	if( ls.tok.tag==TokenPow ) {
		GetToken(ls, formula);
		float e = ParsePowExpr(ls, formula, n);
		float p = Pow(val, e);
		return p;
	}
	return val;
}

float ParseFactor(LexState ls, const char[] formula, const float n)
{
	switch( ls.tok.tag ) {
		case TokenNum: {
			float f = ls.tok.val;
			GetToken(ls, formula);
			return f;
		}
		case TokenVar: {
			GetToken(ls, formula);
			return n;
		}
		case TokenLParen: {
			GetToken(ls, formula);
			float f = ParseAddExpr(ls, formula, n);
			if( ls.tok.tag != TokenRParen ) {
				LogError("VSH2/FF2 :: expected ')' bracket but got '%s'", ls.tok.lexeme);
				return 0.0;
			}
			GetToken(ls, formula);
			return f;
		}
		case TokenLBrack: {
			GetToken(ls, formula);
			float f = ParseAddExpr(ls, formula, n);
			if( ls.tok.tag != TokenRBrack ) {
				LogError("VSH2/FF2 :: expected ']' bracket but got '%s'", ls.tok.lexeme);
				return 0.0;
			}
			GetToken(ls, formula);
			return f;
		}
	}
	return 0.0;
}

bool LexOctal(LexState ls, const char[] formula)
{
	while( formula[ls.i] != 0 && (IsCharNumeric(formula[ls.i])) ) {
		switch( formula[ls.i] ) {
			case '0', '1', '2', '3', '4', '5', '6', '7': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
			}
			default: {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				LogError("VSH2/FF2 :: invalid octal literal: '%s'", ls.tok.lexeme);
				return false;
			}
		}
	}
	return true;
}

bool LexHex(LexState ls, const char[] formula)
{
	while( formula[ls.i] != 0 && (IsCharNumeric(formula[ls.i]) || IsCharAlpha(formula[ls.i])) ) {
		switch( formula[ls.i] ) {
			case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
				'a', 'b', 'c', 'd', 'e', 'f',
				'A', 'B', 'C', 'D', 'E', 'F': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
			}
			default: {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				LogError("VSH2/FF2 :: invalid hex literal: '%s'", ls.tok.lexeme);
				return false;
			}
		}
	}
	return true;
}

bool LexDec(LexState ls, const char[] formula)
{
	int lit_flags = 0;
	while( formula[ls.i] != 0 && (IsCharNumeric(formula[ls.i]) || formula[ls.i]=='.') ) {
		switch( formula[ls.i] ) {
			case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
			}
			case '.': {
				if( lit_flags & dot_flag ) {
					LogError("VSH2/FF2 :: extra dot in decimal literal");
					return false;
				}
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				lit_flags |= dot_flag;
			}
			default: {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				LogError("VSH2/FF2 :: invalid decimal literal: '%s'", ls.tok.lexeme);
				return false;
			}
		}
	}
	return true;
}

void GetToken(LexState ls, const char[] formula)
{
	int len = strlen(formula);
	Token empty;
	ls.tok = empty;
	while( ls.i<len ) {
		switch( formula[ls.i] ) {
			case ' ', '\t', '\n': {
				ls.i++;
			}
			case '0': { /// possible hex, octal, binary, or float.
				ls.tok.tag = TokenNum;
				ls.i++;
				switch( formula[ls.i] ) {
					case 'o', 'O': {
						/// Octal.
						ls.i++;
						if( LexOctal(ls, formula) ) {
							ls.tok.val = StringToInt(ls.tok.lexeme, 8) + 0.0;
						}
						return;
					}
					case 'x', 'X': {
						/// Hex.
						ls.i++;
						if( LexHex(ls, formula) ) {
							ls.tok.val = StringToInt(ls.tok.lexeme, 16) + 0.0;
						}
						return;
					}
					case '.', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9': {
						/// Decimal/Float.
						if( LexDec(ls, formula) ) {
							ls.tok.val = StringToFloat(ls.tok.lexeme);
						}
						return;
					}
				}
			}
			case '.', '1', '2', '3', '4', '5', '6', '7', '8', '9': {
				ls.tok.tag = TokenNum;
				/// Decimal/Float.
				if( LexDec(ls, formula) ) {
					ls.tok.val = StringToFloat(ls.tok.lexeme);
				}
				return;
			}
			case '(': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				ls.tok.tag = TokenLParen;
				return;
			}
			case ')': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				ls.tok.tag = TokenRParen;
				return;
			}
			case '[': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				ls.tok.tag = TokenLBrack;
				return;
			}
			case ']': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				ls.tok.tag = TokenRBrack;
				return;
			}
			case '+': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				ls.tok.tag = TokenPlus;
				return;
			}
			case '-': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				ls.tok.tag = TokenSub;
				return;
			}
			case '*': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				ls.tok.tag = TokenMul;
				return;
			}
			case '/': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				ls.tok.tag = TokenDiv;
				return;
			}
			case '^': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				ls.tok.tag = TokenPow;
				return;
			}
			case 'x', 'n', 'X', 'N': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				ls.tok.tag = TokenVar;
				return;
			}
			default: {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				LogError("VSH2/FF2 :: invalid formula token '%s'.", ls.tok.lexeme);
				return;
			}
		}
	}
}