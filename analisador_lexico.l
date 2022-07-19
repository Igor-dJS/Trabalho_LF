%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

// char* UpperCase(char str[]){
    // char copy[strlen(str)];
    // for(int j = 0; j < strlen(str); j++){
    //     copy[j] = str[j];
    // }

    // int i = 0;

    // while(copy[i]){
    //     copy[i] = toupper(copy[i]);
    //     i++;
    // }

    // return copy;
// }
FILE *out ;
int line, col = 1;

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

<INITIAL>{QUEBRA} {col = 1;}
<INITIAL>"//" {col += 2; BEGIN(COMMENT_LINE);}

<COMMENT_LINE>{QUEBRA} {BEGIN(INITIAL);}
<COMMENT_LINE>{TAB} {col += 4;}
<COMMENT_LINE>(.|{QUEBRA}) {col++;}

<INITIAL>"/*" {line = yylineno; col += 2; BEGIN(COMMENT);}

<COMMENT>"*/" {BEGIN(INITIAL);}
<COMMENT>{TAB} {col += 4;}

<INITIAL>{TAB} {col += 4;}
<INITIAL>{SPACE} {col++;}
<INITIAL>"+"|"*"|"==" {fprintf(out,"(OPR,\"%s\",%d, %d)\n", yytext, yylineno, col); col += strlen(yytext);}
<INITIAL>"if"|"else"|"while"|"var"|"const"|"return"|"fn"|"="|"bool"|"int"|"float"|"true"|"false"|"("|")"|"{"|"}"|";"|":" {fprintf(out,"(%s,\"%s\",%d, %d)\n", yytext, yytext, yylineno, col); col += strlen(yytext);}
<INITIAL>({LETRA}|_)({LETRA}|{NUM}|_)* {fprintf(out,"(ID,\"%s\",%d, %d)\n", yytext, yylineno, col); col += strlen(yytext);}
<INITIAL>0|[1-9]{NUM}* {fprintf(out,"(INTEIRO,\"%s\",%d, %d)\n", yytext, yylineno, col); col += strlen(yytext);}


%%

/*Function yywrap is called by lex when input is exhausted.
Return 1 if you are done or 0 if more processing is required.*/
int yywrap(void) { return 1; }

int main(int argc, char *argv[]) {

    yyin = fopen(argv[1], "r");
    out = fopen(argv[2], "w");
    yylex();

    // if ( strcmp(yylex(), "id") == 0) {
    // printf("A palavra %s pertence a linguagem.\n", yytext);
    // } else {
    // printf("A string %s nao pertence linguagem.\n", yytext);
    // }

    fclose(yyin);
    fclose(out);

    return 0;
}