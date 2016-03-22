
ifeq ($(call module-get-class,$(LOCAL_MODULE)),TEST)
$(LOCAL_BUILT_MODULE): PRIVATE_BUILD_TEST := $(cmd-build-test-exe)
$(LOCAL_BUILT_MODULE): $(LOCAL_OBJECTS)
	@ $(HOST_ECHO) "TestProgram    : $(PRIVATE_NAME)"
	$(hide) $(PRIVATE_BUILD_TEST)

ALL_TESTS += $(LOCAL_BUILT_MODULE)
endif


ifneq (,$(filter THRID_PARTY_EXEC  KERNEL_BINARY BOOTLOADER,$(call module-get-class,$(LOCAL_MODULE))))

.PHONY: LOCAL_TH3_$(LOCAL_MODULE)_BUILD_COMMAND
LOCAL_TH3_$(LOCAL_MODULE)_BUILD_COMMAND: $(LOCAL_DEPS_MODULES)
#only support makefile ruler
ifneq (,$(filter KERNEL_BINARY BOOTLOADER,$(call module-get-class,$(LOCAL_MODULE))))
.PHONY: make-$(LOCAL_MODULE)-% \
       make-$(LOCAL_MODUOE)- 

make-$(LOCAL_MODULE)-%:PRIVATE_EXEC_MAKEFILE_PATH := $(cmd-makefile-path)
make-$(LOCAL_MODULE)-%:PRIVATE_MAKEFILE_ARGS := $(cmd-makefile-args)
make-$(LOCAL_MODULE)-%:PRIVATE_MAKEFILE_NAME := $(LOCAL_MODULE)
make-$(LOCAL_MODULE)-%:
	$(hide) $(PRIVATE_EXEC_MAKEFILE_PATH)  $(patsubst make-$(PRIVATE_MAKEFILE_NAME)-%,%,$@) $(PRIVATE_MAKEFILE_ARGS)

#if we are not ruler,only to execute make -C dir command.
make-$(LOCAL_MODULE)-:PRIVATE_MAKEFILE_NAME := $(LOCAL_MODULE) 
make-$(LOCAL_MODULE)-:PRIVATE_EXEC_MAKEFILE_PATH := $(cmd-makefile-path) 
make-$(LOCAL_MODULE)-:PRIVATE_MAKEFILE_ARGS := $(cmd-makefile-args)
make-$(LOCAL_MODULE)-:
	$(hide) $(PRIVATE_EXEC_MAKEFILE_PATH)  $(PRIVATE_MAKEFILE_ARGS)
endif

ifneq (,$(filter THRID_PARTY_EXEC,$(call module-get-class,$(LOCAL_MODULE))))
#only support shell script

.PHONY: shell-$(LOCAL_MODULE)-% 

shell-$(LOCAL_MODULE)-%:PRIVATE_EXEC_SHELL_CMD := $(cmd-shell-rulers)
shell-$(LOCAL_MODULE)-%:PRIVATE_NAME := $(LOCAL_MODULE)
shell-$(LOCAL_MODULE)-%:
	$(hide) $(PRIVATE_EXEC_SHELL_CMD) $(patsubst shell-$(PRIVATE_NAME)-%,%,$@)
endif #(,$(filter THRID_PARTY_EXEC,

ifdef LOCAL_TARGET_COPY_FILES
$(foreach file,$(LOCAL_TARGET_COPY_FILES),\
$(eval PRIVATE_$(LOCAL_MODULE)_WANTED_COPYES_FILE_$(notdir $(file)) := $(file))\
)
#add $(LOCAL_MODULE) prefix for every one waned copy files.
PRIVATE_$(LOCAL_MODULE)_WANTED_COPY_FILES := $(addprefix $(dir $(LOCAL_BUILT_MODULE))$(LOCAL_MODULE)_,\
$(notdir $(LOCAL_TARGET_COPY_FILES)))

$(PRIVATE_$(LOCAL_MODULE)_WANTED_COPY_FILES): PRIVATE_MAKEFILE_NAME := $(LOCAL_MODULE)

$(PRIVATE_$(LOCAL_MODULE)_WANTED_COPY_FILES): LOCAL_TH3_$(LOCAL_MODULE)_BUILD_COMMAND
	@$(HOST_ECHO) "Install        : <$(PRIVATE_MAKEFILE_NAME)> $(patsubst $(PRIVATE_MAKEFILE_NAME)_%,%,$(notdir $@)) => $@"
	$(hide) $(call host-cp,$(PRIVATE_$(PRIVATE_MAKEFILE_NAME)_WANTED_COPYES_FILE_$(patsubst $(PRIVATE_MAKEFILE_NAME)_%,%,$(notdir $@))), $@)

LOCAL_private_th3_common_target_$(LOCAL_MODULE):$(PRIVATE_$(LOCAL_MODULE)_WANTED_COPY_FILES)

