/*============================================================================
 * File Name   : FeatureExtractor.h
 * Author      : Yang Cai
 * Version     : 0.1
 * Copyright   : Copyright 2014 DeepGlint Inc.
 * Created on  : 3/14/2015
 * Description :
 * ==========================================================================*/

#ifndef FEATURE_EXTRACTOR_H
#define FEATURE_EXTRACTOR_H

#define FAST_INTENSITY_DIFF_THRD 20

#include "opencv2/core/core.hpp"
#include "opencv2/features2d/features2d.hpp"
#include <string>
#include <vector>
#include <iostream>

using namespace std;
using namespace cv;

enum FeatureDetectorType {
	FAST_DET, ORB_DET, MSER_DET, DONOT_DET
};

enum FeatureDescriptorType {
	ORB_DESC, BRISK_DESC, BRIEF_DESC, FREAK_DESC, DONOT_DESC
};

class FeatureDetectorParam {
public:
	FeatureDetectorParam() {
	}
};

class FeatureDescriptorParam {
public:
	FeatureDescriptorParam() {
	}

};

class FASTFeatureDetectorParam: public FeatureDetectorParam {
public:
	int intensity_diff_thrd;
	bool non_max_supression;
	FASTFeatureDetectorParam(int thrd = FAST_INTENSITY_DIFF_THRD,
			bool _non_max_supression = true) :
			intensity_diff_thrd(thrd), non_max_supression(_non_max_supression) {
	}
};

class ORBFeatureDescriptorParam: public FeatureDescriptorParam {
public:
	int nfeatures;
	float scaleFactor;
	int nlevels;
	int edgeThreshold;
	int firstLevel;
	int WTA_K;
	int scoreType;
	int patchSize;
	ORBFeatureDescriptorParam(int _nfeatures = 2000, float _scaleFactor = 2,
			int _nlevels = 8, int _edgeThreshold = 31, int _firstLevel = 0,
			int _WTA_K = 2, int _scoreType = ORB::HARRIS_SCORE, int _patchSize =
					31) {
		nfeatures = _nfeatures;
		scaleFactor = _scaleFactor;
		nlevels = _nlevels;
		edgeThreshold = _edgeThreshold;
		firstLevel = _firstLevel;
		WTA_K = _WTA_K;
		scoreType = _scoreType;
		patchSize = _patchSize;
	}

};

class ORBFeatureDetectorParam: public FeatureDetectorParam {
public:
	int nfeatures;
	float scaleFactor;
	int nlevels;
	int edgeThreshold;
	int firstLevel;
	int WTA_K;
	int scoreType;
	int patchSize;
	ORBFeatureDetectorParam(int _nfeatures = 2000, float _scaleFactor = 2,
			int _nlevels = 8, int _edgeThreshold = 31, int _firstLevel = 0,
			int _WTA_K = 2, int _scoreType = ORB::HARRIS_SCORE, int _patchSize =
					31) {
		nfeatures = _nfeatures;
		scaleFactor = _scaleFactor;
		nlevels = _nlevels;
		edgeThreshold = _edgeThreshold;
		firstLevel = _firstLevel;
		WTA_K = _WTA_K;
		scoreType = _scoreType;
		patchSize = _patchSize;
	}

};

class MSERFeatureDetectorParam: public FeatureDetectorParam {
public:
	int delta;
	int min_area;
	int max_area;
	double max_variation;
	double min_diversity;
	int max_evolution;
	double area_threshold;
	double min_margin;
	MSERFeatureDetectorParam(int _delta = 5, int _min_area = 60, int _max_area =
			14400, double _max_variation = 0.25, double _min_diversity = .2,
			int _max_evolution = 200, double _area_threshold = 1.01,
			double _min_margin = 0.003, int _edge_blur_size = 5) {
		delta = _delta;
		min_area = _min_area;
		max_area = _max_area;
		max_variation = _max_variation;
		min_diversity = _min_diversity;
		max_evolution = _max_evolution;
		area_threshold = _area_threshold;
		min_margin = _min_margin;

	}

};

class FeatureExtractor {
public:

	FeatureExtractor(FeatureDetectorType det_type,
			FeatureDescriptorType desc_type, FeatureDetectorParam* det_param,
			FeatureDescriptorParam* desc_param) {
		detector = NULL;
		descriptor = NULL;

        if (det_type == FAST_DET) {

			FASTFeatureDetectorParam* param =
					(FASTFeatureDetectorParam*) det_param;
			detector = new FastFeatureDetector(param->intensity_diff_thrd,
					param->non_max_supression);
        } else if (det_type == ORB_DET) {
			ORBFeatureDetectorParam* param =
					(ORBFeatureDetectorParam*) det_param;
			detector = new ORB(param->nfeatures, param->scaleFactor,
					param->nlevels, param->edgeThreshold, param->firstLevel,
					param->WTA_K, param->scoreType, param->patchSize);
        } else if (det_type == MSER_DET) {
			MSERFeatureDetectorParam* param =
					(MSERFeatureDetectorParam*) det_param;
			detector = new MSER(param->delta, param->min_area, param->max_area,
					param->max_variation, param->min_diversity,
					param->max_evolution, param->area_threshold,
					param->min_margin);
		}

        if (desc_type == ORB_DESC) {
			ORBFeatureDescriptorParam* param =
					(ORBFeatureDescriptorParam*) desc_param;
			descriptor = new ORB(param->nfeatures, param->scaleFactor,
					param->nlevels, param->edgeThreshold, param->firstLevel,
					param->WTA_K, param->scoreType, param->patchSize);
        } else if (desc_type == BRISK_DESC) {
			descriptor = new BRISK();
        } else if (desc_type == FREAK_DESC) {
			descriptor = new FREAK();
        } else if (desc_type == BRIEF_DESC) {
			descriptor = new BriefDescriptorExtractor();
		}

	}

	virtual ~FeatureExtractor() {
		if (detector != NULL) {
			delete detector;
			detector = NULL;
		}
		if (descriptor != NULL) {
			delete descriptor;
			descriptor = NULL;
		}
	}
	bool DetectAndExtract(const Mat& gray_img, vector<KeyPoint>& keypoints,
			Mat& descrptors);
	bool Extract(const Mat& gray_img, vector<KeyPoint>& keypoints,
			Mat& descrptors);
	bool Detect(const Mat& gray_img, vector<KeyPoint>& keypoints);
private:
	FeatureDetector* detector;
	DescriptorExtractor* descriptor;
};

#endif
