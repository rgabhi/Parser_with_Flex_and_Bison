%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h" 

void yyerror(const char *s);
int yylex(void);
extern int yylineno;
extern FILE *yyin; // file ptr used by flex

extern char* yytext; // Required to see the offending token

ASTNode *root; // global var to hold root of tree

// Simple symbol table for tracking declared variables
#define MAX_VARS 1000
char* symbolTable[MAX_VARS];
int symbolCount = 0;

// Function to check if variable is declared
int isVarDeclared(const char* name) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i], name) == 0) {
            return 1; // Found
        }
    }
    return 0; // Not found
}

// Function to add variable to symbol table
void addVariable(const char* name) {
    if (symbolCount >= MAX_VARS) {
        fprintf(stderr, "Error: Too many variables declared\n");
        exit(1);
    }
    // Check for duplicate declaration
    if (isVarDeclared(name)) {
        fprintf(stderr, "Semantic Error: Variable '%s' already declared\n", name);
        exit(1);
    }
    symbolTable[symbolCount++] = strdup(name);
}

// Function to check variable usage
void checkVarUsage(const char* name) {
    if (!isVarDeclared(name)) {
        // Test 10: "error indicating undeclared variable" [cite: 178]
        fprintf(stderr, "Semantic Error at line %d: undeclared variable '%s'\n", yylineno, name);
        exit(1); 
    }
}

%}

%union {
    int intValue;
    char* idName;
    struct ASTNode* node;
}

%token <intValue> INTEGER
%token <idName> IDENTIFIER

/*keywords*/
%token VAR IF ELSE WHILE FOR

/* comp operators */
%token EQ NEQ LT GT LE GE

/* math */
%token PLUS MINUS MULT DIV ASSIGN SEMI LPAREN RPAREN LBRACE RBRACE

%token LOWER_THAN_ELSE

/* bind non-terminals (grammar rules to 'node' type) */
%type <node> program statement_list statement
%type <node> variable_decl assignment assignment_no_semi block if_statement while_statement for_statement
%type <node> for_init for_update
%type <node> expression equality comparison term factor unary primary

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
            /*find the end of list and append new statement*/
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
    | for_statement { $$ = $1; }
    | block { $$ = $1; }
    ;

/**/
variable_decl:
    VAR IDENTIFIER SEMI{
        addVariable($2);  // Add to symbol table
        $$ = createVarDeclNode($2, NULL);
    } // var x;
    | VAR IDENTIFIER ASSIGN expression SEMI {
        addVariable($2);  // Add to symbol table
        $$ = createVarDeclNode($2, $4);
    }// var x = 5;
    ;

/**/
assignment:
    IDENTIFIER ASSIGN expression SEMI {
        checkVarUsage($1);  // Check if variable is declared
        $$ = createAssignNode($1, $3);
    }
    ;

/* Assignment without semicolon (for use in for loops) */
assignment_no_semi:
    IDENTIFIER ASSIGN expression {
        checkVarUsage($1);  // Check if variable is declared
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

/* For loop initialization - can be assignment or declaration */
for_init:
    assignment_no_semi { $$ = $1; }
    | VAR IDENTIFIER ASSIGN expression {
        addVariable($2);
        $$ = createVarDeclNode($2, $4);
    }
    ;

/* For loop update - assignment without semicolon */
for_update:
    assignment_no_semi { $$ = $1; }
    ;

/**/
for_statement:
    FOR LPAREN for_init SEMI expression SEMI for_update RPAREN statement {
        // for (init; cond; update) body
        // We'll represent this as a block containing: init, while(cond){body; update}
        ASTNode* initNode = $3;
        ASTNode* condNode = $5;
        ASTNode* updateNode = $7;
        ASTNode* bodyNode = $9;
        
        // Create a sequence: body followed by update
        if (bodyNode->type == NODE_BLOCK) {
            // If body is already a block, append update to it
            ASTNode* tmp = bodyNode->left;
            if (tmp) {
                while(tmp->next != NULL) tmp = tmp->next;
                tmp->next = updateNode;
            } else {
                bodyNode->left = updateNode;
            }
        } else {
            // Create a block containing body and update
            bodyNode->next = updateNode;
            bodyNode = createBlockNode(bodyNode);
        }
        
        // Create while loop: while(cond) {body; update}
        ASTNode* whileNode = createWhileNode(condNode, bodyNode);
        
        // Create block containing: init; while_loop
        initNode->next = whileNode;
        $$ = createBlockNode(initNode);
    }
    ;

/*--------------*/ 
/*sits on top of additive_expression*/ 
expression:
    equality { $$ = $1; }
    ;

equality:
    comparison { $$ = $1; }
    | equality EQ comparison  { $$ = createBinOpNode(OP_EQ, $1, $3); }
    | equality NEQ comparison { $$ = createBinOpNode(OP_NEQ, $1, $3); }
    ;

comparison:
    term { $$ = $1; }
    | comparison LT term { $$ = createBinOpNode(OP_LT, $1, $3); }
    | comparison GT term { $$ = createBinOpNode(OP_GT, $1, $3); }
    | comparison LE term { $$ = createBinOpNode(OP_LE, $1, $3); }
    | comparison GE term { $$ = createBinOpNode(OP_GE, $1, $3); }
    ;

term:
    factor { $$ = $1; }
    | term PLUS factor  { $$ = createBinOpNode(OP_PLUS, $1, $3); }
    | term MINUS factor { $$ = createBinOpNode(OP_MINUS, $1, $3); }
    ;

factor:
    unary { $$ = $1; }
    | factor MULT unary { $$ = createBinOpNode(OP_MULT, $1, $3); }
    | factor DIV unary  { $$ = createBinOpNode(OP_DIV, $1, $3); }
    ;

unary:
    primary { $$ = $1; }
    | MINUS unary { $$ = createUnaryNode(OP_NEG, $2); } /* Handles -5 or -x */
    | PLUS unary  { $$ = $2; } /* Unary plus does nothing */
    ;

primary:
    INTEGER { $$ = createIntNode($1); }
    | IDENTIFIER { $$ = createVarNode($1); }
    | LPAREN expression RPAREN { $$ = $2; }
    ;

%%

/* User Code */
void yyerror(const char *s) {
    // Test 13: Handle missing braces by checking for empty token at EOF 
    if (yytext == NULL || strcmp(yytext, "") == 0) {
        fprintf(stderr, "Error at line %d: parse failure due to missing '}'\n", yylineno);
    } 
    // Test 12: Specific message for malformed expressions [cite: 185]
    else if (strcmp(yytext, ";") == 0) {
        fprintf(stderr, "Error at line %d: syntax error near ';'\n", yylineno);
    }
    // Test 11: General syntax error with token [cite: 182, 197]
    else {
        fprintf(stderr, "Error at line %d: syntax error (unexpected token: '%s')\n", yylineno, yytext);
    }
    exit(1); 
}


int main(){
    printf("Enter code (Ctrl+D to finish):\n");
    if(yyparse() == 0){
        printf("\nParsing Successful!\n");
        printf("\nAbstract Syntax Tree:\n");
        printf("=====================\n");
        printAST(root, 0);
    }
    return 0;
}