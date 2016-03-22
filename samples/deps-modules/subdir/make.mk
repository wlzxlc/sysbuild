LOCAL_PATH := $(call my-dir)

#build libtestdep.so
include $(CLEAR_VARS)
LOCAL_MODULE := libtest-deps-so
LOCAL_MODULE_FILENAME := libtestdep
LOCAL_CPP_EXTENSION := .cxx
#export the inc path.
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/inc
LOCAL_C_INCLUDES := $(LOCAL_EXPORT_C_INCLUDES)
LOCAL_SRC_FILES := libc++.cxx
#Maby the '-fPIC' by needed for x86 compiler.
ifeq ($(TARGET_ARCH),x86)
 LOCAL_CFLAGS := -fPIC
endif
LOCAL_LINK_MODE :=c++
include $(BUILD_SHARED_LIBRARY)

#build libtestdep.a
include $(CLEAR_VARS)
LOCAL_MODULE := libtest-deps-a
LOCAL_MODULE_FILENAME := libtestdep
LOCAL_CPP_EXTENSION := .cxx
#export the inc path.
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/inc
LOCAL_C_INCLUDES := $(LOCAL_EXPORT_C_INCLUDES)
LOCAL_SRC_FILES := libc++.cxx
#Maby the '-fPIC' by needed for x86 compiler.
ifeq ($(TARGET_ARCH),x86)
 LOCAL_CFLAGS := -fPIC
endif
LOCAL_LINK_MODE :=c++
include $(BUILD_STATIC_LIBRARY)
