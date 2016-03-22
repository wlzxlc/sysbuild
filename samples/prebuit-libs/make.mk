LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := z_genarate_libtesta
LOCAL_TARGET_TOP := $(LOCAL_PATH)
LOCAL_TARGET_CMD := touch prebuit_libs/libtest.a
include $(BUILD_TH3_BINARY)

#prebuild libtestc.a
include $(CLEAR_VARS)
LOCAL_MODULE := test_prebuit_a
LOCAL_SRC_FILES := prebuit_libs/libtest.a
LOCAL_DEPS_MODULES := z_genarate_libtesta
LOCAL_RELEASE_PATH := $(APP_PROJECT_PATH)/release/prebuit/a
include $(PREBUILT_STATIC_LIBRARY)

#prebuit_libs/libtest.so is x86_64 lib.
ifeq ($(TARGET_ARCH),x86)
$(info $(HOST_ARCH64))
ifeq ($(HOST_ARCH64),x86_64)
  include $(CLEAR_VARS)
  LOCAL_MODULE := test_prebuit_so
  LOCAL_SRC_FILES := prebuit_libs/libtest_x86_64.so
  include $(PREBUILT_SHARED_LIBRARY)

#build testprebuit 
 include $(CLEAR_VARS)
  LOCAL_MODULE := testprebuit
  LOCAL_SRC_FILES := src/test.cpp
#Deps modules name.
  LOCAL_SHARED_LIBRARIES := test_prebuit_so
  LOCAL_LINK_MODE := c++
  LOCAL_RELEASE_PATH := $(LOCAL_PATH)
  include $(BUILD_TEST)
#build testprebuit_not_copy
#if your don't prebuit library.
 include $(CLEAR_VARS)
  LOCAL_MODULE := testprebuit_not_copy
  LOCAL_SRC_FILES := src/test.cpp
#specify the libs path.
  LOCAL_LDFLAGS := -L$(LOCAL_PATH)/prebuit_libs
#depends list of the libs.
  LOCAL_LDLIBS := -ltest_x86_64
  LOCAL_LINK_MODE := c++
  LOCAL_RELEASE_PATH := $(LOCAL_PATH)
  include $(BUILD_TEST)
endif
endif

