%{
#include <string>
#include <limits.h>

/* Get our custom yyFlexScanner subclass */
#include "scanner.hpp"
#include "tokens.hpp"
#undef  YY_DECL
#define YY_DECL int leviathan::Scanner::yylex( leviathan::Parser::semantic_type * const lval )

/* define yyterminate as this instead of NULL */
#define yyterminate() return( TokenKind::END )

/* Exclude unistd.h for Visual Studio compatability. */
#define YY_NO_UNISTD_H

/* typedef to make the reference to token kinds shorter */
using TokenKind = leviathan::Parser::token;

%}

%option debug
%option nodefault
%option yyclass="leviathan::Scanner"
%option noyywrap
%option c++

DIGIT [0-9]
STRING \"(\\[nt\"\\]|[^\\\"\n])*\" 
BAD_ESC \"([^\\\"\n]|\\[^nt\"\\])*\"
BAD_TERM \"(\\[nt\"\\]|[^\\\"\n])*
BAD_BOTH \"([^\\\"\n]|\\[^nt\"\\])*

%%
%{          /** Code executed at the beginning of yylex **/
            yylval = lval;
%}

"and" {
    int tokenKind = TokenKind::AND;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+3);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=3;
    return tokenKind;
}

"bool" {
    int tokenKind = TokenKind::BOOL;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+4);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=4;
    return tokenKind;
}

"else" {
    int tokenKind = TokenKind::ELSE;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+4);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=4;
    return tokenKind;
}

"false" {
    int tokenKind = TokenKind::FALSE;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+5);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=5;
    return tokenKind;
}

"file" {
    int tokenKind = TokenKind::FILE;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+4);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=4;
    return tokenKind;
}

"if" {
    int tokenKind = TokenKind::IF;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+2);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=2;
    return tokenKind;
}

"immutable" {
    int tokenKind = TokenKind::IMMUTABLE;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+9);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=9;
    return tokenKind;
}

"int" {
    int tokenKind = TokenKind::INT;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+3);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=3;
    return tokenKind;
}

"or" {
    int tokenKind = TokenKind::OR;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+2);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=2;
    return tokenKind;
}

"return" {
    int tokenKind = TokenKind::RETURN;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+6);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=6;
    return tokenKind;
}

"sink" {
    int tokenKind = TokenKind::SINK;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+4);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=4;
    return tokenKind;
}

"thrash" {
    int tokenKind = TokenKind::THRASH;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+6);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=6;
    return tokenKind;
}

"true" {
    int tokenKind = TokenKind::TRUE;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+4);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=4;
    return tokenKind;
}

"void" {
    int tokenKind = TokenKind::VOID;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+4);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=4;
    return tokenKind;
}

"while" {
    int tokenKind = TokenKind::WHILE;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+5);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=5;
    return tokenKind;
}

{STRING} {
    int tokenKind = TokenKind::STRINGLITERAL;
    size_t len = strlen(yytext);

    std::string strVal(yytext + 1, len - 2);

    Position * pos = new Position(lineNum, colNum, lineNum, colNum + len);
    Token * tok = new StrToken(pos, '"'+strVal+'"');
    yylval->emplace<leviathan::Token *>(tok);

    colNum += len;
    return tokenKind;
}

"+"		{
	
		int tokenKind = TokenKind::CROSS;
		Position * pos = new Position(
			lineNum, colNum, lineNum, colNum+1);

		Token * token = new Token(pos, tokenKind);
		this->yylval->emplace<leviathan::Token *>(token);
		colNum++;
		return tokenKind;
		}

"-" {
		int tokenKind = TokenKind::DASH;
		Position * pos = new Position(
			lineNum, colNum, lineNum, colNum+1);
		this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
		colNum++;
		return tokenKind;
		}

{DIGIT}+ {
    size_t len = strlen(yytext);
    
    long long val = atoll(yytext);

    if (val > INT_MAX) {
        std::string msg = "Integer literal overflow";
        Position * pos = new Position(lineNum, colNum, lineNum, colNum + len);
        Report::fatal(pos, msg);
        Token * tok = new IntLitToken(pos, 0);
        yylval->emplace<leviathan::Token *>(tok);
        colNum += len;
        return TokenKind::INTLITERAL;
    } else {

        int intVal = static_cast<int>(val);
        Position * pos = new Position(lineNum, colNum, lineNum, colNum + len);
        Token * tok = new IntLitToken(pos, intVal);
        yylval->emplace<leviathan::Token *>(tok);

        colNum += len;

        return TokenKind::INTLITERAL;
    }
}


