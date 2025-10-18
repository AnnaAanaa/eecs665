#ifndef LEVI_AST_HPP
#define LEVI_AST_HPP

#include <ostream>
#include <list>
#include "tokens.hpp"
#include <cassert>


/* You'll probably want to add a bunch of ASTNode subclasses */

namespace leviathan{

/* You may find it useful to forward declare AST subclasses
   here so that you can use a class before it's full definition
*/
class DeclNode;
class TypeNode;
class StmtNode;
class IDNode;

/** 
* \class ASTNode
* Base class for all other AST Node types
**/
class ASTNode{
public:
	ASTNode(const Position * p) : myPos(p){ }
	virtual void unparse(std::ostream& out, int indent) = 0;
	const Position * pos() { return myPos; }
	std::string posStr() { return pos()->span(); }
protected:
	const Position * myPos = nullptr;
};

/** 
* \class ProgramNode
* Class that contains the entire abstract syntax tree for a program.
* Note the list of declarations encompasses all global declarations
* which includes (obviously) all global variables and struct declarations
* and (perhaps less obviously), all function declarations
**/
class ProgramNode : public ASTNode{
public:
	ProgramNode(std::list<DeclNode *> * globalsIn) ;
	void unparse(std::ostream& out, int indent) override;
private:
	std::list<DeclNode * > * myGlobals;
};

class StmtNode : public ASTNode{
public:
	StmtNode(const Position * p) : ASTNode(p){ }
	void unparse(std::ostream& out, int indent) override = 0;
};


/** \class DeclNode
* Superclass for declarations (i.e. nodes that can be used to 
* declare a struct, function, variable, etc).  This base class will 
**/
class DeclNode : public StmtNode{
public:
	DeclNode(const Position * p) : StmtNode(p) { }
	void unparse(std::ostream& out, int indent) override = 0;
};

/**  \class ExpNode
* Superclass for expression nodes (i.e. nodes that can be used as
* part of an expression).  Nodes that are part of an expression
* should inherit from this abstract superclass.
**/
class ExpNode : public ASTNode{
protected:
	ExpNode(const Position * p) : ASTNode(p){ }
};

/**  \class TypeNode
* Superclass of nodes that indicate a data type. For example, in 
* the declaration "int a", the int part is the type node (a is an IDNode
* and the whole thing is a DeclNode).
**/
class TypeNode : public ASTNode{
protected:
	TypeNode(const Position * p) : ASTNode(p){
	}
public:
	virtual void unparse(std::ostream& out, int indent) = 0;
};

/** A memory location. LocNodes subclass ExpNode
 * because they can be used as part of an expression. 
**/
class LocNode : public ExpNode{
public:
	LocNode(const Position * p)
	: ExpNode(p) {}
	void unparse(std::ostream& out, int indent) = 0;
};

/** An identifier. Note that IDNodes subclass
 * LocNode because they are a type of memory location. 
**/
class IDNode : public LocNode{
public:
	IDNode(const Position * p, std::string nameIn) 
	: LocNode(p), name(nameIn){ }
	void unparse(std::ostream& out, int indent);
private:
	/** The name of the identifier **/
	std::string name;
};


class InitializerNode : public ASTNode {
public:
    InitializerNode(const Position * p, std::list<ExpNode*> * elements)
        : ASTNode(p), myElements(elements) {
        assert(myElements != nullptr);
    }
    void unparse(std::ostream& out, int indent) override;
private:
    std::list<ExpNode*> * myElements;
};
 
/** A variable declaration.
**/
class VarDeclNode : public DeclNode{
public:
	VarDeclNode(const Position * p, IDNode * inID, TypeNode * inType) 
	: DeclNode(p), myID(inID), myType(inType){
		assert (myType != nullptr);
		assert (myID != nullptr);
	}
	void unparse(std::ostream& out, int indent);
private:
	IDNode * myID;
	TypeNode * myType;
};

class IntTypeNode : public TypeNode{
public:
	IntTypeNode(const Position * p) : TypeNode(p){ }
	void unparse(std::ostream& out, int indent);
};

class BoolTypeNode : public TypeNode {
public:
    BoolTypeNode(const Position * p) : TypeNode(p) { }
    void unparse(std::ostream& out, int indent) override;
};

class VoidTypeNode : public TypeNode {
public:
    VoidTypeNode(const Position * p) : TypeNode(p) { }
    void unparse(std::ostream& out, int indent) override;
};

class FileTypeNode : public TypeNode {
public:
    FileTypeNode(const Position * p) : TypeNode(p) { }
    void unparse(std::ostream& out, int indent) override;
};

class ArrayTypeNode : public TypeNode {
public:
    ArrayTypeNode(const Position * p, TypeNode * base, int size)
        : TypeNode(p), myBase(base), mySize(size) { }
    void unparse(std::ostream& out, int indent) override;
private:
    TypeNode * myBase;
    int mySize;
};

class ImmutableTypeNode : public TypeNode {
public:
    ImmutableTypeNode(const Position * p, TypeNode * base)
        : TypeNode(p), myBase(base) { }
    void unparse(std::ostream& out, int indent) override;
private:
    TypeNode * myBase;
};

class FnDeclNode : public DeclNode {
public:
    FnDeclNode(const Position * p, IDNode * id,
               std::list<VarDeclNode*> * formals,
               TypeNode * returnType,
               std::list<StmtNode*> * body)
        : DeclNode(p), myID(id), myFormals(formals),
          myReturnType(returnType), myBody(body) {
        assert(myID != nullptr);
        assert(myReturnType != nullptr);
        assert(myFormals != nullptr);
        assert(myBody != nullptr);
    }

