/*============================================================================
 * File Name   : AutoRecalibrator.cpp
 * Author      : Yang Cai
 * Version     : 0.1
 * Copyright   : Copyright 2014 DeepGlint Inc.
 * Created on  : 3/14/2015
 * Description :
 * ==========================================================================*/

#include "AutoRecalibrator.h"

using namespace std;
using namespace cv;
#include <glog/logging.h>

Mat AxisRotation(char axis, double angle) {
	if (axis == 'x')
		return (Mat_<double>(3, 3) << 1, 0, 0, 0, cos(angle), -sin(angle), 0, sin(
				angle), cos(angle));

	else if (axis == 'y')
		return (Mat_<double>(3, 3) << cos(angle), 0, sin(angle), 0, 1, 0, -sin(
				angle), 0, cos(angle));

	else if (axis == 'z')
		return (Mat_<double>(3, 3) << cos(angle), -sin(angle), 0, sin(angle), cos(
				angle), 0, 0, 0, 1);
}

void EpipolarError(double *p, double *x, int m, int n, void *data) {

	EpiErrOptData* epi_opt_data = (EpiErrOptData*) data;
	double lamda = p[0], beta_l = p[1], beta_r = p[2], alpha_l = p[3], alpha_r =
			p[4];
	Mat Rc_left = AxisRotation('x', lamda / 2) * AxisRotation('z', beta_l)
			* AxisRotation('y', alpha_l);
	Mat Rc_right = AxisRotation('x', -lamda / 2) * AxisRotation('z', beta_r)
			* AxisRotation('y', alpha_r);
	Mat rc_left_2 = (Mat_<double>(1, 3) << Rc_left.at<double>(1, 0), Rc_left.at<
			double>(1, 1), Rc_left.at<double>(1, 2));
	Mat rc_left_3 = (Mat_<double>(1, 3) << Rc_left.at<double>(2, 0), Rc_left.at<
			double>(2, 1), Rc_left.at<double>(2, 2));
	Mat rc_right_2 =
			(Mat_<double>(1, 3) << Rc_right.at<double>(1, 0), Rc_right.at<double>(
					1, 1), Rc_right.at<double>(1, 2));
	Mat rc_right_3 =
			(Mat_<double>(1, 3) << Rc_right.at<double>(2, 0), Rc_right.at<double>(
					2, 1), Rc_right.at<double>(2, 2));

	Mat K_left_inv = epi_opt_data->K_left.inv();
	Mat K_right_inv = epi_opt_data->K_right.inv();
	double f_left = epi_opt_data->K_left.at<double>(0, 0);
	double f_right = epi_opt_data->K_right.at<double>(0, 0);
	Mat rc_left_2_K_inv = rc_left_2 * K_left_inv;
	Mat rc_left_3_K_inv = rc_left_3 * K_left_inv;
	Mat rc_right_2_K_inv = rc_right_2 * K_right_inv;
	Mat rc_right_3_K_inv = rc_right_3 * K_right_inv;

	double err_l = 0, err_r = 0, err = 0;
	for (int i = 0; i < n; ++i) {
		err_l = (rc_left_2_K_inv.dot(epi_opt_data->corres_left.row(i)))
				/ (rc_left_3_K_inv.dot(epi_opt_data->corres_left.row(i)));
		err_r = (rc_right_2_K_inv.dot(epi_opt_data->corres_right.row(i)))
				/ (rc_right_3_K_inv.dot(epi_opt_data->corres_right.row(i)));
		err = f_left * err_l - f_right * err_r;
		x[i] = err;
	}
}

double AutoRecalibrator::EvalEpipolarError(const vector<Mat>& imgs_rect_left,
		const vector<Mat>& imgs_rect_right) {
	InitRectifiedImagePairs(imgs_rect_left, imgs_rect_right);
	return GetEpipolarError();
}

