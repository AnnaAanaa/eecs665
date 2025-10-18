%skeleton "lalr1.cc"
%require "3.0"
%debug
%defines
%define api.namespace{leviathan}
%define api.parser.class {Parser}
%define api.value.type variant
//%define parse.error verbose
%output "parser.cc"
%token-table

%code requires{
	#include <list>
	#include "tokens.hpp"
	#include "ast.hpp"
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
%parse-param { leviathan::ProgramNode** root}

%code {
   // C std code for utility functions
   #include <iostream>
   #include <cstdlib>
   #include <fstream>

   // Our code for interoperation between scanner/parser
   #include "scanner.hpp"
   #include "ast.hpp"
   #include "tokens.hpp"

  //Request tokens from our scanner member, not 
  // from a global function
  #undef yylex
  #define yylex scanner.yylex
}

//%define parse.assert

/* Terminals */


%token                     END   0 "end file"
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

%type <leviathan::ProgramNode *> program
%type <std::list<leviathan::DeclNode *> *> globals
%type <leviathan::DeclNode *> decl
%type <leviathan::VarDeclNode *> varDecl
%type <leviathan::TypeNode *> type
%type <leviathan::TypeNode *> dataType
%type <leviathan::TypeNode *> primType
%type <leviathan::LocNode *> loc
%type <leviathan::IDNode *> name

/* NOTE: Make sure to add precedence and associativity 
 * declarations
 */
%right ASSIGN
%left OR
%left AND
%nonassoc LESS GREATER LESSEQ GREATEREQ EQUALS NOTEQUALS
%left DASH CROSS
%left STAR SLASH
%left NOT 

%%

program		: globals
		  {
		  $$ = new ProgramNode($1);
		  *root = $$;
		  }

globals		: globals decl
		  {
		  $$ = $1;
		  DeclNode * declNode = $2;
		  $$->push_back(declNode);
		  }
		| /* epsilon */
		  {
		  $$ = new std::list<DeclNode *>();
		  }

decl		: varDecl SEMICOL
		  {
		  $$ = $1;
		  }
		| fnDecl
		  {
			$$ = $1;
		  }

varDecl		: name COLON type
		  {
		  const Position * p;
		  p = new Position($1->pos(), $3->pos());
		  $$ = new VarDeclNode(p,$1, $3);
		  }
		| name COLON type ASSIGN initializer
		  {
			const Position * p = new Position($1->pos(), $4->pos());
			$$ = new VarDeclNode(p, $1, $3, $5);
		  }

type		: IMMUTABLE dataType
		  {
			const Position * p = new Position($1->pos(), $2->pos());
			$$ = new ImmutableTypeNode(p, $2);
		  }
		| dataType
		  {
		  $$ = $1;
		  }

dataType	: primType LBRACKET INTLITERAL RBRACKET
		  {
			int size = $3->value();
			const Position * p = new Position($1->pos(), $3->pos());
			$$ = new ArrayTypeNode(p, $1, size);
		  }
		| primType
		  {
		  $$ = $1;
		  }

primType	: INT
		  {
		  $$ = new IntTypeNode($1->pos());
		  }
		| BOOL
		  {
			$$ = new BoolTypeNode($1->pos());
		  }
		| FILE
		  {
			$$ = new FileTypeNode($1->pos());
		  }
		| VOID
		  {
			$$ = new VoidTypeNode($1->pos());
		  }

fnDecl 		: name COLON LPAREN maybeFormals RPAREN type LCURLY stmtList RCURLY
		  {
			const Position * p = new Position ($1->pos(), $7->front()->pos());
			$$ = new FnDeclNode(p, $1, $4, $6, $8);
		  }

maybeFormals	: /* epsilon */
		  {
			$$ = new std::list<FormalDeclNode*>();
		  }
		| formalList
		  {
			$$ = $1;
		  }

formalList	: formalDecl
		  {
			$$ = new std::list<FormalDeclNode*>();
			$$->push_back($1);
		  }
		| formalList COMMA formalDecl
		  {
			$$ = $1;
			$$->push_back($3);
		  }

formalDecl	: name COLON type
		  {
			const Position * p = new Position($1->pos(), $3->pos());
			$$ = new FormalDeclNode(p, $1, $3);
		  }
		| name COLON type ASSIGN initializer
		  {
			const Position * p = new Position($1->pos(), $4->pos());
			$$ = new FormalDeclNode(p, $1, $3, $5 /* initializer */);
		  }

stmtList	: /* epsilon */
		  {
			$$ = new std::list<StmtNode*>();
		  }
		| stmtList stmt SEMICOL
		  {
			$$ = $1; $$->push_back($2);
		  }
		| stmtList blockStmt
		  {
			$$ = $1; $$->push_back($2);
		  }

blockStmt	: WHILE LPAREN exp RPAREN LCURLY stmtList RCURLY
		  {
			const Position * p = new Position($1->pos(), $6->empty() ? $4->pos() : $6->front()->pos());
			$$ = new WhileStmtNode(p, $3, $6);
		  }
		| IF LPAREN exp RPAREN LCURLY stmtList RCURLY
		  {
			const Position * p = new Position($1->pos(), $6->empty() ? $4->pos() : $6->front()->pos());
			$$ = new IfStmtNode(p, $3, $6);
		  }
		| IF LPAREN exp RPAREN LCURLY stmtList RCURLY ELSE LCURLY stmtList RCURLY
		  {
			const Position * p = new Position($1->pos(), $10->empty() ? $4->pos() : $10->front()->pos());
			$$ = new IfElseStmtNode(p, $3, $6, $10);
		  }

stmt		: varDecl
		  {
			$$ = $1;
		  }
		| loc ASSIGN exp
		  {
			const Position * p = new Position($1->pos(), $3->pos());
			$$ = new AssignStmtNode(p, $1, $3);
		  }
		| callExp
		  {
			const Position * p = $1->pos();
			$$ = new CallStmtNode(p, $1);
		  }
		| loc POSTDEC
		  {
			const Position * p = new Position($1->pos(), $2->pos());
			$$ = new PostDecStmtNode(p, $1);
		  }
		| loc POSTINC
		  {
			const Position * p = new Position($1->pos(), $2->pos());
			$$ = new PostIncStmtNode(p, $1);
		  }
		| loc OUTPUT exp
		  {
			const Position * p = new Position($1->pos(), $3->pos());
			$$ = new WriteStmtNode(p, $1, $3);
		  }
		| loc INPUT loc
		  {
			const Position * p = new Position($1->pos(), $3->pos());
			$$ = new ReadStmtNode(p, $1, $3);
		  }
		| SINK name
		  {
			const Position * p = new Position($1->pos(), $2->pos());
			$$ = new SinkStmtNode(p, $2);
		  }
		| RETURN exp
		  {
			const Position * p = new Position($1->pos(), $2->pos());
			$$ = new ReturnStmtNode(p, $2);
		  }
		| RETURN
		  {
			$$ = new ReturnStmtNode($1->pos(), nullptr);
		  }

exp		: exp DASH exp
	  	  {
			const Position * p = new Position($1->pos(), $3->pos());
			$$ = new BinaryExpNode(p, $1, "-", $3);
		  }
		| exp CROSS exp
	  	  {
			const Position * p = new Position($1->pos(), $3->pos());
			$$ = new BinaryExpNode(p, $1, "+", $3);
		  }
		| exp STAR exp
	  	  {
			const Position * p = new Position($1->pos(), $3->pos());
			$$ = new BinaryExpNode(p, $1, "*", $3);
		  }
		| exp SLASH exp
	  	  {
			const Position * p = new Position($1->pos(), $3->pos());
			$$ = new BinaryExpNode(p, $1, "/", $3);
		  }
		| exp AND exp
	  	  {
			const Position * p = new Position($1->pos(), $3->pos());
			$$ = new BinaryExpNode(p, $1, "&&", $3);
		  }
		| exp OR exp
	  	  {
			const Position * p = new Position($1->pos(), $3->pos());
			$$ = new BinaryExpNode(p, $1, "||", $3);
		  }
		| exp EQUALS exp
	  	  {
			const Position * p = new Position($1->pos(), $3->pos());
			$$ = new BinaryExpNode(p, $1, "==", $3);
		  }
		| exp NOTEQUALS exp
	  	  {
			const Position * p = new Position($1->pos(), $3->pos());
			$$ = new BinaryExpNode(p, $1, "!=", $3);
		  }
		| exp GREATER exp
	  	  {
			const Position * p = new Position($1->pos(), $3->pos());
			$$ = new BinaryExpNode(p, $1, ">", $3);
		  }
		| exp GREATEREQ exp
	  	  {
			const Position * p = new Position($1->pos(), $3->pos());
			$$ = new BinaryExpNode(p, $1, ">=", $3);
		  }
		| exp LESS exp
	  	  {
			const Position * p = new Position($1->pos(), $3->pos());
			$$ = new BinaryExpNode(p, $1, "<", $3);
		  }
		| exp LESSEQ exp
	  	  {
			const Position * p = new Position($1->pos(), $3->pos());
			$$ = new BinaryExpNode(p, $1, "<=", $3);
		  }
		| NOT exp
	  	  {
			const Position * p = new Position($1->pos(), $2->pos());
			$$ = new UnaryExpNode(p, "!", $2);
		  }
		| DASH term
	  	  {
			const Position * p = new Position($1->pos(), $2->pos());
			$$ = new UnaryExpNode(p, "-", $2);
		  }
		| term
	  	  {
			$$ = $1;
		  }


callExp		: loc LPAREN RPAREN
		  {
			$$ = new CallExpNode($1->pos(), dynamic_cast<IDNode*>($1), new std::list<ExpNode*>());
		  }
		| loc LPAREN actualsList RPAREN
		  {
			$$ = new CallExpNode($1->pos(), dynamic_cast<IDNode*>($1), $3);
		  }

actualsList	: exp
		  {
			$$ = new std::list<ExpNode*>();
			$$->push_back($1);
		  }
		| actualsList COMMA exp
		  {
			$$ = $1;
			$$->push_back($3);
		  }

term 		: loc
		  { 
			$$ = $1;
		  }
		| literal
		  { 
			$$ = $1;
		  }
		| THRASH 
		  { /*TODO $$ = new StrLitNode($1->pos(), $1->str());*/ 
		  $$ = new StrLitNode($1->pos(), $1->str());
		  }
		  
		| LPAREN exp RPAREN
		  {
			$$ = $2;
		  }
		| callExp
		  {
			$$ = $1;
		  }

initializer	: literal
		  { 
			$$ = $1;
		  } 
		| LBRACKET litList RBRACKET
		  { 
			const Position * p = new Position($1->pos(), $3->pos());
			$$ = new InitializerNode(p, $2);
		  } 

litList		: literal
		  { 
			$$ = new std::list<ExpNode*>();
			$$->push_back($1);
		  } 
		| literal COMMA litList
		  { 
			$$ = $3;
			$$->push_front($1);
		  } 

literal		: TRUE
		  {
			$$ = new TrueNode($1->pos());
		  }
		| FALSE
		  {
			$$ = new FalseNode($1->pos());
		  }
		| INTLITERAL
		  {
			$$ = new IntLitNode($1->pos(), $1->value());
		  }
		| STRINGLITERAL
		  {
			$$ = new StrLitNode($1->pos(), $1->value());
		  }

loc		: name
		  {
		  $$ = $1;
		  }
		| loc LBRACKET exp RBRACKET
		  {
			const Position * p = new Position($1->pos(), $3->pos());
			$$ = new ArrayIndexNode(p, $1, $3);
		  }

name		: ID
		  {
		  const Position * pos = $1->pos();
		  $$ = new IDNode(pos, $1->value());
		  }
	
%%

void leviathan::Parser::error(const std::string& msg){
	//std::cout << msg << std::endl;
	std::cerr << "syntax error" << std::endl;
}
