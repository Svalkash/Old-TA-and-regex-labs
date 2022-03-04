#include "pch.h"

#include "ReaderClass.h"
#include "ServTable.h"
#include <ctime>

using namespace std;
using namespace statemap;
using namespace stab;

const string logFile = "log.txt";
const string journalFile = "journal.txt";
//Для отладки
#define DEBUGMODE 0

int main(int argc, char *argv[])
{
	//timing
	clock_t t0 = clock();
	////////
	ServTable servJournal;
	ReaderClass reader(servJournal);
	int rc = 0;
#if !DEBUGMODE
	if (argc < 2) //Чтобы можно было пускать из консоли. Если аргумента нет (нулевой - что-то другое)...
	{
		cerr << "No input file." << endl;
		rc = 1;
	}
	else if (argc > 2) //И если их много
	{
		cerr << "Only one argument is accepted." << endl;
		rc = 2;
	}
	else
#endif
	{
		//opening files
#if DEBUGMODE
		ifstream fin("stringList.txt");
#else
		ifstream fin(argv[1]); //По первому параметру открываем файл
#endif
		if (!fin.is_open()) //Не вышло - ошибка.
		{
			cerr << "Cannot open input file." << endl;
			rc = 3;
		}
		else
		{
			ofstream flog(logFile);
			while (!fin.eof()) //пока не конец файла
			{
				char line[256];
				fin.getline(line, 256); //Читаем строку из файла
				if (reader.checkString(line)) //Проверяем
					flog << "  ACCEPTABLE - " << line << endl; //Пишем в лог результат
				else
					flog << "UNACCEPTABLE - " << line << endl;
			}
			fin.close();
			flog.close();
			//journal
			servJournal.save(journalFile); //Сохраняем таблицу со статистикой
		}
	}
	//timing
	clock_t t1 = clock();
	cout << "Elapsed time: " << (float)(t1 - t0) / CLOCKS_PER_SEC << endl; //Позже пригодится
	////////
	system("pause");
	return rc;
}