void AutoRecalibrator::RectifyImage(const Mat& img_orig, Mat& img_rect,
		const Mat& R, const Mat& K, const Mat& d, const Mat& P) {
	Mat rmap[2];
	initUndistortRectifyMap(K, d, R, P, img_orig.size(), CV_16SC2, rmap[0],
			rmap[1]);
	remap(img_orig, img_rect, rmap[0], rmap[1], CV_INTER_LINEAR);
}

int AutoRecalibrator::AutoRecalibration(const vector<Mat>& imgs_rect_left,
		const vector<Mat>& imgs_rect_right, const vector<Mat>& imgs_orig_left,
		const vector<Mat>& imgs_orig_right, const Mat& K_left,
		const Mat& K_right, const Mat& d_left, const Mat& d_right,
		const Mat& R_left, const Mat& R_right, const Mat& P_left,
		const Mat& P_right, Mat& R_new, Mat& T_new, Mat& Q_new, Mat& R_left_new,
		Mat& R_right_new, Mat& P_left_new, Mat& P_right_new, Rect& roi_left_new,
		Rect& roi_right_new, double& epi_err_old, double& epi_err_new,
		double epi_err_thrd, bool post_validation) {
	// check if input data is valid
	if (imgs_rect_left.size() != imgs_rect_right.size())
		return RECALIB_ERR_NO_EQUAL_DATA;
	if (imgs_rect_left.size() < MIN_RECT_IMG_PAIR_SIZE)
		return RECALIB_ERR_NO_ENOUGH_DATA;
	Size img_sz = imgs_rect_left[0].size();

	// add first batch of data
	vector<Mat> imgs_rect_left_tmp(imgs_rect_left.begin(),
			imgs_rect_left.begin() + MIN_RECT_IMG_PAIR_SIZE);
	vector<Mat> imgs_rect_right_tmp(imgs_rect_right.begin(),
			imgs_rect_right.begin() + MIN_RECT_IMG_PAIR_SIZE);

	InitRectifiedImagePairs(imgs_rect_left_tmp, imgs_rect_right_tmp);

	epi_err_old = GetEpipolarError();
	if (epi_err_old < epi_err_thrd) // epipolar error is small enough and there is no need for recalibration
		return RECALIB_ERR_NO_NEED;

	if (!IsReadyToRecalib()) { // data is not enough
		int curr_img_idx = MIN_RECT_IMG_PAIR_SIZE;
		while (curr_img_idx < imgs_rect_left.size()) {
			imgs_rect_left_tmp.clear();
			imgs_rect_right_tmp.clear();
			vector<Mat> imgs_rect_left_tmp(
					imgs_rect_left.begin() + curr_img_idx,
					imgs_rect_left.begin() + curr_img_idx + 1);
			vector<Mat> imgs_rect_right_tmp(
					imgs_rect_right.begin() + curr_img_idx,
					imgs_rect_right.begin() + curr_img_idx + 1);
			AddRectifiedImagePairs(imgs_rect_left_tmp, imgs_rect_right_tmp);
			if (IsReadyToRecalib())
				break;
			curr_img_idx++;
		}
		if (!IsReadyToRecalib())	// data is used up
			return RECALIB_ERR_NO_ENOUGH_DATA;
	}
	if (!ReCalibration(P_left(Rect(0, 0, 3, 3)), P_right(Rect(0, 0, 3, 3)),
			R_left, R_right, R_left_new, R_right_new))	// run recalibration
		return RECALIB_ERR_RECAL_FAILED;	// recalibration is failed
	else {
		R_new = R_right_new.t() * R_left_new;	// must be in this order!!!
		T_new = R_right_new.t()
				* (P_right(Rect(3, 0, 1, 3)) / P_right.at<double>(0, 0));// P = [K, [-b * f; 0; 0]], need to divide by f!
		cv::stereoRectify(K_left, d_left, K_right, d_right, img_sz, R_new,
				T_new, R_left_new, R_right_new, P_left_new, P_right_new, Q_new,
				CV_CALIB_ZERO_DISPARITY, 1, img_sz, &roi_left_new,
				&roi_right_new);
	}
	if (post_validation) {
		// need to validate rectification gets better with new R
		if (imgs_orig_left.size() != imgs_orig_right.size())
			return RECALIB_ERR_NO_EQUAL_DATA;
		if (imgs_orig_left.size() < MIN_VALID_IMG_PAIR_SIZE)
			return RECALIB_ERR_NO_ENOUGH_DATA;

		vector<Mat> imgs_rect_left_new, imgs_rect_right_new;
		for (int i = 0; i < MIN_VALID_IMG_PAIR_SIZE; ++i) {
			Mat img_rect_left, img_rect_right;
			RectifyImage(imgs_orig_left[i], img_rect_left, R_left_new, K_left,
					d_left, P_left_new);
			RectifyImage(imgs_orig_right[i], img_rect_right, R_right_new,
					K_right, d_right, P_right_new);
			imgs_rect_left_new.push_back(img_rect_left);
			imgs_rect_right_new.push_back(img_rect_right);
		}
		epi_err_new = EvalEpipolarError(imgs_rect_left_new,
				imgs_rect_right_new);
		if (epi_err_new < epi_err_old)
			return true;
		else
			return RECALIB_ERR_LARGER_EPIERR;
	} else
		// no need to validate
		return true;
}

