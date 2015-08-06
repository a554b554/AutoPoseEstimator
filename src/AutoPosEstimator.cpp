/*
 * AutoPosEsimator.cpp
 *
 *  Created on: Jul 29, 2015
 *      Author: xc
 */

#include "AutoPosEstimator.h"
#include <iostream>
using namespace std;

void readmat(string fname, Mat& m){
    FILE* fp;
    fp = fopen(fname.c_str(),"r");
    vector<Point2f> pt;
    while (!feof(fp)) {
        double x,y,z;
        fscanf(fp,"  %lf, %lf, %lf;\n",&x,&y,&z);
        pt.push_back(Point2f(x,y));
       // cout<<x<<" "<<y<<" "<<z<<endl;
    }
    pt.pop_back();
    vec2mat(pt,m);
    //cout<<pt[19249].x;
    return;

}

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

void vec2mat(const vector<Point2f> &pts, Mat &output){
    output.create(pts.size(),3,CV_64FC1);
    for(int i = 0; i < pts.size();i++){
        output.at<double>(i,0)=pts[i].x;
        output.at<double>(i,1)=pts[i].y;
        output.at<double>(i,2)=1;
    }
}

void null(const Mat& essential, Mat& dst){
    dst.create(3,1,CV_64FC1);
}

void linearSearchSolver(void(*func)(double*,double*,int,int,void*),double* p,
                        double* x, double step, double lb, double ub, void* data){
    *p=lb;
    func(p,x,1,1,data);
    double bestval = *p;
    double minfuncval = *x;
    while(1){
        *p += step;
        func(p,x,1,1,data);
        if(*x<minfuncval){
           // cout<<"x:"<<*x<<endl;
            minfuncval = *x;
            bestval=*p;
        }
        if(*p>ub){
            break;
        }
    }
    *p=bestval;
}

void Xm2EpiLineError(double *p, double *x, int m, int n, void *data) {

//function obj = Xm2EpiLineError(rt, X1_m, X2_m, X1_o, X2_o, T_norm)
//    lamda = 1;
//    r = rt(1:3);
//    t = rt(4:6) / norm(rt(4:6)) * T_norm;
//    R = rodrigues(r);
//    T_s = Skew(t);
//    e3_s = Skew([0, 0, 1]);
//    N = size(X1_m, 2);
//    obj = [];
//    TsR = T_s * R;
//    e3sTsR = e3_s * TsR;
//    TsRe3sT = TsR * e3_s';
//    X1_m = X1_m';
//    X2_m = X2_m';
//    X1_o = X1_o';
//    X2_o = X2_o';

//    for i = 1:N
//        x1_m = X1_m(i, :);
//        x2_m = X2_m(i, :);
//        x1_o = X1_o(i, :);
//        x2_o = X2_o(i, :);
//        obj = [obj;(x2_o * TsR * x1_m')/ norm(e3sTsR * x1_m');(x2_m * TsR * x1_o')/ norm(x2_m * TsRe3sT)];
//    end

    //corres_left_o : n*3 matrix CV_64F
    //corres_left_m : n*3 matrix CV_64F
    OptData* epi_opt_data = (OptData*) data;
    //double Rx = p[0], Ry = p[1], Rz = p[2], Tx = p[3], Ty = p[4], Tz = p[5];
    double rdata[3]={p[0],p[1],p[2]};
    Mat _r(1,3,CV_64FC1,rdata);
    Mat R;
    Rodrigues(_r,R);
    double _t[3]={p[3],p[4],p[5]};
    Mat T(1,3,CV_64FC1,_t);
    T = T/norm(T) * (epi_opt_data->T_norm);
    Mat T_s = Skew(T);
   // cout<<"T_s:"<<T_s<<endl;
    double d[3]={0,0,1};
    Mat e3_s = Skew(Mat(1,3,CV_64F,d));
   // cout<<"e3_s:"<<e3_s<<endl;
    Mat TsR = T_s * R;
    Mat e3sTsR = e3_s * TsR;
    Mat TsRe3sT = TsR * e3_s;
    int ct = 0;
    for(int i = 0; i < n; i=i+2){
        Mat x1_m,x2_m,x1_o,x2_o;
        x1_m = epi_opt_data->corres_left_m.row(ct);
        x2_m = epi_opt_data->corres_right_m.row(ct);
        x1_o = epi_opt_data->corres_left_o.row(ct);
        x2_o = epi_opt_data->corres_right_o.row(ct);
        x[i] = Mat(x2_o*TsR*x1_m.t()).at<double>(0,0)/norm(e3sTsR*x1_m.t());
        x[i+1] = Mat(x2_m*TsR*x1_o.t()).at<double>(0,0)/norm(x2_m*TsRe3sT);
        ct++;
        //cout<<ct<<" "<<x[i]<<endl;
    }
    double ans=0;
    for(int i = 0;i<n;i++){
        ans+=x[i];
    }
}

