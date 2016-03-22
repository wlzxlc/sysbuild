
# Declare comma(,) symbol, it will be add-build-options function reference
comma =$(empty),$(empty)

define cmd-build-th3-executable
@$(LOCAL_TARGET_CMD)
@$(HOST_ECHO) "Th3_Binary     : <$(PRIVATE_NAME)> compiled done."
endef

define cmd-build-test-exe
$(PRIVATE_LD_EXE) \
    -Wl,--gc-sections \
	$(call add-build-options,--sysroot,$(PRIVATE_SYSROOT_LINK)) \
	$(call add-build-options,-Wl$(comma)-rpath-link,$(PRIVATE_SYSROOT_LINK)/usr/lib) \
	-Wl,-rpath-link=$(call host-path,$(TARGET_OUT)) \
    $(PRIVATE_LINKER_OBJECTS_AND_LIBRARIES) \
    $(PRIVATE_LDFLAGS) \
    $(PRIVATE_LDLIBS) \
    -o $(call host-path,$(LOCAL_BUILT_MODULE))
endef


define cmd-build-th3-kernel-binary
@$(call host-mkdir,$(LOCAL_$(call module-get-class,$(LOCAL_MODULE))_OUTPUT_DIR))
#we prefer the mrproper command,about you?
@$(GNUMAKE) -C $(LOCAL_TARGET_TOP) mrproper $(cmd-fixed-makefile-args) 
@$(GNUMAKE) -C $(LOCAL_TARGET_TOP) $(LOCAL_TARGET_CONFIG)_defconfig $(cmd-makefile-args) 
@$(GNUMAKE) -C $(LOCAL_TARGET_TOP) $(LOCAL_TARGET_RULER) $(cmd-makefile-args) 1>/dev/null
@$(HOST_ECHO) "Kernel         : <$(PRIVATE_NAME)> compiled done."
endef

define cmd-build-th3-bootloader
@$(call host-mkdir,$(LOCAL_$(call module-get-class,$(LOCAL_MODULE))_OUTPUT_DIR))
#we prefer the distclean command,about you?
@$(GNUMAKE) -C $(LOCAL_TARGET_TOP) distclean $(cmd-makefile-args)
@$(GNUMAKE) -C $(LOCAL_TARGET_TOP) $(LOCAL_TARGET_CONFIG)_config $(cmd-makefile-args)
@$(GNUMAKE) -C $(LOCAL_TARGET_TOP) $(LOCAL_TARGET_RULER) $(cmd-makefile-args) 1>/dev/null
@$(HOST_ECHO) "Bootloader     : <$(PRIVATE_NAME)> compiled done."
endef

define cmd-fixed-makefile-args
ARCH=$(TARGET_ARCH) CROSS_COMPILE=$(LOCAL_TARGET_TOOLCHAIN)
endef

define cmd-makefile-args
-j$(strip $(lastword $(shell cat /proc/cpuinfo |grep "cpu cores")))\
 $(cmd-fixed-makefile-args) $(LOCAL_CFLAGS)
endef

define cmd-makefile-path
$(GNUMAKE) -C $(LOCAL_TARGET_TOP)
endef

define cmd-shell-rulers
cd $(LOCAL_TARGET_TOP) &&
endef

define print_module_files
$(foreach module,$(notdir $(1)),echo " $(module)";\
$(foreach file,$(PRIVATE_$(module)_WANTED_COPY_FILES), echo "   [$(file)]";))
endef
