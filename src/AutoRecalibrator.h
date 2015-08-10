/*============================================================================
 * File Name   : AutoRecalibrator.h
 * Author      : Yang Cai
 * Version     : 0.1
 * Copyright   : Copyright 2014 DeepGlint Inc.
 * Created on  : 3/14/2015
 * Description :
 * ==========================================================================*/

#ifndef AUTO_RECALIBRATOR_H
#define AUTO_RECALIBRATOR_H

#include "opencv2/core/core.hpp"
#include "opencv2/features2d/features2d.hpp"
#include "opencv2/calib3d/calib3d.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "FeatureExtractor.h"
#include "CorrespondenceDetector.h"
#include "levmar.h"
#include <string>
#include <vector>
#include <stdio.h>

using namespace std;
using namespace cv;

#define EPIPOLAR_CONSTRAIN_THRD 20
#define DISTR_GRID_WIDTH 3
#define DISTR_GRID_HEIGHT 2
#define DISTR_CORRES_MIN_SIZE 1
#define DISTR_CORRES_MAX_SIZE 500
#define MIN_RECT_IMG_PAIR_SIZE 2
#define MAX_RECT_IMG_PAIR_SIZE 20
#define MIN_VALID_IMG_PAIR_SIZE 2
#define MAX_VALID_IMG_PAIR_SIZE 5
#define MAX_EPI_ERR 1.0

#define RECALIB_ERR_NO_NEED 0
#define RECALIB_ERR_NO_EQUAL_DATA -1
#define RECALIB_ERR_NO_ENOUGH_DATA -2
#define RECALIB_ERR_RECAL_FAILED -3
#define RECALIB_ERR_LARGER_EPIERR -4

// force a view (i.e. left/right/none) to fix and rotate the other only for recalibration (this may avoid overfitting)
enum FixView {
	FIX_NONE, FIX_LEFT, FIX_RIGHT, FIX_HALF
};

struct EpiErrOptData {
	Mat corres_left; 	// homogeneous coordinates correspondences
	Mat corres_right;	// homogeneous coordinates correspondences
	Mat K_left;				// intrinsic parameters
	Mat K_right;				// intrinsic parameters
	int corres_ct; 		// number of correspondences
};

Mat AxisRotation(char axis, double angle);
void EpipolarError(double *p, double *x, int m, int n, void *data);

class AutoRecalibrator {
public:

