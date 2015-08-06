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


bool loadCameraMatrix(const string filepath, Mat& K_left, Mat& K_right,
                      Mat& d_left, Mat& d_right){
    FileStorage fs(filepath, FileStorage::READ);
    if(!fs.isOpened()){
        return false;
    }
    fs["M1"]>>K_left;
    fs["M2"]>>K_right;
    fs["D1"]>>d_left;
    fs["D2"]>>d_right;
    return true;
}

int mainaa(){
    double lb=0.4;
    double ub=0.7;
    double p = (lb+ub)/2;
    double x = 0;
    int m = 1;
    int n = 2;
    int itmax = 10000;
    // Options to the solver, see the manual of the library
    double opts[]={0.1, 0.0001, 0.0001, 0.0001};

    // Output information from the solver
    double info[9];
    modelOptData data;
    data.A = Mat::eye(3,3,CV_64FC1);
    data.B = Mat::eye(3,3,CV_64FC1);
    data.C = Mat::eye(3,3,CV_64FC1);
    data.D = Mat::eye(3,3,CV_64FC1);
    data.N1 = Mat::eye(1,3,CV_64FC1);
    data.N2 = Mat::eye(3,1,CV_64FC1);
    data.R = Mat::eye(3,3,CV_64FC1);;
    double desc=0.001;
    //int ret = dlevmar_bc_dif(Xm2XoError,&p,x,m,n,&lb,&ub,NULL,itmax,opts,info,
                           //  NULL,NULL,reinterpret_cast<void*>(&data));
    linearSearchSolver(Xm2XoError,&p,&x,desc,lb,ub,reinterpret_cast<void*>(&data));
    cout<<p;
}

int mainc(){
    Mat a;
    readmat("oleft.txt",a);
    return 0;
}

int main() {
//    double d[3]={0,0,1};
//    Mat e3_s = Skew(Mat(1,3,CV_64F,d));
//    cout<<e3_s;
//    return 0;
    string imgpath = "../demo/data/png/";
//    string mid[]={"00001","00011","00021","00061"};
    string ids[]={"00000","00100"};
//    string ids[]={"00000"};
    string mid[]={"00001"};
    vector<string> mid_path(mid,mid+1);
    vector<string> imgids(ids,ids+1);
    vector<Mat> left_imgs,right_imgs;
    string calibpath="../demo/calib/intrinsics.yml";
    Mat K_left,K_right,d_left,d_right;
    if(!loadImage(imgpath, mid_path, imgids, left_imgs, right_imgs)){
        cerr<<"read image fail!"<<endl;
        exit(1);
    }
    if(!loadCameraMatrix(calibpath,K_left,K_right,d_left,d_right)){
        cerr<<"load camera matrix failed!"<<endl;
        exit(1);
    }
    EstimatorOption* opt = new EstimatorOption(FAST_DET);
    AutoPosEstimator* est = new AutoPosEstimator(opt,left_imgs,right_imgs);
    est->setIntrinsic(K_left,K_right,d_left,d_right);
    est->extractCorres();
    est->setid("test");
    Mat R,T,dstl,dstr,optR,optT,leftopt,rightopt;
    est->recoverRT(R,T);
    est->rectifyImage(left_imgs[0],right_imgs[0],R,T,dstl,dstr);

    vector<Mat> ll,rr;
    ll.push_back(left_imgs[0]);
    rr.push_back(right_imgs[0]);
    ll.push_back(dstl);
    rr.push_back(dstr);
    est->optmizePos(R,T,optR,optT,10);
    est->rectifyImage(left_imgs[0],right_imgs[0],optR,optT,leftopt,rightopt);
    cout<<"err:"<<est->evalEpiErr(dstl,dstr)<<endl;
    cout<<"opt err:"<<est->evalEpiErr(leftopt,rightopt)<<endl;
    ll.push_back(leftopt);
    rr.push_back(rightopt);
    VisualizeRectResults(ll,rr);
    est->exportImg();

	return 0;
}
