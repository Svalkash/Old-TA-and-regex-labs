// H_S4_Prog1_var2_REGEX.cpp : Этот файл содержит функцию "main". Здесь начинается и заканчивается выполнение программы.
//

#include "pch.h"

#include <regex>
#include <ctime>
#include "ServTable.h"

const char logFile[] = "log.txt";
const char journalFile[] = "journal.txt";

using namespace std;
using namespace stab;

ifstream &checkFile(ifstream &ifs, ServTable &servt, ofstream &ofs)
{
	const regex my_regex("^ftp\\:\\/\\/([a-z0-9]{1,20})(\\:[a-z0-9]{1,20})?@([0-9a-z]{1,20})(\\.[a-z]{1,5})+$", std::regex_constants::icase);
	smatch any_match;
	char buf[512];
	string workStr;
	while (ifs.good())
	{
		ifs.getline(buf, 15000);
		workStr = buf;
		if (regex_match(workStr, any_match, my_regex))
		{
			servt.addserv(any_match[3]);
			ofs << "  ACCEPTABLE - " << buf << endl;
		}
		else
			ofs << "INACCEPTABLE - " << buf << endl;
	}
	return ifs;
}

#define DEBUGMODE 0

int main(int argc, char* argv[])
{
	//timing
	clock_t t0 = clock();
	////////
	ServTable servJournal;
	int rc = 0;
#if (!DEBUGMODE)
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
#endif
	{
		//opening files
#if (!DEBUGMODE)
		ifstream fin(argv[1]);
#else
		ifstream fin("stringList.txt");
#endif
		if (!fin.is_open())
		{
			cerr << "Cannot open input file." << endl;
			rc = 3;
		}
		else
		{
			ofstream flog(logFile);
			checkFile(fin, servJournal, flog);
			fin.close();;
			flog.close();
			//journal
			servJournal.save(journalFile);
		}
	}
	//timing
	clock_t t1 = clock();
	cout << "Elapsed time: " << (float)(t1 - t0) / CLOCKS_PER_SEC << endl;
	////////
	system("pause");
	return rc;
}