#include "ServTable.h"
#include <algorithm>

namespace stab
{
	void ServTable::addserv(std::string serv)
	{
		std::transform(serv.begin(), serv.end(), serv.begin(), ::tolower);
		std::map<std::string, int>::iterator pos = table.find(serv);
		if (pos == table.end())
			table.insert(std::make_pair(serv, 1));
		else
			++(*pos).second;
	}

	int ServTable::getuses(std::string serv) const
	{
		std::transform(serv.begin(), serv.end(), serv.begin(), ::tolower);
		std::map<std::string, int>::const_iterator pos = table.find(serv);
		if (pos == table.end())
			throw std::exception();
		return (*pos).second;
	}

	void ServTable::save(const std::string &fname) const
	{
		std::ofstream fout(fname);
		for (std::map<std::string, int>::const_iterator it = table.begin(); it != table.end(); ++it)
			fout << (*it).first << " | " << (*it).second << std::endl;
		fout.close();
	}
}
