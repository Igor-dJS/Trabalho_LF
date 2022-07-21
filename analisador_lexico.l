%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

typedef enum _TOKEN {
EOF = -1, OPR = 0, RESERVADAS = 1, ID = 2, LITERALINT = 3, LITERALFLOAT = 4, ERROR = 5, IF = 6, 
ELSE = 7, WHILE = 8, VAR = 9, CONST = 10, RETURN = 11, FN = 12, ATRIB = 13,
BOOL = 14, INT = 15, FLOAT = 16, TRU =17, FALSE = 18, OPAR = 19, CPAR = 20, OBRAC = 21, 
CBRAC = 22, SCOL = 23, COL = 24
} TOKEN;

char* UpperCase(char str[]){
    char* copy = (char*)malloc(strlen(str));
    for(int j = 0; j < strlen(str); j++){
        copy[j] = str[j];
    }

    int i = 0;

    while(copy[i]){
        copy[i] = toupper(copy[i]);
        i++;
    }

    return copy;
}

int line, col = 1, nivel_comment = 0, colComment;

%}
LETRAMIN [a-z]
LETRAMAIS [A-Z]
LETRA [a-zA-Z]
NUM [0-9]
QUEBRA [\n]
TAB [\t]
SPACE [ ]

%option yylineno
%x COMMENT_LINE
%x COMMENT
%%

<INITIAL><<eof>> {return eof;}
<INITIAL>{QUEBRA} {col = 1;}
<INITIAL>"//" {col += 2; BEGIN(COMMENT_LINE);}

<COMMENT_LINE>{QUEBRA} {col=1; BEGIN(INITIAL);}
<COMMENT_LINE>{TAB} {col += 4;}
<COMMENT_LINE>(.) {col++;}
<COMMENT_LINE><<eof>> {return eof;}

<INITIAL>"/*" {line = yylineno; colComment = col; col += 2; nivel_comment++; BEGIN(COMMENT);}

<COMMENT>"/*" {line = yylineno; col += 2; nivel_comment++;}
<COMMENT>"*/" {col += 2; nivel_comment--; if(nivel_comment == 0) BEGIN(INITIAL);}
<COMMENT>{QUEBRA} {col = 1;}
<COMMENT>{TAB} {col += 4;}
<COMMENT>{SPACE} {col++;}
<COMMENT>(.) {col++;}
<COMMENT><<eof>> {return ERROR;}


<INITIAL>{TAB} {col += 4;}
<INITIAL>{SPACE} {col++;}
<INITIAL>"+"|"*"|"==" {return opr;}
<INITIAL>"if"|"else"|"while"|"var"|"const"|"return"|"fn"|"="|"bool"|"int"|"float"|"true"|"false"|"("|")"|"{"|"}"|";"|":" {return reservadas;}
<INITIAL>({LETRA}|_)({LETRA}|{NUM}|_)* {return id;}
<INITIAL>0|[1-9]{NUM}* {return literalint;}
<INITIAL>(0|[1-9][0-9]*)\.[0-9]+ {return literalfloat;}


%%

/*Function yywrap is called by lex when input is exhausted.
Return 1 if you are done or 0 if more processing is required.*/
int yywrap(void) { return 1; }

int main(int argc, char *argv[]) {
    TOKEN token_atual;

    yyin = fopen(argv[1], "r");
    // out = fopen(argv[2], "w");

    token_atual = (TOKEN) yylex();

    do{
        if(token_atual == ERROR){
            printf("(ERROR,\"/*\",%d,%d)\n", line, colComment);
            break;
        }else if(token_atual == EOF){
            printf("(EOF,\"%s\",%d,%d)\n", yytext, yylineno, col);
        }else if(token_atual == OPR){
            printf("(OPR,\"%s\",%d,%d)\n", yytext, yylineno, col);
            col += strlen(yytext);
        }else if(token_atual == RESERVADAS){
            printf("(%s,\"%s\",%d,%d)\n", UpperCase(yytext),yytext, yylineno, col);
            col += strlen(yytext);
        }else if(token_atual == ID){
            printf("(ID,\"%s\",%d,%d)\n", yytext, yylineno, col);
            col += strlen(yytext);
        }else if(token_atual == LITERALINT){
            printf("(LITERALINT,\"%s\",%d,%d)\n", yytext, yylineno, col);
            col += strlen(yytext);
        }else if(token_atual == LITERALFLOAT){
            printf("(LITERALFLOAT,\"%s\",%d,%d)\n", yytext, yylineno, col);
            col += strlen(yytext);
        }
    }while((token_atual = (TOKEN) yylex()) != EOF);

    printf("(EOF,\"%s\",%d,%d)\n", yytext, yylineno, col);


    fclose(yyin);
    // fclose(out);

    return 0;
}