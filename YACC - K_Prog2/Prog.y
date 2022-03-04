%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <map>
#include <vector>
#include <climits>
#include "Prog.h"

int line = 0;

extern FILE * yyin;
/* prototypes */
nodeType *cel(char * str);
nodeType  *opr(int oper, int nops, ...);
nodeType  *id(char *) ;
nodeType  *bol(bool value) ;
nodeType  *con(int value);
void             fun(char *name,nodeType *ptr);
void freeNode(nodeType *p);
ret ex(nodeType *p);
int yylex(void);
void init (void);


void yyerror(const char* s);
void yyerror(const char *, char, int l);
std::vector<NameSpace> NameSpaces; //SH: ...blyat
int SpaceNum = -1;
std::map<std::string,nodeType *> funTable;
int const memSize = 100000; //SH: I'm too stupid to understand it
std::vector<Var> memTable(memSize); //SH: I'm too stupid to understand it
std::vector<AdrConf> adrTable; //SH: I'm too stupid to understand it
const int FieldSize = 10;
int resSize = 3;
bool winFlag = false;
int field[FieldSize][FieldSize] = { {1,1,1,1,4,1,1,1,1,1},
                               					   			{1,1,1,1,1,1,1,1,1,1},
											   			    {1,1,3,3,3,3,3,3,3,1},
							  					 		    {1,1,3,3,3,3,3,3,3,1},
							 				     			{1,1,3,3,1,1,1,3,3,1},
											     		    {1,1,3,3,1,1,1,3,3,1},
							  					  		    {1,1,3,3,3,3,3,3,3,1},
							  					 		    {1,1,3,3,3,3,3,3,3,1},
							  					  		    {1,1,1,1,1,1,1,1,1,1},
											     		    {1,1,1,1,1,1,1,1,1,1} };
															
Cord Coord;
bool BoxFlag = false;
bool errorFlag = false;
%}



%union {
    bool iBool;               /*bool value*/
    int iValue;                 /* integer value */
	char *iCell;               /* cell value */
//Fuck it. I will make it Integer
    char* iName;                /* symbol table index */
    nodeType *nPtr;             /* node pointer */
};


%nonassoc END
%token <iBool> BOOL
%token <iValue> INTEGER
%token <iName> VARIABLE
%token <iCell>  CELL
%token IF WHILE FROM GO PICK DROP LOOK DO FUNCTION TO STEP LEFT RIGHT UP DOWN ENDLINE MAIN PRINT 


%left AS
%left '(' ')'
%left  '|'
%left '&'
%left '+' '-'
%nonassoc UMINUS
%nonassoc IN  AIN SIN LS  ALS  SLS  '['  ']' ','

%destructor {printf("call destructor for line %d\n", line); free($$);} VARIABLE
%destructor {printf("call destructor for line %d\n", line); free($$);} CELL

%type <nPtr> stmt vr expr stmt_list function  VRR

%%

program:
        MAIN function END                   { ex($2); freeNode($2);}
		| MAIN function                         { line = @2.first_line; printf("Missed <end> at the end of program\n"); errorFlag = true; yyerrok;}
		|MAIN error END                       { line = @2.first_line; yyerror("program error"); errorFlag = true; yyerrok; }
        ;
		
function:
                                                                  { init(); $$ = NULL;}
          |function stmt_list                     { line = @2.first_line;$$ = opr(';', 2, $1, $2);}
		  |function error ENDLINE        { line = @3.first_line; yyerror("function error"); errorFlag = true; yyerrok;  }
        ;

vr:
       VARIABLE  '[' INTEGER                                              { line = @1.first_line; $$ = opr('[',2,id($1),con($3));}
	   |VARIABLE  '[' VARIABLE                                          { line = @1.first_line; $$ = opr('[',2,id($1),id($3)); }
	   |VARIABLE  '[' ']'                                                         { line = @2.first_line; yyerror("Missed index"); errorFlag = true; yyerrok;}
	   |vr  ',' INTEGER                                                          { line = @2.first_line; $$ = opr(',',2,$1,con($3));}
	   |vr  ',' VARIABLE                                                         { line = @2.first_line; $$ = opr(',',2,$1,id($3)); }
	   ;
	   
VRR:
 		vr  ']'                                                                             { line = @2.first_line;$$ = opr(']' ,1,$1);}           
		;

stmt:
        expr 					                                                                                                       			  { line = @1.first_line; $$ = $1; }
        |VARIABLE AS expr 	                                                                                                       { line = @1.first_line; $$ = opr(AS, 2, id($1), $3); }
		|VRR AS expr 	                                                                                                        	     { line = @1.first_line; $$ = opr(AS, 2, $1, $3); }
		|INTEGER  AS expr                                                                                                           { line = @1.first_line; yyerror("You can`t change constant"); errorFlag = true; yyerrok;}
		|BOOL  AS expr                                                                                                                 { line = @1.first_line; yyerror("You can`t change constant"); errorFlag = true; yyerrok;}
		|CELL  AS expr                                                                                                                    { line = @1.first_line; yyerror("You can`t change constant"); errorFlag = true; yyerrok;}
        |FROM  expr  TO expr  '[' STEP expr ']' DO VARIABLE                                             { line = @1.first_line; $$ = opr(FROM, 4, $2, $4,$7,id($10)); }
		|FROM  expr  TO expr '[' STEP expr  DO VARIABLE                                                  { line = @1.first_line; yyerror("Missed ']'"); errorFlag = true; yyerrok;}
	    |FROM  expr  TO expr  STEP ']' expr  DO VARIABLE                                                 { line = @1.first_line; yyerror("Missed '['"); errorFlag = true; yyerrok;}
		|FROM  expr  TO expr '[' STEP expr ']' DO FUNCTION stmt_list END                  { line = @1.first_line; $$ = opr(FROM, 4, $2, $4,$7,$11); }
		|FROM  expr  TO expr '[' STEP expr  DO FUNCTION stmt_list END                     { line = @1.first_line; yyerror("Missed ']'"); errorFlag = true; yyerrok;}
		|FROM  expr  TO expr  STEP ']' expr  DO FUNCTION stmt_list END                    { line = @1.first_line; yyerror("Missed '['"); errorFlag = true; yyerrok;}
        |IF expr DO VARIABLE 							                                                                          { line = @1.first_line; $$ = opr(IF, 2, $2, id($4)); }		
		|IF  expr  DO  FUNCTION stmt_list END  								                                       { line = @1.first_line; $$ = opr(IF, 2, $2, $5); }		
		|IF expr 							                                                                                                     { line = @1.first_line; yyerror("Wrong format of <if>"); errorFlag = true; yyerrok;}	
	    |WHILE expr DO VARIABLE 							                                                                { line = @1.first_line; $$ = opr(WHILE, 2, $2, id($4));}		
		|WHILE expr  DO  FUNCTION stmt_list END  								                             { line = @1.first_line; $$ = opr(WHILE, 2, $2, $5); }		
		|FUNCTION '[' VARIABLE ']' stmt_list  END	                                                              { line = @1.first_line;fun($3,$5); $$ = NULL;}
		|FUNCTION '[' VARIABLE  stmt_list  END	                                                                  { line = @1.first_line; yyerror("Missed ']'"); errorFlag = true; yyerrok;}
		|FUNCTION  VARIABLE ']' stmt_list  END	                                                                  { line = @1.first_line; yyerror("Missed '['"); errorFlag = true; yyerrok;}
		|FUNCTION  VARIABLE  stmt_list  END	                                                                      { line = @1.first_line; yyerror("Missed '[ ]'"); errorFlag = true; yyerrok;}
		|FUNCTION '[' ']' stmt_list  END	                                                                                { line = @1.first_line; yyerror("Missed name"); errorFlag = true; yyerrok;}
		|FUNCTION  stmt_list  END	                                                                                         { line = @1.first_line; yyerror("Missed '[' name ']'"); errorFlag = true; yyerrok;}
		|PRINT expr          																									          { line = @1.first_line; $$ = opr(PRINT, 1, $2); }	
        ;
		

	
stmt_list:
           ENDLINE             							       { line = @1.first_line; $$ = NULL;}
        |stmt   ENDLINE                                  { line = @1.first_line; $$ = $1; }
		|stmt_list   ENDLINE                           { line = @1.first_line; $$ = $1; }
        | stmt_list stmt ENDLINE                  { line = @1.first_line; $$ = opr(';', 2, $1, $2); }
		|stmt                                                      { line = @1.first_line; yyerror("';' or '\\n' needed"); errorFlag = true; yyerrok;}
		|stmt_list stmt                                     { line = @2.first_line; yyerror("';' or '\\n' needed"); errorFlag = true; yyerrok;}
		|stmt_list error  ENDLINE                { line = @2.first_line; yyerror("stmt_list error"); errorFlag = true; yyerrok;  }
        ;
		 		
		
