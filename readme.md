# Lab 2B: Parser with Flex and Bison

**Course:** COP7001<br>
**Team Members:** [ Abhinav_Gupta  --  Pratik_Chaudhari ]


## 1. Overview
This project implements a **Lexical Analyzer** and **Parser** for a custom C-like imperative programming language using **GNU Flex** and **GNU Bison**. 

The compiler performs the following stages:
1.  **Lexical Analysis:** Tokenizes the input source code (keywords, identifiers, numbers, operators).
2.  **Parsing:** Validates the token stream against a defined context-free grammar.
3.  **Semantic Analysis:** Checks for variable redeclarations and ensures variables are declared before use.
4.  **AST Construction:** Generates an Abstract Syntax Tree (AST) representing the program structure.
5.  **Desugaring:** Automatically converts high-level constructs (like `for` loops) into simpler AST nodes (`while` loops) for easier backend processing.

## 2. Features & Requirements Met

### Functional Requirements
* **Tokenization:** Handles identifiers, integers, and operators while ignoring whitespace and single-line comments (`//`).
* **Grammar Parsing:** Supports a comprehensive grammar for statements, blocks, and expressions.
* **Control Flow:**
    * `if` / `else` statements (handles nested conditions and "dangling else").
    * `while` loops.
    * `for` loops (implemented via AST transformation).
* **Variable Management:**
    * Syntax: `var x;` or `var x = 10;`.
    * **Semantic Checks:** Errors are raised for undeclared variables or duplicate declarations.
* **Expression Support:**
    * Arithmetic: `+`, `-`, `*`, `/`, unary `-`.
    * Comparison: `==`, `!=`, `<`, `>`, `<=`, `>=`.
    * Operator Precedence: Correctly handles standard mathematical precedence (e.g., `*` binds tighter than `+`).
* **File Input:** Accepts script files as arguments for batch processing.

### Technical Highlights
* **AST Visualization:** The parser outputs a hierarchical textual representation of the AST to stdout.
* **Memory Management:** AST nodes are dynamically allocated.
* **Modular Build:** Uses a `Makefile` to compile Flex, Bison, and C sources separately.

## 3. Project Structure

```text
.
├── src/
│   ├── lexer.l         # Flex file: Defines tokens and lexical rules
│   ├── parser.y        # Bison file: Defines grammar, precedence, and semantic logic
│   ├── ast.c           # AST Implementation: Functions to create and print nodes
│   ├── ast.h           # AST Header: Node structs and enums
├── Makefile            # Build script to generate the 'parser_w_fnb' executable
├── tests/
│   ├── valid_test_cases/      # Scripts that should parse successfully
│   │   ├── test1_decl.txt
│   │   ├── test2_control_flow.txt
│   │   └── ...
│   └── invalid_test_cases/    # Scripts designed to trigger syntax/semantic errors
└── README.md           # Project documentation

```


## 4. Building and Running
**Prerequisites**<br>
* GCC (GNU Compiler Collection)
* Flex
* Bison
* Make

**Compilation**<br>
Navigate to the `src` directory and run:
    
```[text]
cd src
make
```
This will generate the executable binary named `parser_w_fnb`.

**Execution**<br>
You can run the parser in two modes:
1. File Input Mode (Recommended): Pass a source file as an argument:
```[text]
./parser_w_fnb ../tests/valid_test_cases/test3_for_loop.txt
```

2. Interactive Mode: Run without arguments and type code manually (press Ctrl+D to end input):
```[text]
./parser_w_fnb
```
**Cleaning Up**<br>
To remove object files and generated C source files:
```
make clean
```
## 5. Language Syntax
**Data Types**<br>
- Integers: Whole numbers `(e.g., 0, 42, -5)`.

**Variables**<br>
Must be declared using the `var` keyword.
```[text]
var a;
var b = 10;
a = b + 5;
```
**Control Structures**<br>
**If-Else:**<br>
```[text]
if (a > 5) {
    a = 0;
} else {
    a = 1;
}
```
While Loop:
```[text]
while (a < 10) {
    a = a + 1;
}
```
For Loop:
```[text]
for (var i = 0; i < 10; i = i + 1) {
    // Body
}
```
## 6. Implementation Details
**Semantic Analysis (Symbol Table)**<br>
A simple symbol table is implemented in `parser.y` to track declared variables.
- `addVariable`:Adds a variable to the table; calls `exit(1)` if a duplicate is found.
- `checkVarUsage`: Verifies if a variable exists; calls `exit(1)` if an undeclared variable is used.


**For Loop Desugaring**<br>
The `for` loop is not stored as a distinct AST node. Instead, the parser transforms it during construction:

**Source:** `for (INIT; COND; UPDATE) BODY`

**AST Result:**<br>
```[text]
BLOCK {
    INIT;
    WHILE (COND) {
        BLOCK {
            BODY;
            UPDATE;
        }
    }
}
```
This simplifies code generation or evaluation logic by reducing the number of node types.
