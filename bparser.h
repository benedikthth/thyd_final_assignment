
#ifndef DECAFPARSER_BPARSER_H
#define DECAFPARSER_BPARSER_H

#include "parser.h"
#include "parser_decaf.hpp"
#include "ast.h"

class BParser : public Parser {
public:

    BParser( FILE* file, bool debug_lexer, bool debug_parser )
            : Parser(file, debug_lexer, debug_parser)
    {
        extern FILE* yyin;
        yyin = file_;
    }

    virtual int parse() override
    {
        extern bool yy_flex_debug;
        yy::parser_decaf parser(*this);
        yy_flex_debug = debug_lexer_;
        parser.set_debug_level( debug_parser_ );
        int res = parser.parse();
        return res;
    }

    virtual std::string get_name() const override { return "Bison"; }
};

#endif //DECAFPARSER_BPARSER_H
