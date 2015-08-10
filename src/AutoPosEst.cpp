//============================================================================
// Name        : AutoPosEst.cpp
// Author      : 
// Version     :
// Copyright   : Your copyright notice
// Description : Hello World in C++, Ansi-style
//============================================================================

#include <iostream>
#include <string>
#include "AutoPosEstimator.h"
#include "StereoVisualizeUtils.h"
#include "AutoCalibParam.h"
#include "cpu_sncc.h"
#include "AutoRecalibrator.h"

#include <dirent.h>
#include <sys/stat.h>

using namespace std;
using namespace cv;
bool loadImage(const string imgpath,
               const vector<string>& midpath,
               const vector<string>& imgids,
               vector<Mat>& left_imgs,
               vector<Mat>& right_imgs){
    for(int i = 0;i < midpath.size();i++){
        for(int j = 0;j < imgids.size(); j++){
            string leftimgpath=imgpath+"all_"+midpath[i]+"_"+imgids[j]+"_left.png";
            string rightimgpath=imgpath+"all_"+midpath[i]+"_"+imgids[j]+"_right.png";
            Mat imgl=imread(leftimgpath);
            Mat imgr=imread(rightimgpath);
            if(imgl.empty()||imgr.empty()){
                return false;
            }
            left_imgs.push_back(imgl);
            right_imgs.push_back(imgr);
        }
    }
    return true;
}

//
//bool loadCameraMatrix(const string filepath, Mat& K_left, Mat& K_right,
//                      Mat& d_left, Mat& d_right){
//    FileStorage fs(filepath, FileStorage::READ);
//    if(!fs.isOpened()){
//        return false;
//    }
//    fs["M1"]>>K_left;
//    fs["M2"]>>K_right;
//    fs["D1"]>>d_left;
//    fs["D2"]>>d_right;
//    return true;
//}
//
//int mainaa(){
//    double lb=0.4;
//    double ub=0.7;
//    double p = (lb+ub)/2;
//    double x = 0;
//    int m = 1;
//    int n = 2;
//    int itmax = 10000;
//    // Options to the solver, see the manual of the library
//    double opts[]={0.1, 0.0001, 0.0001, 0.0001};
//
//    // Output information from the solver
//    double info[9];
//    modelOptData data;
//    data.A = Mat::eye(3,3,CV_64FC1);
//    data.B = Mat::eye(3,3,CV_64FC1);
//    data.C = Mat::eye(3,3,CV_64FC1);
//    data.D = Mat::eye(3,3,CV_64FC1);
//    data.N1 = Mat::eye(1,3,CV_64FC1);
//    data.N2 = Mat::eye(3,1,CV_64FC1);
//    data.R = Mat::eye(3,3,CV_64FC1);;
//    double desc=0.001;
//    //int ret = dlevmar_bc_dif(Xm2XoError,&p,x,m,n,&lb,&ub,NULL,itmax,opts,info,
//                           //  NULL,NULL,reinterpret_cast<void*>(&data));
//    linearSearchSolver(Xm2XoError,&p,&x,desc,lb,ub,reinterpret_cast<void*>(&data));
//    cout<<p;
//}
//
//int mainc(){
//    Mat a;
//    readmat("oleft.txt",a);
//    return 0;
//}
void BuildDir(string dirpath, unsigned int dir_perm = 0777) {
	mkdir(dirpath.c_str(), dir_perm);
}
void LoadIntrinsic(string filepath, Mat& K_left, Mat& d_left, Mat& K_right, Mat& d_right)
{
	FileStorage fs(filepath, CV_STORAGE_READ);
	if (fs.isOpened()) {
		fs["M1"] >> K_left;
		fs["D1"] >> d_left;
		fs["M2"] >> K_right;
		fs["D2"] >> d_right;
		fs.release();
	}
}

void LoadExtrinsic(string filepath, Mat& R, Mat& T, Mat& R_left, Mat& R_right, Mat& P_left, Mat& P_right)
{
	FileStorage fs(filepath, CV_STORAGE_READ);
	fs.open(filepath, CV_STORAGE_READ);
	if (fs.isOpened()) {
		fs["R"] >> R;
		fs["T"] >> T;
		fs["R1"] >> R_left;
		fs["R2"] >> R_right;
		fs["P1"] >> P_left;
		fs["P2"] >> P_right;
		fs.release();
	}
}

