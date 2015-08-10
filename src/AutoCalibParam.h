/*
 * AutoCalibParam.h
 *
 *  Created on: Jul 29, 2015
 *      Author: Yang Cai
 */

#ifndef AUTO_CALIB_PARAM_H_
#define AUTO_CALIB_PARAM_H_
#include "Parameters.h"
#include "StringProc.h"
#include "FeatureExtractor.h"
#include <sstream>
#include <fstream>
using namespace std;

#define IMG_WIDTH 1280
#define IMG_HEIGHT 720

class AutoCalibParam: public Parameters
{
public:
	struct InputData
	{
		string id;
		vector<pair<string, string>> left_right_imgs;
	};

	string intr_filepath;
	string extr_filepath;
	string input_filepath;
	string output_dirpath;
	vector<InputData> input_data;
	FeatureDetectorType det_type;
	FeatureDescriptorType desc_type;
	int img_width;
	int img_height;

	AutoCalibParam() {
		det_type = FeatureDetectorType::FAST_DET;
		desc_type = FeatureDescriptorType::ORB_DESC;
		img_width = IMG_WIDTH;
		img_height = IMG_HEIGHT;
	}

	virtual bool InternalParse()
	{

		if (_params.find("intr") != _params.end()) {
			intr_filepath = _params["intr"];
		} else {
			errMessage = "intrinsic parameter path was not specified";
			return false;
		}
		if (_params.find("extr") != _params.end()) {
			extr_filepath = _params["extr"];
		}

		if (_params.find("input") != _params.end()) {
			input_filepath = _params["input"];
			ParseInputData();
		} else {
			errMessage = "input filepath was not specified";
			return false;
		}

		if (_params.find("output") != _params.end()) {
			output_dirpath = _params["output"];
		} else {
			errMessage = "output directory was not specified";
			return false;
		}


		if (_params.find("det") != _params.end()) {
			if (_params["det"] == "fast")
				det_type = FAST_DET;
			else if (_params["det"] == "orb")
				det_type = ORB_DET;
			else if (_params["det"] == "mser")
				det_type = MSER_DET;
		}
		if (_params.find("desc") != _params.end()) {
			if (_params["desc"] == "orb")
				desc_type = ORB_DESC;
			else if (_params["desc"] == "freak")
				desc_type = FREAK_DESC;
			else if (_params["desc"] == "brief")
				desc_type = BRIEF_DESC;
			else if (_params["desc"] == "brisk")
				desc_type = BRISK_DESC;
		}

		if (_params.find("width") != _params.end()) {
			img_width = atoi(_params["width"].c_str());
		}
		if (_params.find("height") != _params.end()) {
			img_height = atoi(_params["height"].c_str());
		}

		return true;
	}

	virtual string Usage()
	{
		stringstream s;
		s<<Parameters::Usage();
		s<<"\t -intr input intrinsic file path (must be specified)"<<endl;
		s<<"\t -extr input ground truth extrinsic file path (optional)"<<endl;
		s<<"\t -input input data file path. format <id>\t<left_right_pair_image_list(left_1.png:right_1.png, left_2.png:right_2.png , ...)> (must be specified)"<<endl;
		s<<"\t -output output directory path (must be specified)"<<endl;
		s<<"\t -det detector type [fast|orb|mser] (default: fast)"<<endl;
		s<<"\t -desc descriptor type [orb|freak|brief|brisk] (default: orb)"<<endl;
		s<<"\t -height image height in pixels (default: 720 pixels)"<<endl;
		s<<"\t -width image width in pixels (default: 1280 pixels)"<<endl;
		return s.str();
	}

	 void ParseInputData()
	 {
		 ifstream ifs(input_filepath.c_str(), std::ios_base::in);
		 string line;
		 while(ifs.good())
		 {
			 InputData data;
			 getline(ifs, line);
			 if(line == "")
				 continue;
			 vector<string> parts = StringProc::Split(line, '\t');
			 data.id = parts[0];
			 vector<string> left_right_imgs = StringProc::Split(parts[1], ',');
			 for(int i = 0; i < left_right_imgs.size(); ++i)
			 {
				 vector<string> imgs = StringProc::Split(left_right_imgs[i], ':');
				 data.left_right_imgs.push_back(std::make_pair(imgs[0], imgs[1]));
			 }
			 input_data.push_back(data);
		 }
		 ifs.close();
	 }

};
#endif /* AUTOCALIBPARAM_H_ */
