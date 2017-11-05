#ifndef DECAFPARSER_SYMBOL_TABLE_H
#define DECAFPARSER_SYMBOL_TABLE_H

#include <string>
#include <map>
#include <list>

enum class ValueType { VoidVal, IntVal, RealVal };

inline std::string tostr( ValueType t ) {
    return ((t==ValueType::VoidVal) ? "void" : ((t==ValueType::IntVal) ? "int" : "real"));
}

enum class EntryType { Variable, Method };

inline std::string tostr( EntryType t ) {
    return ((t==EntryType::Variable) ? "Variable" : "Method");
}

class SymbolTable {
public:

    // Entry in the symbol table.
    class Entry {
    public:
        std::string name;
        std::string scope;
        EntryType   entry_type;
        ValueType   value_type;
        std::string signature;
    };

    static std::string to_str( Entry e ) {
        return std::string("(") + e.name + "," + e.scope + "," + tostr(e.entry_type) +
               "," + tostr(e.value_type) + "," + e.signature + ")";
    }

    // Returns the size of the symbol table.
    size_t size() const {
        return data_.size();
    }

    // Clears the symbol table.
    void clear() {
        data_.clear();
    }

    // Returns entry in symbol table for 'key' if exists, otherwise nullptr.
    SymbolTable::Entry* lookup( std::string scope, std::string name ) {
        auto it = data_.find( key(scope, name) );
        return ( it == data_.end() ) ? nullptr : &(it->second);
    }

    // Add a new entry to the symbol table
    // (overriding an existing entry with same name, if any).
    SymbolTable::Entry* add( const SymbolTable::Entry& entry ) {
        data_[key(entry.scope, entry.name)] = entry;
        return lookup( entry.scope, entry.name );
    }

    // Returns a list of the entries in the symbol table ordered by name.
    std::list<SymbolTable::Entry> entries() const {
        std::list<SymbolTable::Entry> list_of_entries;
        for ( auto it : data_ ) {
            list_of_entries.push_back( it.second );
        }
        return list_of_entries;
    }

private:

    std::string key( std::string scope, std::string name ) {
        return scope + std::string("::") + name;
    }

    std::map<std::string,SymbolTable::Entry> data_;
};

#endif //DECAFPARSER_SYMBOL_TABLE_H
