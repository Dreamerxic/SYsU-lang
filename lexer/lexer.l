%{
#include <stdio.h>
#include <string.h>
//int yylex(void);
//int yywrap(void);
void lex_error(const char*);
int token=0,  start_line, leading_space, row, col, pre=0;

enum E_LEX
{
    // keyword
    e_auto = 256,
    e_break,
    e_case,
    e_char,
    e_const,
    e_continue,
    e_default,
    e_do,
    e_double,
    e_else,
    e_enum,
    e_extern,
    e_float,
    e_for,
    e_goto,
    e_if,
    e_inline,
    e_int,
    e_long,
    e_register,
    e_restrict,
    e_return,
    e_short,
    e_signed,
    e_sizeof,
    e_static,
    e_struct,
    e_switch,
    e_typedef,
    e_union,
    e_unsigned,
    e_void,
    e_volatile,
    e_while,
    e_bool,
    e_complex,
    e_imaginary,
    e_pragma,

    // components
    e_identifier,
    e_newline,
    e_space,
    e_numconst,
    e_charconst,
    e_string,
    e_comment,

    // punctuators
    //e_l_brace,
    //e_r_brace,
    //e_l_square,
    //e_r_square,
    //e_hash,
    e_hashhash,
    //e_l_paren,
    //e_r_paren,
    //e_semi,
    //e_colon,
    e_ellipsis,
    //e_question,
    //e_period,
    //e_tilde,
    e_arrow,
    //e_exclaim,
    //e_plus,
    //e_minus,
    //e_star,
    //e_slash,
    //e_percent,
    //e_caret,
    //e_amp,
    //e_pipe,
    //e_equal,
    e_plusequal,
    e_minusequal,
    e_starequal,
    e_slashequal,
    e_percentequal,
    e_caretequal,
    e_ampequal,
    e_equalequal,
    e_exclaimequal,
    //e_less,
    //e_greater,
    e_lessequal,
    e_greaterequal,
    e_ampamp,
    e_pipepipe,
    e_lessless,
    e_greatergreater,
    e_lesslessequal,
    e_greatergreaterequal,
    e_plusplus,
    e_minusminus,
    //e_comma

    //preprocessor 
    e_ppdefine,
    e_ppundef,
    e_ppinclude,
    e_ppif,
    e_ppifdef,
    e_ppifndef,
    e_ppelse,
    e_ppelif,
    e_ppendif,
    e_ppline,
    e_pperror,
    e_pppragma,
    e_ppdefined,
    e_header

};

const char * s_token[400]={
    [0]="eof",
    ['{']="l_brace",
    ['}']="r_brace",
    ['[']="l_square",
    [']']="r_square",
    ['#']="hash",
    ['(']="l_paren",
    [')']="r_paren",
    [';']="semi",
    [':']="colon",
    ['?']="question",
    ['.']="period",
    ['~']="tilde",
    ['!']="exclaim",
    ['+']="plus",
    ['-']="minus",
    ['*']="star",
    ['/']="slash",
    ['%']="percent",
    ['^']="caret",
    ['&']="amp",
    ['|']="pipe",
    ['=']="equal",
    ['<']="less",
    ['>']="greater",
    [',']="comma",

    // keyword
    [256]="auto",
    "break",
    "case",
    "char",
    "const",
    "continue",
    "default",
    "do",
    "double",
    "else",
    "enum",
    "extern",
    "float",
    "for",
    "goto",
    "if",
    "inline",
    "int",
    "long",
    "register",
    "restrict",
    "return",
    "short",
    "signed",
    "sizeof",
    "static",
    "struct",
    "switch",
    "typedef",
    "union",
    "unsigned",
    "void",
    "volatile",
    "while",
    "bool",
    "complex",
    "imaginary",
    "pragma",

    // components
    "identifier",
    "newline",
    "space",
    "numeric_constant",
    "char",
    "string_literal",
    "comment",

    // punctuators
    "hashhash",
    "ellipsis",
    "arrow",
    "plusequal",
    "minusequal",
    "starequal",
    "slashequal",
    "percentequal",
    "caretequal",
    "ampequal",
    "equalequal",
    "exclaimequal",
    "lessequal",
    "greaterequal",
    "ampamp",
    "pipepipe",
    "lessless",
    "greatergreater",
    "lesslessequal",
    "greatergreaterequal",
    "plusplus",
    "minusminus",

    //preprocessor
    "ppdefine",
    "ppundef",
    "ppinclude",
    "ppif",
    "ppifdef",
    "ppifndef",
    "ppelse",
    "ppelif",
    "ppendif",
    "ppline",
    "pperror",
    "pppragma",
    "ppdefined",
    "header"

};


%}

