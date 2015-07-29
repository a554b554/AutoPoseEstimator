% Intrinsic and Extrinsic Camera Parameters
%
% This script file can be directly excecuted under Matlab to recover the camera intrinsic and extrinsic parameters.
% IMPORTANT: This file contains neither the structure of the calibration objects nor the image coordinates of the calibration points.
%            All those complementary variables are saved in the complete matlab data file Calib_Results.mat.
% For more information regarding the calibration model visit http://www.vision.caltech.edu/bouguetj/calib_doc/


%-- Focal length:
fc = [ 2145.497523256125987 ; 2142.665019475442932 ];

%-- Principal point:
cc = [ 639.500000000000000 ; 359.500000000000000 ];

%-- Skew coefficient:
alpha_c = 0.000000000000000;

%-- Distortion coefficients:
kc = [ -0.544584611473421 ; 0.656494509296493 ; -0.003105771667227 ; -0.003529345190431 ; 0.000000000000000 ];

%-- Focal length uncertainty:
fc_error = [ 14.081224379110935 ; 14.137773481574644 ];

%-- Principal point uncertainty:
cc_error = [ 0.000000000000000 ; 0.000000000000000 ];

%-- Skew coefficient uncertainty:
alpha_c_error = 0.000000000000000;

%-- Distortion coefficients uncertainty:
kc_error = [ 0.022858443868924 ; 0.307022899526637 ; 0.001156384883548 ; 0.000944586258624 ; 0.000000000000000 ];

%-- Image size:
nx = 1280;
ny = 720;


%-- Various other variables (may be ignored if you do not use the Matlab Calibration Toolbox):
%-- Those variables are used to control which intrinsic parameters should be optimized

n_ima = 61;						% Number of calibration images
est_fc = [ 1 ; 1 ];					% Estimation indicator of the two focal variables
est_aspect_ratio = 1;				% Estimation indicator of the aspect ratio fc(2)/fc(1)
center_optim = 0;					% Estimation indicator of the principal point
est_alpha = 0;						% Estimation indicator of the skew coefficient
est_dist = [ 1 ; 1 ; 1 ; 1 ; 0 ];	% Estimation indicator of the distortion coefficients


%-- Extrinsic parameters:
%-- The rotation (omc_kk) and the translation (Tc_kk) vectors for every calibration image and their uncertainties

%-- Image #1:
omc_1 = [ -2.131741e+00 ; -2.223359e+00 ; -1.470587e-01 ];
Tc_1  = [ -3.728945e+01 ; -1.893028e+02 ; 6.177191e+03 ];
omc_error_1 = [ 4.369641e-03 ; 4.945279e-03 ; 8.120409e-03 ];
Tc_error_1  = [ 2.331999e-01 ; 2.779418e-01 ; 4.103033e+01 ];

%-- Image #2:
omc_2 = [ 2.163579e+00 ; 2.261211e+00 ; 2.648281e-01 ];
Tc_2  = [ -8.740176e+02 ; -1.059356e+02 ; 6.090909e+03 ];
omc_error_2 = [ 3.988595e-03 ; 4.327757e-03 ; 8.064124e-03 ];
Tc_error_2  = [ 5.912909e-01 ; 2.554838e-01 ; 4.069378e+01 ];

%-- Image #3:
omc_3 = [ NaN ; NaN ; NaN ];
Tc_3  = [ NaN ; NaN ; NaN ];
omc_error_3 = [ NaN ; NaN ; NaN ];
Tc_error_3  = [ NaN ; NaN ; NaN ];

%-- Image #4:
omc_4 = [ NaN ; NaN ; NaN ];
Tc_4  = [ NaN ; NaN ; NaN ];
omc_error_4 = [ NaN ; NaN ; NaN ];
Tc_error_4  = [ NaN ; NaN ; NaN ];

%-- Image #5:
omc_5 = [ NaN ; NaN ; NaN ];
Tc_5  = [ NaN ; NaN ; NaN ];
omc_error_5 = [ NaN ; NaN ; NaN ];
Tc_error_5  = [ NaN ; NaN ; NaN ];

%-- Image #6:
omc_6 = [ -2.187085e+00 ; -2.154211e+00 ; -1.694605e-02 ];
Tc_6  = [ -2.692097e+02 ; -1.907376e+02 ; 6.275038e+03 ];
omc_error_6 = [ 5.942343e-03 ; 6.263880e-03 ; 1.396684e-02 ];
Tc_error_6  = [ 1.848881e-01 ; 2.321718e-01 ; 4.144066e+01 ];

