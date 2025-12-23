%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h" 

void yyerror(const char *s);
int yylex(void);

ASTNode *root; // global var to hold root of tree

%}

%union {
    int intValue;
    char* idName;
    struct ASTNode* node;
}

%token <intValue> INTEGER
%token <idName> IDENTIFIER


/*keywords*/
%token VAR IF ELSE WHILE

/* comp operators */
%token EQ NEQ LT GT LE GE

/* math */
%token PLUS MINUS MULT DIV ASSIGN SEMI LPAREN RPAREN LBRACE RBRACE
%token LOWER_THAN_ELSE

/* bind non-terminals (grammar rules to 'node' type) */
%type <node> program statement_list statement
%type <node> variable_decl assignment block if_statement while_statement
%type <node> expression additive_expression term factor

/*"If you see an IF statement and the next token is ELSE, 
compare their strengths. Since we defined %nonassoc ELSE 
later in the file than LOWER_THAN_ELSE, the ELSE wins. 
Therefore, keep reading (Shift) rather than finishing the statement (Reduce)."*/
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

program:
    statement_list { root = $1; } /* save result to global root. */
    ;


/**/
statement_list:
/*empty*/   { $$ = NULL; }
| statement_list statement {
    if($1 == NULL){
        $$ = $2;
    }
    else{
        /*finf the end of list and append new statement*/
        ASTNode *tmp = $1;
        while(tmp->next != NULL){
            tmp = tmp->next;
        }
        tmp->next = $2;
        $$ = $1;
    }
}
;

/**/
statement:
    variable_decl { $$ = $1; }
    | assignment { $$ = $1; }
    | if_statement { $$ = $1; }
    | while_statement { $$ = $1; }
    | block { $$ = $1; }
    ;


/**/
variable_decl:
    VAR IDENTIFIER SEMI{
        $$ = createVarDeclNode($2, NULL);
    } // var x;
    | VAR IDENTIFIER ASSIGN expression SEMI {
        $$ = createVarDeclNode($2, $4);
    }// var x = 5;
    ;

/**/
assignment:
    IDENTIFIER ASSIGN expression SEMI {
        $$ = createAssignNode($1, $3);
    }
    ;

/**/
block:
    LBRACE statement_list RBRACE {
        $$ = createBlockNode($2);
    }
    ;

/**/
if_statement:
    IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE{
        $$ = createIfNode($3, $5, NULL);
    }
    | IF LPAREN expression RPAREN statement ELSE statement{
        $$ = createIfNode($3, $5, $7);
    }
    ;

/**/
while_statement:
    WHILE LPAREN expression RPAREN statement {
        $$ = createWhileNode($3, $5);
    }
    ;


/*--------------*/ 
/*sits on top of additive_expression*/ 
expression:
    additive_expression {$$ = $1; }
    | expression EQ additive_expression { $$ = createBinOpNode(OP_EQ, $1, $3); }
    | expression NEQ additive_expression { $$ = createBinOpNode(OP_NEQ, $1, $3); }
    | expression LT additive_expression { $$ = createBinOpNode(OP_LT, $1, $3); }
    | expression GT additive_expression { $$ = createBinOpNode(OP_GT, $1, $3); }
    | expression LE additive_expression { $$ = createBinOpNode(OP_LE, $1, $3); }
    | expression GE additive_expression { $$ = createBinOpNode(OP_GE, $1, $3); }
    ;

/*sits on top of term*/ 
additive_expression:
    term { $$ = $1; }
    | additive_expression PLUS term { $$ = createBinOpNode(OP_PLUS, $1, $3); }
    | additive_expression MINUS term { $$ = createBinOpNode(OP_MINUS, $1, $3); }
    ;
/**/ 
term:
    factor { $$ = $1; }
    | term MULT factor { $$ = createBinOpNode(OP_MULT, $1, $3); }
    | term DIV factor { $$ = createBinOpNode(OP_DIV, $1, $3); }
    ; 

factor:
    INTEGER { $$ = createIntNode($1); }
    | IDENTIFIER { $$ = createVarNode($1); }
    | LPAREN expression RPAREN { $$ = $2; }
    ;


%%

/* User Code */

void yyerror(const char *s){
    fprintf(stderr, "Syntax Error: %s\n", s);
}

int main(){
    printf("Enter code (Ctrl+D to finish):\n");
    if(yyparse() == 0){
        printf("\nParsing Successful!\n");
        printAST(root, 0);
    }
    return 0;
}