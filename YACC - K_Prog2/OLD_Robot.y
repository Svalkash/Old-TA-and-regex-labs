%{
#include <cstdio>
#include <cstdarg>
#include <cstring>
#include <map>
#include <vector>
#include "Robot.h"

std::ofstream flog;

int line = 0;
bool errorFlag = false;

extern FILE * yyin; /*file from flex*/
extern bool winFlag;

int yylex();
void yyerror(const char* s);
%}

%union {
	int iValue; /*okay, here I can copy names*/
	bool iBool;
	char *iCell;
	char* iName;
	nodeType *nPtr;
};

%token <iBool> BOOL
%token <iValue> INTEGER
%token <iName> VARIABLE
%token <iCell>  CELL
%token IF FROM TO STEP GO PICK DROP LOOK DO FUNCTION LEFT RIGHT UP DOWN ENDLINE WHILE PRINT PRINTS

%nonassoc END
%right '['
%left ',' ']'
%left '|'
%left '&'
%left '+' '-'
%nonassoc UMINUS
%left IN LS
%nonassoc AS AIN SIN ALS SLS
%left '(' ')'
%left ENDLINE

%destructor {delete $$;} VARIABLE CELL function_list varName varInd varIndBr stmt stmt_list expr

%type <nPtr> program function_list function varName varInd varIndBr stmt stmt_list expr   /*TODO:DEFINE ALL NON-TERMINALS*/

/*
NON-TERMS:

varInd - name[ or name[var(ind) or name[ind,ind
	just VAR will be used in other cases...
varIndBr - varInd with ]
stmt - any statement ...; WITHOUT ;
	all functions are INCLUDED in expr, no need to put them into stmt
funcDecl: DON'T NEED IT. 
*/

/*
TODO:
VARnode+VARnode - work later
*/

%%

program:
		function_list	{
			/* included "function"s work*/
			if (errorFlag)
				std::cerr << "Errors found, compilation terminated." << std::endl;
			else
			{
				nodeType *m = findFunc("main");
				if (!m)
					std::cerr << "Cannot find MAIN, compilation terminated." << std::endl;
				else
				{
					std::cout << "COMPILATION SUCCESSFUL" << std::endl;
					std::cout << std::endl << "________________________________________________________________________________"<< std::endl;
					/*errorFlag == 0*/
					try
					{
						ex(m, 0);
						std::cout << std::endl << "________________________________________________________________________________"<< std::endl;
					}
					catch(std::runtime_error &ex)
					{
						errorFlag = true;
						std::cout << std::endl << "________________________________________________________________________________"<< std::endl;
						std::cerr << "RUNTIME ERROR: " << ex.what() << std::endl;
					}
				}
			}
		}
	|	error			{
			line = @1.first_line;
			errorFlag = true;
			}
	;

function_list:
		ENDLINE								{ line = @1.first_line; $$ = nullptr; }
	|	function							{ line = @1.first_line; $$ = nullptr; }
	|	function_list ENDLINE function		{ line = @1.first_line; $$ = nullptr; }
	|	function_list ENDLINE				{ line = @1.first_line; $$ = nullptr; }
	|	function_list function				{ line = @1.first_line; yyerror("';' or '\\n' needed"); yyerrok; $$ = nullptr; }
	;

function:
		FUNCTION '[' VARIABLE ']' stmt_list END							{ line = @1.first_line; funcDef($3, $5); $$ = nullptr;}
	|	FUNCTION '[' VARIABLE stmt_list END								{ line = @1.first_line; yyerror("Missed ']'"); yyerrok;}
	|	FUNCTION VARIABLE ']' stmt_list END								{ line = @1.first_line; yyerror("Missed '['"); yyerrok;}
	|	FUNCTION VARIABLE stmt_list END									{ line = @1.first_line; yyerror("Missed '[ ]'"); yyerrok;}
	|	FUNCTION '[' ']' stmt_list END									{ line = @1.first_line; yyerror("Missed name"); yyerrok;}
	|	FUNCTION stmt_list END											{ line = @1.first_line; yyerror("Missed \"[name]\""); yyerrok;}
	|	FUNCTION error END												{ line = @1.first_line; yyerror("In function"); yyerrok;}
	;

