# Copyright (C) 2009 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# this file is included repeatedly from build/core/setup-abi.mk and is used
# to setup the target toolchain for a given platform/abi combination.
#

$(call assert-defined,TARGET_PLATFORM TARGET_ARCH TARGET_ARCH_ABI TARGET_ABI)

CURRENT_TARGET_ARCH :=
ifeq ($(TARGET_ARCH),x86)
 CURRENT_TARGET_ARCH :=X86
endif
ifeq ($(TARGET_ARCH),arm)
 CURRENT_TARGET_ARCH :=ARM
endif
ifeq ($(TARGET_ARCH),arm64)
 CURRENT_TARGET_ARCH :=ARM64
endif
ifeq ($(TARGET_ARCH),mips)
 CURRENT_TARGET_ARCH :=MIPS
endif
ifeq ($(TARGET_ARCH),powerpc)
 CURRENT_TARGET_ARCH :=PPC
endif

TOOLCHAIN_PREFIX := $(strip $(APP_$(CURRENT_TARGET_ARCH)_TOOLCHAIN))

ifndef TOOLCHAIN_PREFIX
$(call __ndk_warning,"Invalid APP_$(CURRENT_TARGET_ARCH)_TOOLCHAIN defined \
	in the `$(_application_mk)`. using `gcc/g++($(HOST_ARCH))` as default.")
endif

NDK_APP_TOOLCHAIN_SYSROOT := $(wildcard $(NDK_APP_TOOLCHAIN_SYSROOT))

ifdef NDK_APP_TOOLCHAIN_SYSROOT
 SYSROOT_INC := $(strip $(NDK_APP_TOOLCHAIN_SYSROOT))
 SYSROOT_LINK := $(SYSROOT_INC)
endif

# Define default values for TOOLCHAIN_NAME, this can be overriden in
# the setup file.
TOOLCHAIN_NAME   := $(notdir $(TOOLCHAIN_PREFIX)) 
TOOLCHAIN_VERSION_temp := $(shell $(TOOLCHAIN_PREFIX)gcc --version) 
TOOLCHAIN_VERSION := $(firstword $(shell echo "$(TOOLCHAIN_VERSION_temp)" | grep -oE "[1-9]\.[1-9]\.[1-9]"))
ifndef TOOLCHAIN_VERSION
  TOOLCHAIN_VERSION := $(firstword $(shell echo "$(TOOLCHAIN_VERSION_temp)" | grep -oE "[1-9]\.[1-9]"))
endif

# Define the root path of the toolchain in the NDK tree.
TOOLCHAIN_ROOT   := $(strip $(patsubst %/,%,$(dir $(shell which $(TOOLCHAIN_PREFIX)gcc))))

$(call ndk_log,Current App platform: $(TARGET_PLATFORM))
$(call ndk_log,Current App arch: $(TARGET_ARCH))
$(call ndk_log,Current App abi: $(TARGET_ABI))
$(call ndk_log,Current App toolchain: $(TOOLCHAIN_PREFIX))

$(call ndk_log,TOOLCHAIN_NAME : $(TOOLCHAIN_NAME))
$(call ndk_log,TOOLCHAIN_ROOT : $(TOOLCHAIN_ROOT))
$(call ndk_log,TOOLCHAIN_VERSION : $(TOOLCHAIN_VERSION))
$(call ndk_log,TOOLCHAIN_SYSROOT : $(NDK_APP_TOOLCHAIN_SYSROOT))

# We expect the gdbserver binary for this toolchain to be located at its root.

# compute NDK_APP_DST_DIR as the destination directory for the generated files
$(call init-relate-path)

ifdef NDK_LOG
$(foreach mode,$(default-relate-mode),\
  $(call ndk_log,Relate Mode($(mode)):obj  path: $(call get-relate-path,$(mode),obj))\
  $(call ndk_log,Relate Mode($(mode)):libs Path: $(call get-relate-path,$(mode),libs))\
)
endif


NDK_APP_DST_DIR := $(NDK_APP_LIBS_OUT)/$(TARGET_ARCH)/$(TARGET_ABI)/$(TARGET_PLATFORM)/$(TARGET_BOARD)
# Default build commands, can be overriden by the toolchain's setup script
include $(BUILD_SYSTEM)/default-build-commands.mk

ifdef __USE_NDK__
# now call the toolchain-specific setup script
include $(NDK_TOOLCHAIN.$(TARGET_TOOLCHAIN).setup)
endif #__USE_NDK__

