#ifndef RCLASS_H
#define RCLASS_H
#include "ReaderClass_sm.h"
#include "ServTable.h" //контейнер для запоминания имён серверов
#include <string>
#include <vector>



class ReaderClass
{
private:
	ReaderClassContext _fsm; //надо

	bool successFlag; //флаг успеха, устанавливается в конце строки
	bool firstRun; //флаг первого запуска. Объяснил в .срр
	
	std::string ftpStr; //ftp запоминаем и сверяем
	
	std::string servStr; //имя сервера
	stab::ServTable &journal; //ссылка на таблицу с статистикой
	
	int unameLen; //длина имени
	int passLen; //длина пароля
	int zoneLen; //длина имени зоны
	
	
public:
	ReaderClass(stab::ServTable &jTable) : firstRun(true), _fsm(*this), journal(jTable), successFlag(false), ftpStr(), servStr(), unameLen(0), passLen(0), zoneLen(0) {}
    ~ReaderClass() {}
    bool checkString(const char *); //функция проверки строки
	void fSuccess(); //ставит флажок успеха и сохраняет имя сервера
	void fFail(); //флажок неудачи
	
	bool checkFL() { return ftpStr.length() < 3; } //проверка длины ftp
	void addFS(char c) { ftpStr += c; } //добаление символа
	bool checkFtp(); //сверяем точно
	
	bool checkUL() { return unameLen < 20; } ///Проверка длины имени пользователя
	void incUL() { unameLen++; } //добавили символ
	bool checkULN() { return unameLen != 0; } //не нулевая строка

	bool checkPL() { return passLen < 20; } ///Проверка длины пароля
	void incPL() { passLen++; } //добавили символ
	bool checkPLN() { return passLen != 0; } //не нулевая строка
	
	bool checkSL() { return servStr.length() < 20; } ///Проверка длины имени сервера
	void addSS(char c) { servStr += c; } //добавили символ
	bool checkSLN() { return servStr.length() != 0; } //не нулевая строка
	
	bool checkZL() { return zoneLen < 5; } //проверка длины зоны
	void incZL() { zoneLen++; } //увеличили длину
	void resetZL() { zoneLen = 0; } //сброс длины
	bool checkZLN() { return zoneLen != 0; } //не нулевая
};


#endif