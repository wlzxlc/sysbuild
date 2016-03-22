LOCAL_PATH := $(call my-dir)

#we are only to compile the arm archs.
ifeq ($(TARGET_ARCH),arm)
include $(CLEAR_VARS)
LOCAL_MODULE := boot
LOCAL_TARGET_TOOLCHAIN := arm-none-linux-gnueabi-
ifeq ($(TARGET_PLATFORM),a5s)
LOCAL_TARGET_TOP := ~/work/source/freescale/android/android-4.2.2/android/bootable/bootloader/uboot-imx/
LOCAL_TARGET_CONFIG := mx6q_sabreauto_android
else
LOCAL_TARGET_TOP := ~/work/source/ti/uboot/u-boot 
LOCAL_TARGET_CONFIG := omap4430panda 
endif
LOCAL_TARGET_COPY_FILES := u-boot.bin

#declear the ruler,of course,you can not be defiend it.
#but,Are you sure you can get the u-boot.bin file at the end of the compilation.
LOCAL_TARGET_RULER := u-boot.bin

#we are want to release the "uImage" to $(APP_PROJECT_PATH)/release/boot/
#of course,you can not be defiend it.
LOCAL_RELEASE_PATH := $(APP_PROJECT_PATH)/release/boot
include $(BUILD_BOOTLOADER)
endif

#Test the Applicaton.mk configure.
ifeq ($(TARGET_ARCH),x86)
$(info Not need to build at x86 Boot.)
endif