NEWLINE             (\n)
SPACES              ([ \t\v\f\r\0\a\b]+)
U_ESCAPE            (\\U[0-9A-Fa-f]{1,8}|\\u[0-9A-Fa-f]{1,4})
IDENTIFIER          (([A-Z_a-z])([0-9A-Z_a-z])*)
NUM_CONST           (\.?[0-9]([.0-9A-Z_a-z]|[EPep][\+\-])*)
CHAR_CONST          (([LUu]|u8)?\'([^\n\'\\]|\\[^\n])*\')
CHAR_CONST_ERR          (([LUu]|u8)?\'([^\n\'\\]|\\[^\n])*)
STRING_LITERAL      (([LUu]|u8)?\"([^\n\"\\]|\\[^\n])*\")
STRING_LITERAL_ERR      (([LUu]|u8)?\"([^\n\"\\]|\\[^\n])*)
COMMENT_C           (\/\*([^\*]|\*+[^\*\/])*(\*\/)?)
COMMENT_CPP         (\/\/.*)
HEADER_FILE         (<([^\n>]|\\>)*>?|\"([^\n\"]|\\\")*\"?)

%s                  pp_directive
%s                  pp_expression
%s                  pp_header

%%

<pp_directive>{

    "define"          {
        BEGIN(pp_expression);
        return e_ppdefine;
    } 
    "undef"           {
        BEGIN(0);
        return e_ppundef;
    }

    "include"         {
        BEGIN(pp_header);
        return e_ppinclude;
    }

    "if"              {
        BEGIN(pp_expression);
        return e_ppif;
    }
    "ifdef"           {
        BEGIN(0);
        return e_ppifdef;
    }
    "ifndef"         {
        BEGIN(0);
        return e_ppifndef;
    }
    "else"            {
        BEGIN(0);
        return e_ppelse;
    }
    "elif"            {
        BEGIN(pp_expression);
        return e_ppelif;
    }
    "endif"           {
        BEGIN(0);
        return e_ppendif;
    }

    "line"            {
        BEGIN(pp_expression);
        return e_ppline;
    }

    "error"           {
        BEGIN(0);
        return e_pperror;
    }

    "pragma"          {
        BEGIN(pp_header);
        return e_pppragma;
    }

    {NUM_CONST}     |
    {IDENTIFIER}    {
        BEGIN(0);
        lex_error("Preprocessor directive unrecognized");
        return -1;
    }
    
}

<pp_expression>{
    "defined"         {
        return e_ppdefined;
    }
    {IDENTIFIER}        {
        return e_identifier;
    }
}

<pp_header>{HEADER_FILE}   {
    if (yyleng>=2)
        if (yytext[0]=='\"' && yytext[yyleng-1]=='\"' || yytext[0]=='<' && yytext[yyleng-1]=='>')
            return e_header;
    lex_error("HEADER_FILE unterminated");
    return -1;              
}

"auto"            {return e_auto;}
"break"           {return e_break;}
"case"            {return e_case;}
"char"            {return e_char;}
"const"           {return e_const;}
"continue"        {return e_continue;}
"default"         {return e_default;}
"do"              {return e_do;}
"double"          {return e_double;}
"else"            {return e_else;}
"enum"            {return e_enum;}
"extern"          {return e_extern;}
"float"           {return e_float;}
"for"             {return e_for;}
"goto"            {return e_goto;}
"if"              {return e_if;}
"inline"          {return e_inline;}
"int"             {return e_int;}
"long"            {return e_long;}
"register"        {return e_register;}
"restrict"        {return e_restrict;}
"return"          {return e_return;}
"short"           {return e_short;}
"signed"          {return e_signed;}
"sizeof"          {return e_sizeof;}
"static"          {return e_static;}
"struct"          {return e_struct;}
"switch"          {return e_switch;}
"typedef"         {return e_typedef;}
"union"           {return e_union;}
"unsigned"        {return e_unsigned;}
"void"            {return e_void;}
"volatile"        {return e_volatile;}
"while"           {return e_while;}
"_Bool"           {return e_bool;}
"_Complex"        {return e_complex;}
"_Imaginary"      {return e_imaginary;}
"_Pragma"         {return e_pragma;}

{IDENTIFIER}        {
    return e_identifier;
}

{NUM_CONST}         {
    return e_numconst;
}

{CHAR_CONST}        {
    return e_charconst;
    // if (yyleng>=3 &&yytext[yyleng-2]!='\\'&& yytext[yyleng-1]=='\'') return e_charconst;
    // lex_error("CHAR_CONSTANT unterminated");
    // return -1;              
}

{STRING_LITERAL}    {
    return e_string;
    // if (yyleng>=2 &&yytext[yyleng-2]!='\\'&& yytext[yyleng-1]=='\"') return e_string;
    // lex_error("STRING_LITERAL unterminated");
    // return -1;              
}

{COMMENT_C}         {
     if (yyleng>=4 && yytext[yyleng-2]=='*' && yytext[yyleng-1]=='/') return e_comment;
     lex_error("COMMENT_C unterminated");
     return -1;
 }     
{COMMENT_CPP}       {
    return e_comment;
}
{SPACES}             {
    return e_space;
}

{NEWLINE}           {
    BEGIN(0);
    return e_newline;
}

"<%"                |
"{"                 {return '{';}
"%>"                |
"}"                 {return '}';}
"<:"                |
"["                 {return '[';}
":>"                |
"]"                 {return ']';}
"%:"                |
"#"                 {
    if (start_line) BEGIN(pp_directive);
    return '#';
}
"%:%:"              |
"##"                {return e_hashhash;}
"("                 {return '(';}
")"                 {return ')';}
";"                 {return ';';}
":"                 {return ':';}
"..."               {return e_ellipsis;}
"?"                 {return '?';}
"."                 {return '.';}
"->"                {return e_arrow;}
"~"                 {return '~';}
"!"                 {return '!';}
"+"                 {return '+';}
"-"                 {return '-';}
"*"                 {return '*';}
"/"                 {return '/';}
"%"                 {return '%';}
"^"                 {return '^';}
"&"                 {return '&';}
"|"                 {return '|';}
"="                 {return '=';}
"+="                {return e_plusequal;}
"-="                {return e_minusequal;}
"*="                {return e_starequal;}
"/="                {return e_slashequal;}
"%="                {return e_percentequal;}
"^="                {return e_caretequal;}
"&="                {return e_ampequal;}
"=="                {return e_equalequal;}
"!="                {return e_exclaimequal;}
"<"                 {return '<';}
">"                 {return '>';}
"<="                {return e_lessequal;}
">="                {return e_greaterequal;}
"&&"                {return e_ampamp;}
"||"                {return e_pipepipe;}
"<<"                {return e_lessless;}
">>"                {return e_greatergreater;}
"<<="               {return e_lesslessequal;}
">>="               {return e_greatergreaterequal;}
"++"                {return e_plusplus;}
"--"                {return e_minusminus;}
","                 {return ',';}


.                   {
    lex_error("character unrecognized");
    return -1;
}

<<EOF>>             {
    BEGIN(0);
    return 0;
}

%%

void lex_error(const char* msg){
    
}

void print(void){
    if (token=='#' && start_line) pre=1;
    if (token==e_newline) pre=0;
    if (token==0) {
        start_line=0;
        leading_space=0;
    }
    if (token==e_space || token==e_comment || token==e_newline|| pre) return;
    fprintf(yyout, "%s '%s'\t%s\t%s\tLoc=<<stdin>:%d:%d>\n",
        s_token[token], yytext, 
        start_line?"[StartOfLine]":"",
        leading_space?"[LeadingSpace]":"",
        row, col
    );
    
}



int main(int argc, char * argv[]){
    yyout=stderr;
    token=0;
    start_line=1;
    leading_space=0;
    row=1;
    col=1;
    pre=0;
    do{
        int i=0;
        token=yylex();
        
        

        print();

        switch(token){
            case e_newline:            
                start_line=1;
                leading_space=0;
                break;

            case e_space:
            case e_comment:
                leading_space=1; 
                break;

            default:
                start_line=0;
                leading_space=0;
        }

        for(i=0; i<yyleng; ++i){
            if (yytext[i]=='\n') {
                row+=1;
                col=1;
            }
            else col+=1;
        }
    }
    while (token);

    return 0;
}



int yywrap(void){
    return 1;
}
