
ifeq ($(strip $(TOOLCHAIN_NAME)),arm-linux-androideabi-)

ifneq ($(filter 4.%,$(TOOLCHAIN_VERSION)),)
TARGET_CFLAGS += \
    -fpic \
    -ffunction-sections \
    -funwind-tables \
    -fstack-protector \
    -D__ARM_ARCH_5__ -D__ARM_ARCH_5T__ \
    -D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__ \
    -no-canonical-prefixes

TARGET_LDFLAGS += -no-canonical-prefixes


ifeq ($(TARGET_ABI),armeabi-v7a)
    TARGET_CFLAGS += -march=armv7-a \
                     -mfloat-abi=softfp \
                     -mfpu=vfpv3-d16

    TARGET_LDFLAGS += -march=armv7-a \
                     -Wl,--fix-cortex-a8
else
    TARGET_CFLAGS += -march=armv5te \
                            -mtune=xscale \
                            -msoft-float
endif

TARGET_CFLAGS.neon := -mfpu=neon

TARGET_arm_release_CFLAGS :=  -O2 \
                              -g \
                              -DNDEBUG \
                              -fomit-frame-pointer \
                              -fstrict-aliasing    \
                              -funswitch-loops     \
                              -finline-limit=300

TARGET_thumb_release_CFLAGS := -mthumb \
                               -Os \
                               -g \
                               -DNDEBUG \
                               -fomit-frame-pointer \
                               -fno-strict-aliasing \
                               -finline-limit=64

# When building for debug, compile everything as arm.
TARGET_arm_debug_CFLAGS := $(TARGET_arm_release_CFLAGS) \
                           -O0 \
                           -UNDEBUG \
                           -fno-omit-frame-pointer \
                           -fno-strict-aliasing

TARGET_thumb_debug_CFLAGS := $(TARGET_thumb_release_CFLAGS) \
                             -O0 \
                             -UNDEBUG \
                             -marm \
                             -fno-omit-frame-pointer

# This function will be called to determine the target CFLAGS used to build
# a C or Assembler source file, based on its tags.
#
TARGET-process-src-files-tags = \
$(eval __arm_sources := $(call get-src-files-with-tag,arm)) \
$(eval __thumb_sources := $(call get-src-files-without-tag,arm)) \
$(eval __debug_sources := $(call get-src-files-with-tag,debug)) \
$(eval __release_sources := $(call get-src-files-without-tag,debug)) \
$(call set-src-files-target-cflags, \
    $(call set_intersection,$(__arm_sources),$(__debug_sources)), \
    $(TARGET_arm_debug_CFLAGS)) \
$(call set-src-files-target-cflags,\
    $(call set_intersection,$(__arm_sources),$(__release_sources)),\
    $(TARGET_arm_release_CFLAGS)) \
$(call set-src-files-target-cflags,\
    $(call set_intersection,$(__arm_sources),$(__debug_sources)),\
    $(TARGET_arm_debug_CFLAGS)) \
$(call set-src-files-target-cflags,\
    $(call set_intersection,$(__thumb_sources),$(__release_sources)),\
    $(TARGET_thumb_release_CFLAGS)) \
$(call set-src-files-target-cflags,\
    $(call set_intersection,$(__thumb_sources),$(__debug_sources)),\
    $(TARGET_thumb_debug_CFLAGS)) \
$(call add-src-files-target-cflags,\
    $(call get-src-files-with-tag,neon),\
    $(TARGET_CFLAGS.neon)) \
$(call set-src-files-text,$(__arm_sources),arm$(space)$(space)) \
$(call set-src-files-text,$(__thumb_sources),thumb)

endif #ifneq ($(filter 4.6%...))

ifneq ($(APP_TOOLCHAIN_SYSROOT),)
    _ndk_root := $(abspath $(TOOLCHAIN_ROOT)/../../../../../)
    cxx_stl_path := $(_ndk_root)/sources/cxx-stl/gnu-libstdc++/$(TOOLCHAIN_VERSION)

   TARGET_C_INCLUDES += $(cxx_stl_path)/include \
                        $(cxx_stl_path)/libs/$(TARGET_ABI)/include \
	                    $(cxx_stl_path)/include/backward

   TARGET_LDLIBS += $(cxx_stl_path)/libs/$(TARGET_ABI)/libgnustl_static.a
   TARGET_CFLAGS += -D_STLP_USE_NO_IOSTREAMS -D_STLP_USE_MALLOC
endif

endif #endif ifeq (...,arm-linux-androideabi-)