{BAD_ESC} {
    size_t len = strlen(yytext);
    std::string msg = "String literal with bad escape sequence detected";
    Position * pos = new Position(lineNum, colNum, lineNum, colNum + len);
    Report::fatal(pos, msg);
    colNum += len;
}

{BAD_TERM} {
    size_t len = strlen(yytext);
    std::string msg = "Unterminated string literal detected";
    Position * pos = new Position(lineNum, colNum, lineNum, colNum + len);
    Report::fatal(pos, msg);
    colNum += len;
}

{BAD_BOTH} {
    size_t len = strlen(yytext);
    std::string msg = "Unterminated string literal with bad escape sequence detected";
    Position * pos = new Position(lineNum, colNum, lineNum, colNum + len);
    Report::fatal(pos, msg);
    colNum += len;
}


[a-zA-Z_][a-zA-Z0-9_]* {
    Position *pos = new Position(lineNum, colNum, lineNum, colNum+strlen(yytext));
    Token *tok = new IDToken(pos, std::string(yytext));
    yylval->emplace<leviathan::Token *>(tok);
    colNum += strlen(yytext);
    return TokenKind::ID;
}

"="     {
    int tokenKind = TokenKind::ASSIGN;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+1);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum++;
    return tokenKind;
}

":"     {
    int tokenKind = TokenKind::COLON;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+1);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum++;
    return tokenKind;
}

","     {
    int tokenKind = TokenKind::COMMA;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+1);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum++;
    return tokenKind;
}


"==" {
    int tokenKind = TokenKind::EQUALS;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+2);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum += 2;
    return tokenKind;
}

">>"    {
    int tokenKind = TokenKind::INPUT;  
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+2);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=2;
    return tokenKind;
}

">"     {
    int tokenKind = TokenKind::GREATER;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+1);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum++;
    return tokenKind;
}

">="    {
    int tokenKind = TokenKind::GREATEREQ;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+2);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=2;
    return tokenKind;
}

"["     {
    int tokenKind = TokenKind::LBRACKET;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+1);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum++;
    return tokenKind;
}

"<<"    {
    int tokenKind = TokenKind::SINK;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+2);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=2;
    return tokenKind;
}

"\\(-o-)//" {
    int tokenKind = TokenKind::THRASH;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+8);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=8;
    return tokenKind;
}

"{"     {
    int tokenKind = TokenKind::LCURLY;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+1);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum++;
    return tokenKind;
}

"<"     {
    int tokenKind = TokenKind::LESS;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+1);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum++;
    return tokenKind;
}

"<="    {
    int tokenKind = TokenKind::LESSEQ;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+2);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=2;
    return tokenKind;
}

"("     {
    int tokenKind = TokenKind::LPAREN;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+1);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum++;
    return tokenKind;
}

"!"     {
    int tokenKind = TokenKind::NOT;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+1);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum++;
    return tokenKind;
}

"!="    {
    int tokenKind = TokenKind::NOTEQUALS;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+2);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=2;
    return tokenKind;
}

"--"    {
    int tokenKind = TokenKind::POSTDEC;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+2);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=2;
    return tokenKind;
}

"++"    {
    int tokenKind = TokenKind::POSTINC;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+2);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=2;
    return tokenKind;
}

"]"     {
    int tokenKind = TokenKind::RBRACKET;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+1);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum++;
    return tokenKind;
}

"}"     {
    int tokenKind = TokenKind::RCURLY;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+1);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum++;
    return tokenKind;
}

")"     {
    int tokenKind = TokenKind::RPAREN;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+1);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum++;
    return tokenKind;
}

";"     {
    int tokenKind = TokenKind::SEMICOL;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+1);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum++;
    return tokenKind;
}

"..."   {
    int tokenKind = TokenKind::SINK;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+3);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum+=3;
    return tokenKind;
}

"/"     {
    int tokenKind = TokenKind::SLASH;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+1);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum++;
    return tokenKind;
}

"*"     {
    int tokenKind = TokenKind::STAR;
    Position * pos = new Position(lineNum, colNum, lineNum, colNum+1);
    this->yylval->emplace<leviathan::Token *>(new Token(pos, tokenKind));
    colNum++;
    return tokenKind;
}

#.*   {
    colNum += strlen(yytext);
}
\n		{
		//Update the line number, reset the columnNumber
        lineNum++;
		colNum = 1;
		}

[ \t\r]+    {
    colNum += strlen(yytext);
}

.   {
		std::string msg ="Illegal character ";
		msg += yytext;
		Position * pos = new Position(
			lineNum, colNum, lineNum, colNum+1);
		Report::fatal(pos,msg);
		colNum += strlen(yytext);
    }
%%
