#include "pch.h"
#include "ReaderClass.h"

const int ReaderClass::MTL = 3;
const int ReaderClass::NTSn = 3;
const std::string ReaderClass::NTS[3] = { "tel", "fax", "sms" }; //sms always last
const int ReaderClass::MNL = 11;
const int ReaderClass::MBL = 5;
const std::string ReaderClass::NBS = "?body";
const int ReaderClass::MSL = 64;

bool ReaderClass::checkString(const char *str)
{
	successFlag = false;
	typeLen = 0;
	typeStr.clear();
	smsMode = false;
	numLen = 0;
	numStr = "+";
	numVect.clear();
	bodyLen = 0;
	bodyStr.clear();
	smsLen = 0;
	if (firstRun)
	{
		_fsm.enterStartState();
		firstRun = false;
	}
	else
		_fsm.Reset();
	while (*str != '\0')
	{
		if ((*str >= '0') && (*str <= '9'))
			_fsm.Dig(*str); //lit too
		else if (((*str >= 'a') && (*str <= 'z')) || ((*str >= 'A') && (*str <= 'Z')) || (*str == '%') || (*str == '.') || (*str == '!') || (*str == '?'))
			_fsm.Lit(*str);
		else if (*str == '+')
			_fsm.Plus();
		else if (*str == ':')
			_fsm.Colon();
		else if (*str == ',')
			_fsm.Comma(); //lit too
		else if (*str == ';')
			_fsm.Semicolon();
		else if (*str == '=')
			_fsm.EqualSign();
		else
			_fsm.Unknown();
		++str;
	}
	_fsm.EOS();
	return successFlag;
}

void ReaderClass::fSuccess()
{
	successFlag = true;
	for (std::vector<std::string>::iterator it = numVect.begin(); it != numVect.end(); ++it)
		journal.addnum(*it);
}

void ReaderClass::fFail()
{
	successFlag = false;
}

bool ReaderClass::checkType()
{
	for (int i = 0; i < NTSn; ++i)
		if (typeStr == NTS[i])
		{
			if (i == NTSn - 1) //for sms
				smsMode = true;
			return true;
		}
	return false;
}

void ReaderClass::resetNS()
{
	numVect.push_back(numStr);
	numStr = "+";
	numLen = 0;
}