$(call add-target-module,$(LOCAL_MODULE),$(PRIVATE_$(LOCAL_MODULE)_WANTED_COPY_FILES))
else
LOCAL_private_th3_common_target_$(LOCAL_MODULE): LOCAL_TH3_$(LOCAL_MODULE)_BUILD_COMMAND
endif #ifdef LOCAL_TARGET_COPY_FILES


LOCAL_TH3_$(LOCAL_MODULE)_BUILD_COMMAND:  PRIVATE_NAME := $(LOCAL_MODULE)

#if the target '$(LOCAL_BUILT_MODULE)' already in the $(LOCAL_TARGET_COPY_FILES),
#we are must filter out it,and myself must copy the $@.
$(LOCAL_BUILT_MODULE): LOCAL_private_th3_common_target_$(LOCAL_MODULE) 

ifeq ($(call module-get-class,$(LOCAL_MODULE)),THRID_PARTY_EXEC)
LOCAL_TH3_$(LOCAL_MODULE)_BUILD_COMMAND:  PRIVATE_BUILD_TH3 := $(cmd-build-th3-executable)
LOCAL_TH3_$(LOCAL_MODULE)_BUILD_COMMAND: $(NDK_APP_APPLICATION_MK) 
	@ $(HOST_ECHO) "Th3_Binary     : $(PRIVATE_NAME)"
	$(hide) $(PRIVATE_BUILD_TH3)
 
ALL_THIRD_PARTY_EXECS += $(LOCAL_BUILT_MODULE)
endif

ifeq ($(call module-get-class,$(LOCAL_MODULE)),KERNEL_BINARY)
LOCAL_TH3_$(LOCAL_MODULE)_BUILD_COMMAND:  PRIVATE_BUILD_KERNEL := $(cmd-build-th3-kernel-binary)
LOCAL_TH3_$(LOCAL_MODULE)_BUILD_COMMAND: $(NDK_APP_APPLICATION_MK) 
	@ $(HOST_ECHO) "Kernel         : $(PRIVATE_NAME)"
	$(hide) $(PRIVATE_BUILD_KERNEL)

ALL_KERNEL_BINARYS += $(LOCAL_BUILT_MODULE)
endif

ifeq ($(call module-get-class,$(LOCAL_MODULE)),BOOTLOADER)
LOCAL_TH3_$(LOCAL_MODULE)_BUILD_COMMAND:  PRIVATE_BUILD_BOOTLOADER := $(cmd-build-th3-bootloader)
LOCAL_TH3_$(LOCAL_MODULE)_BUILD_COMMAND:  $(NDK_APP_APPLICATION_MK) 
	@ $(HOST_ECHO) "Bootloader     : $(PRIVATE_NAME)"
	$(hide) $(PRIVATE_BUILD_BOOTLOADER)

ALL_BOOTLOADERS += $(LOCAL_BUILT_MODULE)
endif

#defined  all (th3/kernel/bootloader) release path targets.
ifeq ($(call module-is-installed-release,$(LOCAL_MODULE)),$(true))


ifndef LOCAL_TARGET_COPY_FILES
 $(call __ndk_info,$(LOCAL_MAKEFILE):$(LOCAL_MODULE):ERROR: No want to release the files. Are you sure defined LOCAL_TARGET_COPY_FILES.)
 $(call __ndk_error,Abort ...)
endif
LOCAL_INSTALL_RELEASE_FILES := $(notdir $(PRIVATE_$(LOCAL_MODULE)_WANTED_COPY_FILES))

#define target of the all wanted release ,e.g:
#
#out/release/$(LOCAL_MODULE): out/release/$(LOCAL_MODULE)_copy_file1  out/release/$(LOCAL_MODUOE)_copy_file2 ... 
#out/release2/$(LOCAL_MODULE): out/release2/$(LOCAL_MODUOE)_copy_file1  out/release2/$(LOCAL_MODUOE)_copy_file2 ... 
#

.PHONY: $(LOCAL_INSTALLED_RELEASE)

$(foreach target,$(LOCAL_INSTALLED_RELEASE),\
$(eval $(call add-target-module,$(LOCAL_MODULE),$(target))) \
$(eval $(target): $(LOCAL_DEPS_MODULES)) \
$(eval $(target):$(addprefix $(dir $(target)),$(LOCAL_INSTALL_RELEASE_FILES)))\
)

LOCAL_INSTALL_RELEASE_FILES_PATH := $(foreach path,$(dir $(LOCAL_INSTALLED_RELEASE)),$(addprefix $(path),$(LOCAL_INSTALL_RELEASE_FILES)))

#maybe its no existent but we are want to build every time.
.PHONY: $(LOCAL_INSTALL_RELEASE_FILES_PATH)

LOCAL_filter_RELEASE_TARGET := \
  $(filter $(LOCAL_INSTALL_RELEASE_FILES_PATH),$(LOCAL_BUILT_MODULE) \
  $(PRIVATE_$(LOCAL_MODULE)_WANTED_COPY_FILES))


