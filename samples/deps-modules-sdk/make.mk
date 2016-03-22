# Depends reference
# deps_test_h_exe[EXE]  deps_test_h_test[TEST]
#       |  [src deps]                  |
#       |------------------------------|
#       V      [src deps]         [link deps]             [src deps] 
# z_touch_h[Th3] ---> testlibexe[EXE] ---> testlib[SHARED] ---> z_touch_c[Th3]
#     
# Build sequence: testlibexe -> z_touch_c -> testlib 
#                                               |
#                                               V
#             deps_test_h_exe <- z_touch_h <- testlibexe[link]
#            deps_test_h_test <--|
#
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := z_touch_h
LOCAL_TARGET_TOP := $(LOCAL_PATH)
LOCAL_TARGET_CMD := echo "void test_f(){}" >  test.h
$(call add-module-clean,$(LOCAL_MODULE),clean_$(LOCAL_MODULE))
clean_$(LOCAL_MODULE): priv_path := $(LOCAL_PATH)
clean_$(LOCAL_MODULE):
	@-rm -rf $(priv_path)/test.h

LOCAL_DEPS_MODULES := testlibexe
include $(BUILD_TH3_BINARY)


include $(CLEAR_VARS)
LOCAL_MODULE := deps_test_h_test
LOCAL_SRC_FILES := test.c
#Maby the '-fPIC' by needed for x86 compiler.
LOCAL_DEPS_MODULES := z_touch_h
ifeq ($(TARGET_ARCH),x86)
 LOCAL_CFLAGS := -fPIC
endif
include $(BUILD_TEST)

include $(CLEAR_VARS)
LOCAL_MODULE := deps_test_h_exe
LOCAL_SRC_FILES := test.c
#Maby the '-fPIC' by needed for x86 compiler.
LOCAL_DEPS_MODULES := z_touch_h 
ifeq ($(TARGET_ARCH),x86)
 LOCAL_CFLAGS := -fPIC
endif
include $(BUILD_EXECUTABLE)

# Test Deps libraries
include $(CLEAR_VARS)
LOCAL_MODULE := z_touch_c
LOCAL_TARGET_TOP := $(LOCAL_PATH)
CUSTOM_SIG := \
"void test_hello_from_lib() {\n" \
"  printf(\"Hello from lib.\\\n\");\n \
}"

LOCAL_TARGET_CMD := echo $(CUSTOM_SIG) > test_hello_from_lib.c 

$(call add-module-clean,$(LOCAL_MODULE),clean_$(LOCAL_MODULE))
clean_$(LOCAL_MODULE): priv_path := $(LOCAL_PATH)
clean_$(LOCAL_MODULE):
	@-rm -rf $(priv_path)/test_hello_from_lib.c
include $(BUILD_TH3_BINARY)

include $(CLEAR_VARS)
LOCAL_MODULE := testlib
LOCAL_SRC_FILES := test_hello_from_lib.c

# Genarate test_hello_from_lib.c file
LOCAL_DEPS_MODULES := z_touch_c
#Maby the '-fPIC' by needed for x86 compiler.
ifeq ($(TARGET_ARCH),x86)
 LOCAL_CFLAGS := -fPIC
endif
include $(BUILD_SHARED_LIBRARY)


include $(CLEAR_VARS)
LOCAL_MODULE := testlibexe
LOCAL_SRC_FILES := testlib_main.c
#Maby the '-fPIC' by needed for x86 compiler.
LOCAL_SHARED_LIBRARIES := testlib
ifeq ($(TARGET_ARCH),x86)
 LOCAL_CFLAGS := -fPIC
endif
include $(BUILD_EXECUTABLE)