%-- Image #7:
omc_7 = [ NaN ; NaN ; NaN ];
Tc_7  = [ NaN ; NaN ; NaN ];
omc_error_7 = [ NaN ; NaN ; NaN ];
Tc_error_7  = [ NaN ; NaN ; NaN ];

%-- Image #8:
omc_8 = [ NaN ; NaN ; NaN ];
Tc_8  = [ NaN ; NaN ; NaN ];
omc_error_8 = [ NaN ; NaN ; NaN ];
Tc_error_8  = [ NaN ; NaN ; NaN ];

%-- Image #9:
omc_9 = [ NaN ; NaN ; NaN ];
Tc_9  = [ NaN ; NaN ; NaN ];
omc_error_9 = [ NaN ; NaN ; NaN ];
Tc_error_9  = [ NaN ; NaN ; NaN ];

%-- Image #10:
omc_10 = [ NaN ; NaN ; NaN ];
Tc_10  = [ NaN ; NaN ; NaN ];
omc_error_10 = [ NaN ; NaN ; NaN ];
Tc_error_10  = [ NaN ; NaN ; NaN ];

%-- Image #11:
omc_11 = [ -2.176103e+00 ; -2.196797e+00 ; -1.468685e-01 ];
Tc_11  = [ -1.333502e+03 ; -2.006744e+02 ; 6.280745e+03 ];
omc_error_11 = [ 4.860106e-03 ; 4.300359e-03 ; 1.069585e-02 ];
Tc_error_11  = [ 6.077503e-01 ; 3.059172e-01 ; 4.220580e+01 ];

%-- Image #12:
omc_12 = [ NaN ; NaN ; NaN ];
Tc_12  = [ NaN ; NaN ; NaN ];
omc_error_12 = [ NaN ; NaN ; NaN ];
Tc_error_12  = [ NaN ; NaN ; NaN ];

%-- Image #13:
omc_13 = [ NaN ; NaN ; NaN ];
Tc_13  = [ NaN ; NaN ; NaN ];
omc_error_13 = [ NaN ; NaN ; NaN ];
Tc_error_13  = [ NaN ; NaN ; NaN ];

%-- Image #14:
omc_14 = [ NaN ; NaN ; NaN ];
Tc_14  = [ NaN ; NaN ; NaN ];
omc_error_14 = [ NaN ; NaN ; NaN ];
Tc_error_14  = [ NaN ; NaN ; NaN ];

%-- Image #15:
omc_15 = [ NaN ; NaN ; NaN ];
Tc_15  = [ NaN ; NaN ; NaN ];
omc_error_15 = [ NaN ; NaN ; NaN ];
Tc_error_15  = [ NaN ; NaN ; NaN ];

%-- Image #16:
omc_16 = [ -2.166139e+00 ; -2.158917e+00 ; -1.051978e-01 ];
Tc_16  = [ -1.572389e+03 ; -1.978077e+02 ; 6.412817e+03 ];
omc_error_16 = [ 4.154964e-03 ; 3.701748e-03 ; 9.878861e-03 ];
Tc_error_16  = [ 8.407592e-01 ; 4.118289e-01 ; 4.345101e+01 ];

%-- Image #17:
omc_17 = [ NaN ; NaN ; NaN ];
Tc_17  = [ NaN ; NaN ; NaN ];
omc_error_17 = [ NaN ; NaN ; NaN ];
Tc_error_17  = [ NaN ; NaN ; NaN ];

%-- Image #18:
omc_18 = [ NaN ; NaN ; NaN ];
Tc_18  = [ NaN ; NaN ; NaN ];
omc_error_18 = [ NaN ; NaN ; NaN ];
Tc_error_18  = [ NaN ; NaN ; NaN ];

%-- Image #19:
omc_19 = [ NaN ; NaN ; NaN ];
Tc_19  = [ NaN ; NaN ; NaN ];
omc_error_19 = [ NaN ; NaN ; NaN ];
Tc_error_19  = [ NaN ; NaN ; NaN ];

%-- Image #20:
omc_20 = [ NaN ; NaN ; NaN ];
Tc_20  = [ NaN ; NaN ; NaN ];
omc_error_20 = [ NaN ; NaN ; NaN ];
Tc_error_20  = [ NaN ; NaN ; NaN ];