//function [obj] = Xm2XoError(theta, A, B, C, D, N1, N2, R)
//    l2 = cos(theta) * N1 + sin(theta) * N2;
//    obj = (l2' * A * l2) / (l2' * B * l2) + ...
//          (l2' * R * C  * R' * l2) / (l2' * R * D  * R' * l2);
//end
//void LMHelper(double *p,
//              double *hx,
//              int m,
//              int n,
//              void *adata)
void Xm2XoError(double* p, double* x, int m, int n, void* data){
    modelOptData* _data = reinterpret_cast<modelOptData*>(data);
    double theta = *p;
    Mat l2 = cos(theta)*_data->N1.t() + sin(theta)*_data->N2; //l2: 3x1
    double a = Mat(l2.t()*_data->A*l2).at<double>(0)/Mat(l2.t()*_data->B*l2).at<double>(0);
    double b = Mat(l2.t() * _data->R * _data->C * _data->R.t() * l2).at<double>(0)/Mat(l2.t() * _data->R * _data->D * _data->R.t() * l2).at<double>(0);
    *x=a+b;
}

void OptData::print(){
    cout<<"x1_o: "<<corres_left_o<<endl;
    cout<<"x2_o: "<<corres_right_o<<endl;
    cout<<"x1_m: "<<corres_left_m<<endl;
    cout<<"x2_m: "<<corres_right_m<<endl;
    cout<<"T_norm: "<<T_norm<<endl;
}

AutoPosEstimator::AutoPosEstimator(EstimatorOption *_options, vector<Mat>& _left_imgs, 
	vector<Mat>& _right_imgs) {
	this->options = options;
	for (int i = 0; i < _left_imgs.size(); ++i)
	{
        Mat imgl = _left_imgs[i].clone();
		if (imgl.channels()==3){
			cvtColor(imgl,imgl,CV_BGR2GRAY);
		}
        Mat imgr = _right_imgs[i].clone();
		if (imgr.channels()==3){
			cvtColor(imgr,imgr,CV_BGR2GRAY);
		}
		left_imgs.push_back(imgl);
        right_imgs.push_back(imgr);
	}

    feature_extractor = new FeatureExtractor(_options->detector_type,_options->descriptor_type
                                             , _options->detector_param,_options->descriptor_param);
    corres_detector = new HomographyRansacCorresDetector();
    img_width = left_imgs[0].cols;
    img_height = left_imgs[0].rows;
    //imshow("dd",left_imgs[0]);

}

AutoPosEstimator::~AutoPosEstimator() {
    delete feature_extractor;
    delete corres_detector;
    delete options;
	// TODO Auto-generated destructor stub
}

