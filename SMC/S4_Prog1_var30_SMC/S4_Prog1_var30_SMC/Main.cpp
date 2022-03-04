#include "pch.h"

#include "ReaderClass.h"
#include "NumTable.h"
#include <ctime>

using namespace std;
using namespace statemap;
using namespace nt;

const string logFile = "log.txt";
const string journalFile = "journal.txt";

int main(int argc, char *argv[])
{
	//timing
	clock_t t0 = clock();
	////////
	NumTable numJournal;
	ReaderClass reader(numJournal);
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
		//ifstream fin("stringList.txt");
		if (!fin.is_open())
		{
			cerr << "Cannot open input file." << endl;
			rc = 3;
		}
		else
		{
			ofstream flog(logFile);
			while (!fin.eof())
			{
				char line[256];
				fin.getline(line, 256);
				if (reader.checkString(line))
					flog << "  ACCEPTABLE | " << line << endl;
				else
					flog << "INACCEPTABLE | " << line << endl;
			}
			fin.close();
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