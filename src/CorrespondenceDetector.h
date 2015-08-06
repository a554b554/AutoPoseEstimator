/*============================================================================
 * File Name   : CorrespondenceDetector.h
 * Author      : Yang Cai
 * Version     : 0.1
 * Copyright   : Copyright 2014 DeepGlint Inc.
 * Created on  : 3/14/2015
 * Description :
 * ==========================================================================*/

#ifndef CORRESPONDENCE_DETECTOR_H
#define CORRESPONDENCE_DETECTOR_H

#define H_REPORJ_ERR_THRD 1.5
#define MIN_CORRES_RANSAC_SIZE 20
#define USE_SEQ_CORRES_RANSAC 1

#include "opencv2/core/core.hpp"
#include "opencv2/features2d/features2d.hpp"
#include "opencv2/calib3d/calib3d.hpp"

#include <string>
#include <vector>

using namespace std;
using namespace cv;

enum CorresDetectorType{
	BRUTE_FORCE, HOMOGRAPHY
};

class CorrespondenceDetector {
public:
	virtual ~CorrespondenceDetector(){}
	virtual void Detect(const vector<KeyPoint>& src_keypoints,
			const vector<KeyPoint>& dest_keypoints, const Mat& src_descrpt,
			const Mat& dest_descrpt, vector<Point2f>& corres_left,
			vector<Point2f>& corres_right) = 0;
    static void checkMatch(const Mat& imgl, const Mat& imgr,
                           const vector<Point2f>& corresl,
                           const vector<Point2f>& corresr);
};

class HomographyRansacCorresDetector: public CorrespondenceDetector {
public:

	HomographyRansacCorresDetector(int _dist_type = NORM_HAMMING,
			float _reproj_err_thrd = H_REPORJ_ERR_THRD,
			int _min_ransac_accept_size = MIN_CORRES_RANSAC_SIZE,
			bool _seq_ransac = true) :
			dist_type(_dist_type), reproj_err_thrd(_reproj_err_thrd), min_ransac_accept_size(
					_min_ransac_accept_size), seq_ransac(_seq_ransac) {
	}
	virtual ~HomographyRansacCorresDetector(){}
	virtual void Detect(const vector<KeyPoint>& src_keypoints,
			const vector<KeyPoint>& dest_keypoints, const Mat& src_descrpt,
			const Mat& dest_descrpt, vector<Point2f>& corres_left,
			vector<Point2f>& corres_right);
private:
	int dist_type;
	float reproj_err_thrd;
	int min_ransac_accept_size;
	bool seq_ransac;

	void CorresRefineByHomographyRANSAC(vector<Point2f>& corres_left,
			vector<Point2f>& corres_right, vector<Point2f>& corres_left_ref,
			vector<Point2f>& corres_right_ref);

};


#endif
