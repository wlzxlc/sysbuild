# Copyright (C) 2009-2010 The Android Open Source Project
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

#
# This script is used to build all wanted NDK binaries. It is included
# by several scripts.
#

# ensure that the following variables are properly defined
$(call assert-defined,NDK_APPS NDK_APP_OUT)

# ====================================================================
#
# Prepare the build for parsing Android.mk files
#
# ====================================================================

# These phony targets are used to control various stages of the build
__ndk_app_all_build_targets := \
        all \
        host_libraries host_executables \
        installed_modules \
        executables libraries static_libraries shared_libraries \
        clean clean-objs-dir \
        clean-executables clean-libraries \
        clean-installed-modules \
        clean-installed-binaries \
        tag-so \
        tag-a \
        tag-exe \
        tag-test \
        tag-kernel \
        tag-bootloader \
        tag-th3 \
        help \
        modules

.PHONY: $(__ndk_app_all_build_targets)

$(call add-target-module,default,$(__ndk_app_all_build_targets))
# the first rule
all: installed_modules host_libraries host_executables



help:
	$(cmd_sys_build_help_info)

modules:
	@echo "------------------------------------------"
	@echo "ShareLibrary modules:"
	@echo " $(notdir $(ALL_SHARED_LIBRARIES))"
	@echo "StaticLibrary modules:"
	@echo " $(notdir $(ALL_STATIC_LIBRARIES))"
	@echo "Executable modules:"
	@echo " $(notdir $(ALL_EXECUTABLES))"
	@echo "Kernel modules:"
	@$(call print_module_files,$(ALL_KERNEL_BINARYS))
	@echo "Bootloader modules:"
	@$(call print_module_files,$(ALL_BOOTLOADERS))
	@echo "TestProgram modules:"
	@echo " $(notdir $(ALL_TESTS))"
	@echo "ThirdpartBinary modules:"
	@$(call print_module_files,$(ALL_THIRD_PARTY_EXECS))
	@echo "Prebuit modules:"
	@echo " $(notdir $(ALL_PREBUIT_LIBRARIES))"
	@echo "------------------------------------------"

	
# These macros are used in Android.mk to include the corresponding
# build script that will parse the LOCAL_XXX variable definitions.
#
CLEAR_VARS                := $(BUILD_SYSTEM)/clear-vars.mk
BUILD_HOST_EXECUTABLE     := $(BUILD_SYSTEM)/build-host-executable.mk
BUILD_HOST_STATIC_LIBRARY := $(BUILD_SYSTEM)/build-host-static-library.mk
BUILD_STATIC_LIBRARY      := $(BUILD_SYSTEM)/build-static-library.mk
BUILD_SHARED_LIBRARY      := $(BUILD_SYSTEM)/build-shared-library.mk
BUILD_EXECUTABLE          := $(BUILD_SYSTEM)/build-executable.mk
PREBUILT_SHARED_LIBRARY   := $(BUILD_SYSTEM)/prebuilt-shared-library.mk
PREBUILT_STATIC_LIBRARY   := $(BUILD_SYSTEM)/prebuilt-static-library.mk
BUILD_TH3_BINARY	      := $(BUILD_SYSTEM)/build-th3-binary.mk
BUILD_KERNEL              := $(BUILD_SYSTEM)/build-kernel-img.mk
BUILD_BOOTLOADER          := $(BUILD_SYSTEM)/build-bootloader-img.mk
BUILD_TEST                := $(BUILD_SYSTEM)/build-test-exe.mk

ANDROID_MK_INCLUDED := \
  $(CLEAR_VARS) \
  $(BUILD_HOST_EXECUTABLE) \
  $(BUILD_HOST_STATIC_LIBRARY) \
  $(BUILD_STATIC_LIBRARY) \
  $(BUILD_SHARED_LIBRARY) \
  $(BUILD_EXECUTABLE) \
  $(PREBUILT_SHARED_LIBRARY) \
  $(PREBUILT_STATIC_LIBRARY) \
  $(BUILD_TH3_BINARY) \
  $(BUILD_KERNEL) \
  $(BUILD_BOOTLOADER) \
  $(BUILD_TEST)


# this is the list of directories containing dependency information
# generated during the build. It will be updated by build scripts
# when module definitions are parsed.
#
ALL_DEPENDENCY_DIRS :=

