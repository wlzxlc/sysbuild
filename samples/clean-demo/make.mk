LOCAL_PATH := $(call my-dir)

#build libtestc.so
include $(CLEAR_VARS)
LOCAL_MODULE := testc-so-clean
#defiend alias,the default is lib$(LOCAL_MODULE).so
LOCAL_MODULE_FILENAME := libtestc
LOCAL_SRC_FILES := testc.c
#Maby the '-fPIC' by needed for x86 compiler.
ifeq ($(TARGET_ARCH),x86)
 LOCAL_CFLAGS := -fPIC
endif

#add my clean target
$(call add-module-clean,$(LOCAL_MODULE),clean_$(LOCAL_MODULE))
clean_$(LOCAL_MODULE): MY_PRIVATE_NAME := $(LOCAL_MODULE)
clean_$(LOCAL_MODULE):
	@echo "This is custom clean in the module [$(MY_PRIVATE_NAME)]"

include $(BUILD_SHARED_LIBRARY)



#build libtestc.a
include $(CLEAR_VARS)
LOCAL_MODULE := testc-a-clean
#defiend alias,the default is lib$(LOCAL_MODULE).a
LOCAL_MODULE_FILENAME := libtestc
LOCAL_SRC_FILES := testc.c
#Maby the '-fPIC' by needed for x86 compiler.
ifeq ($(TARGET_ARCH),x86)
 LOCAL_CFLAGS := -fPIC
endif

#add my clean target
$(call add-module-clean,$(LOCAL_MODULE),clean_module)
clean_global: MY_PRIVATE_MODULE := $(LOCAL_MODULE)
include $(BUILD_STATIC_LIBRARY)

#declear the target.
clean_module:
	@echo "This is custom clean and target name $@ at [$(PRIVATE_MODULE)]"

#add the clean_global target to list of clean target depends
$(call add-module-clean,,clean_global)
clean_global:
	@echo "Clean Application.mk"
	@rm -rf $(APP_PROJECT_PATH)/Application.mk
