TARGET_CFLAGS := \
    -fpic \
    -ffunction-sections \
    -funwind-tables \
    -fstack-protector \
    -no-canonical-prefixes

TARGET_LDFLAGS := -no-canonical-prefixes

TARGET_arm64_release_CFLAGS := -O2 \
                               -g \
                               -DNDEBUG \
                               -fomit-frame-pointer \
                               -fstrict-aliasing    \
                               -funswitch-loops     \
                               -finline-limit=300

TARGET_arm64_debug_CFLAGS := $(TARGET_arm64_release_CFLAGS) \
                             -O0 \
                             -UNDEBUG \
                             -fno-omit-frame-pointer \
                             -fno-strict-aliasing

# This function will be called to determine the target CFLAGS used to build
# a C or Assembler source file, based on its tags.
#
TARGET-process-src-files-tags = \
$(eval __debug_sources := $(call get-src-files-with-tag,debug)) \
$(eval __release_sources := $(call get-src-files-without-tag,debug)) \
$(call set-src-files-target-cflags, $(__debug_sources), $(TARGET_arm64_debug_CFLAGS)) \
$(call set-src-files-target-cflags, $(__release_sources),$(TARGET_arm64_release_CFLAGS)) \

ifneq ($(APP_TOOLCHAIN_SYSROOT),)
    _ndk_root := $(abspath $(TOOLCHAIN_ROOT)/../../../../../)
    cxx_stl_path := $(_ndk_root)/sources/cxx-stl/gnu-libstdc++/$(TOOLCHAIN_VERSION)

   TARGET_C_INCLUDES += $(cxx_stl_path)/include \
                        $(cxx_stl_path)/libs/$(TARGET_ABI)/include \
	                    $(cxx_stl_path)/include/backward

   TARGET_LDLIBS += $(cxx_stl_path)/libs/$(TARGET_ABI)/libgnustl_static.a
   TARGET_CFLAGS += -D_STLP_USE_NO_IOSTREAMS -D_STLP_USE_MALLOC
endif
