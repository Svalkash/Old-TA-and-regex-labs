#include "AppClass.h"
#include <algorithm>
bool AppClass::checkTN()
{
	if (strTN == "int" || strTN == "short" || strTN == "long")
		return 1;
	return 0;
}
bool AppClass::checkS1()//поиск переменной в памяти
{
	return ((notLF1() && strS1.length() > 0) || journal.search(strS1));
}
bool AppClass::checkS2()//поиск переменной в памяти
{
	return ((notLF1() && strS2.length() > 0) || journal.search(strS2));
}
bool AppClass::checkFL()
{
	if (strN[0] >= '0' && strN[0] <= '9')
		return 0;
	return 1;

}
bool AppClass::checkTFL()
{
	if (strTN[0] >= '0' && strTN[0] <= '9')
		return 0;
	return 1;
}
bool AppClass::checkString(char *s)
{
	successFlag = 0;
	letterFlag1 = 0;
	letterFlag2 = 0;
	strTN.clear();
	strN.clear();
	strS1.clear();
	strS2.clear();
	if (firstRunFlag)
	{
		firstRunFlag = 0;
		_fsm.enterStartState();
	}
	else
		_fsm.Reset();
	while (*s != '\0')
	{
		if ((*s >= 'a'&&*s <= 'z') || (*s >= 'A'&&*s <= 'Z'))
			_fsm.Letter(*s);
		else if (*s >= '0'&&*s <= '9')
			_fsm.Digit(*s);
		else if (*s == '*' || *s == '+' || *s == '-' || *s == '/')
			_fsm.Sign();
		else if (*s == ' ')
			_fsm.Space();
		else if (*s == '=')
			_fsm.EqualSign();
		else if (*s == ':')
			_fsm.Colon();
		else
			_fsm.Unknown();
		s++;
	}
	_fsm.EOS();
	return successFlag;
}