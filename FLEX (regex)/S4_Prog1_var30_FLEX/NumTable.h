#ifndef NUMTABLE_H
#define NUMTABLE_H

#include <stdio.h>
#include <string>
#include <map>
#include <iostream>
#include <fstream>

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
