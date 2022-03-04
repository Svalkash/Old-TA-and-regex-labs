%option noyywrap
%x SERVER TAIL

%{
#include <string>
#include "ServTable.h"
#include <iostream>
#include <fstream>

using namespace std;
using namespace stab;
ServTable servJournal;
ofstream flog;
const string logFile = "log.txt";
const string journalFile = "journal.txt";
string memstring = "";
%}

%%
<INITIAL>{ //проверка заголовка
^(?i:ftp\:\/\/)/.{1,64}\n {BEGIN(SERVER); memstring+=string(yytext);} //проверка заголовка
\n {flog<<"INACCEPTABLE | "<<memstring<<endl; memstring.clear();} //получили конец - ругаемся
. memstring+=string(yytext);  //если всё плохо, "съедаем" символы до конца.
}
<SERVER>{ //имя сервера и остаток
(?i:[0-9a-z]{1,20})/(?i:\.([0-9a-z]{1,20}\.)*[a-z]{1,5})\n {BEGIN(TAIL); servJournal.addserv(string(yytext)); memstring+=string(yytext);} //проверка середины и конца. Сохранение сервера
. {BEGIN(INITIAL);memstring+=string(yytext);}  //если всё плохо, "съедаем" символы до конца.
\n {BEGIN(INITIAL); flog<<"INACCEPTABLE | "<<memstring<<endl; memstring.clear();} //получили конец - ругаемся
}
<TAIL>{ //удаление конца
. memstring+=string(yytext); //всё уже хорошо. съедаем остаток (уже проверенный).
\n {BEGIN(INITIAL); flog<<"  ACCEPTABLE | "<<memstring<<endl; memstring.clear();} //конец строки
}
%%
 //всё как раньше
int main(int argc, char *argv[])
{
	int rc = 0;
	if (argc < 2)
	{
		cerr << "No input file." << endl;
		rc = 1;
	}
	else if (argc > 2)
	{
		cerr << "Only one argument is accepted." << endl;
		rc = 2;
	}
	else
	{
		//opening files
		if (!(yyin = fopen(argv[1], "r")))
		{
			cerr << "Cannot open input file." << endl;
			rc = 3;
		}
		else
		{
			flog.open(logFile);
			yylex(); //запуск анализатора
			fclose(yyin);
			flog.close();
			//journal
			servJournal.save(journalFile);
		}
	}
	return rc;
}
