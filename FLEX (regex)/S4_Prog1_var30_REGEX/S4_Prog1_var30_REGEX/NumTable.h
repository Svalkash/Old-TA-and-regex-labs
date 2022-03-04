#ifndef NUMTABLE_H
#define NUMTABLE_H

namespace nt
{
	class NumTable
	{
	private:
		std::map<std::string, int> table;
	public:
		NumTable() {}
		~NumTable() {}
		void addnum(const std::string &);
		int getuses(const std::string &) const;
		void save(const std::string &) const;
	};
}

#endif