bool AutoPosEstimator::extractCorres() {
	// data format transform
    for(int i = 0;i < this->left_imgs.size();i++){
        Mat imgl = left_imgs[i].clone();
        Mat imgr = right_imgs[i].clone();
        vector<KeyPoint> kptl,kptr;
        vector<Point2f> corresl,corresr;
        Mat desl,desr;
        //detect and extract left image's feature
        feature_extractor->DetectAndExtract(imgl,kptl,desl);
        feature_extractor->DetectAndExtract(imgr,kptr,desr);
        corres_detector->Detect(kptl,kptr,desl,desr,corresl,corresr);
//        corres_detector->checkMatch(imgl,imgr,corresl,corresr);
//        waitKey(0);
        corres_left.insert(corres_left.end(),corresl.begin(),corresl.end());
        corres_right.insert(corres_right.end(),corresr.begin(),corresr.end());
    }
    if(corres_left.size() > MIN_CORRES){
        return true;
    }
    else{
        return false;
    }
	
}

void AutoPosEstimator::setIntrinsic(const Mat &K_left, const Mat &K_right, const Mat &d_left, const Mat &d_right){
    this->K_left = K_left;
    this->K_right = K_right;
    this->d_left = d_left;
    this->d_right = d_right;
}

void AutoPosEstimator::recoverRT(Mat &R, Mat &T){
    int corres_size = corres_left.size();
    double err = INFINITY;
    vector<Point2f> left_sample, right_sample;
    srand((int)time(NULL));
    for(int i = 0; i < sampleCount; i++){
        for(int j = 0; j < 8; j++){
            int idx = rand()%corres_size;
            left_sample.push_back(corres_left[idx]);
            right_sample.push_back(corres_right[idx]);
        }

        Mat F =  findFundamentalMat(left_sample, right_sample, FM_8POINT);
        Mat_<double> E = K_left.t() * F * K_right;

        Mat tmpR,tmpT;
        svddecompose(E, tmpR, tmpT);
        Mat recl,recr;
        rectifyImage(left_imgs[0], right_imgs[0], tmpR, tmpT, recl, recr);

        double tmperr = evalEpiErr(recl,recr);
        if(tmperr<err){
            err = tmperr;
            R = tmpR;
            T = tmpT;
        }
        left_sample.clear();
        right_sample.clear();
    }
    //cout<<"final err:"<<err<<endl;
}

double AutoPosEstimator::evalEpiErr(const Mat &left_img_rect, const Mat &right_img_rect){
    vector<KeyPoint> kptl,kptr;
    vector<Point2f> corresl,corresr;
    Mat desl,desr;
    feature_extractor->DetectAndExtract(left_img_rect,kptl,desl);
    feature_extractor->DetectAndExtract(right_img_rect,kptr,desr);
    if(kptl.size() < MIN_CORRES){
        return INFINITY;
    }
    if(kptr.size() < MIN_CORRES){
        return INFINITY;
    }
    corres_detector->Detect(kptl,kptr,desl,desr,corresl,corresr);
    if(corresl.size() < MIN_CORRES){
        return INFINITY;
    }
    double ans=0;

    for(int i = 0;i < corresl.size();i++){
        ans+=fabs(corresl[i].y-corresr[i].y);
    }
    return ans/corresl.size();
}

void AutoPosEstimator::svddecompose(const Mat &E, Mat &R, Mat &T){
    SVD svd(E);
    Matx33d W(0,-1,0,
              1,0,0,
              0,0,1);
    Mat_<double> _R = svd.u * Mat(W) * svd.vt;
    Mat_<double> _t = svd.u.col(2);
    R = _R;
    T = _t;
}