expr:
          INTEGER                                          		     { line = @1.first_line; $$ = con($1); }
		|CELL                                                  		     { line = @1.first_line;$$ = cel($1);}
        | VARIABLE                                       		    { line = @1.first_line; $$ = id($1); }
		| VRR                                                     		  { line = @1.first_line; $$ = $1;}
		| BOOL                                             		        { line = @1.first_line; $$ = bol($1); }
        | '(' '-' expr ')' %prec UMINUS    		        { line = @2.first_line; $$ = opr(UMINUS, 1, $3);}
        | expr '+' expr                                   			 { line = @2.first_line; $$ = opr('+', 2, $1, $3); }
		| expr '+' '+' expr                            			    { line = @2.first_line; yyerror("Missed argument"); errorFlag = true; yyerrok;  }
        | expr '-' expr                                    			  { line = @2.first_line; $$ = opr('-', 2, $1, $3);}
		| expr '-' '-' expr                              			  { line = @2.first_line; yyerror("Missed argument"); errorFlag = true; yyerrok;  }
		|expr '&' expr                                  		     { line = @1.first_line; $$ = opr('&', 2, $1, $3);}
		| expr '&' '&' expr                          			   { line = @2.first_line; yyerror("Missed argument");errorFlag = true; yyerrok;  }
	    |expr '|' expr                                     			  { line = @1.first_line; $$ = opr('|', 2, $1, $3);}
		| expr '|' '|' expr                               			 { line = @2.first_line; yyerror("Missed argument"); errorFlag = true; yyerrok;  }
		|expr IN VARIABLE                          		       { line = @1.first_line; $$ = opr(IN,2,$1,id($3));}
		|expr IN VRR                        		                 { line = @1.first_line; $$ = opr(IN,2,$1,$3);}
		| VARIABLE AIN VARIABLE                		    { line = @1.first_line; $$ = opr(AIN,2,id($1),id($3));}
		| VARIABLE SIN VARIABLE                 		{ line = @1.first_line; $$ = opr(SIN,2,id($1),id($3));}
		| expr LS VARIABLE                          		    { line = @1.first_line; $$ = opr(LS,2,$1,id($3));} 
		| expr LS VRR                        		                  { line = @1.first_line; $$ = opr(LS,2,$1,$3);} 
	    | VARIABLE SLS VARIABLE                 		 { line = @1.first_line; $$ = opr(SLS,2,id($1),id($3));}
		| VARIABLE ALS VARIABLE                 		 { line = @1.first_line; $$ = opr(ALS,2,id($1),id($3));}
        | '(' expr ')'                                          			{ line = @1.first_line; $$ = $2; }
		|DO VARIABLE    	                                       { line = @1.first_line;$$ = opr(DO,1,id($2));}
		|DO INTEGER 	                                		   { line = @1.first_line; yyerror("Wrong format of function name"); errorFlag = true; yyerrok;} 
		|DO BOOL 	                                                  { line = @1.first_line; yyerror("Wrong format of function name"); errorFlag = true; yyerrok;} 
		|DO CELL	                                                    { line = @1.first_line; yyerror("Wrong format of function name"); errorFlag = true; yyerrok;} 
	    |DO FUNCTION stmt_list END	                { line = @1.first_line; $$ = opr(DO,1,$3);}  
		|GO LEFT 	                                                     { line = @1.first_line; $$ = opr(GO, 1, con('1')); }
		|GO RIGHT	                                                  { line = @1.first_line;  $$ = opr(GO, 1, con('2')); }
		|GO UP 	                                                          { line = @1.first_line; $$ = opr(GO, 1, con('3')); }
		|GO DOWN 	                                                { line = @1.first_line; $$ = opr(GO, 1, con('4')); }
		|LOOK LEFT 	                                                  { line = @1.first_line; $$ = opr(LOOK, 1, con('1')); }
		|LOOK RIGHT 	                                           { line = @1.first_line; $$ = opr(LOOK, 1, con('2')); }
		|LOOK UP 	                                                   { line = @1.first_line; $$ = opr(LOOK, 1, con('3')); }
		|LOOK DOWN 	                                             { line = @1.first_line; $$ = opr(LOOK, 1, con('4')); }
		|PICK LEFT 	                                                    { line = @1.first_line; $$ = opr(PICK, 1, con('1')); }
		|PICK RIGHT	                                                 { line = @1.first_line; $$ = opr(PICK, 1, con('2')); }
		|PICK UP                                                         { line = @1.first_line; $$ = opr(PICK, 1, con('3')); }
		|PICK DOWN 	                                                { line = @1.first_line; $$ = opr(PICK, 1, con('4')); }
		|DROP LEFT 	                                                  { line = @1.first_line; $$ = opr(DROP, 1, con('1')); }
		|DROP RIGHT 	                                           { line = @1.first_line; $$ = opr(DROP, 1, con('2')); }
		|DROP UP 	                                                   { line = @1.first_line; $$ = opr(DROP, 1, con('3')); }
		|DROP DOWN 						                         { line = @1.first_line; $$ = opr(DROP, 1, con('4')); }		
        ;
		
%%


#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)

