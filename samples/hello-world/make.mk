LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE := testc
LOCAL_SRC_FILES := testc.c
include $(BUILD_TEST)

include $(CLEAR_VARS)
LOCAL_MODULE := testc++
LOCAL_SRC_FILES := testc++.cpp
#defined 'c++' link mode,the default is c.
LOCAL_LINK_MODE := c++
include $(BUILD_TEST)

#build testc_exe
include $(CLEAR_VARS)
LOCAL_MODULE := testc_exe
LOCAL_SRC_FILES := testc.c
include $(BUILD_EXECUTABLE)
