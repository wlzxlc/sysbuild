LOCAL_BUILD_SCRIPT := BUILD_BOOTLOADER
LOCAL_MAKEFILE     := $(local-makefile)

$(call assert-defined, LOCAL_TARGET_TOP LOCAL_TARGET_CONFIG  )

LOCAL_TARGET_CONFIG := $(strip $(LOCAL_TARGET_CONFIG))
#reset cross_compile
LOCAL_TARGET_TOOLCHAIN := $(strip $(LOCAL_TARGET_TOOLCHAIN))
ifndef LOCAL_TARGET_TOOLCHAIN 
 LOCAL_TARGET_TOOLCHAIN :=$(strip $(TOOLCHAIN_PREFIX))
else
 $(call __ndk_info,$(LOCAL_MAKEFILE):$(LOCAL_MODULE): Compiler  cover `$(LOCAL_TARGET_TOOLCHAIN)`.)
endif

LOCAL_TARGET_TOP :=$(patsubst %/,%,$(LOCAL_TARGET_TOP))
LOCAL_TARGET_TOP :=$(strip $(wildcard $(LOCAL_TARGET_TOP)))

$(if $(strip $(wildcard $(LOCAL_TARGET_TOP)/Makefile)),,\
	$(call __ndk_info,$(LOCAL_MAKEFILE):$(LOCAL_MODULE): ERROR:Veriable LOCAL_TARGET_TOP `$(LOCAL_TARGET_TOP)` to point an invalid path.)\
$(call __ndk_error,Abort ...)\
)

$(if $(strip $(patsubst $(TARGET_ARCH)%,,$(notdir $(LOCAL_TARGET_TOOLCHAIN)))),\
$(call __ndk_info,WANRING:$(LOCAL_MAKEFILE):$(LOCAL_MODULE):Current arch is `$(TARGET_ARCH)` ,but the toolchain prefix is `$(LOCAL_TARGET_TOOLCHAIN).)\
,)
#LOCAL_TARGET_CMD :=$(GNUMAKE) $(LOCAL_TARGET_CONFIG)_defconfig  ARCH=$(TARGET_ARCH) \
;$(GNUMAKE) $(LOCAL_TARGET_RULER) -j$(shell cat /proc/cpuinfo |grep "cpu cores" |awk '{print $4}' |wc -l) \
 CROSS_COMPILE=$(TOOLCHAIN_PREFIX) ARCH=$(TARGET_ARCH) $(LOCAL_CFLAGS);

# we are building target objects
my := TARGET_


LOCAL_BOOTLOADER_OUTPUT_DIR := $(strip $(LOCAL_BOOTLOADER_OUTPUT_DIR))
ifndef LOCAL_BOOTLOADER_OUTPUT_DIR
#if the path contain '~' char.
LOCAL_BOOTLOADER_OUTPUT_DIR := $(abspath $(subst ~,$(HOME),$(lastword $(patsubst O=%,%,$(filter O=%,$(LOCAL_CFLAGS))))))
LOCAL_BOOTLOADER_OUTPUT_DIR :=$(patsubst %/,%,$(LOCAL_BOOTLOADER_OUTPUT_DIR))
endif

ifndef LOCAL_BOOTLOADER_OUTPUT_DIR
#we are want to set the output directory to .../<arch>/<platform>/kernel for the bootloader
# LOCAL_BOOTLOADER_OUTPUT_DIR :=$(abspath $(TARGET_OUT)/../.bootloader)

# if the output not definded , we are set the default path for "$(LOCAL_TARGET_TOP)"
# because some bootloader not support the 'O' parameter.
 LOCAL_BOOTLOADER_OUTPUT_DIR :=$(LOCAL_TARGET_TOP)
endif

ifneq ($(LOCAL_BOOTLOADER_OUTPUT_DIR),$(LOCAL_TARGET_TOP))
#update output dir parameter
LOCAL_CFLAGS := $(strip $(filter-out O=%,$(LOCAL_CFLAGS)) O=$(LOCAL_BOOTLOADER_OUTPUT_DIR))
endif

ifdef LOCAL_TARGET_COPY_FILES
LOCAL_TARGET_COPY_FILES :=$(foreach a,$(LOCAL_TARGET_COPY_FILES),$(LOCAL_BOOTLOADER_OUTPUT_DIR)/$(a))

endif
ifdef LOCAL_RELATE_MODE
 $(call __ndk_info,WARNING: Default bootloader modules only to support 'board' mode \
  ,the '$(LOCAL_RELATE_MODE)' setting  is invalid in the file $(LOCAL_MAKEFILE).)
LOCAL_RELATE_MODE := board
endif

$(call handle-module-filename,,)
$(call handle-module-built)
LOCAL_MODULE_CLASS := BOOTLOADER
include $(BUILD_SYSTEM)/build-module.mk
