/*============================================================================
 * File Name   : StereoVisualizeUtils.h
 * Author      : Yang Cai
 * Version     : 0.1
 * Copyright   : Copyright 2014 DeepGlint Inc.
 * Created on  : 3/14/2015
 * Description :
 * ==========================================================================*/

#ifndef STEREO_VISUALIZE_UTILS_H
#define STEREO_VISUALIZE_UTILS_H

#include "opencv2/core/core.hpp"
#include "opencv2/features2d/features2d.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <string>
#include <vector>

using namespace std;
using namespace cv;

void DrawEpiLines(int event, int x, int y, int flags, void* p);
Mat& DrawRoI(Mat& img, const Rect& roi);
Mat& DrawGrids(Mat& img, int step = 64);
void VisualizeCorres(const Mat& img_left, const Mat& img_right,
		const vector<Point2f>& corres_left,
		const vector<Point2f>& corres_right);
Mat VisualizeRectResults(const vector<Mat>& imgs_left,
		const vector<Mat>& imgs_right, bool is_show = true);

void VisualizeKeypoints(const Mat& img, const vector<KeyPoint>& keypoints);

#endif
