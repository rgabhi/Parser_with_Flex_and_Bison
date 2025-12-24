%option noyywrap
%option yylineno

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h> // for strdup
#include "ast.h" // for ASTNode
#include "parser.tab.h" // will generate with bison later

//int yylineno = 1; // init line no
%}

%%
    //keywords 
"var"   { return VAR; }
"if"    { return IF; }
"else"  { return ELSE; }
"while" { return WHILE; }
"for"   { return FOR; }

    /*operators*/
"=="    { return EQ; }
"!="    { return NEQ; }
"<"     { return LT; }
">"     { return GT; }
"<="    { return LE; }
">="    { return GE; }

    /*single char symbols*/
"+"     { return PLUS; }
"-"     { return MINUS; }
"*"     { return MULT; }
"/"     { return DIV; }
"="     { return ASSIGN; }
";"     { return SEMI; }
"("     { return LPAREN; }
")"     { return RPAREN; }
"{"     { return LBRACE; }
"}"     { return RBRACE; }

[0-9]+ { 
    yylval.intValue = atoi(yytext); // convert to int 
    return INTEGER; 
}

[a-zA-Z][a-zA-Z0-9]* { 
    yylval.idName = strdup(yytext);
    return IDENTIFIER; 
}

"//".* {/* Ignore comments */}

[ \t\n]+ {/* Ignore whitespace */}

. { 
    fprintf(stderr, "Lexical Error: Unknown character on line %d: '%s'\n", yylineno, yytext); 
    exit(1); 
}

%%