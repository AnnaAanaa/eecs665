#ifndef LEVI_SYMBOL_TABLE_HPP
#define LEVI_SYMBOL_TABLE_HPP
#include <string>
#include <unordered_map>
#include <list>
#include <set>

//Use an alias template so that we can use
// "HashMap" and it means "std::unordered_map"
template <typename K, typename V>
using HashMap = std::unordered_map<K, V>;

using namespace std;

namespace leviathan {

//A semantic symbol, which represents a single
// variable, function, etc. Semantic symbols 
// exist for the lifetime of a scope in the 
// symbol table. 

enum class SymbolKind {
    VARIABLE,
    FUNCTION,
    PARAMETER
};

class SemSymbol {
	//TODO add the fields that 
	// each semantic symbol should track
	// (i.e. the kind of the symbol like variable or function)
	// and functions to get/set those fields
public:
    SemSymbol(const std::string &name, const std::string &type, SymbolKind kind);

    const std::string &getName() const;
    const std::string &getType() const;
    SymbolKind getKind() const;

    std::string typeString() const;
private:
	std::string name;
	std::string type;
	SymbolKind kind;
};

//A single scope. The symbol table is broken down into a 
// chain of scope tables, and each scope table holds 
// semantic symbols for a single scope. For example,
// the globals scope will be represented by a ScopeTable,
// and the contents of each function can be represented by
// a ScopeTable.
class ScopeTable {
	public:
		ScopeTable();
		//TODO: add functions for looking up symbols
		// and/or returning information to indicate
		// that the symbol does not exist within the
		// current scope.

		bool insert(SemSymbol *sym);
		SemSymbol * lookupLocal(const std::string & name) const;
		void dump(std::ostream & outstream) const;

	private:
		//Note: based on your implementation, you might
		// change this data type, since a name might not
		// be unique in a scope (if it's been sunk and then
		// redeclared in that scope!)

		HashMap<std::string, SemSymbol *> * symbols;
};

class SymbolTable{
	public:
		SymbolTable();
		//TODO: add functions to create a new ScopeTable
		// when a new scope is entered, drop a ScopeTable
		// when a scope is exited, etc. 
		void enterScope();
		void exitScope();
		bool insert(SemSymbol * sym);
		SemSymbol * lookup(const std::string & name) const;
		SemSymbol * lookupLocal(const std::string & name) const;
		bool SymbolTable::sink(const std::string &name);
		void dump(std::ostream & outstream) const;
	private:
		std::list<ScopeTable *> scopeTableChain;
		std::list<std::set<std::string>> sinkedNames;
};

	
} //End namespace

#endif
