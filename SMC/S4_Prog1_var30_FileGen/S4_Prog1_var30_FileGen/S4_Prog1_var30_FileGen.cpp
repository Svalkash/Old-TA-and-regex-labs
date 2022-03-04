// S4_Prog1_var30_FileGen.cpp : Этот файл содержит функцию "main". Здесь начинается и заканчивается выполнение программы.
//

#include "pch.h"
#include <iostream>
#include <string>
#include <fstream>
#include <ctime>

using namespace std;

const int MAXNUM = 10;
const int MAXSMS = 64;

string strgen()
{
	string str;
	int type = rand() % 3;
	switch (type)
	{
	case 0:
		str += "tel";
		break;
	case 1:
		str += "fax";
		break;
	case 2:
		str += "sms";
		break;
	}
	str += ':';
	//num0
	str += '+';
	for (int i = 0; i < 11; ++i)
		str += char(48 + rand() % 10);
	//othernums
	int mc = rand() % MAXNUM;
	for (int c = 0; c < mc; ++c)
	{
		str += ',';
		str += '+';
		for (int i = 0; i < 11; ++i)
			str += char(int('0') + rand() % 10);
	}
	str += ';';
	//body
	str += "?body=";
	//sms
	if (type == 2)
	{
		int ms = rand() % (MAXSMS + 1);
		for (int s = 0; s < ms; ++s)
			str += char(int('a') + rand() % 26);
	}
	//
	return str;
}

int filegen(const string &fname, int strn)
{
	ofstream fout(fname);
	if (!fout.is_open())
		return 1;
	for (int i = 0; i < strn; i++)
		fout << strgen() << endl;
	fout.close();
	return 0;
}

int main(int argc, char* argv[])
{
	srand(time(0));
	int rc = 0;
	if (argc != 2)
	{
		cerr << "need only one argument";
		return -1;
	}
	int n = 1;
	for (int d = 0; d < atoi(argv[1]); d++, n *= 10)
	{
		string str = string("file_") + char(int('0') + d) + string(".txt");
		rc += filegen(str, n);
	}
	return rc;
}

// Запуск программы: CTRL+F5 или меню "Отладка" > "Запуск без отладки"
// Отладка программы: F5 или меню "Отладка" > "Запустить отладку"

// Советы по началу работы 
//   1. В окне обозревателя решений можно добавлять файлы и управлять ими.
//   2. В окне Team Explorer можно подключиться к системе управления версиями.
//   3. В окне "Выходные данные" можно просматривать выходные данные сборки и другие сообщения.
//   4. В окне "Список ошибок" можно просматривать ошибки.
//   5. Последовательно выберите пункты меню "Проект" > "Добавить новый элемент", чтобы создать файлы кода, или "Проект" > "Добавить существующий элемент", чтобы добавить в проект существующие файлы кода.
//   6. Чтобы снова открыть этот проект позже, выберите пункты меню "Файл" > "Открыть" > "Проект" и выберите SLN-файл.
