LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE := testc
LOCAL_SRC_FILES := src/test.c
include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_MODULE := testc++
LOCAL_SRC_FILES := src/test.cpp
#declear this module use c++ mode link.
LOCAL_LINK_MODE := c++
include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_MODULE := testc_plat
LOCAL_SRC_FILES := src/test.c
#declear this module depends plat.
LOCAL_RELATE_MODE := plat
include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_MODULE := testc++_compiler
LOCAL_SRC_FILES := src/test.cpp
LOCAL_LINK_MODE := c++
LOCAL_RELATE_MODE := compiler
include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_MODULE := testc_plat_release
LOCAL_SRC_FILES := src/test.c
#declear this module depends plat.
LOCAL_RELATE_MODE := plat
#we are release two place. follows:
LOCAL_RELEASE_PATH := $(APP_PROJECT_PATH)/release/exe/$(TARGET_BOARD)/;
include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_MODULE := testc++_compiler_release
LOCAL_SRC_FILES := src/test.cpp
#declear this module depends compiler.
LOCAL_RELATE_MODE := compiler
LOCAL_LINK_MODE := c++
#we are release two place. follows:
LOCAL_RELEASE_PATH := $(APP_PROJECT_PATH)/release/exe/$(TARGET_BOARD)/exe/;
include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_MODULE := testc_plat_release_demo
LOCAL_SRC_FILES := src/test.c
#declear this module depends plat.
LOCAL_RELATE_MODE := plat
#we are release two place. follows:
LOCAL_RELEASE_PATH := $(APP_PROJECT_PATH)/release/exe/$(TARGET_BOARD)/demo/;
#build test 
include $(BUILD_TEST)

include $(CLEAR_VARS)
LOCAL_MODULE := testc++_compiler_release_demo
LOCAL_SRC_FILES := src/test.cpp
#declear this module depends compiler.
LOCAL_RELATE_MODE := compiler
LOCAL_LINK_MODE := c++
#we are release two place. follows:
LOCAL_RELEASE_PATH := $(APP_PROJECT_PATH)/release/exe/$(TARGET_BOARD)/demo/;
#build test
include $(BUILD_TEST)
