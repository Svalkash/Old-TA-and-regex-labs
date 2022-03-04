%{
#include "Robot.h"
#include "Robot.tab.h"
#include <cstring>

extern bool errorFlag;
extern int visRad;

void lexerror(const char *s, char c, int line);
%}

%option yylineno
%option noyywrap
%x COMMENT1 COMMENT2

%%

<INITIAL>{
"true"|"false" { 
	yylloc.last_line = yylloc.first_line = yylineno;
	if(*yytext == 't')
		yylval.iBool = true;
	else 
		yylval.iBool = false;
	return BOOL;
}

"EMPTY"|"WALL"|"BOX"|"EXIT"|"UNDEF" {
	yylloc.last_line = yylloc.first_line = yylineno;
	int len = strlen(yytext) + 1;
	yylval.iCell = new char[len]; /*sends_raw_char*_values_to_analyze_later*/
	strcpy(yylval.iCell , yytext); /*i'd_prefer_to_use_microsoft_functions...*/
	yylval.iCell[len] = '\0';
	return CELL;
}

[0-9]+(\.[0-9]+)?(E\-?[0-9]+)? {
	yylloc.last_line=yylloc.first_line =yylineno;
	yylval.iValue = (int)atof(yytext); /*hope it works*/
	return INTEGER;
}

"VISRAD"    {
	yylloc.last_line=yylloc.first_line =yylineno;
	yylval.iValue = visRad;
	return INTEGER;
}

"<="		{yylloc.last_line = yylloc.first_line = yylineno; return AS;}

"in"		{yylloc.last_line = yylloc.first_line = yylineno; return IN;}

"all in"	{yylloc.last_line = yylloc.first_line = yylineno; return AIN;}

"some in"	{yylloc.last_line = yylloc.first_line = yylineno; return SIN;}

"less"		{yylloc.last_line = yylloc.first_line = yylineno; return LS;}

"all less"	{yylloc.last_line = yylloc.first_line = yylineno; return ALS;}

"some less"	{yylloc.last_line = yylloc.first_line = yylineno; return SLS;}

"if"		{yylloc.last_line = yylloc.first_line = yylineno; return IF;}

"while"		{yylloc.last_line = yylloc.first_line = yylineno; return WHILE;}

"from"		{yylloc.last_line = yylloc.first_line = yylineno; return FROM;}

"to"        {yylloc.last_line = yylloc.first_line = yylineno; return TO;}

"with"[ \t]+"step" {yylloc.last_line = yylloc.first_line = yylineno; return STEP;}

"print"		{yylloc.last_line = yylloc.first_line = yylineno; return PRINT;}

"prints"	{yylloc.last_line = yylloc.first_line = yylineno; return PRINTS;}

"left"      {yylloc.last_line = yylloc.first_line = yylineno; return LEFT;}

"right" 	{yylloc.last_line = yylloc.first_line = yylineno; return RIGHT;}

"up" 		{yylloc.last_line = yylloc.first_line = yylineno; return UP;}

"down" 		{yylloc.last_line = yylloc.first_line = yylineno; return DOWN;}

"function"	{yylloc.last_line = yylloc.first_line = yylineno; return FUNCTION;}

"do" 		{yylloc.last_line = yylloc.first_line = yylineno; return DO;}

"end" 		{yylloc.last_line = yylloc.first_line = yylineno; return END;}

"pick"      {yylloc.last_line = yylloc.first_line = yylineno; return PICK;}

"drop"      {yylloc.last_line = yylloc.first_line = yylineno; return DROP;}

"look"      {yylloc.last_line = yylloc.first_line = yylineno; return LOOK;}

"go"        {yylloc.last_line = yylloc.first_line = yylineno; return GO;}

"\["        {yylloc.last_line = yylloc.first_line = yylineno; return *yytext;}

"\]"        {yylloc.last_line = yylloc.first_line = yylineno; return *yytext;}

[;\n]       {yylloc.last_line = yylloc.first_line = yylineno; return ENDLINE;}

[()&+,|\-] {
	yylloc.last_line = yylloc.first_line = yylineno;
	return *yytext;
}

[a-z][a-z0-9]* { 
	yylloc.last_line = yylloc.first_line = yylineno;
	int len = strlen(yytext) + 1;
	yylval.iName = new char[len];
	strcpy(yylval.iName , yytext);
	yylval.iName[len] = '\0';
	return VARNAME; /*also_the_name_of_function,hulinet*/
}

[ \t]+ ; /*whitespace*/

. {
	yylloc.last_line = yylloc.first_line = yylineno;
	lexerror("Invalid character", *yytext, yylineno);
	return *yytext;
}

\/\/ BEGIN(COMMENT1);

\/\* BEGIN(COMMENT2);
}

<COMMENT1>{
[;\n]	{ BEGIN(INITIAL); yylloc.last_line = yylloc.first_line = yylineno; return ENDLINE;}
. ;
}

<COMMENT2>{
\*\/	{ BEGIN(INITIAL); }
.|\n ;
}

%%

void lexerror(const char *s, char c, int l)
{
	std::cerr << "LEXICAL ERROR: " << s << " '" << c << "'"<< " at line " << l << std::endl;
	errorFlag = true;
}
