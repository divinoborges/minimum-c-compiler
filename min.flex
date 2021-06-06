%{
	#include "min.tab.h"
	int linha=1;
	int coluna=1;
%}

LETRA [a-zA-Z]
DIGITO [0-9]
%%
[\n]						{linha++; coluna=1;}
"int"						{ coluna += yyleng; return INT; }
"main"						{ coluna += yyleng; return MAIN; }
"("							{ coluna += yyleng; return ABRE_PARENTESES; }
")"							{ coluna += yyleng; return FECHA_PARENTESES; }
"{"							{ coluna += yyleng; return ABRE_CHAVES; }
"}"							{ coluna += yyleng; return FECHA_CHAVES; }
";"							{ coluna += yyleng; return PONTO_E_VIRGULA; }
"return"					{ coluna += yyleng; return RETURN; }
"+"							{ coluna += yyleng; return MAIS; }
"-"							{ coluna += yyleng; return MENOS; }
"="							{ coluna += yyleng; return IGUAL; }
{DIGITO}+					{ coluna += yyleng; yylval.inteiro = atoi(yytext); return NUM; }
{LETRA}({LETRA}|{DIGITO})*	{ coluna += yyleng; yylval.texto = yytext; return VARIAVEL; }
.	{ coluna += yyleng; }
%%
