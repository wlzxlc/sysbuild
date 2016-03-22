LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE := test-deps1
LOCAL_SRC_FILES := test.cpp

LOCAL_SHARED_LIBRARIES := libtest-deps-so
#we don't contain it,because it's already export in the module libtest-deps-so
#LOCAL_C_INCLUDES := $(LOCAL_PATH)/subdir/inc
LOCAL_LINK_MODE := c++
include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_MODULE := test-deps2
LOCAL_SRC_FILES := test.cpp

LOCAL_STATIC_LIBRARIES := libtest-deps-a
#we don't contain it,because it's already export in the module libtest-deps-so
#LOCAL_C_INCLUDES := $(LOCAL_PATH)/subdir/inc
LOCAL_LINK_MODE := c++
LOCAL_RELEASE_PATH := $(TARGET_RELEASE_DIR)/release
include $(BUILD_EXECUTABLE)

#Contain subdir's make.mk
$(call include-makefiles,$(call all-subdir-makefiles))