ifdef LOCAL_filter_RELEASE_TARGET
$(call __ndk_info,$(LOCAL_PATH)/make.mk:$(LOCAL_MODULE):ERROR:Illegal release path '$(sort $(dir $(LOCAL_filter_RELEASE_TARGET)))'.)
$(call __ndk_error,Abort ...)
endif

#----------------------------------------------------------------
#define target of the all wanted release and copy files,e.g:
#
#out/release/$(LOCAL_MODUOE)_copy_file1:PRIVATE_COPY_FILE_NAME := copy_file1 
#out/release/$(LOCAL_MODUOE)_copy_file1: LOCAL_TH3_$$(LOCAL_MODULE)_BUILD_COMMAND 
#	@$(HOST_ECHO) "Release      : $(LOCAL_MODUOE)_copy_file1 => $(dir $@)$(PRIVATE_COPY_FILE_NAME)
#	@$(call host-cp,$<,$(dir $@)$$(PRIVATE_COPY_FILE_NAME))
#----------------------------------------------------------------
$(foreach T,$(LOCAL_INSTALL_RELEASE_FILES_PATH),\
$(eval $(call generate-file-dir,$(T))) \
$(eval $(call add-target-module,$(LOCAL_MODULE),$(T))) \
$(eval $(T):PRIVATE_COPY_FILE_NAME := $$(patsubst $$(LOCAL_MODULE)_%,%,$$(notdir $T)))\
$(eval $(T):PRIVATE_NAME := $$(LOCAL_MODULE))\
$(eval $(T):PRIVATE_TARGET_FILE := $$(PRIVATE_$$(LOCAL_MODULE)_WANTED_COPYES_FILE_$$(PRIVATE_COPY_FILE_NAME)))\
$(eval $(T):LOCAL_TH3_$$(LOCAL_MODULE)_BUILD_COMMAND;\
@$$(HOST_ECHO) "Release        : <$$(PRIVATE_NAME)> $$(PRIVATE_COPY_FILE_NAME) => $$(dir $$@)$$(PRIVATE_COPY_FILE_NAME)";\
$$(call host-cp,$$(PRIVATE_TARGET_FILE),$$(dir $$@)))\
)
endif #ifeq ($(call module-is-installed-release,

$(cleantarget): PRIVATE_CLEAN_FILES += $(PRIVATE_$(LOCAL_MODULE)_WANTED_COPY_FILES)
 
else #class not in (THRID_PARTY_EXEC  KERNEL_BINARY BOOTLOADER)

#if the class is library and executable then defined its relase target for Follows 
LOCAL_filter_RELEASE_TARGET := $(filter $(LOCAL_INSTALLED_RELEASE),$(LOCAL_INSTALLED) $(LOCAL_BUILT_MODULE))

ifdef LOCAL_filter_RELEASE_TARGET
$(call __ndk_info,$(LOCAL_PATH)/make.mk:$(LOCAL_MODULE):ERROR:Illegal release path '$(sort $(dir $(LOCAL_filter_RELEASE_TARGET)))'.)
$(call __ndk_error,Abort ...)
endif

ifeq ($(call module-is-installed-release,$(LOCAL_MODULE)),$(true))

#we are want to rebuild every time.
.PHONY: $(LOCAL_INSTALLED_RELEASE)

#create the every one file's parent dir.
$(foreach release,$(LOCAL_INSTALLED_RELEASE),\
$(call generate-file-dir,$(release)))


#if the LOCAL_MODULE is prebuilt module. we are depends LOCAL_SRC_FILES(LOCAL_OBJECTS)  
ifneq (,$(filter PREBUILT%,$(call module-get-class,$(LOCAL_MODULE))))
$(LOCAL_INSTALLED_RELEASE):$(LOCAL_OBJECTS)
	@$(HOST_ECHO) "Release[preb]  : $(notdir $<) => $@"
	@$(call host-cp,$<,$@)

else #Not prebuit moddules.

#its sharedLibrary staticLibrary executable(test/exe) for follows.
ifeq ($(NDK_APP_OPTIM),release)
$(LOCAL_INSTALLED_RELEASE):$(LOCAL_INSTALLED)
	@$(HOST_ECHO) "Release        : $(notdir $<) => $@"
	@$(call host-cp,$<,$@)
else #It is debug mode.
$(LOCAL_INSTALLED_RELEASE):$(LOCAL_BUILT_MODULE)
	@$(HOST_ECHO) "Release[debug] : $(notdir $<) => $@"
	@$(call host-cp,$<,$@)
endif
endif #ifneq (,$(filter PREBUILT%,

$(call add-target-module,$(LOCAL_MODULE),$(LOCAL_INSTALLED_RELEASE))

endif #(163) ifeq ($(call module-is-installed-release

endif #ifneq (,$(filter THRID_PARTY_EXEC  KERNEL_BINARY BOOTLOADER,$(call module-get-class,$(LOCAL_MODULE))))
