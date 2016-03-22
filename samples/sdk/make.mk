LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := sdk_custom
#defined the third part top tree.
LOCAL_TARGET_TOP := $(LOCAL_PATH)/third_part

#we are want to executable commands
# LOCAL_TARGET_CMD := echo "Executable:./build.sh";./build.sh
LOCAL_TARGET_CMD := \
	              if [ -d process ];then \
				  echo "Process..." && \
				  ./build.sh;\
				  else \
                  echo "Don't process..."; \
				  fi

LOCAL_TARGET_COPY_FILES := custom_test
LOCAL_DEPS_MODULES := sdk_custom_copy_inc
LOCAL_RELEASE_PATH := $(APP_PROJECT_PATH)/release/sdk/$(TARGET_BOARD)/exe_file;$(LOCAL_PATH);
include $(BUILD_TH3_BINARY)

include $(CLEAR_VARS)
LOCAL_MODULE := sdk_custom_copy_inc
LOCAL_TARGET_TOP := $(LOCAL_PATH)/third_part
LOCAL_TARGET_COPY_FILES := inc

#this module deps module list.
LOCAL_RELEASE_PATH := $(APP_PROJECT_PATH)/release/sdk/$(TARGET_BOARD)/head_file;
include $(BUILD_TH3_BINARY)

