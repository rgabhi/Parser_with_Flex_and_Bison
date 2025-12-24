# Lab 2B: Parser with Flex and Bison

**Name:** [Your Name]  
**Roll No:** [Your Roll No]  

## Overview
This project implements a Lexer and Parser for a C-like imperative programming language using **Flex** and **Bison**. The compiler accepts source code, validates the syntax, enforces semantic rules (variable declaration before use), and generates an **Abstract Syntax Tree (AST)**.

## Project Structure
The project follows the required directory structure:

```text
Folder
├── src/
│   ├── lexer.l         # Lexical Analyzer (Flex)
│   ├── parser.y        # Parser & Semantic Logic (Bison)
│   ├── ast.c           # AST Node Implementation
│   ├── ast.h           # AST Header Definitions
│   ├── Makefile        # Build Script
├── tests/
│   ├── valid/          # Test cases that should pass
│   └── invalid/        # Test cases that should fail
├── report.pdf          # Technical Report
└── README.md           # This file