#include "cpu_sncc.h"

Mat CpuSNCC::g_disp_r = Mat::zeros(image_height, image_width, CV_32F);
Mat CpuSNCC::g_conf_r = Mat::zeros(image_height, image_width, CV_32F);
int CpuSNCC::image_width = 1280;
int CpuSNCC::image_height = 720;

Mat CpuSNCC::Process(Mat img_left, Mat img_right) {
	image_width = img_left.cols;
	image_height = img_left.rows;
	Mat left_float, right_float;
	Mat left_gray, right_gray, left_gauss, right_gauss;

	Mat disp_l(image_height, image_width, CV_32F);
	Mat conf_l(image_height, image_width, CV_32F);
	Mat checked(image_height, image_width, CV_32F);
	Mat confidenced(image_height, image_width, CV_32F);
	Mat disp_vis(image_height, image_width, CV_8UC3);
	if(img_left.channels() == 3)
		cvtColor(img_left, left_gray, CV_RGB2GRAY);
	else
		left_gray = img_left.clone();
	left_gray.convertTo(left_float, CV_32F);
	left_float *= 1 / 255.0;
	GaussianBlur(left_float, left_gauss, Size(3, 3), 0.9, 0.9,
			BORDER_REPLICATE);
	if(img_right.channels() == 3)
		cvtColor(img_right, right_gray, CV_RGB2GRAY);
	else
		right_gray = img_right.clone();

	right_gray.convertTo(right_float, CV_32F);
	right_float *= 1 / 255.0;
	GaussianBlur(right_float, right_gauss, Size(3, 3), 0.9, 0.9,
			BORDER_REPLICATE);
	StereoSNCC(right_gauss, left_gauss, WINDOW_SIZE, DMIN, DMAX, disp_l,
			conf_l);
	CrossCheck(disp_l, g_disp_r, 0.1, checked);
	ConfidenceCheck(conf_l, g_conf_r, 0.70, checked, confidenced);
	FloatRGB2Jet(confidenced, disp_vis);
	return disp_vis;
}

void CpuSNCC::StereoSNCC(const Mat& left, const Mat& right, const int window_size,
		const int dmin, const int dmax, Mat& disp, Mat& conf) {
	int sz[] = { image_height, image_width, dmax - dmin };
	Mat scores(3, sz, CV_32F, Scalar::all(0));

	Mat left_mean, right_mean, left_sig, right_sig, left_sq, right_sq;
	Mat left_mean_sq, right_mean_sq, left_sq_filt, right_sq_filt, left_sig_sq,
			right_sig_sq;

	boxFilter(left, left_mean, -1, Size(3, 3), Point(-1, -1), true,
			BORDER_REPLICATE);
	boxFilter(right, right_mean, -1, Size(3, 3), Point(-1, -1), true,
			BORDER_REPLICATE);

	multiply(left, left, left_sq, 1, -1);
	multiply(right, right, right_sq, 1, -1);

	boxFilter(left_sq, left_sq_filt, -1, Size(3, 3), Point(-1, -1), true,
			BORDER_REPLICATE);
	boxFilter(right_sq, right_sq_filt, -1, Size(3, 3), Point(-1, -1), true,
			BORDER_REPLICATE);

	multiply(left_mean, left_mean, left_mean_sq, 1, -1);
	multiply(right_mean, right_mean, right_mean_sq, 1, -1);

	subtract(left_sq_filt, left_mean_sq, left_sig_sq);
	subtract(right_sq_filt, right_mean_sq, right_sig_sq);

	sqrt(left_sig_sq, left_sig);
	sqrt(right_sig_sq, right_sig);

	Mat M;
	M = Mat::zeros(2, 3, CV_32F);
	M.at<float>(0, 0) = 1.0;
	M.at<float>(1, 1) = 1.0;

	for (int d = dmin; d < dmax; d++) {
		Mat shifted_img, shifted_mean, shifted_sig;
		M.at<float>(0, 2) = (float) d;
		warpAffine(left, shifted_img, M, Size(image_width, image_height), INTER_LINEAR,
				BORDER_REPLICATE);
		for (int i = 0; i < image_height; i++) {
			for (int j = 0; j < d; j++) {
				shifted_img.at<float>(i, j) = 0.0;
			}
		}

		warpAffine(left_mean, shifted_mean, M, Size(image_width, image_height),
				INTER_LINEAR, BORDER_REPLICATE);
		for (int i = 0; i < image_height; i++) {
			for (int j = 0; j < d; j++) {
				shifted_mean.at<float>(i, j) = 0.0;
			}
		}

		warpAffine(left_sig, shifted_sig, M, Size(image_width, image_height),
				INTER_LINEAR, BORDER_REPLICATE);
		for (int i = 0; i < image_height; i++) {
			for (int j = 0; j < d; j++) {
				shifted_sig.at<float>(i, j) = 0.0;
			}
		}

		Mat product, product_filt, diff, NCC, SNCC, mean_product, sig_product;
		multiply(shifted_img, right, product, 1, -1);

		boxFilter(product, product_filt, -1, Size(3, 3), Point(-1, -1), true,
				BORDER_REPLICATE);

		multiply(shifted_mean, right_mean, mean_product, 1, -1);
		subtract(product_filt, mean_product, diff);

		multiply(shifted_sig, right_sig, sig_product, 1, -1);
		divide(diff, sig_product, NCC, 1, -1);

		for (int i = 0; i < image_height; i++) {
			for (int j = 0; j < image_width; j++) {
				if (cvIsInf(NCC.at<float>(i, j))
						|| cvIsNaN(NCC.at<float>(i, j)))
					NCC.at<float>(i, j) = 0;
			}
		}
		boxFilter(NCC, SNCC, -1, Size(WINDOW_SIZE, WINDOW_SIZE), Point(-1, -1),
				true, BORDER_REPLICATE);

		for (int i = 0; i < image_height; i++) {
			for (int j = 0; j < image_width; j++) {
				scores.at<float>(i, j, d - dmin) = SNCC.at<float>(i, j);
			}
		}
	}

	for (int i = 0; i < image_height; i++) {
		for (int j = 0; j < image_width; j++) {
			float ind, val;
			ind = 0.0;
			val = -1.0;
			for (int k = 0; k < dmax - dmin; k++) {
				if (scores.at<float>(i, j, k) > val
						&& !cvIsInf(scores.at<float>(i, j, k))
						&& !cvIsNaN(scores.at<float>(i, j, k))) {
					val = scores.at<float>(i, j, k);
					ind = (float) k;
				}
			}

			disp.at<float>(i, j) = ind + (float) dmin;
			conf.at<float>(i, j) = val;
		}
	}

	for (int i = 0; i < image_height; i++) {
		for (int j = 0; j < image_width; j++) {
			float ind, val;
			ind = 0.0;
			val = -1.0;
			for (int k = 0; k < dmax - dmin; k++) {
				if (k < (image_width - j - WINDOW_SIZE)
						&& scores.at<float>(i, j + k, k) > val
						&& !cvIsInf(scores.at<float>(i, j + k, k))
						&& !cvIsNaN(scores.at<float>(i, j + k, k))) {
					val = scores.at<float>(i, j + k, k);
					ind = (float) k;
				}
			}

			g_disp_r.at<float>(i, j) = ind + (float) dmin;
			g_conf_r.at<float>(i, j) = val;
		}
	}
}

