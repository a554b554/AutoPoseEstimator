% Intrinsic and Extrinsic Camera Parameters
%
% This script file can be directly excecuted under Matlab to recover the camera intrinsic and extrinsic parameters.
% IMPORTANT: This file contains neither the structure of the calibration objects nor the image coordinates of the calibration points.
%            All those complementary variables are saved in the complete matlab data file Calib_Results.mat.
% For more information regarding the calibration model visit http://www.vision.caltech.edu/bouguetj/calib_doc/


%-- Focal length:
fc = [ 903.235209369343693 ; 904.207165281198172 ];

%-- Principal point:
cc = [ 669.854564621948612 ; 363.794322023507448 ];

%-- Skew coefficient:
alpha_c = 0.000000000000000;

%-- Distortion coefficients:
kc = [ 0.077158218566613 ; 0.260407886014696 ; 0.003788796647944 ; 0.008670304713174 ; 0.000000000000000 ];

%-- Focal length uncertainty:
fc_error = [ 13.074650113427479 ; 13.239451511550673 ];

%-- Principal point uncertainty:
cc_error = [ 19.879713002578733 ; 16.068817423324472 ];

%-- Skew coefficient uncertainty:
alpha_c_error = 0.000000000000000;

%-- Distortion coefficients uncertainty:
kc_error = [ 0.052996003690012 ; 0.401523456590616 ; 0.008090228643585 ; 0.009987223051702 ; 0.000000000000000 ];

%-- Image size:
nx = 1280;
ny = 720;


%-- Various other variables (may be ignored if you do not use the Matlab Calibration Toolbox):
%-- Those variables are used to control which intrinsic parameters should be optimized

n_ima = 18;						% Number of calibration images
est_fc = [ 1 ; 1 ];					% Estimation indicator of the two focal variables
est_aspect_ratio = 1;				% Estimation indicator of the aspect ratio fc(2)/fc(1)
center_optim = 1;					% Estimation indicator of the principal point
est_alpha = 0;						% Estimation indicator of the skew coefficient
est_dist = [ 1 ; 1 ; 1 ; 1 ; 0 ];	% Estimation indicator of the distortion coefficients


%-- Extrinsic parameters:
%-- The rotation (omc_kk) and the translation (Tc_kk) vectors for every calibration image and their uncertainties

%-- Image #1:
omc_1 = [ -2.075505e+00 ; -1.908644e+00 ; 4.157631e-01 ];
Tc_1  = [ -7.765995e+00 ; -2.728222e+01 ; 1.936150e+02 ];
omc_error_1 = [ 1.877927e-02 ; 1.395502e-02 ; 3.079450e-02 ];
Tc_error_1  = [ 4.287677e+00 ; 3.426942e+00 ; 2.708489e+00 ];

%-- Image #2:
omc_2 = [ -1.814874e+00 ; -1.300674e+00 ; -3.384133e-01 ];
Tc_2  = [ -1.407129e+01 ; -4.120888e+01 ; 1.970825e+02 ];
omc_error_2 = [ 1.503408e-02 ; 1.698937e-02 ; 2.176146e-02 ];
Tc_error_2  = [ 4.401112e+00 ; 3.511023e+00 ; 2.965993e+00 ];

%-- Image #3:
omc_3 = [ 2.239509e+00 ; 1.804291e+00 ; 2.736911e-01 ];
Tc_3  = [ -4.482022e+01 ; -2.166939e+01 ; 1.783213e+02 ];
omc_error_3 = [ 1.812371e-02 ; 1.587557e-02 ; 2.794841e-02 ];
Tc_error_3  = [ 4.003193e+00 ; 3.225301e+00 ; 2.893540e+00 ];

%-- Image #4:
omc_4 = [ 2.627730e+00 ; 1.400208e+00 ; 4.251240e-01 ];
Tc_4  = [ -4.279641e+01 ; -5.463587e+00 ; 1.932806e+02 ];
omc_error_4 = [ 2.200156e-02 ; 1.051441e-02 ; 3.146231e-02 ];
Tc_error_4  = [ 4.322953e+00 ; 3.486567e+00 ; 3.174418e+00 ];

%-- Image #5:
omc_5 = [ -1.808582e+00 ; -1.698473e+00 ; 7.092922e-01 ];
Tc_5  = [ -4.117491e+00 ; -2.749662e+01 ; 2.019286e+02 ];
omc_error_5 = [ 2.004655e-02 ; 1.340629e-02 ; 2.402619e-02 ];
Tc_error_5  = [ 4.469762e+00 ; 3.578904e+00 ; 2.635682e+00 ];

%-- Image #6:
omc_6 = [ 2.159153e+00 ; 1.664617e+00 ; -4.847610e-01 ];
Tc_6  = [ -1.902451e+01 ; -1.461922e+01 ; 2.017382e+02 ];
omc_error_6 = [ 1.421002e-02 ; 1.757606e-02 ; 2.859125e-02 ];
Tc_error_6  = [ 4.451965e+00 ; 3.573436e+00 ; 2.900880e+00 ];

%-- Image #7:
omc_7 = [ -2.192447e+00 ; -1.624499e+00 ; 3.526230e-01 ];
Tc_7  = [ -1.111082e+01 ; -3.596557e+01 ; 2.073622e+02 ];
omc_error_7 = [ 1.932459e-02 ; 1.156720e-02 ; 3.197036e-02 ];
Tc_error_7  = [ 4.616082e+00 ; 3.679553e+00 ; 2.921534e+00 ];

