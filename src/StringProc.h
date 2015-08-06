/*============================================================================
 * File Name   : StringProc.h
 * Author      : Yang Cai
 * Version     : 0.1
 * Copyright   : Copyright 2014 DeepGlint Inc.
 * Created on  : 10/11/2014
 * Description : A string processing class
 * ==========================================================================*/

#ifndef STRING_PROC_H
#define STRING_PROC_H

#include <string>
#include <vector>

using namespace std;
class StringProc
{
public:
	StringProc() {}
	static void Split(string str, char dilemma, vector<string>& splits) {
		if (str.length() == 0)
			return;
		char* p1 = (char*) str.c_str();
		char* p2 = NULL;
		do {
			p2 = strchr(p1, dilemma);
			if (p2 != NULL) {
				splits.push_back(string(p1, p2));
				p1 = p2 + 1;
			} else {
				splits.push_back(string(p1));
				break;
			}
		} while (true);
	}
	static vector<string> Split(string str, char dilemma) {
		vector<string> splits;
		if (str.length() == 0)
			return splits;
		char* p1 = (char*) str.c_str();
		char* p2 = NULL;
		do {
			p2 = strchr(p1, dilemma);
			if (p2 != NULL) {
				splits.push_back(string(p1, p2));
				p1 = p2 + 1;
			} else {
				splits.push_back(string(p1));
				break;
			}
		} while (true);
		return splits;
	}
};

#endif
