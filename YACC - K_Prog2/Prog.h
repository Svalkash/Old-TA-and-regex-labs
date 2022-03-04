#include<iostream>
#include<vector>
#include <map>

typedef enum { typeCon, typeVar, typeOpr, typeBol, typeCell, Undef } nodeEnum;



	

typedef struct{
	int adr;
	int size;
}AdrConf;

typedef struct{
	int adr;
	int dim;
	int cur_dim;
	std::vector<int> lim;
	std::vector<int> cur_lim;
}VarConf;

typedef struct{
	char status;
	int value;
}Var;

typedef struct{ 
	nodeEnum type;
	long long value;
}ret;

typedef struct{
	std::string name;
	std::map<std::string, VarConf> varTable;
}NameSpace;



typedef struct{
	int x = 5;
	int y = 5;
}Cord;

/* int constants */
typedef struct {
    int value;                  /* value of constant */
} conNodeType;


/* bool constants */
typedef struct {
    bool value;                  /* value of constant */
} bolNodeType;

/* identifiers */
typedef struct {
    std::string name;                     /* subscript to sym array */
} varNodeType;

/* cell constants */
typedef struct {
    int value;                  /* value of constant */
} cellNodeType;


/* operators */
typedef struct {
    int oper;                   /* operator */
    int nops;                   /* number of operands */
    struct nodeTypeTag *op[1];  /* operands (expandable) */
} oprNodeType;

typedef struct nodeTypeTag {
    nodeEnum type;              /* type of node */
    /* union must be last entry in nodeType */
    /* because operNodeType may dynamically increase */
    union {
        conNodeType con;         /* int constants */
		bolNodeType bol;           /* bool constants */
		cellNodeType cel;          /* cell constants */
        varNodeType var;          /* identifiers */
        oprNodeType opr;         /* operators */
    };
} nodeType;





/* Код ошибки  -  ошибка 
     3000000000;  -  не инициализированная переменная
	 3000000000;  -  под данную переменную не было выделено памяти
	 3  -  общие ошибки
	 
	 
	 			                     case FROM:     for(int i = ex(p->opr.op[0]); i < ex(p->opr.op[1]); i = i + ex(p->opr.op[2])) ex(p->opr.op[4]); return 0;
				 case IF:           if(ex(p->opr.op[0])) ex(p->opr.op[1]); return 0;
				 case '+':           return ex(p->opr.op[0]) + ex(p->opr.op[1]);
			     case '-':            return ex(p->opr.op[0]) - ex(p->opr.op[1]);
				 case '&':           return ex(p->opr.op[0]) && ex(p->opr.op[1]);
			     case '|':            return ex(p->opr.op[0]) || ex(p->opr.op[1]);
*/

/*
{ {1,1,1,1,1,1,2,1,2,1},
                               					   			{1,1,3,1,1,1,2,1,2,1},
											   			    {1,2,2,2,2,2,2,1,1,1},
							  					 		    {1,2,1,2,1,1,1,1,2,1},
							 				     			{1,2,1,2,1,1,2,1,2,1},
											     		    {1,2,1,2,1,1,2,1,2,1},
							  					  		    {1,2,1,1,1,1,2,1,2,1},
							  					 		    {1,2,1,3,1,1,2,3,2,1},
							  					  		    {1,2,1,2,1,1,2,1,2,1},
											     		    {1,1,1,2,1,1,2,1,2,4} };
															*/

/*


{ {1,1,1,1,1,1,1,1,1,1},
                               					   			{2,2,2,2,2,2,2,2,2,1},
											   			    {1,1,1,1,1,1,1,1,2,1},
							  					 		    {1,1,1,1,1,1,1,1,2,1},
							 				     			{1,1,1,1,1,1,1,1,2,1},
											     		    {1,1,1,1,1,1,1,1,2,1},
							  					  		    {1,1,1,1,1,1,1,1,2,1},
							  					 		    {1,1,1,1,1,1,1,1,2,1},
							  					  		    {1,1,1,1,1,1,1,1,2,1},
											     		    {1,1,1,1,1,1,1,1,2,4} };
*/

/*
{ {1,1,1,1,2,4,1,1,1,1},
                               					   			{2,1,2,1,1,1,1,1,2,1},
											   			    {1,1,2,2,2,2,2,2,1,1},
							  					 		    {1,2,2,1,1,1,1,3,1,2},
							 				     			{1,1,2,1,1,3,1,2,1,1},
											     		    {2,1,2,1,1,1,1,2,2,1},
							  					  		    {1,1,2,2,1,2,2,2,1,1},
							  					 		    {1,2,1,1,1,2,1,1,1,1},
							  					  		    {1,1,1,1,1,2,1,2,1,1},
											     		    {1,2,1,1,1,1,1,2,1,1} };
															
*/

															