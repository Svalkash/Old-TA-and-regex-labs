#ifndef RCLASS_H
#define RCLASS_H
#include "ReaderClass_sm.h"
#include "ServTable.h" //��������� ��� ����������� ��� ��������
#include <string>
#include <vector>



class ReaderClass
{
private:
	ReaderClassContext _fsm; //����

	bool successFlag; //���� ������, ��������������� � ����� ������
	bool firstRun; //���� ������� �������. �������� � .���
	
	std::string ftpStr; //ftp ���������� � �������
	
	std::string servStr; //��� �������
	stab::ServTable &journal; //������ �� ������� � �����������
	
	int unameLen; //����� �����
	int passLen; //����� ������
	int zoneLen; //����� ����� ����
	
	
public:
	ReaderClass(stab::ServTable &jTable) : firstRun(true), _fsm(*this), journal(jTable), successFlag(false), ftpStr(), servStr(), unameLen(0), passLen(0), zoneLen(0) {}
    ~ReaderClass() {}
    bool checkString(const char *); //������� �������� ������
	void fSuccess(); //������ ������ ������ � ��������� ��� �������
	void fFail(); //������ �������
	
	bool checkFL() { return ftpStr.length() < 3; } //�������� ����� ftp
	void addFS(char c) { ftpStr += c; } //��������� �������
	bool checkFtp(); //������� �����
	
	bool checkUL() { return unameLen < 20; } ///�������� ����� ����� ������������
	void incUL() { unameLen++; } //�������� ������
	bool checkULN() { return unameLen != 0; } //�� ������� ������

	bool checkPL() { return passLen < 20; } ///�������� ����� ������
	void incPL() { passLen++; } //�������� ������
	bool checkPLN() { return passLen != 0; } //�� ������� ������
	
	bool checkSL() { return servStr.length() < 20; } ///�������� ����� ����� �������
	void addSS(char c) { servStr += c; } //�������� ������
	bool checkSLN() { return servStr.length() != 0; } //�� ������� ������
	
	bool checkZL() { return zoneLen < 5; } //�������� ����� ����
	void incZL() { zoneLen++; } //��������� �����
	void resetZL() { zoneLen = 0; } //����� �����
	bool checkZLN() { return zoneLen != 0; } //�� �������
};


#endif