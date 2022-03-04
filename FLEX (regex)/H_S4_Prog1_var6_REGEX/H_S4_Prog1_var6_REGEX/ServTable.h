#ifndef SERVTABLE_H
#define SERVTABLE_H

namespace stab
{
	class ServTable
	{
	private:
		std::map<std::string, int> table; //всё на map
	public:
		ServTable() {}
		~ServTable() {}
		void addserv(std::string); //добавление имени сервера (или увеличение количества, если уже есть). Регистр сбрасывается в нижний (А->а)
		int getuses(std::string) const; //получение кол-ва использований
		void save(const std::string &) const; //Сохранение в файл
	};
}

#endif