nodeType *con(int value) {
    nodeType *p;
    size_t nodeSize;

    /* allocate node */
    nodeSize = SIZEOF_NODETYPE + sizeof(conNodeType);
    if ((p = (nodeType*) malloc(nodeSize)) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeCon;
    p->con.value = value;

    return p;
}


nodeType *bol(bool value) {
    nodeType *p;
    size_t nodeSize;

    /* allocate node */
    nodeSize = SIZEOF_NODETYPE + sizeof(bolNodeType);
    if ((p = (nodeType*) malloc(nodeSize)) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeBol;
    p->bol.value = value;

    return p;
}

//SH: create func char*->name
nodeType *cel(char * str) {
    nodeType *p;
    size_t nodeSize;

    /* allocate node */
    nodeSize = SIZEOF_NODETYPE + sizeof(varNodeType); 
    if ((p = (nodeType*) malloc(nodeSize)) == NULL)
        yyerror("out of memory");
		
    /* copy information */
    p->type = typeCell;
	std::string s(str);
	if(s == "EMPTY")
         p->cel.value = 1; 
    if(s == "WALL")
         p->cel.value = 2; 
	if(s == "BOX")
         p->cel.value = 3; 
	if(s == "EXIT")
         p->cel.value = 4; 
	if(s == "UNDEF")
         p->cel.value = 0; 
		 
    return p;
}


nodeType *id(char * str) {
    nodeType *p;
    size_t nodeSize;

    /* allocate node */
    nodeSize = SIZEOF_NODETYPE + sizeof(varNodeType); 
    if ((p = (nodeType*) malloc(nodeSize)) == NULL)
        yyerror("out of memory");
    /* copy information */
    p->type = typeVar;
	std::string s(str);
    p->var.name = s;
	
    return p;
}


nodeType *opr(int oper, int nops, ...) {
    va_list ap;
    nodeType *p;
    size_t nodeSize;
    int i;

    /* allocate node */
    nodeSize = SIZEOF_NODETYPE + sizeof(oprNodeType) +
        (nops - 1) * sizeof(nodeType*);
    if ((p = (nodeType*) malloc(nodeSize)) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeOpr;
    p->opr.oper = oper;
    p->opr.nops = nops;
    va_start(ap, nops);
    for (i = 0; i < nops; i++)
        p->opr.op[i] = va_arg(ap, nodeType*);
    va_end(ap);
    return p;
}


void fun(char *name,nodeType *ptr) {
    /* copy information */
	std::string s(name);
	std::map<std::string, nodeType *> ::iterator it = funTable.find(s);
	if( it != funTable.end() ) {
			errorFlag = true;
			std::cout << "Multiply defenition of function '" << s << "'\n";
			return;
	}
	funTable.insert( std::pair<std::string,nodeType *>(s,ptr) );
    return;
}

void freeNode(nodeType *p) {
    int i;
    if (!p) return;
    if (p->type == typeOpr) {
        for (i = 0; i < p->opr.nops; i++)
            freeNode(p->opr.op[i]);
    }
    free (p);
}

void yyerror(const char* s) {
       fprintf(stderr, "%s at line %d\n", s, line);
}

void yyerror(const char *s, char C, int l) {
std::cerr <<  s << ' ' << C <<" at line "<<l<< std::endl;
}

void init (void)
{
	Var a;
	a.status = 0;
	a.value = 0;
	for( int i = 0; i < memSize; i++)
	    memTable[i] = a;
	AdrConf b;
	b.adr = resSize*2;
	b.size = memSize - resSize*2;
	adrTable.push_back(b);
	NameSpace c;
	VarConf v;
	v.adr = resSize;
	v.dim = 1;
	v.lim.push_back(resSize);
	c.name = "main";
	NameSpaces.push_back(c);
	SpaceNum++;
	for( int i = 0; i < resSize*2; i++)
			memTable[i].status = 3;
	NameSpaces[SpaceNum].varTable.insert(std::pair<std::string, VarConf>("res",v));
	return;
}


ret ex(nodeType *p) //I think there should be namespace (current)
{
    if (!p) {
		ret r;
		r.type = typeBol;
		r.value = 0;
		return r;
	}
	switch(p->type) {
	    case typeCon:       {ret r; r.type = p->type; r.value = p->con.value;  return r; }
		case typeBol:         { ret r; r.type = p->type; r.value =(int)p->bol.value; return r; }
		case typeCell:         { ret r; r.type = p->type; r.value =p->cel.value; return r; }
		case typeVar:       {
									ret r;
		 							std::map<std::string, VarConf>::iterator it;
									for( int k = 0; k < SpaceNum + 1; k++) {
											it = NameSpaces[k].varTable.find(p->var.name);
											if( it != NameSpaces[k].varTable.end() ) 
													break;
									}
									if( it == NameSpaces[SpaceNum].varTable.end()) {
									     r.value = 3000000000;
									     return r;
								    }
									it -> second.cur_dim = 0;
									int ind = it -> second.adr;
									if( it-> second.dim == 0) {
									     if( memTable[ind].status == 1)
										      r.type = typeCon;
										 if( memTable[ind].status == 2)
										      r.type = typeBol;
										 if( memTable[ind].status == 3)
										      r.type = typeCell;
									     r.value = memTable[ind].value;
									     return r;
									}
									}
		case typeOpr:
		    switch(p->opr.oper) {
				 case ';':    {
				 									ret r;
				 									ex(p->opr.op[0]); 
													r= ex(p->opr.op[1]);
													return r;
												}
				 case PRINT:  {	
				 									ret r;
													if( errorFlag ) {
														r.value = 0;
														r.type = typeBol;
														return r;
													}
													r = ex( p -> opr.op[0]);		 
													if( p -> opr.op[0] -> type == typeVar) {
													if( p -> opr.op[0] -> var.name == "Coordinate") {
															std::cout << "print: [" << Coord.y << "," << Coord.x << "]";
															r.value = 0;
															r.type = typeBol;
															return r;
													}		
													if( p -> opr.op[0] -> var.name == "endline") {
															std::cout << std::endl;
															r.value = 0;
															r.type = typeBol;
															return r;
													}															
													}
													if( r.value <= INT_MAX) {
													if( r.type == typeCon) {
															std::cout << r.value << "\t";
													}
													if( r.type == typeBol) {
													        if(r.value)
																std::cout << "true\t";
															else
																std::cout << "false\t";
													}
												   if( r.type == typeCell) {
															if( r. value == 0)
																std::cout << "UNDEF\t";
															if( r. value == 1)
																std::cout << "EMPTY\t";
															if( r. value == 2)
																std::cout << "WALL\t";
															if( r. value == 3)
																std::cout << "BOX\t";
															if( r. value == 4)
																std::cout << "EXIT\t";
													}
													}
													return r;
				 						}
				 case IF:      {
				                         	 ret r;
											 ret cond = ex(p->opr.op[0]);
											 if( cond.value) {
				 									switch(p->opr.op[1]->type) {
													case typeVar: {	
															NameSpace a;
															a.name = p->opr.op[1]->var.name;
															std::map<std::string, nodeType *> ::iterator it = funTable.find(p->opr.op[1]->var.name);
															SpaceNum++;
															NameSpaces.resize(SpaceNum + 1);
															NameSpaces[SpaceNum] = a;
															r = ex(it -> second);
															SpaceNum--;
															return r;
													}
													case typeOpr: {
															NameSpace a;															
															a.name = "noname";
															SpaceNum++;
															NameSpaces.resize(SpaceNum + 1);
															NameSpaces[SpaceNum] = a;
															r = ex( p-> opr.op[1]);																			
															SpaceNum--;
															return r;
													
													}
					 						}
													
											}
											r.type = typeBol;
											r.value = 0;
											return r;
				  					}
				 case WHILE: {
				                         	 ret r;
											 ret cond = ex(p->opr.op[0]);
											 while( ex(p->opr.op[0]).value) {
				 									switch(p->opr.op[1]->type) {
													case typeVar: {	
															NameSpace a;
															a.name = p->opr.op[1]->var.name;
															std::map<std::string, nodeType *> ::iterator it = funTable.find(p->opr.op[1]->var.name);
															SpaceNum++;
															NameSpaces.resize(SpaceNum + 1);
															NameSpaces[SpaceNum] = a;
															r = ex(it -> second);
															SpaceNum--;
													}
													case typeOpr: {
															NameSpace a;															
															a.name = "noname";
															SpaceNum++;
															NameSpaces.resize(SpaceNum + 1);
															NameSpaces[SpaceNum] = a;
															r = ex( p-> opr.op[1]);																			
															SpaceNum--;
													
													}
					 						}													
											}
											r.type = typeBol;
											r.value = 0;
											return r;
				  					}
				 case FROM:      {
				 							 ret r;
				 							 ret init = ex(p->opr.op[0]);
				                             ret cond = ex(p->opr.op[1]);
											 ret step = ex(p->opr.op[2]);											
											 if( step.value == 0)
											 		printf("Runtime error");
											 else
											 		switch(p->opr.op[3]->type) {
													case typeVar: {	
															NameSpace a;
															a.name = p->opr.op[3]->var.name;
															std::map<std::string, nodeType *> ::iterator it = funTable.find(p->opr.op[3]->var.name);
															SpaceNum++;
															NameSpaces.resize(SpaceNum + 1);
															NameSpaces[SpaceNum] = a;
															for( int i = init.value; i < cond.value; i += step.value)
																	r = ex(it -> second);
															SpaceNum--;
															return r;
													}
													case typeOpr: {
															NameSpace a;
															a.name = "noname";
															SpaceNum++;
															NameSpaces.resize(SpaceNum + 1);
															NameSpaces[SpaceNum] = a;
															for( int i = init.value; i < cond.value; i += step.value)
																	 r = ex( p-> opr.op[3]);
															SpaceNum--;
															return r;
													
													}
					 						}
											r.type = typeBol;
											r.value = 0;
											return r;
				  					}
				 case '+':          {	
				 							ret p1, p2,p3;
											p1 = ex( p -> opr.op[0] );
											p2 = ex( p -> opr.op[1] );
				 							if( p -> opr.op[0] -> type == typeCell)
										    {													
													if( p1.value != 0)
														p1.value = 1;
											}
											if( p -> opr.op[1] -> type == typeCell)
										    {
													if( p2.value != 0)
														p2.value = 1;
											}
											p3.value = p1.value + p2.value;
											p3.type = typeCon;
											return p3;				 
				 							}
				  case '-':          {	
				 							ret p1, p2, p3;
											p1 = ex( p -> opr.op[0] );
											p2 = ex( p -> opr.op[1] );
				 							if( p -> opr.op[0] -> type == typeCell)
										    {
													if( p1.value != 0)
														p1.value = 1;
											}
											if( p -> opr.op[1] -> type == typeCell)
										    {
													if( p2.value != 0)
														p2.value = 1;
											}
											p3.value = p1.value - p2.value;
											p3.type = typeCon;
											return p3;				 
				 							}
				  case '&':          {	
				 							ret p1, p2, p3;
											p1 = ex( p -> opr.op[0] );
											p2 = ex( p -> opr.op[1] );
											if( p1.value != 0)
												p1.value = 1;
											if( p2.value != 0)
												p2.value = 1;
											p3.value = p1.value && p2.value;
											p3.type = typeBol;
											return p3;				 
				 							}
				  case '|':          {	
				 							ret p1, p2,p3;
											p1 = ex( p -> opr.op[0] );
											p2 = ex( p -> opr.op[1] );
				 							if( p -> opr.op[0] -> type == typeCell)
										    {
													if( p1.value != 0)
														p1.value = 1;
											}
											if( p -> opr.op[1] -> type == typeCell)
										    {
													if( p2.value != 0)
														p2.value = 1;
											}
											p3.value = p1.value || p2.value;
											p3.type = typeBol;
											return p3;				 
				 							}
				case UMINUS: {
														ret r;
														r = ex( p -> opr.op[0] );
														if( r.type == typeBol || r.type == typeCell) 
														     r.value = !r.value;
														if( r.type == typeCon)
															r.value = -r.value;
														return r;				
											}
				 case GO:          {
				 							ret r;
				 							ret val = ex(p->opr.op[0]);
											val.value -= 48;
				 							 if( val.value == 3)
				                             if(Coord.x - 1 >= 0 && Coord.x - 1 < FieldSize)
				 							    if(field[Coord.x-1][Coord.y] == 1 || field[Coord.x-1][Coord.y] == 4 || field[Coord.x-1][Coord.y] == 3) {
				 								    Coord.x--;
													r.type = typeBol;
													r.value = 1;
													if( field[Coord.x][Coord.y] == 4)
															winFlag = true;
				 									return r;
				 								}
				 								else {
													r.type = typeBol;
													r.value = 0;
				 									return r;
												}
										    else {
													r.type = typeBol;
													r.value = 0;
				 									return r;
											}
										if( val.value == 4)
				                             if(Coord.x + 1 >= 0 && Coord.x + 1 < FieldSize)
											    if(field[Coord.x+1][Coord.y] == 1 || field[Coord.x+1][Coord.y] == 4 || field[Coord.x+1][Coord.y] == 3) {
												    Coord.x++;
													r.type = typeBol;
													r.value = 1;
													if( field[Coord.x][Coord.y] == 4)
															winFlag = true;
				 									return r;
												}
												else {
													r.type = typeBol;
													r.value = 0;
				 									return r;
												}
										    else {
												r.type = typeBol;
													r.value = 0;
				 									return r;
											}
										if( val.value== 2)
				                             if(Coord.y + 1 >= 0 && Coord.y + 1 < FieldSize)
											    if(field[Coord.x][Coord.y+1] == 1 || field[Coord.x][Coord.y+1] == 4  || field[Coord.x][Coord.y+1] == 3) {
												    Coord.y++;
													r.type = typeBol;
													r.value = 1;
													if( field[Coord.x][Coord.y] == 4)
															winFlag = true;
				 									return r;
												}
												else {
													r.type = typeBol;
													r.value = 0;
				 									return r;
												}
										    else {
													r.type = typeBol;
													r.value = 0;
				 									return r;
											}
										if( val.value == 1)
				                             if(Coord.y - 1 >= 0 && Coord.y - 1 < FieldSize)
											    if(field[Coord.x][Coord.y-1] == 1 || field[Coord.x][Coord.y-1] == 4 || field[Coord.x][Coord.y-1] == 3 ) {
				 								    Coord.y--;
													r.type = typeBol;
													r.value = 1;
													if( field[Coord.x][Coord.y] == 4)
															winFlag = true;
				 									return r;
												}
												else {
													r.type =  typeBol;
													r.value = 0;
				 									return r;
												}
										    else {
													r.type = typeBol;
													r.value = 0;
				 									return r;
											}
											}
				 case PICK:     {
				 							ret r;
				 							 ret val = ex(p->opr.op[0]);
											 val.value -= 48;
				 							 if( val.value == 3)
				                             if(Coord.x - 1 >= 0 && Coord.x - 1 < FieldSize)
				 							    if(field[Coord.x-1][Coord.y] == 3) {
				 								    BoxFlag = true;
													field[Coord.x-1][Coord.y] = 1;
				 									r.type = typeBol;
													r.value = 1;
				 									return r;
				 								}
				 								else {
													r.type = typeBol;
													r.value = 0;
				 									return r;
												}
										    else {
												r.type = typeBol;
													r.value = 0;
				 									return r;
											}
										if( val.value == 4 )
				                             if(Coord.x + 1 >= 0 && Coord.x + 1 < FieldSize)
											    if(field[Coord.x+1][Coord.y] == 3) {
												    BoxFlag = true;
													field[Coord.x+1][Coord.y] = 1;
													r.type = typeBol;
													r.value = 1;
				 									return r;
												}
												else {
													r.type = typeBol;
													r.value = 0;
				 									return r;
												}
										    else {
													r.type = typeBol;
													r.value = 0;
				 									return r;
												}
										if( val.value == 1)
				                             if(Coord.y + 1 >= 0 && Coord.y + 1 < FieldSize)
											    if(field[Coord.x][Coord.y+1] == 3) {
												    BoxFlag = true;
													field[Coord.x][Coord.y+1] == 1;
													r.type = typeBol;
													r.value = 1;
				 									return r;
												}
												else {
													r.type = typeBol;
													r.value = 0;
				 									return r;
												}
										    else {
												r.type = typeBol;
													r.value = 0;
				 									return r;
												}
										if( val.value == 2)
				                             if(Coord.y - 1 >= 0 && Coord.y - 1 < FieldSize)
											    if(field[Coord.x][Coord.y-1] == 3) {
				 								    BoxFlag = true;
													field[Coord.x][Coord.y-1] == 1;
													r.type = typeBol;
													r.value = 1;
				 									return r;
												}
												else {
													r.type = typeBol;
													r.value = 0;
				 									return r;
												}
										    else {
													r.type = typeBol;
													r.value = 0;
				 									return r;
												}
											}
				case DROP:    {
											ret r;
											 ret val = ex(p->opr.op[0]);											 
											 val.value -= 48;
											 if( val.value == 3)
				                             if(Coord.x - 1 >= 0 && Coord.x - 1 < FieldSize)
				 							    if(field[Coord.x-1][Coord.y] == 1 && BoxFlag) {
				 								    BoxFlag = false;
													field[Coord.x-1][Coord.y] = 3;
				 									r.type = typeBol;
													r.value = 1;
				 									return r;
				 								}
				 								else {
													r.type = typeBol;
													r.value = 0;
				 									return r;
												}
										    else {
													r.type = typeBol;
													r.value = 0;
				 									return r;
											}
										if( val.value== 4)
				                             if(Coord.x + 1 >= 0 && Coord.x + 1 < FieldSize)
					     					    if(field[Coord.x+1][Coord.y] == 1 && BoxFlag) {
												    BoxFlag = false;
													field[Coord.x+1][Coord.y] = 3;
													r.type = typeBol;
													r.value = 1;
				 									return r;
												}
												else {
													r.type = typeBol;
													r.value = 0;
				 									return r;
												}
											else {
												r.type = typeBol;
													r.value = 0;
				 									return r;
											}
										if( val.value == 1)
				                             if(Coord.y + 1 >= 0 && Coord.y + 1 < FieldSize)
											    if(field[Coord.x][Coord.y+1] == 1 && BoxFlag) {
												    BoxFlag = false;
													field[Coord.x][Coord.y+1] == 3;
													r.type = typeBol;
													r.value = 1;
				 									return r;
												}
												else {
													r.type = typeBol;
													r.value = 0;
				 									return r;
												}
										    else {
												r.type = typeBol;
													r.value = 0;
				 									return r;
											}
										if( val.value == 2)
				                             if(Coord.y - 1 >= 0 && Coord.y - 1 < FieldSize)
											    if(field[Coord.x][Coord.y-1] == 1 && BoxFlag) {
				 								    BoxFlag = false;
													field[Coord.x][Coord.y-1] == 3;
													r.type = typeBol;
													r.value = 1;
				 									return r;
												}
												else {
													r.type = typeBol;
													r.value = 0;
				 									return r;
												}
										    else {
												r.type = typeBol;
													r.value = 0;
				 									return r;
											}
										}
				 case LOOK: {
				 							ret r;
				 							ret val = ex(p->opr.op[0]);											 
											 val.value -= 48;
											 std::map<std::string, VarConf>::iterator it;
											 for( int k = 0; k < SpaceNum + 1; k++) {
													it =  NameSpaces[k].varTable.find("res");
													if( it != NameSpaces[k].varTable.end() ) 
															break;
											}
										 if( val.value == 3) 
											 for( int i =0; i < resSize; i++) {
				                              	if(Coord.x - i >= 0 && Coord.x - i < FieldSize) 
													memTable[it -> second.adr +i].value = field[Coord.x - i][Coord.y];
												else 
													memTable[it -> second.adr+i].value = 0;
											memTable[it -> second.adr+i].status= 3;														
										}
										if( val.value== 4)
					     					    for( int i =0; i < resSize; i++) {
				                              	if(Coord.x +i >= 0 && Coord.x +i < FieldSize) 
													memTable[it -> second.adr+i].value = field[Coord.x + i][Coord.y];
												else 
													memTable[it -> second.adr+i].value = 0;
											memTable[it -> second.adr+i].status= 3;														
										}
										if( val.value == 1)
				                            for( int i =0; i < resSize; i++) {
				                              	if(Coord.y + i >= 0 && Coord.y + i < FieldSize) 
													memTable[it -> second.adr+i].value = field[Coord.x][Coord.y - i];
												else 
													memTable[it -> second.adr+i].value = 0;
											memTable[it -> second.adr+i].status= 3;														
										}
										if( val.value == 2)
				                             for( int i =0; i < resSize; i++) {
				                              	if(Coord.y - i >= 0 && Coord.y - i < FieldSize) 
													memTable[it -> second.adr+i].value = field[Coord.x][Coord.y + i];
												else 
													memTable[it -> second.adr+i].value = 0;
											memTable[it -> second.adr+i].status= 3;														
										}
				 
				 						r.type = typeBol;
										r.value = 1;
				 						return r;
				 						}
				 case IN:       {	
				 												ret r;
																switch(p->opr.op[1]->type) {
																		case typeVar: {
																			   std::map<std::string, VarConf>::iterator it;
																			   for( int k = 0; k < SpaceNum + 1; k++) {
																						it =  NameSpaces[k].varTable.find(p->opr.op[1]->var.name);
																						if( it != NameSpaces[k].varTable.end() ) 
																								break;
																			  }
																			  int flag = 0;
																			   if( it == NameSpaces[SpaceNum].varTable.end()) {
																					errorFlag = true;
																					 std::cout << "Undefined variable '" << p->opr.op[1]->var.name << "'\n";
																					  r.value = 3000000001;
																					 return r;
																			 }		
																			 int size = 2;
																			 for( int i = 0; i < it -> second.dim; i++) {
																					size = size * it -> second.lim[i];
																			 }
																			 ret val = ex(p->opr.op[0]);
																			 int i;
																			 if( it -> second.dim > 0)
																					 for( i = it -> second.adr - size/2 ; i < it -> second.adr + size/2; i++) {
																							if( val.value == memTable[i].value) {
																										flag = 1;
																										break;
																							}
																					 }
																			else {
																					if( val.value == memTable[it -> second.adr].value) {
																							flag = 1;			
																					}
																			}
																			 if( flag ) {
																					r.type = typeBol;
																					r.value = 1;
																					return r;
																			 }
																			 else
																			 {
																					r.type = typeBol;
																					r.value = 0;
																					return r;																 
																			 }		
														}
														}
													case typeOpr: {
																r = ex( p -> opr.op[1] );
																ret val = ex(p->opr.op[0]);
																if ( val.value == r.value ) {
																				r.type = typeBol;
																				r.value = 1;
																				return r;
																 }
																 else {
																			 r.type = typeBol;
																				r.value = 0;
																				return r;
																 
																 }													
													
													}
				 
				 						}
				  case AIN:		{
				  													ret r;
																	int flag = 1;
										                          std::map<std::string, VarConf>::iterator it;
																  for( int k = 0; k < SpaceNum + 1; k++) {
																			it =  NameSpaces[k].varTable.find(p->opr.op[1]->var.name);
																			if( it != NameSpaces[k].varTable.end() ) 
																					break;
																  }
																   if( it == NameSpaces[SpaceNum].varTable.end()) {
																   		errorFlag = true;
																	     std::cout << "Undefined variable '" << p->opr.op[1]->var.name << "'\n";
									   									  r.value = 3000000001;
																	     return r;
								   								 }		
																 std::map<std::string, VarConf>::iterator it2;
																  for( int k = 0; k < SpaceNum + 1; k++) {
																			it2 =  NameSpaces[k].varTable.find(p->opr.op[0]->var.name);
																			if( it2 != NameSpaces[k].varTable.end() ) 
																					break;
																  }
																   if( it2 == NameSpaces[SpaceNum].varTable.end()) {
																   		errorFlag = true;
																	     std::cout << "Undefined variable '" << p->opr.op[1]->var.name << "'\n";
									   									  r.value = 3000000001;
																	     return r;
								   								 }	
																 int size = 2;
																 for( int i = 0; i < it -> second.dim; i++) {
																		size = size * it -> second.lim[i];
																 }
																 int size2 = 2;
																 for( int i = 0; i < it2 -> second.dim; i++) {
																		size2 = size2 * it2 -> second.lim[i];
																 }
																 int i, j;
																  if( it -> second.dim > 0 && it2 -> second.dim > 0)   {
																 for( j = it2 -> second.adr - size2/2; j < it2->second.adr + size2/2; j++) {
																 		int fl = 0;
																		 for( i = it -> second.adr - size/2 ; i < it -> second.adr + size/2; i++) {
																 		if( memTable[j].value == memTable[i].value) {
																					fl = 1;
																					break;																					
																		 }
																		 }
																		 if( !fl ) {
																		 	flag = 0;
																			break;
																		}
																 }
																 }
																 if( it -> second.dim > 0 && it2 -> second.dim == 0) {
																 		int fl = 0;
																 		for( i = it -> second.adr - size/2 ; i < it -> second.adr + size/2; i++) {
																 		if( memTable[ it2 -> second.adr ].value == memTable[i].value) {
																					fl = 1;
																					break;																					
																		 }
																		 }
																		 if( !fl )
																		 	flag = 0;
																 }
																 if( it -> second.dim == 0 && it2 -> second.dim > 0) 
																 		flag = 0;
																 if( it -> second.dim == 0 && it2 -> second.dim == 0) 
																 {
																 		if( memTable[ it2-> second.adr].value != memTable[ it -> second.adr].value) {
																				flag = 0;				
																		}
																 }
																 if( !flag) {
																 		r.type = typeBol;
																 		r.value = 0;
																		return r;		
																 }
																 else {
																 r.type = typeBol;
																 r.value = 1;
																 return r;		
																 }
				  
				  						}
										
				  case SIN:    {
				  												  ret r;
																  int flag = 0;
										                          std::map<std::string, VarConf>::iterator it ;
																  for( int k = 0; k < SpaceNum + 1; k++) {
																			it =  NameSpaces[k].varTable.find(p->opr.op[1]->var.name);
																			if( it != NameSpaces[k].varTable.end() ) 
																					break;
																  }
																   if( it == NameSpaces[SpaceNum].varTable.end()) {
																   		errorFlag = true;
																	     std::cout << "Undefined variable '" << p->opr.op[1]->var.name << "'\n";
									   									  r.value = 3000000001;
																	     return r;
								   								 }		
																 std::map<std::string, VarConf>::iterator it2;
																  for( int k = 0; k < SpaceNum + 1; k++) {
																			it2 =  NameSpaces[k].varTable.find(p->opr.op[0]->var.name);
																			if( it2 != NameSpaces[k].varTable.end() ) 
																					break;
																  }
																   if( it2 == NameSpaces[SpaceNum].varTable.end()) {
																   		errorFlag = true;
																	     std::cout << "Undefined variable '" << p->opr.op[1]->var.name << "'\n";
									   									  r.value = 3000000001;
																	     return r;
								   								 }	
																 int size = 2;
																 for( int i = 0; i < it -> second.dim; i++) {
																		size = size * it -> second.lim[i];
																 }
																 int size2 = 2;
																 for( int i = 0; i < it2 -> second.dim; i++) {
																		size2 = size2 * it2 -> second.lim[i];
																 }
																 int i, j;
																  if( it -> second.dim > 0 && it2 -> second.dim > 0) {
																 for( j = it2 -> second.adr - size2/2; j < it2->second.adr + size2/2; j++) {
																		 for( i = it -> second.adr - size/2 ; i < it -> second.adr + size/2; i++) {
																 		if( memTable[j].value == memTable[i].value) {
																					flag = 1;
																					break;
																		}
																		 }
																		 if( flag)
																			break;
																}
																}
																 if( it -> second.dim > 0 && it2 -> second.dim == 0) {
																 		for( i = it -> second.adr - size/2 ; i < it -> second.adr + size/2; i++) {
																 		if( memTable[ it2 -> second.adr ].value == memTable[i].value) {
																					flag = 1;
																					break;
																		}
																 }
																 }
																  if( it -> second.dim == 0 && it2 -> second.dim > 0) {
																  	for( j = it2 -> second.adr - size2/2; j < it2->second.adr + size2/2; j++) {
																 		if( memTable[j].value == memTable[ it -> second.adr].value) {
																					flag = 1;
																					break;
																		}
																  }
																  }
																 if( it -> second.dim == 0 && it2 -> second.dim == 0) 
																 {
																 		if( memTable[ it2 -> second.adr].value == memTable[ it -> second.adr].value) 
																				flag = 1;																				
																 }
																 if( flag) {
																 		 r.type = typeBol;
																		 r.value = 1;
																		 return r;
																 }
																 else {
																 r.type = typeBol;
																 r.value = 0;
																 return r;			  
																 }
				  						}
				  case LS:      {
				  												  ret r;
																switch(p->opr.op[1]->type) {
																	case typeVar: {
																					  int flag = 1;
																					  std::map<std::string, VarConf>::iterator it;
																					  for( int k = 0; k < SpaceNum + 1; k++) {
																								it =  NameSpaces[k].varTable.find(p->opr.op[1]->var.name);
																								if( it != NameSpaces[k].varTable.end() ) 
																										break;
																					  }
																					   if( it == NameSpaces[SpaceNum].varTable.end()) {
																							errorFlag = true;
																							 std::cout << "Undefined variable '" << p->opr.op[1]->var.name << "'\n";
																							  r.value = 3000000001;
																							 return r;
																					 }		
																					 int size = 2;
																					 for( int i = 0; i < it -> second.dim; i++) {
																							size = size * it -> second.lim[i];
																					 }
																					 ret val = ex(p->opr.op[0]);
																					 int i;
																					 if( it -> second.dim > 0) {
																					 for( i = it -> second.adr - size/2 ; i < it -> second.adr + size/2; i++) {
																							if( val.value >=  memTable[i].value) {
																										flag = 0;
																										break;
																							}
																					 }
																					 }
																					 else {
																							if( val.value >= memTable[ it -> second.adr].value )
																								flag = 0;
																					 } 
																					 if( !flag ) {
																							r.type = typeBol;
																							r.value = 0;
																							return r;
																					 }
																					 else
																					 {
																							r.type = typeBol;
																							r.value = 1;
																							return r;																 
																					 }	
																}
															case typeOpr: {
																		r = ex( p -> opr.op[1] );
																		ret val = ex(p->opr.op[0]);
																		if ( val.value < r.value ) {
																						r.type = typeBol;
																						r.value = 1;																						
																						return r;
																		 }
																		 else {
																					 r.type = typeBol;
																						r.value = 0;																						
																						return r;

																		 }		

															}
													}



				  
				  						}
				  case ALS:    {
				  												  ret r;
																  int flag = 1;
										                          std::map<std::string, VarConf>::iterator it ;
																  for( int k = 0; k < SpaceNum + 1; k++) {
																			it =  NameSpaces[k].varTable.find(p->opr.op[1]->var.name);
																			if( it != NameSpaces[k].varTable.end() ) 
																					break;
																  }
																   if( it == NameSpaces[SpaceNum].varTable.end()) {
																   		errorFlag = true;
																	     std::cout << "Undefined variable '" << p->opr.op[1]->var.name << "'\n";
									   									  r.value = 3000000001;
																	     return r;
								   								 }		
																 std::map<std::string, VarConf>::iterator it2;
																  for( int k = 0; k < SpaceNum + 1; k++) {
																			it2 =  NameSpaces[k].varTable.find(p->opr.op[0]->var.name);
																			if( it2 != NameSpaces[k].varTable.end() ) 
																					break;
																  }
																   if( it2 == NameSpaces[SpaceNum].varTable.end()) {
																   		errorFlag = true;
																	     std::cout << "Undefined variable '" << p->opr.op[1]->var.name << "'\n";
									   									  r.value = 3000000001;
																	     return r;
								   								 }	
																 int size = 2;
																 for( int i = 0; i < it -> second.dim; i++) {
																		size = size * it -> second.lim[i];
																 }
																 int size2 = 2;
																 for( int i = 0; i < it2 -> second.dim; i++) {
																		size2 = size2 * it2 -> second.lim[i];
																 }
																 ret val = ex(p->opr.op[0]);
																 int i, j;
																 if( it -> second.dim > 0 && it2 -> second.dim > 0) {
																 for( j = it2 -> second.adr - size2/2; j < it2->second.adr + size2/2; j++) {
																		 for( i = it -> second.adr - size/2 ; i < it -> second.adr + size/2; i++) {
																 		if( memTable[j].value >= memTable[i].value) {
																					flag = 0;
																					break;
																		}
																		 }
																		 if( !flag)
																			break;
																 }
																 }
																 if( it -> second.dim > 0 && it2 -> second.dim == 0) {
																 		for( i = it -> second.adr - size/2 ; i < it -> second.adr + size/2; i++) {
																 		if( memTable[ it2 -> second.adr ].value >= memTable[i].value) {
																					flag = 0;
																					break;
																		}
																		 }
																 }
																  if( it -> second.dim == 0 && it2 -> second.dim > 0) {
																  		 for( j = it2 -> second.adr - size2/2; j < it2->second.adr + size2/2; j++) {
																 		if( memTable[j].value >= memTable[ it -> second.adr].value) {
																					flag = 0;
																					break;
																		}
																		 }
																  }
																 if( it -> second.dim == 0 && it2 -> second.dim == 0) 
																 {
																 		if( memTable[it2 -> second.adr ].value >= memTable[it -> second.adr ].value )
																			flag = 0;
																 }
																 if( !flag) {
																 		r.type = typeBol;
																		 r.value = 0;
																 		return r;	
																 }
																 else {
																 r.type = typeBol;
																 r.value = 1;
																 return r;		
																 }
				  
				  
				  						}
				 case SLS: 	   {
				 												  ret r;
																  int flag = 0;
										                          std::map<std::string, VarConf>::iterator it;
																   for( int k = 0; k < SpaceNum + 1; k++) {
																			it =  NameSpaces[k].varTable.find(p->opr.op[1]->var.name);
																			if( it != NameSpaces[k].varTable.end() ) 
																					break;
																  }
																   if( it == NameSpaces[SpaceNum].varTable.end()) {
																   		errorFlag = true;
																	     std::cout << "Undefined variable '" << p->opr.op[1]->var.name << "'\n";
									   									  r.value = 3000000001;
																	     return r;
								   								 }		
																 std::map<std::string, VarConf>::iterator it2;
																   for( int k = 0; k < SpaceNum + 1; k++) {
																			it2 =  NameSpaces[k].varTable.find(p->opr.op[0]->var.name);
																			if( it2 != NameSpaces[k].varTable.end() ) 
																					break;
																  }
																   if( it2 == NameSpaces[SpaceNum].varTable.end()) {
																   		errorFlag = true;
																	     std::cout << "Undefined variable '" << p->opr.op[1]->var.name << "'\n";
									   									  r.value = 3000000001;
																	     return r;
								   								 }	
																 int size = 2;
																 for( int i = 0; i < it -> second.dim; i++) {
																		size = size * it -> second.lim[i];
																 }
																 int size2 = 2;
																 for( int i = 0; i < it2 -> second.dim; i++) {
																		size2 = size2 * it2 -> second.lim[i];
																 }
																 ret val = ex(p->opr.op[0]);
																 int i, j;
																 if( it -> second.dim > 0 && it2 -> second.dim > 0) {
																 for( j = it2 -> second.adr - size2/2; j < it2->second.adr + size2/2; j++) {
																		 for( i = it -> second.adr - size/2 ; i < it -> second.adr + size/2; i++) {
																 		if( memTable[j].value < memTable[i].value) {
																		           flag = 1;
																					break;
																		 }
																		}
																		if( flag)
																			break;
																}
																}
																 if( it -> second.dim > 0 && it2 -> second.dim == 0) {
																 		 for( i = it -> second.adr - size/2 ; i < it -> second.adr + size/2; i++) {
																 		if( memTable[ it2 -> second.adr].value < memTable[i].value) {
																		           flag = 1;
																					break;
																		 }
																		}
																 }
																  if( it -> second.dim == 0 && it2 -> second.dim > 0) {
																  		for( j = it2 -> second.adr - size2/2; j < it2->second.adr + size2/2; j++)  {
																 		if( memTable[j].value < memTable[ it -> second.adr].value) {
																		           flag = 1;
																					break;
																		 }
																		}
																  }
																 if( it -> second.dim == 0 && it2 -> second.dim == 0) {
																		if( memTable[it2 -> second.adr].value < memTable[it -> second.adr].value) 
																			flag = 1;
																}
																 if( !flag) {
																 		r.type = typeBol;
																 		r.value = 0;
																		 return r;	
																 }
																 else {
																 r.type = typeBol;
																 r.value = 1;
																 return r;		
																 }
				  
				 
				 						}
				 case DO:     {	
				 							ret r;
				 							switch(p->opr.op[0]->type) {
													case typeVar: {	
															NameSpace a;
															a.name = p->opr.op[0]->var.name;
															std::map<std::string, nodeType *> ::iterator it = funTable.find(p->opr.op[0]->var.name);
															SpaceNum++;
															NameSpaces.resize(SpaceNum + 1);
															NameSpaces[SpaceNum] = a;
															r = ex(it -> second);
															SpaceNum--;
															return r;
													}
													case typeOpr: {
															NameSpace a;
															a.name = "noname";
															SpaceNum++;
															NameSpaces.resize(SpaceNum + 1);
															NameSpaces[SpaceNum] = a;
															r = ex( p-> opr.op[0]);
															SpaceNum--;
															return r;
													
													}
					 						}
										}
				case '[':           switch(p->opr.op[1]->type) {
				                          case typeVar:  {
										                          ret r;
										                          std::map<std::string, VarConf>::iterator it;
																   for( int k = 0; k < SpaceNum + 1; k++) {
																			it =  NameSpaces[k].varTable.find(p->opr.op[1]->var.name);
																			if( it != NameSpaces[k].varTable.end() ) 
																					break;
																  }
																   if( it == NameSpaces[SpaceNum].varTable.end()) {
																   		errorFlag = true;
																	     std::cout << "Undefined variable '" << p->opr.op[1]->var.name << "'\n";
									   									  r.value = 3000000001;
																	     return r;
								   								 }											
																  else {
																	 ret ind = ex(p->opr.op[1]);	
																	 if( ind.value >= INT_MAX) {
																	 		errorFlag = true;
																	       std::cout << "Any error of index '" << p->opr.op[0]->var.name << "'\n";
																	   	   r.value = 3000000001;
																	       return r;
																	 }
																	 if( ind.type != typeCon) {
																	 		errorFlag = true;
																	      std::cout << "Wrong type of index '" <<  p->opr.op[0]->var.name <<"'\n";
																	       r.type = typeBol;
																		   r.value = 3000000001;
																		   return r;
																     }
																	 std::map<std::string, VarConf>::iterator it2; 
																	  for( int k = 0; k < SpaceNum + 1; k++) {
																			it2 =  NameSpaces[k].varTable.find(p->opr.op[0]->var.name);
																			if( it2 != NameSpaces[k].varTable.end() ) 
																					break;
																  }
																	   if( it2 == NameSpaces[SpaceNum].varTable.end()) {
									   										  r.value = 3000000000;
																	   		  return r;
								   								     }
																	 it2 -> second.cur_dim = 1;
																	 it2 -> second.cur_lim.resize(it2 -> second.cur_dim);
																	 if( ind.value > 0)
																	        it2 -> second.cur_lim[it2 -> second.cur_dim - 1] = ind.value + 1;
																	else
																			it2 -> second.cur_lim[it2 -> second.cur_dim - 1] = -ind.value;
																	 if( it2 -> second.dim <  it2 -> second.cur_dim) {
																		  r.type = typeBol;
																		  r.value = 3000000000;
																		  return r;
																	 }
																	 if( it2 -> second.dim >= it2 -> second.cur_dim)
																	 {    
																	 			if( it2 -> second.cur_lim[it2 -> second.cur_dim - 1] > it2 -> second.lim[it2 -> second.cur_dim - 1] )
																				{
																						std::cout << p->opr.op[0]->var.name << std::endl;
																						std::cout << ind.value << std::endl;
																						std::cout << "Segmentation failed\n";
																						errorFlag = true;
																						r.value = 3000000001;
																						  r.type = typeBol;
																						 return r;
																				}
																      		     int offset = 1;
																				 for( int i = it2 -> second.cur_dim; i <  it2 -> second.dim; i++)
																	 			{
																	       			 offset *= it2 -> second.lim[i];
																				 }
																	    		r.type = typeBol;
																				r.value = ind.value*offset;
																	    	    return r;
																}
																  }
														}
										case typeCon:  {
																					ret r;
										        					      			std::map<std::string, VarConf>::iterator it2;
																					for( int k = 0; k < SpaceNum + 1; k++) {
																							it2 =  NameSpaces[k].varTable.find(p->opr.op[0]->var.name);
																							if( it2 != NameSpaces[k].varTable.end() ) 
																								break;
																					  }
																					  if( it2 == NameSpaces[SpaceNum].varTable.end()) {
									   														  r.value = 3000000000;
																						      return r;
								   													 }
																					ret ind = ex(p->opr.op[1]);
																					 it2 -> second.cur_dim = 1;
																					 it2 -> second.cur_lim.resize(it2 -> second.cur_dim);
																					if( ind.value > 0)
																	                 		it2 -> second.cur_lim[it2 -> second.cur_dim - 1] = ind.value + 1;
																					else
																							it2 -> second.cur_lim[it2 -> second.cur_dim - 1] = -ind.value;
																					 if( it2 -> second.dim <  it2 -> second.cur_dim) {
																						  r.type = typeBol;
																						  r.value = 3000000000;
																						  return r;
																					 }
																					 if( it2 -> second.dim >= it2 -> second.cur_dim)
																					 {    
																					 			if( it2 -> second.cur_lim[it2 -> second.cur_dim - 1] > it2 -> second.lim[it2 -> second.cur_dim - 1] )
																								{
																										std::cout << "Segmentation failed\n";
																										errorFlag = true;
																										r.value = 3000000001;
																										  r.type = typeBol;
																										 return r;
																								}
																      					     	int offset = 1;
																								 for( int i = it2 -> second.cur_dim; i <  it2 -> second.dim; i++)
																	 							{
																	       							 offset *= it2 -> second.lim[i];
																								 }
																								   r.type = typeBol;
																							  	  r.value = ind.value *offset;
																	    						 return r;
																				}
																	}
										}
				case ',':			  switch(p->opr.op[1]->type) {
				                          case typeVar:  {
										  						  ret r;
										                          std::map<std::string, VarConf>::iterator it;
																  for( int k = 0; k < SpaceNum + 1; k++) {
																							it = NameSpaces[k].varTable.find(p->opr.op[1]->var.name);
																							if( it != NameSpaces[k].varTable.end() ) 
																								break;
																	}
																  if( it == NameSpaces[SpaceNum].varTable.end()) {
																  		errorFlag = true;
																	     std::cout << "Undefined variable '"<< p->opr.op[1]->var.name<< "'\n";
									   									  r.value = 3000000001;
																	     return r;
								   								 }
																  else {
																  	  ret ind = ex(p->opr.op[1]);
																	  if( ind.value >= INT_MAX) {
																	  		errorFlag = true;
																	       std::cout << "Any error of index '"<< p->opr.op[0]->var.name << "'\n";
																	       r.type = typeBol;
																		   r.value = 3000000001;
																	       return r;
																	 }
																	 if( ind.type != typeCon) {
																	 		errorFlag = true;
																	       std::cout << "Wrong type of index '" << p->opr.op[0]->var.name << "'\n";
																	       r.type = typeBol; 
																		   r.value = 3000000001;
																		   return r;
																     }
																	nodeType *p1;
																	p1 = p;
																	while( p1->type != typeVar)
											    						 p1 = p1->opr.op[0];
																	  std::map<std::string, VarConf>::iterator it2;
																	 for( int k = 0; k < SpaceNum + 1; k++) {
																							it2 = NameSpaces[k].varTable.find(p1 -> var.name);
																							if( it2 != NameSpaces[k].varTable.end() ) 
																								break;
																	  }
																	  if( it2 == NameSpaces[SpaceNum].varTable.end()) {
									   									  r.value = 3000000000;
																	     return r;
								   								 }
																	 ret ind2 = ex(p->opr.op[0]);		
																	 if( ind2.value > INT_MAX && ind2.value != 3000000000) 
																	     return ind2;
																	 it2 -> second.cur_dim++;
																	 it2 -> second.cur_lim.resize(it2 -> second.cur_dim);
																	 if( ind.value > 0)
																	            it2 -> second.cur_lim[it2 -> second.cur_dim - 1] = ind.value + 1;
																	else
																				it2 -> second.cur_lim[it2 -> second.cur_dim - 1] = -ind.value;
																	 if( it2 -> second.dim <  it2 -> second.cur_dim) {
																		  r.type = typeBol;
																		  r.value = 3000000000;
																		  return r;
																	 }
																	 if( it2 -> second.dim >= it2 -> second.cur_dim)
																	 {    
																	 			if( it2 -> second.cur_lim[it2 -> second.cur_dim - 1] > it2 -> second.lim[it2 -> second.cur_dim - 1] )
																								{
																										std::cout << "Segmentation failed\n";
																										errorFlag = true;
																										r.value = 3000000001;
																										  r.type = typeBol;
																										 return r;
																								}
																      		     int offset = 1;
																				 for( int i = it2 -> second.cur_dim; i <  it2 -> second.dim; i++)
																	 			{
																	       			 offset *= it2 -> second.lim[i];
																				 }
																				 r.type = typeBol;
																				 r.value =ind2.value+ind.value *offset;
																				 return r;
																}
															  }
																  }
										case typeCon:  {
																					ret r;
										        					      			nodeType *p1;
																					p1 = p;
																					while( p1->type != typeVar)
											    										 p1 = p1->opr.op[0];
																					std::map<std::string, VarConf>::iterator it2;
																					for( int k = 0; k < SpaceNum + 1; k++) {
																							it2 =NameSpaces[k].varTable.find(p1 -> var.name);
																							if( it2 != NameSpaces[k].varTable.end() ) 
																								break;
																					  }
																					  if( it2 == NameSpaces[SpaceNum].varTable.end()) {
									   														  r.value = 3000000000;
																	    					  return r;
								   													 }
																	 				ret ind2 = ex(p->opr.op[0]);																					
																					if( ind2.value > INT_MAX && ind2.value != 3000000000) 
																	 					    return ind2;
																					ret ind = ex(p->opr.op[1]);
																					 it2 -> second.cur_dim++;
																					 it2 -> second.cur_lim.resize(it2 -> second.cur_dim);
																					 if( ind.value > 0)
																	                 		it2 -> second.cur_lim[it2 -> second.cur_dim - 1] = ind.value + 1;
																					else
																							it2 -> second.cur_lim[it2 -> second.cur_dim - 1] = -ind.value;
																					 if( it2 -> second.dim <  it2 -> second.cur_dim) {
																						  r.type = typeBol;
																						  r.value = 3000000000;
																						  return r;
																					 }
																					 if( it2 -> second.dim >= it2 -> second.cur_dim)
																					 {    
																					 			if( it2 -> second.cur_lim[it2 -> second.cur_dim - 1] > it2 -> second.lim[it2 -> second.cur_dim - 1] )
																								{
																										std::cout << "Segmentation failed\n";
																										errorFlag = true;
																										r.value = 3000000001;
																										  r.type = typeBol;
																										 return r;
																								}
																      					     	int offset = 1;
																								 for( int i = it2 -> second.cur_dim; i <  it2 -> second.dim; i++)
																	 							{
																	       							 offset *= it2 -> second.lim[i];
																								 }
																								 r.type = typeBol;
																								r.value = ind2.value+ind.value*offset;
																								return r;
																				}
																	}
										}
				case ']':        {
											ret r;
				                            nodeType *p1;
											p1 = p;											
											while( p1->type != typeVar)
											     p1 = p1->opr.op[0];
											  std::map<std::string, VarConf>::iterator it2;
											  for( int k = 0; k < SpaceNum + 1; k++) {
															it2 = NameSpaces[k].varTable.find(p1 -> var.name);
															if( it2 != NameSpaces[k].varTable.end() ) 
																		break;
											  }
											    if( it2 == NameSpaces[SpaceNum].varTable.end()) {
														errorFlag = true;
														 std::cout << "Undefined variable '" << p1 -> var.name  << "'"<< std::endl;
									   					 r.value = 3000000000;
											   		     return r;
											 }
				                              ret ind = ex(p->opr.op[0]);
											  if( ind.value <= INT_MAX && ind.value > memSize) {
											  		errorFlag = true;
											       printf("Out of memory");
												   return ind;
											  }
				                              if( ind.value > INT_MAX )
										         return ind;
										     else {
											    for( int i = 0; i < it2->second.cur_dim; i++) {
														if( it2 -> second.lim[i] < it2 -> second.cur_lim[i]) {
																errorFlag = true;
																std::cout << "Segmentation failed\n";
																r.type = typeBol;
																r.value = 3000000001;
																return r;
														}
												}
											 	if( it2 -> second.cur_dim <= it2 -> second.dim) {
											    if( memTable[it2 -> second.adr + ind.value].status == 1)
													r.type = typeCon;
												if( memTable[it2 -> second.adr + ind.value].status == 2)
													r.type = typeBol;
												if( memTable[it2 -> second.adr + ind.value].status == 3)
													r.type = typeCell;
											    r.value = memTable[it2 -> second.adr + ind.value].value;
												// std::cout << p1->var.name << " <= " << r.value << std:: endl;
												return r;
											}
											else {
													r.type = typeBol;
													r.value = 3000000000;
													return r;											
											}
											}
											
				                     }
			case AS:        {	
											ret val2 = ex(p->opr.op[1]);
											ret r;
											if( val2.value > INT_MAX)  {
											     r.type = typeBol;
												 r.value = 0;
												 return r;
											}
											if( p->opr.op[0] -> type == typeVar) { 
													if( p -> opr.op[1] -> type == typeVar){
															ret r;
															int i;
															int size = 2;
															std::map<std::string, VarConf>::iterator it1; 
															for( int k = 0; k < SpaceNum + 1; k++) {
																		it1 = NameSpaces[k].varTable.find(p->opr.op[0] -> var.name);
																		if( it1 != NameSpaces[k].varTable.end() ) 
																					break;
															 }
															std::map<std::string, VarConf>::iterator it2;
															for( int k = 0; k < SpaceNum + 1; k++) {
																		it2 = NameSpaces[k].varTable.find(p->opr.op[1] -> var.name);
																		if( it2 != NameSpaces[k].varTable.end() ) 
																					break;
															 }
														   if( it2 == NameSpaces[SpaceNum].varTable.end() )
														   {
														   					errorFlag = true;
														   					std::cout << "Undefined variable '" << p->opr.op[1]->var.name << "'\n";
														   					r.type = typeBol;
																			r.value = 0;
																			return r;
														   }
														   if( it1 == NameSpaces[SpaceNum].varTable.end() ) {
															 		VarConf b;
																	b.adr = -1;
																	b.dim = -1;
																	b.cur_dim = -1;
																	NameSpaces[SpaceNum].varTable.insert(std::pair<std::string, VarConf>(p->opr.op[0]->var.name ,b));
																	it1 = NameSpaces[0].varTable.find( p->opr.op[0]->var.name );
																	 if( it1 == NameSpaces[0].varTable.end() ) {
																			it1 = NameSpaces[SpaceNum].varTable.find( p->opr.op[0]->var.name );
											  	  					 }
																	 int size = 2;
																	 for( int i = 0; i < it2 -> second.dim; i++) 
																	 		size *= it2 -> second.lim[i];
																	std::vector<AdrConf>::iterator vect ;
																	for( vect = adrTable.begin(); vect < adrTable.end(); vect++) {
																			if( vect -> size >= size) {
																				    it1 -> second.adr = vect -> adr +size/2;
																					it1 -> second.dim = it2 -> second.dim;
																				    it1 -> second.lim = it2 -> second.lim;
																					vect -> adr += size;
																					vect -> size -= size;
																					break;																
																			}
																	}		
																	
														   }
															if( it1 -> second.dim == it2 -> second.dim) {
																	for( i = 0; i < it1 -> second.dim; i++) {
																		size *= it1 -> second.lim[i];
																		if( it1 -> second.lim[i] != it2 -> second.lim[i]) 
																		     break;
																	}
																	if( i == it1 -> second.dim) {
																			if( it1 -> second.dim > 0)
																					for( int x = it1 -> second.adr - size/2, y = it2->second.adr - size/2; x < it1 -> second.adr + size/2; x++, y++)
																							memTable[x] = memTable[y];		
																			if( it1 -> second.dim == 0)
																					memTable[it1 -> second.adr] = memTable[it2 -> second.adr];		
																	}
																	else {
																			errorFlag = true;
																			std::cout << "Different limits of the variables '"  << p->opr.op[0] -> var.name <<"' and '" << p->opr.op[1] -> var.name <<"'\n";
																			r.type = typeBol;
																			r.value = 0;
																			return r;
																	}
															
															}
															else {
																			errorFlag = true;
																			std::cout << "Different dimentions of the variables '"  << p->opr.op[0] -> var.name <<"' and '" << p->opr.op[1] -> var.name <<"'\n";
																			r.type = typeBol;
																			r.value = 0;
																			return r;
																	}
													
													
													}
													else {
													std::map<std::string, VarConf>::iterator it;
													for( int k = 0; k < SpaceNum + 1; k++) {
																		it = NameSpaces[k].varTable.find(p->opr.op[0] -> var.name);
																		if( it != NameSpaces[k].varTable.end() ) 
																					break;
															 }
													if( it  != NameSpaces[SpaceNum].varTable.end() ) {
													   if( memTable[it -> second.adr].status == 0) {
													         if( val2.type == typeCon)
															     memTable[it -> second.adr].status = 1;
														     if( val2.type == typeBol) 
															 	memTable[it -> second.adr].status = 2;
															if( val2.type == typeCell )
																memTable[it -> second.adr].status = 3;
													   }
													   if( memTable[it -> second.adr].status == 1) {
													         if( val2.type == typeCon)
															     memTable[it -> second.adr].value = val2.value;
														     if( val2.type == typeBol) 
															 	if( val2.value == 0 )
																	memTable[it -> second.adr].value = 0;
																else
																	memTable[it -> second.adr].value = 1;
															if( val2.type == typeCell )
																if( val2.value == 0 )
																	memTable[it -> second.adr].value = 0;
																else
																	memTable[it -> second.adr].value = 1;
													   }
													   if( memTable[it -> second.adr].status == 2) {
													         if( val2.type == typeCon)
															 	if( val2.value != 0)
															     	memTable[it -> second.adr].value = 1;
																else
																	memTable[it -> second.adr].value = 0;
														     if( val2.type == typeBol) 
															 	memTable[it -> second.adr].value = val2.value;
															if( val2.type == typeCell )
																if( val2.value == 0 )
																	memTable[it -> second.adr].value = 0;
																else
																	memTable[it -> second.adr].value = 1;
													   }
													    if( memTable[it -> second.adr].status == 3) {
													         if( val2.type == typeCon)
															 	if( val2.value == 0 )
																	memTable[it -> second.adr].value = val2.value;
																else {
																	errorFlag = true;
																     printf("Illigal convertation\n");
																}
														     if( val2.type == typeBol) 
															 	if( val2.value == 0 )
																	memTable[it -> second.adr].value = val2.value;
																else {
																	errorFlag = true;
															  	    printf("Illigal convertation\n");
																}
															if( val2.type == typeCell )
																memTable[it -> second.adr].value = val2.value;
													   }
														r.type = typeBol;
														r.value = 0;
														return r;
													}
												    else
													{
														VarConf a;
														a.adr = -1;
														a.dim = -1;
														a.cur_dim = -1;
														NameSpaces[SpaceNum].varTable.insert(std::pair<std::string, VarConf>(p->opr.op[0] -> var.name,a));
														std::map<std::string, VarConf>::iterator it;
														 for( int k = 0; k < SpaceNum + 1; k++) {
																		it = NameSpaces[k].varTable.find(p->opr.op[0] -> var.name);
																		if( it != NameSpaces[k].varTable.end() ) 
																					break;
															 }
														std::vector<AdrConf>::iterator vect ;
														for( vect = adrTable.begin(); vect < adrTable.end(); vect++) {
																if( vect -> size >= 1) {
																    it -> second.adr = vect -> adr;
																	it -> second.dim = 0;
																	vect -> adr ++;
																	vect -> size--;
																	break;																
																}
														}
														if( vect == adrTable.end() ) {
															errorFlag = true;
													          printf("Out of memory");
															  r.type = typeBol;
															  r.value = 0;
															  return r;
													 	}
													
														if( memTable[it -> second.adr].status == 0) {
													         if( val2.type == typeCon) {
															     memTable[it -> second.adr].status = 1;
															}
														     if( val2.type == typeBol) 
															 	memTable[it -> second.adr].status = 2;
															if( val2.type == typeCell )
																memTable[it -> second.adr].status = 3;
													   }
													   if( memTable[it -> second.adr].status == 1) {
													         if( val2.type == typeCon)
															     memTable[it -> second.adr].value = val2.value;
														     if( val2.type == typeBol) 
															 	if( val2.value == 0 )
																	memTable[it -> second.adr].value = 0;
																else
																	memTable[it -> second.adr].value = 1;
															if( val2.type == typeCell )
																if( val2.value == 0 )
																	memTable[it -> second.adr].value = 0;
																else
																	memTable[it -> second.adr].value = 1;
													   }
													   if( memTable[it -> second.adr].status == 2) {
													         if( val2.type == typeCon)
															 	if( val2.value != 0)
															     	memTable[it -> second.adr].value = 1;
																else
																	memTable[it -> second.adr].value = 0;
														     if( val2.type == typeBol) 
															 	memTable[it -> second.adr].value = val2.value;
															if( val2.type == typeCell )
																if( val2.value == 0 )
																	memTable[it -> second.adr].value = 0;
																else
																	memTable[it -> second.adr].value = 1;
													   }
													    if( memTable[it -> second.adr].status == 3) {
													         if( val2.type == typeCon)
															 	if( val2.value == 0 )
																	memTable[it -> second.adr].value = val2.value;
																else {
																	errorFlag = true;
															       printf("Illigal convertation\n");
																 }
														     if( val2.type == typeBol) 
															 	if( val2.value == 0 )
																	memTable[it -> second.adr].value = val2.value;
																else {
															     errorFlag = true;
															     printf("Illigal convertation\n");
															}
															if( val2.type == typeCell )
																memTable[it -> second.adr].value = val2.value;
													   }
													   //std::cout << p->opr.op[0] -> var.name << " = " <<  memTable[it -> second.adr].value << "("<< (int)memTable[it -> second.adr].status << "): " << it -> second.adr << std::endl; 
													   
														r.type = typeBol;
														r.value = 0;
														return r;
													 }		
													
													
													}
											}
											else  {
													nodeType *p1;
													p1 = p;
													ret r;													
													while( p1->type != typeVar) {
											  		   p1 = p1->opr.op[0];
													}
													  std::map<std::string, VarConf>::iterator it;
													  for( int k = 0; k < SpaceNum + 1; k++) {
																		it = NameSpaces[k].varTable.find(p1 -> var.name);
																		if( it != NameSpaces[k].varTable.end() ) 
																					break;
													}
													ret ind = ex(p -> opr.op[0] -> opr.op[0]);
													if( it -> second.cur_dim > it -> second.dim) {
															ind.value = 3000000000;
													}
													if( ind.value > INT_MAX && ind.value != 3000000000) {
													     r.type = typeBol;
														 r.value = 0;
														 return r;
													}
												    if( ind.value <= INT_MAX) {
															if( ind.value > memSize) {
																	errorFlag = true;
																	printf("Segmentation failed");
																	r.type = typeBol;
																	r.value = 0;
																	return r;
															}
															else {
													  					 if( memTable[it -> second.adr + ind.value].status == 0) {
													        					 if( val2.type == typeCon)
																				     memTable[it -> second.adr + ind.value].status = 1;
																			     if( val2.type == typeBol) 
																				 	memTable[it -> second.adr + ind.value].status = 2;
																				if( val2.type == typeCell )
																					memTable[it -> second.adr + ind.value].status = 3;
																		}
																	   if( memTable[it -> second.adr + ind.value].status == 1) {
																	         if( val2.type == typeCon)
																			     	memTable[it -> second.adr + ind.value].value = val2.value;
														 				    if( val2.type == typeBol) 
																				 	memTable[it -> second.adr + ind.value].value =(int) val2.value;
																			if( val2.type == typeCell )
																					if( val2.value == 0 )
																						memTable[it -> second.adr + ind.value].value = 0;
																					else
																						memTable[it -> second.adr + ind.value].value = 1;
													 				}
																   if( memTable[it -> second.adr + ind.value].status == 2) {
																         if( val2.type == typeCon)
																		 	if( val2.value != 0)
																		     	memTable[it -> second.adr + ind.value].value = 1;
																			else
																				memTable[it -> second.adr + ind.value].value = 0;
																	     if( val2.type == typeBol) 
																		 	memTable[it -> second.adr + ind.value].value =(int) val2.value;
																		if( val2.type == typeCell )
																			if( val2.value == 0 )
																				memTable[it -> second.adr + ind.value].value = 0;
																			else
																				memTable[it -> second.adr + ind.value].value = 1;
																  	 }
																    if( memTable[it -> second.adr + ind.value].status == 3) {
													 			        if( val2.type == typeCon)
																		 	if( val2.value == 0 )
																				memTable[it -> second.adr + ind.value].value =val2.value;
																			else {
																				errorFlag = true;
																		     	printf("Could not convert from 'int' to 'cell'");
																			}
																	     if( val2.type == typeBol) 
																		 	if( val2.value == 0 )
																				memTable[it -> second.adr + ind.value].value =val2.value;
																			else {
																				errorFlag = true;
																			     printf("Could not convert from 'bool' to 'cell'");
																			}
																		if( val2.type == typeCell )
																			memTable[it -> second.adr + ind.value].value =val2.value;
																   }
																	r.type = typeBol;
																	//std::cout << p1 -> var.name << " = " << memTable[it -> second.adr + ind.value].value << std::endl;
																	r.value = 0;
																	return r;																									
													}
													}
													if( ind.value == 3000000000) {
															 if( it == NameSpaces[SpaceNum].varTable.end() ) {
															 		VarConf b;
																	b.adr = -1;
																	b.dim = -1;
																	b.cur_dim = -1;
																	NameSpaces[SpaceNum].varTable.insert(std::pair<std::string, VarConf>(p1 -> var.name,b));
																	 for( int k = 0; k < SpaceNum + 1; k++) {
																				it = NameSpaces[k].varTable.find(p1 -> var.name);
																				if( it != NameSpaces[k].varTable.end() ) 
																						break;
																	}
																	ind = ex(p -> opr.op[0] -> opr.op[0]);
															}
															/*std::cout << "{\n";
															for( it = NameSpaces[SpaceNum].varTable.begin(); it != NameSpaces[SpaceNum].varTable.end(); it++ ) {
																	std::cout << it -> first << "\t";
																	std::cout << it -> second.dim << "\t";
																	std::cout << it -> second.cur_dim << std::endl;
															}
															std::cout << "}\n";*/
															  if( it -> second.cur_dim > it -> second.dim ) {
															  			for( int i =it -> second. cur_dim - 1,  j = it -> second.dim - 1; j>= 0; i--, j-- ) {
																					if( it -> second.lim[j] != it -> second.cur_lim[i] ) {
																								errorFlag = true;
																								std::cout << "Wrong expending of '" <<  p1 -> var.name <<"'\n";
																								r.type = typeBol;
																								r.value = 0;
																								return r;
																					}																		
																		}
																		int adr = it -> second.adr;
																		int old_dim = it -> second.dim;
																		std::vector<int> old_lim = it ->second.lim;
																		int size = 2;
																		for( int i = 0; i < it -> second.cur_dim; i++) {
																				size = size * it -> second.cur_lim[i];
																		}
																		std::vector<AdrConf>::iterator vect ;
																		for( vect = adrTable.begin(); vect < adrTable.end(); vect++) {
																				if( vect -> size >= size) {
																				    it -> second.adr = vect -> adr +size/2;
																					it -> second.dim = it -> second.cur_dim;
																					it -> second.lim = it -> second.cur_lim;
																					vect -> adr += size;
																					vect -> size -= size;
																					break;																
																				}
																		}
																		if( vect == adrTable.end() ) {
																				errorFlag = true;
																	          printf("Out of memory");
																			  r.type = typeBol;
																			  r.value = 0;
																		   	  return r;
																	 	}
																		if ( adr != -1 ) {
																		int old_size = 2;
																		for( int i = 0; i <  old_dim; i++)
																					old_size *= old_lim[i];
																		if( old_dim == 0) {
																		           memTable[it -> second.adr] = memTable[adr];
																					memTable[adr].status = 0;
																					memTable[adr].value = 0;
																		}
																		else
																		for( int i = adr - old_size/2, j = it -> second.adr - old_size/2; i < adr + old_size/2; i++, j++ ) {
																					memTable[j] = memTable[i];
																					memTable[i].status = 0;
																					memTable[i].value = 0;
																		}
												 						for( vect = adrTable.begin(); vect < adrTable.end(); vect++) {
												            				    if( adr - old_size/2 - 1  == vect->adr + vect-> size) {
																				      vect -> size += old_size;
																					  break;
																	            }
																				if( adr + old_size/2 == vect-> adr ) {
																				      vect -> size += old_size;
																					  vect ->adr = adr;
																					  break;
																				}
																		}
																		if( vect == adrTable.end())
																		{
																		           AdrConf a;
																				   a.adr = adr;
																				   a.size = old_size;
																		          adrTable.push_back(a);
																		}
																		std::vector<AdrConf>::iterator vect2;
																		for( vect = adrTable.begin(); vect < adrTable.end(); vect++) 
																		    for( vect2 = adrTable.begin(); vect2 < adrTable.end(); vect2++) {
																			     if( vect2 -> adr + vect2 -> size == vect->adr) {
																				      vect2 -> size += vect -> size;
																					  adrTable.erase(vect);
													         				   }
																				if( vect -> adr + vect -> size == vect2 ->adr ) {
																				       vect -> size += vect2 -> size;
																					  adrTable.erase(vect2);
																				}														
																		}
													       }
														   }
														   			 	 ind = ex(p -> opr.op[0] -> opr.op[0]);
													  					 if( memTable[it -> second.adr + ind.value].status == 0) {
													        					 if( val2.type == typeCon)
																				     memTable[it -> second.adr + ind.value].status = 1;
																			     if( val2.type == typeBol) 
																				 	memTable[it -> second.adr + ind.value].status = 2;
																				if( val2.type == typeCell )
																					memTable[it -> second.adr + ind.value].status = 3;
																		}
																	   if( memTable[it -> second.adr + ind.value].status == 1) {
																	         if( val2.type == typeCon)
																			     	memTable[it -> second.adr + ind.value].value = val2.value;
														 				    if( val2.type == typeBol) 
																				 	memTable[it -> second.adr + ind.value].value =(int) val2.value;
																			if( val2.type == typeCell )
																					if( val2.value == 0 )
																						memTable[it -> second.adr + ind.value].value = 0;
																					else
																						memTable[it -> second.adr + ind.value].value = 1;
													 				}
																   if( memTable[it -> second.adr + ind.value].status == 2) {
																         if( val2.type == typeCon)
																		 	if( val2.value != 0)
																		     	memTable[it -> second.adr + ind.value].value = 1;
																			else
																				memTable[it -> second.adr + ind.value].value = 0;
																	     if( val2.type == typeBol) 
																		 	memTable[it -> second.adr + ind.value].value =(int) val2.value;
																		if( val2.type == typeCell )
																			if( val2.value == 0 )
																				memTable[it -> second.adr + ind.value].value = 0;
																			else
																				memTable[it -> second.adr + ind.value].value = 1;
																  	 }
																    if( memTable[it -> second.adr + ind.value].status == 3) {
													 			        if( val2.type == typeCon)
																		 	if( val2.value == 0 )
																				memTable[it -> second.adr + ind.value].value =val2.value;
																			else
																		     printf("Could not convert from 'int' to 'cell'");
																	     if( val2.type == typeBol) 
																		 	if( val2.value == 0 )
																				memTable[it -> second.adr + ind.value].value =val2.value;
																			else {
																				errorFlag = true;
																			     printf("Could not convert from 'bool' to 'cell'");
																		}
																		if( val2.type == typeCell )
																			memTable[it -> second.adr + ind.value].value =val2.value;
																   }
																	r.type = typeBol;
																	/*int size = 2;
																		for( int i = 0; i < it -> second.dim; i++) {
																				size = size * it -> second.lim[i];
																		}
																	for( int i = it -> second.adr - size/2; i < it -> second.adr + size/2; i++) {
																			std::cout <<"status = " <<(int) memTable[i].status<<"\t value = "<<memTable[i].value << std::endl;
																	}*/
																	r.value = 0;
																	return r;														
															}	
													
																								
											
											}
			
			                        }
				
					}
													 
		   }

}



int main(void) {
	yyin = fopen ("./test3.txt", "r");
    yyparse();
	if( !errorFlag)
			if( winFlag)
					std::cout << "\nSuccess" << std::endl;
			else
					std::cout << "\nFailure" << std::endl;
    fclose (yyin);
    return 0;
}



