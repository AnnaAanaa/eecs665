%skeleton "lalr1.cc"
%require "3.0"
%debug
%defines
%define api.namespace{leviathan}
%define api.parser.class {Parser}
%define api.value.type variant
%define parse.error verbose
%output "parser.cc"
%token-table

%code requires{
	#include <list>
	#include "tokens.hpp"
	namespace leviathan {
		class Scanner;
	}

//The following definition is required when 
// we don't use the %locations directive (which we won't)
# ifndef YY_NULLPTR
#  if defined __cplusplus && 201103L <= __cplusplus
#   define YY_NULLPTR nullptr
#  else
#   define YY_NULLPTR 0
#  endif
# endif

//End "requires" code
}

%parse-param { leviathan::Scanner &scanner }
%code{
   // C std code for utility functions
   #include <iostream>
   #include <cstdlib>
   #include <fstream>

   // Our code for interoperation between scanner/parser
   #include "scanner.hpp"
   #include "tokens.hpp"

  //Request tokens from our scanner member, not 
  // from a global function
  #undef yylex
  #define yylex scanner.yylex
}


/* Terminals 
 *  No need to touch these, but do note the translation type
 *  of each node. Most are just "transToken", which is defined in
 *  the %union above to mean that the token translation is an instance
 *  of leviathan::Token *, and thus has no fields (other than line and column).
 *  Some terminals, like ID, are "transIDToken", meaning the translation
 *  also has a name field. 
*/
%token                   END	0 "end file"
%token	<leviathan::Token *>       AND
%token	<leviathan::Token *>       ASSIGN
%token	<leviathan::Token *>       BOOL
%token	<leviathan::Token *>       COLON
%token	<leviathan::Token *>       COMMA
%token	<leviathan::Token *>       DASH
%token	<leviathan::Token *>       ELSE
%token	<leviathan::Token *>       SINK
%token	<leviathan::Token *>       EQUALS
%token	<leviathan::Token *>       FALSE
%token	<leviathan::Token *>       FILE
%token	<leviathan::Token *>       OUTPUT
%token	<leviathan::Token *>       GREATER
%token	<leviathan::Token *>       GREATEREQ
%token	<leviathan::IDToken *>     ID
%token	<leviathan::Token *>       IF
%token	<leviathan::Token *>       INT
%token	<leviathan::IntLitToken *> INTLITERAL
%token	<leviathan::Token *>       IMMUTABLE
%token	<leviathan::Token *>       LCURLY
%token	<leviathan::Token *>       LESS
%token	<leviathan::Token *>       LESSEQ
%token	<leviathan::Token *>       LPAREN
%token	<leviathan::Token *>       NOT
%token	<leviathan::Token *>       NOTEQUALS
%token	<leviathan::Token *>       OR
%token	<leviathan::Token *>       CROSS
%token	<leviathan::Token *>       POSTDEC
%token	<leviathan::Token *>       POSTINC
%token	<leviathan::Token *>       RETURN
%token	<leviathan::Token *>       RCURLY
%token	<leviathan::Token *>       RPAREN
%token	<leviathan::Token *>       SEMICOL
%token	<leviathan::Token *>       SLASH
%token	<leviathan::Token *>       STAR
%token	<leviathan::StrToken *>    STRINGLITERAL
%token	<leviathan::Token *>       INPUT
%token	<leviathan::Token *>       LBRACKET
%token	<leviathan::Token *>       RBRACKET
%token	<leviathan::Token *>       THRASH
%token	<leviathan::Token *>       TRUE
%token	<leviathan::Token *>       VOID
%token	<leviathan::Token *>       WHILE


/* NOTE: Make sure to add precedence and associativity 
 * declarations
 */

%right ASSIGN
%left OR
%left AND
%nonassoc EQUALS NOTEQUALS LESS LESSEQ GREATER GREATEREQ
%left CROSS DASH
%left STAR SLASH
%right NOT UMINUS

%%

program 	: globals
		  {
		  //For the project, we will only be checking std::cerr for 
		  // correctness. You might choose to uncomment the following
		  // Line to help you debug, which will print when this
		  // production is applied
		  std::cout << "got to the program ::= globals rule\n";
		  }

globals 	: globals decl 
			{}
		| /* epsilon */ 
			{}

decl		: varDecl SEMICOL 
			{}
			| fnDecl 
			{}

varDecl 	: name COLON type 
			{
		  	/* There are other rules for varDecl to add as well */
		  	}
		  | name COLON type ASSIGN initializer
		  {}

type		: datatype {}
		  	| IMMUTABLE datatype {}

datatype	: primType LBRACKET INTLITERAL RBRACKET {}
			| primType {}

primType	: INT {}
			| BOOL {}
			| FILE {}
			| VOID {}

fnDecl		: name COLON LPAREN maybeformals RPAREN type LCURLY stmtList RCURLY {}	

maybeformals	: formalsList {}
				| {}

formalsList	: formalDecl {}
			| formalsList COMMA formalDecl {}

formalDecl	: name COLON type {}

stmtList	: stmtList stmt SEMICOL {}
		| stmtList stmt {}
                | {}

stmt            : matched_stmt
                | unmatched_stmt

matched_stmt    : IF LPAREN exp RPAREN matched_stmt ELSE matched_stmt {}
                | other_stmt {}

unmatched_stmt  : IF LPAREN exp RPAREN stmt {}
                | IF LPAREN exp RPAREN matched_stmt ELSE unmatched_stmt {}

other_stmt      : WHILE LPAREN exp RPAREN LCURLY stmtList RCURLY {}
                | varDecl SEMICOL {}
                | loc ASSIGN exp SEMICOL {}
                | callExp SEMICOL {}
                | loc POSTDEC SEMICOL {}
                | loc POSTINC SEMICOL {}
                | loc OUTPUT exp SEMICOL {}
                | loc INPUT loc SEMICOL {}
                | SINK name SEMICOL {}
                | RETURN exp SEMICOL {}
                | RETURN SEMICOL {}
                | LCURLY stmtList RCURLY {}


exp     : exp ASSIGN exp {}
        | exp OR exp {}
        | exp AND exp {}
        | exp EQUALS exp {}
        | exp NOTEQUALS exp {}
        | exp GREATER exp {}
        | exp GREATEREQ exp {}
        | exp LESS exp {}
        | exp LESSEQ exp {}
        | exp CROSS exp {}
        | exp DASH exp {}
        | exp STAR exp {}
        | exp SLASH exp {}
        | NOT exp {}
        | DASH exp %prec UMINUS {}
        | term {}


callExp     :  loc LPAREN RPAREN {}
            | loc LPAREN actualsList RPAREN {} 

actualsList     : exp {}
                | actualsList COMMA exp {}
                
term    : loc {}
        | literal {}
        | THRASH {}
        | LPAREN exp RPAREN {}
        | callExp {}

literal 	: INTLITERAL {}
            | STRINGLITERAL {}
            | TRUE {}
            | FALSE {}

litList		: literal {}
			| literal COMMA litList {}

initializer	: literal {}
			| LBRACKET litList RBRACKET {}

loc		: name {}
		| loc LBRACKET exp RBRACKET {}

name		: ID {}
 /* TODO: add productions for the entire grammar of the language */
	
%%

void leviathan::Parser::error(const std::string& msg){
	//For the project, we will only be checking std::cerr for 
	// correctness. You might choose to uncomment the following
	// Line to help you debug, since it gives slightly more 
	// descriptive error messages 
	//std::cout << msg << std::endl;
	std::cerr << "syntax error" << std::endl;
}
