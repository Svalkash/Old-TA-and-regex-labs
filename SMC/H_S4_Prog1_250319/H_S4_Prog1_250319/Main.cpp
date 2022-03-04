#include "AppClass.h"
#include "Varm.h"
#include <ctime>
#include <iostream>
#include <fstream>
#include <string>

using namespace std;
using namespace my_big_namespace;

const string logFile = "log.txt";
const string journalFile = "journal.txt";
//ƒÎˇ ÓÚÎ‡‰ÍË
#define DEBUGMODE 0

int main(int argc, char *argv[])
{
	//timing
	clock_t t0 = clock();
	////////
	Varm servJournal;
	AppClass reader(servJournal);
	int rc = 0;
#if !DEBUGMODE
	if (argc < 2) //◊ÚÓ·˚ ÏÓÊÌÓ ·˚ÎÓ ÔÛÒÍ‡Ú¸ ËÁ ÍÓÌÒÓÎË. ≈ÒÎË ‡„ÛÏÂÌÚ‡ ÌÂÚ (ÌÛÎÂ‚ÓÈ - ˜ÚÓ-ÚÓ ‰Û„ÓÂ)...
	{
		cerr << "No input file." << endl;
		rc = 1;
	}
	else if (argc > 2) //» ÂÒÎË Ëı ÏÌÓ„Ó
	{
		cerr << "Only one argument is accepted." << endl;
		rc = 2;
	}
	else
#endif   
	{
		//opening files
#if !DEBUGMODE
		ifstream fin(argv[1]); //œÓ ÔÂ‚ÓÏÛ Ô‡‡ÏÂÚÛ ÓÚÍ˚‚‡ÂÏ Ù‡ÈÎ
#else
		ifstream fin("finput.txt");
#endif
		if (!fin.is_open()) //ÕÂ ‚˚¯ÎÓ - Ó¯Ë·Í‡.
		{
			cerr << "Cannot open input file." << endl;
			rc = 3;
		}
		else
		{
			ofstream flog(logFile);
			while (!fin.eof()) //ÔÓÍ‡ ÌÂ ÍÓÌÂˆ Ù‡ÈÎ‡
			{
				char line[256];//не забыть увеличить буфер
				fin.getline(line, 256); //читает сткроу с пробелами
				if (reader.checkString(line)) //œÓ‚ÂˇÂÏ
					flog << "  ACCEPTABLE - " << line << endl; //œË¯ÂÏ ‚ ÎÓ„ ÂÁÛÎ¸Ú‡Ú
				else
					flog << "UNACCEPTABLE - " << line << endl;
			}
			fin.close();
			flog.close();
			//journal
			servJournal.save(journalFile); //—Óı‡ÌˇÂÏ Ú‡·ÎËˆÛ ÒÓ ÒÚ‡ÚËÒÚËÍÓÈ
		}
	}
	//timing
	clock_t t1 = clock();
	cout << "Elapsed time: " << (float)(t1 - t0) / CLOCKS_PER_SEC << endl; //œÓÁÊÂ ÔË„Ó‰ËÚÒˇ
	////////
	return rc;
}
