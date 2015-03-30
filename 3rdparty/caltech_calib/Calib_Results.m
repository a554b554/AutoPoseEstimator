% Intrinsic and Extrinsic Camera Parameters
%
% This script file can be directly excecuted under Matlab to recover the camera intrinsic and extrinsic parameters.
% IMPORTANT: This file contains neither the structure of the calibration objects nor the image coordinates of the calibration points.
%            All those complementary variables are saved in the complete matlab data file Calib_Results.mat.
% For more information regarding the calibration model visit http://www.vision.caltech.edu/bouguetj/calib_doc/


%-- Focal length:
fc = [ 895.463440789565766 ; 887.802958078796337 ];

%-- Principal point:
cc = [ 656.768321357957916 ; 366.585660026619337 ];

%-- Skew coefficient:
alpha_c = 0.000000000000000;

%-- Distortion coefficients:
kc = [ 0.193093228249494 ; -0.261596567150555 ; 0.012859058490521 ; 0.019464706393658 ; 0.000000000000000 ];

%-- Focal length uncertainty:
fc_error = [ 14.043389161366825 ; 12.224545366124342 ];

%-- Principal point uncertainty:
cc_error = [ 20.801350720933353 ; 11.758783655211428 ];

%-- Skew coefficient uncertainty:
alpha_c_error = 0.000000000000000;

%-- Distortion coefficients uncertainty:
kc_error = [ 0.051428401423472 ; 0.074299743544664 ; 0.005089573834023 ; 0.012888110083113 ; 0.000000000000000 ];

%-- Image size:
nx = 1280;
ny = 720;


%-- Various other variables (may be ignored if you do not use the Matlab Calibration Toolbox):
%-- Those variables are used to control which intrinsic parameters should be optimized

n_ima = 20;						% Number of calibration images
est_fc = [ 1 ; 1 ];					% Estimation indicator of the two focal variables
est_aspect_ratio = 1;				% Estimation indicator of the aspect ratio fc(2)/fc(1)
center_optim = 1;					% Estimation indicator of the principal point
est_alpha = 0;						% Estimation indicator of the skew coefficient
est_dist = [ 1 ; 1 ; 1 ; 1 ; 0 ];	% Estimation indicator of the distortion coefficients


%-- Extrinsic parameters:
%-- The rotation (omc_kk) and the translation (Tc_kk) vectors for every calibration image and their uncertainties

%-- Image #1:
omc_1 = [ -2.115791e+00 ; -2.043221e+00 ; 3.278757e-01 ];
Tc_1  = [ -2.259292e+02 ; -8.984631e+01 ; 7.428157e+02 ];
omc_error_1 = [ 1.614770e-02 ; 1.261033e-02 ; 3.177056e-02 ];
Tc_error_1  = [ 1.711996e+01 ; 1.006947e+01 ; 1.157713e+01 ];

%-- Image #2:
omc_2 = [ 1.613478e+00 ; 2.190698e+00 ; -1.354122e+00 ];
Tc_2  = [ -1.367018e+02 ; -7.679189e+01 ; 7.775505e+02 ];
omc_error_2 = [ 1.113628e-02 ; 1.843342e-02 ; 3.023063e-02 ];
Tc_error_2  = [ 1.811834e+01 ; 1.044510e+01 ; 1.031469e+01 ];

%-- Image #3:
omc_3 = [ -1.723721e+00 ; -1.831023e+00 ; 5.681204e-01 ];
Tc_3  = [ -1.676905e+02 ; -1.017578e+02 ; 7.677577e+02 ];
omc_error_3 = [ 1.571883e-02 ; 1.498597e-02 ; 2.396950e-02 ];
Tc_error_3  = [ 1.766693e+01 ; 1.030478e+01 ; 1.104231e+01 ];

%-- Image #4:
omc_4 = [ 2.245551e+00 ; 1.793968e+00 ; 8.479438e-01 ];
Tc_4  = [ -3.775477e+02 ; -1.208292e+02 ; 6.319354e+02 ];
omc_error_4 = [ 2.013960e-02 ; 1.765047e-02 ; 3.656724e-02 ];
Tc_error_4  = [ 1.569007e+01 ; 9.387756e+00 ; 1.373388e+01 ];

%-- Image #5:
omc_5 = [ -2.144952e+00 ; -2.022230e+00 ; 3.203469e-01 ];
Tc_5  = [ -2.249114e+02 ; -8.397838e+01 ; 7.362357e+02 ];
omc_error_5 = [ 1.614283e-02 ; 1.239136e-02 ; 3.193593e-02 ];
Tc_error_5  = [ 1.695555e+01 ; 9.977373e+00 ; 1.148704e+01 ];

%-- Image #6:
omc_6 = [ 2.199659e+00 ; 2.034374e+00 ; 9.399195e-01 ];
Tc_6  = [ -2.493840e+02 ; -1.448452e+02 ; 6.568033e+02 ];
omc_error_6 = [ 2.192743e-02 ; 1.639140e-02 ; 2.987925e-02 ];
Tc_error_6  = [ 1.582836e+01 ; 9.170375e+00 ; 1.209669e+01 ];

%-- Image #7:
omc_7 = [ -2.068038e+00 ; -1.774086e+00 ; -9.492585e-02 ];
Tc_7  = [ -1.833743e+02 ; -9.531227e+01 ; 6.996047e+02 ];
omc_error_7 = [ 1.390496e-02 ; 1.431149e-02 ; 2.779976e-02 ];
Tc_error_7  = [ 1.618694e+01 ; 9.411966e+00 ; 1.110746e+01 ];

