LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := test_deps
LOCAL_TARGET_TOP := $(LOCAL_PATH)
LOCAL_TARGET_CMD := echo "Test LOCAL_DEPS_MODULES"
include $(BUILD_TH3_BINARY)

#build libtestc.so
include $(CLEAR_VARS)
LOCAL_MODULE := testc-so
#defiend alias,the default is lib$(LOCAL_MODULE).so
LOCAL_MODULE_FILENAME := libtestc
LOCAL_SRC_FILES := testc.c
LOCAL_DEPS_MODULES := test_deps
#Maby the '-fPIC' by needed for x86 compiler.
ifeq ($(TARGET_ARCH),x86)
 LOCAL_CFLAGS := -fPIC
endif
include $(BUILD_SHARED_LIBRARY)

#build libtestc.a
include $(CLEAR_VARS)
LOCAL_MODULE := testc-a
#defiend alias,the default is lib$(LOCAL_MODULE).a
LOCAL_MODULE_FILENAME := libtestc
LOCAL_SRC_FILES := testc.c
#Maby the '-fPIC' by needed for x86 compiler.
ifeq ($(TARGET_ARCH),x86)
 LOCAL_CFLAGS := -fPIC
endif
include $(BUILD_STATIC_LIBRARY)
