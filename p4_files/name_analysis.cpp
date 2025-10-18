#include "ast.hpp"
#include "symbol_table.hpp"
#include "errors.hpp"

namespace leviathan {

//TODO here is a subset of the nodes needed to do nameAnalysis, 
// you should add the rest to allow for a complete treatment
// of any AST

bool ASTNode::nameAnalysis(SymbolTable * symTab){
	throw new ToDoError("This function should have"
		"been overriden in the subclass!");
}

bool ProgramNode::nameAnalysis(SymbolTable * symTab){
	bool res = true;
	for (auto global : *myGlobals){
		res = global->nameAnalysis(symTab) && res;
	}
	return res;
}
bool IDNode::nameAnalysis(SymbolTable * symTab){
    SemSymbol * sym = symTab->lookup(name);
    if (sym == nullptr){
        Report::fatal(pos(), "Undeclared identifier");
        return false;
    }
    attachSymbol(sym);
    return true;
}

bool VarDeclNode::nameAnalysis(SymbolTable * symTab){
	bool nameAnalysisOk = true;

	if (dynamic_cast<VoidTypeNode*>(myType) != nullptr){
		Report::fatal(myID->pos(), "Non-function declared void");
		nameAnalysisOk = false;
	}

	if (symTab->lookupLocal(myID->getName())){
		Report::fatal(myID->pos(), "Multiply declared identifier");
		nameAnalysisOk = false;
	}

	SemSymbol *sym = new SemSymbol(myID->getName(), myType->getType(), SymbolKind::VARIABLE);
	if (!symTab->insert(sym)){
		Report::fatal(myID->pos(), "Multiply declared identifier");
		delete sym;
		nameAnalysisOk = false;
	}
	
	return nameAnalysisOk;
}

bool FnDeclNode::nameAnalysis(SymbolTable * symTab){
	bool nameAnalysisOk = true;

    SemSymbol *fnSym = new SemSymbol(myID->getName(), myRetType->getType(), SymbolKind::FUNCTION);
    if (!symTab->insert(fnSym)) {
        Report::fatal(myID->pos(), "Multiply declared identifier");
        delete fnSym;
        nameAnalysisOk = false;
    }
    symTab->enterScope();

    for (auto formal : *myFormals) {
        nameAnalysisOk = formal->nameAnalysis(symTab) && nameAnalysisOk;
    }

    for (auto stmt : *myBody) {
        nameAnalysisOk = stmt->nameAnalysis(symTab) && nameAnalysisOk;
    }

    symTab->exitScope();
	return nameAnalysisOk;
}
bool FormalDeclNode::nameAnalysis(SymbolTable * symTab){
	bool nameAnalysisOk = true;

	if (dynamic_cast<VoidTypeNode*>(myType) != nullptr){
		Report::fatal(myID->pos(), "Non-function declared void");
		nameAnalysisOk = false;
	}

	if (symTab->lookupLocal(myID->getName())){
		Report::fatal(myID->pos(), "Multiply declared identifier");
		nameAnalysisOk = false;
	}

	SemSymbol *sym = new SemSymbol(myID->getName(), myType->getType(), SymbolKind::PARAMETER);
	if (!symTab->insert(sym)){
		Report::fatal(myID->pos(), "Multiply declared identifier");
		delete sym;
		nameAnalysisOk = false;
	}
	
	return nameAnalysisOk;
}
bool IntTypeNode::nameAnalysis(SymbolTable* symTab){
	// Name analysis may never even recurse down to IntTypeNode,
	// but if it does, just return true to indicate that 
	// name analysis has not failed, and add nothing to the symbol table
	return true;
}

bool BoolTypeNode::nameAnalysis(SymbolTable* symTab){
	return true;
}
bool VoidTypeNode::nameAnalysis(SymbolTable* symTab){
	return true;
}
bool FileTypeNode::nameAnalysis(SymbolTable* symTab){
	return true;
}
bool ImmutableTypeNode::nameAnalysis(SymbolTable* symTab){
	return mySub->nameAnalysis(symTab);
}

bool ArrayTypeNode::nameAnalysis(SymbolTable* symTab){
	return myEltType->nameAnalysis(symTab);
}
bool IntLitNode::nameAnalysis(SymbolTable* symTab) { return true; }
bool StrLitNode::nameAnalysis(SymbolTable* symTab) { return true; }
bool TrueNode::nameAnalysis(SymbolTable* symTab) { return true; }
bool FalseNode::nameAnalysis(SymbolTable* symTab) { return true; }
bool ThrashNode::nameAnalysis(SymbolTable* symTab) { return true; }

bool BinaryExpNode::nameAnalysis(SymbolTable * symTab) {
    bool nameAnalysisOk = true;
    if (myExp1) nameAnalysisOk = myExp1->nameAnalysis(symTab) && nameAnalysisOk;
    if (myExp2) nameAnalysisOk = myExp2->nameAnalysis(symTab) && nameAnalysisOk;
    return nameAnalysisOk;
}
bool UnaryExpNode::nameAnalysis(SymbolTable * symTab) {
    if (myExp) return myExp->nameAnalysis(symTab);
    return true;
}
bool ArrayIndexNode::nameAnalysis(SymbolTable * symTab) {
    bool nameAnalysisOk = true;
    if (myLoc) nameAnalysisOk = myLoc->nameAnalysis(symTab) && nameAnalysisOk;
    if (myIdx) nameAnalysisOk = myIdx->nameAnalysis(symTab) && nameAnalysisOk;
    return nameAnalysisOk;
}
bool AssignStmtNode::nameAnalysis(SymbolTable * symTab) {
    bool nameAnalysisOk = true;
    if (myDst) nameAnalysisOk = myDst->nameAnalysis(symTab) && nameAnalysisOk;
    if (mySrc) nameAnalysisOk = mySrc->nameAnalysis(symTab) && nameAnalysisOk;
    return nameAnalysisOk;
}
bool ReadStmtNode::nameAnalysis(SymbolTable * symTab) {
    bool nameAnalysisOk = true;
    if (mySrc) nameAnalysisOk = mySrc->nameAnalysis(symTab) && nameAnalysisOk;
    if (myDst) nameAnalysisOk = myDst->nameAnalysis(symTab) && nameAnalysisOk;
    return nameAnalysisOk;
}
bool WriteStmtNode::nameAnalysis(SymbolTable * symTab) {
    bool nameAnalysisOk = true;
    if (myDst) nameAnalysisOk = myDst->nameAnalysis(symTab) && nameAnalysisOk;
    if (mySrc) nameAnalysisOk = mySrc->nameAnalysis(symTab) && nameAnalysisOk;
    return nameAnalysisOk;
}
bool PostDecStmtNode::nameAnalysis(SymbolTable * symTab) {
    if (myLoc) return myLoc->nameAnalysis(symTab);
    return true;
}
bool PostIncStmtNode::nameAnalysis(SymbolTable * symTab) {
    if (myLoc) return myLoc->nameAnalysis(symTab);
    return true;
}
bool CallStmtNode::nameAnalysis(SymbolTable * symTab) {
    if (myCallExp) return myCallExp->nameAnalysis(symTab);
    return true;
}

bool SinkStmtNode::nameAnalysis(SymbolTable * symTab) {
    if (myID) return myID->nameAnalysis(symTab);
    return true;
}
bool ReturnStmtNode::nameAnalysis(SymbolTable * symTab) {
    if (myExp) return myExp->nameAnalysis(symTab);
    return true;
}
bool NotNode::nameAnalysis(SymbolTable * symTab) {
	if (myExp) return myExp->nameAnalysis(symTab);
	return true;
}
bool NegNode::nameAnalysis(SymbolTable * symTab) {
	if (myExp) return myExp->nameAnalysis(symTab);
	return true;
}
bool IfStmtNode::nameAnalysis(SymbolTable * symTab) {
	bool nameAnalysisOk = true;
	if (myCond) nameAnalysisOk = myCond->nameAnalysis(symTab) && nameAnalysisOk;

	symTab->enterScope();
	for (auto stmt : *myBody) {
		nameAnalysisOk = stmt->nameAnalysis(symTab) && nameAnalysisOk;
	}
	symTab->exitScope();

	return nameAnalysisOk;
}
bool IfElseStmtNode::nameAnalysis(SymbolTable * symTab) {
	bool nameAnalysisOk = true;
	if (myCond) nameAnalysisOk = myCond->nameAnalysis(symTab) && nameAnalysisOk;
	symTab->enterScope();
	for (auto stmt : *myBodyTrue) {
		nameAnalysisOk = stmt->nameAnalysis(symTab) && nameAnalysisOk;
	}
	symTab->exitScope();
	symTab->enterScope();
	for (auto stmt : *myBodyFalse) {
		nameAnalysisOk = stmt->nameAnalysis(symTab) && nameAnalysisOk;
	}
	symTab->exitScope();
	return nameAnalysisOk;
}
bool WhileStmtNode::nameAnalysis(SymbolTable * symTab) {
	bool nameAnalysisOk = true;
	if (myCond) nameAnalysisOk = myCond->nameAnalysis(symTab) && nameAnalysisOk;
	symTab->enterScope();
	for (auto stmt : *myBody) {
		nameAnalysisOk = stmt->nameAnalysis(symTab) && nameAnalysisOk;
	}
	symTab->exitScope();
	return nameAnalysisOk;
}
bool PlusNode::nameAnalysis(SymbolTable * symTab) {
	return BinaryExpNode::nameAnalysis(symTab);
}
bool MinusNode::nameAnalysis(SymbolTable * symTab) {
	return BinaryExpNode::nameAnalysis(symTab);
}
bool TimesNode::nameAnalysis(SymbolTable * symTab) {
	return BinaryExpNode::nameAnalysis(symTab);
}
bool DivideNode::nameAnalysis(SymbolTable * symTab) {
	return BinaryExpNode::nameAnalysis(symTab);
}
bool AndNode::nameAnalysis(SymbolTable * symTab) {
	return BinaryExpNode::nameAnalysis(symTab);
}
bool OrNode::nameAnalysis(SymbolTable * symTab) {
	return BinaryExpNode::nameAnalysis(symTab);
}
bool EqualsNode::nameAnalysis(SymbolTable * symTab) {
	return BinaryExpNode::nameAnalysis(symTab);
}
bool NotEqualsNode::nameAnalysis(SymbolTable * symTab) {
	return BinaryExpNode::nameAnalysis(symTab);
}
bool LessNode::nameAnalysis(SymbolTable * symTab) {
	return BinaryExpNode::nameAnalysis(symTab);
}
bool LessEqNode::nameAnalysis(SymbolTable * symTab) {
	return BinaryExpNode::nameAnalysis(symTab);
}
bool GreaterNode::nameAnalysis(SymbolTable * symTab) {
	return BinaryExpNode::nameAnalysis(symTab);
}
bool GreaterEqNode::nameAnalysis(SymbolTable * symTab) {
	return BinaryExpNode::nameAnalysis(symTab);
}
bool NotEqualsNode::nameAnalysis(SymbolTable * symTab) {
	return BinaryExpNode::nameAnalysis(symTab);
}
bool EqualsNode::nameAnalysis(SymbolTable * symTab) {
	return BinaryExpNode::nameAnalysis(symTab);
}



} //end namespace