-include $(SYSBUILD_ROOT)/build/configs/$(TARGET_ARCH)/$(TARGET_PLATFORM)/compiler.mk

ifdef SYSROOT_INC
TARGET_C_INCLUDES += $(SYSROOT_INC)/usr/include
endif

$(call ndk_log ,Skiping include $$(NDK_TOOLCHAIN.$$(TARGET_TOOLCHAIN).setup))
$(call ndk_log ,Skiping include $(NDK_TOOLCHAIN.$(TARGET_TOOLCHAIN).setup))
clean-installed-binaries::

# free the dictionary of LOCAL_MODULE definitions
$(call modules-clear)


# now parse the Android.mk for the application, this records all
# module declarations, but does not populate the dependency graph yet.
$(call ndk_log,Include $(notdir $(NDK_APP_BUILD_SCRIPT)) path $(NDK_APP_BUILD_SCRIPT))
include $(NDK_APP_BUILD_SCRIPT)

ifdef NDK_APP_STL
$(foreach ndk_app_stl,$(NDK_APP_STL),\
$(call ndk-stl-select,$(ndk_app_stl))\
$(call ndk-stl-add-dependencies,$(ndk_app_stl)))
endif

# recompute all dependencies between modules
$(call modules-compute-dependencies)

# for debugging purpose
ifdef NDK_DEBUG_MODULES
$(call modules-dump-database)
endif

# now, really build the modules, the second pass allows one to deal
# with exported values
$(foreach __pass2_module,$(__ndk_modules),\
    $(eval LOCAL_MODULE := $(__pass2_module))\
    $(eval include $(BUILD_SYSTEM)/build-binary.mk)\
)

# Now compute the closure of all module dependencies.
#
# If APP_MODULES is not defined in the Application.mk, we
# will build all modules that were listed from the top-level Android.mk
# and the installable imported ones they depend on
#
ifeq ($(strip $(NDK_APP_MODULES)),)

#we are want to building all modules.
#    WANTED_MODULES := $(call modules-get-all-installable,$(modules-get-top-list))
    WANTED_MODULES := $(call modules-get-top-list)
    ifeq (,$(strip $(WANTED_MODULES)))
        WANTED_MODULES := $(modules-get-top-list)
        $(call ndk_log,[$(TARGET_ARCH_ABI)] No installable modules in project - forcing static library build)
    endif
else
    WANTED_MODULES := $(call module-get-all-dependencies,$(NDK_APP_MODULES))
endif

#addprefix $(TARGET_OUT)/MeduleName
WANTED_INSTALLED_MODULES += $(call map,module-get-installed,$(WANTED_MODULES))


ifdef NDK_LOG
$(call ndk_log,[$(TARGET_ARCH_ABI)] Modules to build: $(WANTED_MODULES))
$(call ndk_log,----------------------------------------------------------------------------)
$(foreach module,$(WANTED_MODULES) $(call get-default-fake-modules),\
	$(call ndk_log,Module:$(module)[$(call module-get-class,$(module))])\
$(call ndk_log,Target:)\
$(foreach target,$(call get-target-module-list,$(module)),$(call ndk_log,   $(target)))\
$(call ndk_log, ) \
)
$(call ndk_log,----------------------------------------------------------------------------)
endif

ifndef __ndk_app_all_targets
__ndk_app_all_targets := $(foreach module,$(WANTED_MODULES) $(call get-default-fake-modules),\
 $(call get-target-module-list,$(module)))
endif

#if the target contain '~' character.
__ndk_app_all_targets := $(subst ~,$(HOME),$(__ndk_app_all_targets))
__ndk_ap_all_targets_count_old := $(words $(__ndk_app_all_targets))
__ndk_ap_all_targets_count_new := $(words $(sort $(__ndk_app_all_targets)))


#if target conflict then find the targets.
$(if $(call seq,$(__ndk_ap_all_targets_count_old),$(__ndk_ap_all_targets_count_new)),,\
  $(foreach target,$(__ndk_app_all_targets), \
   $(if $(call set_is_member,$(__ndk_app_all_targets_for_modules),$(target)),\
  	 $(call __ndk_info,Target Conflict:$(target)),\
       $(eval __ndk_app_all_targets_for_modules := $(call set_insert,\
  	 $(__ndk_app_all_targets_for_modules),$(target))) \
  ))\
 $(call __ndk_info,Detection the target conflict \
 ($(__ndk_ap_all_targets_count_new)/$(__ndk_ap_all_targets_count_old)) and please correct error.) \
 $(call __ndk_error,Abort ...)\
 )
