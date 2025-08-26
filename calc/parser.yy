/* definitions and declarations */
%skeleton "lalr1.cc"
%require "3.0"
%debug
%defines
%define api.namespace {EECS}
%define parser_class_name {Parser}
%output "parser.cc"
%token-table

%code requires {
	namespace EECS {
		class Manager;
		class Scanner;
	}

#ifndef YY_NULLPTR
#define YY_NULLPTR 0
#endif
}

%parse-param { Scanner &scanner}
%parse-param { Manager &manager}

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
	bool transGood;
}

%token END 0
%token LPAR
%token RPAR
%token PLUS
%token MINUS
%token DIV
%token MULT
%token <intVal> INTLIT

%type <transGood> Equation

%%
Equation : /* Add to this (and other) productions */ { 
		}

/* CF-productions and actions */
%%
/* Program stub -- code at end of the parser.cc*/
void
EECS::Parser::error(const std::string &err_message){
	std::cerr << "Parser Error: " << err_message << "\n";
}