// add initial rectified image pairs. THIS FUNCTION SHOULD BE CALLED WHEN TRYING TO START A NEW CALIBRATION.
bool AutoRecalibrator::InitRectifiedImagePairs(
		const vector<Mat>& left_rect_imgs, const vector<Mat>& right_rect_imgs) {
	// clear first
	Clear();
	return AddRectifiedImagePairs(left_rect_imgs, right_rect_imgs);
}

// add more rectified image pairs. THIS FUNCTION SHOULD *NOT* BE CALLED WHEN TRYING TO START A NEW CALIBRATION.
bool AutoRecalibrator::AddRectifiedImagePairs(const vector<Mat>& left_rect_imgs,
		const vector<Mat>& right_rect_imgs) {
	vector<Point2f> corres_left_tmp, corres_right_tmp;
	for (int m = 0; m < left_rect_imgs.size(); ++m) {
		corres_left_tmp.clear();
		corres_right_tmp.clear();
		// find initial correspondences by using raw feature distance
		if (CalcCorrespondences(left_rect_imgs[m], right_rect_imgs[m],
				corres_left_tmp, corres_right_tmp) == true) {
			// keep only correspondences that satisfy the epipolar error constraint.
			float curr_err = 0;
			for (int i = 0; i < corres_left_tmp.size(); ++i) {
				curr_err = fabs(corres_left_tmp[i].y - corres_right_tmp[i].y);
				if (curr_err < epipolar_constrian_thrd) {
					corres_left.push_back(corres_left_tmp[i]);
					corres_right.push_back(corres_right_tmp[i]);
				}
			}
		}
	}
	if (corres_left.size() == 0 || corres_right.size() == 0)
		ready_to_recalib = false;
	else
		ready_to_recalib = BalanceCorresDistribution(corres_left, corres_right);
	return ready_to_recalib;
}
bool AutoRecalibrator::IsReadyToRecalib() {
	return ready_to_recalib;
}

double AutoRecalibrator::GetEpipolarError() {
	double err_sum = 0;
	for (int i = 0; i < corres_left.size(); ++i) {
		err_sum += fabs(corres_left[i].y - corres_right[i].y);
	}
	return err_sum * 1.0 / corres_left.size();
}

float AutoRecalibrator::GetCorresSize() {
	return corres_left.size();
}

void AutoRecalibrator::Clear() {
	corres_left.clear();
	corres_right.clear();
	ready_to_recalib = false;
}

vector<vector<int> > AutoRecalibrator::GetCorresDistr() {
	return corres_distr;
}