void AutoPosEstimator::rectifyImage(const Mat &imgl, const Mat &imgr, const Mat &R, const Mat &T, Mat& dstl, Mat& dstr){
    Mat R_left,R_right,P_left,P_right,Q;
    Size imageSize = imgl.size();
    stereoRectify(K_left,d_left,K_right,d_right,imageSize,R,T,R_left,R_right,P_left,P_right,Q);
    Mat rmap[2][2];

    //Precompute maps for cv::remap()
    initUndistortRectifyMap(K_left, d_left, R_left, P_left, imageSize, CV_16SC2, rmap[0][0], rmap[0][1]);
    initUndistortRectifyMap(K_right, d_right, R_right, P_right, imageSize, CV_16SC2, rmap[1][0], rmap[1][1]);

    remap(imgl, dstl, rmap[0][0], rmap[0][1], CV_INTER_LINEAR);
    remap(imgr, dstr, rmap[1][0], rmap[1][1], CV_INTER_LINEAR);
    left_rect = dstl.clone();
    right_rect = dstr.clone();
}

void AutoPosEstimator::optmizePos(const Mat &oriR, const Mat &oriT, Mat &R, Mat &T, int maxIter){
    Mat m_left,m_right,o_left,o_right;
    vec2mat(corres_left, o_left);
    vec2mat(corres_right, o_right);
    //cout<<"o_left before:"<<o_left<<endl;
    Mat K_left_inv = K_left.inv();
    Mat K_right_inv = K_right.inv();
    for(int i = 0; i < corres_left.size(); i++){
        Mat tmp = K_left_inv * o_left.row(i).t();
        o_left.row(i) = tmp.clone().t();
        tmp = K_right_inv * o_right.row(i).t();
        o_right.row(i) = tmp.clone().t();
    }
    //cout<<"o_left after:"<<o_left<<endl;
    m_left = o_left.clone();
    m_right = o_right.clone();
    double olderr=INFINITY;
    for(int i = 0; i < maxIter; i++){
       cout<<"iter: "<<i<<endl;
       //ob2model(corres_left, K_left, m_left);
       //ob2model(corres_right, K_right, m_right);
      // cout<<"before:"<<R<<T<<endl;
       updatePose(m_left,m_right, o_left,o_right, oriR,oriT,R,T);
      // cout<<"after:"<<R<<T<<endl;
       //[X1_m, X2_m, err] = UpdateModel(X1_o, X2_o, R_opt_, T_opt_);
//       fstream _oleft,_oright,_R,_T,_mleft,_mright;
//       _oleft.open("oleft.txt");
//       _oleft<<o_left;
//       _oright.open("oright.txt");
//       _oright<<o_right;
//       _R.open("R.txt");
//       _R<<R;
//       _T.open("T.txt");
//       _T<<T;
//       _oleft.close();
//       _oright.close();
//       _R.close();
//       _T.close();

       //set data.
//       readmat("oleft.txt", o_left);
//       readmat("oright.txt", o_right);
//   //    0.9992743437057664, 0.005113460405459317, -0.03774438413978537;
//   //      -0.005386477346865726, 0.9999600368138971, -0.007135169019802929;
//   //      0.03770639034966863, 0.00733330060963363, 0.9992619530578392
//       double rdata[3][3] = {{0.999274,0.005113,-0.037744},{-0.005386,0.99996,-0.007135},{0.037706, 0.0073333, 0.9992619}};
//       R = Mat(3,3,CV_64FC1,rdata);
//   //    0.5601016654248652;
//   //      -0.03630544292511217;
//   //      -0.8276279594131074
//       double tdata[3]={0.560101,-0.036305,-0.827628};
//       T = Mat(3,1,CV_64FC1,tdata);



       double err = updateModel(o_left,o_right,R,T,m_left,m_right);
        cout<<"err:"<<err<<endl;

//       _mleft.open("mleft.txt");
//       _mleft<<m_left;
//       _mright.open("mright.txt");
//       _mright<<m_right;
//       _mleft.close();
//       _mright.close();
       if(fabs(err-olderr) < REPROJECT_ERR_THRE){
            break;
       }
       olderr = err;
    }
}