%-- Image #8:
omc_8 = [ -2.003777e+00 ; -1.340846e+00 ; -3.894677e-01 ];
Tc_8  = [ -4.215785e+01 ; -3.114139e+01 ; 2.021300e+02 ];
omc_error_8 = [ 1.625182e-02 ; 1.543860e-02 ; 2.467114e-02 ];
Tc_error_8  = [ 4.487886e+00 ; 3.646897e+00 ; 3.115330e+00 ];

%-- Image #9:
omc_9 = [ -2.071479e+00 ; -1.554714e+00 ; -5.298657e-01 ];
Tc_9  = [ -2.106168e+01 ; -3.042962e+01 ; 1.910759e+02 ];
omc_error_9 = [ 1.475920e-02 ; 1.766126e-02 ; 2.476459e-02 ];
Tc_error_9  = [ 4.252509e+00 ; 3.408260e+00 ; 2.948382e+00 ];

%-- Image #10:
omc_10 = [ -2.094424e+00 ; -1.545757e+00 ; -2.556727e-01 ];
Tc_10  = [ -3.897680e+01 ; -3.235971e+01 ; 2.016099e+02 ];
omc_error_10 = [ 1.682230e-02 ; 1.494540e-02 ; 2.777615e-02 ];
Tc_error_10  = [ 4.477707e+00 ; 3.627350e+00 ; 3.083383e+00 ];

%-- Image #11:
omc_11 = [ 1.738197e+00 ; 2.140299e+00 ; -1.021857e+00 ];
Tc_11  = [ -6.762790e+00 ; -1.322184e+01 ; 2.216931e+02 ];
omc_error_11 = [ 9.575109e-03 ; 2.182186e-02 ; 2.716025e-02 ];
Tc_error_11  = [ 4.880105e+00 ; 3.928539e+00 ; 2.964451e+00 ];

%-- Image #12:
omc_12 = [ 2.315118e+00 ; 2.010996e+00 ; -2.407775e-02 ];
Tc_12  = [ -1.271019e+01 ; -2.556724e+01 ; 1.834641e+02 ];
omc_error_12 = [ 1.962870e-02 ; 1.792008e-02 ; 3.696113e-02 ];
Tc_error_12  = [ 4.059293e+00 ; 3.254059e+00 ; 2.671855e+00 ];

%-- Image #13:
omc_13 = [ 2.818792e+00 ; 8.351626e-01 ; -3.212889e-02 ];
Tc_13  = [ -1.341100e+01 ; -1.436875e+01 ; 1.971580e+02 ];
omc_error_13 = [ 2.133285e-02 ; 9.756841e-03 ; 3.744286e-02 ];
Tc_error_13  = [ 4.356012e+00 ; 3.502431e+00 ; 2.946367e+00 ];

%-- Image #14:
omc_14 = [ 2.626267e+00 ; 1.029078e+00 ; -5.179689e-02 ];
Tc_14  = [ -1.854355e+01 ; -1.485576e+01 ; 1.941688e+02 ];
omc_error_14 = [ 1.952109e-02 ; 1.193225e-02 ; 3.309627e-02 ];
Tc_error_14  = [ 4.288434e+00 ; 3.448763e+00 ; 2.931860e+00 ];

%-- Image #15:
omc_15 = [ 2.444706e+00 ; 1.486119e+00 ; 3.785750e-01 ];
Tc_15  = [ -5.132169e+01 ; -5.987396e+00 ; 1.906273e+02 ];
omc_error_15 = [ 1.971925e-02 ; 1.229199e-02 ; 2.910585e-02 ];
Tc_error_15  = [ 4.291258e+00 ; 3.463436e+00 ; 3.198259e+00 ];

%-- Image #16:
omc_16 = [ 2.083178e+00 ; 1.340408e+00 ; 7.762838e-01 ];
Tc_16  = [ -2.630492e+01 ; -1.665556e+01 ; 1.868419e+02 ];
omc_error_16 = [ 2.168768e-02 ; 1.274151e-02 ; 2.216792e-02 ];
Tc_error_16  = [ 4.151033e+00 ; 3.340621e+00 ; 3.071277e+00 ];

%-- Image #17:
omc_17 = [ 2.467308e+00 ; 1.429942e+00 ; 4.043634e-01 ];
Tc_17  = [ -4.949639e+01 ; 6.681777e-02 ; 1.914983e+02 ];
omc_error_17 = [ 2.004380e-02 ; 1.115067e-02 ; 2.895080e-02 ];
Tc_error_17  = [ 4.306987e+00 ; 3.474333e+00 ; 3.252568e+00 ];

%-- Image #18:
omc_18 = [ -1.867682e+00 ; -1.334226e+00 ; 3.929833e-01 ];
Tc_18  = [ -8.335762e+00 ; -4.479246e+01 ; 2.093971e+02 ];
omc_error_18 = [ 1.859924e-02 ; 1.248746e-02 ; 2.365683e-02 ];
Tc_error_18  = [ 4.682316e+00 ; 3.722644e+00 ; 2.868032e+00 ];

