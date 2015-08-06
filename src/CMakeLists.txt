project(AutoPoseEstimation)
cmake_minimum_required(VERSION 2.8)
aux_source_directory(. SRC)
set(SRC_LIST
AutoCalibParam.cpp
AutoPosEst.cpp
AutoPosEstimator.cpp
CorrespondenceDetector.cpp
FeatureExtractor.cpp
Parameters.cpp
StereoVisualizeUtils.cpp
)
add_executable(${PROJECT_NAME} ${SRC_LIST})
link_directories( )
set(LIBRARY
opencv_video
opencv_core
opencv_imgproc
opencv_highgui
opencv_flann
opencv_calib3d
opencv_features2d
lapack
blas
)
target_link_libraries(${PROJECT_NAME}  ${CMAKE_SOURCE_DIR}/libf2c/libf2c.a ${CMAKE_SOURCE_DIR}/levmar-2.6/liblevmar.a ${LIBRARY})
set( CMAKE_BUILD_TYPE Debug )