void AutoPosEstimator::updatePose(const Mat &corres_left_m, const Mat &corres_right_m, const Mat &corres_left_o, const Mat &corres_right_o,
                                  const Mat &oriR, const Mat &oriT, Mat &R, Mat &T){
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



//        [R_opt, T_opt] = UpdatePose(X1_m, X2_m, X1_o, X2_o, R, T)

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
        double p[6];
        //p: Rx Ry Rz Tx Ty Tz
        Mat _r;
        Rodrigues(oriR,_r);
        p[0]=_r.at<double>(0);
        p[1]=_r.at<double>(1);
        p[2]=_r.at<double>(2);
        p[3]=oriT.at<double>(0);
        p[4]=oriT.at<double>(1);
        p[5]=oriT.at<double>(2);

        OptData data;
//        fstream corresl,corresr;
//        corresl.open("cl.txt");
//        corresr.open("cr.txt");
//        corresl<<corres_left_o<<endl;
//        corresr<<corres_right_o<<endl;
//        exit(0);
        data.corres_left_m = corres_left_m.clone();
        data.corres_right_m = corres_right_m.clone();
        data.corres_left_o = corres_left_o.clone();
        data.corres_right_o = corres_right_o.clone();
        data.T_norm = norm(oriT);
        data.corres_size = corres_left.size();
        //Rx,Ry,Rz,Tx,Ty,Tz
        /* I/O: initial parameter estimates. On output contains the estimated solution */
        double* x = new double[data.corres_size*2];
        /* I: measurement vector. NULL implies a zero vector */
        int m = 6;
        /* I: parameter vector dimension (i.e. #unknowns) */
        int n = data.corres_size*2;
        /* I: measurement vector dimension */
        int itmax = 10000;
        /* I: maximum number of iterations */

        memset(x, 0.0, sizeof(double)*n);
        //memset(p, 0.0, sizeof(double)*m);
        // set initial estimation to all zero
        //data.print();


        // optimize without analytical Jacobian
        int ret = dlevmar_dif(Xm2EpiLineError, p, x, m, n, itmax, opts, info,NULL, NULL, &data);  // no Jacobian
        cout<<"||e||_2:"<<info[1]<<endl;
        cout<<"stop reason:"<<info[6]<<endl;
        cout<<"num of iter:"<<ret<<endl;
        T = oriT.clone();
        //R = _r.clone();
        _r.at<double>(0) = p[0];
        _r.at<double>(1) = p[1];
        _r.at<double>(2) = p[2];
        T.at<double>(0) = p[3];
        T.at<double>(1) = p[4];
        T.at<double>(2) = p[5];

        //T=oriT;

        T = T/norm(T)*data.T_norm;
        Rodrigues(_r,R);
     //   cout<<p[3]<<" "<<p[4]<<" "<<p[5];
        cout<<"R:"<<R<<endl;
        cout<<"T:"<<T<<endl;
        cout<<"oriR:"<<oriR<<endl;
        cout<<"oriT:"<<oriT<<endl;

        delete []x;
}

