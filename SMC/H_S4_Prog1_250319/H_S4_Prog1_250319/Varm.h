#ifndef VARM_H
#define VARM_H

#include <set>
#include <map>
#include <string>
//контейнер в который мы будем помещать
namespace my_big_namespace
{
	class Varm
	{
	private:
		std::set<std::pair<std::string, std::string> > table;
	public:
		Varm() {}
		~Varm() {}
		void addpair(const std::pair<std::string, std::string> &);
		bool search(const std::string &) const;
		void save(const std::string &) const;
	};
}

#endif