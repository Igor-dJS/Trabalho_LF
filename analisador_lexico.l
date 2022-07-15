%{
#include <stdio.h>
#include <stdlib.h>
//if, else, while, var, const, return, fn, = (atribuição), bool (tipo), int (tipo), float (tipo), true e false, (, ), {, }, ;, :
typedef enum _TOKEN {
ID = "id", INT = "int", FLOAT = "float", OPR = "opr", IF = "if", ELSE = "else", WHILE = "while", VAR = "var",
CONST = "const", RETURN = "return", FN = "fn", ATRIB = "atrib", BOOL = "bool", TRULY = "true", FALSY = "false",
OPENPAR = "(", CLOSEPAR = ")", OPENBRACE = "{", CLOSEBRACE = "}", SEMICOLON = ";", COLON = ":"
} TOKEN;

%}
LETRAMIN [a-z]
LETRAMAIS [A-Z]
LETRA [a-zA-Z]
NUM [0-9]
SPACES [\t]|[[:space:]]

%%
<<EOF>>     { return eof; }

%%

char* ler_arquivo(char filename[]){ 
    char * buffer = 0;
    long length;

    FILE * f = fopen (filename, "rb");

    if (f)
    {
    fseek (f, 0, SEEK_END);
    length = ftell (f);
    fseek (f, 0, SEEK_SET);
    buffer = malloc (length);
    if (buffer)
    {
        fread (buffer, 1, length, f);
    }
    fclose (f);
    }

    if (buffer)
    {
        return buffer;
    }

    return NULL;
}

/*Function yywrap is called by lex when input is exhausted.
Return 1 if you are done or 0 if more processing is required.*/
int yywrap(void) { return 1; }

int main(int argc, char *argv[]) {
    int ln = 1, col = 1;
    char* entrada = lerArquivo(argv[1]);

    return 0;
}