int main(int argc, char** argv) {

	AutoCalibParam param;
	if (!param.ParseCommandLine(argc, argv)) {
		fprintf(stderr, "%s\n", param.Usage().c_str());
		exit(0);
	} else {
		fprintf(stdout, "%s\n", param.ToString().c_str());
	}

	// build outputdirs
	string output_eval_filepath = param.output_dirpath + "/eval.txt";
	string output_extr_dirpath = param.output_dirpath + "/extr";
	string output_img_dirpath = param.output_dirpath + "/img";
	BuildDir(param.output_dirpath);
	BuildDir(output_extr_dirpath);
	BuildDir(output_img_dirpath);
	Size imageSize(1280, 720);
	Mat K_left, K_right, d_left, d_right;
	EstimatorOption* opt = new EstimatorOption();
	AutoPosEstimator* est = new AutoPosEstimator(1280, 720, opt);
	//AutoRecalibrator* recalib = new AutoRecalibrator(1280, 720);
	// load intrinsic and extrinsic (calibration results)
	LoadIntrinsic(param.intr_filepath, K_left, d_left, K_right, d_right);
	bool has_gt = false;
	Mat R_gt, T_gt, R_left_gt, R_right_gt, P_left_gt, P_right_gt;
	Mat rmap_gt[2][2];
	if(param.extr_filepath != "")
	{
		LoadExtrinsic(param.extr_filepath, R_gt, T_gt, R_left_gt, R_right_gt, P_left_gt, P_right_gt);
		initUndistortRectifyMap(K_left, d_left, R_left_gt, P_left_gt,
				imageSize,
				CV_16SC2, rmap_gt[0][0], rmap_gt[0][1]);
		initUndistortRectifyMap(K_right, d_right, R_right_gt, P_right_gt,
				imageSize,
				CV_16SC2, rmap_gt[1][0], rmap_gt[1][1]);
		has_gt = true;
	}

	for (int t = 0; t < param.input_data.size(); ++t) {
		AutoCalibParam::InputData data = param.input_data[t];
		printf("processing: %s\n", data.id.c_str());
		// load left and right images
		vector<Mat> left_imgs,right_imgs;
		for (int i = 0; i < data.left_right_imgs.size(); ++i) {
			Mat img_left, img_right;
			cvtColor(imread(data.left_right_imgs[i].first, 0), img_left,
					COLOR_GRAY2BGR);
			cvtColor(imread(data.left_right_imgs[i].second, 0), img_right,
					COLOR_GRAY2BGR);
			left_imgs.push_back(img_left);
			right_imgs.push_back(img_right);
		}

		Mat R, T, optR, optT;
		vector<Mat> rect_imgs_left_init, rect_imgs_right_init, rect_imgs_left_opt, rect_imgs_right_opt;
		vector<Mat> rect_imgs_left_final, rect_imgs_right_final;
		est->EstimatePose(K_left, K_right, d_left, d_right, left_imgs,
				right_imgs, R, T, optR, optT);
		double err_init = est->EvalPose(R, T, left_imgs, right_imgs, rect_imgs_left_init,
				rect_imgs_right_init);
		double err_opt = est->EvalPose(optR, optT, left_imgs, right_imgs,
				rect_imgs_left_opt, rect_imgs_right_opt);
//		bool is_succ = false;
//		if (err_init < 1.0) {
//			rect_imgs_left_final = rect_imgs_left_init;
//			rect_imgs_right_final = rect_imgs_right_init;
//			is_succ = true;
//			cout << "init err: " << err_init << endl;
//		} else {
//			double err_opt = est->EvalPose(optR, optT, left_imgs, right_imgs,
//					rect_imgs_left_opt, rect_imgs_right_opt);
//			cout << "opt err: " << err_opt << endl;
//			if (err_opt < 2.0) {
//				rect_imgs_left_final = rect_imgs_left_opt;
//				rect_imgs_right_final = rect_imgs_right_opt;
//				is_succ = true;
//			}
//		}
//		if (!is_succ) {
//			printf("failed!\n");
//			continue;
//		}

//		Mat R_left_opt, R_right_opt, P_left_opt, P_right_opt, Q_opt;
//		stereoRectify(K_left, d_left, K_right, d_right, imageSize, optR, optT, R_left_opt,
//				R_right_opt, P_left_opt, P_right_opt, Q_opt);
//		Mat R_new, T_new, Q_new, R_left_new, R_right_new, P_left_new,
//				P_right_new;
//		Rect roi_left_new, roi_right_new;
//		double epi_err_old,epi_err_new;
//		double epi_err_thrd = 3;
//		bool post_validation = true;



//		recalib->AutoRecalibration(rect_imgs_left_opt, rect_imgs_right_opt,
//				left_imgs, right_imgs, K_left, K_right, d_left, d_right,
//				R_left_opt, R_right_opt, P_left_opt, P_right_opt, R_new, T_new,
//				Q_new, R_left_new, R_right_new, P_left_new, P_right_new,
//				roi_left_new, roi_right_new, epi_err_old, epi_err_new,
//				epi_err_thrd, post_validation);
//
//		Mat rmap[2][2];
//
//		//Precompute maps for cv::remap()
//		initUndistortRectifyMap(K_left, d_left, R_left_new, P_left_new, imageSize,
//				CV_16SC2, rmap[0][0], rmap[0][1]);
//		initUndistortRectifyMap(K_right, d_right, R_right_new, P_right_new, imageSize,
//				CV_16SC2, rmap[1][0], rmap[1][1]);


//		cout << "recalib err: " << epi_err_old << endl;
		for (int i = 0; i < left_imgs.size(); ++i) {
			vector<Mat> ll, rr;
			Mat img_left_recalib, img_right_recalib;
			Mat img_left_gt, img_right_gt;

//			remap(left_imgs[i], img_left_recalib, rmap[0][0], rmap[0][1], CV_INTER_LINEAR);
//			remap(right_imgs[i], img_right_recalib, rmap[1][0], rmap[1][1], CV_INTER_LINEAR);
			ll.push_back(left_imgs[i]);
			rr.push_back(right_imgs[i]);
//			ll.push_back(rect_imgs_left_final[i]);
//			rr.push_back(rect_imgs_right_final[i]);
			ll.push_back(rect_imgs_left_init[i]);
			rr.push_back(rect_imgs_right_init[i]);
			ll.push_back(rect_imgs_left_opt[i]);
			rr.push_back(rect_imgs_right_opt[i]);
//			ll.push_back(img_left_recalib);
//			rr.push_back(img_right_recalib);
			if (has_gt) {
				remap(left_imgs[i], img_left_gt, rmap_gt[0][0], rmap_gt[0][1],
						CV_INTER_LINEAR);
				remap(right_imgs[i], img_right_gt, rmap_gt[1][0], rmap_gt[1][1],
						CV_INTER_LINEAR);
				ll.push_back(img_left_gt);
				rr.push_back(img_right_gt);
			}


			Mat rect_img = VisualizeRectResults(ll, rr, false);
			Mat depth_img_init = CpuSNCC::Process(rect_imgs_left_init[i], rect_imgs_right_init[i]);
			Mat depth_img_opt = CpuSNCC::Process(rect_imgs_left_opt[i], rect_imgs_right_opt[i]);
//			Mat depth_img_final = CpuSNCC::Process(rect_imgs_left_final[i], rect_imgs_right_final[i]);
//			Mat depth_img_recalib = CpuSNCC::Process(img_left_recalib, img_right_recalib);
//			imshow("rect_img", rect_img);
//			imshow("depth_img_final", depth_img_final);
//			imshow("depth_img_init", depth_img_init);
//			imshow("depth_img_opt", depth_img_opt);

//			imshow("depth_img_recalib", depth_img_recalib);

			string rect_img_filepath = output_img_dirpath + "/" + data.id + "_"
					+ std::to_string(i) + "_rect.jpg";
			imwrite(rect_img_filepath, rect_img);
//			string depth_final_img_filepath = output_img_dirpath + "/" + data.id
//					+ "_" + std::to_string(i) + "_depth_final.jpg";
//			imwrite(depth_final_img_filepath, depth_img_final);
			string depth_init_img_filepath = output_img_dirpath + "/" + data.id
					+ "_" + std::to_string(i) + "_depth_init.jpg";
			imwrite(depth_init_img_filepath, depth_img_init);
			string depth_opt_img_filepath = output_img_dirpath + "/" + data.id
					+ "_" + std::to_string(i) + "_depth_opt.jpg";
			imwrite(depth_opt_img_filepath, depth_img_opt);

			if (has_gt) {
				Mat depth_img_gt = CpuSNCC::Process(img_left_gt, img_right_gt);
				imshow("depth_img_gt", depth_img_gt);
				string depth_gt_img_filepath = output_img_dirpath + "/"
						+ data.id + "_" + std::to_string(i) + "_depth_gt.jpg";
				imwrite(depth_gt_img_filepath, depth_img_gt);
			}
			cvWaitKey(10);
			break;

		}

	}

//	delete recalib;
	delete est;
	delete opt;

	return 0;
}
