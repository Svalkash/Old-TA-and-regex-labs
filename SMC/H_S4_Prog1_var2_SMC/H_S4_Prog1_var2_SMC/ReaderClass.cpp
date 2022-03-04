#include "pch.h"
#include "ReaderClass.h"
#include <algorithm>

bool ReaderClass::checkString(const char *str)
{
	//Сброс всего в 0
	successFlag = false;
	unameLen = 0;
	passLen = 0;
	ftpStr.clear();
	servStr.clear();
	zoneLen = 0;
	if (firstRun) //Проверка первого запуска. Особенности SMC. Чтобы можно было много раз запускать. Входим в начальное состояние (Ftp)
	{
		_fsm.enterStartState();
		firstRun = false;
	}
	else
		_fsm.Reset();
	//Пока не достигли конца строки, смотрим на текущий символ и в зависимости от него отправляем переходы. Если что не так - unknown
	while (*str != '\0')
	{
		if ((*str >= '0') && (*str <= '9'))
			_fsm.Dig(*str);
		else if (((*str >= 'a') && (*str <= 'z')) || ((*str >= 'A') && (*str <= 'Z')))
			_fsm.Letter(*str);
		else if (*str == ':')
			_fsm.Colon();
		else if (*str == '.')
			_fsm.Dot();
		else if (*str == '/')
			_fsm.Slash();
		else if (*str == '@')
			_fsm.At();
		else
			_fsm.Unknown();
		++str;
	}
	_fsm.EOS(); //достигли, отправляем конец строки. Флажок проставился.
	return successFlag;
}

void ReaderClass::fSuccess()
{
	successFlag = true;
	journal.addserv(servStr); //сохранение сервера
}

void ReaderClass::fFail()
{
	successFlag = false;
}

bool ReaderClass::checkFtp()
{
	std::transform(ftpStr.begin(), ftpStr.end(), ftpStr.begin(), ::tolower);
	return ftpStr == std::string("ftp");
}