varName:
		VARIABLE							{ line = @1.first_line; $$ = varNode($1);}
	|	DO VARIABLE							{ line = @1.first_line; $$ = opNode(DO, 1, varNode($2));}
	|	DO INTEGER							{ line = @1.first_line; yyerror("Wrong format of function name"); yyerrok;} 
	|	DO BOOL 							{ line = @1.first_line; yyerror("Wrong format of function name"); yyerrok;} 
	|	DO CELL								{ line = @1.first_line; yyerror("Wrong format of function name"); yyerrok;} 
	|	DO FUNCTION stmt_list END			{ line = @1.first_line; $$ = opNode(DO, 1, $3);}  
	|	LOOK UP								{ line = @1.first_line; $$ = opNode(LOOK, 1, intNode(0));}
	|	LOOK LEFT							{ line = @1.first_line; $$ = opNode(LOOK, 1, intNode(1));}
	|	LOOK DOWN							{ line = @1.first_line; $$ = opNode(LOOK, 1, intNode(2));}
	|	LOOK RIGHT							{ line = @1.first_line; $$ = opNode(LOOK, 1, intNode(3));}
	;

varInd:
		varName '[' expr		{ line = @1.first_line; $$ = opNode('[', 2, $1, $3);}
	|	varName '[' ']'		{ line = @2.first_line; yyerror("Missed index"); yyerrok;}
	|	varInd  ',' expr		{ line = @2.first_line; $$ = opNode(',', 2, $1, $3);}
	;

varIndBr:
		varInd  ']'		{ line = @2.first_line; $$ = opNode(']', 1, $1);}           
	;

stmt:
        expr															{ line = @1.first_line; $$ = $1; /*functions-in-expr come here*/}
    |	varName AS expr													{ line = @1.first_line; $$ = opNode(AS, 2, $1, $3); }
	|	varIndBr AS expr												{ line = @1.first_line; $$ = opNode(AS, 2, $1, $3); }
	|	INTEGER AS expr													{ line = @1.first_line; yyerror("You can`t change constant"); yyerrok;}
	|	BOOL AS expr													{ line = @1.first_line; yyerror("You can`t change constant"); yyerrok;}
	|	CELL AS expr													{ line = @1.first_line; yyerror("You can`t change constant"); yyerrok;}
    |	FROM expr TO expr STEP expr DO VARIABLE							{ line = @1.first_line; $$ = opNode(FROM, 4, $2, $4, $6, varNode($8)); }
    |	FROM TO expr STEP expr DO VARIABLE								{ line = @1.first_line; yyerror("Missed FROM expression"); yyerrok; }
    |	FROM expr TO STEP DO VARIABLE									{ line = @1.first_line; yyerror("Missed TO expression"); yyerrok; }
    |	FROM expr TO expr STEP DO VARIABLE								{ line = @1.first_line; yyerror("Missed STEP expression"); yyerrok; }
	|	FROM expr TO expr STEP expr DO FUNCTION stmt_list END			{ line = @1.first_line; $$ = opNode(FROM, 4, $2, $4, $6, $9); }
    |	FROM TO expr STEP expr DO FUNCTION stmt_list END				{ line = @1.first_line; yyerror("Missed FROM expression"); yyerrok; }
    |	FROM expr TO STEP DO FUNCTION stmt_list END						{ line = @1.first_line; yyerror("Missed TO expression"); yyerrok; }
    |	FROM expr TO expr STEP DO FUNCTION stmt_list END				{ line = @1.first_line; yyerror("Missed STEP expression"); yyerrok; }
    |	IF expr DO VARIABLE												{ line = @1.first_line; $$ = opNode(IF, 2, $2, varNode($4)); }		
	|	IF expr DO FUNCTION stmt_list END								{ line = @1.first_line; $$ = opNode(IF, 2, $2, $5); }	
    |	IF expr															{ line = @1.first_line; yyerror("Missing action"); yyerrok;}
    |	WHILE expr DO VARIABLE											{ line = @1.first_line; $$ = opNode(WHILE, 2, $2, varNode($4)); }		
	|	WHILE expr DO FUNCTION stmt_list END							{ line = @1.first_line; $$ = opNode(WHILE, 2, $2, $5); }
    |	WHILE expr														{ line = @1.first_line; yyerror("Missing action"); yyerrok;}
	|	function														{ line = @1.first_line; $$ = $1; }
	|	PRINT expr														{ line = @1.first_line; $$ = opNode(PRINT, 1, $2); }
	|	PRINTS VARIABLE													{ line = @1.first_line; $$ = opNode(PRINTS, 1, varNode($2));}
	;

stmt_list:
    	ENDLINE						{ line = @1.first_line; $$ = nullptr;}
    |	stmt ENDLINE				{ line = @1.first_line; $$ = opNode(';', 2, $1, nullptr); /*MUST BE ;*/ }
	|	stmt_list ENDLINE			{ line = @1.first_line; $$ = $1; }
    |	stmt_list stmt ENDLINE		{ line = @1.first_line; $$ = opNode(';', 2, $1, $2); }
	|	stmt_list error ENDLINE		{ line = @2.first_line; yyerror("In the statement list"); yyerrok;}
    ;
		 		
