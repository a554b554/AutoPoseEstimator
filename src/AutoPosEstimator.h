/*
 * AutoPosEsimator.h
 *
 *  Created on: Jul 29, 2015
 *      Author: xc
 */

#ifndef AUTOPOSESIMATOR_H_
#define AUTOPOSESIMATOR_H_
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
#include <fstream>

#define EPIPOLAR_CONSTRAIN_THRD 50
#define DISTR_GRID_WIDTH 3
#define DISTR_GRID_HEIGHT 2
#define DISTR_CORRES_MIN_SIZE 10
#define DISTR_CORRES_MAX_SIZE 1000
#define MIN_RECT_IMG_PAIR_SIZE 3
#define MIN_VALID_IMG_PAIR_SIZE 1
#define MIN_CORRES 100
#define MAX_EPI_ERR 2.0
#define REPROJECT_ERR_THRE 1.0

#define RECALIB_ERR_NO_NEED 0
#define RECALIB_ERR_NO_EQUAL_DATA -1
#define RECALIB_ERR_NO_ENOUGH_DATA -2
#define RECALIB_ERR_RECAL_FAILED -3
#define RECALIB_ERR_LARGER_EPIERR -4


using namespace std;
using namespace cv;
void readmat(string fname, Mat& m);
void vec2mat(const vector<Point2f>& pts, Mat& output);
Mat Skew(const Mat& m);
Mat AxisRotation(char axis, double angle);
void linearSearchSolver(void(*func)(double*,double*,int,int,void*),double* p,
                        double* x, double step, double lb, double ub, void* data);
void Xm2XoError(double* p, double* x, int m, int n, void* data);
void Xm2EpiLineError(double *p, double *x, int m, int n, void *data);
struct OptData{
    int corres_size;
    Mat corres_left_o;
    Mat corres_right_o;
    Mat corres_left_m;
    Mat corres_right_m;
    double T_norm;
    void print();

};

struct modelOptData{
    Mat A;
    Mat B;
    Mat C;
    Mat D;
    Mat N1;
    Mat N2;
    Mat R;
};

class EstimatorOption{
public:
    EstimatorOption(FeatureDetectorType _detector_type = FAST_DET,
        FeatureDescriptorType _descriptor_type = ORB_DESC,
		FeatureDescriptorParam* _desc_param = new ORBFeatureDescriptorParam(),
		FeatureDetectorParam* _det_param = new FASTFeatureDetectorParam(),
        CorresDetectorType _corres_type = HOMOGRAPHY,
		int _epipolar_constrian_thrd = EPIPOLAR_CONSTRAIN_THRD,
        bool _corres_balancing = true):detector_type(_detector_type),
        descriptor_type(_descriptor_type),detector_param(_det_param),
        corres_type(_corres_type),descriptor_param(_desc_param),
        epipolar_constrian_thrd(_epipolar_constrian_thrd),
        corres_balancing(_corres_balancing){}
	FeatureDetectorType detector_type;
	FeatureDescriptorType descriptor_type;
	FeatureDetectorParam* detector_param;
	FeatureDescriptorParam* descriptor_param;
	CorresDetectorType corres_type;
    int epipolar_constrian_thrd;
    bool corres_balancing;
};


class AutoPosEstimator {
public:
	AutoPosEstimator(EstimatorOption* _options, vector<Mat>& _left_imgs, vector<Mat>& _right_imgs);
	~AutoPosEstimator();
	bool extractCorres();
    void recoverRT(Mat& R, Mat& T);
    void rectifyImage(const Mat& imgl, const Mat& imgr, const Mat& R, const Mat& T, Mat& dstl, Mat& dstr);
    void setIntrinsic(const Mat& K_left, const Mat& K_right, const Mat& d_left, const Mat& d_right);
    void svddecompose(const Mat& E, Mat& R, Mat& T);
    double evalEpiErr(const Mat& left_img_rect, const Mat& right_img_rect);
    void optmizePos(const Mat& oriR, const Mat& oriT, Mat& R, Mat& T, int maxIter);
    void updatePose(const Mat& corres_left_m, const Mat& corres_right_m, const Mat& corres_left_o, const Mat& corres_right_o,
                    const Mat& oriR, const Mat& oriT, Mat& R, Mat& T);
    double updateModel(const Mat& corres_left_o, const Mat& corres_right_o, const Mat& R,
                     const Mat& T, Mat& corres_left_m, Mat& corres_right_m);
    // return the error.
    void exportImg();
    void setid(string _id);

private:
    string id;
	EstimatorOption* options;
	int img_width;
	int img_height;
	Mat K_left;
	Mat K_right;
	Mat d_left;
	Mat d_right;
    Mat left_rect;
    Mat right_rect;
	vector<Mat> left_imgs;
	vector<Mat> right_imgs;
	FeatureExtractor* feature_extractor;
	CorrespondenceDetector* corres_detector;
	vector<Point2f> corres_left, corres_right;
    int sampleCount=2000;
};

#endif /* AUTOPOSESIMATOR_H_ */
