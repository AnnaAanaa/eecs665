#include <fstream>
#include "scanner.hpp"

using namespace leviathan;

using TokenKind = leviathan::Parser::token;
using Lexeme = leviathan::Parser::semantic_type;

void Scanner::outputTokens(std::ostream& outstream){
	Lexeme lastMatch;
	//Token * t = lex.as<Token *>();
	int tokenKind;
	while(true){
		tokenKind = this->yylex(&lastMatch);
		if (tokenKind == TokenKind::END){
			outstream << "EOF" 
			  << " [" << this->lineNum 
			  << "," << this->colNum << "]"
			  << std::endl;
			return;
		} else {
			outstream << lastMatch.as<Token *>()->toString()
			  << std::endl;
		}
	}
}