expr:
		INTEGER								{ line = @1.first_line; $$ = intNode($1);}
	|	BOOL								{ line = @1.first_line; $$ = boolNode($1);}
	|	CELL								{ line = @1.first_line; $$ = cellNode($1);}
	|	varName								{ line = @1.first_line; $$ = $1;}
	|	varIndBr							{ line = @1.first_line; $$ = $1;}
	|	'-' expr %prec UMINUS				{ line = @2.first_line; $$ = opNode(UMINUS, 1, $2);}
	|	expr '+' expr						{ line = @2.first_line; $$ = opNode('+', 2, $1, $3); }
	|	expr '-' expr						{ line = @2.first_line; $$ = opNode('-', 2, $1, $3);}
	|	expr '&' expr						{ line = @1.first_line; $$ = opNode('&', 2, $1, $3);}
	|	expr '|' expr						{ line = @1.first_line; $$ = opNode('|', 2, $1, $3);}
	|	expr IN varName						{ line = @1.first_line; $$ = opNode(IN, 2, $1, $3);}
	|	expr IN varIndBr					{ line = @1.first_line; $$ = opNode(IN, 2, $1, $3);}
	|	varName AIN varName					{ line = @1.first_line; $$ = opNode(AIN, 2, $1, $3);}
	|	varName SIN varName					{ line = @1.first_line; $$ = opNode(SIN, 2, $1, $3);}
	|	expr LS varName						{ line = @1.first_line; $$ = opNode(LS, 2, $1, $3);} 
	|	expr LS varIndBr					{ line = @1.first_line; $$ = opNode(LS, 2, $1, $3);} 
	|	varName SLS varName					{ line = @1.first_line; $$ = opNode(SLS, 2, $1, $3);}
	|	varName ALS varName					{ line = @1.first_line; $$ = opNode(ALS, 2, $1, $3);}
	|	'(' expr ')' 						{ line = @1.first_line; $$ = $2;}
	|	GO UP								{ line = @1.first_line; $$ = opNode(GO, 1, intNode(0));}
	|	GO LEFT								{ line = @1.first_line; $$ = opNode(GO, 1, intNode(1));}
	|	GO DOWN								{ line = @1.first_line; $$ = opNode(GO, 1, intNode(2));}
	|	GO RIGHT							{ line = @1.first_line; $$ = opNode(GO, 1, intNode(3));} 
	|	PICK UP								{ line = @1.first_line; $$ = opNode(PICK, 1, intNode(0));}
	|	PICK LEFT							{ line = @1.first_line; $$ = opNode(PICK, 1, intNode(1));}
	|	PICK DOWN							{ line = @1.first_line; $$ = opNode(PICK, 1, intNode(2));}
	|	PICK RIGHT							{ line = @1.first_line; $$ = opNode(PICK, 1, intNode(3));} 
	|	DROP UP								{ line = @1.first_line; $$ = opNode(DROP, 1, intNode(0));}
	|	DROP LEFT							{ line = @1.first_line; $$ = opNode(DROP, 1, intNode(1));}
	|	DROP DOWN							{ line = @1.first_line; $$ = opNode(DROP, 1, intNode(2));}
	|	DROP RIGHT							{ line = @1.first_line; $$ = opNode(DROP, 1, intNode(3));} 
	;

%%

void yyerror(const char *s)
{
	std::cerr << "COMPILATION ERROR: " << s << " at line " << line << std::endl;
	errorFlag = true;
}

int main(int argc, char *argv[]) {
	int rc = 0;
	if (argc < 3)
	{
		std::cerr << "No input file." << std::endl;
		rc = -1;
	}
	else if (argc > 3)
	{
		std::cerr << "Only 2 arguments are accepted." << std::endl;
		rc = -2;
	}
	else
	{
		yyin = fopen(argv[1], "r");
		if (!yyin)
		{
			std::cerr << "Cannot open file." << std::endl;
			rc = -3;
		}
		if (!loadLevel(argv[2]))
		{
			std::cerr << "Cannot load level." << std::endl;
			rc = -4;
		}
		flog.open("robot_log.txt");
    	yyparse();
		flog.close();
		if(!errorFlag)
			if(winFlag)
				{
					std::cout << "END: SUCCESS" << std::endl;
					rc = 1;
				}
			else
				{
					std::cout << "END: FAILURE" << std::endl;
					rc = 2;
				}
		else
			rc = 0;
    	fclose(yyin);
	}
}