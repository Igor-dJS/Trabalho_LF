%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

typedef enum _TOKEN {
eof = -1, opr = 0, reservadas = 1, id = 2, literalint = 3, literalfloat = 4
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
FILE *out ;
int line, col = 1, nivel_comment = 0;

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

<INITIAL><<eof>> {fprintf(out,"(ERROR,\"/*\",%d,%d)\n",yylineno, col); return eof;}
<INITIAL>{QUEBRA} {col = 1;}
<INITIAL>"//" {col += 2; BEGIN(COMMENT_LINE);}

<COMMENT_LINE>{QUEBRA} {col=1; BEGIN(INITIAL);}
<COMMENT_LINE>{TAB} {col += 4;}
<COMMENT_LINE>(.) {col++;}

<INITIAL>"/*" {line = yylineno; col += 2; nivel_comment++; BEGIN(COMMENT);}

<COMMENT>"/*" {line = yylineno; col += 2; nivel_comment++;}
<COMMENT>"*/" {col += 2; nivel_comment--; if(nivel_comment == 0) BEGIN(INITIAL);}
<COMMENT>{TAB} {col += 4;}
<COMMENT>(.) {col++;}
<COMMENT><<eof>> {fprintf(out,"(ERROR,\"/*\",%d,%d)\n",yylineno, col); return eof;}


<INITIAL>{TAB} {col += 4;}
<INITIAL>{SPACE} {col++;}
<INITIAL>"+"|"*"|"==" {fprintf(out,"(OPR,\"%s\",%d, %d)\n", yytext, yylineno, col); col += strlen(yytext); return opr;}
<INITIAL>"if"|"else"|"while"|"var"|"const"|"return"|"fn"|"="|"bool"|"int"|"float"|"true"|"false"|"("|")"|"{"|"}"|";"|":" {fprintf(out,"(%s,\"%s\",%d, %d)\n", UpperCase(yytext), yytext, yylineno, col); col += strlen(yytext); return reservadas;}
<INITIAL>({LETRA}|_)({LETRA}|{NUM}|_)* {fprintf(out,"(ID,\"%s\",%d, %d)\n", yytext, yylineno, col); col += strlen(yytext); return id;}
<INITIAL>0|[1-9]{NUM}* {fprintf(out,"(LITERALINT,\"%s\",%d, %d)\n", yytext, yylineno, col); col += strlen(yytext);return literalint;}
<INITIAL>(0|[1-9][0-9]*)\.[0-9]+ {fprintf(out,"(LITERALFLOAT,\"%s\",%d, %d)\n", yytext, yylineno, col); col += strlen(yytext); return literalfloat;}


%%

/*Function yywrap is called by lex when input is exhausted.
Return 1 if you are done or 0 if more processing is required.*/
int yywrap(void) { return 1; }

int main(int argc, char *argv[]) {
    TOKEN token_atual;

    yyin = fopen(argv[1], "r");
    out = fopen(argv[2], "w");

    while((token_atual = (TOKEN) yylex()) != eof){
        if(token_atual == eof){
            printf("(EOF,\"%s\",%d,%d)\n", yytext, yylineno, col);
        }else if(token_atual == opr){
            printf("(OPR,\"%s\",%d,%d)\n", yytext, yylineno, col -= strlen(yytext));
        }else if(token_atual == reservadas){
            printf("(%s,\"%s\",%d,%d)\n", UpperCase(yytext),yytext, yylineno, col -= strlen(yytext));
        }else if(token_atual == id){
            printf("(ID,\"%s\",%d,%d)\n", yytext, yylineno, col -= strlen(yytext));
        }else if(token_atual == literalint){
            printf("(LITERALINT,\"%s\",%d,%d)\n", yytext, yylineno, col -= strlen(yytext));
        }else if(token_atual == literalfloat){
            printf("(LITERALFLOAT,\"%s\",%d,%d)\n", yytext, yylineno, col -= strlen(yytext));
        }
    }

    fclose(yyin);
    fclose(out);

    return 0;
}