LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := kernel

#Cover this compiler.
LOCAL_TARGET_TOOLCHAIN := /opt/arm9q/bin/arm-none-linux-gnueabi-
ifeq ($(TARGET_PLATFORM),a5s)
#declear the kernel source path.
LOCAL_TARGET_TOP := ~/work/source/freescale/android/android-4.2.2/android/kernel_imx/

# must be kernel configure
# the follow equivalently "make -C $(LOCAL_TARGET_TOP) $(LOCAL_TARGET_CONFIG)_defconfig"
LOCAL_TARGET_CONFIG := imx6_android

else
LOCAL_TARGET_TOP := ~/work/source/ti/kernel/omap
LOCAL_TARGET_CONFIG := panda
endif
LOCAL_TARGET_COPY_FILES := arch/$(TARGET_ARCH)/boot/uImage

#declear the ruler,of course,you can not be defiend it.
#but,Are you sure you can get the uImage file at the end of the compilation.
LOCAL_TARGET_RULER := uImage
#we are want to release the "uImage" to $(APP_PROJECT_PATH)/release/kernel/
#of course,you can not be defiend it.
LOCAL_RELEASE_PATH := $(APP_PROJECT_PATH)/release/kernel/
#build kernel module.
include $(BUILD_KERNEL)
