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

# this file is included repeatedly from build/core/main.mk
# and is used to prepare for app-specific build rules.
#

$(call assert-defined,_app)

_map := NDK_APP.$(_app)

# ok, let's parse all Android.mk source files in order to build
# the modules for this app.
#

# Restore the APP_XXX variables just for this pass as NDK_APP_XXX
#
NDK_APP_NAME           := $(_app)
NDK_APP_APPLICATION_MK := $(call get,$(_map),Application.mk)

$(foreach __name,$(NDK_APP_VARS),\
  $(eval NDK_$(__name) := $(call get,$(_map),$(__name)))\
)

# make the application depend on the modules it requires
.PHONY: ndk-app-$(_app)
ndk-app-$(_app): $(NDK_APP_MODULES)
all: ndk-app-$(_app)

# which platform/abi/toolchain are we going to use?
TARGET_ARCH := $(call get,$(_map),APP_ARCH)
ifeq ($(words $(TARGET_ARCH)),1)
  TARGET_ARCH :=$(strip $(filter $(TARGET_ARCH),$(NDK_ALL_ARCHS)))
else
 TARGET_ARCH :=$(empty)
endif
ifndef TARGET_ARCH
$(call __ndk_info, Invalid ARCH '$(TARGET_ARCH)')
$(call __ndk_error,Aborting...)
endif

TARGET_PLATFORM := $(call get,$(_map),APP_PLATFORM)
ifneq ($(words $(TARGET_PLATFORM)),1)
  TARGET_PLATFORM :=$(empty)
endif

ifndef TARGET_PLATFORM
$(call __ndk_info, Invalid platform '$(TARGET_PLATFORM)')
$(call __ndk_error,Aborting...)
endif

TARGET_ABI := $(call get,$(_map),APP_ABI)
TARGET_ABI := $(filter $(TARGET_ABI),$(NDK_ALL_ABIS))
ifeq ($(words $(TARGET_ABI)),1)
  TARGET_ABI :=$(strip $(if $(patsubst $(TARGET_ARCH)%,,$(TARGET_ABI)),,$(TARGET_ABI)))
else
 TARGET_ABI :=
endif
ifndef TARGET_ABI
 $(call __ndk_info,The current ARCH '$(TARGET_ARCH)' and ABI '$(APP_ABI)' settings not match.)
 $(call __ndk_info,Please fix the APP_ABI definition in $(NDK_APP_APPLICATION_MK))
 $(call __ndk_error,Aborting...)
endif

NDK_APP_ABI :=$(TARGET_ABI)

TARGET_BOARD := $(call get,$(_map),APP_BOARD)
ifneq ($(words $(TARGET_BOARD)),1)
  TARGET_BOARD :=$(empty)
endif

ifndef TARGET_BOARD
$(call __ndk_info, Invalid board '$(TARGET_BOARD)')
$(call __ndk_error,Aborting...)
endif

TARGET_VENDOR := $(call get,$(_map),APP_VENDOR)

TARGET_WORKSPACE := $(call get,$(_map),APP_WORKSPACE)
TARGET_SDK_DIR := $(call get,$(_map),APP_SDK_DIR)
TARGET_LSP_DIR := $(call get,$(_map),APP_LSP_DIR)
TARGET_RELEASE_DIR := $(call get,$(_map),APP_RELEASE_DIR)
TARGET_ALIAS_BOARD := $(call get,$(_map),APP_ALIAS_BOARD)

__ndk_TARGET_WORKSPACE := $(strip $(wildcard $(TARGET_WORKSPACE)))
__ndk_TARGET_SDK_DIR := $(strip $(wildcard $(TARGET_SDK_DIR)))
__ndk_TARGET_LSP_DIR := $(strip $(wildcard $(TARGET_LSP_DIR)))


ifeq ($(strip $(__ndk_TARGET_WORKSPACE)),)
$(call __ndk_info,Could not find workspace directory !)
$(call __ndk_info,Please define the APP_WORKSPACE variable to point to it.)
$(call __ndk_error,Abort ...)
endif

__ndk_all_relate_app_workspace :=$(sort TARGET_SDK_DIR TARGET_LSP_DIR )

