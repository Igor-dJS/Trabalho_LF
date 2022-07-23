%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

// define uma tupla que é composta de um enum, sua chave, e a string contendo seu nome/tipo, o valor associado à chave
typedef struct _enum_tuple 
{
    int    enum_key;
    char  *enum_value;
} enum_tuple;

// retorna a string associada a uma chave dada por key no dicionário dado em table
char* GetEnumName(enum_tuple* table, int key)
{
   while (table->enum_value != NULL)
   {
      if (table->enum_key == key)
        return table->enum_value;
      table++;
   }
   return NULL;
}

// representa os tokens da linguagem LF
typedef enum _TOKEN 
{
eof = -1, OPR = 0, RESERVADAS = 1, ID = 2, LITERALINT = 3, LITERALFLOAT = 4, ERROR = 5, IF = 6, 
ELSE = 7, WHILE = 8, VAR = 9, CONST = 10, RETURN = 11, FN = 12, ATRIB = 13,
BOOL = 14, INT = 15, FLOAT = 16, TRU =17, FALS = 18, OPAR = 19, CPAR = 20, OBRAC = 21, 
CBRAC = 22, SCOL = 23, COL = 24
} TOKEN;

// representa um dicionário de tokens
enum_tuple dicionario_tokens[] = 
{
    { eof, "eof" },
    { OPR, "OPR" },
    { RESERVADAS,  "RESERVADAS"  },
    { ID,  "ID"  },
    { LITERALINT,"LITERALINT"},
    {LITERALFLOAT, "LITERALFLOAT"}, 
    {ERROR, "ERROR"}, 
    {IF, "IF"}, 
    {ELSE, "ELSE"}, 
    {WHILE, "WHILE"},
    {VAR, "VAR"},
    {CONST, "CONST"},
    {RETURN, "RETURN"},
    {FN, "FN"},
    {ATRIB, "ATRIB"},
    {BOOL, "BOOL"},
    {INT, "INT"}, 
    {FLOAT, "FLOAT"},
    {TRU, "TRU"},
    {FALS, "FALS"},
    {OPAR, "OPAR"},
    {CPAR, "CPAR"},
    {OBRAC, "OBRAC"},
    {CBRAC, "CBRAC"},
    {SCOL, "SCOL"},
    {COL, "COL"},
};

// retorna a string contendo o nome ou tipo associada ao token dado por token_key
char* GetTokenName(TOKEN token_key)
{
    return GetEnumName(dicionario_tokens, token_key);
}


/*
%option yylineno é uma variável nativa do flex que aramzena em que linha da entrada está o analisador.
É incremmentado em 1 toda vez que uma quebra de linha é lida

a variável 'line' recebe o valor da linha atual ao iniciar um comentário de múltiplas linhas, pois
se todos os cometários não forem fechados o analisador será capaz de mostrar a linha que se iniciou o 
comentário. E a variável 'colComment' guarda a coluna para o mesmo propósito

'col' controlará a qual coluna cada token pertence e ela se inicia em 1

'nivel_comment' guarda quantos comentários do tipo "/*" foram abertos e ao fechar todos voltamos pro
estado inicial do analisador
*/
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
<INITIAL>"+"|"*"|"==" {return OPR;}
<INITIAL>"if" {return IF;}
<INITIAL>"else" {return ELSE;}
<INITIAL>"while" {return WHILE;}
<INITIAL>"var" {return VAR;}
<INITIAL>"const" {return CONST;}
<INITIAL>"return" {return RETURN;}
<INITIAL>"fn" {return FN;}
<INITIAL>"=" {return ATRIB;}
<INITIAL>"bool" {return BOOL;}
<INITIAL>"int" {return INT;}
<INITIAL>"float" {return FLOAT;}
<INITIAL>"true" {return TRU;}
<INITIAL>"false" {return FALS;}
<INITIAL>"(" {return OPAR;}
<INITIAL>")" {return CPAR;}
<INITIAL>"{" {return OBRAC;}
<INITIAL>"}" {return CBRAC;}
<INITIAL>";" {return SCOL;}
<INITIAL>":" {return COL;}
<INITIAL>({LETRA}|_)({LETRA}|{NUM}|_)* {return ID;}
<INITIAL>0|[1-9]{NUM}* {return LITERALINT;}
<INITIAL>(0|[1-9][0-9]*)\.[0-9]+ {return LITERALFLOAT;}


%%

/*Function yywrap is called by lex when input is exhausted.
Return 1 if you are done or 0 if more processing is required.*/
int yywrap(void) 
{
    return 1; 
}

int main(int argc, char *argv[])
{
    TOKEN token_atual; // representa a classificação do token atualmente em análise/leitura

    // abrir arquivos
    yyin = fopen("input.text", "r"); // abrir para leitura arquivo onde código para análise léxica está para leitura
    yyout = fopen("output.txt", "w"); // criar arquivo para escrita onde os resultados da análise léxica

    while(1)
    {
        // ler próximo token para análise
        token_atual = (TOKEN) yylex(); 

        // testar validade do token:
        if (token_atual == EOF) // inválido, se for o fim do arquivo
        {
            fprintf(yyout, "(EOF, %d, %d)\n", yylineno, col); // imprimir tupla (tipo, token, info)
            break;
        }
        if (token_atual == ERROR) // inválido, se houver algum erro
        {
            fprintf(yyout, "(ERROR,\"/*\",%d,%d)\n", line, colComment); // imprimir mensagem de erro
            break;
        }
        char* tokenName; // representa o nome do tipo de token reconhecido
        if ((tokenName = GetTokenName(token_atual)) != NULL) //válido, se não for fim do arquivo, não houver erro e se for um comando reconhecido pelas regras
        {
            fprintf(yyout, "(%s,\"%s\",%d,%d)\n", tokenName, yytext, yylineno, col); // imprimir tupla (tipo, token, info)
            col += strlen(yytext); // atualizar contagem de colunas
        }
        else fprintf(yyout, "\n");
    } 
    
    // fechar arquivos de leitura e escrita
    fclose(yyin);
    fclose(yyout);

    return 0;
}
