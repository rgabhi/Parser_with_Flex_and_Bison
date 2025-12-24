#include "ast.h"

// helper to create node
ASTNode* createNode(NodeType type){
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = type;
    node->left = NULL;
    node->right = NULL;
    node->next = NULL;
    return node;
}

ASTNode* createIntNode(int value){
    ASTNode* node = createNode(NODE_INT);
    node->data.intValue = value;
    return node;
}

ASTNode* createVarNode(char* name){
    ASTNode* node = createNode(NODE_VAR);
    node->data.idName = strdup(name);// make copy
    return node;
}
ASTNode* createBinOpNode(OpType op, ASTNode *left, ASTNode *right){
    ASTNode* node = createNode(NODE_BIN_OP);
    node->data.op = op;
    node->left = left;
    node->right = right;
    return node;
}

ASTNode* createAssignNode(char *name, ASTNode *value){
    ASTNode* node = createNode(NODE_ASSIGN);
    node->data.idName = strdup(name);
    node->left = value; // store val of exp in left
    return node;
}

ASTNode* createVarDeclNode(char *name, ASTNode *initValue){
    ASTNode* node = createNode(NODE_VAR_DECL);
    node->data.idName = strdup(name);
    node->left = initValue;
    return node;
}

ASTNode* createIfNode(ASTNode *cond, ASTNode *thenBranch, ASTNode *elseBranch){
    ASTNode* node = createNode(NODE_IF);
    node->left = cond;
    node->right = thenBranch;
    // convention: IfNode->left = cond, IfNode->right = then, IfNode->next = else.
    node->next = elseBranch;
    return node;
}

ASTNode* createWhileNode(ASTNode *cond, ASTNode *body){
    ASTNode* node = createNode(NODE_WHILE);
    node->left = cond;
    node->right = body;
    return node;
}

ASTNode *createBlockNode(ASTNode *statementList){
    ASTNode* node = createNode(NODE_BLOCK);
    node->left = statementList; // point to head of list
    return node;
}

ASTNode *createUnaryNode(OpType op, ASTNode *left){
    ASTNode* node = createNode(NODE_UNARY);
    node->data.op = op;
    node->left = left;
    return node;
}

const char* getOpSymbol(OpType op) {
    switch(op) {
        case OP_PLUS: return "+";
        case OP_MINUS: return "-";
        case OP_MULT: return "*";
        case OP_DIV: return "/";
        case OP_EQ: return "==";
        case OP_NEQ: return "!=";
        case OP_LT: return "<";
        case OP_GT: return ">";
        case OP_LE: return "<=";
        case OP_GE: return ">=";
        case OP_NEG: return "- (unary)";
        default: return "?";
    }
}


 //visualize
 void printAST(ASTNode *node, int level) {
    if (!node) return;

    // print indentation
    for (int i = 0; i < level; i++) printf("  ");
    
    // print tree marker
    if (level > 0) printf("|-- ");

    // print node details
    switch (node->type) {
        case NODE_INT:
            printf("Integer: %d\n", node->data.intValue);
            break;
        case NODE_VAR:
            printf("Variable: %s\n", node->data.idName);
            break;
        case NODE_BIN_OP:
            printf("Binary Op: %s\n", getOpSymbol(node->data.op));
            printAST(node->left, level + 1);
            printAST(node->right, level + 1);
            break;
        case NODE_UNARY:
            printf("Unary Op: %s\n", getOpSymbol(node->data.op));
            printAST(node->left, level + 1);
            break;
        case NODE_ASSIGN:
            printf("Assignment: %s\n", node->data.idName);
            printAST(node->left, level + 1);
            break;
        case NODE_VAR_DECL:
            printf("VarDecl: %s\n", node->data.idName);
            if (node->left) printAST(node->left, level + 1);
            break;
        case NODE_IF:
            printf("If Statement\n");
            // cond
            printAST(node->left, level + 1);
            // then branch
            printAST(node->right, level + 1);
            // else branch (stored in next for if nodes)
            if (node->next) {
                for (int i = 0; i < level + 1; i++) printf("  ");
                printf("|-- Else\n");
                printAST(node->next, level + 2);
            }
            break;
        case NODE_WHILE:
            printf("While Loop\n");
            printAST(node->left, level + 1); // cond
            printAST(node->right, level + 1); // body
            break;
        case NODE_BLOCK:
            printf("Block\n");
            printAST(node->left, level + 1);
            break;
    }

    // If this is a list (like in a block), print the next sibling
    // But NOT for IF statements where we used 'next' for 'else'
    if (node->type != NODE_IF && node->next != NULL) {
        // Pass the same level, so they appear as siblings
        printAST(node->next, level);
    }
}