#
#Args 1 : old TARGET_WORKSPACE
#Args 2 : new TARGET_WORKSPACE
#
__ndk_search_workspace = $(foreach v,$(__ndk_all_relate_app_workspace),\
						       $(eval $(call ndk_log,__ndk_$(v)=$($(v)))) \
							   $(eval __ndk_$(v) := $(patsubst $(1)/%,%,$($(v)))) \
							   $(eval $(call ndk_log,__ndk_$(v)=$(__ndk_$(v)))) \
							   $(eval __ndk_$(v) := $(wildcard $(strip $(2))/$(__ndk_$(v)))) \
							   $(eval $(call ndk_log,__ndk_$(v)=$(__ndk_$(v)))) \
							   $(eval __ndk_$(v) := $(patsubst %/,,$(strip $(wildcard $(__ndk_$(v))))))  \
							   $(eval $(call ndk_log,__ndk_$(v)=$(__ndk_$(v)))))


ifneq (2,$(words $(__ndk_TARGET_SDK_DIR) $(__ndk_TARGET_LSP_DIR)))
#need redirect target_workspace
  #search app_workspace 
  __ndk_TARGET_WORKSPACE := $(abspath $(SYSBUILD_ROOT)/..)
  $(call ndk_log,redo the search app_workspace in '$(__ndk_TARGET_WORKSPACE)')
  $(call __ndk_search_workspace,$(TARGET_WORKSPACE),$(__ndk_TARGET_WORKSPACE))
  TARGET_SDK_DIR := $(strip $(__ndk_TARGET_SDK_DIR))
  TARGET_LSP_DIR := $(strip $(__ndk_TARGET_LSP_DIR))
  ifdef TARGET_SDK_DIR
   ifdef TARGET_LSP_DIR
    $(call ndk_log,Updata invalid app_workspace '$(TARGET_WORKSPACE)' to '$(__ndk_TARGET_WORKSPACE)')
    #the release dir maby no create. it must be $(TARGET_WORKSPACE) prefixe ?
    TARGET_RELEASE_DIR := $(patsubst $(TARGET_WORKSPACE)/%,$(__ndk_TARGET_WORKSPACE)/%,$(TARGET_RELEASE_DIR))
    #update TARGET_WORKSPACE
    TARGET_WORKSPACE := $(strip $(__ndk_TARGET_WORKSPACE))
    #keep synchronized
    APP_WORKSPACE := $(strip $(TARGET_WORKSPACE))
    APP_SDK_DIR := $(strip $(TARGET_SDK_DIR))
    APP_LSP_DIR := $(strip $(TARGET_LSP_DIR))
    APP_RELEASE_DIR := $(strip $(TARGET_RELEASE_DIR))
   endif
  endif
else 
#Do't redirect target_workspace
 TARGET_SDK_DIR := $(patsubst %/,%,$(strip $(TARGET_SDK_DIR)))
 TARGET_LSP_DIR := $(patsubst %/,%,$(strip $(TARGET_LSP_DIR)))
 TARGET_RELEASE_DIR := $(patsubst %/,%,$(strip $(TARGET_RELEASE_DIR)))
endif

ifndef TARGET_RELEASE_DIR
#if no define TARGET_RELEASE_DIR
#use /tmp/sys_build_default_release_dir/$(strip $(LOCAL_MODULE))
#We don't care about its cleaning operations
#TARGET_RELEASE_DIR =/tmp/sys_build_default_release_dir/$(strip $(LOCAL_MODULE))
endif

ifneq (2,$(words $(TARGET_SDK_DIR) $(TARGET_LSP_DIR)))
#clear invalid value
#sub-make must be check it if by used.
TARGET_WORKSPACE := $(empty)
TARGET_LSP_DIR := $(empty)
TARGET_SDK_DIR := $(empty)
TARGET_RELEASE_DIR := $(empty)
$(call __ndk_info,WARNING: May be you are try Compiling a sub-make.)
$(call __ndk_info,     But the TARGET_SDK_DIR or TARGET_LSP_DIR variables no define.)
$(call __ndk_info,     They depends APP_WORKSPACE  directory. If you need to use them.) 
$(call __ndk_info,     Please define them or redefine the APP_WORKSPACE variable to point a valid workspace !)
endif

