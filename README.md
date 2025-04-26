# Mini Compiler for a C Subset

This project implements a simple compiler that parses a subset of the C language and generates x86-64 assembly code. It uses **Flex** for lexical analysis and **Bison** for syntax analysis.

## Project Files

- `entrada.c` — Example input C file.
- `min.flex` — Lexical analyzer (scanner) to tokenize input.
- `min.y` — Syntax analyzer (parser) and code generator.
- `regras.txt` — Rules and instructions for using the compiler.

## Features

- Supports integer variable declarations and assignments.
- Handles addition (`+`) and subtraction (`-`) operations.
- Enforces basic semantic rules:
  - Variables must be declared before use.
  - Variables cannot be declared multiple times.
  - Variables must be assigned before being used.
- Respects parentheses for operation precedence.

## Rules

| Rule | Description | Error Message |
|:----:|:------------|:--------------|
| 1 | Variables must be declared only once. | `VARIAVEL JA DECLARADA` |
| 2 | Variables must be declared before assignment. | `VARIAVEL NAO DECLARADA` |
| 3 | Variables must be assigned before use in expressions. | `VARIAVEL NAO ATRIBUIDA ANTERIORMENTE` |
| 4 | Parentheses have higher priority in expressions. | — |

## How to Compile and Run

### Step 1: Generate parser and lexer, and compile

```bash
bison -d min.y
flex min.flex
gcc min.tab.c lex.yy.c -lfl -o min
./min < entrada.c
```

### Step 2: Assemble and link the output assembly

```bash
as out.s -o out.o
ld out.o -o out
./out
```

### Step 3: Check the program's exit status

```bash
echo $?
```

The output corresponds to the result of the `return` statement in your C input program.

## Example Inputs

### Example 1

```c
int main() {
    int x;
    int y;
    int z;
    int w;

    y = 6 + 2;
    z = 20 - y;
    x = 3 + z + 5;

    int a;
    a = 1;

    w = 35 + (x - y + z) + 24;

    return w - 3 - 6 - 7 + (22 + (2 - a));
}
```

### Example 2

```c
int main() {
    int x;
    int y;
    int z;

    z = 2;
    z = 5 + 6 + z;
    x = 3 + z - 5;

    return x + 4 - 2;
}
```

## Notes

- The generated assembly file is named `out.s`.
- Errors are reported with the specific line and column where they occur.
- The compiler ensures correct memory reservation and operation order based on the input.

