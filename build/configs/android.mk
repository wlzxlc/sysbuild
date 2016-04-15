ifeq ($(TARGET_PLATFORM),android)
ifneq ($(APP_TOOLCHAIN_SYSROOT),)
    _ndk_root := $(abspath $(TOOLCHAIN_ROOT)/../../../../../)
    cxx_stl_path := $(_ndk_root)/sources/cxx-stl/gnu-libstdc++/$(TOOLCHAIN_VERSION)

   TARGET_C_INCLUDES += $(cxx_stl_path)/include \
                        $(cxx_stl_path)/libs/$(TARGET_ABI)/include \
	                    $(cxx_stl_path)/include/backward

   TARGET_LDLIBS += $(cxx_stl_path)/libs/$(TARGET_ABI)/libgnustl_static.a
   TARGET_CFLAGS += -D_STLP_USE_NO_IOSTREAMS -D_STLP_USE_MALLOC

endif
endif