$(call ndk_log,------------------------------------------)
#$(call ndk_log,app_workspace=$(APP_WORKSPACE))
#$(call ndk_log,app_sdk_dir=$(APP_SDK_DIR))
#$(call ndk_log,app_lsp_dir=$(APP_LSP_DIR))
#$(call ndk_log,app_release_dir=$(APP_RELEASE_DIR))
$(call ndk_log,target_workspace=$(TARGET_WORKSPACE))
$(call ndk_log,target_sdk_dir=$(TARGET_SDK_DIR))
$(call ndk_log,target_lsp_dir=$(TARGET_LSP_DIR))
$(call ndk_log,target_release_dir=$(TARGET_RELEASE_DIR))
$(call ndk_log,------------------------------------------)

# The ABI(s) to use
NDK_APP_ABI := $(strip $(NDK_APP_ABI))
ifndef NDK_APP_ABI
    # the default ABI for now is armeabi
    NDK_APP_ABI := armeabi
endif

NDK_ABI_FILTER := $(strip $(NDK_ABI_FILTER))
ifdef NDK_ABI_FILTER
    $(eval $(NDK_ABI_FILTER))
endif

# If APP_ABI is 'all', then set it to all supported ABIs
# Otherwise, check that we don't have an invalid value here.
#
ifeq ($(NDK_APP_ABI),all)
    NDK_APP_ABI := $(NDK_KNOWN_ABIS)
else
    # Plug in the unknown
    _unknown_abis := $(strip $(filter-out $(NDK_ALL_ABIS),$(NDK_APP_ABI)))
    ifneq ($(_unknown_abis),)
        ifeq (1,$(words $(filter-out $(NDK_KNOWN_ARCHS),$(NDK_FOUND_ARCHS))))
            ifneq ($(filter %bcall,$(_unknown_abis)),)
                 _unknown_abis_prefix := $(_unknown_abis:%bcall=%)
                 NDK_APP_ABI := $(NDK_KNOWN_ABIS:%=$(_unknown_abis_prefix)bc%)
            else
                ifneq ($(filter %all,$(_unknown_abis)),)
                    _unknown_abis_prefix := $(_unknown_abis:%all=%)
                    NDK_APP_ABI := $(NDK_KNOWN_ABIS:%=$(_unknown_abis_prefix)%)
                else
                    $(foreach _abi,$(NDK_KNOWN_ABIS),\
                        $(eval _unknown_abis := $(subst $(_abi),,$(subst bc$(_abi),,$(_unknown_abis)))) \
                    )
                    _unknown_abis_prefix := $(sort $(_unknown_abis))
                endif
            endif
            ifeq (1,$(words $(_unknown_abis_prefix)))
                NDK_APP_ABI := $(subst $(_unknown_abis_prefix),$(filter-out $(NDK_KNOWN_ARCHS),$(NDK_FOUND_ARCHS)),$(NDK_APP_ABI))
            endif
        endif
    endif
    # check the target ABIs for this application
    _bad_abis = $(strip $(filter-out $(NDK_ALL_ABIS),$(NDK_APP_ABI)))
    ifneq ($(_bad_abis),)
        $(call __ndk_info,NDK Application '$(_app)' targets unknown ABI(s): $(_bad_abis))
        $(call __ndk_info,Please fix the APP_ABI definition in $(NDK_APP_APPLICATION_MK))
        $(call __ndk_error,Aborting)
    endif
endif

# Clear all installed binaries for this application
# This ensures that if the build fails, you're not going to mistakenly
# package an obsolete version of it. Or if you change the ABIs you're targetting,
# you're not going to leave a stale shared library for the old one.
#

#Temporarily no need it.
#ifeq ($(NDK_APP.$(_app).cleaned_binaries),)
#    NDK_APP.$(_app).cleaned_binaries := true
#    clean-installed-binaries::
#	$(hide) $(call host-rm,$(NDK_APP_LIBS_OUT)/$(TARGET_ARCH)/$(TARGET_ABI)/$(TARGET_PLATFORM)/$(TARGET_BOARD)/*)
#endif

$(foreach _abi,$(NDK_APP_ABI),\
    $(eval TARGET_ARCH_ABI := $(_abi))\
    $(eval include $(BUILD_SYSTEM)/setup-abi.mk) \
)
