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
	bool digFlag; //флаг получения цифры в строке домена/зоны. Чтобы в имени зоны не было цифр.
	
	int totalLen; //суммарная длина строки (без заголовка)
	
	std::string ftpStr; //ftp запоминаем и сверяем
	
	std::string servStr; //имя сервера
	stab::ServTable &journal; //ссылка на таблицу с статистикой
	
	int domzoneLen; //длина имени домена/зоны
	
	
public:
	ReaderClass(stab::ServTable &jTable) : firstRun(true), _fsm(*this), journal(jTable), successFlag(false), totalLen(0), ftpStr(), servStr(), domzoneLen(0), digFlag(false) {}
    ~ReaderClass() {}
    bool checkString(const char *); //функция проверки строки
	void fSuccess(); //ставит флажок успеха и сохраняет имя сервера
	void fFail(); //флажок неудачи
	
	bool checkFL() { return ftpStr.length() < 3; } //проверка длины ftp
	void addFS(char c) { ftpStr += c; } //добаление символа
	bool checkFtp(); //сверяем точно
	
	void incTL() { totalLen++; } //увеличение длины суммарной строки
	bool checkTL() { return totalLen < 64; } //проверка этой длины
	bool checkTLF() { return totalLen <= 64; } //Проверка в конце (когда не добавляем символ)
	
	bool checkSL() { return servStr.length() < 20; } ///Проверка длины имени сервера
	void addSS(char c) { servStr += c; } //добавили символ
	bool checkSLN() { return servStr.length() != 0; } //не нулевая строка
	
	bool checkDL() { return domzoneLen < 20; } //проверка длины ДОМЕНА
	void incDZL() { domzoneLen++; } //увеличили длину
	void resetDZL() { domzoneLen = 0; } //сброс длины
	bool checkDZLN() { return domzoneLen != 0; } //не нулевая
	bool checkZLF() { return (domzoneLen != 0) && (domzoneLen <=  5); } //одновременно проверили не 0 и макс. длину

	void setDigFlag() { digFlag = true; } //ставим флаг цифры
	void resetDigFlag() { digFlag = false; } //сбрасываем
	bool checkDigFlag() { return digFlag; } //проверяем
};


#endif