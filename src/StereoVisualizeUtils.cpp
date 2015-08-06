/*============================================================================
 * File Name   : StereoVisualizeUtils.cpp
 * Author      : Yang Cai
 * Version     : 0.1
 * Copyright   : Copyright 2014 DeepGlint Inc.
 * Created on  : 3/14/2015
 * Description :
 * ==========================================================================*/


#include "StereoVisualizeUtils.h"
#include <stdio.h>
using namespace std;
using namespace cv;

void DrawEpiLines(int event, int x, int y, int flags,
		void* p) {

	Mat* img = (Mat*)p;
	if (event == EVENT_LBUTTONDOWN) {
		line(*img, Point(0, y), Point(img->cols, y), Scalar(0, 255, 0), 1, 8);
	} else if (event == EVENT_RBUTTONUP) {
		exit(0);
	}
	imshow("rectified", *img);
}

void VisualizeCorres(const Mat& img_left, const Mat& img_right,
		const vector<Point2f>& corres_left, const vector<Point2f>& corres_right) {
	Mat canvas, canvas_resz;
	Size img_sz = img_left.size();
	canvas.create(img_sz.height, img_sz.width * 2, CV_8UC3);
	canvas_resz.create(cvRound(canvas.rows * 0.5), cvRound(canvas.cols * 0.5),
	CV_8UC3);

	img_left.copyTo(canvas(Rect(0, 0, img_sz.width, img_sz.height)));
	img_right.copyTo(
			canvas(Rect(img_sz.width, 0, img_sz.width, img_sz.height)));

	for (int i = 0; i < corres_left.size(); ++i) {
		line(canvas, Point(corres_left[i].x, corres_left[i].y),
				Point(corres_right[i].x + img_sz.width, corres_right[i].y),
				Scalar(0, 255, 0), 1, 8);
		resize(canvas, canvas_resz, canvas_resz.size(), 0, 0, CV_INTER_AREA);
		imshow("correspondences", canvas_resz);

	}
	cvWaitKey(0);

}

Mat& DrawRoI(Mat& img, const Rect& roi) {
	rectangle(img, roi, Scalar(0, 0, 255), 2, 8);
	return img;
}

Mat& DrawGrids(Mat& img, int step)
{
	for (int j = 0; j < img.rows; j += step)
		line(img, Point(0, j), Point(img.cols, j), Scalar(0, 255, 0), 1, 8);
	for (int j = 0; j < img.cols; j += step)
		line(img, Point(j, 0), Point(j, img.rows), Scalar(0, 255, 0), 1, 8);
	return img;
}

Mat VisualizeRectResults(const vector<Mat>& imgs_left, const vector<Mat>& imgs_right, bool is_show)
{
	// show the results
	Mat canvas, canvas_resz;
	int img_ct = imgs_left.size();
	Size img_sz = imgs_left[0].size();
	canvas.create(img_sz.height * img_ct, img_sz.width * 2, CV_8UC3);
	canvas_resz.create(cvRound(canvas.rows * 0.4), cvRound(canvas.cols * 0.4), CV_8UC3);
	for(int i = 0; i < img_ct; ++i)
	{
		imgs_left[i].copyTo(canvas(Rect(0, i * img_sz.height, img_sz.width, img_sz.height)));
		imgs_right[i].copyTo(canvas(Rect(img_sz.width, i * img_sz.height, img_sz.width, img_sz.height)));
	}
	resize(canvas, canvas_resz, canvas_resz.size(), 0, 0, CV_INTER_AREA);
	if (is_show) {
		imshow("rectified", canvas_resz);
		setMouseCallback("rectified", DrawEpiLines, &canvas_resz);
		cvWaitKey(0);
	}
	return canvas_resz;
}

void VisualizeKeypoints(const Mat& img, const vector<KeyPoint>& keypoints)
{
	Mat canvas, canvas_resz;

	img.copyTo(canvas);
	canvas_resz.create(cvRound(canvas.rows * 0.5), cvRound(canvas.cols * 0.5),
			CV_8UC3);
	printf("%d\n", keypoints.size());
	for(int i = 0; i < keypoints.size(); ++i)
	{
		circle(canvas, Point(keypoints[i].pt.x, keypoints[i].pt.y), 3, Scalar(255, 255, 255));
	}
	resize(canvas, canvas_resz, canvas_resz.size(), 0, 0, CV_INTER_AREA);
	imshow("keypoints", canvas_resz);
	cvWaitKey(0);
}
