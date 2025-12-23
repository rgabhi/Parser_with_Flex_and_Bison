%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h> // for strdup
#include "ast.h" // for ASTNode
#include "parser.tab.h" // will generate with bison later
%}


%%

    //keywords 
"var" { return VAR; }
"if" { return IF; }
"else" { return ELSE; }
"while" { return WHILE; }

    /*operators*/
"==" { return EQ; }
"!=" { return NEQ; }
"<" { return LT; }
">" { return GT; }
"<=" { return LE; }
">=" { return GE; }

    /*single char symbols*/
"+" { return PLUS; }
"-" { return MINUS; }
"*" { return MULT; }
"/" { return DIV; }
"=" { return ASSIGN; }
";" { return SEMI; }
"(" { return LPAREN; }
")" { return RPAREN; }
"{" { return LBRACE; }
"}" { return RBRACE; }

[0-9]+ { 
    yylval.intValue = atoi(yytext); // convert to int 
    return INTEGER; }
[a-zA-Z][a-zA-Z0-9]* { 
    yylval.idName = strdup(yytext);
    return IDENTIFIER; }

"//".* {/* Igonre comments */}
[ \t\n]+ {}

. { printf("Unknown character: %s\n", yytext); exit(1); }

%%