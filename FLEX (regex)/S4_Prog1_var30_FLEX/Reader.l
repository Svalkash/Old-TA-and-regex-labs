%option noyywrap
%x NUMS BODY

%{
#include <string.h>
#include "NumTable.h"
#include <iostream>
#include <fstream>

using namespace std;
using namespace nt;
NumTable numJournal;
int snn, sni;
const int numlen = 12;
int smslen;
char buf[13] = "+00000000000";
ofstream flog;
const string logFile = "log.txt";
const string flexLogFile = "flexlog.txt";
const string journalFile = "journal.txt";
string failstring = "";
%}

NUM	 \+[0-9]{11}
SMSTEXT [0-9a-zA-Z%\.,!\?]{1,64}
%%
tel\:{NUM}(,{NUM})*;\?body= |
fax\:{NUM}(,{NUM})*;\?body= {
	snn = (strlen(yytext) - 11 - numlen) / (numlen + 1) + 1;
	for (sni = 0; sni < snn; sni++)
	{
		strncpy(buf, yytext + (4 + (numlen + 1) * sni), numlen);
		numJournal.addnum(string(buf));
	}
	flog << "  ACCEPTABLE | " << yytext << endl;
}
sms\:{NUM}(,{NUM})*;\?body={SMSTEXT} {
	smslen = strlen(strchr(yytext, '=')) - 1;
	snn = (strlen(yytext) - 11 - numlen - smslen) / (numlen + 1) + 1;
	for (sni = 0; sni < snn; sni++)
	{
		strncpy(buf, yytext + (4 + (numlen + 1) * sni), numlen);
		numJournal.addnum(string(buf));
	}
	flog << "  ACCEPTABLE | " << yytext << endl;
}
. { failstring += *yytext; }
\n { flog << "INACCEPTABLE | " << failstring << endl; failstring = ""; }
%%

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
			yylex();
			fclose(yyin);
			flog.close();
			//journal
			numJournal.save(journalFile);
		}
	}
	return rc;
}
