%option noyywrap
%option c++
%x SERVER TAIL 
%{
#include <string>
#include "ServTable.h"
#include <iostream>
#include <fstream>

using namespace std;
using namespace stab;
ServTable servJournal;
fstream flog;
fstream fin;
const string logFile = "log.txt";
const string journalFile = "journal.txt";
%}
%% 
<INITIAL>{
    ^(?i:ftp\:\/\/)/.{1,64} BEGIN(SERVER);
    \n return 0;
    . ;
}
<SERVER>{
    (?i:[0-9a-z]{1,20}\.([0-9a-z]{1,20}\.)*[a-z]{1,5})$ {BEGIN(TAIL); servJournal.addserv(yytext); return 1; }
    . {BEGIN(INITIAL); return 0;}
    \n {BEGIN(INITIAL); return 0; }
}

<TAIL>{
    . ;
    \n BEGIN(INITIAL);
}
%%

int main()
{   
    flog.open(logFile,std::ios_base::out);
	fin.open("stringList.txt",std::ios_base::in);
    if(!flog || !fin){
        std::cout << "One of files can not be opened";
        return 1;
    }
	yyFlexLexer ftp;
	ftp.yyrestart(static_cast<std::istream&>(fin));
    while(fin.get() && !fin.eof())
    {
        fin.unget();
	    if(ftp.yylex()){
	        flog << "ACCEPTABLE" << std::endl;
        }
        else{
            flog << "INACCEPTABLE" << std::endl;
        }
    }
	flog.close();
	fin.close();
    servJournal.save(journalFile);
    return 0;
}
