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
	bool digFlag; //���� ��������� ����� � ������ ������/����. ����� � ����� ���� �� ���� ����.
	
	int totalLen; //��������� ����� ������ (��� ���������)
	
	std::string ftpStr; //ftp ���������� � �������
	
	std::string servStr; //��� �������
	stab::ServTable &journal; //������ �� ������� � �����������
	
	int domzoneLen; //����� ����� ������/����
	
	
public:
	ReaderClass(stab::ServTable &jTable) : firstRun(true), _fsm(*this), journal(jTable), successFlag(false), totalLen(0), ftpStr(), servStr(), domzoneLen(0), digFlag(false) {}
    ~ReaderClass() {}
    bool checkString(const char *); //������� �������� ������
	void fSuccess(); //������ ������ ������ � ��������� ��� �������
	void fFail(); //������ �������
	
	bool checkFL() { return ftpStr.length() < 3; } //�������� ����� ftp
	void addFS(char c) { ftpStr += c; } //��������� �������
	bool checkFtp(); //������� �����
	
	void incTL() { totalLen++; } //���������� ����� ��������� ������
	bool checkTL() { return totalLen < 64; } //�������� ���� �����
	bool checkTLF() { return totalLen <= 64; } //�������� � ����� (����� �� ��������� ������)
	
	bool checkSL() { return servStr.length() < 20; } ///�������� ����� ����� �������
	void addSS(char c) { servStr += c; } //�������� ������
	bool checkSLN() { return servStr.length() != 0; } //�� ������� ������
	
	bool checkDL() { return domzoneLen < 20; } //�������� ����� ������
	void incDZL() { domzoneLen++; } //��������� �����
	void resetDZL() { domzoneLen = 0; } //����� �����
	bool checkDZLN() { return domzoneLen != 0; } //�� �������
	bool checkZLF() { return (domzoneLen != 0) && (domzoneLen <=  5); } //������������ ��������� �� 0 � ����. �����

	void setDigFlag() { digFlag = true; } //������ ���� �����
	void resetDigFlag() { digFlag = false; } //����������
	bool checkDigFlag() { return digFlag; } //���������
};


#endif