%-- Image #21:
omc_21 = [ -2.180141e+00 ; -2.144871e+00 ; -1.677304e-01 ];
Tc_21  = [ -2.637186e+02 ; -1.728512e+02 ; 6.384028e+03 ];
omc_error_21 = [ 4.141477e-03 ; 4.318352e-03 ; 7.903086e-03 ];
Tc_error_21  = [ 2.378903e-01 ; 2.876636e-01 ; 4.234716e+01 ];

%-- Image #22:
omc_22 = [ NaN ; NaN ; NaN ];
Tc_22  = [ NaN ; NaN ; NaN ];
omc_error_22 = [ NaN ; NaN ; NaN ];
Tc_error_22  = [ NaN ; NaN ; NaN ];

%-- Image #23:
omc_23 = [ NaN ; NaN ; NaN ];
Tc_23  = [ NaN ; NaN ; NaN ];
omc_error_23 = [ NaN ; NaN ; NaN ];
Tc_error_23  = [ NaN ; NaN ; NaN ];

%-- Image #24:
omc_24 = [ NaN ; NaN ; NaN ];
Tc_24  = [ NaN ; NaN ; NaN ];
omc_error_24 = [ NaN ; NaN ; NaN ];
Tc_error_24  = [ NaN ; NaN ; NaN ];

%-- Image #25:
omc_25 = [ NaN ; NaN ; NaN ];
Tc_25  = [ NaN ; NaN ; NaN ];
omc_error_25 = [ NaN ; NaN ; NaN ];
Tc_error_25  = [ NaN ; NaN ; NaN ];

%-- Image #26:
omc_26 = [ -1.950560e+00 ; -1.951009e+00 ; -5.800837e-01 ];
Tc_26  = [ -7.428842e+02 ; -1.138589e+02 ; 6.260801e+03 ];
omc_error_26 = [ 1.348832e-03 ; 1.417621e-03 ; 2.231828e-03 ];
Tc_error_26  = [ 2.907710e-01 ; 2.754108e-01 ; 4.213290e+01 ];

%-- Image #27:
omc_27 = [ NaN ; NaN ; NaN ];
Tc_27  = [ NaN ; NaN ; NaN ];
omc_error_27 = [ NaN ; NaN ; NaN ];
Tc_error_27  = [ NaN ; NaN ; NaN ];

%-- Image #28:
omc_28 = [ NaN ; NaN ; NaN ];
Tc_28  = [ NaN ; NaN ; NaN ];
omc_error_28 = [ NaN ; NaN ; NaN ];
Tc_error_28  = [ NaN ; NaN ; NaN ];

%-- Image #29:
omc_29 = [ NaN ; NaN ; NaN ];
Tc_29  = [ NaN ; NaN ; NaN ];
omc_error_29 = [ NaN ; NaN ; NaN ];
Tc_error_29  = [ NaN ; NaN ; NaN ];

%-- Image #30:
omc_30 = [ NaN ; NaN ; NaN ];
Tc_30  = [ NaN ; NaN ; NaN ];
omc_error_30 = [ NaN ; NaN ; NaN ];
Tc_error_30  = [ NaN ; NaN ; NaN ];

%-- Image #31:
omc_31 = [ -1.762820e+00 ; -2.000027e+00 ; -1.018573e+00 ];
Tc_31  = [ -1.113717e+03 ; -2.101654e+02 ; 5.653081e+03 ];
omc_error_31 = [ 1.141601e-03 ; 1.165102e-03 ; 1.895862e-03 ];
Tc_error_31  = [ 6.866334e-01 ; 3.881529e-01 ; 3.946486e+01 ];

%-- Image #32:
omc_32 = [ NaN ; NaN ; NaN ];
Tc_32  = [ NaN ; NaN ; NaN ];
omc_error_32 = [ NaN ; NaN ; NaN ];
Tc_error_32  = [ NaN ; NaN ; NaN ];

%-- Image #33:
omc_33 = [ NaN ; NaN ; NaN ];
Tc_33  = [ NaN ; NaN ; NaN ];
omc_error_33 = [ NaN ; NaN ; NaN ];
Tc_error_33  = [ NaN ; NaN ; NaN ];

%-- Image #34:
omc_34 = [ NaN ; NaN ; NaN ];
Tc_34  = [ NaN ; NaN ; NaN ];
omc_error_34 = [ NaN ; NaN ; NaN ];
Tc_error_34  = [ NaN ; NaN ; NaN ];

