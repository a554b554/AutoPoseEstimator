/*============================================================================
 * File Name   : CorrespondenceDetector.cpp
 * Author      : Yang Cai
 * Version     : 0.1
 * Copyright   : Copyright 2014 DeepGlint Inc.
 * Created on  : 3/14/2015
 * Description :
 * ==========================================================================*/

#include "CorrespondenceDetector.h"
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
using namespace std;
using namespace cv;

void HomographyRansacCorresDetector::Detect(
		const vector<KeyPoint>& src_keypoints,
		const vector<KeyPoint>& dest_keypoints, const Mat& src_descrpt,
		const Mat& dest_descrpt, vector<Point2f>& corres_left,
		vector<Point2f>& corres_right) {
	vector<Point2f> corres_left_tmp, corres_right_tmp;
	std::vector<DMatch> matches;
	BFMatcher matcher(dist_type, true);
	matcher.match(src_descrpt, dest_descrpt, matches);
	for (unsigned int i = 0; i < matches.size(); i++) {
		corres_left_tmp.push_back(src_keypoints[matches[i].queryIdx].pt);
		corres_right_tmp.push_back(dest_keypoints[matches[i].trainIdx].pt);
	}
	CorresRefineByHomographyRANSAC(corres_left_tmp, corres_right_tmp,
			corres_left, corres_right);

}

void HomographyRansacCorresDetector::CorresRefineByHomographyRANSAC(
		vector<Point2f>& corres_left, vector<Point2f>& corres_right,
		vector<Point2f>& corres_left_ref, vector<Point2f>& corres_right_ref) {

	int match_sz = 0, nonmatch_sz = 0;
	Mat mask;
	if(corres_left.size() < MIN_CORRES_RANSAC_SIZE)
		return;
	do {
		findHomography(Mat(corres_left), Mat(corres_right), CV_RANSAC,
				reproj_err_thrd, mask);
		vector<Point2f> match_left, match_right, nonmatch_left, nonmatch_right;
		match_sz = 0;
		nonmatch_sz = 0;
		for (int i = 0; i < mask.rows; ++i) {
			if (mask.at<uchar>(i, 0)) {
				match_left.push_back(corres_left[i]);
				match_right.push_back(corres_right[i]);
				match_sz++;
			} else {
				nonmatch_left.push_back(corres_left[i]);
				nonmatch_right.push_back(corres_right[i]);
				nonmatch_sz++;
			}
		}
		if (match_sz >= MIN_CORRES_RANSAC_SIZE) {
			//corres_left_ref.push_back(match_left);
			//corres_right_ref.push_back(match_right);
			corres_left_ref.insert(corres_left_ref.end(), match_left.begin(),
					match_left.end());
			corres_right_ref.insert(corres_right_ref.end(), match_right.begin(),
					match_right.end());
			corres_left = nonmatch_left;
			corres_right = nonmatch_right;
		} else
			break;
	} while (seq_ransac && nonmatch_sz >= min_ransac_accept_size);

}

void CorrespondenceDetector::checkMatch(const Mat &imgl, const Mat &imgr, const vector<Point2f> &corresl, const vector<Point2f> &corresr){
    Mat dst(imgl.rows,imgl.cols+imgr.cols,CV_8UC1);
    Rect roil(0,0,imgl.cols,imgl.rows);
    Rect roir(imgl.cols,0,imgr.cols,imgr.rows);
    imgl.copyTo(dst(roil));
    imgr.copyTo(dst(roir));
    cvtColor(dst,dst,CV_GRAY2BGR);
    for(int i = 0; i < corresl.size(); i++){
        line(dst,corresl[i],Point2f(corresr[i].x+imgl.cols,corresr[i].y),CV_RGB(rand()*123,rand()*147,rand()*255));

    }
    imshow("corres",dst);

}
