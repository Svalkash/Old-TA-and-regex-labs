#ifndef RCLASS_H
#define RCLASS_H

#include "ReaderClass_sm.h"
#include "NumTable.h"
#include <string>
#include <vector>



class ReaderClass
{
private:
	ReaderClassContext _fsm;

	bool successFlag;
	bool firstRun;
	
	int typeLen;
	std::string typeStr;
	bool smsMode;
	
	int numLen;
	std::string numStr;
	std::vector<std::string> numVect;
	nt::NumTable &journal;
	int bodyLen;
	std::string bodyStr;
	
	int smsLen;
	
	static const int MTL;
	static const int NTSn;
	static const std::string NTS[3];
	static const int MNL;
	static const int MBL;
	static const std::string NBS;
	static const int MSL;
public:
	ReaderClass(nt::NumTable &jTable) : firstRun(true), _fsm(*this), journal(jTable), successFlag(false), typeLen(0), typeStr(), smsMode(false), numLen(0), numStr("+"), numVect(), bodyLen(0), bodyStr(), smsLen(0) {}
    ~ReaderClass() {}
    bool checkString(const char *);
	void fSuccess();
	void fFail();
	
	bool checkTL() { return (typeLen < MTL); }
	void addTS(char c) { typeLen++; typeStr += c; }
	bool checkType(); //checks if type's correct and sets smsMode flag
	
	bool checkNL() { return (numLen < MNL); }
	void addNS(char c) { numLen++; numStr += c; }
	void resetNS(); //adds to vector
	
	bool checkBL() { return (bodyLen < MBL); }
	void addBS(char c) { bodyLen++; bodyStr += c; }
	bool checkBS() { return (bodyStr == NBS);}
	
	void incSL() { smsLen++; }
	bool checkSL() { return (smsLen < MSL); }
	
	bool isSms() { return smsMode; }

	/*
	void typeNump() { std::cout << "typeNump" << std::endl; }
	void numpNum() { std::cout << "numpNum" << std::endl; }
	void numNump() { std::cout << "numNump" << std::endl; }
	void numBody() { std::cout << "numBody" << std::endl; }
	void bodySms() { std::cout << "bodySms" << std::endl; }
	void bodyNosms() { std::cout << "bodyNosms" << std::endl; }
	*/
};


#endif