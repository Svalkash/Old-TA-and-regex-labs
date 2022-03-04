#include "Varm.h"
#include <fstream>

using namespace std;

namespace my_big_namespace
{
	void Varm::addpair(const std::pair<std::string, std::string> &p)
	{
		if (!table.insert(p).second)
		{
			//throw exception("kk");
		}
	}

	bool Varm::search(const std::string &s) const
	{
		for (auto rit : table)
			if (rit.second == s)
				return 1;
		return 0;
	}


	void Varm::save(const std::string &fname) const
	{
		std::ofstream fout(fname);
		for (auto it = table.begin(); it != table.end(); ++it)
			fout << (*it).first << " - " << (*it).second << std::endl;
		fout.close();
	}
}
