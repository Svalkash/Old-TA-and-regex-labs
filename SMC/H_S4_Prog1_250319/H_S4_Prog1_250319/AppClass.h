#pragma once
#include <iostream>
#include <string>
#include "AppClass_sm.h"
#include "Varm.h"
using namespace std;
using namespace my_big_namespace;
class AppClass
{
private:
	AppClassContext _fsm;
	bool successFlag;
	bool letterFlag1;
	bool letterFlag2;
	bool firstRunFlag;
	Varm &journal;//для хранения статистики
	string strTN;
	string strN;
	string strS1;
	string strS2;
public:
	AppClass(Varm &v) :_fsm(*this), journal(v), successFlag(0), letterFlag1(0), letterFlag2(0), firstRunFlag(1) {}
	bool checkString(char *s);
	void Unacceptable() { successFlag = 0; }
	bool checkTNlen() { return strTN.length() < 16; }
	void addTN(char c) { strTN += c; }
	bool checkTN();
	void setDefTN() { strN = strTN; strTN = "int"; }
	bool checkNlen() { return strN.length() < 16; }
	void addN(char c) { strN += c; }
	bool checkS1len() { return strS1.length() < 16; }
	void setLF1() { letterFlag1 = 1; }
	bool notLF1() { return !letterFlag1; }
	void addS1(char c) { strS1 += c; }
	bool checkS1();
	bool checkS2len() { return strS2.length() < 16; }
	void setLF2() { letterFlag2 = 1; }
	bool notLF2() { return !letterFlag2; }
	void addS2(char c) { strS2 += c; }
	bool checkS2();
	void Acceptable() { successFlag = 1; journal.addpair(std::make_pair(strTN, strN)); }
	bool checkFL();//проверяем на первую букву в : strN
	bool checkTFL();//проверяем на первую букву в : strTN
	void sch() { /*std::cout << "good" << endl;*/ }
	bool checkTNlenN() { return strTN.length() > 0; }
	bool checkNlenN() { return strN.length() > 0; }
};

