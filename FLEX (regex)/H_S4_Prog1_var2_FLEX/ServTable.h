#ifndef SERVTABLE_H
#define SERVTABLE_H

#include <string>
#include <map>
#include <iostream>
#include <fstream>

namespace stab
{
	class ServTable
	{
	private:
		std::map<std::string, int> table; //�� �� map
	public:
		ServTable() {}
		~ServTable() {}
		void addserv(std::string); //���������� ����� ������� (��� ���������� ����������, ���� ��� ����). ������� ������������ � ������ (�->�)
		int getuses(std::string) const; //��������� ���-�� �������������
		void save(const std::string &) const; //���������� � ����
	};
}

#endif
