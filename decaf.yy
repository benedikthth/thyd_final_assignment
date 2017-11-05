////////////////////////////////////////////////////////////////////////////////////

%skeleton "lalr1.cc"
%require "3.0.4"
%defines
%define parser_class_name {parser_decaf}

%define api.token.constructor
%define api.value.type variant

%define parse.assert
%define parse.trace
%define parse.error verbose

%code requires
{
#include <string>
#include "ast.h"
class Parser;
}

%parse-param { Parser& driver }
%locations
%code
{
#include "parser.h"
}

////////////////////////////////////////////////////////////////////////////////////

%token EOI 0

%token kwClass
%token kwStatic
%token kwVoid
%token kwInt
%token kwReal
%token kwReturn
%token kwBreak
%token kwContinue
%token kwIf
%token kwElse
%token kwFor

%token ptLBrace
%token ptRBrace
%token ptComma
%token ptSemicolon
%token ptLParen
%token ptRParen

%token OpAssign
%token OpArtPlus
%token OpArtMinus
%token OpArtMult
%token OpArtDiv
%token OpArtModulus
%token OpArtInc
%token OpArtDec
%token OpRelEQ
%token OpRelNEQ
%token OpRelLT
%token OpRelLTE
%token OpRelGT
%token OpRelGTE
%token OpLogAnd
%token OpLogOr
%token OpLogNot

%token <std::string> Identifier
%token <std::string> Number
%token <std::string> ErrUnknown

%left OpLogOr
%left OpLogAnd
%nonassoc OpRelEQ OpRelNEQ
%nonassoc OpRelLT OpRelLTE OpRelGT OpRelGTE
%left OpArtPlus OpArtMinus
%left OpArtMult OpArtDiv OpArtModulus
%left OpLogNot

%type <std::list<VariableDeclarationNode*>*> variable_declarations
%type <ValueType> type
%type <std::list<VariableExprNode*>*> variable_list
%type <VariableExprNode*> variable
%type <std::list<MethodNode*>*> method_declarations
%type <MethodNode*> method_declaration
%type <ValueType> method_return_type
%type <std::list<ParameterNode*>*> parameters
%type <std::list<ParameterNode*>*> parameter_list
%type <std::list<StmNode*>*> statement_list
%type <StmNode*> statement
%type <ExprNode*> optional_expr
%type <BlockStmNode*> statement_block
%type <IncrDecrStmNode*> incr_decr_var
%type <BlockStmNode*> optional_else
%type <std::list<ExprNode*>*> expr_list
%type <std::list<ExprNode*>*> more_expr
%type <ExprNode*> expr

////////////////////////////////////////////////////////////////////////////////////

%%

////////////////////////////////////////////////////////////////////////////////////

program: kwClass Identifier ptLBrace
             variable_declarations
             method_declarations
         ptRBrace
         { driver.set_AST( new ProgramNode( $2, $4, $5 ) ); }

variable_declarations: variable_declarations type variable_list ptSemicolon
                      { $$ = $1; $$->push_back( new VariableDeclarationNode($2,$3) ); }
                    | { $$ = new std::list<VariableDeclarationNode*>(); }

type: kwInt  { $$ = ValueType::IntVal; }
    | kwReal { $$ = ValueType::RealVal; }

variable_list: variable
               { $$ = new std::list<VariableExprNode*>(); $$->push_back( $1 ); }
             | variable_list ptComma variable
               { $$ = $1; $$->push_back( $3 ); }

variable:  Identifier      { $$ = new VariableExprNode($1); }

method_declarations: method_declarations method_declaration
                      { $$ = $1; $$->push_back( $2 ); }
                    | method_declaration 
                      { $$ = new std::list<MethodNode*>(); $$->push_back( $1 ); }

method_declaration:
    kwStatic method_return_type Identifier ptLParen parameters ptRParen ptLBrace
      variable_declarations
      statement_list
    ptRBrace
    { $$ = new MethodNode( $2, $3, $5, $8, $9 ); }

method_return_type: type    { $$ = $1; }
                  | kwVoid  { $$ = ValueType::VoidVal; }

parameters:  parameter_list  { $$ = $1; }
          |                  { $$ = new std::list<ParameterNode*>(); }

