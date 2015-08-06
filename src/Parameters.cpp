/*============================================================================
 * File Name   : Parameters.cpp
 * Author      : Yang Cai
 * Version     : 0.1
 * Copyright   : Copyright 2014 DeepGlint Inc.
 * Created on  : 10/11/2014
 * Description : A parameter (virtual) class for parameter reading and parsing
 * ==========================================================================*/

#include "Parameters.h"
bool Parameters::ParseCommandLine(int argc, char *argv[])
{
	exeName = argv[0];
	std::pair<string, string> cur = std::make_pair("", "");
	int i = 0;
	while (++i < argc) {
		if (argv[i][0] == '-') {
			if (cur.first != "") {
				_params.insert(cur);
			}
			cur = std::make_pair(string(argv[i]).substr(1), "");
		}
		else {
			if (cur.first == "") {
				errMessage = "incorrect parameters";
				return false;
			}
			if (cur.second != "")
				cur.second.append(" ");
			cur.second.append(argv[i]);
		}
	}
	if (cur.first != "")
		_params.insert(cur);
	return InternalParse();
}