double AutoPosEstimator::updateModel(const Mat &corres_left_o,
                                     const Mat &corres_right_o,
                                     const Mat &R, const Mat &T,
                                     Mat &corres_left_m,
                                     Mat &corres_right_m){
    double err = 0.0;
    Mat E = Skew(T)*R;
    //cout<<"E:"<<E<<endl;
    Mat e2; //e2: 3x1

    //solve(E.t(), Mat::zeros(3,1,CV_64FC1), e2, DECOMP_EIG);
    SVD::solveZ(E.t(),e2);
    e2 = e2/norm(e2);
   // cout<<"e2:"<<e2<<endl;
    double _d[3]={0,0,1};
    Mat e3(1,3,CV_64FC1,_d);
    Mat e3_s = Skew(e3);
    Mat N1(1,3,CV_64FC1);
    Mat N2;
//    cout<<"e2:"<<e2<<endl;
//    cout<<"e3:"<<e3<<endl;
    while(1){
        //while(1)
        //            a = rand(1);
        //            b = rand(1);
        //            c = -(e2(1)*a + e2(2)*b) / e2(3);
        //            N1 = [a; b; c];
        //            N1 = N1 / norm(N1);
        //            if N1 ~= e2
        //                N2 = cross(e2, N1);
        //                break;
        //            end
        //        end
//        double a = ((double)rand()/RAND_MAX);
//        double b = ((double)rand()/RAND_MAX);
        double a = 0.1;
        double b = 0.3;
        //c = -(e2(1)*a + e2(2)*b) / e2(3);
        double c = -(e2.at<double>(0)*a+e2.at<double>(1)*b)/e2.at<double>(2);
        double tmp[3] = {a,b,c};
        N1.at<double>(0)=a;
        N1.at<double>(1)=b;
        N1.at<double>(2)=c;
        N1 = N1/norm(N1);
        if(N1.at<double>(0)!=e2.at<double>(0)){
            N2 = e2.cross(N1.t());
            break;
        }
    }
    Mat B = e3_s.t()*e3_s;
    Mat D = B;
    //triangulate each point.
    for(int i = 0; i < corres_left_o.rows; i++){
       // cout<<"N1 0:"<<N1<<endl;
        Mat x1_o = corres_left_o.row(i);
        Mat x2_o = corres_right_o.row(i);
//        cout<<"x1_o:"<<x1_o<<endl;
//        cout<<"x2_o:"<<x2_o<<endl;
        Mat x1_s = Skew(x1_o);
        Mat x2_s = Skew(x2_o);
        //            A = eye(3) - (e3_s * x2_o * x2_o' * e3_s' + x2_s * e3_s + e3_s * x2_s);
        //            C = eye(3) - (e3_s * x1_o * x1_o' * e3_s' + x1_s * e3_s + e3_s * x1_s);
        Mat A = Mat::eye(3,3,CV_64FC1) - (e3_s * x2_o.t() * x2_o * e3_s.t() + x2_s * e3_s + e3_s * x2_s);
        Mat C = Mat::eye(3,3,CV_64FC1) - (e3_s * x1_o.t() * x1_o * e3_s.t() + x1_s * e3_s + e3_s * x1_s);
//        cout<<"A:"<<A<<endl;
//        cout<<"C:"<<C<<endl;
        //get the boundary.
        //            l2_b1 = cross(e2, x2_o);
        //            l2_b2 = cross(e2, R * x1_o);
        //            l2_b1 = l2_b1 / norm(l2_b1);
        //            l2_b2 = l2_b2 / norm(l2_b2);
        //            theta_b1 = acos(l2_b1' * N1);
        //            theta_b2 = acos(l2_b2' * N1);
        Mat l2_b1 = e2.cross(x2_o.t());
        Mat product = R*x1_o.t();
        Mat l2_b2 = e2.cross(product);
        l2_b1 = l2_b1/norm(l2_b1);
        l2_b2 = l2_b2/norm(l2_b2);
        //cout<<"N1 1:"<<N1<<endl;
        double dot1 = l2_b1.dot(N1.t());
        double dot2 = l2_b2.dot(N1.t());
        double theta_b1 = acos(dot1);
        double theta_b2 = acos(dot2);
        double lb = min(theta_b1,theta_b2);
        double ub = max(theta_b1,theta_b2);

        //begin to optimize.
        double p = (lb+ub)/2;
        double x = 0;
        int m = 1;
        int n = 1;
        int itmax = 10000;
        // Options to the solver, see the manual of the library
        double opts[]={0.1, 0.0001, 0.0001, 0.0001};

       // cout<<"N1 2:"<<N1<<endl;
        // Output information from the solver
        double info[9];
        modelOptData data;
        data.A = A.clone();
        data.B = B.clone();
        data.C = C.clone();
        data.D = D.clone();
        data.N1 = N1.clone();
        data.N2 = N2.clone();
        data.R = R.clone();
        double desc=(ub-lb)/100.0;
        //cout<<"before:"<<p<<endl;

        linearSearchSolver(Xm2XoError,&p,&x,desc,lb,ub,reinterpret_cast<void*>(&data));

        //int ret = dlevmar_bc_dif(Xm2XoError,&p,&x,m,n,&lb,&ub,NULL,itmax,opts,info,
                                // NULL,NULL,reinterpret_cast<void*>(&data));
        //            l2 = cos(theta) * N1 + sin(theta) * N2;
        //            l1 = R' * l2;
        //            l2_s = Skew(l2);
        //            l1_s = Skew(l1);
        //            x1_m = (e3_s * l1 * l1' * e3_s' * x1_o + l1_s' * l1_s * e3) / (e3' * l1_s' * l1_s * e3);
        //            x2_m = (e3_s * l2 * l2' * e3_s' * x2_o + l2_s' * l2_s * e3) / (e3' * l2_s' * l2_s * e3);
        //            x1_m = x1_m / x1_m(3);
        //            x2_m = x2_m / x2_m(3);
        //            X1_m(:,i) = x1_m;
        //            X2_m(:,i) = x2_m;
        //            err = err + norm(x1_m - x1_o) + norm(x2_m - x2_o);
        double theta = p;
        //cout<<"after:"<<p<<endl;
        Mat l2 = cos(theta)*N1 + sin(theta)*N2.t();//l2: 1x3
        Mat l1 = R.t()*l2.t(); //l1: 3x1
        Mat l2_s = Skew(l2);
        Mat l1_s = Skew(l1);
        //e3 1x3
        Mat x1_m = Mat(e3_s * l1 * l1.t() * e3_s.t() * x1_o.t() + l1_s.t()*l1_s*e3.t())/
                Mat(e3 * l1_s.t() * l1_s * e3.t()).at<double>(0);// x1_m: 3x1
        Mat x2_m = Mat(e3_s * l2.t() * l2 * e3_s.t() * x2_o.t() + l2_s.t()*l2_s*e3.t())/
                Mat(e3 * l2_s.t() * l2_s * e3.t()).at<double>(0);// x2_m: 3x1
        x1_m = x1_m/x1_m.at<double>(2);
        x2_m = x2_m/x2_m.at<double>(2);
       // cout<<"N1:"<<N1<<"N2:"<<N2<<"l1:"<<l1<<"l2:"<<l2<<"x1_m:"<<x1_m<<"x1_o:"<<x1_o<<"x2_m:"<<x2_m<<"x2_o:"<<x2_o<<endl;
       // cout<<"N1 3:"<<N1<<endl;
        corres_left_m.row(i) = x1_m.t();
        //cout<<"N1 4:"<<N1<<endl;
        corres_right_m.row(i) = x2_m.t();
        //cout<<"N1 5:"<<N1<<endl;
        Mat a = x1_m.t()-x1_o;
        Mat b = x2_m.clone().t()-x2_o.clone();
        //cout<<"N1 6:"<<N1<<endl;

        //cout<<"N1 7:"<<N1<<endl;
        err = err + norm(a)+norm(b);
        //cout<<"N1 8:"<<N1<<endl;
    }
    return err;
}

void AutoPosEstimator::exportImg(){
    string leftname=this->id+"_left.jpg";
    string rightname=this->id+"_right.jpg";
    imwrite(leftname,left_rect);
    imwrite(rightname,right_rect);
}

void AutoPosEstimator::setid(string _id){
    this->id=_id;
}

Mat Skew(const Mat &m){
//    S = [0, -s(3), s(2);
//         s(3), 0, -s(1);
//         -s(2), s(1), 0];
    Matx33d ans(0,-m.at<double>(2),m.at<double>(1),
                m.at<double>(2),0,-m.at<double>(0),
                -m.at<double>(1),m.at<double>(0),0);
    return Mat(ans);
}