parameter_list: type variable
                { $$ = new std::list<ParameterNode*>();
                  $$->push_back( new ParameterNode($1, $2) ); }
              | parameter_list ptComma type variable
                { $$ = $1;
                  $$->push_back( new ParameterNode($3, $4) ); }

statement_list: statement_list statement
                { $$ = $1;  $$->push_back( $2 ); }
              | { $$ = new std::list<StmNode*>(); }

statement: variable OpAssign expr ptSemicolon
           { $$ = new AssignStmNode( $1, $3 ); }
         | Identifier ptLParen expr_list ptRParen ptSemicolon
           { $$ = new MethodCallExprStmNode( $1, $3 ); }
         | kwIf ptLParen expr ptRParen statement_block optional_else
           { $$ = new IfStmNode( $3, $5, $6 ); }
         | kwFor ptLParen variable OpAssign expr ptSemicolon
                          expr ptSemicolon incr_decr_var ptRParen statement_block
           { $$ = new ForStmNode( new AssignStmNode( $3, $5 ),
                                  $7, $9, $11 ); }
         | kwReturn optional_expr ptSemicolon
           { $$ = new ReturnStmNode( $2 ); }
         | kwBreak ptSemicolon
           { $$ = new BreakStmNode( ); }
         | kwContinue ptSemicolon
           { $$ = new ContinueStmNode( ); }
         | incr_decr_var ptSemicolon
           { $$ = $1; }
         | statement_block
           { $$ = $1; }

optional_expr:  expr  { $$ = $1; }
             |        { $$ = nullptr; }

statement_block: ptLBrace statement_list ptRBrace { $$ = new BlockStmNode($2); }

incr_decr_var:  variable OpArtInc { $$ = new IncrStmNode( $1 ); }
             |  variable OpArtDec { $$ = new DecrStmNode( $1 ); }

optional_else: kwElse statement_block   { $$ = $2; }
             |                          { $$ = nullptr; }

expr_list: expr more_expr          { $$ = $2; $$->push_front( $1 ); }
         |                         { $$ = new std::list<ExprNode*>(); }

more_expr: ptComma expr more_expr  { $$ = $3; $$->push_front( $2 ); }
         |                         { $$ = new std::list<ExprNode*>(); }

expr: Number                  { $$ = new NumberExprNode($1); }
    | variable                { $$ = $1; }
    | Identifier ptLParen expr_list ptRParen { $$ = new MethodCallExprStmNode($1,$3); }
    | ptLParen expr ptRParen  { $$ = $2; }
    | expr OpArtPlus    expr  { $$ = new PlusExprNode($1,$3); }
    | expr OpArtMinus   expr  { $$ = new MinusExprNode($1,$3); }
    | expr OpArtMult    expr  { $$ = new MultiplyExprNode($1,$3); }
    | expr OpArtDiv     expr  { $$ = new DivideExprNode($1,$3); }
    | expr OpArtModulus expr  { $$ = new ModulusExprNode($1,$3); }
    | expr OpRelEQ      expr  { $$ = new EqExprNode($1,$3); }
    | expr OpRelNEQ     expr  { $$ = new NeqExprNode($1,$3); }
    | expr OpRelLT      expr  { $$ = new LtExprNode($1,$3); }
    | expr OpRelLTE     expr  { $$ = new LteExprNode($1,$3); }
    | expr OpRelGT      expr  { $$ = new GtExprNode($1,$3); }
    | expr OpRelGTE     expr  { $$ = new GteExprNode($1,$3); }
    | expr OpLogAnd     expr  { $$ = new AndExprNode($1,$3); }
    | expr OpLogOr      expr  { $$ = new OrExprNode($1,$3); }
    |      OpLogNot     expr  { $$ = new NotExprNode($2); }
    |      OpArtPlus    expr  %prec OpLogNot { $$ = new PlusExprNode($2); }
    |      OpArtMinus   expr  %prec OpLogNot { $$ = new MinusExprNode($2); }

%%

////////////////////////////////////////////////////////////////////////////////////


void yy::parser_decaf::error(const yy::location& l, const std::string& m)
{
    std::cerr << l << ": " << m << std::endl;
}