bool AutoRecalibrator::ReCalibration(const Mat& K_left, const Mat& K_right,
		const Mat& R_left_orig, const Mat& R_right_orig, Mat& R_left_new,
		Mat& R_right_new) {

	if (!ready_to_recalib)
		return false;

	// create the homogeneous correspondences matrix
	EpiErrOptData data;
	data.corres_left = Mat::ones(corres_left.size(), 3, CV_64FC1);
	data.corres_right = Mat::ones(corres_right.size(), 3, CV_64FC1);
	for (int i = 0; i < corres_left.size(); ++i) {
		data.corres_left.at<double>(i, 0) = corres_left[i].x;
		data.corres_left.at<double>(i, 1) = corres_left[i].y;
		data.corres_right.at<double>(i, 0) = corres_right[i].x;
		data.corres_right.at<double>(i, 1) = corres_right[i].y;
	}
	K_left.convertTo(data.K_left, CV_64F);
	K_right.convertTo(data.K_right, CV_64F);
	data.corres_ct = corres_left.size();

	// use levmar library (Levenbergh-Marquart) for optimization
	// http://users.ics.forth.gr/~lourakis/levmar/

	double info[LM_INFO_SZ];
	/* O: information regarding the minimization. Set to NULL if don't care
	 * info[0]= ||e||_2 at initial p.
	 * info[1-4]=[ ||e||_2, ||J^T e||_inf,  ||Dp||_2, \mu/max[J^T J]_ii ], all computed at estimated p.
	 * info[5]= # iterations,
	 * info[6]=reason for terminating: 1 - stopped by small gradient J^T e
	 *                                 2 - stopped by small Dp
	 *                                 3 - stopped by itmax
	 *                                 4 - singular matrix. Restart from current p with increased \mu
	 *                                 5 - no further error reduction is possible. Restart with increased mu
	 *                                 6 - stopped by small ||e||_2
	 *                                 7 - stopped by invalid (i.e. NaN or Inf) "func" values; a user error
	 * info[7]= # function evaluations
	 * info[8]= # Jacobian evaluations
	 * info[9]= # linear systems solved, i.e. # attempts for reducing error
	 */
	register int i;
	double opts[LM_OPTS_SZ];
	opts[0] = LM_INIT_MU;
	opts[1] = 1E-20;
	opts[2] = 1E-20;
	opts[3] = 1E-25;
	opts[4] = 1E-4; // relevant only if the Jacobian is approximated using finite differences; specifies forward differencing
	/* I: opts[0-4] = minim. options [\tau, \epsilon1, \epsilon2, \epsilon3, \delta]. Respectively the
	 * scale factor for initial \mu, stopping thresholds for ||J^T e||_inf, ||Dp||_2 and ||e||_2 and the
	 * step used in difference approximation to the Jacobian. If \delta<0, the Jacobian is approximated
	 * with central differences which are more accurate (but slower!) compared to the forward differences
	 * employed by default. Set to NULL for defaults to be used.
	 */
	double p[5];
	/* I/O: initial parameter estimates. On output contains the estimated solution */
	double* x = new double[data.corres_ct];
	/* I: measurement vector. NULL implies a zero vector */
	int m = 5;
	/* I: parameter vector dimension (i.e. #unknowns) */
	int n = data.corres_ct;
	/* I: measurement vector dimension */
	int itmax = 10000;
	/* I: maximum number of iterations */
	for (i = 0; i < n; i++)
		x[i] = 0.0;
	// set initial estimation to all zero
	for (i = 0; i < m; i++)
		p[i] = 0.0;

	// optimize without analytical Jacobian
	int ret = dlevmar_dif(EpipolarError, p, x, m, n, itmax, opts, info,
	NULL, NULL, &data);  // no Jacobian
	//	printf("reason for terminating: %f\n", info[6]);
	//	printf("number of iterations: %f\n", info[5]);
	//	printf("initial ||e||^2: %f\n current ||e||^2: %f\n current ||J^T e||: %f\n current |||Dp||_2: %f \n", info[0], info[1], info[2], info[3]);

	double lamda = p[0], beta_l = p[1], beta_r = p[2], alpha_l = p[3], alpha_r =
			p[4];

	// get the correct rotation matrix
	Mat Rc_left = AxisRotation('x', lamda / 2) * AxisRotation('z', beta_l)
			* AxisRotation('y', alpha_l);
	Mat Rc_right = AxisRotation('x', -lamda / 2) * AxisRotation('z', beta_r)
			* AxisRotation('y', alpha_r);
	R_left_new = Rc_left * R_left_orig;
	R_right_new = Rc_right * R_right_orig;

//	// clear the correspondences after re-calibration
//	Clear();
	delete[] x;
	return true;
}

