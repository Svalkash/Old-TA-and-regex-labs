%option noyywrap
%option c++
%x SERVER TAIL 
%{
#include <iostream>
#include <string>
#include <cstdlib>
#include <map>
#include "head.h"
%}
%% 
<INITIAL>{
    ^(?i:gtalk\:(talk|chat)\?jid\=[a-zA-Z0-9]{1,}@) BEGIN(SERVER);
    \n return 0;
    . ;
}
<SERVER>{
    (?i:[a-zA-Z0-9]{1,}\.[a-z]{1,4})$ {BEGIN(TAIL); s = yytext; len = s.size();  s = s.substr (0, s.size());  insertStats(s); return 1; }
    . {BEGIN(INITIAL); return 0;}
    \n {BEGIN(INITIAL); return 0; }
}

<TAIL>{
    . ;
    \n BEGIN(INITIAL);
}
%%

//#define ALLRIGHT

int main()
{   	
    ResData.open("./ResData.txt",std::ios_base::out);
#ifdef ALLRIGHT
	Data.open("./allright.txt",std::ios_base::in);
#else
    Data.open("./txfile.txt",std::ios_base::in);
#endif
    if(!Data || !ResData){
        std::cout << "One of files can not be opened";
        return 1;
    }
    high_resolution_clock::time_point start = high_resolution_clock::now();
	yyFlexLexer ftp;
	ftp.yyrestart(static_cast<std::istream&>(Data));
    while(Data.get() && !Data.eof())
    {
        Data.unget();
	    if(ftp.yylex()){
	        std::cout << "The string is true" << std::endl;
        }
        else{
            std::cout << "The string is false" << std::endl;
        }
    }
    high_resolution_clock::time_point finish = high_resolution_clock::now();
    auto duration_mcs = duration_cast<microseconds>(finish - start).count();
    auto duration_ns  = duration_cast<nanoseconds>(finish - start).count();
    std::cout << std::endl;
    ResData << "Statistics:" << std::endl;
    for (auto& el:stats){
	    ResData << el.first << " " << el.second << std::endl;
	    std::cout << el.first << " " << el.second << std::endl;
    }
    std::cout << "\nDuration:\n    - microseconds: " << duration_mcs \
              << "\n    - nanoseconds:  " << duration_ns << std::endl;
    return 0;
}