%-- Image #35:
omc_35 = [ NaN ; NaN ; NaN ];
Tc_35  = [ NaN ; NaN ; NaN ];
omc_error_35 = [ NaN ; NaN ; NaN ];
Tc_error_35  = [ NaN ; NaN ; NaN ];

%-- Image #36:
omc_36 = [ 2.250734e+00 ; 2.168026e+00 ; 2.714797e-01 ];
Tc_36  = [ -4.008630e+02 ; -3.167105e+02 ; 4.168741e+03 ];
omc_error_36 = [ 2.795481e-03 ; 2.772900e-03 ; 4.410010e-03 ];
Tc_error_36  = [ 2.676792e-01 ; 2.200390e-01 ; 2.782291e+01 ];

%-- Image #37:
omc_37 = [ NaN ; NaN ; NaN ];
Tc_37  = [ NaN ; NaN ; NaN ];
omc_error_37 = [ NaN ; NaN ; NaN ];
Tc_error_37  = [ NaN ; NaN ; NaN ];

%-- Image #38:
omc_38 = [ NaN ; NaN ; NaN ];
Tc_38  = [ NaN ; NaN ; NaN ];
omc_error_38 = [ NaN ; NaN ; NaN ];
Tc_error_38  = [ NaN ; NaN ; NaN ];

%-- Image #39:
omc_39 = [ NaN ; NaN ; NaN ];
Tc_39  = [ NaN ; NaN ; NaN ];
omc_error_39 = [ NaN ; NaN ; NaN ];
Tc_error_39  = [ NaN ; NaN ; NaN ];

%-- Image #40:
omc_40 = [ NaN ; NaN ; NaN ];
Tc_40  = [ NaN ; NaN ; NaN ];
omc_error_40 = [ NaN ; NaN ; NaN ];
Tc_error_40  = [ NaN ; NaN ; NaN ];

%-- Image #41:
omc_41 = [ 2.037618e+00 ; 1.958227e+00 ; -6.178341e-01 ];
Tc_41  = [ -4.573403e+02 ; -5.652320e+01 ; 4.431143e+03 ];
omc_error_41 = [ 1.237013e-03 ; 1.203465e-03 ; 1.645843e-03 ];
Tc_error_41  = [ 1.715420e-01 ; 1.873634e-01 ; 2.809257e+01 ];

%-- Image #42:
omc_42 = [ NaN ; NaN ; NaN ];
Tc_42  = [ NaN ; NaN ; NaN ];
omc_error_42 = [ NaN ; NaN ; NaN ];
Tc_error_42  = [ NaN ; NaN ; NaN ];

%-- Image #43:
omc_43 = [ NaN ; NaN ; NaN ];
Tc_43  = [ NaN ; NaN ; NaN ];
omc_error_43 = [ NaN ; NaN ; NaN ];
Tc_error_43  = [ NaN ; NaN ; NaN ];

%-- Image #44:
omc_44 = [ NaN ; NaN ; NaN ];
Tc_44  = [ NaN ; NaN ; NaN ];
omc_error_44 = [ NaN ; NaN ; NaN ];
Tc_error_44  = [ NaN ; NaN ; NaN ];

%-- Image #45:
omc_45 = [ NaN ; NaN ; NaN ];
Tc_45  = [ NaN ; NaN ; NaN ];
omc_error_45 = [ NaN ; NaN ; NaN ];
Tc_error_45  = [ NaN ; NaN ; NaN ];

%-- Image #46:
omc_46 = [ 2.051172e+00 ; 1.886403e+00 ; -9.751792e-01 ];
Tc_46  = [ -6.433852e+02 ; -1.321490e+02 ; 4.630539e+03 ];
omc_error_46 = [ 8.485226e-04 ; 7.868748e-04 ; 1.232087e-03 ];
Tc_error_46  = [ 3.188582e-01 ; 2.212052e-01 ; 2.884578e+01 ];

%-- Image #47:
omc_47 = [ NaN ; NaN ; NaN ];
Tc_47  = [ NaN ; NaN ; NaN ];
omc_error_47 = [ NaN ; NaN ; NaN ];
Tc_error_47  = [ NaN ; NaN ; NaN ];

