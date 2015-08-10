/*
 * cpu_sncc.cpp
 *
 *  Created on: Oct 24, 2014
 *      Author: xinyi, Yang Cai
 */

#ifndef CPU_SNCC_H_
#define CPU_SNCC_H_

#include <fstream>
#include <string.h>
#include <stdlib.h>
#include <float.h>
#include <stdio.h>
#include <opencv/cv.h>
#include <opencv/highgui.h>
#include <sys/time.h>
#include <time.h>

#define WINDOW_SIZE 11
#define DMIN 0
#define DMAX 128

using namespace std;
using namespace cv;


class CpuSNCC
{
public:
	static Mat Process(Mat img_left, Mat img_right);
private:
	static int image_width;
	static int image_height;
	static Mat g_disp_r;
	static Mat g_conf_r;
	static void StereoSNCC(const Mat& left, const Mat& right, const int window_size, const int dmin, const int dmax, Mat& disp,
	  Mat& conf);
	static void CrossCheck(const Mat& left, const Mat& right, const float conf_threshold, Mat& checked);
	static void ConfidenceCheck(const Mat& conf_left, const Mat& conf_right, const float conf_threshold, const Mat& checked,
	  Mat& confidenced);
	static void FloatRGB2Jet(const Mat& in, Mat& out);

};



#endif
