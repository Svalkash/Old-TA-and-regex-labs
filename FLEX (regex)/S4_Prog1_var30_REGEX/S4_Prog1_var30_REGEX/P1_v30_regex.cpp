// P1_v30_regex.cpp : Defines the entry point for the console application.
//
#include "pch.h"

#include <regex>
#include <ctime>
#include "NumTable.h"

const char logFile[] = "log.txt";
const char journalFile[] = "journal.txt";
const int numlen = 12;

using namespace std;
using namespace nt;

ifstream &checkFile(ifstream &ifs, NumTable &numt, ofstream &ofs)
{
	const regex tel_regex("tel\\:\\+[0-9]{11}(,\\+[0-9]{11})*;\\?body=");
	const regex fax_regex("fax\\:\\+[0-9]{11}(,\\+[0-9]{11})*;\\?body=");
	const regex sms_regex("sms\\:\\+[0-9]{11}(,\\+[0-9]{11})*;\\?body=[0-9a-zA-Z%\\.,!\\?]{0,64}");
	smatch any_match;
	char buf[256];
	string workStr;
	int snn, sni, smslen;
	char buftemp[13] = "+00000000000";
	while (ifs.good())
	{
		ifs.getline(buf, 255);
		workStr = buf;
		if (regex_match(workStr, any_match, tel_regex) || regex_match(workStr, any_match, fax_regex))
		{
			snn = (strlen(buf) - 11 - numlen) / (numlen + 1) + 1;
			for (sni = 0; sni < snn; sni++)
			{
				strncpy_s(buftemp, buf + (4 + (numlen + 1) * sni), numlen);
				numt.addnum(string(buftemp));
			}
			ofs << "  ACCEPTABLE | " << buf << endl;
		}
		else if (regex_match(workStr, any_match, sms_regex))
		{
			smslen = strlen(strchr(buf, '=')) - 1;
			snn = (strlen(buf) - 11 - numlen - smslen) / (numlen + 1) + 1;
			for (sni = 0; sni < snn; sni++)
			{
				strncpy_s(buftemp, buf + (4 + (numlen + 1) * sni), numlen);
				numt.addnum(string(buftemp));
			}
			ofs << "  ACCEPTABLE | " << buf << endl;
		}
		else
			ofs << "INACCEPTABLE | " << buf << endl;
	}
	return ifs;
}

int _tmain(int argc, _TCHAR* argv[])
{
	/*
	NumTable numJournal;
	ifstream fin("stringList.txt");
	if (!fin.is_open())
		cerr << "Cannot open input file." << endl;
	ofstream flog(logFile);
	checkFile(fin, numJournal, flog);
	*/

	//timing
	clock_t t0 = clock();
	////////
	NumTable numJournal;
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
		ifstream fin(argv[1]);
		if (!fin.is_open())
		{
			cerr << "Cannot open input file." << endl;
			rc = 3;
		}
		else
		{
			ofstream flog(logFile);
			checkFile(fin, numJournal, flog);
			fin.close();;
			flog.close();
			//journal
			numJournal.save(journalFile);
		}
	}
	//timing
	clock_t t1 = clock();
	cout << "Elapsed time: " << (float)(t1 - t0) / CLOCKS_PER_SEC << endl;
	////////
	return rc;
}