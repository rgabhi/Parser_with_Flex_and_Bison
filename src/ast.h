#ifndef AST_H
#define AST_H


#include <stdlib.h>
#include <stdio.h>
#include <string.h>

// define node types
typedef enum {
    NODE_INT, // 5
    NODE_VAR, // x
    NODE_BIN_OP, // x + 5
    NODE_UNARY, // | 
    NODE_ASSIGN, // x = ...
    NODE_VAR_DECL, // var x
    NODE_IF, // if
    NODE_WHILE, // while
    NODE_BLOCK // {...} 
} NodeType;

// define operators
typedef enum {
    OP_PLUS, OP_MINUS, OP_MULT, OP_DIV,
    OP_EQ, OP_NEQ, OP_LT, OP_GT, OP_LE, OP_GE,
    OP_NEG // for unary minus (-)
} OpType;

// Node Structure
typedef struct ASTNode {
    NodeType type;
    // ptrs to connect tree
    struct ASTNode *left;
    struct ASTNode *right;
    struct ASTNode *next; // used for list of statements


    // Data specific to node
    union{
        int intValue; // for ints
        char *idName; // for var names
        OpType op; // for operators
     } data;
     
} ASTNode;

// functions
ASTNode* createIntNode(int value);
ASTNode* createVarNode(char *name);
ASTNode* createBinOpNode(OpType op, ASTNode *left, ASTNode *right);
ASTNode* createUnaryNode(OpType op, ASTNode *left);
ASTNode* createAssignNode(char *name, ASTNode *value);
ASTNode* createVarDeclNode(char *name, ASTNode *initValue);
ASTNode* createIfNode(ASTNode *cond, ASTNode *thenBranch, ASTNode *elseBranch);
ASTNode* createWhileNode(ASTNode *cond, ASTNode *body);
ASTNode* createBlockNode(ASTNode *statementList);


void freeAST(ASTNode *node);
void printAST(ASTNode *node, int level); // helper to visualize tree

#endif
