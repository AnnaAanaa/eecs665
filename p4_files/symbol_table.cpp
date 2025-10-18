#include "symbol_table.hpp"
#include <iostream>
#include <string>

namespace leviathan {

SemSymbol::SemSymbol(const std::string &name, const std::string &type, SymbolKind kind)
	: name(name), type(type), kind(kind) {}

const std::string &SemSymbol::getName() const { return name; }
const std::string &SemSymbol::getType() const { return type; }
SymbolKind SemSymbol::getKind() const { return kind; }

std::string SemSymbol::typeString() const{
	return "{"+type+"}";
}

ScopeTable::ScopeTable(){
	symbols = new HashMap<std::string, SemSymbol *>();
}
bool ScopeTable::insert(SemSymbol *sym){
	auto result = symbols->emplace(sym->getName(), sym);
	return result.second; // true if insertion took place, false if name already existed
}

SemSymbol * ScopeTable::lookupLocal(const std::string &name) const {
	auto it = symbols->find(name);
	if (it != symbols->end()) {
		return it->second;
	}
	return nullptr; // not found
}
void ScopeTable::dump(std::ostream & outstream) const {
	for (auto &pair : *symbols) {
		outstream << "  " << pair.first << "  " << pair.second->typeString() << "\n";

	}
}

SymbolTable::SymbolTable(){
	//TODO: implement the list of hashtables approach
	// to building a symbol table:
	// Upon entry to a scope a new scope table will be 
	// entered into the front of the chain and upon exit the 
	// latest scope table will be removed from the front of 
	// the chain.
	//scopeTableChain = new std::list<ScopeTable *>();
	enterScope(); // start with a global scope

	insert(new SemSymbol("in", "FILE", SymbolKind::VARIABLE));
	insert(new SemSymbol("out", "FILE", SymbolKind::VARIABLE));

}
void SymbolTable::enterScope() {
    scopeTableChain.push_front(new ScopeTable());
	sinkedNames.push_front({});
}

void SymbolTable::exitScope(){
	if (!scopeTableChain.empty()) {
        delete scopeTableChain.front();
        scopeTableChain.pop_front();
		sinkedNames.pop_front();
    }
}

bool SymbolTable::insert(SemSymbol *sym) {
    if (scopeTableChain.empty()) enterScope();
    return scopeTableChain.front()->insert(sym);
}

SemSymbol *SymbolTable::lookup(const std::string &name) const {
	auto sinkIter = sinkedNames.begin();
    for (auto *scope : scopeTableChain) {
		if (sinkIter != sinkedNames.end() && sinkIter->count(name) > 0) {
			++sinkIter;
			continue;
		}
        SemSymbol *sym = scope->lookupLocal(name);
        if (sym) return sym;
		++sinkIter;
    }
    return nullptr;
}

SemSymbol *SymbolTable::lookupLocal(const std::string &name) const {
    if (scopeTableChain.empty()) return nullptr;
    return scopeTableChain.front()->lookupLocal(name);
}
bool SymbolTable::sink(const std::string &name) {
    if (!lookup(name)) {
        // trying to sink something not in scope -> error
        return false;
    }
    sinkedNames.front().insert(name);
    return true;
}


void SymbolTable::dump(std::ostream & outstream) const {
    int level = 0;
    for (auto *scope : scopeTableChain) {
        outstream << "Scope level " << level++ << ":\n";
        scope->dump(outstream);
    }
}

}
