/*============================================================================
 * File Name   : Parameters.h
 * Author      : Yang Cai
 * Version     : 0.1
 * Copyright   : Copyright 2014 DeepGlint Inc.
 * Created on  : 10/11/2014
 * Description : A parameter (virtual) class for parameter reading and parsing
 * ==========================================================================*/

#ifndef PARAMETER_H
#define PARAMETER_H
#include <map>
#include <string>
#include <cassert>
#include <sstream>

using std::map;
using std::string;
using std::endl;
class Parameters
{
public:

	//return the err message, "" means success
	virtual bool ParseCommandLine(int argc, char* argv[]);
	virtual string Usage() const
	{
		std::stringstream s;
		s<<exeName<<endl;
		if(errMessage != "")
		s<<" Error: "<<errMessage<<endl;
		s<<" Usage:"<<endl;

		return s.str();
	}
	virtual string ToString() const
	{
		std::stringstream s;
		for(map<string, string>::const_iterator p=_params.begin(); p!=_params.end(); ++p)
		{
			s<<"-"<<p->first<<"\t"<<p->second<<endl;
		}
		return s.str();
	}
protected:
	virtual bool InternalParse()
	{
		return true;
	}
	map<string, string> _params;
	string errMessage;
	string exeName;
};
#endif
