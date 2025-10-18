/* definitions and declarations */
%skeleton "lalr1.cc"
%require "3.0"
%debug
%defines
%define api.namespace {EECS}
%define parser_class_name {Parser}
%define parse.error verbose
%output "parser.cc"
%token-table 

%code requires{
	namespace EECS {
		class Manager;
		class Scanner;
	}
	#include <iostream>
	#include "string.h"
	#include "ast.hpp"

#ifndef YY_NULLPTR
#define YY_NULLPTR 0
#endif
}

%parse-param { Scanner &scanner}
%parse-param { Manager& manager}

%code{
	#include <iostream>
	#include "string.h"
	#include <fstream>
	#include <cstdlib>

	#include "calc.hpp"

	#undef yylex
	#define yylex scanner.yylex
}

%union {
	int intVal;
	const char * strVal;
}

%token END  0
%token <strVal> ID
%token <intVal> INTLIT
%token LPAR
%token RPAR
%token PLUS
%token MINUS
%token DIV
%token MULT
%token ORATE
%token CALCULATE

%type <intVal> Program
%type <intVal> Ops
%type <intVal> Op
%type <intVal> Sum
%type <intVal> Sub
%type <intVal> Prod
%type <intVal> Quot
%type <intVal> Base

%%
Program : Ops END           { /* Make sure to set manager.root = $$ here so the ast can be accessed outside the parser! */ } 
Ops     : Ops Op            { /* Fill out the SDD rules with your custom ast node types */ }
        | Op                { }
Op      : CALCULATE ID Sum  { } 
        | ORATE Sum         { } 
Sum     : Sum PLUS Sub      { }
        | Sub		    { }
Sub     : Sub MINUS Prod    { }
        | Prod		    { }
Prod    : Prod MULT Quot    { }
        | Quot 		    { }
Quot    : Quot DIV Base	    { }
        | Base		    { }
Base    : INTLIT            { }
        | LPAR Sum RPAR     { }
        | ID                { }
/* CF-productions and actions */
%%
/* Program stub -- code at end of the parser.cc*/
void 
EECS::Parser::error(const std::string &err_message){
	std::cerr << "Parser Error: " << err_message << "\n";
}