    void unparse(std::ostream& out, int indent) override;

private:
    IDNode * myID;
    std::list<VarDeclNode*> * myFormals;
    TypeNode * myReturnType;
    std::list<StmtNode*> * myBody;
};

class ReturnStmtNode : public StmtNode {
public:
    ReturnStmtNode(const Position * p, ExpNode * exp = nullptr)
        : StmtNode(p), myExp(exp) {}
    void unparse(std::ostream& out, int indent) override;
private:
    ExpNode * myExp; // may be nullptr
};

class AssignStmtNode : public StmtNode {
public:
    AssignStmtNode(const Position * p, LocNode * loc, ExpNode * exp)
        : StmtNode(p), myLoc(loc), myExp(exp) {
        assert(myLoc != nullptr);
        assert(myExp != nullptr);
    }
    void unparse(std::ostream& out, int indent) override;
private:
    LocNode * myLoc;
    ExpNode * myExp;
};

class IfStmtNode : public StmtNode {
public:
    IfStmtNode(const Position * p, ExpNode * cond,
               std::list<StmtNode*> * thenPart,
               std::list<StmtNode*> * elsePart = nullptr)
        : StmtNode(p), myCond(cond), myThenPart(thenPart), myElsePart(elsePart) {
        assert(myCond != nullptr);
        assert(myThenPart != nullptr);
    }
    void unparse(std::ostream& out, int indent) override;
private:
    ExpNode * myCond;
    std::list<StmtNode*> * myThenPart;
    std::list<StmtNode*> * myElsePart; // may be nullptr
};

class IfElseStmtNode : public StmtNode {
public:
    IfElseStmtNode(const Position * p, ExpNode * cond,
                   std::list<StmtNode*> * thenPart,
                   std::list<StmtNode*> * elsePart)
        : StmtNode(p), myCond(cond), myThenPart(thenPart), myElsePart(elsePart) {
        assert(myCond != nullptr);
        assert(myThenPart != nullptr);
        assert(myElsePart != nullptr);
    }
    void unparse(std::ostream& out, int indent) override;
private:
    ExpNode * myCond;
    std::list<StmtNode*> * myThenPart;
    std::list<StmtNode*> * myElsePart;
};

class WhileStmtNode : public StmtNode {
public:
    WhileStmtNode(const Position * p, ExpNode * cond,
                  std::list<StmtNode*> * body)
        : StmtNode(p), myCond(cond), myBody(body) {
        assert(myCond != nullptr);
        assert(myBody != nullptr);
    }
    void unparse(std::ostream& out, int indent) override;
private:
    ExpNode * myCond;
    std::list<StmtNode*> * myBody;
};

class CallStmtNode : public StmtNode {
public:
    CallStmtNode(const Position * p, CallExpNode * call)
        : StmtNode(p), myCall(call) { assert(myCall != nullptr); }
    void unparse(std::ostream& out, int indent) override;
private:
    CallExpNode * myCall;
};

class PostIncStmtNode : public StmtNode {
public:
    PostIncStmtNode(const Position * p, LocNode * loc)
        : StmtNode(p), myLoc(loc) { }
    void unparse(std::ostream& out, int indent) override;
private:
    LocNode * myLoc;
};

class PostDecStmtNode : public StmtNode {
public:
    PostDecStmtNode(const Position * p, LocNode * loc)
        : StmtNode(p), myLoc(loc) { }
    void unparse(std::ostream& out, int indent) override;
private:
    LocNode * myLoc;
};

class WriteStmtNode : public StmtNode {
public:
    WriteStmtNode(const Position * p, LocNode * dest, ExpNode * src)
        : StmtNode(p), myDest(dest), mySrc(src) { }
    void unparse(std::ostream& out, int indent) override;
private:
    LocNode * myDest;
    ExpNode * mySrc;
};

class ReadStmtNode : public StmtNode {
public:
    ReadStmtNode(const Position * p, LocNode * dest, LocNode * src)
        : StmtNode(p), myDest(dest), mySrc(src) { }
    void unparse(std::ostream& out, int indent) override;
private:
    LocNode * myDest;
    LocNode * mySrc;
};

class SinkStmtNode : public StmtNode {
public:
    SinkStmtNode(const Position * p, IDNode * id)
        : StmtNode(p), myID(id) { }
    void unparse(std::ostream& out, int indent) override;
private:
    IDNode * myID;
};

class IntLitNode : public ExpNode {
public:
    IntLitNode(const Position * p, int val) : ExpNode(p), myVal(val) {}
    void unparse(std::ostream& out, int indent) override;
private:
    int myVal;
};

class BinaryExpNode : public ExpNode {
public:
    BinaryExpNode(const Position * p, ExpNode * lhs, std::string op, ExpNode * rhs)
        : ExpNode(p), myLhs(lhs), myOp(op), myRhs(rhs) {}
    void unparse(std::ostream& out, int indent) override;
private:
    ExpNode * myLhs;
    std::string myOp;
    ExpNode * myRhs;
};

class UnaryExpNode : public ExpNode {
public:
    UnaryExpNode(const Position * p, std::string op, ExpNode * exp)
        : ExpNode(p), myOp(op), myExp(exp) { }
    void unparse(std::ostream& out, int indent) override;
private:
    std::string myOp;
    ExpNode * myExp;
};

class TrueNode : public ExpNode {
public:
    TrueNode(const Position * p) : ExpNode(p) { }
    void unparse(std::ostream& out, int indent) override;
};

class FalseNode : public ExpNode {
public:
    FalseNode(const Position * p) : ExpNode(p) { }
    void unparse(std::ostream& out, int indent) override;
};

class StrLitNode : public ExpNode {
public:
    StrLitNode(const Position * p, std::string val)
        : ExpNode(p), myVal(val) { }
    void unparse(std::ostream& out, int indent) override;
private:
    std::string myVal;
};

class ThrashNode : public ExpNode {
public:
    ThrashNode(const Position * p) : ExpNode(p) { }
    void unparse(std::ostream& out, int indent) override {
        out << "\\(-o-)//";
    }
};


class ArrayIndexNode : public LocNode {
public:
    ArrayIndexNode(const Position * p, LocNode * base, ExpNode * index)
        : LocNode(p), myBase(base), myIndex(index) { }
    void unparse(std::ostream& out, int indent) override;
private:
    LocNode * myBase;
    ExpNode * myIndex;
};

class FormalDeclNode : public DeclNode {
public:
    FormalDeclNode(const Position * p, IDNode * id, TypeNode * type)
        : DeclNode(p), myID(id), myType(type) { }
    void unparse(std::ostream& out, int indent) override;
private:
    IDNode * myID;
    TypeNode * myType;
};

class CallExpNode : public ExpNode {
public:
    CallExpNode(const Position * p, IDNode * id,
                std::list<ExpNode*> * args)
        : ExpNode(p), myID(id), myArgs(args) {
        assert(myID != nullptr);
        assert(myArgs != nullptr);
    }
    void unparse(std::ostream& out, int indent) override;
private:
    IDNode * myID;
    std::list<ExpNode*> * myArgs;
};
// Helper function for indentation
inline void doIndent(std::ostream& out, int indent) {
    for (int i = 0; i < indent; i++) {
        out << "    "; // 4 spaces
    }
}

} //End namespace leviathan

#endif
