
#ifndef DECAFPARSER_PARSER_H
#define DECAFPARSER_PARSER_H

#include <string>
#include "ast.h"
#include "parser_decaf.hpp"
using decaf = yy::parser_decaf;
#define YY_DECL decaf::symbol_type yylex ()
YY_DECL;

class Parser {
public:
    // Constructor, input stream to read provided.
    Parser( FILE* file, bool debug_lexer, bool debug_parser ) : file_(file),
        debug_lexer_(debug_lexer), debug_parser_(debug_parser), ast_(nullptr) {}

    // Parse the input. This method could potentially throw IO-related exceptions.
    virtual int parse( ) = 0;

    // Return a name given to the parser (e.g., "Bison" or "handmade").
    virtual std::string get_name() const = 0;

    // Keep the root node of the abstract syntax tree.
    void set_AST( Node* node ) { ast_ = node; }

    // Return the root node of the abstract syntax tree.
    Node* get_AST( ) { return ast_; }

    // Destructor.
    virtual ~Parser() = default;

protected:
    FILE *file_;
    bool debug_lexer_;
    bool debug_parser_;
    Node *ast_;
};

#endif //DECAFPARSER_PARSER_H
