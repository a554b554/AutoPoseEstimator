/*============================================================================
 * File Name   : FeatureExtractor.cpp
 * Author      : Yang Cai
 * Version     : 0.1
 * Copyright   : Copyright 2014 DeepGlint Inc.
 * Created on  : 3/14/2015
 * Description :
 * ==========================================================================*/

#include "FeatureExtractor.h"

using namespace std;
using namespace cv;

bool FeatureExtractor::DetectAndExtract(const Mat& gray_img,
		vector<KeyPoint>& keypoints, Mat& descrptors) {
	if (descriptor == NULL || detector == NULL)
		return false;
	Detect(gray_img, keypoints);
	if(keypoints.size() == 0)	// no keypoint can be extracted.
		return false;
	Extract(gray_img, keypoints, descrptors);
	return true;
}
bool FeatureExtractor::Extract(const Mat& gray_img, vector<KeyPoint>& keypoints,
		Mat& descrptors) {
	if (descriptor == NULL)
		return false;
	descriptor->compute(gray_img, keypoints, descrptors);
	return true;
}
bool FeatureExtractor::Detect(const Mat& gray_img,
		vector<KeyPoint>& keypoints) {
	if (detector == NULL)
		return false;
	detector->detect(gray_img, keypoints);
	return true;
}