void CpuSNCC::CrossCheck(const Mat& left, const Mat& right, const float conf_threshold,
		Mat& checked) {
	for (int i = 0; i < image_height; i++) {
		for (int j = 0; j < image_width; j++) {
			float d_l = left.at<float>(i, j);
			float d_r = 0.0;
			if (j >= d_l) {
				d_r = right.at<float>(i, j - d_l);
			}
			if (fabs((d_r - d_l) / d_r) < conf_threshold)
				checked.at<float>(i, j) = d_l;
			else {
				checked.at<float>(i, j) = 0.0;
			}
		}
	}
}

void CpuSNCC::ConfidenceCheck(const Mat& conf_left, const Mat& conf_right,
		const float conf_threshold, const Mat& checked, Mat& confidenced) {
	for (int i = 0; i < image_height; i++) {
		for (int j = 0; j < image_width; j++) {
			if (conf_left.at<float>(i, j) < conf_threshold
					&& conf_right.at<float>(i, j) < conf_threshold) {
				confidenced.at<float>(i, j) = 0;
			} else {
				confidenced.at<float>(i, j) = checked.at<float>(i, j);
			}
		}
	}
}

void CpuSNCC::FloatRGB2Jet(const Mat& in, Mat& out) {
	float value;
	float fourValue;
	float red, green, blue;

	for (int row = 0; row < in.rows; row++) {
		for (int col = 0; col < in.cols; col++) {
			value = (float) (in.at<float>(row, col) - DMIN)
					/ (float) (DMAX - DMIN);
			fourValue = 4 * value;
			red = min(fourValue - 1.5, -fourValue + 4.5);
			green = min(fourValue - 0.5, -fourValue + 3.5);
			blue = min(fourValue + 0.5, -fourValue + 2.5);
			red = (red < 0) ? 0.0f : red;
			red = (red > 1.0) ? 1.0f : red;
			green = (green < 0) ? 0.0f : green;
			green = (green > 1.0) ? 1.0f : green;
			blue = (blue < 0) ? 0.0f : blue;
			blue = (blue > 1.0) ? 1.0f : blue;

			out.data[row * out.step + 3 * col] = (unsigned char) (blue * 255);
			out.data[row * out.step + 3 * col + 1] = (unsigned char) (green
					* 255);
			out.data[row * out.step + 3 * col + 2] =
					(unsigned char) (red * 255);
		}
	}

	return;
}