%-- Image #48:
omc_48 = [ NaN ; NaN ; NaN ];
Tc_48  = [ NaN ; NaN ; NaN ];
omc_error_48 = [ NaN ; NaN ; NaN ];
Tc_error_48  = [ NaN ; NaN ; NaN ];

%-- Image #49:
omc_49 = [ NaN ; NaN ; NaN ];
Tc_49  = [ NaN ; NaN ; NaN ];
omc_error_49 = [ NaN ; NaN ; NaN ];
Tc_error_49  = [ NaN ; NaN ; NaN ];

%-- Image #50:
omc_50 = [ NaN ; NaN ; NaN ];
Tc_50  = [ NaN ; NaN ; NaN ];
omc_error_50 = [ NaN ; NaN ; NaN ];
Tc_error_50  = [ NaN ; NaN ; NaN ];

%-- Image #51:
omc_51 = [ -2.116252e+00 ; -2.020607e+00 ; -8.476841e-02 ];
Tc_51  = [ -1.180163e+02 ; -1.581867e+02 ; 6.212010e+03 ];
omc_error_51 = [ 2.605057e-03 ; 2.914227e-03 ; 6.235676e-03 ];
Tc_error_51  = [ 2.274996e-01 ; 2.517701e-01 ; 4.110657e+01 ];

%-- Image #52:
omc_52 = [ NaN ; NaN ; NaN ];
Tc_52  = [ NaN ; NaN ; NaN ];
omc_error_52 = [ NaN ; NaN ; NaN ];
Tc_error_52  = [ NaN ; NaN ; NaN ];

%-- Image #53:
omc_53 = [ NaN ; NaN ; NaN ];
Tc_53  = [ NaN ; NaN ; NaN ];
omc_error_53 = [ NaN ; NaN ; NaN ];
Tc_error_53  = [ NaN ; NaN ; NaN ];

%-- Image #54:
omc_54 = [ NaN ; NaN ; NaN ];
Tc_54  = [ NaN ; NaN ; NaN ];
omc_error_54 = [ NaN ; NaN ; NaN ];
Tc_error_54  = [ NaN ; NaN ; NaN ];

%-- Image #55:
omc_55 = [ NaN ; NaN ; NaN ];
Tc_55  = [ NaN ; NaN ; NaN ];
omc_error_55 = [ NaN ; NaN ; NaN ];
Tc_error_55  = [ NaN ; NaN ; NaN ];

%-- Image #56:
omc_56 = [ 1.827591e+00 ; 2.020419e+00 ; 1.019410e+00 ];
Tc_56  = [ -1.117909e+03 ; -1.306065e+02 ; 6.422081e+03 ];
omc_error_56 = [ 1.492204e-03 ; 1.473646e-03 ; 2.102898e-03 ];
Tc_error_56  = [ 1.214595e+00 ; 3.636695e-01 ; 4.504038e+01 ];

%-- Image #57:
omc_57 = [ NaN ; NaN ; NaN ];
Tc_57  = [ NaN ; NaN ; NaN ];
omc_error_57 = [ NaN ; NaN ; NaN ];
Tc_error_57  = [ NaN ; NaN ; NaN ];

%-- Image #58:
omc_58 = [ NaN ; NaN ; NaN ];
Tc_58  = [ NaN ; NaN ; NaN ];
omc_error_58 = [ NaN ; NaN ; NaN ];
Tc_error_58  = [ NaN ; NaN ; NaN ];

%-- Image #59:
omc_59 = [ NaN ; NaN ; NaN ];
Tc_59  = [ NaN ; NaN ; NaN ];
omc_error_59 = [ NaN ; NaN ; NaN ];
Tc_error_59  = [ NaN ; NaN ; NaN ];

%-- Image #60:
omc_60 = [ NaN ; NaN ; NaN ];
Tc_60  = [ NaN ; NaN ; NaN ];
omc_error_60 = [ NaN ; NaN ; NaN ];
Tc_error_60  = [ NaN ; NaN ; NaN ];

%-- Image #61:
omc_61 = [ -1.699484e+00 ; -2.386579e+00 ; 4.928985e-01 ];
Tc_61  = [ -9.480249e+02 ; -1.177461e+02 ; 6.666865e+03 ];
omc_error_61 = [ 1.390244e-03 ; 2.031558e-03 ; 3.075695e-03 ];
Tc_error_61  = [ 9.060920e-01 ; 2.915193e-01 ; 4.333513e+01 ];

