%{
#include <stdlib.h>
#include "Prog.h"
#include <string.h>
#include "Prog.tab.h"
void yyerror(const char *, char, int line);


%}


%option yylineno
%option noyywrap


%%

[|] {
                yylloc.last_line=yylloc.first_line =yylineno;
                return *yytext;
             }
			 
[-] {
                yylloc.last_line=yylloc.first_line =yylineno;
                return *yytext;
             }
			 
"true"|"false"    { 
                yylloc.last_line=yylloc.first_line =yylineno;
                if(*yytext == 't')
				   yylval.iBool = true;
				else 
				   yylval.iBool = false;
				return BOOL;
            }
			
"EMPTY"|"WALL"|"BOX"|"EXIT"|"UNDEF" {
                yylloc.last_line=yylloc.first_line =yylineno;
                int leng = strlen(yytext);
				yylval.iCell = (char*)calloc((leng+1),sizeof(char));
				strcpy(yylval.iCell , yytext);
				yylval.iName[leng] = '\0';
				return CELL;
}

"main"               {yylloc.last_line=yylloc.first_line =yylineno; return MAIN;}
"<="                   {yylloc.last_line=yylloc.first_line =yylineno; return AS;}
"in"                    {yylloc.last_line=yylloc.first_line =yylineno; return IN;}
"all in"               {yylloc.last_line=yylloc.first_line =yylineno; return AIN;}
"some in"         {yylloc.last_line=yylloc.first_line =yylineno; return SIN;}
"less"                 {yylloc.last_line=yylloc.first_line =yylineno; return LS;}
"all less"            {yylloc.last_line=yylloc.first_line =yylineno; return ALS;}
"some less"      {yylloc.last_line=yylloc.first_line =yylineno; return SLS;}
"if"                       {yylloc.last_line=yylloc.first_line =yylineno; return IF;}
"from"                {yylloc.last_line=yylloc.first_line =yylineno; return FROM;}
"while"               {yylloc.last_line=yylloc.first_line =yylineno; return WHILE;}
"to"                     {yylloc.last_line=yylloc.first_line =yylineno; return TO;}
"with step"       {yylloc.last_line=yylloc.first_line =yylineno; return STEP;}
"left"                 {yylloc.last_line=yylloc.first_line =yylineno; return LEFT;}
"right"              {yylloc.last_line=yylloc.first_line =yylineno; return RIGHT;}
"up"                 {yylloc.last_line=yylloc.first_line =yylineno; return UP;}
"down"           {yylloc.last_line=yylloc.first_line =yylineno; return DOWN;}
"function"      {yylloc.last_line=yylloc.first_line =yylineno; return FUNCTION;}
"do"                 {yylloc.last_line=yylloc.first_line =yylineno; return DO;}
"end"               {yylloc.last_line=yylloc.first_line =yylineno; return END;}
"pick"               {yylloc.last_line=yylloc.first_line =yylineno; return PICK;}
"drop"             {yylloc.last_line=yylloc.first_line =yylineno; return DROP;}
"look"               {yylloc.last_line=yylloc.first_line =yylineno; return LOOK;}
"go"                   {yylloc.last_line=yylloc.first_line =yylineno; return GO;}
"\["                   {yylloc.last_line=yylloc.first_line =yylineno; return *yytext;}
"\]"                   {yylloc.last_line=yylloc.first_line =yylineno; return *yytext;}
"print"            {yylloc.last_line=yylloc.first_line =yylineno; return PRINT;}
[;\n]                 {yylloc.last_line=yylloc.first_line =yylineno; return ENDLINE;}





[a-zA-Z]([A-Za-z]|[0-9]){0,19}   { 
                yylloc.last_line=yylloc.first_line =yylineno;
                int leng = strlen(yytext);
				yylval.iName = (char*)calloc((leng+1),sizeof(char));
				strcpy(yylval.iName , yytext);
				yylval.iName[leng] = '\0';
				return VARIABLE;
            }
			

[-?0-9]+      {
                yylloc.last_line=yylloc.first_line =yylineno;
                yylval.iValue = atoi(yytext);
				//yyerror("int", ' ');
                return INTEGER;
            }
			
			


[()&+,] {
                yylloc.last_line=yylloc.first_line =yylineno;
                return *yytext;
             }




[ \t]+        ;       /* ignore whitespace */

.               {yylloc.last_line=yylloc.first_line =yylineno; yyerror("invalid character", *yytext,yylineno);return *yytext;}
%%