# this is the list of all generated files that we would need to clean
ALL_HOST_EXECUTABLES      :=
ALL_HOST_STATIC_LIBRARIES :=
ALL_STATIC_LIBRARIES      :=
ALL_SHARED_LIBRARIES      :=
ALL_EXECUTABLES           :=
ALL_KERNEL_BINARYS        :=
ALL_TESTS                 :=
ALL_BOOTLOADERS           :=
ALL_THIRD_PARTY_EXECS     :=
ALL_PREBUIT_LIBRARIES     :=
WANTED_INSTALLED_MODULES  :=


$(ndk_log ,NDK_APPS: $(NDK_APPS))
$(foreach _app,$(NDK_APPS),\
  $(eval include $(BUILD_SYSTEM)/setup-app.mk)\
)

ifeq (,$(strip $(WANTED_INSTALLED_MODULES)))
    ifneq (,$(strip $(NDK_APP_MODULES)))
        $(call __ndk_warning,WARNING: No modules to build, your APP_MODULES definition is probably incorrect!)
    else
        $(call __ndk_warning,WARNING: There are no modules to build in this project!)
    endif
endif

# ====================================================================
#
# Now finish the build preparation with a few rules that depend on
# what has been effectively parsed and recorded previously
#
# ====================================================================

clean: clean-intermediates clean-installed-binaries

distclean: clean

installed_modules: clean-installed-binaries libraries $(WANTED_INSTALLED_MODULES)
host_libraries: $(HOST_STATIC_LIBRARIES)
host_executables: $(HOST_EXECUTABLES)

static_libraries: $(STATIC_LIBRARIES)
shared_libraries: $(SHARED_LIBRARIES)
executables: $(EXECUTABLES)

tag-so: clean-installed-binaries shared_libraries $(call map,module-get-installed,\
         $(patsubst lib%.so,%,$(notdir $(ALL_SHARED_LIBRARIES))))
	@$(call ndk_log,All SharedLibrary target:$(call map,module-get-installed,$(patsubst lib%.so,%,$(notdir $(ALL_SHARED_LIBRARIES)))))
tag-a: clean-installed-binaries static_libraries $(call map,module-get-installed,\
         $(patsubst lib%.a,%,$(notdir $(ALL_STATIC_LIBRARIES))))
	@$(call ndk_log,All StaticLibrary target:$(ALL_STATIC_LIBRARIES))

tag-exe: clean-installed-binaries executables $(call map,module-get-installed,$(notdir $(ALL_EXECUTABLES)))
	@$(call ndk_log,All Executable target:$(call map,module-get-installed,$(notdir $(ALL_EXECUTABLES))))
 
tag-test: clean-installed-binaries $(call map,module-get-installed,$(notdir $(ALL_TESTS)))
	@$(call ndk_log,All Test target:$(call map,module-get-installed,$(notdir $(ALL_TESTS)))) 
tag-kernel: clean-installed-binaries $(call map,module-get-installed,$(notdir $(ALL_KERNEL_BINARYS)))
	@$(call ndk_log,All Kernel target:$<) 
tag-bootloader: clean-installed-binaries $(call map,module-get-installed,$(notdir $(ALL_BOOTLOADERS)))
	@$(call ndk_log,All Bootloader target:$(ALL_BOOTLOADERS))
tag-th3: clean-installed-binaries $(call map,module-get-installed,$(notdir $(ALL_THIRD_PARTY_EXECS)))
	@$(call ndk_log,All Th3Binary target:$(ALL_THIRD_PARTY_EXECS)) 

libraries: static_libraries shared_libraries

clean-host-intermediates:
#	$(hide) $(call host-rm,$(HOST_EXECUTABLES) $(HOST_STATIC_LIBRARIES))

#Temporarily no need it.
clean-intermediates: clean-host-intermediates
#	$(hide) $(call host-rm,$(ALL_EXECUTABLES) $(ALL_STATIC_LIBRARIES) $(ALL_SHARED_LIBRARIES))

ifeq ($(HOST_OS),cygwin)
clean: clean-dependency-converter
endif
	
# include dependency information
ALL_DEPENDENCY_DIRS := $(patsubst %/,%,$(sort $(ALL_DEPENDENCY_DIRS)))
-include $(wildcard $(ALL_DEPENDENCY_DIRS:%=%/*.d))
