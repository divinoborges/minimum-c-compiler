%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdbool.h>
    #include <string.h>

    int extern linha;
    int extern coluna;
    int extern yyleng;
    char extern *yytext;
    
    // array usado para armazenar os nomes das variaveis declaradas
    char *variaveis_declaradas[100];

    // array usado para armazenar os nomes das variaveis ja atribuidas
    char *variaveis_atribuidas[100];

    // variavel para armazenar a variavel atual que esta sendo atribuida
    char *variavel_atual;

    // flag usada para determinar se a secao .bss foi criada
    bool secao_bss_criado = false;

    // flag usada para determinar se a secao .text e _start foram criadas
    bool secao_text_start_criado = false;

    FILE *f;

    int yylex(void);
    int yyerror(char *error_msg){
        printf("%s (%i,%i) = %s\n", error_msg, linha, coluna-yyleng, yytext);
        exit(1);
    }

    // abre o arquivo par escrita
    void abre_arquivo() {
        f = fopen("out.s", "w+");
    }

    // monta o codigo de secao .text e _start se a flag for falsa
    void montar_codigo_de_secao_text_start(){
        if (!secao_text_start_criado) {
            secao_text_start_criado = true;
            fprintf(f, "\n.text\n");
            fprintf(f, "    .global _start\n\n");
            fprintf(f, "_start:\n\n");
        }
    }

    void montar_codigo_retorno(){
        fprintf(f, "  popq %%rbx\n");
        fprintf(f, "  movq $1, %%rax\n");
        fprintf(f, "  int $0x80\n\n");
    }

    // fecha o arquivo criado
    void fecha_arquivo(){
        fclose(f);
        printf("Arquivo out.s gerado.\n\n");
    }

    // monta o codigo de secao .bss se a flag for falsa
    void montar_codigo_de_secao_de_declaracao_de_variaveis(){
        if (!secao_bss_criado) {
            fprintf(f, ".bss\n");
            secao_bss_criado = true;
        }
    }

    // adiciona a variavel na lista de variaveis declaradas
    void adiciona_variavel_na_lista_de_variaveis_declaradas(char *variavel){
        int i = 0;
        while(i < 100) {
            if (variaveis_declaradas[i] == NULL) {
                variaveis_declaradas[i] = strdup(variavel);
                break;
            }
            if (!strcmp(variaveis_declaradas[i], strdup(variavel))) {
                yyerror("VARIAVEL JA DECLARADA\n");
            };
            i++;
        }
    }

    // monta o codigo de reserva de memoria usando o .lcomm para uma variavel declarada
    void montar_codigo_declaracao_de_variavel(char *variavel){
        adiciona_variavel_na_lista_de_variaveis_declaradas(variavel);
        fprintf(f, "  .lcomm %s, 8\n", variavel);
    }

    void montar_codigo_empilhamento(int num){
        fprintf(f, "  pushq $%i\n", num);
    }

    void montar_codigo_operacao(char op){
        fprintf(f, "  popq %%rax\n");
        fprintf(f, "  popq %%rbx\n");
        if (op == '+') {
            fprintf(f, "  addq %%rax, %%rbx\n");
        }
         if (op == '-') {
            fprintf(f, "  subq %%rax, %%rbx\n");
        }
        fprintf(f, "  pushq %%rbx\n\n");
    }

    void verifica_se_variavel_foi_declarada(char *variavel){
        bool foi_declarada = false;
        int i = 0;
        while(i < 100) {
            if (variaveis_declaradas[i] == NULL) break;
            if (!strcmp(variaveis_declaradas[i],variavel)) {
                foi_declarada = true;
                break;
            };
            i++;
        }
        if (!foi_declarada) yyerror("VARIAVEL NAO DECLARADA\n");
    }

    void adiciona_variavel_na_lista_de_variaveis_atribuidas() {
        int i = 0;
        while(i < 100) {
            if (variaveis_atribuidas[i] == NULL) {
                variaveis_atribuidas[i] = strdup(variavel_atual);
                break;
            }
            if (!strcmp(variaveis_atribuidas[i], strdup(variavel_atual))) {
                break;
            };
            i++;
        }
    }

    void verifica_se_variavel_foi_atribuida(char *variavel) {
        bool foi_atribuida = false;
        int i = 0;
        while(i < 100) {
            if (variaveis_atribuidas[i] == NULL) break;
            if (!strcmp(variaveis_atribuidas[i], variavel)) {
                foi_atribuida = true;
                break;
            };
            i++;
        }
        if (!foi_atribuida) yyerror("VARIAVEL NAO ATRIBUIDA ANTERIORMENTE\n");
    }

    void montar_codigo_empilhamento_variavel(char *variavel){
        fprintf(f, "  pushq (%s)\n", variavel);
    }

    // remove da pilha e adiciona na variavel
    void montar_codigo_atribuicao_em_variavel() {
        fprintf(f, "  popq (%s)\n\n", variavel_atual);
    }

%}

%union {
    int inteiro;
    char *texto;
}

%token INT
%token MAIN
%token RETURN
%token ABRE_PARENTESES
%token FECHA_PARENTESES
%token ABRE_CHAVES
%token FECHA_CHAVES
%token PONTO_E_VIRGULA
%token IGUAL

%token<inteiro> NUM
%token<texto> VARIAVEL

%left MAIS MENOS

%%
programa: INT
          MAIN
          ABRE_PARENTESES
          FECHA_PARENTESES 
          ABRE_CHAVES { abre_arquivo(); }
          corpo
          FECHA_CHAVES { fecha_arquivo(); }
          ;

corpo: RETURN { montar_codigo_de_secao_text_start(); }
       expr
       PONTO_E_VIRGULA { montar_codigo_retorno();} corpo
       | declarao_de_variavel
       | atribuicao_em_variaveis 
       |
       ; 

expr: expr MAIS expr { montar_codigo_operacao('+'); }
      | expr MENOS expr { montar_codigo_operacao('-'); }
      | NUM { montar_codigo_empilhamento($1); }
      | VARIAVEL { verifica_se_variavel_foi_declarada($1); verifica_se_variavel_foi_atribuida($1); montar_codigo_empilhamento_variavel($1); }
      | ABRE_PARENTESES expr FECHA_PARENTESES
      ;

declarao_de_variavel: INT
                      VARIAVEL { montar_codigo_de_secao_de_declaracao_de_variaveis(); montar_codigo_declaracao_de_variavel($2); }
                      PONTO_E_VIRGULA corpo
                      ;

atribuicao_em_variaveis: VARIAVEL { variavel_atual = strdup($1); montar_codigo_de_secao_text_start(); verifica_se_variavel_foi_declarada($1); }
                         IGUAL
                         expr
                         PONTO_E_VIRGULA { montar_codigo_atribuicao_em_variavel(); adiciona_variavel_na_lista_de_variaveis_atribuidas(); } corpo
                         ;

%%

int main() {
    yyparse();
    printf("Entrada reconhecida.\n");
    return 0;
}