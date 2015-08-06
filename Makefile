CXX= g++ $(MY_FLAGS)
MY_FLAGS= -O0 -g
SRC_INCLUDE= -I$(SRC_DIR)  -I$(3RDPARTY_DIR)/levmar-2.6
OPENCV_LIBS= -lopencv_video -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_flann -lopencv_calib3d -lopencv_features2d -Xlinker -rpath .
LEVMAAR_LIBS= -L$(3RDPARTY_DIR)/levmar-2.6 -L$(3RDPARTY_DIR)/libf2c -llevmar -llapack -lblas -lf2c
INC_FLAG= $(SRC_INCLUDE)
LIB_FLAG= $(OPENCV_LIBS) $(LEVMAAR_LIBS) -lm 
CFLAG= -Wall -std=c++11 $(INC_FLAG) $(LIB_FLAG) 
OUT_DIR:= build
SRC_DIR:= src
SUB_DIRS:= $(shell find $(SRC_DIR) -type d)
DST_DIR:= bin
DEMO_DIR:=demo
3RDPARTY_DIR:= ./3rdparty

SEQ_AUTO_RECALIB_SRC= $(SRC_DIR)/AutoPosEst.cpp\
				  $(SRC_DIR)/CorrespondenceDetector.cpp\
				  $(SRC_DIR)/FeatureExtractor.cpp\
				  $(SRC_DIR)/AutoPosEstimator.cpp\
			      $(SRC_DIR)/StereoVisualizeUtils.cpp\
				  $(SRC_DIR)/Parameters.cpp

ALL_SRC= $(SRC_DIR)/AutoPosEst.cpp\
	    # $(SRC_DIR)/SeqAutoRecalibMain.cpp\
		 $(SRC_DIR)/Parameters.cpp

#objects
SEQ_AUTO_RECALIB_O= $(SEQ_AUTO_RECALIB_SRC:%.cpp=$(OUT_DIR)/%.o)
ALL_O= $(ALL_SRC:%.cpp=$(OUT_DIR)/%.o)

#source dependency
SEQ_AUTO_RECALIB_DEPS= $(SEQ_AUTO_RECALIB_SRC:%.cpp=%.d)
ALL_DEPS= $(ALL_SRC:%.cpp=$(OUT_DIR)/%.d)

#target  
SEQ_AUTO_RECALIB= auto_pos_est
ALL= $(SEQ_AUTO_RECALIB)

all: $(ALL)

#clean the project all
clean: 
	@echo "$(RM) $(ALL)"
	$(RM) $(ALL_O)  $(OUT_DIR)/$(AUTO_RECALIB) $(OUT_DIR)/$(SEQ_AUTO_RECALIB)
	
#link rules for target

$(SEQ_AUTO_RECALIB):dirs $(SEQ_AUTO_RECALIB_O)  
		@echo "$(SEQ_AUTO_RECALIB_O)"
		$(CXX) $(SEQ_AUTO_RECALIB_O)    $(CFLAG)  -o $(addprefix $(OUT_DIR)/,$@)
		cp  $(OUT_DIR)/$(SEQ_AUTO_RECALIB) $(DST_DIR)
		cp  $(OUT_DIR)/$(SEQ_AUTO_RECALIB) $(DEMO_DIR)

#compile dependency and rules
$(OUT_DIR)/%.o:%.cpp 
		$(CXX)  $(CFLAG) -fmessage-length=0  -MMD -MP -MF"$(@:%.o=%.d)"  -c $< -o $@


#rule for make the dir 
dirs:
	mkdir -p $(DST_DIR);
	mkdir -p $(OUT_DIR);
	for val in $(SUB_DIRS);do \
   		mkdir -p  $(OUT_DIR)/$${val};\
	done;

#generate dependency rules
-include $(ALL_DEPS) 
$(OUT_DIR)/%.d:$(SRC_DIR)/%.cpp 
		@set -e; rm -f $@; \ 
		$(CXX) -M $(CFLAG) $< >; $@.$$$$; \ 
		sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ >; $@; \ 
		rm -f $@.$$$$ 

.PHONY: clean  release $(SEQ_AUTO_RECALIB)

#all:
#	$(CXX) $(MY_FLAGS) main.cpp ./SkeletonIdentification.cpp ./FeatureExtraction.cpp  $(CFLAG) -o test