%-- Image #8:
omc_8 = [ 2.214889e+00 ; 1.617775e+00 ; 5.445457e-01 ];
Tc_8  = [ -3.229842e+02 ; -1.264831e+02 ; 6.197189e+02 ];
omc_error_8 = [ 1.748541e-02 ; 1.881524e-02 ; 3.421322e-02 ];
Tc_error_8  = [ 1.483834e+01 ; 8.755142e+00 ; 1.273598e+01 ];

%-- Image #9:
omc_9 = [ -1.789584e+00 ; -1.958467e+00 ; 6.626587e-01 ];
Tc_9  = [ -1.644076e+02 ; -9.086847e+01 ; 7.464198e+02 ];
omc_error_9 = [ 1.675785e-02 ; 1.416648e-02 ; 2.533130e-02 ];
Tc_error_9  = [ 1.717846e+01 ; 1.002331e+01 ; 1.069969e+01 ];

%-- Image #10:
omc_10 = [ -1.704963e+00 ; -1.711916e+00 ; -9.767893e-01 ];
Tc_10  = [ -2.973130e+02 ; -1.793384e+02 ; 6.303083e+02 ];
omc_error_10 = [ 1.311689e-02 ; 1.512598e-02 ; 2.684753e-02 ];
Tc_error_10  = [ 1.513895e+01 ; 9.012882e+00 ; 1.269627e+01 ];

%-- Image #11:
omc_11 = [ 1.963720e+00 ; 1.832780e+00 ; 1.095522e+00 ];
Tc_11  = [ -3.479552e+02 ; -1.229258e+02 ; 5.934082e+02 ];
omc_error_11 = [ 1.981850e-02 ; 1.448472e-02 ; 2.632009e-02 ];
Tc_error_11  = [ 1.473070e+01 ; 8.778606e+00 ; 1.296540e+01 ];

%-- Image #12:
omc_12 = [ -2.083238e+00 ; -2.064152e+00 ; 1.506810e-01 ];
Tc_12  = [ -2.228941e+02 ; -8.935415e+01 ; 7.365301e+02 ];
omc_error_12 = [ 1.510840e-02 ; 1.368809e-02 ; 3.230946e-02 ];
Tc_error_12  = [ 1.694454e+01 ; 9.973345e+00 ; 1.165013e+01 ];

%-- Image #13:
omc_13 = [ 1.917654e+00 ; 1.490295e+00 ; -2.014806e-01 ];
Tc_13  = [ -3.011430e+02 ; -1.058803e+02 ; 6.845634e+02 ];
omc_error_13 = [ 1.022073e-02 ; 1.805111e-02 ; 2.812057e-02 ];
Tc_error_13  = [ 1.600917e+01 ; 9.533500e+00 ; 1.243507e+01 ];

%-- Image #14:
omc_14 = [ 2.196069e+00 ; 1.988705e+00 ; 6.439361e-01 ];
Tc_14  = [ -2.564129e+02 ; -1.573859e+02 ; 6.582127e+02 ];
omc_error_14 = [ 2.118820e-02 ; 2.223357e-02 ; 3.711494e-02 ];
Tc_error_14  = [ 1.588743e+01 ; 9.200196e+00 ; 1.212262e+01 ];

%-- Image #15:
omc_15 = [ -1.083915e+00 ; -2.445102e+00 ; 1.242780e+00 ];
Tc_15  = [ -7.487371e+01 ; -1.395054e+02 ; 7.631299e+02 ];
omc_error_15 = [ 2.186999e-02 ; 1.801563e-02 ; 2.099306e-02 ];
Tc_error_15  = [ 1.789445e+01 ; 1.021270e+01 ; 9.999595e+00 ];

%-- Image #16:
omc_16 = [ -1.677988e+00 ; -1.761210e+00 ; 6.148553e-01 ];
Tc_16  = [ -1.552823e+02 ; -1.009953e+02 ; 7.690332e+02 ];
omc_error_16 = [ 1.588627e-02 ; 1.532131e-02 ; 2.304288e-02 ];
Tc_error_16  = [ 1.770312e+01 ; 1.030421e+01 ; 1.087454e+01 ];

%-- Image #17:
omc_17 = [ 2.213757e+00 ; 1.167260e+00 ; 3.924430e-01 ];
Tc_17  = [ -3.858397e+02 ; -8.120118e+01 ; 6.290613e+02 ];
omc_error_17 = [ 1.461750e-02 ; 1.650465e-02 ; 2.938346e-02 ];
Tc_error_17  = [ 1.488320e+01 ; 9.155525e+00 ; 1.419553e+01 ];

%-- Image #18:
omc_18 = [ -1.723609e+00 ; -1.475463e+00 ; -1.086724e-02 ];
Tc_18  = [ -1.810939e+02 ; -6.421187e+01 ; 7.250607e+02 ];
omc_error_18 = [ 1.262155e-02 ; 1.729170e-02 ; 2.154999e-02 ];
Tc_error_18  = [ 1.665991e+01 ; 9.741843e+00 ; 1.113724e+01 ];

%-- Image #19:
omc_19 = [ 2.071392e+00 ; 1.236238e+00 ; 1.799676e-01 ];
Tc_19  = [ -3.337588e+02 ; -9.570834e+01 ; 6.475666e+02 ];
omc_error_19 = [ 1.267452e-02 ; 1.700117e-02 ; 2.814743e-02 ];
Tc_error_19  = [ 1.516319e+01 ; 9.160091e+00 ; 1.314906e+01 ];

%-- Image #20:
omc_20 = [ -1.238922e+00 ; -2.140332e+00 ; 8.373807e-01 ];
Tc_20  = [ -8.719746e+01 ; -1.490053e+02 ; 7.441673e+02 ];
omc_error_20 = [ 1.713960e-02 ; 1.746871e-02 ; 2.135435e-02 ];
Tc_error_20  = [ 1.737949e+01 ; 9.942075e+00 ; 1.015890e+01 ];

