#include "pch.h"
#include "ReaderClass.h"
#include <algorithm>

bool ReaderClass::checkString(const char *str)
{
	//����� ����� � 0
	successFlag = false;
	unameLen = 0;
	passLen = 0;
	ftpStr.clear();
	servStr.clear();
	zoneLen = 0;
	if (firstRun) //�������� ������� �������. ����������� SMC. ����� ����� ���� ����� ��� ���������. ������ � ��������� ��������� (Ftp)
	{
		_fsm.enterStartState();
		firstRun = false;
	}
	else
		_fsm.Reset();
	//���� �� �������� ����� ������, ������� �� ������� ������ � � ����������� �� ���� ���������� ��������. ���� ��� �� ��� - unknown
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
	_fsm.EOS(); //��������, ���������� ����� ������. ������ �����������.
	return successFlag;
}

void ReaderClass::fSuccess()
{
	successFlag = true;
	journal.addserv(servStr); //���������� �������
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