bool AutoRecalibrator::CalcCorrespondences(const Mat& img_left,
		const Mat& img_right, vector<Point2f>& corres_left,
		vector<Point2f>& corres_right) {
	// data format transform
	Mat img_left_gray, img_right_gray;
	if(img_left.channels() == 3)
		cvtColor(img_left, img_left_gray, CV_BGR2GRAY);
	else
		img_left_gray = img_left;
	if(img_right.channels() == 3)
		cvtColor(img_right, img_right_gray, CV_BGR2GRAY);
	else
		img_right_gray = img_right;
	//Detect the features
	vector<KeyPoint> src_keypoints, dest_keypoints;
	Mat src_descrpt, dest_descrpt;

	if (!feat_extractor->DetectAndExtract(img_left_gray, src_keypoints,
			src_descrpt))
		return false;
	if (!feat_extractor->DetectAndExtract(img_right_gray, dest_keypoints,
			dest_descrpt))
		return false;
	// correspondence matching
	corres_detector->Detect(src_keypoints, dest_keypoints, src_descrpt,
			dest_descrpt, corres_left, corres_right);
	if (corres_left.size() != corres_right.size() || corres_left.size() == 0)
		return false;
	return true;
}

bool AutoRecalibrator::BalanceCorresDistribution(vector<Point2f>& corres_left,
		vector<Point2f>& corres_right) {

	int w_step = ceil(img_width / DISTR_GRID_WIDTH);
	int h_step = ceil(img_height / DISTR_GRID_HEIGHT);
	vector<vector<vector<pair<Point2f, Point2f> > > > corres_grid(
			DISTR_GRID_HEIGHT,
			vector<vector<pair<Point2f, Point2f> > >(DISTR_GRID_WIDTH));
	int x, y;
	for (int i = 0; i < corres_left.size(); ++i) {
		y = floor(corres_left[i].y / h_step);
		x = floor(corres_left[i].x / w_step);
		corres_grid[y][x].push_back(
				std::make_pair(corres_left[i], corres_right[i]));
	}
	bool is_ready = true;

	for (y = 0; y < DISTR_GRID_HEIGHT; ++y) {
		for (x = 0; x < DISTR_GRID_WIDTH; ++x) {
			int grid_sz = corres_grid[y][x].size();
			corres_distr[y][x] = grid_sz;
			if (grid_sz < DISTR_CORRES_MIN_SIZE)
				is_ready = false;
		}
	}
	// if not ready simply return and do not clear the correspondences and wait for more data to be added.
	if (!is_ready)
		return false;
	corres_left.clear();
	corres_right.clear();
	for (y = 0; y < DISTR_GRID_HEIGHT; ++y) {
		for (x = 0; x < DISTR_GRID_WIDTH; ++x) {
			int grid_sz = corres_grid[y][x].size();
			int sel_sz = min(grid_sz, DISTR_CORRES_MAX_SIZE);
			if (grid_sz > sel_sz)
				random_shuffle(corres_grid[y][x].begin(),
						corres_grid[y][x].end());
			for (int i = 0; i < sel_sz; ++i) {
				corres_left.push_back(corres_grid[y][x][i].first);
				corres_right.push_back(corres_grid[y][x][i].second);
			}
		}
	}
	return true;
}

