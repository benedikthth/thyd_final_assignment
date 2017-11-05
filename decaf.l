%{
#include "parser.h"
static yy::location loc;
%}
%option noyywrap nounput batch debug noinput

ws [ \t\r\n]
blank [ \t]
letter_ [a-zA-Z_]
digit [0-9]
digits [0-9]+

%x comment

%{
  // Code run each time a pattern is matched.
  # define YY_USER_ACTION  loc.columns (yyleng);
%}

%%

%{
  // Code run each time yylex is called.
  loc.step ();
%}

{blank}+                            { loc.step (); }
[\n]+                               { loc.lines(yyleng); loc.step (); }

"/*"                                { BEGIN(comment); }
<comment>[\n]+                      { loc.lines(yyleng); loc.step (); }
<comment>[^*\n]+
<comment>"*"
<comment>"*"+"/"                    { BEGIN(INITIAL); }

"class"                             { return decaf::make_kwClass(loc); }
"static"                            { return decaf::make_kwStatic(loc); }
"void"                              { return decaf::make_kwVoid(loc); }
"int"                               { return decaf::make_kwInt(loc); }
"real"                              { return decaf::make_kwReal(loc); }
"return"                            { return decaf::make_kwReturn(loc); }
"break"                             { return decaf::make_kwBreak(loc); }
"continue"                          { return decaf::make_kwContinue(loc); }
"if"                                { return decaf::make_kwIf(loc); }
"else"                              { return decaf::make_kwElse(loc); }
"for"                               { return decaf::make_kwFor(loc); }

"{"                                 { return decaf::make_ptLBrace(loc); }
"}"                                 { return decaf::make_ptRBrace(loc); }
"("                                 { return decaf::make_ptLParen(loc); }
")"                                 { return decaf::make_ptRParen(loc); }
";"                                 { return decaf::make_ptSemicolon(loc); }
","                                 { return decaf::make_ptComma(loc); }

"="                                 { return decaf::make_OpAssign(loc); }
"+"                                 { return decaf::make_OpArtPlus(loc); }
"-"                                 { return decaf::make_OpArtMinus(loc); }
"*"                                 { return decaf::make_OpArtMult(loc); }
"/"                                 { return decaf::make_OpArtDiv(loc); }
"%"                                 { return decaf::make_OpArtModulus(loc); }
"++"                                { return decaf::make_OpArtInc(loc); }
"--"                                { return decaf::make_OpArtDec(loc); }
"=="                                { return decaf::make_OpRelEQ(loc); }
"!="                                { return decaf::make_OpRelNEQ(loc); }
"<"                                 { return decaf::make_OpRelLT(loc); }
"<="                                { return decaf::make_OpRelLTE(loc); }
">"                                 { return decaf::make_OpRelGT(loc); }
">="                                { return decaf::make_OpRelGTE(loc); }
"&&"                                { return decaf::make_OpLogAnd(loc); }
"||"                                { return decaf::make_OpLogOr(loc); }
"!"                                 { return decaf::make_OpLogNot(loc); }

{letter_}({letter_}|{digit})*       { return decaf::make_Identifier(yytext,loc); }
{digits}("."{digits})?("E"("+"|"-")?{digits})?  { return decaf::make_Number(yytext,loc); }

.                                   { return decaf::make_ErrUnknown(yytext, loc); }

<<EOF>>                             { return decaf::make_EOI(loc); }
%%
