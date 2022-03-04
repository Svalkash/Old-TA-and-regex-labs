#include "pch.h"
#include "NumTable.h"

namespace nt
{
	void NumTable::addnum(const std::string &num)
	{
		std::map<std::string, int>::iterator pos = table.find(num);
		if (pos == table.end())
			table.insert(std::make_pair(num, 1));
		else
			++(*pos).second;
	}

	int NumTable::getuses(const std::string &num) const
	{
		std::map<std::string, int>::const_iterator pos = table.find(num);
		if (pos == table.end())
			throw std::exception("no_such_number");
		return (*pos).second;
	}

	void NumTable::save(const std::string &fname) const
	{
		std::ofstream fout(fname);
		for (std::map<std::string, int>::const_iterator it = table.begin(); it != table.end(); ++it)
			fout << (*it).first << " | " << (*it).second << std::endl;
		fout.close();
	}
}