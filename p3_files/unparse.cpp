#include "ast.hpp"

namespace leviathan{

/*
doIndent is declared static, which means that it can 
only be called in this file (its symbol is not exported).
*/
static void doIndent(std::ostream& out, int indent){
	for (int k = 0 ; k < indent; k++){ out << "\t"; }
}

/*
In this code, the intention is that functions are grouped 
into files by purpose, rather than by class.
If you're used to having all of the functions of a class 
defined in the same file, this style may be a bit disorienting,
though it is legal. Thus, we can have
ProgramNode::unparse, which is the unparse method of ProgramNodes
defined in the same file as DeclNode::unparse, the unparse method
of DeclNodes.
*/


void ProgramNode::unparse(std::ostream& out, int indent){
	/* Oh, hey it's a for-each loop in C++!
	   The loop iterates over each element in a collection
	   without that gross i++ nonsense. 
	 */
	for (auto global : *myGlobals){
		/* The auto keyword tells the compiler
		   to (try to) figure out what the
		   type of a variable should be from 
		   context. here, since we're iterating
		   over a list of DeclNode *s, it's 
		   pretty clear that global is of 
		   type DeclNode *.
		*/
		global->unparse(out, indent);
	}
}


void VarDeclNode::unparse(std::ostream& out, int indent){
	doIndent(out, indent);
	this->myID->unparse(out, 0);
	out << ": ";
	this->myType->unparse(out, 0);
	out << ";\n";
}

void IDNode::unparse(std::ostream& out, int indent){
	out << this->name;
}

void IntTypeNode::unparse(std::ostream& out, int indent){
	out << "int";
}

void BoolTypeNode::unparse(std::ostream& out, int indent){
	out << "bool";
}

void VoidTypeNode::unparse(std::ostream& out, int indent){
	out << "void";
}

void FileTypeNode::unparse(std::ostream& out, int indent) {
    out << "file";
}

void ArrayTypeNode::unparse(std::ostream& out, int indent) {
    myBase->unparse(out, 0);
    out << "[" << mySize << "]";
}

void ImmutableTypeNode::unparse(std::ostream& out, int indent) {
    out << "immutable ";
    myBase->unparse(out, 0);
}

void FormalDeclNode::unparse(std::ostream& out, int indent) {
    myID->unparse(out, 0);
    out << ": ";
    myType->unparse(out, 0);
}

void IntLitNode::unparse(std::ostream& out, int indent) {
    out << myVal;
}

void StrLitNode::unparse(std::ostream& out, int indent) {
    out << "\"" << myVal << "\"";
}

void TrueNode::unparse(std::ostream& out, int indent) {
    out << "true";
}

void FalseNode::unparse(std::ostream& out, int indent) {
    out << "false";
}

void ThrashNode::unparse(std::ostream& out, int indent) {
	out << "\\(-o-)//";
}

void ArrayIndexNode::unparse(std::ostream& out, int indent) {
	myBase->unparse(out, 0);
	out << "[";
	myIndex->unparse(out, 0);
	out << "]";
}

void CallExpNode::unparse(std::ostream& out, int indent) {
	myID->unparse(out, 0);
	out << "(";
	bool first = true;
	for (auto arg : *myArgs) {
		if (!first) out << ", ";
		arg->unparse(out, 0);
		first = false;
	}
	out << ")";
}

void InitializerNode::unparse(std::ostream& out, int indent) {
    out << "[";
    bool first = true;
    for (auto elem : *myElements) {
        if (!first) out << ", ";
        elem->unparse(out, 0);
        first = false;
    }
    out << "]";
}

void BinaryExpNode::unparse(std::ostream& out, int indent) {
    out << "(";
    myLhs->unparse(out, 0);
    out << " " << myOp << " ";
    myRhs->unparse(out, 0);
    out << ")";
}

void UnaryExpNode::unparse(std::ostream& out, int indent) {
    out << "(" << myOp;
    myExp->unparse(out, 0);
    out << ")";
}

void ReturnStmtNode::unparse(std::ostream& out, int indent) {
    doIndent(out, indent);
    out << "return";
    if (myExp != nullptr) {
        out << " ";
        myExp->unparse(out, 0);
    }
    out << ";\n";
}

void IfStmtNode::unparse(std::ostream& out, int indent) {
    doIndent(out, indent);
    out << "if (";
    myCond->unparse(out, 0);
    out << ") {\n";
    for (auto stmt : *myThenPart) stmt->unparse(out, indent + 1);
    doIndent(out, indent);
    out << "}\n";
}

void AssignStmtNode::unparse(std::ostream& out, int indent) {
    doIndent(out, indent);
    myLoc->unparse(out, 0);
    out << " = ";
    myExp->unparse(out, 0);
    out << ";\n";
}

void IfElseStmtNode::unparse(std::ostream& out, int indent) {
    doIndent(out, indent);
    out << "if (";
    myCond->unparse(out, 0);
    out << ") {\n";
    for (auto stmt : *myThenPart) stmt->unparse(out, indent + 1);
    doIndent(out, indent);
    out << "} else {\n";
    for (auto stmt : *myElsePart) stmt->unparse(out, indent + 1);
    doIndent(out, indent);
    out << "}\n";
}

void WhileStmtNode::unparse(std::ostream& out, int indent) {
    doIndent(out, indent);
    out << "while (";
    myCond->unparse(out, 0);
    out << ") {\n";
    for (auto stmt : *myBody) stmt->unparse(out, indent + 1);
    doIndent(out, indent);
    out << "}\n";
}

void CallStmtNode::unparse(std::ostream& out, int indent) {
    doIndent(out, indent);
    myCall->unparse(out, 0);
    out << ";\n";
}

void PostIncStmtNode::unparse(std::ostream& out, int indent) {
    doIndent(out, indent);
    myLoc->unparse(out, 0);
    out << "++;\n";
}

void PostDecStmtNode::unparse(std::ostream& out, int indent) {
    doIndent(out, indent);
    myLoc->unparse(out, 0);
    out << "--;\n";
}

void WriteStmtNode::unparse(std::ostream& out, int indent) {
    doIndent(out, indent);
    myDest->unparse(out, 0);
    out << " << ";
    mySrc->unparse(out, 0);
    out << ";\n";
}

void ReadStmtNode::unparse(std::ostream& out, int indent) {
    doIndent(out, indent);
    myDest->unparse(out, 0);
    out << " >> ";
    mySrc->unparse(out, 0);
    out << ";\n";
}

void SinkStmtNode::unparse(std::ostream& out, int indent) {
    doIndent(out, indent);
    out << "sink ";
    myID->unparse(out, 0);
    out << ";\n";
}

void FnDeclNode::unparse(std::ostream& out, int indent) {
    doIndent(out, indent);
    myID->unparse(out, 0);
    out << ": (";
    bool first = true;
    for (auto formal : *myFormals) {
        if (!first) out << ", ";
        formal->unparse(out, 0);
        first = false;
    }
    out << ") ";
    myReturnType->unparse(out, 0);
    out << " {\n";
    for (auto stmt : *myBody) stmt->unparse(out, indent + 1);
    doIndent(out, indent);
    out << "}\n";
}



} // End namespace leviathan
