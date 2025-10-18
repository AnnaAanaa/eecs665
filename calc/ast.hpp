#ifndef EECS665_AST
#define EECS665_AST
#include <list>
#include <iostream>
#include <string>

namespace EECS {

class OpNode;
class MathNode;

class ProgramNode{
public:
	std::list<OpNode *> * ops;
	void print(){
		for (auto op: *ops) {
			op->print();
		}
	}
};

enum OpTypes{
	CALCULATE, ORATE
};

class OpNode{
public:
	virtual ~OpNode(){}
	virtual void print()=0;
};

class CalculateNode: public OpNode{
	MathNode * lhs;
	MathNode * rhs;
public:
	CalculateNode (MathNode *l, MathNode *r): lhs(l), rhs(r) {}
	void print () override{
	std::cout <<"calculate ";
	lhs->print();
	std::cout<<" ";
	rhs->print();
	std::cout<<std::endl;
	
	}
};

class OrateNode: public OpNode{
	MathNode * lhs;
public:
	OrateNode(MathNode *l) : lhs(l) {}
	void print() override{
	std::cout<<"orate ";
	lhs->print();
	std::cout<<std::endl;
	}
};

class MathNode{
public:
    virtual ~MathNode() {}
    virtual void print() = 0;
};
class IDNode : public MathNode {
    std::string name;
public:
    IDNode(const std::string &n) : name(n) {}
    void print() override { std::cout << name; }
};

class NumNode : public MathNode {
    int value;
public:
    NumNode(int v) : value(v) {}
    void print() override { std::cout << value; }
};

class AddNode : public MathNode {
    MathNode * lhs;
    MathNode * rhs;
public:
    AddNode(MathNode *l, MathNode *r) : lhs(l), rhs(r) {}
    void print() override {
        lhs->print();
        std::cout << "+";
        rhs->print();
    }
};

class SubNode : public MathNode {
    MathNode * lhs;
    MathNode * rhs;
public:
    SubNode(MathNode *l, MathNode *r) : lhs(l), rhs(r) {}
    void print() override {
        lhs->print();
        std::cout << "-";
        rhs->print();
    }
};

class MultNode : public MathNode {
    MathNode * lhs;
    MathNode * rhs;
public:
    MultNode(MathNode *l, MathNode *r) : lhs(l), rhs(r) {}
    void print() override {
        lhs->print();
        std::cout << "*";
        rhs->print();
    }
};

class DivNode : public MathNode {
    MathNode * lhs;
    MathNode * rhs;
public:
    DivNode(MathNode *l, MathNode *r) : lhs(l), rhs(r) {}
    void print() override {
        lhs->print();
        std::cout << "/";
        rhs->print();
    }
};


} //End namespace
#endif


