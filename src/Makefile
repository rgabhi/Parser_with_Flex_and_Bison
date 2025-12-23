# Compiler and Flags
CC = gcc
CFLAGS = -Wall -g -w # -w suppresses warnings (optional, good for Flex/Bison code)

# Output Binary Name
TARGET = simple_compiler

# Source Files
# Note: We include codegen.c because your report mentions MIPS generation.
# If you are strictly using the AST-only version, remove 'codegen.c' from this list.
SRCS = parser.tab.c lex.yy.c ast.c

# Object Files
OBJS = $(SRCS:.c=.o)

# Default Rule (Type 'make' to run this)
all: $(TARGET)

# Link the final executable
$(TARGET): $(SRCS)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRCS)

# Generate Parser (Bison)
# -d creates the header file (parser.tab.h) needed by the lexer
parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

# Generate Lexer (Flex)
# Depends on parser.tab.h because lexer.l includes token definitions
lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

# Clean Rule (Type 'make clean' to reset)
clean:
	rm -f $(TARGET) parser.tab.c parser.tab.h lex.yy.c *.o *.asm