	AutoRecalibrator(int _img_width, int _img_height,
			FeatureDetectorType _det_type = FAST_DET,
			FeatureDescriptorType _desc_type = ORB_DESC,
			FeatureDetectorParam* _det_param = new FASTFeatureDetectorParam(),
			FeatureDescriptorParam* _desc_param =
					new ORBFeatureDescriptorParam(),
			CorresDetectorType _corres_type = HOMOGRAPHY,
			int _epipolar_constrian_thrd = EPIPOLAR_CONSTRAIN_THRD,
			bool _corres_balancing = true) :
			img_width(_img_width), img_height(_img_height), det_type(_det_type), desc_type(
					_desc_type), det_param(_det_param), desc_param(_desc_param), corres_type(
					_corres_type), epipolar_constrian_thrd(
					_epipolar_constrian_thrd), corres_balancing(
					_corres_balancing) {
		feat_extractor = new FeatureExtractor(det_type, desc_type, det_param,
				desc_param);
		corres_detector = new HomographyRansacCorresDetector();
		corres_distr = vector<vector<int> >(DISTR_GRID_HEIGHT,
				vector<int>(DISTR_GRID_WIDTH, 0));
		Clear();
	}
	virtual ~AutoRecalibrator() {
		if (feat_extractor != NULL) {
			delete feat_extractor;
			feat_extractor = NULL;
		}
		if (corres_detector != NULL) {
			delete corres_detector;
			corres_detector = NULL;
		}
		if (det_param != NULL) {
			delete det_param;
			det_param = NULL;
		}
		if (desc_param != NULL) {
			delete desc_param;
			desc_param = NULL;
		}
		Clear();
	}
	/*
	 * @function    AutoRecalibration
	 * @abstract    A full wrapper for auto recalibration
	 * @in param	imgs_rect_left/imgs_rect_left	a vector of *rectified* image pairs.
	 *  											The size of the two vectors should be
	 *  											the same and *greater* than the MIN_RECT_IMG_PAIR_SIZE.
	 * @in param	post_validation     			if post validation is needed
	 * 												(i.e. validate the new rotation matrices give better results)
	 * @in param	imgs_orig_left/imgs_orig_left	a vector of *original* image pairs.
	 * 												(only needed when post_validation == true)
	 *  											The size of the two vectors should be
	 *  											the same and *greater* than the MIN_VALID_IMG_PAIR_SIZE.
	 * @in param	K_left/K_right 					3x3 intrinsic camera matrices
	 * 												(only needed when post_validation == true)
	 * @in param	d_left/d_right 					intrinsic distortion matrices
	 * 												(only needed when post_validation == true)
	 * @in param	R_left/R_right 					3x3 rotation matrices that given by stereoRectify (R1, R2)
	 * @in param	P_left/P_right 					3x4 projection matrices in the rectified camera system
	 * 												given by stereoRectify (P1, P2)
	 * @out param	R_new 							new 3x3 rotation matrices between two cameras (before rectification)
	 * @out param	T_new 							new 3x1 translation vector between two cameras (before rectification)
	 * @out param	Q_new 							new 4x4 disparity-to-depth mapping matrix
	 * @out param	R_left_new/R_right_new 			new 3x3 rotation matrices to rectify left and right cameras
	 * @out param	P_left_new/P_right_new 			new 3x4 projection matrices in the rectified camera system
	 * @out param	roi_left_new/roi_right_new		new ROI of the left and right cameras
	 * @out param	epi_err_orig/epi_err_new 		original and new epipolar error
	 * @in param	epi_err_thrd 					max acceptable epipolar error
	 * @return      error code(int)					AutoRecalibration is successful if greater.
	 * 												Zero means no need to recalibrate
	 */
	int AutoRecalibration(const vector<Mat>& imgs_rect_left,
			const vector<Mat>& imgs_rect_right,
			const vector<Mat>& imgs_orig_left,
			const vector<Mat>& imgs_orig_right, const Mat& K_left,
			const Mat& K_right, const Mat& d_left, const Mat& d_right,
			const Mat& R_left, const Mat& R_right, const Mat& P_left,
			const Mat& P_right, Mat& R_new, Mat& T_new, Mat& Q_new,
			Mat& R_left_new, Mat& R_right_new, Mat& P_left_new,
			Mat& P_right_new, cv::Rect& roi_left_new, cv::Rect& roi_right_new,
			double& epi_err_orig, double& epi_err_new, double epi_err_thrd =
			MAX_EPI_ERR, bool post_validation = true);
	double EvalEpipolarError(const vector<Mat>& imgs_rect_left,
			const vector<Mat>& imgs_rect_right);
	// add initial rectified image pairs. THIS FUNCTION SHOULD BE CALLED WHEN TRYING TO START A NEW CALIBRATION.
	bool InitRectifiedImagePairs(const vector<Mat>& left_rect_imgs,
			const vector<Mat>& right_rect_imgs);
	// add more rectified image pairs. THIS FUNCTION SHOULD *NOT* BE CALLED WHEN TRYING TO START A NEW CALIBRATION.
	bool AddRectifiedImagePairs(const vector<Mat>& left_rect_imgs,
			const vector<Mat>& right_rect_imgs);
	bool IsReadyToRecalib();
	double GetEpipolarError();
	float GetCorresSize();
	vector<vector<int> > GetCorresDistr();
	void Clear();

	bool ReCalibration(const Mat& K_left, const Mat& K_right,
			const Mat& R_left_orig, const Mat& R_right_orig, Mat& R_left_new,
			Mat& R_right_new);

private:

	void RectifyImage(const Mat& img_orig, Mat& img_rect, const Mat& R,
			const Mat& K, const Mat& d, const Mat& P);
	bool CalcCorrespondences(const Mat& img_left, const Mat& img_right,
			vector<Point2f>& corres_left, vector<Point2f>& corres_right);

	bool BalanceCorresDistribution(vector<Point2f>& corres_left,
			vector<Point2f>& corres_right);

	FeatureDetectorType det_type;
	FeatureDescriptorType desc_type;
	FeatureDetectorParam* det_param;
	FeatureDescriptorParam* desc_param;
	CorresDetectorType corres_type;
	FeatureExtractor* feat_extractor;
	CorrespondenceDetector* corres_detector;
	vector<Point2f> corres_left, corres_right;
	vector<vector<int> > corres_distr;
	Mat gray_img_left, gray_img_right;
	int epipolar_constrian_thrd;
	bool corres_balancing;
	bool ready_to_recalib;
	int img_width;
	int img_height;
};

#endif
