#ifndef SERVTABLE_H
#define SERVTABLE_H

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